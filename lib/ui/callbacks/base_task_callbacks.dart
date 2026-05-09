class BaseTaskCallbacks {
  final Function(bool) onCompletionChange;
  final Function(double) onActualDurationChange;
  final Function(String) onTitleChange;
  final Function(String, double) onDurationValuesChange; // min/likely/max
  final Function(String) onDependsChange;
  final VoidCallback onDelete;

  const BaseTaskCallbacks({
    required this.onCompletionChange,
    required this.onActualDurationChange,
    required this.onTitleChange,
    required this.onDurationValuesChange,
    required this.onDependsChange,
    required this.onDelete,
  });
}
