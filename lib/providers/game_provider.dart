import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/level_manager.dart';
import '../engine/game_engine_notifier.dart';
import '../models/level_definition.dart';
import '../engine/game_engine_state.dart';

final gameEngineProvider = StateNotifierProvider<GameEngineNotifier, GameEngineState>((ref) {
  final levelManager = ref.watch(levelManagerProvider);
  final currentLevel = levelManager.currentLevel;
  
  return GameEngineNotifier(
    initialLevel: currentLevel,
    onWin: () {
      levelManager.markCurrentLevelComplete();
    },
  );
});
