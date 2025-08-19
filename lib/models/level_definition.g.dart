// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'level_definition.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LevelDefinitionImpl _$$LevelDefinitionImplFromJson(
        Map<String, dynamic> json) =>
    _$LevelDefinitionImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      levelNumber: (json['levelNumber'] as num).toInt(),
      author: json['author'] as String,
      version: (json['version'] as num).toInt(),
      rows: (json['rows'] as num).toInt(),
      cols: (json['cols'] as num).toInt(),
      blockedCells: (json['blockedCells'] as List<dynamic>)
          .map((e) => Position.fromJson(e as Map<String, dynamic>))
          .toList(),
      initialComponents: (json['initialComponents'] as List<dynamic>)
          .map((e) => ComponentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      paletteComponents: (json['paletteComponents'] as List<dynamic>)
          .map((e) => ComponentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      goals: (json['goals'] as List<dynamic>)
          .map((e) => Goal.fromJson(e as Map<String, dynamic>))
          .toList(),
      hints: (json['hints'] as List<dynamic>)
          .map((e) => Hint.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$LevelDefinitionImplToJson(
        _$LevelDefinitionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'levelNumber': instance.levelNumber,
      'author': instance.author,
      'version': instance.version,
      'rows': instance.rows,
      'cols': instance.cols,
      'blockedCells': instance.blockedCells,
      'initialComponents': instance.initialComponents,
      'paletteComponents': instance.paletteComponents,
      'goals': instance.goals,
      'hints': instance.hints,
    };
