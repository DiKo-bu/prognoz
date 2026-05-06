import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/controller.dart';
import '../logic/engine.dart';
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Отчет принят, график перестроен')),
              );
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
                // Строка даты старта
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

                // Список этапов (задачи)
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

                // Блок результатов и диаграммы
                if (_controller.resultText.startsWith("ОШИБКА"))
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(_controller.resultText, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  ),

                if (_controller.ganttData.isNotEmpty)
                  Expanded(
                    flex: 5,
                    child: _buildDashboard(),
                  ),

                // Кнопка моделирования
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _controller.runSimulation,
                    child: const Text("ВЫПОЛНИТЬ МОДЕЛИРОВАНИЕ"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ===== ДАШБОРД =====
  Widget _buildDashboard() {
    final start = _controller.startDate;
    final p90 = _controller.p90Duration;
    final finishDate = start.add(Duration(days: p90.ceil()));
    final formattedFinish = "${finishDate.day.toString().padLeft(2, '0')}.${finishDate.month.toString().padLeft(2, '0')}.${finishDate.year}";

    // Собираем превышения
    final overMaxTasks = _controller.tasks.where((t) => t.isCompleted && t.actualDuration > t.max).toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Карточка ФИНИШ
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: const [
                      Icon(Icons.flag_circle, color: Colors.green, size: 28),
                      SizedBox(width: 8),
                      Text("Финиш (90%)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(formattedFinish, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green)),
                  const SizedBox(height: 4),
                  Text("${p90.toStringAsFixed(1)} рабочих дней", style: const TextStyle(fontSize: 16, color: Colors.grey)),
                ],
              ),
            ),
          ),

          // Карточка ПРЕДУПРЕЖДЕНИЯ (если есть превышения)
          if (overMaxTasks.isNotEmpty) ...[
            const SizedBox(height: 12),
            Card(
              color: Colors.orange.shade50,
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 24),
                        SizedBox(width: 8),
                        Text("Превышения максимума", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...overMaxTasks.map((t) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: Colors.red, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "${t.name}: факт ${t.actualDuration} дн. > макс ${t.max} дн.",
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ],

          // Карточка КРИТИЧЕСКИЕ УЗЛЫ (если есть)
          if (_controller.topRisks.isNotEmpty) ...[
            const SizedBox(height: 12),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.dangerous, color: Colors.red, size: 24),
                        SizedBox(width: 8),
                        Text("Критические узлы", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ..._controller.topRisks.map((risk) {
                      double maxImpact = _controller.topRisks.first.impactDays;
                      double fraction = maxImpact > 0 ? risk.impactDays / maxImpact : 0;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("${risk.taskName} (Угроза: +${risk.impactDays.toStringAsFixed(1)} дн.)",
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: fraction,
                              backgroundColor: Colors.red.shade100,
                              color: Colors.red,
                              minHeight: 8,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],

          // Диаграмма Ганта с легендой
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Диаграмма Ганта", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                GanttChart(
                  data: _controller.ganttData,
                  totalDuration: _controller.p90Duration,
                  startDate: _controller.startDate,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _legendItem(Colors.blue, "План"),
                    const SizedBox(width: 12),
                    _legendItem(Colors.green, "Выполнено"),
                    const SizedBox(width: 12),
                    _legendItem(Colors.red, "Превышение"),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 16, height: 16, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
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
