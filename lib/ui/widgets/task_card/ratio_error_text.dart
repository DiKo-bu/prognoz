import 'package:flutter/material.dart';

class RatioErrorText extends StatelessWidget {
  const RatioErrorText({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 8),
      child: Text(
        "Ошибка: должно быть Мин <= Норма <= Макс",
        style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}
