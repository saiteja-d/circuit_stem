import 'package:flutter/material.dart';
import 'package:flame/flame.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'services/asset_manager.dart';
import 'common/logger.dart';
import 'services/level_manager.dart' hide levelManagerProvider;
import 'core/providers.dart';
import 'ui/widgets/debug_overlay.dart';

void main() async {
  Logger.log('main() called');
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  await Flame.device.setLandscape();

  Logger.log('Asset loading started...');
  final assetManager = AssetManager();
  await assetManager.loadAllAssets();
  Logger.log('Asset loading finished.');

  Logger.log('Creating SharedPreferences instance...');
  final prefs = await SharedPreferences.getInstance();

  Logger.log('Creating LevelManager...');
  final levelManager = LevelManager(assetManager, prefs);
  await levelManager.loadManifest();
  Logger.log('LevelManager created and manifest loaded.');

  runApp(
    ProviderScope(
      overrides: [
        assetManagerProvider.overrideWithValue(assetManager),
        levelManagerProvider.overrideWithValue(levelManager),
        debugOverlayControllerProvider.overrideWithValue(DebugOverlayController()),
      ],
      child: const App(),
    ),
  );
  Logger.log('runApp() called');
}