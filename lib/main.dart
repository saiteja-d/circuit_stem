import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flame/flame.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'services/asset_manager.dart';
import 'common/logger.dart';
import 'services/level_manager.dart';
import 'core/providers.dart';
import 'ui/controllers/debug_overlay_controller.dart';

void main() async {
  Logger.log('main() called');
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  await Flame.device.setLandscape();

  // --- Service Initialization ---
  Logger.log('Initializing services...');
  FlameAudio.audioCache.prefix = '';

  final prefs = await SharedPreferences.getInstance();
  final assetManager = AssetManager();
  await assetManager.loadAllAssets();
  final levelManager = LevelManager(assetManager, prefs);
  await levelManager.loadManifest();
  final debugController = DebugOverlayController();

  Logger.log('All services initialized.');

  runApp(
    ProviderScope(
      overrides: [
        // Override the providers with the initialized service instances.
        sharedPreferencesProvider.overrideWith((ref) => prefs),
        assetManagerProvider.overrideWith((ref) => assetManager),
        levelManagerProvider.overrideWith((ref) => levelManager),
        debugOverlayControllerProvider.overrideWith((ref) => debugController),
      ],
      child: const App(),
    ),
  );
  Logger.log('runApp() called');
}
