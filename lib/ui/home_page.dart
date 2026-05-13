import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../data/controller.dart';
import 'task_card_factory.dart';
import 'widgets/executor_drawer.dart';
import 'result_dashboard.dart';
import 'completed_tasks_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final ExecutorController _controller = ExecutorController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
    _controller.init();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _sharePlan() {
    final json = _controller.exportPlanToJson();
    Share.share(json, subject: 'План работ');
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
          decoration: const InputDecoration(hintText: 'Вставьте JSON отчет', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('ОТМЕНА')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            onPressed: () {
              _controller.importProgressFromJson(importCtrl.text);
              Navigator.pop(context);
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_controller.resultText)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        if (!_controller.isInitialized) return const Scaffold(body: Center(child: CircularProgressIndicator()));
        if (_controller.currentExecutor.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Лесной Прогноз')),
            drawer: ExecutorDrawer(controller: _controller),
            body: Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.person_add),
                label: const Text('Создать исполнителя'),
                onPressed: () => _showAddExecutorDialog(),
              ),
            ),
          );
        }

        final bool isPlanTab = _tabController.index == 0;
        String start = "${_controller.startDate.day}.${_controller.startDate.month}.${_controller.startDate.year}";

        return Scaffold(
          appBar: AppBar(
            title: Text(_controller.currentExecutor),
            actions: [
              if (isPlanTab) ...[
                IconButton(icon: const Icon(Icons.share, color: Colors.red), tooltip: 'Поделиться планом', onPressed: _sharePlan),
                IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: _controller.addTask),
              ],
              if (!isPlanTab) ...[
                IconButton(icon: const Icon(Icons.play_circle_fill, color: Colors.yellow, size: 30), onPressed: _runModeling),
                IconButton(icon: const Icon(Icons.paste, color: Colors.green), tooltip: 'Вставить отчёт', onPressed: _showImportDialog),
              ],
            ],
            bottom: TabBar(controller: _tabController, indicatorColor: Colors.white, tabs: const [Tab(text: 'План'), Tab(text: 'Результат')]),
          ),
          drawer: ExecutorDrawer(controller: _controller),
          body: TabBarView(
            controller: _tabController,
            children: [
              // План
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Старт: $start", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          TextButton.icon(
                            icon: const Icon(Icons.calendar_month),
                            label: const Text("Изменить"),
                            onPressed: () async {
                              DateTime? picked = await showDatePicker(context: context, initialDate: _controller.startDate, firstDate: DateTime(2020), lastDate: DateTime(2030));
                              if (picked != null) _controller.setStartDate(picked);
                            },
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _controller.tasks.isEmpty
                          ? const Center(child: Text("Нет этапов"))
                          : ListView.builder(
                              itemCount: _controller.tasks.length,
                              itemBuilder: (context, i) => TaskCardFactory.build(context, i, _controller, _controller.startDate),
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
          ElevatedButton(onPressed: () { _controller.createNewExecutor(textCtrl.text); Navigator.pop(ctx); }, child: const Text('СОЗДАТЬ')),
        ],
      ),
    );
  }
}
