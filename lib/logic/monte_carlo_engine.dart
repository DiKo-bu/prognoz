import 'dart:math';
import 'simulation_task.dart';
import 'gantt_task_data.dart';
import 'baseline_plan.dart';
import 'risk_impact.dart';

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

      for (var task in tasks) {
        maxProjectTime = max(maxProjectTime, resolveTask(task, <String>{}));
      }
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
      bool overMax = task.isCompleted && task.actualDuration > task.max;
      taskData[task.id] = GanttTaskData(
        name: task.name,
        startTime: startTime,
        endTime: endTime,
        isCompleted: task.isCompleted,
        isOverMax: overMax,
      );
      return endTime;
    }

    for (var task in tasks) {
      totalDuration = max(totalDuration, resolveTask(task, <String>{}));
    }
    return BaselinePlan(taskData: taskData, totalDuration: totalDuration);
  }

  static List<RiskImpact> calculateRisks(List<SimulationTask> tasks) {
    if (tasks.isEmpty) return [];

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
        double duration = task.isCompleted ? task.actualDuration : (overrides.containsKey(task.id) ? overrides[task.id]! : task.likely);
        double endTime = startTime + duration;
        endTimes[task.id] = endTime;
        return endTime;
      }
      for (var task in tasks) { maxTime = max(maxTime, resolveTask(task, <String>{})); }
      return maxTime;
    }

    double baselineDuration = calcWithOverrides({});
    List<RiskImpact> risks = [];

    for (var task in tasks) {
      if (task.isCompleted || task.max <= task.likely) continue;
      double worstCaseDuration = calcWithOverrides({task.id: task.max});
      double impact = worstCaseDuration - baselineDuration;
      if (impact > 0.1) {
        risks.add(RiskImpact(taskName: task.name, impactDays: impact));
      }
    }

    for (var task in tasks) {
      if (task.isCompleted && task.actualDuration > task.max) {
        double over = task.actualDuration - task.max;
        risks.add(RiskImpact(taskName: task.name, impactDays: over));
      }
    }

    risks.sort((a, b) => b.impactDays.compareTo(a.impactDays));
    return risks.take(3).toList();
  }
}
