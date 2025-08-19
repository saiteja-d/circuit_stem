import 'dart:ui' as ui;

import 'package:circuit_stem/services/asset_manager.dart';
import 'package:circuit_stem/services/asset_manager_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MockAssetManager extends StateNotifier<AssetState> implements AssetManagerNotifier {
  final Map<String, String> _files = {};

  MockAssetManager(AssetState state) : super(state);

  void primeFile(String path, String content) {
    _files[path] = content;
  }

  @override
  Future<void> loadAllAssets() async {
    // No-op for mock.
  }

  @override
  void setSvgImages(Map<String, ui.Image> images) {
    state = state.copyWith(svgImageCache: images);
  }

  @override
  Future<String> loadString(String path) {
    if (_files.containsKey(path)) {
      return Future.value(_files[path]!);
    }
    return Future.error(Exception('MockAssetManager: File not primed: $path'));
  }

  @override
  ui.Image? getImage(String path) => state.imageCache[path];

  @override
  ui.Image? getSvgAsImage(String path) => state.svgImageCache[path];

  @override
  bool hasAsset(String path) {
    return state.imageCache.containsKey(path) ||
        state.svgImageCache.containsKey(path) ||
        _files.containsKey(path);
  }

  @override
  ui.Image? getBestImageForCanvas(String path) {
    return state.svgImageCache[path] ?? state.imageCache[path];
  }

  @override
  Map<String, int> getStats() {
    return {
      'regular_images': state.imageCache.length,
      'svg_images': state.svgImageCache.length,
      'total_assets': state.imageCache.length + state.svgImageCache.length + _files.length,
    };
  }
}
