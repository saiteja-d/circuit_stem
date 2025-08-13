import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/level_definition.dart';
import '../models/level_metadata.dart';
import '../common/logger.dart';
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
    if (_currentLevelDefinition == null) return;

    final levelId = _currentLevelDefinition!.id;
    if (!_completedLevelIds.contains(levelId)) {
      _completedLevelIds.add(levelId);
      await sharedPrefs.setStringList(_prefsKeyCompletedLevels, _completedLevelIds);

      // Unlock next level if available
      if (_currentIndex < _levels.length - 1) {
        final nextIndex = _currentIndex + 1;
        _levels = [
          ..._levels.sublist(0, nextIndex),
          _levels[nextIndex].copyWith(unlocked: true),
          ..._levels.sublist(nextIndex + 1),
        ];
        await _saveUnlockedLevels();
      }

      notifyListeners();
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
    _isLoading = true;
    _hasError = false;
    _errorMessage = null;
    notifyListeners();
    try {
      final jsonString =
          await rootBundle.loadString('assets/levels/level_manifest.json');
      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
      final lvlList = jsonMap['levels'] as List<dynamic>;
      final tempLevels = lvlList
          .map((e) => LevelMetadata.fromJson(e as Map<String, dynamic>))
          .toList();
      final unlockedIds = sharedPrefs.getStringList(_prefsKeyUnlockedLevels) ?? [];
      _completedLevelIds =
          sharedPrefs.getStringList(_prefsKeyCompletedLevels) ?? [];

      _levels = tempLevels.map((lvl) {
        return lvl.copyWith(unlocked: unlockedIds.contains(lvl.id));
      }).toList();

      final anyUnlocked = _levels.any((lvl) => lvl.unlocked);

      if (!anyUnlocked && _levels.isNotEmpty) {
        _levels = [
          _levels[0].copyWith(unlocked: true),
          ..._levels.sublist(1),
        ];
        await _saveUnlockedLevels();
      }

      _currentIndex = 0;
      await _loadCurrentLevel();
    } catch (e) {
      _levels = [];
      _currentLevelDefinition = null;
      _hasError = true;
      _errorMessage = 'Failed to load levels. Please restart the app.';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadLevelByIndex(int index) async {
    if (index < 0 || index >= _levels.length) return;
    if (!_levels[index].unlocked) return;
    _currentIndex = index;
    await _loadCurrentLevel();
    notifyListeners();
  }

  Future<void> unlockLevel(String levelId) async {
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
    try {
      await sharedPrefs.setStringList(_prefsKeyCompletedLevels, _completedLevelIds);
      await sharedPrefs.setStringList(_prefsKeyUnlockedLevels,
          _levels.where((l) => l.unlocked).map((l) => l.id).toList());
    } catch (e) {
      // Log error if needed
    }
  }

  Future<void> reloadCurrentLevel() async {
    await _loadCurrentLevel();
    notifyListeners();
  }

  Future<void> goToNextLevel() async {
    if (isLastLevel) return;
    final nextIndex = _currentIndex + 1;
    if (nextIndex < _levels.length && _levels[nextIndex].unlocked) {
      _currentIndex = nextIndex;
      await _loadCurrentLevel();
      notifyListeners();
    }
  }

  Future<void> _saveUnlockedLevels() async {
    final unlockedIds =
        _levels.where((lvl) => lvl.unlocked).map((lvl) => lvl.id).toList();
    await sharedPrefs.setStringList(_prefsKeyUnlockedLevels, unlockedIds);
  }

  Future<void> _loadCurrentLevel() async {
    _isLoading = true;
    _hasError = false;
    _errorMessage = null;
    notifyListeners();
    try {
      final path = 'assets/levels/${_levels[_currentIndex].id}.json';
      final jsonString = await rootBundle.loadString(path);
      final jsonMap = json.decode(jsonString);
      _currentLevelDefinition = LevelDefinition.fromJson(jsonMap);
    } catch (e) {
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
