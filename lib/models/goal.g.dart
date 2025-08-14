// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GoalImpl _$$GoalImplFromJson(Map<String, dynamic> json) => _$GoalImpl(
      type: json['type'] as String,
      r: (json['r'] as num?)?.toInt(),
      c: (json['c'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$GoalImplToJson(_$GoalImpl instance) =>
    <String, dynamic>{
      'type': instance.type,
      'r': instance.r,
      'c': instance.c,
    };
