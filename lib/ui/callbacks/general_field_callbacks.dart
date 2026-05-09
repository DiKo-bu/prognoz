class GeneralFieldCallbacks {
  final Function(String) onLocationChange;
  final Function(String) onQuarterChange;
  final Function(String) onAllotmentChange;

  const GeneralFieldCallbacks({
    required this.onLocationChange,
    required this.onQuarterChange,
    required this.onAllotmentChange,
  });
}
