
import 'component.dart';

/// Represents the definition of a game level.
class LevelDefinition {
  final String id;
  final String title;
  final String author;
  final int version;
  final int rows;
  final int cols;
  final List<Map<String, dynamic>> goals;
  final List<String> hints;
  final List<ComponentModel> initialComponents;

  const LevelDefinition({
    required this.id,
    required this.title,
    required this.author,
    required this.version,
    required this.rows,
    required this.cols,
    required this.goals,
    required this.hints,
    required this.initialComponents,
  });

  /// Creates a [LevelDefinition] from a JSON map.
  factory LevelDefinition.fromJson(Map<String, dynamic> json) {
    final gridSize = json['gridSize'] as Map<String, dynamic>;
    return LevelDefinition(
      id: json['id'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      version: json['version'] as int,
      rows: gridSize['rows'] as int,
      cols: gridSize['cols'] as int,
      goals: List<Map<String, dynamic>>.from(json['goals'] as List),
      hints: List<String>.from(json['hints'] as List),
      initialComponents: (json['components'] as List<dynamic>)
          .map((e) => ComponentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Converts this [LevelDefinition] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'version': version,
      'gridSize': {
        'rows': rows,
        'cols': cols,
      },
      'goals': goals,
      'hints': hints,
      'components': initialComponents.map((e) => e.toJson()).toList(),
    };
  }

  // Convenience getters
  Map<String, int> get gridSize => {'rows': rows, 'cols': cols};
  List<ComponentModel> get components => initialComponents;
}