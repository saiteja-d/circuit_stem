import 'package:stemcir/models/circuit_component.dart';

class GameLevel {
  final int levelNumber;
  final String title;
  final String description;
  final String objective;
  final int gridWidth;
  final int gridHeight;
  final List<CircuitComponent> initialComponents;
  final List<CircuitComponent> availableComponents;
  final List<String> targetComponentIds; // Components that need to be powered
  
  const GameLevel({
    required this.levelNumber,
    required this.title,
    required this.description,
    required this.objective,
    this.gridWidth = 10,
    this.gridHeight = 8,
    required this.initialComponents,
    required this.availableComponents,
    required this.targetComponentIds,
  });

  Map<String, dynamic> toJson() => {
    'levelNumber': levelNumber,
    'title': title,
    'description': description,
    'objective': objective,
    'gridWidth': gridWidth,
    'gridHeight': gridHeight,
    'initialComponents': initialComponents.map((c) => c.toJson()).toList(),
    'availableComponents': availableComponents.map((c) => c.toJson()).toList(),
    'targetComponentIds': targetComponentIds,
  };

  factory GameLevel.fromJson(Map<String, dynamic> json) => GameLevel(
    levelNumber: json['levelNumber'] as int,
    title: json['title'] as String,
    description: json['description'] as String,
    objective: json['objective'] as String,
    gridWidth: json['gridWidth'] as int? ?? 10,
    gridHeight: json['gridHeight'] as int? ?? 8,
    initialComponents: (json['initialComponents'] as List)
        .map((c) => CircuitComponent.fromJson(c as Map<String, dynamic>))
        .toList(),
    availableComponents: (json['availableComponents'] as List)
        .map((c) => CircuitComponent.fromJson(c as Map<String, dynamic>))
        .toList(),
    targetComponentIds: (json['targetComponentIds'] as List).cast<String>(),
  );
}