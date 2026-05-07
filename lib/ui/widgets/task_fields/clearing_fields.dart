import 'package:flutter/material.dart';

class ClearingFields extends StatelessWidget {
  final double? clearingArea;
  final double? clearingVolume;
  final Function(double) onClearingAreaChange;
  final Function(double) onClearingVolumeChange;

  const ClearingFields({
    super.key,
    this.clearingArea,
    this.clearingVolume,
    required this.onClearingAreaChange,
    required this.onClearingVolumeChange,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: clearingArea != null ? clearingArea!.toString() : '',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Площадь, га', isDense: true),
                onChanged: (v) => onClearingAreaChange(double.tryParse(v.replaceAll(',', '.')) ?? 0),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                initialValue: clearingVolume != null ? clearingVolume!.toString() : '',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Объём, м³', isDense: true),
                onChanged: (v) => onClearingVolumeChange(double.tryParse(v.replaceAll(',', '.')) ?? 0),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
