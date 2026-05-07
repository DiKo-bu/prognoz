import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../logic/gantt_task_data.dart';

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
      Color barColor;
      if (task.isOverMax) {
        barColor = Colors.red[400]!;
      } else if (task.isCompleted) {
        barColor = Colors.green[400]!;
      } else {
        barColor = Colors.blue[300]!;
      }
      final paintBar = Paint()..color = barColor..style = PaintingStyle.fill;

      textPainter.text = TextSpan(
          text: taskId,
          style: TextStyle(fontWeight: FontWeight.bold, color: task.isOverMax ? Colors.red : (task.isCompleted ? Colors.green : Colors.blue)));
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
