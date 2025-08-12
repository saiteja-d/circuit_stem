import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/level_definition.dart';
import '../common/logger.dart';

/// Holds basic metadata about a level.
class LevelMetadata {
  final String id;
  final String title;
  bool unlocked;

  LevelMetadata({
    required this.id,
    required this.title,
    this.unlocked = false,
  });

  factory LevelMetadata.fromJson(Map<String, dynamic> json) => LevelMetadata(
        id: json['id'] as String,
        title: json['title'] as String,
        unlocked: json['unlocked'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'unlocked': unlocked,
      };
}

/// Manages the game's levels lifecycle, loading from a manifest,
/// tracking current level, progression, and persisting unlock state.
class LevelManager extends ChangeNotifier {
  static const _prefsKeyUnlockedLevels = 'unlockedLevels';
  static const _prefsKeyCompletedLevels = 'completedLevels';

  List<LevelMetadata> _levels = [];
  int _currentIndex = 0;
  LevelDefinition? _currentLevelDefinition;
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;
  List<String> _completedLevelIds = [];

  /// The list of levels with metadata.
  List<LevelMetadata> get levels => List.unmodifiable(_levels);

  /// Current loaded level definition.
  LevelDefinition? get currentLevelDefinition => _currentLevelDefinition;

  /// Currently loaded level ID.
  String get currentLevelId => _levels.isNotEmpty ? _levels[_currentIndex].id : '';

  /// Whether the current level is the last in the list.
  bool get isLastLevel => _currentIndex >= _levels.length - 1;

  /// Whether the manager is currently loading a level.
  bool get isLoading => _isLoading;

  /// Whether there was an error loading levels.
  bool get hasError => _hasError;

  /// The error message if an error occurred.
  String? get errorMessage => _errorMessage;

  /// Whether the current level is unlocked.
  bool get isCurrentLevelUnlocked =>
      _levels.isNotEmpty && _levels[_currentIndex].unlocked;

  /// The list of completed level IDs.
  List<String> get completedLevels => List.unmodifiable(_completedLevelIds);

  /// Checks if a specific level is unlocked.
  bool isLevelUnlocked(String levelId) {
    final level = _levels.firstWhere((lvl) => lvl.id == levelId, orElse: () => LevelMetadata(id: '', title: '', unlocked: false));
    return level.unlocked;
  }

  /// Checks if a specific level is completed.
  bool isLevelCompleted(String levelId) {
    return _completedLevelIds.contains(levelId);
  }

