import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/controller.dart';
import 'parts.dart';
import 'widgets/executor_drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ExecutorController _controller = ExecutorController();

  @override
  void initState() {
    super.initState();
    _controller.init();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
            hintText: 'Вставьте код отчета сюда...',
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
            },
            child: const Text('ОБНОВИТЬ ГРАФИК'),
          ),
        ],
      ),
    );
  }

  void _exportPlan() {
    final jsonStr = _controller.exportPlanToJson();
    Clipboard.setData(ClipboardData(text: jsonStr));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('План скопирован в буфер обмена')),
    );
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

        String startDay = _controller.startDate.day.toString().padLeft(2, '0');
        String startMonth = _controller.startDate.month.toString().padLeft(2, '0');
        String startYear = _controller.startDate.year.toString();

        return Scaffold(
          appBar: AppBar(
            title: Text(_controller.currentExecutor, style: const TextStyle(fontSize: 18)),
            actions: [
              IconButton(icon: const Icon(Icons.upload_file), tooltip: 'Экспорт плана', onPressed: _exportPlan),
              IconButton(icon: const Icon(Icons.download_for_offline), color: Colors.green, onPressed: _showImportDialog),
              IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: _controller.addTask),
            ],
          ),
          drawer: ExecutorDrawer(controller: _controller),
          body: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Старт: $startDay.$startMonth.$startYear", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      TextButton.icon(
                        icon: const Icon(Icons.calendar_month),
                        label: const Text("Изменить"),
                        onPressed: () async {
                          DateTime? picked = await showDatePicker(
                            context: context, initialDate: _controller.startDate,
                            firstDate: DateTime(2020), lastDate: DateTime(2030),
                          );
                          if (picked != null) _controller.setStartDate(picked);
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 6,
                  child: _controller.tasks.isEmpty
                      ? const Center(child: Text("Нет этапов. Нажмите '+' вверху экрана.", style: TextStyle(color: Colors.grey)))
                      : ListView.builder(
                          itemCount: _controller.tasks.length,
                          itemBuilder: (context, i) {
                            var task = _controller.tasks[i];
                            return TaskInputCard(
                              id: task.id,
                              title: task.name,
                              currentMin: task.min,
                              currentLikely: task.likely,
                              currentMax: task.max,
                              currentDepends: task.dependsOn.join(', '),
                              isCompleted: task.isCompleted,
                              actualDuration: task.actualDuration,
                              onCompletionChange: (v) => _controller.updateTaskCompletion(i, v),
                              onActualChange: (v) => _controller.updateTaskActualDuration(i, v),
                              onTitleChange: (v) => _controller.updateTaskTitle(i, v),
                              onUpdate: (key, val) => _controller.updateTaskValues(i, key, val),
                              onDependsChange: (val) => _controller.updateTaskDepends(i, val),
                              onDelete: () => _controller.removeTask(i),
                            );
                          },
                        ),
                ),
                if (_controller.resultText.isNotEmpty)
                  Expanded(
                    flex: 4,
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          children: [
                            Text(_controller.resultText, textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
                                    color: _controller.resultText.contains("ОШИБКА") ? Colors.red : Colors.green[700])),
                            const SizedBox(height: 10),
                            GanttChart(data: _controller.ganttData, totalDuration: _controller.p90Duration, startDate: _controller.startDate),
                            if (_controller.topRisks.isNotEmpty)
                              Container(
                                margin: const EdgeInsets.only(top: 15), padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(color: Colors.red.withOpacity(0.05), border: Border.all(color: Colors.red.withOpacity(0.3)), borderRadius: BorderRadius.circular(8)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(children: [Icon(Icons.warning_amber_rounded, color: Colors.red), SizedBox(width: 8), Text("КРИТИЧЕСКИЕ УЗЛЫ (Влияние на финиш)", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red))]),
                                    const SizedBox(height: 10),
                                    ..._controller.topRisks.map((risk) {
                                      double maxImpact = _controller.topRisks.first.impactDays;
                                      double fraction = maxImpact > 0 ? risk.impactDays / maxImpact : 0;
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 8.0),
                                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                          Text("${risk.taskName} (Угроза: +${risk.impactDays.toStringAsFixed(1)} дн.)", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                          const SizedBox(height: 4),
                                          LinearProgressIndicator(value: fraction, backgroundColor: Colors.red.withOpacity(0.1), color: Colors.red, minHeight: 8, borderRadius: BorderRadius.circular(4)),
                                        ]),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                SizedBox(width: double.infinity, height: 55,
                  child: ElevatedButton(onPressed: _controller.runSimulation, child: const Text("ВЫПОЛНИТЬ МОДЕЛИРОВАНИЕ")),
                ),
              ],
            ),
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
          ElevatedButton(onPressed: () { _controller.createNewExecutor(textCtrl.text); Navigator.pop(ctx); }, child: const Text('СОЗДАТЬ')),
        ],
      ),
    );
  }
}
