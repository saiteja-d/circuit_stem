import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../models/level_definition.dart';

class LevelLoader {
  static Future<LevelDefinition> loadLevel(String levelId) async {
    try {
      final jsonString = await rootBundle.loadString('assets/levels/$levelId.json');
      final json = jsonDecode(jsonString) as Map<String, dynamic>;

      return LevelDefinition.fromJson(json); // Use fromJson constructor
    } catch (e) {
      debugPrint('Failed to load level $levelId: $e');
      rethrow;
    }
  }
}
