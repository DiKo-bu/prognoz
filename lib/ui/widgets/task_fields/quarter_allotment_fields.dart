import 'package:flutter/material.dart';

class QuarterAllotmentFields extends StatelessWidget {
  final String? quarter;
  final String? allotment;
  final Function(String) onQuarterChanged;
  final Function(String) onAllotmentChanged;

  const QuarterAllotmentFields({
    super.key,
    this.quarter,
    this.allotment,
    required this.onQuarterChanged,
    required this.onAllotmentChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: quarter ?? '',
                decoration: const InputDecoration(labelText: 'Квартал', isDense: true),
                onChanged: onQuarterChanged,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                initialValue: allotment ?? '',
                decoration: const InputDecoration(labelText: 'Выдел', isDense: true),
                onChanged: onAllotmentChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
