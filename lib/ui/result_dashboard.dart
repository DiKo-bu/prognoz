import 'package:flutter/material.dart';

import '../data/controller.dart';
import '../logic/gantt_task_data.dart';
import '../logic/risk_impact.dart';
import '../logic/simulation_task.dart';
import 'gantt_chart.dart';

class ResultDashboard extends StatelessWidget {
  final ExecutorController controller;

  const ResultDashboard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final start = controller.startDate;
    final p90 = controller.p90Duration;
    final finishDate = start.add(Duration(days: p90.ceil()));
    final formattedFinish =
        "${finishDate.day.toString().padLeft(2, '0')}.${finishDate.month.toString().padLeft(2, '0')}.${finishDate.year}";

    final overMaxTasks = controller.tasks
        .where((SimulationTask t) =>
            t.isCompleted && (t.actualDuration ?? 0) > t.max)
        .toList();

    String deadlineWarnings = '';
    for (final t in controller.tasks) {
      if (t.isCompleted && t.actualEndDate != null) {
        final plannedEnd = start.add(Duration(days: t.likely.toInt()));
        if (t.actualEndDate!.isAfter(plannedEnd)) {
          deadlineWarnings +=
              '⚠️ Срыв срока: «${t.name}» – план ${plannedEnd.day.toString().padLeft(2, '0')}.${plannedEnd.month.toString().padLeft(2, '0')}, факт ${t.actualEndDate!.day.toString().padLeft(2, '0')}.${t.actualEndDate!.month.toString().padLeft(2, '0')}\n';
        }
      }
    }

    if (controller.ganttData.isEmpty) {
      return const Center(
        child: Text(
          "Нет данных моделирования.\nНажмите ▶️ вверху экрана.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: const [
                      Icon(Icons.flag_circle, color: Colors.green, size: 28),
                      SizedBox(width: 8),
                      Text(
                        "Финиш (90%)",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    formattedFinish,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${p90.toStringAsFixed(1)} рабочих дней",
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),

          if (deadlineWarnings.isNotEmpty) ...[
            const SizedBox(height: 12),
            Card(
              color: Colors.red.shade50,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.warning_amber_rounded,
                            color: Colors.red, size: 24),
                        SizedBox(width: 8),
                        Text(
                          "Нарушения сроков",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      deadlineWarnings,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          if (overMaxTasks.isNotEmpty) ...[
            const SizedBox(height: 12),
            Card(
              color: Colors.orange.shade50,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.warning_amber_rounded,
                            color: Colors.orange, size: 24),
                        SizedBox(width: 8),
                        Text(
                          "Превышения максимума",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...overMaxTasks.map(
                      (t) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline,
                                color: Colors.red, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "${t.name}: факт ${t.actualDuration} дн. > макс ${t.max} дн.",
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          if (controller.topRisks.isNotEmpty) ...[
            const SizedBox(height: 12),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.dangerous, color: Colors.red, size: 24),
                        SizedBox(width: 8),
                        Text(
                          "Критические узлы",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...controller.topRisks.map((RiskImpact risk) {
                      final maxImpact =
                          controller.topRisks.first.impactDays;
                      final fraction =
                          maxImpact > 0 ? risk.impactDays / maxImpact : 0.0;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${risk.taskName} (Угроза: +${risk.impactDays.toStringAsFixed(1)} дн.)",
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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

          const SizedBox(height: 16),
          const Text(
            "Диаграмма Ганта",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          GanttChart(
            data: controller.ganttData,
            totalDuration: controller.p90Duration,
            startDate: controller.startDate,
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
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
