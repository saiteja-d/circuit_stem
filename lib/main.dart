
import 'package:flutter/material.dart';
import 'package:flame/flame.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'common/asset_manager.dart';
import 'flame_integration/flame_preloader.dart';
import 'common/logger.dart';
import 'services/level_manager.dart';

void main() async {
  Logger.log('main() called');
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  await Flame.device.setLandscape();

  final assetManager = AssetManager();
  assetManager.setPreloader(FlamePreloader(assetManager));
  Logger.log('Asset loading started...');
  await assetManager.loadAllAssets();
  Logger.log('Asset loading finished.');

  Logger.log('Creating LevelManager...');
  final levelManager = LevelManager();
  await levelManager.loadManifest();
  Logger.log('LevelManager created and manifest loaded.');

  runApp(ChangeNotifierProvider.value(
    value: levelManager,
    child: const App(),
  ));
  Logger.log('runApp() called');
}
