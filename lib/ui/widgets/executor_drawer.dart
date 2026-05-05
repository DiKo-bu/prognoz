import 'package:flutter/material.dart';
import '../../data/controller.dart';

class ExecutorDrawer extends StatelessWidget {
  final ExecutorController controller;
  const ExecutorDrawer({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            margin: EdgeInsets.zero,
            child: Center(
              child: Text("ИСПОЛНИТЕЛИ",
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            ),
          ),
          Expanded(
            child: controller.executors.isEmpty
                ? const Center(child: Text("Нет исполнителей"))
                : ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: controller.executors.length,
                    itemBuilder: (context, index) {
                      String name = controller.executors[index];
                      return ListTile(
                        title: Text(name,
                            style: TextStyle(
                                fontWeight: controller.currentExecutor == name
                                    ? FontWeight.bold
                                    : FontWeight.normal)),
                        selected: controller.currentExecutor == name,
                        selectedTileColor: Colors.blue.withOpacity(0.1),
                        onTap: () {
                          controller.currentExecutor = name;
                          controller.loadData();
                          Navigator.pop(context);
                        },
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => controller.deleteExecutor(name),
                        ),
                      );
                    },
                  ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.add, color: Colors.blue),
            title: const Text("Добавить исполнителя",
                style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
            onTap: () => _showAddExecutorDialog(context),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showAddExecutorDialog(BuildContext context) {
    TextEditingController textCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Новый исполнитель'),
        content: TextField(
          controller: textCtrl,
          decoration: const InputDecoration(hintText: 'ФИО исполнителя'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('ОТМЕНА')),
          TextButton(
            onPressed: () {
              controller.createNewExecutor(textCtrl.text);
              Navigator.pop(context);
              Navigator.pop(context); // закрываем меню
            },
            child: const Text('СОЗДАТЬ'),
          ),
        ],
      ),
    );
  }
}
