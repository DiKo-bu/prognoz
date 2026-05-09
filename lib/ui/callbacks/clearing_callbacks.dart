class ClearingCallbacks {
  final Function(double) onAreaChange;
  final Function(double) onVolumeChange;

  const ClearingCallbacks({
    required this.onAreaChange,
    required this.onVolumeChange,
  });
}
