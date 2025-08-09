import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../models/level_definition.dart';

class LevelLoader {
  static Future<LevelDefinition> loadLevel(String levelId) async {
    try {
      final jsonString = await rootBundle.loadString('assets/levels/$levelId.json');
      final json = jsonDecode(jsonString) as Map<String, dynamic>;

      return LevelDefinition.fromJson(json);
    } catch (e) {
      debugPrint('Failed to load level $levelId: $e');
      // Return a default level if loading fails
      return const LevelDefinition(
        id: 'default',
        title: 'Default Level',
        author: 'System',
        version: 1,
        rows: 3,
        cols: 3,
        goals: [],
        hints: ['Try connecting the battery to the bulb!'],
        initialComponents: [],
      );
    }
  }
}