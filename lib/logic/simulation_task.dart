import 'dart:math';

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

  double getSample(Random rnd) {
    final u = rnd.nextDouble();
    final f = (likely - min) / (max - min);

    if (u <= f) {
      return min + sqrt(u * (max - min) * (likely - min));
    } else {
      return max - sqrt((1 - u) * (max - min) * (max - likely));
    }
  }

  factory SimulationTask.fromJson(Map<String, dynamic> json) {
    return SimulationTask(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      min: (json['min'] as num?)?.toDouble() ?? 1.0,
      likely: (json['likely'] as num?)?.toDouble() ?? 2.0,
      max: (json['max'] as num?)?.toDouble() ?? 3.0,
      dependsOn: json['dependsOn'] is List
          ? (json['dependsOn'] as List)
              .map((e) => int.tryParse(e.toString()))
              .whereType<int>()
              .toList()
          : [],
      isCompleted: json['isCompleted'] == true,
      actualDuration: (json['actualDuration'] as num?)?.toDouble(),
      actualEndDate: json['actualEndDate'] != null
          ? DateTime.tryParse(json['actualEndDate'])
          : null,
      plantingType: json['plantingType']?.toString() ?? 'Сеянцы',
      culture: json['culture']?.toString() ?? 'Вяз',
      plantingQuantity: (json['plantingQuantity'] as num?)?.toDouble(),
      plantingArea: (json['plantingArea'] as num?)?.toDouble(),
      sowingBreed: json['sowingBreed']?.toString() ?? '',
      sowingQuantityKg: (json['sowingQuantityKg'] as num?)?.toDouble(),
      sowingAreaHa: (json['sowingAreaHa'] as num?)?.toDouble(),
      cuttingArea: (json['cuttingArea'] as num?)?.toDouble(),
      cuttingVolume: (json['cuttingVolume'] as num?)?.toDouble(),
      clearCuttingArea: (json['clearCuttingArea'] as num?)?.toDouble(),
      clearCuttingVolume: (json['clearCuttingVolume'] as num?)?.toDouble(),
      clearingArea: (json['clearingArea'] as num?)?.toDouble(),
      clearingVolume: (json['clearingVolume'] as num?)?.toDouble(),
      panelsQuantity: json['panelsQuantity'] is int
          ? json['panelsQuantity']
          : int.tryParse(json['panelsQuantity']?.toString() ?? ''),
      location: json['location']?.toString() ?? '',
      quarter: json['quarter'] is int
          ? json['quarter']
          : int.tryParse(json['quarter']?.toString() ?? ''),
      allotment: json['allotment'] is int
          ? json['allotment']
          : int.tryParse(json['allotment']?.toString() ?? ''),
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
