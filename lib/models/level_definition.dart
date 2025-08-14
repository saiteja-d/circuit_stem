import 'package:freezed_annotation/freezed_annotation.dart';
import 'component.dart';
import 'goal.dart';
import 'hint.dart';
import 'position.dart';

part 'level_definition.freezed.dart';
part 'level_definition.g.dart';

@freezed
class LevelDefinition with _$LevelDefinition {
  const factory LevelDefinition({
    required String id,
    required String title,
    required String description,
    required int levelNumber,
    required String author,
    required int version,
    required int rows,
    required int cols,
    required List<Position> blockedCells,
    required List<ComponentModel> components,
    required List<Goal> goals,
    required List<Hint> hints,
  }) = _LevelDefinition;

  factory LevelDefinition.fromJson(Map<String, dynamic> json) => _$LevelDefinitionFromJson(json);
}