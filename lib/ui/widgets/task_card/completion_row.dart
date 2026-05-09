import 'package:flutter/material.dart';

class CompletionRow extends StatelessWidget {
  final bool isCompleted;
  final double actualDuration;
  final bool isOverMax;
  final Function(bool) onChanged;
  final Function(double) onDurationChanged;

  const CompletionRow({
    super.key,
    required this.isCompleted,
    required this.actualDuration,
    required this.isOverMax,
    required this.onChanged,
    required this.onDurationChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: isCompleted,
          activeColor: Colors.green,
          onChanged: (v) => onChanged(v ?? false),
        ),
        const Text("Завершено",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 13)),
        if (isCompleted) ...[
          const Spacer(),
          SizedBox(
            width: 80,
            child: TextFormField(
              initialValue: actualDuration == 0
                  ? ''
                  : actualDuration.toString().replaceAll(RegExp(r'\.0$'), ''),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(
                fontSize: 13,
                color: isOverMax ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                labelText: 'Факт. дней',
                isDense: true,
                labelStyle: TextStyle(color: isOverMax ? Colors.red : Colors.green),
                suffixIcon: isOverMax
                    ? const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 18)
                    : null,
              ),
              onChanged: (v) => onDurationChanged(double.tryParse(v.replaceAll(',', '.')) ?? 0),
            ),
          ),
          const SizedBox(width: 5),
        ],
      ],
    );
  }
}
