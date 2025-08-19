import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/level_definition.dart';
import '../models/level_metadata.dart';
import '../engine/render_state.dart';
import '../services/asset_manager.dart';
import '../services/level_manager.dart';
import '../engine/game_engine_notifier.dart';
import '../engine/game_engine_state.dart';
import '../services/level_manager_state.dart';
import '../services/asset_manager_state.dart';

// This file is the single source of truth for all core providers.

// 1. Foundational Service Providers

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences provider was not overridden');
});

final assetManagerProvider = StateNotifierProvider<AssetManagerNotifier, AssetState>((ref) {
  return AssetManagerNotifier();
});

// 2. Core Notifier Providers

final levelManagerProvider = StateNotifierProvider<LevelManagerNotifier, LevelManagerState>((ref) {
  return LevelManagerNotifier(
    ref.watch(sharedPreferencesProvider),
    ref.watch(assetManagerProvider.notifier),
  );
});

final gameEngineProvider = StateNotifierProvider<GameEngineNotifier, GameEngineState>((ref) {
  final currentLevel = ref.watch(currentLevelDefinitionProvider);

  if (currentLevel == null) {
    return GameEngineNotifier.forNoLevel(
      onWin: () {
        ref.read(levelManagerProvider.notifier).markCurrentLevelComplete();
      },
    );
  }

  return GameEngineNotifier(
    initialLevel: currentLevel,
    onWin: () {
      ref.read(levelManagerProvider.notifier).markCurrentLevelComplete();
    },
  );
});

// 3. Granular State Providers

/// Provider for the list of all level metadata.
final levelsProvider = Provider<List<LevelMetadata>>((ref) {
  return ref.watch(levelManagerProvider).levels;
}, dependencies: [levelManagerProvider]);

/// Provider for the set of completed level IDs.
final completedLevelIdsProvider = Provider<Set<String>>((ref) {
  return ref.watch(levelManagerProvider).completedLevelIds;
}, dependencies: [levelManagerProvider]);

/// Provider that returns true if the level manager is busy loading.
final levelIsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(levelManagerProvider).isLoading;
}, dependencies: [levelManagerProvider]);

/// Provider for the currently loaded level definition.
final currentLevelDefinitionProvider = Provider<LevelDefinition?>((ref) {
  return ref.watch(levelManagerProvider).currentLevelDefinition;
}, dependencies: [levelManagerProvider]);

/// Provider for the game's render state.
final renderStateProvider = Provider<RenderState?>((ref) {
  return ref.watch(gameEngineProvider.select((state) => state.renderState));
}, dependencies: [gameEngineProvider]);

/// Provider that returns true if the game has been won.
final isWinProvider = Provider<bool>((ref) {
  return ref.watch(gameEngineProvider.select((state) => state.isWin));
}, dependencies: [gameEngineProvider]);
