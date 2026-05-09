import 'package:flutter/material.dart';

class DependsField extends StatelessWidget {
  final String currentDepends;
  final Function(String) onChanged;

  const DependsField({
    super.key,
    required this.currentDepends,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: currentDepends,
      decoration: const InputDecoration(
        labelText: 'После этапов (номера через запятую)',
        isDense: true,
        border: OutlineInputBorder(),
        labelStyle: TextStyle(fontSize: 11),
      ),
      style: const TextStyle(fontSize: 13),
      onChanged: onChanged,
    );
  }
}
