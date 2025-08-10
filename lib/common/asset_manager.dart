
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../engine/preloader.dart';

class AssetManager {
  static final AssetManager _instance = AssetManager._internal();
  final Map<String, ui.Image> _imageCache = {};
  Preloader? _preloader;

  factory AssetManager() {
    return _instance;
  }

  AssetManager._internal();

  void setPreloader(Preloader preloader) {
    _preloader = preloader;
  }

  Future<void> loadAllAssets() async {
    if (_preloader != null) {
      await _preloader!.preloadAssets();
    } else {
      // Fallback to manual loading if no preloader is set
      await _loadImages([
        'images/battery.png',
        'images/bulb_off.png',
        'images/bulb_on.png',
        'images/wire_straight.png',
        'images/wire_corner.png',
        'images/wire_t.png',
        'images/switch_open.png',
        'images/switch_closed.png',
        'images/grid_bg_level1.png',
      ]);
    }
  }

  Future<void> _loadImages(List<String> paths) async {
    for (final path in paths) {
      await getImage(path);
    }
  }

  Future<ui.Image> getImage(String path) async {
    if (_imageCache.containsKey(path)) {
      return _imageCache[path]!;
    }
    try {
      final byteData = await rootBundle.load('assets/$path');
      final codec = await ui.instantiateImageCodec(byteData.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      _imageCache[path] = frame.image;
      return frame.image;
    } catch (e) {
      debugPrint('Failed to load image: $e');
      rethrow;
    }
  }

  ui.Image? getImageFromCache(String path) {
    return _imageCache[path];
  }
}
