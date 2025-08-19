// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'component.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TerminalSpecImpl _$$TerminalSpecImplFromJson(Map<String, dynamic> json) =>
    _$TerminalSpecImpl(
      cellIndex: (json['cellIndex'] as num).toInt(),
      dir: $enumDecode(_$DirEnumMap, json['dir']),
      label: json['label'] as String?,
      role: json['role'] as String?,
    );

Map<String, dynamic> _$$TerminalSpecImplToJson(_$TerminalSpecImpl instance) =>
    <String, dynamic>{
      'cellIndex': instance.cellIndex,
      'dir': _$DirEnumMap[instance.dir]!,
      'label': instance.label,
      'role': instance.role,
    };

const _$DirEnumMap = {
  Dir.north: 'north',
  Dir.east: 'east',
  Dir.south: 'south',
  Dir.west: 'west',
};
