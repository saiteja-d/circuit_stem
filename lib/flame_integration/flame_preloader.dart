
import 'package:flame/flame.dart';
import 'package:flame_audio/flame_audio.dart';
import '../engine/preloader.dart';

class FlamePreloader implements Preloader {
  @override
  Future<void> preloadAssets() async {
    await Flame.images.loadAll([
      'battery.svg',
      'bulb_off.svg',
      'bulb_on.svg',
      'wire_straight.svg',
      'wire_corner.svg',
      'wire_t.svg',
      'switch_open.svg',
      'switch_closed.svg',
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
