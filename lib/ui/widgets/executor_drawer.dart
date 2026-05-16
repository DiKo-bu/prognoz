import 'package:flutter/material.dart';
import '../../data/controller.dart';

class ExecutorDrawer extends StatelessWidget {
  final ExecutorController controller;

  const ExecutorDrawer({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final serverController = TextEditingController(text: controller.serverUrl);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.green),
            child: Text("Настройки", style: TextStyle(color: Colors.white)),
          ),

          // 🔥 Поле ввода адреса сервера
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Адрес сервера:", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: serverController,
                  decoration: const InputDecoration(
                    hintText: "https://example.com",
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (value) {
                    controller.setServerUrl(value);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
