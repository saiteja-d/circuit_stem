import 'dart:async';
import 'dart:ui' as ui;

import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:widgets_to_image/widgets_to_image.dart';

import '../common/logger.dart';
import '../common/assets.dart';

class AssetManager {
  final Map<String, ui.Image> _imageCache = {};
  final Map<String, ui.Image> _svgImageCache = {};
  
  // Configuration
  static const double defaultSvgSize = 64.0;

  Future<void> loadAllAssets() async {
    Logger.log('AssetManager: Starting robust asset loading...');
    
    try {
      // This call is no longer strictly necessary here since main() also calls it,
      // but it's harmless to leave for now.
      WidgetsFlutterBinding.ensureInitialized();
      
      final imagePaths = AppAssets.all.where((p) => p.endsWith('.png')).toList();
      await _loadImages(imagePaths);
      
      // SVG processing is now handled by the Initializer widget.
      
      // Load audio
      await _loadAudio();
      
      Logger.log('AssetManager: All non-SVG assets loaded successfully');
    } catch (e) {
      Logger.log('AssetManager: Error during loading: $e');
    }
  }

  Future<void> _loadImages(List<String> paths) async {
    for (final path in paths) {
      try {
        final byteData = await rootBundle.load(path);
        final image = await decodeImageFromList(byteData.buffer.asUint8List());
        _imageCache[path] = image;
        Logger.log('✓ Loaded image: $path');
      } catch (e) {
        Logger.log('✗ Failed to load image: $path - $e');
      }
    }
  }

  void setSvgImages(Map<String, ui.Image> images) {
    _svgImageCache.addAll(images);
  }

  Future<void> _loadAudio() async {
    final audioFiles = AppAssets.all.where((p) => p.endsWith('.wav')).toList();
    
    for (final file in audioFiles) {
      try {
        await FlameAudio.audioCache.load(file);
        Logger.log('✓ Loaded audio: $file');
      } catch (e) {
        Logger.log('✗ Failed to load audio: $file - $e');
      }
    }
  }

  Future<String> loadString(String path) async {
    return await rootBundle.loadString(path);
  }

  // === Public API ===

  ui.Image? getImage(String path) => _imageCache[path];
  ui.Image? getSvgAsImage(String path) => _svgImageCache[path];

  bool hasAsset(String path) {
    return _imageCache.containsKey(path) || 
           _svgImageCache.containsKey(path);
  }

  ui.Image? getBestImageForCanvas(String path) {
    if (_svgImageCache.containsKey(path)) return _svgImageCache[path];
    if (_imageCache.containsKey(path)) return _imageCache[path];
    return null;
  }

  Map<String, int> getStats() {
    return {
      'regular_images': _imageCache.length,
      'svg_images': _svgImageCache.length,
      'total_assets': _imageCache.length + _svgImageCache.length,
    };
  }

  void dispose() {
    for (final image in _imageCache.values) {
      image.dispose();
    }
    for (final image in _svgImageCache.values) {
      image.dispose();
    }
    _imageCache.clear();
    _svgImageCache.clear();
    Logger.log('AssetManager: All assets disposed');
  }
}
