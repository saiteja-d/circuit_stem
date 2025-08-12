import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../models/level_definition.dart';
import '../models/grid.dart';
import 'render_state.dart';

part 'game_engine_state.freezed.dart';

@freezed
class GameEngineState with _$GameEngineState {
  const factory GameEngineState({
    required Grid grid,
    required bool isPaused,
    required bool isWin,
    LevelDefinition? currentLevel,
    String? draggedComponentId,
    Offset? dragPosition,
    @Default(false) bool isShortCircuit,
    RenderState? renderState,
  }) = _GameEngineState;

  factory GameEngineState.initial(LevelDefinition? level) => GameEngineState(
    grid: Grid(rows: level?.rows ?? 0, cols: level?.cols ?? 0), // Provide default grid if level is null
    isPaused: false,
    isWin: false,
    currentLevel: level,
  );
}