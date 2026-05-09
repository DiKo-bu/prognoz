class SowingCallbacks {
  final Function(String?) onBreedChange;
  final Function(double) onQuantityKgChange;
  final Function(double) onAreaHaChange;

  const SowingCallbacks({
    required this.onBreedChange,
    required this.onQuantityKgChange,
    required this.onAreaHaChange,
  });
}
