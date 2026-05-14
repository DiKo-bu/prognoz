import 'package:flutter/material.dart';
import '../data/controller.dart';
import 'task_input_card.dart';
import 'result_dashboard.dart';

class ResultView extends StatelessWidget {
  final ExecutorController controller;

  const ResultView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Результаты и мониторинг'),
        backgroundColor: Colors.orange,
        elevation: 0,
        actions: [
          // Кнопка обновления данных с сервера
          controller.isFetching
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.sync),
                  tooltip: 'Обновить отчеты',
                  onPressed: () {
                    if (controller.currentExecutor.isNotEmpty) {
                      controller.fetchReportFromServer();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Сначала выберите исполнителя')),
                      );
                    }
                  },
                ),
        ],
      ),
      body: controller.tasks.isEmpty
          ? const Center(
              child: Text(
                'Нет данных для анализа.\nСформируйте план на вкладке "План".',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            )
          : Column(
              children: [
                // Блок с общими результатами (P90, риски)
                ResultDashboard(controller: controller),
                
                const Divider(height: 1),
                
                // Список этапов с текущим статусом выполнения
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    itemCount: controller.tasks.length,
                    itemBuilder: (context, i) {
                      var task = controller.tasks[i];
                      return TaskInputCard(
                        id: task.id,
                        title: task.name,
                        currentMin: task.min,
                        currentLikely: task.likely,
                        currentMax: task.max,
                        currentDepends: task.dependsOn.join(', '),
                        isCompleted: task.isCompleted,
                        actualDuration: task.actualDuration,
                        actualEndDate: task.actualEndDate,
                        projectStartDate: controller.startDate,
                        readOnly: true, // Карточки только для просмотра факта
                        
                        // Параметры лесоустройства (отображение)
                        plantingType: task.plantingType,
                        culture: task.culture,
                        location: task.location,
                        quarter: task.quarter,
                        allotment: task.allotment,
                        
                        // Пустые колбэки для readOnly режима
                        onCompletionChange: (_) {},
                        onActualChange: (_) {},
                        onTitleChange: (_) {},
                        onUpdate: (_, __) {},
                        onDependsChange: (_) {},
                        onDelete: () {},
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
