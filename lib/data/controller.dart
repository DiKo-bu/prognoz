import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';
import '../logic/engine.dart';

class ProjectController extends ChangeNotifier {
  late Box _box;
  List<SimulationTask> tasks = [];
  List<String> projects = [];
  String currentProject = '';

  String resultText = '';
  Map<String, GanttTaskData> ganttData = {};
  double p90Duration = 0;
  DateTime startDate = DateTime.now();

  List<RiskImpact> topRisks = [];

  bool isInitialized = false;

  Future<void> init() async {
    _box = Hive.box('prognoz_box');
    var storedProjects = _box.get('projects_list');
    if (storedProjects != null) {
      projects = List<String>.from(storedProjects);
      currentProject = projects.first;
    } else {
      projects = ['Основной проект'];
      currentProject = 'Основной проект';
      _box.put('projects_list', projects);
      var oldTasks = _box.get('tasks');
      if (oldTasks != null) {
        _box.put('proj_Основной проект', oldTasks);
        _box.delete('tasks');
      }
    }
    loadData();
    isInitialized = true;
    notifyListeners();
  }

  void loadData() {
    final stored = _box.get('proj_$currentProject');
    if (stored != null) {
      tasks = (stored as List).map((t) => SimulationTask.fromMap(t)).toList();
    } else {
      tasks = [];
    }
    final storedDate = _box.get('date_$currentProject');
    if (storedDate != null) startDate = DateTime.parse(storedDate);
    else startDate = DateTime.now();
    resultText = '';
    ganttData = {};
    topRisks = [];
    notifyListeners();
  }

  void saveData() {
    _box.put('proj_$currentProject', tasks.map((t) => t.toMap()).toList());
  }

  void saveProjectsList() {
    _box.put('projects_list', projects);
  }

  void setStartDate(DateTime date) {
    startDate = date;
    _box.put('date_$currentProject', date.toIso8601String());
    if (ganttData.isNotEmpty) runSimulation();
    notifyListeners();
  }

  void createNewProject(String name) {
    if (name.isEmpty || projects.contains(name)) return;
    projects.add(name);
    currentProject = name;
    saveProjectsList();
    loadData();
  }

  void deleteProject(String name) {
    if (projects.length <= 1) return;
    projects.remove(name);
    _box.delete('proj_$name');
    _box.delete('date_$name');
    currentProject = projects.first;
    saveProjectsList();
    loadData();
  }

  void addTask() {
    String newId = (tasks.length + 1).toString();
    tasks.add(SimulationTask(id: newId, name: 'Новый этап $newId'));
    saveData();
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

  void updateTaskWorkType(int index, String type) {
    tasks[index].workType = type;
    saveData();
    notifyListeners();
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
      'workType': t.workType,
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
