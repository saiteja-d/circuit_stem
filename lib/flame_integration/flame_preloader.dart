
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';

import '../common/asset_manager.dart';
import '../engine/preloader.dart';

class FlamePreloader implements Preloader {
  final AssetManager _assetManager;

  FlamePreloader(this._assetManager);

  @override
  Future<void> preloadAssets() async {
    final imageAssets = [
      'images/battery.svg',
      'images/bulb_off.svg',
      'images/bulb_on.svg',
      'images/wire_straight.svg',
      'images/wire_corner.svg',
      'images/wire_t.svg',
      'images/switch_open.svg',
      'images/switch_closed.svg',
      'images/grid_bg_level1.png',
    ];

    for (final asset in imageAssets) {
      try {
        await _assetManager.getImage(asset);
        debugPrint('Successfully preloaded: $asset');
      } catch (e) {
        debugPrint('Failed to preload asset "$asset": $e');
      }
    }

    await FlameAudio.audioCache.loadAll([
      'audio/place.wav',
      'audio/toggle.wav',
      'audio/success.wav',
      'audio/short_warning.wav',
    ]);
  }
}