  /// Loads the manifest file and unlocks first level by default.
  Future<void> loadManifest() async {
    Logger.log('LevelManager: loadManifest() started.');
    _isLoading = true;
    _hasError = false;
    _errorMessage = null;
    notifyListeners();

    try {
      Logger.log('LevelManager: Loading manifest from assets...');
      final jsonString = await rootBundle.loadString('assets/levels/manifest.json');
      Logger.log('LevelManager: Manifest string loaded.');
      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
      Logger.log('LevelManager: Manifest JSON decoded.');
      final lvlList = jsonMap['levels'] as List<dynamic>;
      _levels = lvlList
          .map((e) => LevelMetadata.fromJson(e as Map<String, dynamic>))
          .toList();
      Logger.log('LevelManager: Manifest loaded with ${_levels.length} levels.');

      // Load unlock states from prefs
      Logger.log('LevelManager: Loading unlocked levels from SharedPreferences...');
      final prefs = await SharedPreferences.getInstance();
      final unlockedIds = prefs.getStringList(_prefsKeyUnlockedLevels) ?? [];
      _completedLevelIds = prefs.getStringList(_prefsKeyCompletedLevels) ?? [];
      Logger.log('LevelManager: Loaded unlocked levels: $unlockedIds');
      Logger.log('LevelManager: Loaded completed levels: $_completedLevelIds');

      // Mark unlocked based on saved data, unlock first level if none unlocked
      var anyUnlocked = false;
      for (var lvl in _levels) {
        lvl.unlocked = unlockedIds.contains(lvl.id);
        if (lvl.unlocked) anyUnlocked = true;
      }
      if (!anyUnlocked && _levels.isNotEmpty) {
        _levels[0].unlocked = true;
        await _saveUnlockedLevels();
        Logger.log('LevelManager: Unlocked first level by default.');
      }

      _currentIndex = 0;
      Logger.log('LevelManager: Loading current level...');
      await _loadCurrentLevel();
      Logger.log('LevelManager: Current level loaded.');
    } catch (e) {
      Logger.log('Failed to load level manifest: $e');
      _levels = [];
      _currentLevelDefinition = null;
      _hasError = true;
      _errorMessage = 'Failed to load levels. Please restart the app.';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Loads level by index if unlocked.
  Future<void> loadLevelByIndex(int index) async {
    if (index < 0 || index >= _levels.length) return;
    if (!_levels[index].unlocked) {
      Logger.log('Attempted to load locked level: ${_levels[index].id}');
      return;
    }
    _currentIndex = index;
    await _loadCurrentLevel();
    notifyListeners();
  }

  /// Marks the current level as complete, unlocks the next one, and saves progress.
  Future<void> completeCurrentLevel() async {
    if (_currentLevelDefinition == null) return;

    if (!_completedLevelIds.contains(_currentLevelDefinition!.id)) {
      _completedLevelIds.add(_currentLevelDefinition!.id);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_prefsKeyCompletedLevels, _completedLevelIds);
      Logger.log('LevelManager: Marked level ${_currentLevelDefinition!.id} as completed.');
    }

    if (!isLastLevel) {
      final nextIndex = _currentIndex + 1;
      if (nextIndex < _levels.length) {
        _levels[nextIndex].unlocked = true;
        await _saveUnlockedLevels();
        Logger.log('LevelManager: Unlocked level ${nextIndex + 1}.');
      }
    }
    notifyListeners();
  }

  /// Loads the next level if available and unlocked.
  Future<void> goToNextLevel() async {
    if (isLastLevel) return;
    final nextIndex = _currentIndex + 1;
    if (nextIndex < _levels.length && _levels[nextIndex].unlocked) {
      _currentIndex = nextIndex;
      await _loadCurrentLevel();
      notifyListeners();
    }
  }

  /// Reloads the current level definition.
  Future<void> reloadCurrentLevel() async {
    await _loadCurrentLevel();
    notifyListeners();
  }

  /// Unlocks a level by id and persists the unlock state.
  Future<void> unlockLevel(String levelId) async {
    final level = _levels.firstWhere(
      (lvl) => lvl.id == levelId,
      orElse: () => throw Exception('Level $levelId not found'),
    );
    if (!level.unlocked) {
      level.unlocked = true;
      await _saveUnlockedLevels();
      notifyListeners();
    }
  }

  /// Saves the current unlocked levels to SharedPreferences.
  Future<void> _saveUnlockedLevels() async {
    final prefs = await SharedPreferences.getInstance();
    final unlockedIds = _levels.where((lvl) => lvl.unlocked).map((lvl) => lvl.id).toList();
    await prefs.setStringList(_prefsKeyUnlockedLevels, unlockedIds);
    Logger.log('LevelManager: Saved unlocked levels: $unlockedIds');
  }

  Future<void> _loadCurrentLevel() async {
    _isLoading = true;
    _hasError = false;
    _errorMessage = null;
    notifyListeners();

    try {
      final path = 'assets/levels/${_levels[_currentIndex].id}.json';
      Logger.log('LevelManager: Loading level from $path');
      final jsonString = await rootBundle.loadString(path);
      final jsonMap = json.decode(jsonString);
      _currentLevelDefinition = LevelDefinition.fromJson(jsonMap);
      Logger.log('LevelManager: Level loaded successfully.');
    } catch (e) {
      Logger.log('Error loading level: $e');
      _currentLevelDefinition = null;
      _hasError = true;
      _errorMessage = 'Failed to load level. Please try again.';
    }

    _isLoading = false;
    notifyListeners();
  }
}