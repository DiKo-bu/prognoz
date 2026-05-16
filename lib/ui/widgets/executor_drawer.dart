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

          // 🔥 ВЫБОР ИСПОЛНИТЕЛЯ
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Исполнитель:", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                DropdownButton<String>(
                  value: controller.currentExecutor.isEmpty
                      ? null
                      : controller.currentExecutor,
                  isExpanded: true,
                  hint: const Text("Выберите исполнителя"),
                  items: controller.executors
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) {
                      controller.currentExecutor = v;
                      controller.loadData();
                    }
                  },
                ),
                const SizedBox(height: 8),
                TextField(
                  decoration: const InputDecoration(
                    hintText: "Новый исполнитель",
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (value) {
                    controller.createNewExecutor(value);
                  },
                ),
              ],
            ),
          ),

          const Divider(),

          // 🔥 Адрес сервера
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
