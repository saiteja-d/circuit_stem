import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flame/flame.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'services/asset_manager.dart';
import 'common/logger.dart';
import 'core/providers.dart';

void main() async {
  Logger.log('main() called');
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  await Flame.device.setLandscape();

  // --- Service Initialization ---
  Logger.log('Initializing services...');
  FlameAudio.audioCache.prefix = '';

  // Initialize services that need to be available synchronously.
  final prefs = await SharedPreferences.getInstance();
  final assetManager = AssetManager();
  await assetManager.loadAllAssets();

  Logger.log('Base services initialized.');

  runApp(
    ProviderScope(
      overrides: [
        // Override the foundational providers with the initialized service instances.
        // Notifiers that depend on these will automatically use the correct instance.
        sharedPreferencesProvider.overrideWithValue(prefs),
        assetManagerProvider.overrideWithValue(assetManager),
      ],
      child: const App(),
    ),
  );
  Logger.log('runApp() called');
}