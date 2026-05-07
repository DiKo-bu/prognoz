import 'package:flutter/material.dart';

class CuttingFields extends StatelessWidget {
  final double? cuttingArea;
  final double? cuttingVolume;
  final Function(double) onCuttingAreaChange;
  final Function(double) onCuttingVolumeChange;

  const CuttingFields({
    super.key,
    this.cuttingArea,
    this.cuttingVolume,
    required this.onCuttingAreaChange,
    required this.onCuttingVolumeChange,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: cuttingArea != null ? cuttingArea!.toString() : '',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Площадь, га', isDense: true),
                onChanged: (v) => onCuttingAreaChange(double.tryParse(v.replaceAll(',', '.')) ?? 0),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                initialValue: cuttingVolume != null ? cuttingVolume!.toString() : '',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Объём, м³', isDense: true),
                onChanged: (v) => onCuttingVolumeChange(double.tryParse(v.replaceAll(',', '.')) ?? 0),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
