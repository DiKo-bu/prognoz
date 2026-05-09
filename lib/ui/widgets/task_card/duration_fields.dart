import 'package:flutter/material.dart';

class DurationFields extends StatelessWidget {
  final double min, likely, max;
  final bool isCompleted;
  final Function(String, double) onChanged;

  const DurationFields({
    super.key,
    required this.min,
    required this.likely,
    required this.max,
    required this.isCompleted,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: isCompleted,
      child: Opacity(
        opacity: isCompleted ? 0.3 : 1.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _field('Мин', min, (v) => onChanged('min', v)),
            _field('Норма', likely, (v) => onChanged('likely', v)),
            _field('Макс', max, (v) => onChanged('max', v)),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, double val, Function(double) cb) {
    String initVal = val == 0 ? '' : val.toString().replaceAll(RegExp(r'\.0$'), '');
    return SizedBox(
      width: 65,
      child: TextFormField(
        initialValue: initVal,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(labelText: label, isDense: true),
        onChanged: (v) => cb(double.tryParse(v.replaceAll(',', '.')) ?? 0),
      ),
    );
  }
}
