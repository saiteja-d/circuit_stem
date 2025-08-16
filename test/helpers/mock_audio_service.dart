import 'package:circuit_stem/services/audio_service.dart';

class MockAudioService implements AudioService {
  @override
  void play(String fileName) {
    // Do nothing in tests
  }
}
