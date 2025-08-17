import 'package:circuit_stem/engine/animation_scheduler.dart';
import 'package:flutter/material.dart';

class MockAnimationScheduler implements AnimationScheduler {
  final List<AnimationCallback> _callbacks = [];

  @override
  double get bulbIntensity => 1.0; // Fixed value for testing

  @override
  double get wireOffset => 0.0; // Fixed value for testing

  @override
  void addCallback(AnimationCallback callback) {
    _callbacks.add(callback);
  }

  @override
  void dispose() {
    _callbacks.clear();
  }

  @override
  void pause() {}

  @override
  void removeCallback(AnimationCallback callback) {
    _callbacks.remove(callback);
  }

  @override
  void reset() {}

  @override
  void resume() {}

  @override
  void start() {}

  @override
  void stop() {}

  // New method to manually trigger callbacks in tests
  void triggerCallback(double dt) {
    for (final callback in _callbacks) {
      callback(dt);
    }
  }
}
