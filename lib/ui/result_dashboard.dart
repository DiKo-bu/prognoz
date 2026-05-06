import 'package:flutter/material.dart';
import '../data/controller.dart';
import '../logic/engine.dart';
import 'parts.dart';

class ResultDashboardScreen extends StatelessWidget {
  final ExecutorController controller;

  const ResultDashboardScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final start = controller.startDate;
    final p90 = controller.p90Duration;
    final finishDate = start.add(Duration(days: p90.ceil()));
    final formattedFinish =
        "${finishDate.day.toString().padLeft(2, '0')}.${finishDate.month.toString().padLeft(2, '0')}.${finishDate.year}";

    final overMaxTasks = controller.tasks
        .where((t) => t.isCompleted && t.actualDuration > t.max)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Результаты моделирования'),
        backgroundColor: Colors.green.shade700,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Карточка ФИНИШ
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.flag_circle, color: Colors.green, size: 28),
                        SizedBox(width: 8),
                        Text("Финиш (90%)",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(formattedFinish,
                        style: const TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green)),
                    const SizedBox(height: 4),
                    Text("${p90.toStringAsFixed(1)} рабочих дней",
                        style: const TextStyle(fontSize: 16, color: Colors.grey)),
                  ],
                ),
              ),
            ),

            // Карточка ПРЕДУПРЕЖДЕНИЯ
            if (overMaxTasks.isNotEmpty) ...[
              const SizedBox(height: 12),
              Card(
                color: Colors.orange.shade50,
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 24),
                          SizedBox(width: 8),
                          Text("Превышения максимума",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...overMaxTasks.map((t) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline, color: Colors.red, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "${t.name}: факт ${t.actualDuration} дн. > макс ${t.max} дн.",
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              ),
            ],

            // Карточка КРИТИЧЕСКИЕ УЗЛЫ
            if (controller.topRisks.isNotEmpty) ...[
              const SizedBox(height: 12),
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.dangerous, color: Colors.red, size: 24),
                          SizedBox(width: 8),
                          Text("Критические узлы",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...controller.topRisks.map((risk) {
                        double maxImpact = controller.topRisks.first.impactDays;
                        double fraction = maxImpact > 0 ? risk.impactDays / maxImpact : 0;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  "${risk.taskName} (Угроза: +${risk.impactDays.toStringAsFixed(1)} дн.)",
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
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

            // Диаграмма Ганта
            const SizedBox(height: 16),
            const Text("Диаграмма Ганта",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
