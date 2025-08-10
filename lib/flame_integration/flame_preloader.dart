
import 'package:flame/flame.dart';
import 'package:flame_audio/flame_audio.dart';
import '../engine/preloader.dart';

class FlamePreloader implements Preloader {
  @override
  Future<void> preloadAssets() async {
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
}
