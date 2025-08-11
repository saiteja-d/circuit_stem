import 'package:flame_audio/flame_audio.dart';
import '../common/asset_manager.dart';
import 'flame_preloader.dart';

class FlameAdapter {
  final AssetManager _assetManager;

  FlameAdapter(this._assetManager);

  Future<void> preloadAssets() {
    final preloader = FlamePreloader(_assetManager);
    return preloader.preloadAssets();
  }

  void playAudio(String fileName) {
    FlameAudio.play(fileName);
  }
}
