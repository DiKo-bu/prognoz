class ClearCuttingCallbacks {
  final Function(double) onAreaChange;
  final Function(double) onVolumeChange;

  const ClearCuttingCallbacks({
    required this.onAreaChange,
    required this.onVolumeChange,
  });
}
