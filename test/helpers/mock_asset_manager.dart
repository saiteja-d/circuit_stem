import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:circuit_stem/services/asset_manager.dart';

class MockAssetManager implements AssetManager {
  final Map<String, String> _files = {};

  void primeFile(String path, String content) {
    _files[path] = content;
  }

  @override
  Future<String> loadString(String path) {
    if (_files.containsKey(path)) {
      return Future.value(_files[path]!);
    }
    return Future.error(Exception('MockAssetManager: File not primed: $path'));
  }

  @override
  void dispose() {}

  @override
  ui.Image? getBestImageForCanvas(String path) => null;

  @override
  ui.Image? getImage(String path) => null;

  @override
  Map<String, int> getStats() => {};

  @override
  ui.Image? getSvgAsImage(String path) => null;

  @override
  String? getSvgString(String path) => _files[path];

  @override
  Widget? getSvgWidget(String path, {double? width, double? height, ColorFilter? colorFilter, BoxFit fit = BoxFit.contain}) => null;

  @override
  Widget? getSvgWidgetColored(String path, Color color, {double? width, double? height}) => null;

  @override
  bool hasAsset(String path) => _files.containsKey(path);

  @override
  Future<void> loadAllAssets() async {}
}