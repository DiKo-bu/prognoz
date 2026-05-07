import 'package:flutter/material.dart';

class LocationField extends StatelessWidget {
  final String? location;
  final Function(String) onChanged;

  const LocationField({
    super.key,
    this.location,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: location ?? '',
      decoration: const InputDecoration(labelText: 'Где?', isDense: true),
      onChanged: onChanged,
    );
  }
}
