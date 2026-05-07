import 'package:flutter/material.dart';
import '../../constants.dart';

class PlantingFields extends StatelessWidget {
  final String? plantingType;
  final String? culture;
  final double? plantingQuantity;
  final double? plantingArea;
  final Function(String?) onPlantingTypeChange;
  final Function(String?) onCultureChange;
  final Function(double) onPlantingQuantityChange;
  final Function(double) onPlantingAreaChange;

  const PlantingFields({
    super.key,
    this.plantingType,
    this.culture,
    this.plantingQuantity,
    this.plantingArea,
    required this.onPlantingTypeChange,
    required this.onCultureChange,
    required this.onPlantingQuantityChange,
    required this.onPlantingAreaChange,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: plantingType,
                decoration: const InputDecoration(labelText: 'Вид', isDense: true),
                items: plantingTypes.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: onPlantingTypeChange,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: culture,
                decoration: const InputDecoration(labelText: 'Культура', isDense: true),
                items: cultures.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: onCultureChange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: plantingQuantity != null ? plantingQuantity!.toString().replaceAll(RegExp(r'\.0$'), '') : '',
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Кол-во, шт', isDense: true),
                onChanged: (v) => onPlantingQuantityChange(double.tryParse(v.replaceAll(',', '.')) ?? 0),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                initialValue: plantingArea != null ? plantingArea!.toString() : '',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Площадь, га', isDense: true),
                onChanged: (v) => onPlantingAreaChange(double.tryParse(v.replaceAll(',', '.')) ?? 0),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
