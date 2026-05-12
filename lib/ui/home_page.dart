import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../data/controller.dart';
import 'task_input_card.dart';
import 'widgets/executor_drawer.dart';
import 'result_dashboard.dart';
import 'completed_tasks_view.dart';
import 'callbacks/planting_callbacks.dart';
import 'callbacks/sowing_callbacks.dart';
import 'callbacks/selective_cutting_callbacks.dart';
import 'callbacks/clear_cutting_callbacks.dart';
import 'callbacks/clearing_callbacks.dart';
import 'callbacks/panels_callbacks.dart';
import 'callbacks/general_field_callbacks.dart';
import 'callbacks/base_task_callbacks.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final ExecutorController _controller = ExecutorController();
  late TabController _tabController;
  MqttServerClient? _mqttClient;
  String? _mqttError;

  static const String broker = 'receiving-guards-success-lasting.trycloudflare.com';
  static const int port = 1883;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
    _controller.init();
    _setupMqtt();
  }

  @override
  void dispose() {
    _mqttClient?.disconnect();
    _tabController.dispose();
    _controller.dispose();
    super.dispose();
  }

  /// Резолвим домен через HTTPS-запрос к Cloudflare DoH
  Future<String> _resolveHost(String host) async {
    try {
      final url = Uri.https('cloudflare-dns.com', '/dns-query', {'name': host, 'type': 'A'});
      final response = await http.get(url, headers: {'Accept': 'application/dns-json'});
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['Answer'] != null && data['Answer'].isNotEmpty) {
          final ip = data['Answer'][0]['data'];
          print('DNS OK: $host → $ip');
          return ip;
        }
      }
    } catch (e) {
      print('DNS HTTP error: $e');
    }
    return host; // fallback – вернём исходный домен
  }

  Future<void> _setupMqtt() async {
    final ip = await _resolveHost(broker);
    _mqttClient = MqttServerClient(ip, '');
    _mqttClient!.port = port;
    _mqttClient!.logging(on: false);
    _mqttClient!.keepAlivePeriod = 20;

    final connMessage = MqttConnectMessage()
        .withClientIdentifier('prognoz_${_controller.currentExecutor}')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    _mqttClient!.connectionMessage = connMessage;

    try {
      await _mqttClient!.connect();
    } catch (e) {
      _mqttError = 'Ошибка подключения: $e';
      setState(() {});
      return;
    }

    if (_mqttClient!.connectionStatus?.state == MqttConnectionState.connected) {
      _mqttClient!.subscribe('forest/broadcast', MqttQos.atLeastOnce);
      _mqttClient!.updates!.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
        final msg = messages[0].payload as MqttPublishMessage;
        final payload = MqttPublishPayload.bytesToStringAsString(msg.payload.message);
        _controller.importProgressFromJson(payload);
      });
    } else {
      _mqttError = 'Статус: ${_mqttClient?.connectionStatus?.state}';
      setState(() {});
    }
  }

  void _exportPlanViaMqtt() {
    const testTopic = 'forest/reports';
    const testPayload = '{"plan_id":"plant_101", "actual":500, "completed":true}';

    if (_mqttClient?.connectionStatus?.state == MqttConnectionState.connected) {
      _mqttClient!.publishMessage(
        testTopic,
        MqttQos.atLeastOnce,
        MqttClientPayloadBuilder().addString(testPayload).payload!,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Тестовое сообщение отправлено в forest/reports')),
      );
    } else {
      String reason = _mqttError ?? 'неизвестная причина';
      Clipboard.setData(ClipboardData(text: testPayload));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('MQTT не подключён ($reason) – сообщение скопировано в буфер')),
      );
    }
  }

  void _showImportDialog() {
    TextEditingController importCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Принять отчет с участка'),
        content: TextField(
          controller: importCtrl,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Вставьте код отчета (или придёт автоматически)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('ОТМЕНА')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            onPressed: () {
              _controller.importProgressFromJson(importCtrl.text);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Отчет принят вручную')),
              );
              _tabController.animateTo(1);
            },
            child: const Text('ОБНОВИТЬ ДАННЫЕ'),
          ),
        ],
      ),
    );
  }

  void _runModeling() {
    _controller.runSimulation();
    if (_controller.resultText.startsWith("ОШИБКА")) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_controller.resultText)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        if (!_controller.isInitialized)
          return const Scaffold(body: Center(child: CircularProgressIndicator()));

        if (_controller.currentExecutor.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Лесной Прогноз')),
            drawer: ExecutorDrawer(controller: _controller),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Нет выбранного исполнителя.', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.person_add),
                    label: const Text('Создать исполнителя'),
                    onPressed: () => _showAddExecutorDialog(),
                  ),
                ],
              ),
            ),
          );
        }

        final bool isPlanTab = _tabController.index == 0;
        String startDay = _controller.startDate.day.toString().padLeft(2, '0');
        String startMonth = _controller.startDate.month.toString().padLeft(2, '0');
        String startYear = _controller.startDate.year.toString();

        return Scaffold(
          appBar: AppBar(
            title: Text(_controller.currentExecutor, style: const TextStyle(fontSize: 18)),
            actions: [
              if (isPlanTab) ...[
                IconButton(
                  icon: const Icon(Icons.upload, color: Colors.red),
                  tooltip: 'Отправить тест',
                  onPressed: _exportPlanViaMqtt,
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: _controller.addTask,
                ),
              ],
              if (!isPlanTab) ...[
                IconButton(
                  icon: const Icon(Icons.play_circle_fill, color: Colors.yellow, size: 30),
                  tooltip: 'Моделирование',
                  onPressed: _runModeling,
                ),
                IconButton(
                  icon: const Icon(Icons.download_for_offline, color: Colors.green),
                  tooltip: 'Принять отчёт вручную',
                  onPressed: _showImportDialog,
                ),
              ],
            ],
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              tabs: const [
                Tab(text: 'План'),
                Tab(text: 'Результат'),
              ],
            ),
          ),
          drawer: ExecutorDrawer(controller: _controller),
          body: TabBarView(
            controller: _tabController,
            children: [
              // План
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Старт: $startDay.$startMonth.$startYear",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          TextButton.icon(
                            icon: const Icon(Icons.calendar_month),
                            label: const Text("Изменить"),
                            onPressed: () async {
                              DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: _controller.startDate,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                              );
                              if (picked != null) _controller.setStartDate(picked);
                            },
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _controller.tasks.isEmpty
                          ? const Center(child: Text("Нет этапов.", style: TextStyle(color: Colors.grey)))
                          : ListView.builder(
                              itemCount: _controller.tasks.length,
                              itemBuilder: (context, i) {
                                final task = _controller.tasks[i];
                                return TaskInputCard(
                                  id: task.id,
                                  title: task.name,
                                  min: task.min,
                                  likely: task.likely,
                                  max: task.max,
                                  depends: task.dependsOn.join(', '),
                                  isCompleted: task.isCompleted,
                                  actualDuration: task.actualDuration,
                                  actualEndDate: task.actualEndDate,
                                  projectStartDate: _controller.startDate,
                                  plantingType: task.plantingType,
                                  culture: task.culture,
                                  plantingQuantity: task.plantingQuantity,
                                  plantingArea: task.plantingArea,
                                  sowingBreed: task.sowingBreed,
                                  sowingQuantityKg: task.sowingQuantityKg,
                                  sowingAreaHa: task.sowingAreaHa,
                                  cuttingArea: task.cuttingArea,
                                  cuttingVolume: task.cuttingVolume,
                                  clearCuttingArea: task.clearCuttingArea,
                                  clearCuttingVolume: task.clearCuttingVolume,
                                  clearingArea: task.clearingArea,
                                  clearingVolume: task.clearingVolume,
                                  panelsQuantity: task.panelsQuantity,
                                  location: task.location,
                                  quarter: task.quarter,
                                  allotment: task.allotment,
                                  base: BaseTaskCallbacks(
                                    onCompletionChange: (v) => _controller.updateTaskCompletion(i, v),
                                    onActualDurationChange: (v) => _controller.updateTaskActualDuration(i, v),
                                    onTitleChange: (v) => _controller.updateTaskTitle(i, v),
                                    onDurationValuesChange: (key, val) => _controller.updateTaskValues(i, key, val),
                                    onDependsChange: (val) => _controller.updateTaskDepends(i, val),
                                    onDelete: () => _controller.removeTask(i),
                                  ),
                                  planting: task.name == 'Посадка'
                                      ? PlantingCallbacks(
                                          onTypeChange: (v) => _controller.updateTaskPlantingType(i, v),
                                          onCultureChange: (v) => _controller.updateTaskCulture(i, v),
                                          onQuantityChange: (v) => _controller.updateTaskPlantingQuantity(i, v),
                                          onAreaChange: (v) => _controller.updateTaskPlantingArea(i, v),
                                        )
                                      : null,
                                  sowing: task.name == 'Посев'
                                      ? SowingCallbacks(
                                          onBreedChange: (v) => _controller.updateTaskSowingBreed(i, v),
                                          onQuantityKgChange: (v) => _controller.updateTaskSowingQuantityKg(i, v),
                                          onAreaHaChange: (v) => _controller.updateTaskSowingAreaHa(i, v),
                                        )
                                      : null,
                                  selectiveCutting: task.name == 'Выборочная санитарная рубка'
                                      ? SelectiveCuttingCallbacks(
                                          onAreaChange: (v) => _controller.updateTaskCuttingArea(i, v),
                                          onVolumeChange: (v) => _controller.updateTaskCuttingVolume(i, v),
                                        )
                                      : null,
                                  clearCutting: task.name == 'Сплошная санитарная рубка'
                                      ? ClearCuttingCallbacks(
                                          onAreaChange: (v) => _controller.updateTaskClearCuttingArea(i, v),
                                          onVolumeChange: (v) => _controller.updateTaskClearCuttingVolume(i, v),
                                        )
                                      : null,
                                  clearing: task.name == 'Уборка захламленности'
                                      ? ClearingCallbacks(
                                          onAreaChange: (v) => _controller.updateTaskClearingArea(i, v),
                                          onVolumeChange: (v) => _controller.updateTaskClearingVolume(i, v),
                                        )
                                      : null,
                                  panels: task.name == 'Установка панно и аншлагов'
                                      ? PanelsCallbacks(
                                          onQuantityChange: (v) => _controller.updateTaskPanelsQuantity(i, v),
                                        )
                                      : null,
                                  general: GeneralFieldCallbacks(
                                    onLocationChange: (v) => _controller.updateTaskLocation(i, v),
                                    onQuarterChange: (v) => _controller.updateTaskQuarter(i, v),
                                    onAllotmentChange: (v) => _controller.updateTaskAllotment(i, v),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
              // Результат
              _controller.ganttData.isNotEmpty
                  ? ResultDashboard(controller: _controller)
                  : CompletedTasksView(tasks: _controller.tasks, startDate: _controller.startDate),
            ],
          ),
        );
      },
    );
  }

  void _showAddExecutorDialog() {
    TextEditingController textCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Новый исполнитель'),
        content: TextField(controller: textCtrl, decoration: const InputDecoration(hintText: 'ФИО исполнителя')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ОТМЕНА')),
          ElevatedButton(onPressed: () {
            _controller.createNewExecutor(textCtrl.text);
            Navigator.pop(ctx);
          }, child: const Text('СОЗДАТЬ')),
        ],
      ),
    );
  }
}
