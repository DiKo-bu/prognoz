import 'package:flutter/material.dart';
import '../data/controller.dart';
import 'widgets/executor_drawer.dart';
import 'task_card_factory.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final controller = ExecutorController();

  @override
  void initState() {
    super.initState();
    controller.init().then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          controller.currentExecutor.isEmpty
              ? "Нет исполнителя"
              : controller.currentExecutor,
        ),
      ),
      drawer: ExecutorDrawer(controller: controller),

      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: controller.tasks.length,
        itemBuilder: (context, index) {
          return TaskCardFactory.build(
            context,
            index,
            controller,
            controller.startDate,
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          controller.addTask();
          setState(() {});
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
EOFcd ~/prognoz-main/prognoz-main
cat > lib/ui/home_page.dart << 'EOF'
import 'package:flutter/material.dart';
import '../data/controller.dart';
import 'widgets/executor_drawer.dart';
import 'task_card_factory.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final controller = ExecutorController();

  @override
  void initState() {
    super.initState();
    controller.init().then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          controller.currentExecutor.isEmpty
              ? "Нет исполнителя"
              : controller.currentExecutor,
        ),
      ),
      drawer: ExecutorDrawer(controller: controller),

      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: controller.tasks.length,
        itemBuilder: (context, index) {
          return TaskCardFactory.build(
            context,
            index,
            controller,
            controller.startDate,
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          controller.addTask();
          setState(() {});
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
