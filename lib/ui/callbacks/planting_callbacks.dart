class PlantingCallbacks {
  final Function(String?) onTypeChange;
  final Function(String?) onCultureChange;
  final Function(double) onQuantityChange;
  final Function(double) onAreaChange;

  const PlantingCallbacks({
    required this.onTypeChange,
    required this.onCultureChange,
    required this.onQuantityChange,
    required this.onAreaChange,
  });
}
