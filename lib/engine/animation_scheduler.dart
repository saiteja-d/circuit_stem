import 'dart:math' as math;

class AnimationScheduler {
  double _elapsedTime = 0.0;

  double get bulbIntensity {
    // Sinusoidal pulse between 0.9 and 1.2
    return 0.9 + 0.15 * (1 + math.sin(_elapsedTime * math.pi));
  }

  double get wireOffset {
    // Linear progression from 0.0 to 1.0, then repeats
    return (_elapsedTime / 2.0) % 1.0; // Assuming 2 seconds for one cycle
  }

  void tick(double dt) {
    _elapsedTime += dt;
  }

  void reset() {
    _elapsedTime = 0.0;
  }
}