class GanttTaskData {
  final String name;
  final double startTime;
  final double endTime;
  final bool isCompleted;
  final bool isOverMax;
  GanttTaskData({
    required this.name,
    required this.startTime,
    required this.endTime,
    this.isCompleted = false,
    this.isOverMax = false,
  });
}
