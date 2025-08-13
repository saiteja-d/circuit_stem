import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../common/logger.dart';
import '../models/level_definition.dart';
import '../models/level_metadata.dart';

import 'asset_manager.dart';

class LevelManager extends ChangeNotifier {
  final AssetManager assetManager;
  final SharedPreferences sharedPrefs;
  List<LevelMetadata> _levels = [];
  int _currentIndex = 0;
  LevelDefinition? _currentLevelDefinition;
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;
  List<String> _completedLevelIds = [];
  static const String _prefsKeyUnlockedLevels = 'unlocked_levels';
  static const String _prefsKeyCompletedLevels = 'completed_levels';

  LevelDefinition get currentLevel {
    if (_currentLevelDefinition == null) {
      throw StateError('Current level not loaded');
    }
    return _currentLevelDefinition!;
  }

  List<String> get completedLevels => List.unmodifiable(_completedLevelIds);

  Future<void> markCurrentLevelComplete() async {
    Logger.log('LevelManager: Marking current level complete...');
    if (_currentLevelDefinition == null) {
      Logger.log('LevelManager: No current level definition, cannot mark complete.');
      return;
    }

    final levelId = _currentLevelDefinition!.id;
    if (!_completedLevelIds.contains(levelId)) {
      Logger.log('LevelManager: Marking level $levelId as complete.');
      _completedLevelIds.add(levelId);
      await sharedPrefs.setStringList(_prefsKeyCompletedLevels, _completedLevelIds);
      Logger.log('LevelManager: Completed levels saved to shared preferences.');

      // Unlock next level if available
      if (_currentIndex < _levels.length - 1) {
        final nextIndex = _currentIndex + 1;
        Logger.log('LevelManager: Unlocking next level (index $nextIndex).');
        _levels = [
          ..._levels.sublist(0, nextIndex),
          _levels[nextIndex].copyWith(unlocked: true),
          ..._levels.sublist(nextIndex + 1),
        ];
        await _saveUnlockedLevels();
      }

      notifyListeners();
    } else {
      Logger.log('LevelManager: Level $levelId already marked as complete.');
    }
  }

  LevelManager(this.assetManager, this.sharedPrefs);

  List<LevelMetadata> get levels => List.unmodifiable(_levels);
  int get currentIndex => _currentIndex;
  LevelDefinition? get currentLevelDefinition => _currentLevelDefinition;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String? get errorMessage => _errorMessage;
  List<String> get completedLevelIds => List.unmodifiable(_completedLevelIds);
  String get currentLevelId => _levels.isNotEmpty ? _levels[_currentIndex].id : '';
  bool get isLastLevel => _currentIndex >= _levels.length - 1;
  bool get isCurrentLevelUnlocked =>
      _levels.isNotEmpty && _levels[_currentIndex].unlocked;

  Future<void> loadManifest() async {
    Logger.log('LevelManager: Loading manifest...');
    _isLoading = true;
    _hasError = false;
    _errorMessage = null;
    notifyListeners();
    try {
      final jsonString =
          await rootBundle.loadString('assets/levels/level_manifest.json');
      Logger.log('LevelManager: Manifest JSON loaded.');
      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
      final lvlList = jsonMap['levels'] as List<dynamic>;
      final tempLevels = lvlList
          .map((e) => LevelMetadata.fromJson(e as Map<String, dynamic>))
          .toList();
      Logger.log('LevelManager: ${tempLevels.length} levels parsed from manifest.');
      final unlockedIds = sharedPrefs.getStringList(_prefsKeyUnlockedLevels) ?? [];
      _completedLevelIds =
          sharedPrefs.getStringList(_prefsKeyCompletedLevels) ?? [];
      Logger.log('LevelManager: Loaded ${unlockedIds.length} unlocked levels and ${_completedLevelIds.length} completed levels from shared preferences.');

      _levels = tempLevels.map((lvl) {
        return lvl.copyWith(unlocked: unlockedIds.contains(lvl.id));
      }).toList();

      final anyUnlocked = _levels.any((lvl) => lvl.unlocked);

      if (!anyUnlocked && _levels.isNotEmpty) {
        Logger.log('LevelManager: No levels unlocked, unlocking the first level.');
        _levels = [
          _levels[0].copyWith(unlocked: true),
          ..._levels.sublist(1),
        ];
        await _saveUnlockedLevels();
      }

      _currentIndex = 0;
      await _loadCurrentLevel();
    } catch (e) {
      Logger.log('LevelManager: Error loading manifest: $e');
      _levels = [];
      _currentLevelDefinition = null;
      _hasError = true;
      _errorMessage = 'Failed to load levels. Please restart the app.';
    }
    _isLoading = false;
    notifyListeners();
    Logger.log('LevelManager: Manifest loading complete.');
  }

