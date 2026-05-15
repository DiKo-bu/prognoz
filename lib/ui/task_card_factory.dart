import 'package:flutter/material.dart';

import '../data/controller.dart';
import '../logic/simulation_task.dart';
import 'task_input_card.dart';
import 'callbacks/planting_callbacks.dart';
import 'callbacks/sowing_callbacks.dart';
import 'callbacks/selective_cutting_callbacks.dart';
import 'callbacks/clear_cutting_callbacks.dart';
import 'callbacks/clearing_callbacks.dart';
import 'callbacks/panels_callbacks.dart';
import 'callbacks/general_field_callbacks.dart';
import 'callbacks/base_task_callbacks.dart';

class TaskCardFactory {
  static Widget build(
    BuildContext context,
    int index,
    ExecutorController controller,
    DateTime startDate,
  ) {
    final SimulationTask task = controller.tasks[index];

    return TaskInputCard(
      id: task.id.toString(),
      title: task.name,
      min: task.min,
      likely: task.likely,
      max: task.max,
      depends: task.dependsOn.join(', '),
      isCompleted: task.isCompleted,
      actualDuration: task.actualDuration ?? 0,
      actualEndDate: task.actualEndDate,
      projectStartDate: startDate,
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
      panelsQuantity: (task.panelsQuantity ?? 0).toDouble(),
      location: task.location,
      quarter: task.quarter?.toString(),
      allotment: task.allotment?.toString(),
      base: BaseTaskCallbacks(
        onCompletionChange: (v) => controller.updateTaskCompletion(index, v),
        onActualDurationChange: (v) =>
            controller.updateTaskActualDuration(index, v),
        onTitleChange: (v) => controller.updateTaskTitle(index, v),
        onDurationValuesChange: (key, val) =>
            controller.updateTaskValues(index, key, val),
        onDependsChange: (val) => controller.updateTaskDepends(index, val),
        onDelete: () => controller.removeTask(index),
      ),
      planting: task.name == 'Посадка'
          ? PlantingCallbacks(
              onTypeChange: (v) =>
                  controller.updateTaskPlantingType(index, v),
              onCultureChange: (v) =>
                  controller.updateTaskCulture(index, v),
              onQuantityChange: (v) =>
                  controller.updateTaskPlantingQuantity(index, v),
              onAreaChange: (v) =>
                  controller.updateTaskPlantingArea(index, v),
            )
          : null,
      sowing: task.name == 'Посев'
          ? SowingCallbacks(
              onBreedChange: (v) =>
                  controller.updateTaskSowingBreed(index, v ?? ''),
              onQuantityKgChange: (v) =>
                  controller.updateTaskSowingQuantityKg(index, v),
              onAreaHaChange: (v) =>
                  controller.updateTaskSowingAreaHa(index, v),
            )
          : null,
      selectiveCutting: task.name == 'Выборочная санитарная рубка'
          ? SelectiveCuttingCallbacks(
              onAreaChange: (v) =>
                  controller.updateTaskCuttingArea(index, v),
              onVolumeChange: (v) =>
                  controller.updateTaskCuttingVolume(index, v),
            )
          : null,
      clearCutting: task.name == 'Сплошная санитарная рубка'
          ? ClearCuttingCallbacks(
              onAreaChange: (v) =>
                  controller.updateTaskClearCuttingArea(index, v),
              onVolumeChange: (v) =>
                  controller.updateTaskClearCuttingVolume(index, v),
            )
          : null,
      clearing: task.name == 'Уборка захламленности'
          ? ClearingCallbacks(
              onAreaChange: (v) =>
                  controller.updateTaskClearingArea(index, v),
              onVolumeChange: (v) =>
                  controller.updateTaskClearingVolume(index, v),
            )
          : null,
      panels: task.name == 'Установка панно и аншлагов'
          ? PanelsCallbacks(
              onQuantityChange: (v) =>
                  controller.updateTaskPanelsQuantity(index, v.toInt()),
            )
          : null,
      general: GeneralFieldCallbacks(
        onLocationChange: (v) => controller.updateTaskLocation(index, v),
        onQuarterChange: (v) => controller.updateTaskQuarter(index, v),
        onAllotmentChange: (v) => controller.updateTaskAllotment(index, v),
      ),
    );
  }
}
