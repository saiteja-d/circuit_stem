import 'package:flame/flame.dart'; // Changed from game.dart
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart'; // For debugPrint

class AssetManager {
  static final AssetManager _instance = AssetManager._internal();
  final Map<String, dynamic> _cache = {};

  factory AssetManager() {
    return _instance;
  }

  AssetManager._internal();

  static Future<void> loadAllAssets() async {
    await Flame.images.loadAll([
      'battery.png',
      'bulb_off.png',
      'bulb_on.png',
      'wire_straight.png',
      'wire_corner.png',
      'wire_t.png',
      'switch_open.png',
      'switch_closed.png',
      'grid_bg_level1.png',
    ]);

    await FlameAudio.audioCache.loadAll([
      'place.wav',
      'toggle.wav',
      'success.wav',
      'short_warning.wav',
    ]);
  }

  Future<dynamic> loadAsset(String path) async {
    if (_cache.containsKey(path)) {
      return _cache[path];
    }
    try {
      // Assuming 'load' here refers to Flame.images.load for image assets.
      // For audio, you would use FlameAudio.audioCache.load.
      // A more robust solution would differentiate asset types.
      final asset = await Flame.images.load(path);
      _cache[path] = asset;
      return asset;
    } catch (e) {
      debugPrint('Failed to load asset: $e');
      rethrow; // Handle error appropriately in your app
    }
  }
}