  Future<void> loadLevelByIndex(int index) async {
    Logger.log('LevelManager: Loading level by index: $index');
    if (index < 0 || index >= _levels.length) {
      Logger.log('LevelManager: Index out of bounds.');
      return;
    }
    if (!_levels[index].unlocked) {
      Logger.log('LevelManager: Level at index $index is locked.');
      return;
    }
    _currentIndex = index;
    await _loadCurrentLevel();
    notifyListeners();
  }

  Future<void> unlockLevel(String levelId) async {
    Logger.log('LevelManager: Unlocking level: $levelId');
    final levelIndex = _levels.indexWhere((lvl) => lvl.id == levelId);
    if (levelIndex != -1 && !_levels[levelIndex].unlocked) {
      _levels = [
        ..._levels.sublist(0, levelIndex),
        _levels[levelIndex].copyWith(unlocked: true),
        ..._levels.sublist(levelIndex + 1),
      ];
      await _saveUnlockedLevels();
      notifyListeners();
    }
  }

  Future<void> saveCompletedLevels() async {
    Logger.log('LevelManager: Saving completed levels...');
    try {
      await sharedPrefs.setStringList(_prefsKeyCompletedLevels, _completedLevelIds);
      await sharedPrefs.setStringList(_prefsKeyUnlockedLevels,
          _levels.where((l) => l.unlocked).map((l) => l.id).toList());
      Logger.log('LevelManager: Completed levels saved.');
    } catch (e) {
      Logger.log('LevelManager: Error saving completed levels: $e');
    }
  }

  Future<void> reloadCurrentLevel() async {
    Logger.log('LevelManager: Reloading current level...');
    await _loadCurrentLevel();
    notifyListeners();
  }

  Future<void> goToNextLevel() async {
    Logger.log('LevelManager: Going to next level...');
    if (isLastLevel) {
      Logger.log('LevelManager: Already on the last level.');
      return;
    }
    final nextIndex = _currentIndex + 1;
    if (nextIndex < _levels.length && _levels[nextIndex].unlocked) {
      _currentIndex = nextIndex;
      await _loadCurrentLevel();
      notifyListeners();
    } else {
      Logger.log('LevelManager: Next level is locked or does not exist.');
    }
  }

  Future<void> _saveUnlockedLevels() async {
    final unlockedIds =
        _levels.where((lvl) => lvl.unlocked).map((lvl) => lvl.id).toList();
    await sharedPrefs.setStringList(_prefsKeyUnlockedLevels, unlockedIds);
    Logger.log('LevelManager: Saved unlocked levels: $unlockedIds');
  }

  Future<void> _loadCurrentLevel() async {
    Logger.log('LevelManager: Loading current level (index: $_currentIndex)...');
    _isLoading = true;
    _hasError = false;
    _errorMessage = null;
    notifyListeners();
    try {
      final path = 'assets/levels/${_levels[_currentIndex].id}.json';
      Logger.log('LevelManager: Current level path: $path');
      final jsonString = await rootBundle.loadString(path);
      final jsonMap = json.decode(jsonString);
      _currentLevelDefinition = LevelDefinition.fromJson(jsonMap);
      Logger.log('LevelManager: Current level loaded successfully.');
    } catch (e) {
      Logger.log('LevelManager: Error loading current level: $e');
      _currentLevelDefinition = null;
      _hasError = true;
      _errorMessage = 'Failed to load level. Please try again.';
    }
    _isLoading = false;
    notifyListeners();
  }

  bool isLevelUnlocked(String levelId) {
    final level = _levels.firstWhere((lvl) => lvl.id == levelId,
        orElse: () => const LevelMetadata(
            id: '', title: '', description: 'Level not found', levelNumber: 0));
    return level.unlocked;
  }

  bool isLevelCompleted(String levelId) {
    return _completedLevelIds.contains(levelId);
  }
}
