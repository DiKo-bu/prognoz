import 'package:flutter/material.dart';

class TaskIdBadge extends StatelessWidget {
  final String id;
  final bool isWarning;
  final bool isCompleted;
  final bool showError;

  const TaskIdBadge({
    super.key,
    required this.id,
    this.isWarning = false,
    this.isCompleted = false,
    this.showError = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isWarning
            ? Colors.red
            : (isCompleted ? Colors.green : (showError ? Colors.red : Colors.blue[700])),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(id, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }
}
