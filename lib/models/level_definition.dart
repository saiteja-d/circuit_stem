import 'component.dart';
import 'goal.dart';
import 'hint.dart';
import 'blocked_cell.dart';

class LevelDefinition {
  final String id;
  final String title;
  final String author;
  final int version;
  final int rows;
  final int cols;
  final List<BlockedCell> blockedCells;
  final List<ComponentModel> components;
  final List<Goal> goals;
  final List<Hint> hints;

  LevelDefinition({
    required this.id,
    required this.title,
    required this.author,
    required this.version,
    required this.rows,
    required this.cols,
    required this.blockedCells,
    required this.components,
    required this.goals,
    required this.hints,
  });

  factory LevelDefinition.fromJson(Map<String, dynamic> json) {
    return LevelDefinition(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      author: json['author'] as String? ?? '',
      version: json['version'] as int? ?? 1,
      rows: json['rows'] as int,
      cols: json['cols'] as int,
      blockedCells: (json['blockedCells'] as List<dynamic>?)
              ?.map((e) => BlockedCell.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      components: (json['components'] as List<dynamic>)
          .map((e) => ComponentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      goals: (json['goals'] as List<dynamic>)
          .map((e) => Goal.fromJson(e as Map<String, dynamic>))
          .toList(),
      hints: (json['hints'] as List<dynamic>?)
              ?.map((e) => Hint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'version': version,
      'rows': rows,
      'cols': cols,
      'blockedCells': blockedCells.map((b) => b.toJson()).toList(),
      'components': components.map((c) => c.toJson()).toList(),
      'goals': goals.map((g) => g.toJson()).toList(),
      'hints': hints.map((h) => h.toJson()).toList(),
    };
  }
}
