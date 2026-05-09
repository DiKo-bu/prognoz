class SelectiveCuttingCallbacks {
  final Function(double) onAreaChange;
  final Function(double) onVolumeChange;

  const SelectiveCuttingCallbacks({
    required this.onAreaChange,
    required this.onVolumeChange,
  });
}
