import 'dart:math';

class GanttTaskData {
  final String name;
  final double startTime;
  final double endTime;
  final bool isCompleted;
  GanttTaskData({required this.name, required this.startTime, required this.endTime, this.isCompleted = false});
}

class BaselinePlan {
  final Map<String, GanttTaskData> taskData;
  final double totalDuration;
  BaselinePlan({required this.taskData, required this.totalDuration});
}

// НОВЫЙ КЛАСС: Для хранения результатов Торнадо-анализа
class RiskImpact {
  final String taskName;
  final double impactDays;
  RiskImpact({required this.taskName, required this.impactDays});
}

class SimulationTask {
  String id;
  String name;
  double min, likely, max;
  List<String> dependsOn;
  bool isCompleted; 
  double actualDuration; 

  SimulationTask({
    required this.id, required this.name,
    this.min = 0, this.likely = 0, this.max = 0,
    this.dependsOn = const [],
    this.isCompleted = false,
    this.actualDuration = 0,
  });

  Map<String, dynamic> toMap() => {
    'id': id, 'name': name, 'min': min, 'likely': likely, 'max': max, 'dependsOn': dependsOn,
    'isCompleted': isCompleted, 'actualDuration': actualDuration
  };

  factory SimulationTask.fromMap(Map<dynamic, dynamic> map) => SimulationTask(
    id: map['id'], name: map['name'],
    min: (map['min'] ?? 0).toDouble(),
    likely: (map['likely'] ?? 0).toDouble(),
    max: (map['max'] ?? 0).toDouble(),
    dependsOn: List<String>.from(map['dependsOn'] ?? []),
    isCompleted: map['isCompleted'] ?? false,
    actualDuration: (map['actualDuration'] ?? 0).toDouble(),
  );

  double getSample(Random rnd) {
    if (isCompleted) return actualDuration; 
    if (max <= min) return min; 
    double r = rnd.nextDouble();
    if (r < (likely - min) / (max - min)) {
      return min + sqrt(r * (max - min) * (likely - min));
    } else {
      return max - sqrt((1 - r) * (max - min) * (max - likely));
    }
  }
}

class MonteCarloEngine {
  static double calculate(List<SimulationTask> tasks, {int iterations = 50000}) {
    if (tasks.isEmpty) return 0;
    final rnd = Random();
    List<double> results = [];

    for (int i = 0; i < iterations; i++) {
      Map<String, double> endTimes = {};
      double maxProjectTime = 0;

      double resolveTask(SimulationTask task, Set<String> stack) {
        if (endTimes.containsKey(task.id)) return endTimes[task.id]!;
        if (stack.contains(task.id)) return 0;
        stack.add(task.id);
        double startTime = 0;
        for (var depId in task.dependsOn) {
          try {
            var depTask = tasks.firstWhere((t) => t.id == depId);
            startTime = max(startTime, resolveTask(depTask, stack));
          } catch(e) {}
        }
        stack.remove(task.id);
        double endTime = startTime + task.getSample(rnd);
        endTimes[task.id] = endTime;
        return endTime;
      }

      for (var task in tasks) { maxProjectTime = max(maxProjectTime, resolveTask(task, <String>{})); }
      results.add(maxProjectTime);
    }
    results.sort();
    return results[(iterations * 0.9).toInt()];
  }

  static BaselinePlan calculateBaselinePlan(List<SimulationTask> tasks) {
    if (tasks.isEmpty) return BaselinePlan(taskData: {}, totalDuration: 0);
    Map<String, GanttTaskData> taskData = {};
    Map<String, double> endTimes = {};
    double totalDuration = 0;

    double resolveTask(SimulationTask task, Set<String> stack) {
      if (endTimes.containsKey(task.id)) return endTimes[task.id]!;
      if (stack.contains(task.id)) return 0;
      stack.add(task.id);
      double startTime = 0;
      for (var depId in task.dependsOn) {
        try {
          var depTask = tasks.firstWhere((t) => t.id == depId);
          startTime = max(startTime, resolveTask(depTask, stack));
        } catch(e) {}
      }
      stack.remove(task.id);
      double endTime = startTime + (task.isCompleted ? task.actualDuration : task.likely);
      endTimes[task.id] = endTime;
      taskData[task.id] = GanttTaskData(name: task.name, startTime: startTime, endTime: endTime, isCompleted: task.isCompleted);
      return endTime;
    }

    for (var task in tasks) { totalDuration = max(totalDuration, resolveTask(task, <String>{})); }
    return BaselinePlan(taskData: taskData, totalDuration: totalDuration);
  }

  // НОВЫЙ АЛГОРИТМ: Вычисление самых опасных задач
  static List<RiskImpact> calculateRisks(List<SimulationTask> tasks) {
    if (tasks.isEmpty) return [];

    // Внутренняя функция для просчета проекта с заданными параметрами
    double calcWithOverrides(Map<String, double> overrides) {
      Map<String, double> endTimes = {};
      double maxTime = 0;
      double resolveTask(SimulationTask task, Set<String> stack) {
        if (endTimes.containsKey(task.id)) return endTimes[task.id]!;
        if (stack.contains(task.id)) return 0;
        stack.add(task.id);
        double startTime = 0;
        for (var depId in task.dependsOn) {
          try {
            var depTask = tasks.firstWhere((t) => t.id == depId);
            startTime = max(startTime, resolveTask(depTask, stack));
          } catch(e) {}
        }
        stack.remove(task.id);
        
        // Берем значение: факт (если завершено), либо переопределенное (для стресс-теста), либо норму
        double duration = task.isCompleted ? task.actualDuration : (overrides.containsKey(task.id) ? overrides[task.id]! : task.likely);
        double endTime = startTime + duration;
        endTimes[task.id] = endTime;
        return endTime;
      }
      for (var task in tasks) { maxTime = max(maxTime, resolveTask(task, <String>{})); }
      return maxTime;
    }

    double baselineDuration = calcWithOverrides({}); // Идеальный сценарий
    List<RiskImpact> risks = [];

    for (var task in tasks) {
      if (task.isCompleted || task.max <= task.likely) continue;
      
      // Имитируем катастрофу только на одном этапе
      double worstCaseDuration = calcWithOverrides({task.id: task.max});
      double impact = worstCaseDuration - baselineDuration;

      // Если задержка этапа сдвинула весь проект, это критический риск
      if (impact > 0.1) {
        risks.add(RiskImpact(taskName: task.name, impactDays: impact));
      }
    }

    risks.sort((a, b) => b.impactDays.compareTo(a.impactDays));
    return risks.take(3).toList(); // Отдаем Топ-3
  }
}
