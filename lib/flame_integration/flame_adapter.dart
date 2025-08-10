import 'package:flame_audio/flame_audio.dart';
import 'flame_preloader.dart';

class FlameAdapter {
  static final FlameAdapter _instance = FlameAdapter._internal();

  factory FlameAdapter() {
    return _instance;
  }

  FlameAdapter._internal();

  Future<void> preloadAssets() {
    final preloader = FlamePreloader();
    return preloader.preloadAssets();
  }

  void playAudio(String fileName) {
    FlameAudio.play(fileName);
  }
}