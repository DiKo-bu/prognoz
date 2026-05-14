import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';
import '../logic/simulation_task.dart';
import '../logic/monte_carlo_engine.dart';
import '../logic/risk_impact.dart';
import '../logic/gantt_task_data.dart';
import 'server_api.dart';

class ExecutorController extends ChangeNotifier {
  late Box _box;
  List<SimulationTask> tasks = [];
  List<String> executors = [];
  String currentExecutor = '';
  DateTime startDate = DateTime.now();
  String resultText = '';
  List<RiskImpact> topRisks = [];
  bool isInitialized = false;
  bool isFetching = false;

  Future<void> init() async {
    _box = Hive.box('prognoz_box');
    executors = List<String>.from(_box.get('executors_list', defaultValue: []));
    if (executors.isNotEmpty) currentExecutor = executors.first;
    loadData();
    isInitialized = true;
    notifyListeners();
  }

  // Методы управления списком исполнителей
  void createNewExecutor(String name) {
    if (name.isEmpty || executors.contains(name)) return;
    executors.add(name);
    currentExecutor = name;
    _box.put('executors_list', executors);
    loadData();
  }

  void deleteExecutor(String name) {
    executors.remove(name);
    _box.delete('tasks_$name');
    _box.put('executors_list', executors);
    if (currentExecutor == name) {
      currentExecutor = executors.isNotEmpty ? executors.first : '';
    }
    loadData();
  }

  // Управление задачами
  void addTask() {
    int nextId = tasks.isEmpty ? 1 : tasks.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1;
    tasks.add(SimulationTask(id: nextId, name: 'Новый этап $nextId', min: 1, likely: 2, max: 3));
    saveData();
  }

  void removeTask(int index) {
    tasks.removeAt(index);
    saveData();
  }

  // Методы обновления (вызываются из UI)
  void updateTaskTitle(int index, String val) { tasks[index].name = val; saveData(); }
  void updateTaskCompletion(int index, bool val) { tasks[index].isCompleted = val; saveData(); }
  void updateTaskActualDuration(int index, double val) { tasks[index].actualDuration = val; saveData(); }
  void updateTaskDepends(int index, String val) {
    tasks[index].dependsOn = val.split(',').map((e) => int.tryParse(e.trim())).whereType<int>().toList();
    saveData();
  }
  void updateTaskValues(int index, String key, double val) {
    if (key == 'min') tasks[index].min = val;
    if (key == 'likely') tasks[index].likely = val;
    if (key == 'max') tasks[index].max = val;
    saveData();
  }

  // Поля лесоустройства
  void updateTaskPlantingType(int index, String val) { tasks[index].plantingType = val; saveData(); }
  void updateTaskCulture(int index, String val) { tasks[index].culture = val; saveData(); }
  void updateTaskLocation(int index, String val) { tasks[index].location = val; saveData(); }
  void updateTaskQuarter(int index, int? val) { tasks[index].quarter = val; saveData(); }
  void updateTaskAllotment(int index, int? val) { tasks[index].allotment = val; saveData(); }

  void setStartDate(DateTime date) { startDate = date; saveData(); }

  // Импорт / Экспорт
  String exportPlanToJson() => jsonEncode(tasks.map((e) => e.toJson()).toList());
  void importProgressFromJson(String jsonStr) {
    try {
      var list = jsonDecode(jsonStr) as List;
      tasks = list.map((e) => SimulationTask.fromJson(e)).toList();
      saveData();
    } catch (_) {}
  }

  // Работа с сервером
  Future<void> fetchReportFromServer() async {
    if (currentExecutor.isEmpty) return;
    isFetching = true;
    notifyListeners();
    final data = await fetchPlan(currentExecutor);
    if (data != null) importProgressFromJson(data);
    isFetching = false;
    notifyListeners();
  }

  void loadData() {
    if (currentExecutor.isEmpty) {
      tasks = [];
    } else {
      var data = _box.get('tasks_$currentExecutor');
      if (data != null) {
        tasks = (jsonDecode(data) as List).map((e) => SimulationTask.fromJson(e)).toList();
      } else {
        tasks = [];
      }
      var sDate = _box.get('start_date_$currentExecutor');
      startDate = sDate != null ? DateTime.parse(sDate) : DateTime.now();
    }
    runSimulation();
  }

  void saveData() {
    if (currentExecutor.isEmpty) return;
    _box.put('tasks_$currentExecutor', jsonEncode(tasks.map((e) => e.toJson()).toList()));
    _box.put('start_date_$currentExecutor', startDate.toIso8601String());
    runSimulation();
  }

  void runSimulation() {
    if (tasks.isEmpty) { resultText = "Нет данных"; notifyListeners(); return; }
    double p90 = MonteCarloEngine.calculate(tasks);
    DateTime finishDate = startDate.add(Duration(days: p90.ceil()));
    resultText = "Прогноз (P90): ${finishDate.day}.${finishDate.month}.${finishDate.year}";
    notifyListeners();
  }
}
