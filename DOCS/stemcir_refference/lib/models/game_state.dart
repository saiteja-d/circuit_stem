import 'package:stemcir/models/circuit_component.dart';
import 'package:stemcir/models/game_level.dart';

class GameState {
  final GameLevel level;
  final List<CircuitComponent> placedComponents;
  final bool isLevelComplete;
  final bool hasShortCircuit;
  final bool isPaused;
  final int currentScore;
  final DateTime? startTime;
  
  const GameState({
    required this.level,
    required this.placedComponents,
    this.isLevelComplete = false,
    this.hasShortCircuit = false,
    this.isPaused = false,
    this.currentScore = 0,
    this.startTime,
  });

  GameState copyWith({
    GameLevel? level,
    List<CircuitComponent>? placedComponents,
    bool? isLevelComplete,
    bool? hasShortCircuit,
    bool? isPaused,
    int? currentScore,
    DateTime? startTime,
  }) => GameState(
    level: level ?? this.level,
    placedComponents: placedComponents ?? this.placedComponents,
    isLevelComplete: isLevelComplete ?? this.isLevelComplete,
    hasShortCircuit: hasShortCircuit ?? this.hasShortCircuit,
    isPaused: isPaused ?? this.isPaused,
    currentScore: currentScore ?? this.currentScore,
    startTime: startTime ?? this.startTime,
  );
}