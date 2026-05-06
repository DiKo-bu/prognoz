import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/controller.dart';
import 'parts.dart';
import 'widgets/executor_drawer.dart';
import 'result_dashboard.dart';

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

  void _runModeling() {
    _controller.runSimulation();
    // Если есть ошибка, покажем снэкбар и не пойдём на дашборд
    if (_controller.resultText.startsWith("ОШИБКА")) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_controller.resultText)),
      );
    } else if (_controller.ganttData.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultDashboardScreen(controller: _controller),
        ),
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

        String startDay = _controller.startDate.day.toString().padLeft(2, '0');
        String startMonth = _controller.startDate.month.toString().padLeft(2, '0');
        String startYear = _controller.startDate.year.toString();

        return Scaffold(
          appBar: AppBar(
            title: Text(_controller.currentExecutor, style: const TextStyle(fontSize: 18)),
            actions: [
              // Иконка моделирования
              IconButton(
                icon: const Icon(Icons.play_circle_fill, color: Colors.yellow, size: 30),
                tooltip: 'Выполнить моделирование',
                onPressed: _runModeling,
              ),
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
                // Список этапов
                Expanded(
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
          ElevatedButton(onPressed: () {
            _controller.createNewExecutor(textCtrl.text);
            Navigator.pop(ctx);
          }, child: const Text('СОЗДАТЬ')),
        ],
      ),
    );
  }
}
