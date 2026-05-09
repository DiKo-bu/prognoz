import 'package:flutter/material.dart';
import '../logic/simulation_task.dart';
import 'constants.dart';
import 'callbacks/planting_callbacks.dart';
import 'callbacks/sowing_callbacks.dart';
import 'callbacks/selective_cutting_callbacks.dart';
import 'callbacks/clear_cutting_callbacks.dart';
import 'callbacks/clearing_callbacks.dart';
import 'callbacks/panels_callbacks.dart';
import 'callbacks/general_field_callbacks.dart';
import 'callbacks/base_task_callbacks.dart';
import 'widgets/task_card/task_id_badge.dart';
import 'widgets/task_card/completion_row.dart';
import 'widgets/task_card/duration_fields.dart';
import 'widgets/task_card/depends_field.dart';
import 'widgets/task_card/ratio_error_text.dart';
import 'widgets/task_card/over_max_warning.dart';
import 'widgets/task_card/deadline_warning.dart';
import 'widgets/task_fields/planting_fields.dart';
import 'widgets/task_fields/sowing_fields.dart';
import 'widgets/task_fields/cutting_fields.dart';
import 'widgets/task_fields/clear_cutting_fields.dart';
import 'widgets/task_fields/clearing_fields.dart';
import 'widgets/task_fields/panels_field.dart';
import 'widgets/task_fields/location_field.dart';
import 'widgets/task_fields/quarter_allotment_fields.dart';

class TaskInputCard extends StatelessWidget {
  final String id;
  final String title;
  final double min, likely, max;
  final String depends;
  final bool isCompleted;
  final double actualDuration;
  final DateTime? actualEndDate;
  final DateTime projectStartDate;

  // Данные для специфичных полей
  final String? plantingType;
  final String? culture;
  final double? plantingQuantity;
  final double? plantingArea;
  final String? sowingBreed;
  final double? sowingQuantityKg;
  final double? sowingAreaHa;
  final double? cuttingArea;
  final double? cuttingVolume;
  final double? clearCuttingArea;
  final double? clearCuttingVolume;
  final double? clearingArea;
  final double? clearingVolume;
  final double? panelsQuantity;
  final String? location;
  final String? quarter;
  final String? allotment;

  // Группы колбэков
  final BaseTaskCallbacks base;
  final PlantingCallbacks? planting;
  final SowingCallbacks? sowing;
  final SelectiveCuttingCallbacks? selectiveCutting;
  final ClearCuttingCallbacks? clearCutting;
  final ClearingCallbacks? clearing;
  final PanelsCallbacks? panels;
  final GeneralFieldCallbacks? general;

  const TaskInputCard({
    super.key,
    required this.id,
    required this.title,
    required this.min,
    required this.likely,
    required this.max,
    required this.depends,
    required this.isCompleted,
    required this.actualDuration,
    this.actualEndDate,
    required this.projectStartDate,
    this.plantingType,
    this.culture,
    this.plantingQuantity,
    this.plantingArea,
    this.sowingBreed,
    this.sowingQuantityKg,
    this.sowingAreaHa,
    this.cuttingArea,
    this.cuttingVolume,
    this.clearCuttingArea,
    this.clearCuttingVolume,
    this.clearingArea,
    this.clearingVolume,
    this.panelsQuantity,
    this.location,
    this.quarter,
    this.allotment,
    required this.base,
    this.planting,
    this.sowing,
    this.selectiveCutting,
    this.clearCutting,
    this.clearing,
    this.panels,
    this.general,
  });

