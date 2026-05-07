import 'package:flutter/material.dart';
import '../../constants.dart';

class SowingFields extends StatelessWidget {
  final String? sowingBreed;
  final double? sowingQuantityKg;
  final double? sowingAreaHa;
  final Function(String?) onSowingBreedChange;
  final Function(double) onSowingQuantityKgChange;
  final Function(double) onSowingAreaHaChange;

  const SowingFields({
    super.key,
    this.sowingBreed,
    this.sowingQuantityKg,
    this.sowingAreaHa,
    required this.onSowingBreedChange,
    required this.onSowingQuantityKgChange,
    required this.onSowingAreaHaChange,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: sowingBreed,
          decoration: const InputDecoration(labelText: 'Порода', isDense: true),
          items: sowingBreeds.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onSowingBreedChange,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: sowingQuantityKg != null ? sowingQuantityKg!.toString() : '',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Количество, кг', isDense: true),
                onChanged: (v) => onSowingQuantityKgChange(double.tryParse(v.replaceAll(',', '.')) ?? 0),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                initialValue: sowingAreaHa != null ? sowingAreaHa!.toString() : '',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Площадь, га', isDense: true),
                onChanged: (v) => onSowingAreaHaChange(double.tryParse(v.replaceAll(',', '.')) ?? 0),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
