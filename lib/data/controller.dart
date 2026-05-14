import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';
import '../logic/simulation_task.dart';
import '../logic/gantt_task_data.dart';
import '../logic/risk_impact.dart';
import '../logic/monte_carlo_engine.dart';
import '../ui/constants.dart';
// Предполагается, что методы API импортируются отсюда
import 'server_api.dart'; 

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
  
  // Флаг для индикации процесса загрузки с сервера
  bool isFetching = false;

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
    } else {
      var data = _box.get('tasks_$currentExecutor');
      if (data != null) {
        var list = jsonDecode(data) as List;
        tasks = list.map((e) => SimulationTask.fromJson(e)).toList();
      } else {
        tasks = [];
      }
      
      var sDate = _box.get('start_date_$currentExecutor');
      startDate = sDate != null ? DateTime.parse(sDate) : DateTime.now();
      
      runSimulation();
    }
    notifyListeners();
  }

  void saveData() {
    if (currentExecutor.isEmpty) return;
    _box.put('tasks_$currentExecutor', jsonEncode(tasks.map((e) => e.toJson()).toList()));
    _box.put('start_date_$currentExecutor', startDate.toIso8601String());
  }

  // МЕТОД РУЧНОГО ОБНОВЛЕНИЯ
  Future<void> fetchReportFromServer() async {
    if (currentExecutor.isEmpty) return;
    
    isFetching = true;
    notifyListeners();

    try {
      // Запрашиваем данные отчета (GET /report/исполнитель)
      final String? jsonResponse = await fetchPlan(currentExecutor); 
      
      if (jsonResponse != null && jsonResponse != '[]') {
        final List<dynamic> decodedReport = jsonDecode(jsonResponse);
        
        bool hasChanges = false;
        for (var reportItem in decodedReport) {
          // Ищем задачу в локальном списке по ID
          final taskId = reportItem['id'];
          final index = tasks.indexWhere((t) => t.id == taskId);
          
          if (index != -1) {
            // Обновляем прогресс и статус
            tasks[index].isCompleted = reportItem['isCompleted'] ?? false;
            if (reportItem['actualDuration'] != null) {
              tasks[index].actualDuration = (reportItem['actualDuration'] as num).toDouble();
            }
            hasChanges = true;
          }
        }
        
        if (hasChanges) {
          saveData();
          runSimulation(); // Пересчитываем прогноз на основе новых данных
        }
      }
    } catch (e) {
      debugPrint("Ошибка при загрузке отчета: $e");
    } finally {
      isFetching = false;
      notifyListeners();
    }
  }

  void runSimulation() {
    if (tasks.isEmpty) {
      resultText = "Добавьте этапы для расчета";
      ganttData = {};
      notifyListeners();
      return;
    }

    // Валидация перед расчетом
    for (var t in tasks) {
      if (!t.isCompleted) {
        if (t.min <= 0 || t.likely <= 0 || t.max <= 0) {
          resultText = "ОШИБКА: Параметры времени должны быть больше 0";
          return;
        }
        if (!(t.min <= t.likely && t.likely <= t.max)) {
          resultText = "ОШИБКА в этапе ${t.id}: Нарушено правило Мин <= Норма <= Макс";
          return;
        }
      }
    }

    p90Duration = MonteCarloEngine.calculate(tasks);
    topRisks = MonteCarloEngine.calculateRisks(tasks);
    
    // Формирование текста результата
    DateTime finishDate = startDate.add(Duration(days: p90Duration.ceil()));
    resultText = "Прогноз завершения (P90): ${finishDate.day}.${finishDate.month}.${finishDate.year}\n"
                 "Общая длительность: ${p90Duration.toStringAsFixed(1)} дн.";
    
    notifyListeners();
  }
}
