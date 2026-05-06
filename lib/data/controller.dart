import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';
import '../logic/engine.dart';
import '../ui/parts.dart'; // для workNames

class ExecutorController extends ChangeNotifier {
  late Box _box;
  List<SimulationTask> tasks = [];
  List<String> executors = [];
  String currentExecutor = '';

  String resultText = '';
  Map<String, GanttTaskData> ganttData = {};
  double p90Duration = 0;
  DateTime startDate = DateTime.now();
  List<RiskImpact> topRisks = [];
  bool isInitialized = false;

  Future<void> init() async {
    _box = Hive.box('prognoz_box');
    var storedExecutors = _box.get('executors_list');
    if (storedExecutors != null) {
      executors = List<String>.from(storedExecutors);
      currentExecutor = executors.isNotEmpty ? executors.first : '';
    } else {
      executors = [];
      currentExecutor = '';
      _box.put('executors_list', executors);
    }
    loadData();
    isInitialized = true;
    notifyListeners();
  }

  void loadData() {
    if (currentExecutor.isEmpty) {
      tasks = [];
      resultText = '';
      ganttData = {};
      topRisks = [];
      startDate = DateTime.now();
      notifyListeners();
      return;
    }
    final stored = _box.get('exec_$currentExecutor');
    if (stored != null) {
      tasks = (stored as List).map((t) => SimulationTask.fromMap(t)).toList();
    } else {
      tasks = [];
    }
    final storedDate = _box.get('date_exec_$currentExecutor');
    if (storedDate != null) startDate = DateTime.parse(storedDate);
    else startDate = DateTime.now();
    resultText = '';
    ganttData = {};
    topRisks = [];
    notifyListeners();
  }

  void saveData() {
    if (currentExecutor.isEmpty) return;
    _box.put('exec_$currentExecutor', tasks.map((t) => t.toMap()).toList());
  }

  void saveExecutorsList() {
    _box.put('executors_list', executors);
  }

  void setStartDate(DateTime date) {
    startDate = date;
    if (currentExecutor.isNotEmpty) {
      _box.put('date_exec_$currentExecutor', date.toIso8601String());
    }
    if (ganttData.isNotEmpty) runSimulation();
    notifyListeners();
  }

  void createNewExecutor(String name) {
    if (name.isEmpty || executors.contains(name)) return;
    executors.add(name);
    currentExecutor = name;
    saveExecutorsList();
    loadData();
  }

  void deleteExecutor(String name) {
    if (!executors.contains(name)) return;
    _box.delete('exec_$name');
    _box.delete('date_exec_$name');
    executors.remove(name);
    if (currentExecutor == name) {
      currentExecutor = executors.isNotEmpty ? executors.first : '';
      loadData();
    } else {
      saveExecutorsList();
      notifyListeners();
    }
  }

  // Добавление этапа с названием по умолчанию (первый из списка работ)
  void addTask() {
    if (currentExecutor.isEmpty) return;
    String newId = (tasks.length + 1).toString();
    // Устанавливаем имя по умолчанию из списка workNames (импортирован из parts.dart)
    tasks.add(SimulationTask(id: newId, name: workNames.first));
    saveData();
    resultText = '';
    ganttData = {};
    p90Duration = 0;
    topRisks = [];
    notifyListeners();
  }

  void removeTask(int index) {
    tasks.removeAt(index);
    for (int i = 0; i < tasks.length; i++)
      tasks[i].id = (i + 1).toString();
    saveData();
    notifyListeners();
  }

  void updateTaskTitle(int index, String title) {
    tasks[index].name = title;
    saveData();
  }

  void updateTaskValues(int index, String key, double val) {
    if (key == 'min') tasks[index].min = val;
    if (key == 'likely') tasks[index].likely = val;
    if (key == 'max') tasks[index].max = val;
    saveData();
  }

  void updateTaskDepends(int index, String dependsStr) {
    tasks[index].dependsOn = dependsStr.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    saveData();
  }

  void updateTaskCompletion(int index, bool val) {
    tasks[index].isCompleted = val;
    saveData();
    notifyListeners();
  }

  void updateTaskActualDuration(int index, double val) {
    tasks[index].actualDuration = val;
    saveData();
  }

  void importProgressFromJson(String jsonString) {
    try {
      Map<String, dynamic> incomingData = jsonDecode(jsonString);
      bool updated = false;
      for (int i = 0; i < tasks.length; i++) {
        String taskId = tasks[i].id;
        if (incomingData.containsKey(taskId) || incomingData.containsKey(tasks[i].name)) {
          var taskUpdate = incomingData[taskId] ?? incomingData[tasks[i].name];
          if (taskUpdate.containsKey('completed')) tasks[i].isCompleted = taskUpdate['completed'];
          if (taskUpdate.containsKey('actual')) tasks[i].actualDuration = (taskUpdate['actual'] as num).toDouble();
          updated = true;
        }
      }
      if (updated) {
        saveData();
        runSimulation();
        resultText = "✅ Отчет загружен. График перестроен.\n\n$resultText";
        notifyListeners();
      }
    } catch (e) {
      resultText = "❌ Ошибка импорта: неверный формат отчета.";
      notifyListeners();
    }
  }

  String exportPlanToJson() {
    final plan = tasks.map((t) => {
      'id': t.id,
      'name': t.name,
      'min': t.min,
      'likely': t.likely,
      'max': t.max,
      'dependsOn': t.dependsOn,
      'workType': t.name,   // теперь workType = названию
      'executor': currentExecutor,
    }).toList();
    return jsonEncode(plan);
  }

  void runSimulation() {
    topRisks = [];
    if (tasks.isEmpty) return;
    for (var t in tasks) {
      if (!t.isCompleted) {
        if (t.min == 0 && t.likely == 0 && t.max == 0) {
          resultText = "ОШИБКА: Заполните цифры в этапе ${t.id}!";
          ganttData = {};
          notifyListeners();
          return;
        }
        if (!(t.min <= t.likely && t.likely <= t.max)) {
          resultText = "ОШИБКА в этапе ${t.id}:\nПравило 'Мин <= Норма <= Макс' нарушено!";
          ganttData = {};
          notifyListeners();
          return;
        }
      }
    }
    double p90 = MonteCarloEngine.calculate(tasks);
    final baseline = MonteCarloEngine.calculateBaselinePlan(tasks);
    topRisks = MonteCarloEngine.calculateRisks(tasks);
    DateTime finishDate = startDate.add(Duration(days: p90.ceil()));
    String fDay = finishDate.day.toString().padLeft(2, '0');
    String fMonth = finishDate.month.toString().padLeft(2, '0');
    resultText = "ФИНИШ (90%): $fDay.$fMonth.${finishDate.year} (${p90.toStringAsFixed(1)} дн.)";
    ganttData = baseline.taskData;
    p90Duration = p90;
    notifyListeners();
  }
}
