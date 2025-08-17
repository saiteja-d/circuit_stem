import 'dart:ui' as ui;
import 'package:circuit_stem/services/asset_manager.dart';
import 'package:flutter/material.dart';
import 'package:widgets_to_image/widgets_to_image.dart';

class MockAssetManager implements AssetManager {
  final Map<String, ui.Image> _imageCache = {};
  final Map<String, ui.Image> _svgImageCache = {};
  final Map<String, String> _files = {};

  // Helper for tests to prime the text file cache
  void primeFile(String path, String content) {
    _files[path] = content;
  }

  // Not part of the interface, but needed to satisfy the implementation.
  @override
  final WidgetsToImageController _widgetsToImageController = WidgetsToImageController();

  @override
  Future<void> loadAllAssets() async {
    // No-op for mock.
  }

  @override
  void setSvgImages(Map<String, ui.Image> images) {
    _svgImageCache.addAll(images);
  }

  @override
  Future<String> loadString(String path) {
    if (_files.containsKey(path)) {
      return Future.value(_files[path]!);
    }
    return Future.error(Exception('MockAssetManager: File not primed: $path'));
  }

  @override
  ui.Image? getImage(String path) => _imageCache[path];

  @override
  ui.Image? getSvgAsImage(String path) => _svgImageCache[path];

  @override
  bool hasAsset(String path) {
    return _imageCache.containsKey(path) || _svgImageCache.containsKey(path) || _files.containsKey(path);
  }

  @override
  ui.Image? getBestImageForCanvas(String path) {
    return _svgImageCache[path] ?? _imageCache[path];
  }

  @override
  Map<String, int> getStats() {
    return {
      'regular_images': _imageCache.length,
      'svg_images': _svgImageCache.length,
      'total_assets': _imageCache.length + _svgImageCache.length + _files.length,
    };
  }

  @override
  void dispose() {
    _imageCache.clear();
    _svgImageCache.clear();
    _files.clear();
  }
}