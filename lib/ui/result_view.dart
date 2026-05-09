import 'package:flutter/material.dart';
import '../data/controller.dart';
import 'task_input_card.dart';
import 'result_dashboard.dart'; // если нужна диаграмма Ганта, можно показать её здесь

class ResultView extends StatelessWidget {
  final ExecutorController controller;

  const ResultView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller.tasks.isEmpty) {
      return const Center(child: Text('Нет данных'));
    }

    final tasks = controller.tasks;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      itemCount: tasks.length,
      itemBuilder: (context, i) {
        var task = tasks[i];
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
          readOnly: true,   // только для чтения
          plantingType: task.plantingType,
          culture: task.culture,
          plantingQuantity: task.plantingQuantity,
          plantingArea: task.plantingArea,
          sowingBreed: task.sowingBreed,
          sowingQuantityKg: task.sowingQuantityKg,
          sowingAreaHa: task.sowingAreaHa,
          cuttingArea: task.cuttingArea,
          cuttingVolume: task.cuttingVolume,
          clearCuttingArea: task.clearCuttingArea,
          clearCuttingVolume: task.clearCuttingVolume,
          clearingArea: task.clearingArea,
          clearingVolume: task.clearingVolume,
          panelsQuantity: task.panelsQuantity,
          location: task.location,
          quarter: task.quarter,
          allotment: task.allotment,
          // колбэки не нужны в readOnly, но формально передаём пустые функции
          onCompletionChange: (_) {},
          onActualChange: (_) {},
          onTitleChange: (_) {},
          onUpdate: (_, __) {},
          onDependsChange: (_) {},
          onPlantingTypeChange: (_) {},
          onCultureChange: (_) {},
          onPlantingQuantityChange: (_) {},
          onPlantingAreaChange: (_) {},
          onSowingBreedChange: (_) {},
          onSowingQuantityKgChange: (_) {},
          onSowingAreaHaChange: (_) {},
          onCuttingAreaChange: (_) {},
          onCuttingVolumeChange: (_) {},
          onClearCuttingAreaChange: (_) {},
          onClearCuttingVolumeChange: (_) {},
          onClearingAreaChange: (_) {},
          onClearingVolumeChange: (_) {},
          onPanelsQuantityChange: (_) {},
          onLocationChange: (_) {},
          onQuarterChange: (_) {},
          onAllotmentChange: (_) {},
          onDelete: () {},
        );
      },
    );
  }
}
