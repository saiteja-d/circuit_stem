import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/asset_manager.dart';
import '../services/level_manager.dart';
import '../engine/game_engine_notifier.dart';
import '../engine/game_engine_state.dart';
import '../ui/controllers/debug_overlay_controller.dart';

// This file is the single source of truth for all core providers.

// 1. Foundational Service Providers
// These are designed to be overridden in main.dart with a concrete, initialized instance.

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences provider was not overridden');
});

final assetManagerProvider = Provider<AssetManager>((ref) {
  throw UnimplementedError('AssetManager provider was not overridden');
});

// 2. Dependent Service Providers

final levelManagerProvider = ChangeNotifierProvider<LevelManager>((ref) {
  throw UnimplementedError('LevelManager provider was not overridden');
});

final debugOverlayControllerProvider = ChangeNotifierProvider<DebugOverlayController>((ref) {
  throw UnimplementedError('DebugOverlayController provider was not overridden');
});

// 3. Game State Provider

final gameEngineProvider = StateNotifierProvider<GameEngineNotifier, GameEngineState>((ref) {
  final levelManager = ref.watch(levelManagerProvider);
  final currentLevel = levelManager.currentLevel;

  // The GameEngineNotifier can be created even without a level.
  // It will be in an idle state until a level is loaded and provided.
  return GameEngineNotifier(
    initialLevel: currentLevel,
    onWin: () {
      levelManager.markCurrentLevelComplete();
    },
  );
});