import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../models/level_definition.dart';

class LevelLoader {
  static Future<LevelDefinition> loadLevel(String levelId) async {
    try {
      // For now, return a hardcoded level since assets might not exist
      return LevelDefinition(
        id: levelId,
        title: 'Basic Circuit - $levelId',
        author: 'Circuit Kids',
        version: 1,
        rows: 5,
        cols: 5,
        goals: [
          {
            'type': 'power_bulb',
            'r': 2,
            'c': 4,
          }
        ],
        hints: ['Connect the battery to the bulb using wires!'],
        initialComponents: [
          {
            'id': 'battery1',
            'type': 'battery',
            'r': 2,
            'c': 0,
            'rotation': 0,
            'isDraggable': false,
            'state': {}
          },
          {
            'id': 'bulb1',
            'type': 'bulb',
            'r': 2,
            'c': 4,
            'rotation': 0,
            'isDraggable': false,
            'state': {}
          },
          {
            'id': 'wire1',
            'type': 'wireStraight',
            'r': 2,
            'c': 1,
            'rotation': 90,
            'isDraggable': true,
            'state': {}
          },
          {
            'id': 'wire2',
            'type': 'wireStraight',
            'r': 2,
            'c': 2,
            'rotation': 90,
            'isDraggable': true,
            'state': {}
          },
          {
            'id': 'wire3',
            'type': 'wireStraight',
            'r': 2,
            'c': 3,
            'rotation': 90,
            'isDraggable': true,
            'state': {}
          },
        ],
      );
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