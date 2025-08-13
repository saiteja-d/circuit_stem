import 'package:flame_audio/flame_audio.dart';

class AudioService {
  void play(String fileName) {
    FlameAudio.play(fileName);
  }

  void playSuccess() {
    play('success.mp3');
  }

  void playToggle() {
    play('toggle.mp3');
  }
}
