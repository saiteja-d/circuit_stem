import 'package:flame_audio/flame_audio.dart';

class SoundService {
  void playSound(String fileName) {
    FlameAudio.play(fileName);
  }
}
