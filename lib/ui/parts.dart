import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../logic/engine.dart';

// Список доступных названий работ
const List<String> workNames = ['Подготовка почвы', 'Посадка', 'Вырубка', 'Охрана', 'Обход'];

class TaskInputCard extends StatelessWidget {
  final String id;
  final String title;
  final double currentMin, currentLikely, currentMax;
  final String currentDepends;
  final bool isCompleted;
  final double actualDuration;
  final Function(bool) onCompletionChange;
  final Function(double) onActualChange;
  final Function(String) onTitleChange;
  final Function(String, double) onUpdate;
  final Function(String) onDependsChange;
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
    required this.onCompletionChange,
    required this.onActualChange,
    required this.onTitleChange,
    required this.onUpdate,
    required this.onDependsChange,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    bool isInvalid = !isCompleted && ((currentMin > currentLikely) || (currentLikely > currentMax));
    bool notEmpty = currentMin != 0 || currentLikely != 0 || currentMax != 0;
    bool showError = isInvalid && notEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      shape: showError
          ? RoundedRectangleBorder(
              side: const BorderSide(color: Colors.red, width: 2),
              borderRadius: BorderRadius.circular(4))
          : null,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: isCompleted
                          ? Colors.green
                          : (showError ? Colors.red : Colors.blue[700]),
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
            ),
            Row(
              children: [
                Checkbox(value: isCompleted, activeColor: Colors.green, onChanged: (v) => onCompletionChange(v ?? false)),
                const Text("Завершено", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 13)),
                if (isCompleted) ...[
                  const Spacer(),
                  _field('Факт. дней', actualDuration, onActualChange, color: Colors.green),
                  const SizedBox(width: 5),
                ]
              ],
            ),
            IgnorePointer(
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
            ),
            if (showError)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text("Ошибка: должно быть Мин <= Норма <= Макс",
                    style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: currentDepends,
              decoration: const InputDecoration(
                  labelText: 'После этапов (номера через запятую)',
                  isDense: true,
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(fontSize: 11)),
              style: const TextStyle(fontSize: 13),
              onChanged: onDependsChange,
            ),
          ],
        ),
      ),
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

class GanttChart extends StatelessWidget {
  final Map<String, GanttTaskData> data;
  final double totalDuration;
  final DateTime startDate;
  const GanttChart({super.key, required this.data, required this.totalDuration, required this.startDate});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty || totalDuration == 0) return const SizedBox();
    return Container(
      height: (data.length * 35.0) + 30.0,
      width: double.infinity,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(5)),
      child: CustomPaint(painter: GanttPainter(data: data, totalDuration: totalDuration, startDate: startDate)),
    );
  }
}

class GanttPainter extends CustomPainter {
  final Map<String, GanttTaskData> data;
  final double totalDuration;
  final DateTime startDate;
  GanttPainter({required this.data, required this.totalDuration, required this.startDate});

  @override
  void paint(Canvas canvas, Size size) {
    if (totalDuration <= 0) return;
    final textPainter = TextPainter(textDirection: ui.TextDirection.ltr);
    double pxPerUnit = (size.width - 30.0) / totalDuration;

    int index = 0;
    for (int t = 0; t <= totalDuration.toInt(); t += (totalDuration / 5).ceil()) {
      double x = 30.0 + (t * pxPerUnit);
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), Paint()..color = Colors.grey[200]!);
      DateTime stepDate = startDate.add(Duration(days: t));
      String dateStr = "${stepDate.day.toString().padLeft(2, '0')}.${stepDate.month.toString().padLeft(2, '0')}";
      textPainter.text = TextSpan(text: dateStr, style: const TextStyle(color: Colors.grey, fontSize: 10));
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - (textPainter.width / 2), size.height - 12));
    }

    for (var taskId in data.keys) {
      final task = data[taskId]!;
      double y = (index * 35.0) + 5;
      final paintBar = Paint()
        ..color = task.isCompleted ? Colors.green[400]! : Colors.blue[300]!
        ..style = PaintingStyle.fill;

      textPainter.text = TextSpan(
          text: taskId,
          style: TextStyle(fontWeight: FontWeight.bold, color: task.isCompleted ? Colors.green : Colors.blue));
      textPainter.layout();
      textPainter.paint(canvas, Offset(5, y + 8));

      double startX = 30.0 + (task.startTime * pxPerUnit);
      double barWidth = (task.endTime - task.startTime) * pxPerUnit;
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(startX, y, barWidth, 25), const Radius.circular(3)), paintBar);

      textPainter.text = TextSpan(text: task.name, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold));
      textPainter.layout();
      if (textPainter.width < barWidth) {
        textPainter.paint(canvas, Offset(startX + (barWidth - textPainter.width) / 2, y + 5));
      } else {
        textPainter.paint(canvas, Offset(startX + 5, y + 5));
      }
      index++;
    }
  }
  @override
  bool shouldRepaint(covariant GanttPainter oldDelegate) => true;
}
