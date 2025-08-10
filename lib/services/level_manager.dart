// lib/services/level_manager.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/level_definition.dart';

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

  List<LevelMetadata> _levels = [];
  int _currentIndex = 0;
  LevelDefinition? _currentLevelDefinition;
  bool _isLoading = false;

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

  /// Whether the current level is unlocked.
  bool get isCurrentLevelUnlocked =>
      _levels.isNotEmpty && _levels[_currentIndex].unlocked;

  /// Loads the manifest file and unlocks first level by default.
  Future<void> loadManifest() async {
    _isLoading = true;
    notifyListeners();

    try {
      final jsonString = await rootBundle.loadString('assets/levels/manifest.json');
      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
      final lvlList = jsonMap['levels'] as List<dynamic>;
      _levels = lvlList
          .map((e) => LevelMetadata.fromJson(e as Map<String, dynamic>))
          .toList();

      // Load unlock states from prefs
      final prefs = await SharedPreferences.getInstance();
      final unlockedIds = prefs.getStringList(_prefsKeyUnlockedLevels) ?? [];

      // Mark unlocked based on saved data, unlock first level if none unlocked
      var anyUnlocked = false;
      for (var lvl in _levels) {
        lvl.unlocked = unlockedIds.contains(lvl.id);
        if (lvl.unlocked) anyUnlocked = true;
      }
      if (!anyUnlocked && _levels.isNotEmpty) {
        _levels[0].unlocked = true;
        await _saveUnlockedLevels();
      }

      _currentIndex = 0;
      await _loadCurrentLevel();
    } catch (e) {
      debugPrint('Failed to load level manifest: $e');
      _levels = [];
      _currentLevelDefinition = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Loads level by index if unlocked.
  Future<void> loadLevelByIndex(int index) async {
    if (index < 0 || index >= _levels.length) return;
    if (!_levels[index].unlocked) {
      debugPrint('Attempted to load locked level: ${_levels[index].id}');
      return;
    }
    _currentIndex = index;
    await _loadCurrentLevel();
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
  }

  Future<void> _loadCurrentLevel() async {
    _isLoading = true;
    notifyListeners();

    try {
      final path = 'assets/levels/${_levels[_currentIndex].id}.json';
      final jsonString = await rootBundle.loadString(path);
      final jsonMap = json.decode(jsonString);
      _currentLevelDefinition = LevelDefinition.fromJson(jsonMap);
    } catch (e) {
      debugPrint('Error loading level: $e');
      _currentLevelDefinition = null;
    }

    _isLoading = false;
    notifyListeners();
  }
}
