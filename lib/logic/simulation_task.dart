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

  // Поля лесоустройства (используются в UI и для отчетов)
  String plantingType;      // Тип посадки (Сеянцы, саженцы и т.д.)
  String culture;           // Культура (Вяз, Ясень, Тополь и т.д.)
  double? plantingQuantity; // Количество (шт)
  double? plantingArea;     // Площадь (га)
  
  String sowingBreed;       // Порода при посеве
  double? sowingQuantityKg; // Количество семян (кг)
  double? sowingAreaHa;     // Площадь посева (га)
  
  double? cuttingArea;      // Площадь рубки
  double? cuttingVolume;    // Объем рубки (м3)
  
  double? clearCuttingArea;
  double? clearCuttingVolume;
  
  double? clearingArea;     // Очистка
  double? clearingVolume;
  
  int? panelsQuantity;      // Количество аншлагов
  
  String location;          // Местонахождение
  int? quarter;             // Квартал
  int? allotment;           // Выдел

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

  // Фабричный метод для создания объекта из JSON (загрузка из Hive/Сервера)
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

  // Метод для преобразования объекта в JSON (сохранение в Hive/Сервер)
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
