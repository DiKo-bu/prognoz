import 'package:flutter/material.dart';

class OverMaxWarning extends StatelessWidget {
  const OverMaxWarning({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 4),
      child: Text(
        "⚠️ Превышение максимума!",
        style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}
