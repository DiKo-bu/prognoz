import 'dart:math';

class SimulationTask {
  String id;
  String name;
  double min, likely, max;
  List<String> dependsOn;
  bool isCompleted;
  double actualDuration;

  // поля для Посадки
  String? plantingType;
  String? culture;
  double? plantingQuantity;
  double? plantingArea;

  // поля для Посева
  String? sowingBreed;
  double? sowingQuantityKg;
  double? sowingAreaHa;

  // поля для Выборочной санитарной рубки
  double? cuttingArea;
  double? cuttingVolume;

  // поля для Сплошной санитарной рубки
  double? clearCuttingArea;
  double? clearCuttingVolume;

  // поля для Уборки захламленности
  double? clearingArea;
  double? clearingVolume;

  // поле для Установки панно и аншлагов
  double? panelsQuantity;

  // новые общие поля
  String? location;   // "Где?" (для Посадки и Посева)
  String? quarter;    // Квартал
  String? allotment;  // Выдел

  SimulationTask({
    required this.id,
    required this.name,
    this.min = 0,
    this.likely = 0,
    this.max = 0,
    this.dependsOn = const [],
    this.isCompleted = false,
    this.actualDuration = 0,
    this.plantingType,
    this.culture,
    this.plantingQuantity,
    this.plantingArea,
    this.sowingBreed,
    this.sowingQuantityKg,
    this.sowingAreaHa,
    this.cuttingArea,
    this.cuttingVolume,
    this.clearCuttingArea,
    this.clearCuttingVolume,
    this.clearingArea,
    this.clearingVolume,
    this.panelsQuantity,
    this.location,
    this.quarter,
    this.allotment,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'min': min,
    'likely': likely,
    'max': max,
    'dependsOn': dependsOn,
    'isCompleted': isCompleted,
    'actualDuration': actualDuration,
    if (plantingType != null) 'plantingType': plantingType,
    if (culture != null) 'culture': culture,
    if (plantingQuantity != null) 'plantingQuantity': plantingQuantity,
    if (plantingArea != null) 'plantingArea': plantingArea,
    if (sowingBreed != null) 'sowingBreed': sowingBreed,
    if (sowingQuantityKg != null) 'sowingQuantityKg': sowingQuantityKg,
    if (sowingAreaHa != null) 'sowingAreaHa': sowingAreaHa,
    if (cuttingArea != null) 'cuttingArea': cuttingArea,
    if (cuttingVolume != null) 'cuttingVolume': cuttingVolume,
    if (clearCuttingArea != null) 'clearCuttingArea': clearCuttingArea,
    if (clearCuttingVolume != null) 'clearCuttingVolume': clearCuttingVolume,
    if (clearingArea != null) 'clearingArea': clearingArea,
    if (clearingVolume != null) 'clearingVolume': clearingVolume,
    if (panelsQuantity != null) 'panelsQuantity': panelsQuantity,
    if (location != null) 'location': location,
    if (quarter != null) 'quarter': quarter,
    if (allotment != null) 'allotment': allotment,
  };

  factory SimulationTask.fromMap(Map<dynamic, dynamic> map) => SimulationTask(
    id: map['id'],
    name: map['name'],
    min: (map['min'] ?? 0).toDouble(),
    likely: (map['likely'] ?? 0).toDouble(),
    max: (map['max'] ?? 0).toDouble(),
    dependsOn: List<String>.from(map['dependsOn'] ?? []),
    isCompleted: map['isCompleted'] ?? false,
    actualDuration: (map['actualDuration'] ?? 0).toDouble(),
    plantingType: map['plantingType'],
    culture: map['culture'],
    plantingQuantity: map['plantingQuantity']?.toDouble(),
    plantingArea: map['plantingArea']?.toDouble(),
    sowingBreed: map['sowingBreed'],
    sowingQuantityKg: map['sowingQuantityKg']?.toDouble(),
    sowingAreaHa: map['sowingAreaHa']?.toDouble(),
    cuttingArea: map['cuttingArea']?.toDouble(),
    cuttingVolume: map['cuttingVolume']?.toDouble(),
    clearCuttingArea: map['clearCuttingArea']?.toDouble(),
    clearCuttingVolume: map['clearCuttingVolume']?.toDouble(),
    clearingArea: map['clearingArea']?.toDouble(),
    clearingVolume: map['clearingVolume']?.toDouble(),
    panelsQuantity: map['panelsQuantity']?.toDouble(),
    location: map['location'],
    quarter: map['quarter'],
    allotment: map['allotment'],
  );

  double getSample(Random rnd) {
    if (isCompleted) return actualDuration;
    if (max <= min) return min;
    double r = rnd.nextDouble();
    if (r < (likely - min) / (max - min)) {
      return min + sqrt(r * (max - min) * (likely - min));
    } else {
      return max - sqrt((1 - r) * (max - min) * (max - likely));
    }
  }
}
