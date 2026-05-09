import 'package:flutter/material.dart';

class DeadlineWarning extends StatelessWidget {
  final DateTime planned;
  final DateTime actual;

  const DeadlineWarning({super.key, required this.planned, required this.actual});

  @override
  Widget build(BuildContext context) {
    String fmt(DateTime d) => "${d.day.toString().padLeft(2,'0')}.${d.month.toString().padLeft(2,'0')}";
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        "⚠️ Срыв срока! План: ${fmt(planned)}, Факт: ${fmt(actual)}",
        style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}
