import 'dart:math';

import 'simulation_task.dart';
import 'gantt_task_data.dart';
import 'risk_impact.dart';

class MonteCarloEngine {
  static double calculate(List<SimulationTask> tasks, {int iterations = 1000}) {
    final rnd = Random();
    final results = <double>[];
    for (int i = 0; i < iterations; i++) {
      results.add(_runSingleIteration(tasks, rnd));
    }
    results.sort();
    return results[(iterations * 0.9).floor()];
  }

  static double _runSingleIteration(List<SimulationTask> tasks, Random rnd) {
    final endTimes = <int, double>{};
    double totalMax = 0;

    void process(SimulationTask task) {
      if (endTimes.containsKey(task.id)) return;

      double startTime = 0;
      for (final depId in task.dependsOn) {
        final depTask =
            tasks.firstWhere((t) => t.id == depId, orElse: () => task);
        if (depTask.id != task.id) {
          process(depTask);
          startTime = max(startTime, endTimes[depTask.id]!);
        }
      }

      final duration = task.isCompleted
          ? (task.actualDuration ?? task.likely)
          : task.getSample(rnd);

      final endTime = startTime + duration;
      endTimes[task.id] = endTime;
      totalMax = max(totalMax, endTime);
    }

    for (final t in tasks) {
      process(t);
    }
    return totalMax;
  }

  static Map<String, GanttTaskData> calculateBaselinePlan(
      List<SimulationTask> tasks) {
    final endTimes = <int, double>{};
    final taskData = <String, GanttTaskData>{};

    void process(SimulationTask task) {
      if (endTimes.containsKey(task.id)) return;

      double startTime = 0;
      for (final depId in task.dependsOn) {
        final depTask =
            tasks.firstWhere((t) => t.id == depId, orElse: () => task);
        if (depTask.id != task.id) {
          process(depTask);
          startTime = max(startTime, endTimes[depTask.id]!);
        }
      }

      final duration = task.isCompleted
          ? (task.actualDuration ?? task.likely)
          : task.likely;

      final endTime = startTime + duration;
      endTimes[task.id] = endTime;

      taskData[task.id.toString()] = GanttTaskData(
        taskId: task.id.toString(),
        name: task.name,
        startTime: startTime,
        endTime: endTime,
        isCompleted: task.isCompleted,
        isOverMax: task.actualDuration != null &&
            task.actualDuration! > task.max,
      );
    }

    for (final t in tasks) {
      process(t);
    }
    return taskData;
  }

  static List<RiskImpact> calculateRisks(List<SimulationTask> tasks) {
    final baseline = calculate(tasks, iterations: 100);
    final risks = <RiskImpact>[];

    for (final t in tasks.where((task) => !task.isCompleted)) {
      final originalLikely = t.likely;
      t.likely = t.max;
      final impact = calculate(tasks, iterations: 100) - baseline;
      t.likely = originalLikely;

      if (impact > 0) {
        risks.add(RiskImpact(taskName: t.name, impactDays: impact));
      }
    }

    risks.sort((a, b) => b.impactDays.compareTo(a.impactDays));
    return risks;
  }
}
