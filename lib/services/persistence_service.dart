import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart'; // For debugPrint

class PersistenceService {
  // Placeholder for secure storage. In a real app, you'd integrate a package
  // like 'flutter_secure_storage' for secureSave and secureLoad.
  Future<void> secureSave(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<String?> secureLoad(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<void> saveGameState(String gameState) async {
    try {
      await secureSave('gameState', gameState);
    } catch (e) {
      debugPrint('Failed to save game state: $e');
    }
  }

  Future<String?> loadGameState() async {
    try {
      return await secureLoad('gameState');
    } catch (e) {
      debugPrint('Failed to load game state: $e');
      return null;
    }
  }
}