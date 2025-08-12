import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'level_goal.freezed.dart';

@freezed
class LevelGoal with _$LevelGoal {
  const factory LevelGoal({
    required String type,
    int? r,
    int? c,
  }) = _LevelGoal;
}
