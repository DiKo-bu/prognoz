import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/controller.dart';
import 'widgets/executor_drawer.dart';
import 'widgets/task_card_factory.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<ExecutorController>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(controller.currentExecutor.isEmpty
            ? "Нет исполнителя"
            : controller.currentExecutor),
      ),
      drawer: ExecutorDrawer(controller: controller),
      body: controller.isInitialized
          ? TaskCardFactory(controller: controller)
          : const Center(child: CircularProgressIndicator()),
      floatingActionButton: FloatingActionButton(
        onPressed: () => controller.addTask(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
