import 'package:flutter/material.dart';
import '../../data/controller.dart';

class ProjectDrawer extends StatelessWidget {
  final ProjectController controller;

  const ProjectDrawer({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            margin: EdgeInsets.zero,
            child: Center(
              child: Text("ПРОЕКТЫ", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold))
            )
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: controller.projects.length,
              itemBuilder: (context, index) {
                String pName = controller.projects[index];
                return ListTile(
                  title: Text(pName, style: TextStyle(fontWeight: controller.currentProject == pName ? FontWeight.bold : FontWeight.normal)),
                  selected: controller.currentProject == pName,
                  selectedTileColor: Colors.blue.withOpacity(0.1),
                  onTap: () {
                    controller.currentProject = pName;
                    controller.loadData();
                    Navigator.pop(context); // Закрываем меню
                  },
                  trailing: controller.projects.length > 1 
                    ? IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => controller.deleteProject(pName))
                    : null,
                );
              },
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.add, color: Colors.blue),
            title: const Text("Создать проект", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
            onTap: () => _showAddProjectDialog(context),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showAddProjectDialog(BuildContext context) {
    TextEditingController textCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Новый проект'),
        content: TextField(
          controller: textCtrl,
          decoration: const InputDecoration(hintText: 'Название (напр. Участок 4)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('ОТМЕНА')),
          TextButton(
            onPressed: () {
              controller.createNewProject(textCtrl.text);
              Navigator.pop(context); 
              Navigator.pop(context); 
            },
            child: const Text('СОЗДАТЬ'),
          ),
        ],
      ),
    );
  }
}
