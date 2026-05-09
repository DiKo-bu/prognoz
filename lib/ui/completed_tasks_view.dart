import 'package:flutter/material.dart';
import '../logic/simulation_task.dart';

class CompletedTasksView extends StatelessWidget {
  final List<SimulationTask> tasks;
  final DateTime startDate;

  const CompletedTasksView({
    super.key,
    required this.tasks,
    required this.startDate,
  });

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return const Center(child: Text("Нет этапов для отображения"));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      itemBuilder: (context, index) => _buildTaskCard(tasks[index]),
    );
  }

  Widget _buildTaskCard(SimulationTask task) {
    DateTime plannedEnd = startDate.add(Duration(days: task.likely.toInt()));
    bool completed = task.isCompleted;
    bool overMax = completed && task.actualDuration > task.max;
    bool deadlineViolation =
        completed && task.actualEndDate != null && task.actualEndDate!.isAfter(plannedEnd);

    Color borderColor;
    String statusText;
    if (deadlineViolation) {
      borderColor = Colors.red;
      statusText = "Срыв срока";
    } else if (overMax) {
      borderColor = Colors.orange;
      statusText = "Превышение дней";
    } else if (completed) {
      borderColor = Colors.green;
      statusText = "Выполнена";
    } else {
      borderColor = Colors.grey;
      statusText = "Не выполнена";
    }

    String dateInfo = '';
    if (completed && task.actualEndDate != null) {
      dateInfo =
          "Факт: ${task.actualEndDate!.day}.${task.actualEndDate!.month}.${task.actualEndDate!.year}";
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: borderColor, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              statusText,
              style: TextStyle(
                color: borderColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (dateInfo.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(dateInfo, style: const TextStyle(color: Colors.grey)),
            ],
            const SizedBox(height: 4),
            Text(
              "План: ${plannedEnd.day}.${plannedEnd.month}.${plannedEnd.year}",
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
