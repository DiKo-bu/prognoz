import 'package:flutter/material.dart';

class ClearCuttingFields extends StatelessWidget {
  final double? clearCuttingArea;
  final double? clearCuttingVolume;
  final Function(double) onClearCuttingAreaChange;
  final Function(double) onClearCuttingVolumeChange;

  const ClearCuttingFields({
    super.key,
    this.clearCuttingArea,
    this.clearCuttingVolume,
    required this.onClearCuttingAreaChange,
    required this.onClearCuttingVolumeChange,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: clearCuttingArea != null ? clearCuttingArea!.toString() : '',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Площадь, га', isDense: true),
                onChanged: (v) => onClearCuttingAreaChange(double.tryParse(v.replaceAll(',', '.')) ?? 0),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                initialValue: clearCuttingVolume != null ? clearCuttingVolume!.toString() : '',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Объём, м³', isDense: true),
                onChanged: (v) => onClearCuttingVolumeChange(double.tryParse(v.replaceAll(',', '.')) ?? 0),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
