import 'package:flutter/material.dart';
import '../logic/simulation_task.dart';
import 'constants.dart';
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
  final double currentMin, currentLikely, currentMax;
  final String currentDepends;
  final bool isCompleted;
  final double actualDuration;
  final DateTime? actualEndDate;          // новое
  final DateTime projectStartDate;        // нужно для расчёта планового окончания

  // Посадка
  final String? plantingType;
  final String? culture;
  final double? plantingQuantity;
  final double? plantingArea;
  // Посев
  final String? sowingBreed;
  final double? sowingQuantityKg;
  final double? sowingAreaHa;
  // Выборочная санитарная рубка
  final double? cuttingArea;
  final double? cuttingVolume;
  // Сплошная санитарная рубка
  final double? clearCuttingArea;
  final double? clearCuttingVolume;
  // Уборка захламленности
  final double? clearingArea;
  final double? clearingVolume;
  // Установка панно и аншлагов
  final double? panelsQuantity;
  // Новые поля
  final String? location;
  final String? quarter;
  final String? allotment;

  final Function(bool) onCompletionChange;
  final Function(double) onActualChange;
  final Function(String) onTitleChange;
  final Function(String, double) onUpdate;
  final Function(String) onDependsChange;
  final Function(String?) onPlantingTypeChange;
  final Function(String?) onCultureChange;
  final Function(double) onPlantingQuantityChange;
  final Function(double) onPlantingAreaChange;
  final Function(String?) onSowingBreedChange;
  final Function(double) onSowingQuantityKgChange;
  final Function(double) onSowingAreaHaChange;
  final Function(double) onCuttingAreaChange;
  final Function(double) onCuttingVolumeChange;
  final Function(double) onClearCuttingAreaChange;
  final Function(double) onClearCuttingVolumeChange;
  final Function(double) onClearingAreaChange;
  final Function(double) onClearingVolumeChange;
  final Function(double) onPanelsQuantityChange;
  final Function(String) onLocationChange;
  final Function(String) onQuarterChange;
  final Function(String) onAllotmentChange;
  final VoidCallback onDelete;

  const TaskInputCard({
    super.key,
    required this.id,
    required this.title,
    required this.currentMin,
    required this.currentLikely,
    required this.currentMax,
    required this.currentDepends,
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
    required this.onCompletionChange,
    required this.onActualChange,
    required this.onTitleChange,
    required this.onUpdate,
    required this.onDependsChange,
    required this.onPlantingTypeChange,
    required this.onCultureChange,
    required this.onPlantingQuantityChange,
    required this.onPlantingAreaChange,
    required this.onSowingBreedChange,
    required this.onSowingQuantityKgChange,
    required this.onSowingAreaHaChange,
    required this.onCuttingAreaChange,
    required this.onCuttingVolumeChange,
    required this.onClearCuttingAreaChange,
    required this.onClearCuttingVolumeChange,
    required this.onClearingAreaChange,
    required this.onClearingVolumeChange,
    required this.onPanelsQuantityChange,
    required this.onLocationChange,
    required this.onQuarterChange,
    required this.onAllotmentChange,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool isInvalid = !isCompleted && ((currentMin > currentLikely) || (currentLikely > currentMax));
    final bool notEmpty = currentMin != 0 || currentLikely != 0 || currentMax != 0;
    final bool showError = isInvalid && notEmpty;
    final bool isOverMax = isCompleted && actualDuration > currentMax;

    // Проверка срыва срока
    DateTime plannedEnd = projectStartDate.add(Duration(days: currentLikely.toInt()));
    bool deadlineViolation = isCompleted && actualEndDate != null && actualEndDate!.isAfter(plannedEnd);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      shape: showError || isOverMax || deadlineViolation
          ? RoundedRectangleBorder(
              side: BorderSide(color: showError ? Colors.red : (deadlineViolation ? Colors.red : Colors.orange), width: 2),
              borderRadius: BorderRadius.circular(4))
          : null,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            _buildHeader(isOverMax || deadlineViolation, isCompleted, showError),
            _buildCompletionRow(isOverMax),
            if (isOverMax) _overMaxWarning,
            if (deadlineViolation) _deadlineWarning(plannedEnd, actualEndDate!),
            _buildDurationFields(isCompleted),
            if (showError) _ratioError,
            const SizedBox(height: 8),
            if (title == 'Посадка') ...[
              PlantingFields(
                plantingType: plantingType,
                culture: culture,
                plantingQuantity: plantingQuantity,
                plantingArea: plantingArea,
                onPlantingTypeChange: onPlantingTypeChange,
                onCultureChange: onCultureChange,
                onPlantingQuantityChange: onPlantingQuantityChange,
                onPlantingAreaChange: onPlantingAreaChange,
              ),
              LocationField(location: location, onChanged: onLocationChange),
            ],
            if (title == 'Посев') ...[
              SowingFields(
                sowingBreed: sowingBreed,
                sowingQuantityKg: sowingQuantityKg,
                sowingAreaHa: sowingAreaHa,
                onSowingBreedChange: onSowingBreedChange,
                onSowingQuantityKgChange: onSowingQuantityKgChange,
                onSowingAreaHaChange: onSowingAreaHaChange,
              ),
              LocationField(location: location, onChanged: onLocationChange),
            ],
            if (title == 'Выборочная санитарная рубка') ...[
              CuttingFields(
                cuttingArea: cuttingArea,
                cuttingVolume: cuttingVolume,
                onCuttingAreaChange: onCuttingAreaChange,
                onCuttingVolumeChange: onCuttingVolumeChange,
              ),
              QuarterAllotmentFields(
                quarter: quarter,
                allotment: allotment,
                onQuarterChanged: onQuarterChange,
                onAllotmentChanged: onAllotmentChange,
              ),
            ],
            if (title == 'Сплошная санитарная рубка') ...[
              ClearCuttingFields(
                clearCuttingArea: clearCuttingArea,
                clearCuttingVolume: clearCuttingVolume,
                onClearCuttingAreaChange: onClearCuttingAreaChange,
                onClearCuttingVolumeChange: onClearCuttingVolumeChange,
              ),
              QuarterAllotmentFields(
                quarter: quarter,
                allotment: allotment,
                onQuarterChanged: onQuarterChange,
                onAllotmentChanged: onAllotmentChange,
              ),
            ],
            if (title == 'Уборка захламленности') ...[
              ClearingFields(
                clearingArea: clearingArea,
                clearingVolume: clearingVolume,
                onClearingAreaChange: onClearingAreaChange,
                onClearingVolumeChange: onClearingVolumeChange,
              ),
              QuarterAllotmentFields(
                quarter: quarter,
                allotment: allotment,
                onQuarterChanged: onQuarterChange,
                onAllotmentChanged: onAllotmentChange,
              ),
            ],
            if (title == 'Установка панно и аншлагов') ...[
              PanelsField(
                panelsQuantity: panelsQuantity,
                onPanelsQuantityChange: onPanelsQuantityChange,
              ),
              QuarterAllotmentFields(
                quarter: quarter,
                allotment: allotment,
                onQuarterChanged: onQuarterChange,
                onAllotmentChanged: onAllotmentChange,
              ),
            ],
            _buildDependsField(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isWarning, bool isCompleted, bool showError) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
              color: isWarning
                  ? Colors.red
                  : (isCompleted ? Colors.green : (showError ? Colors.red : Colors.blue[700])),
              borderRadius: BorderRadius.circular(4)),
          child: Text(id, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: workNames.contains(title) ? title : null,
            decoration: const InputDecoration(border: InputBorder.none, isDense: true),
            items: workNames.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)))).toList(),
            onChanged: (v) {
              if (v != null) onTitleChange(v);
            },
            hint: const Text('Выберите работу', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ),
        ),
        IconButton(
            icon: const Icon(Icons.close, color: Colors.redAccent, size: 20),
            onPressed: onDelete,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints()),
      ],
    );
  }

  Widget _buildCompletionRow(bool isOverMax) {
    return Row(
      children: [
        Checkbox(value: isCompleted, activeColor: Colors.green, onChanged: (v) => onCompletionChange(v ?? false)),
        const Text("Завершено", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 13)),
        if (isCompleted) ...[
          const Spacer(),
          SizedBox(
            width: 80,
            child: TextFormField(
              initialValue: actualDuration == 0 ? '' : actualDuration.toString().replaceAll(RegExp(r'\.0$'), ''),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(fontSize: 13, color: isOverMax ? Colors.red : Colors.green, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                labelText: 'Факт. дней',
                isDense: true,
                labelStyle: TextStyle(color: isOverMax ? Colors.red : Colors.green),
                suffixIcon: isOverMax ? const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 18) : null,
              ),
              onChanged: (v) => onActualChange(double.tryParse(v.replaceAll(',', '.')) ?? 0),
            ),
          ),
          const SizedBox(width: 5),
        ],
      ],
    );
  }

  Widget get _overMaxWarning => const Padding(
        padding: EdgeInsets.only(top: 4),
        child: Text("⚠️ Превышение максимума!",
            style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
      );

  Widget _deadlineWarning(DateTime planned, DateTime actual) {
    final fmt = (DateTime d) => "${d.day.toString().padLeft(2,'0')}.${d.month.toString().padLeft(2,'0')}";
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        "⚠️ Срыв срока! План: ${fmt(planned)}, Факт: ${fmt(actual)}",
        style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDurationFields(bool isCompleted) {
    return IgnorePointer(
      ignoring: isCompleted,
      child: Opacity(
        opacity: isCompleted ? 0.3 : 1.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _field('Мин', currentMin, (v) => onUpdate('min', v)),
            _field('Норма', currentLikely, (v) => onUpdate('likely', v)),
            _field('Макс', currentMax, (v) => onUpdate('max', v)),
          ],
        ),
      ),
    );
  }

  Widget get _ratioError => const Padding(
        padding: EdgeInsets.only(top: 8),
        child: Text("Ошибка: должно быть Мин <= Норма <= Макс",
            style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
      );

  Widget _buildDependsField() {
    return TextFormField(
      initialValue: currentDepends,
      decoration: const InputDecoration(
          labelText: 'После этапов (номера через запятую)',
          isDense: true,
          border: OutlineInputBorder(),
          labelStyle: TextStyle(fontSize: 11)),
      style: const TextStyle(fontSize: 13),
      onChanged: onDependsChange,
    );
  }

  Widget _field(String label, double val, Function(double) onChanged, {Color? color}) {
    String initVal = val == 0 ? '' : val.toString().replaceAll(RegExp(r'\.0$'), '');
    return SizedBox(
      width: 65,
      child: TextFormField(
        initialValue: initVal,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: TextStyle(fontSize: 13, color: color, fontWeight: color != null ? FontWeight.bold : FontWeight.normal),
        decoration: InputDecoration(labelText: label, isDense: true, labelStyle: TextStyle(color: color)),
        onChanged: (v) => onChanged(double.tryParse(v.replaceAll(',', '.')) ?? 0),
      ),
    );
  }
}
