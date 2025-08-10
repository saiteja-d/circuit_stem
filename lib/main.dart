
import 'package:flutter/material.dart';
import 'package:flame/flame.dart';
import 'app.dart';
import 'common/asset_manager.dart';
import 'flame_integration/flame_adapter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  await Flame.device.setLandscape();

  final assetManager = AssetManager();
  assetManager.setPreloader(FlameAdapter());
  await assetManager.loadAllAssets();

  runApp(const App());
}
