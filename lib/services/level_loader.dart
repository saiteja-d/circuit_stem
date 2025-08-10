import 'dart:convert';
import '../models/level_definition.dart';

class LevelLoader {
  /// Loads a level from a raw JSON string dynamically.
  static Future<LevelDefinition> loadLevelFromJsonString(String jsonString) async {
    try {
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      return LevelDefinition.fromJson(jsonMap);
    } catch (e) {
      print('LevelLoader: Failed to parse level JSON: $e');
      rethrow;
    }
  }

  /// Loads a level from a pre-parsed JSON map.
  static Future<LevelDefinition> loadLevelFromJsonMap(Map<String, dynamic> jsonMap) async {
    try {
      return LevelDefinition.fromJson(jsonMap);
    } catch (e) {
      print('LevelLoader: Failed to parse level JSON map: $e');
      rethrow;
    }
  }
}
