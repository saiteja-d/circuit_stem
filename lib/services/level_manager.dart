import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../common/logger.dart';
import '../models/level_definition.dart';
import '../models/level_metadata.dart';
import 'level_manager_state.dart';

/// Notifier for managing level state, including loading, progress, and persistence.
class LevelManagerNotifier extends StateNotifier<LevelManagerState> {
  final SharedPreferences _sharedPrefs;

  static const String _prefsKeyCompletedLevels = 'completed_levels';

  LevelManagerNotifier(this._sharedPrefs) : super(const LevelManagerState()) {
    _loadManifest();
  }

  /// Loads the level manifest and user progress from storage.
  Future<void> _loadManifest() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final manifestString = await rootBundle.loadString('assets/levels/level_manifest.json');
      final manifestJson = json.decode(manifestString) as Map<String, dynamic>;
      final levelList = manifestJson['levels'] as List<dynamic>;
      final allLevels = levelList.map((e) => LevelMetadata.fromJson(e as Map<String, dynamic>)).toList();

      final completedIds = _sharedPrefs.getStringList(_prefsKeyCompletedLevels)?.toSet() ?? {};

      // The first level is always unlocked.
      if (allLevels.isNotEmpty) {
        allLevels[0] = allLevels[0].copyWith(unlocked: true);
      }

      // A level is unlocked if it's the first one, or if the previous one is complete.
      for (int i = 1; i < allLevels.length; i++) {
        if (completedIds.contains(allLevels[i - 1].id)) {
          allLevels[i] = allLevels[i].copyWith(unlocked: true);
        }
      }

      state = state.copyWith(
        levels: allLevels,
        completedLevelIds: completedIds,
        isLoading: false,
      );
    } catch (e, stackTrace) {
      Logger.log('Failed to load level manifest: $e\n$stackTrace');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load levels. Please restart the app.',
      );
    }
  }

  /// Loads the full definition for a specific level by its index.
  Future<LevelDefinition?> loadLevelByIndex(int index) async {
    if (index < 0 || index >= state.levels.length) return null;

    final levelMeta = state.levels[index];
    if (!levelMeta.unlocked) {
      Logger.log('Attempted to load a locked level: ${levelMeta.id}');
      return null;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final path = 'assets/levels/${levelMeta.id}.json';
      final jsonString = await rootBundle.loadString(path);
      final levelDef = LevelDefinition.fromJson(json.decode(jsonString));
      state = state.copyWith(currentLevelDefinition: levelDef, isLoading: false);
      return levelDef;
    } catch (e, stackTrace) {
      Logger.log('Failed to load level ${levelMeta.id}: $e\n$stackTrace');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load level. Please try again.',
      );
      return null;
    }
  }

  /// Marks the current level as complete and unlocks the next one.
  Future<void> markCurrentLevelComplete() async {
    final currentLevelId = state.currentLevelDefinition?.id;
    if (currentLevelId == null || state.completedLevelIds.contains(currentLevelId)) {
      return;
    }

    final newCompletedIds = Set<String>.from(state.completedLevelIds)..add(currentLevelId);
    await _sharedPrefs.setStringList(_prefsKeyCompletedLevels, newCompletedIds.toList());

    // Recalculate unlocked status for all levels
    final newLevels = state.levels.map((level) => level).toList();
    for (int i = 1; i < newLevels.length; i++) {
      if (newCompletedIds.contains(newLevels[i - 1].id)) {
        newLevels[i] = newLevels[i].copyWith(unlocked: true);
      }
    }

    state = state.copyWith(
      completedLevelIds: newCompletedIds,
      levels: newLevels,
    );
  }
}