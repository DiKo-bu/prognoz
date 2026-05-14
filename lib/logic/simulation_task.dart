class SimulationTask {
  int id;
  String name;
  double min;
  double likely;
  double max;
  List<int> dependsOn;
  bool isCompleted;
  double? actualDuration;
  DateTime? actualEndDate;

  // Поля лесоустройства
  String plantingType;
  String culture;
  double? plantingQuantity;
  double? plantingArea;
  String sowingBreed;
  double? sowingQuantityKg;
  double? sowingAreaHa;
  double? cuttingArea;
  double? cuttingVolume;
  double? clearCuttingArea;
  double? clearCuttingVolume;
  double? clearingArea;
  double? clearingVolume;
  int? panelsQuantity;
  String location;
  int? quarter;
  int? allotment;

  SimulationTask({
    required this.id,
    required this.name,
    required this.min,
    required this.likely,
    required this.max,
    this.dependsOn = const [],
    this.isCompleted = false,
    this.actualDuration,
    this.actualEndDate,
    this.plantingType = 'Сеянцы',
    this.culture = 'Вяз',
    this.plantingQuantity,
    this.plantingArea,
    this.sowingBreed = '',
    this.sowingQuantityKg,
    this.sowingAreaHa,
    this.cuttingArea,
    this.cuttingVolume,
    this.clearCuttingArea,
    this.clearCuttingVolume,
    this.clearingArea,
    this.clearingVolume,
    this.panelsQuantity,
    this.location = '',
    this.quarter,
    this.allotment,
  });

  factory SimulationTask.fromJson(Map<String, dynamic> json) {
    return SimulationTask(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      min: (json['min'] as num?)?.toDouble() ?? 1.0,
      likely: (json['likely'] as num?)?.toDouble() ?? 2.0,
      max: (json['max'] as num?)?.toDouble() ?? 3.0,
      dependsOn: json['dependsOn'] != null ? List<int>.from(json['dependsOn']) : [],
      isCompleted: json['isCompleted'] ?? false,
      actualDuration: (json['actualDuration'] as num?)?.toDouble(),
      actualEndDate: json['actualEndDate'] != null ? DateTime.parse(json['actualEndDate']) : null,
      plantingType: json['plantingType'] ?? 'Сеянцы',
      culture: json['culture'] ?? 'Вяз',
      plantingQuantity: (json['plantingQuantity'] as num?)?.toDouble(),
      plantingArea: (json['plantingArea'] as num?)?.toDouble(),
      sowingBreed: json['sowingBreed'] ?? '',
      sowingQuantityKg: (json['sowingQuantityKg'] as num?)?.toDouble(),
      sowingAreaHa: (json['sowingAreaHa'] as num?)?.toDouble(),
      cuttingArea: (json['cuttingArea'] as num?)?.toDouble(),
      cuttingVolume: (json['cuttingVolume'] as num?)?.toDouble(),
      clearCuttingArea: (json['clearCuttingArea'] as num?)?.toDouble(),
      clearCuttingVolume: (json['clearCuttingVolume'] as num?)?.toDouble(),
      clearingArea: (json['clearingArea'] as num?)?.toDouble(),
      clearingVolume: (json['clearingVolume'] as num?)?.toDouble(),
      panelsQuantity: json['panelsQuantity'] as int?,
      location: json['location'] ?? '',
      quarter: json['quarter'] as int?,
      allotment: json['allotment'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'min': min,
    'likely': likely,
    'max': max,
    'dependsOn': dependsOn,
    'isCompleted': isCompleted,
    'actualDuration': actualDuration,
    'actualEndDate': actualEndDate?.toIso8601String(),
    'plantingType': plantingType,
    'culture': culture,
    'plantingQuantity': plantingQuantity,
    'plantingArea': plantingArea,
    'sowingBreed': sowingBreed,
    'sowingQuantityKg': sowingQuantityKg,
    'sowingAreaHa': sowingAreaHa,
    'cuttingArea': cuttingArea,
    'cuttingVolume': cuttingVolume,
    'clearCuttingArea': clearCuttingArea,
    'clearCuttingVolume': clearCuttingVolume,
    'clearingArea': clearingArea,
    'clearingVolume': clearingVolume,
    'panelsQuantity': panelsQuantity,
    'location': location,
    'quarter': quarter,
    'allotment': allotment,
  };
}