  @override
  Widget build(BuildContext context) {
    final bool isInvalid = !isCompleted && ((min > likely) || (likely > max));
    final bool notEmpty = min != 0 || likely != 0 || max != 0;
    final bool showError = isInvalid && notEmpty;
    final bool isOverMax = isCompleted && actualDuration > max;

    DateTime plannedEnd = projectStartDate.add(Duration(days: likely.toInt()));
    bool deadlineViolation = isCompleted && actualEndDate != null && actualEndDate!.isAfter(plannedEnd);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      shape: showError || isOverMax || deadlineViolation
          ? RoundedRectangleBorder(
              side: BorderSide(
                color: showError
                    ? Colors.red
                    : (deadlineViolation ? Colors.red : Colors.orange),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(4))
          : null,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              children: [
                TaskIdBadge(
                  id: id,
                  isWarning: isOverMax || deadlineViolation,
                  isCompleted: isCompleted,
                  showError: showError,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: workNames.contains(title) ? title : null,
                    decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                    items: workNames
                        .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(e,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) base.onTitleChange(v);
                    },
                    hint: const Text('Выберите работу',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.redAccent, size: 20),
                  onPressed: base.onDelete,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            CompletionRow(
              isCompleted: isCompleted,
              actualDuration: actualDuration,
              isOverMax: isOverMax,
              onChanged: base.onCompletionChange,
              onDurationChanged: base.onActualDurationChange,
            ),
            if (isOverMax) const OverMaxWarning(),
            if (deadlineViolation) DeadlineWarning(planned: plannedEnd, actual: actualEndDate!),
            DurationFields(
              min: min,
              likely: likely,
              max: max,
              isCompleted: isCompleted,
              onChanged: base.onDurationValuesChange,
            ),
            if (showError) const RatioErrorText(),
            const SizedBox(height: 8),
            if (title == 'Посадка') ...[
              PlantingFields(
                plantingType: plantingType,
                culture: culture,
                plantingQuantity: plantingQuantity,
                plantingArea: plantingArea,
                onPlantingTypeChange: planting?.onTypeChange ?? (_) {},
                onCultureChange: planting?.onCultureChange ?? (_) {},
                onPlantingQuantityChange: planting?.onQuantityChange ?? (_) {},
                onPlantingAreaChange: planting?.onAreaChange ?? (_) {},
              ),
              if (location != null || general != null)
                LocationField(
                  location: location,
                  onChanged: general?.onLocationChange ?? (_) {},
                ),
            ],
            if (title == 'Посев') ...[
              SowingFields(
                sowingBreed: sowingBreed,
                sowingQuantityKg: sowingQuantityKg,
                sowingAreaHa: sowingAreaHa,
                onSowingBreedChange: sowing?.onBreedChange ?? (_) {},
                onSowingQuantityKgChange: sowing?.onQuantityKgChange ?? (_) {},
                onSowingAreaHaChange: sowing?.onAreaHaChange ?? (_) {},
              ),
              if (location != null || general != null)
                LocationField(
                  location: location,
                  onChanged: general?.onLocationChange ?? (_) {},
                ),
            ],
            if (title == 'Выборочная санитарная рубка') ...[
              CuttingFields(
                cuttingArea: cuttingArea,
                cuttingVolume: cuttingVolume,
                onCuttingAreaChange: selectiveCutting?.onAreaChange ?? (_) {},
                onCuttingVolumeChange: selectiveCutting?.onVolumeChange ?? (_) {},
              ),
              QuarterAllotmentFields(
                quarter: quarter,
                allotment: allotment,
                onQuarterChanged: general?.onQuarterChange ?? (_) {},
                onAllotmentChanged: general?.onAllotmentChange ?? (_) {},
              ),
            ],
            if (title == 'Сплошная санитарная рубка') ...[
              ClearCuttingFields(
                clearCuttingArea: clearCuttingArea,
                clearCuttingVolume: clearCuttingVolume,
                onClearCuttingAreaChange: clearCutting?.onAreaChange ?? (_) {},
                onClearCuttingVolumeChange: clearCutting?.onVolumeChange ?? (_) {},
              ),
              QuarterAllotmentFields(
                quarter: quarter,
                allotment: allotment,
                onQuarterChanged: general?.onQuarterChange ?? (_) {},
                onAllotmentChanged: general?.onAllotmentChange ?? (_) {},
              ),
            ],
            if (title == 'Уборка захламленности') ...[
              ClearingFields(
                clearingArea: clearingArea,
                clearingVolume: clearingVolume,
                onClearingAreaChange: clearing?.onAreaChange ?? (_) {},
                onClearingVolumeChange: clearing?.onVolumeChange ?? (_) {},
              ),
              QuarterAllotmentFields(
                quarter: quarter,
                allotment: allotment,
                onQuarterChanged: general?.onQuarterChange ?? (_) {},
                onAllotmentChanged: general?.onAllotmentChange ?? (_) {},
              ),
            ],
            if (title == 'Установка панно и аншлагов') ...[
              PanelsField(
                panelsQuantity: panelsQuantity,
                onPanelsQuantityChange: panels?.onQuantityChange ?? (_) {},
              ),
              QuarterAllotmentFields(
                quarter: quarter,
                allotment: allotment,
                onQuarterChanged: general?.onQuarterChange ?? (_) {},
                onAllotmentChanged: general?.onAllotmentChange ?? (_) {},
              ),
            ],
            DependsField(
              currentDepends: depends,
              onChanged: base.onDependsChange,
            ),
          ],
        ),
      ),
    );
  }
}
