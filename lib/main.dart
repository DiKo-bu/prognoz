import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'ui/home_page.dart';

void main() async {
  // Инициализируем Flutter и базу данных
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('prognoz_box'); 
  
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: HomePage(),
  ));
}
