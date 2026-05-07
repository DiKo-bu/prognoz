import 'package:flutter/material.dart';

class PanelsField extends StatelessWidget {
  final double? panelsQuantity;
  final Function(double) onPanelsQuantityChange;

  const PanelsField({
    super.key,
    this.panelsQuantity,
    required this.onPanelsQuantityChange,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          initialValue: panelsQuantity != null ? panelsQuantity!.toString() : '',
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Штуки', isDense: true),
          onChanged: (v) => onPanelsQuantityChange(double.tryParse(v.replaceAll(',', '.')) ?? 0),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
