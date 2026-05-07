import 'gantt_task_data.dart';

class BaselinePlan {
  final Map<String, GanttTaskData> taskData;
  final double totalDuration;
  BaselinePlan({required this.taskData, required this.totalDuration});
}
