import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:widgets_to_image/widgets_to_image.dart';

import '../common/logger.dart';
import '../common/assets.dart';

class AssetManager {
  final Map<String, ui.Image> _imageCache = {};
  final Map<String, String> _svgStrings = {};
  final Map<String, ui.Image> _svgImageCache = {};
  final WidgetsToImageController _widgetsToImageController = WidgetsToImageController();
  
  // Configuration
  static const double defaultSvgSize = 64.0;

  Future<void> loadAllAssets() async {
    Logger.log('AssetManager: Starting robust asset loading...');
    
    try {
      // Ensure Flutter is initialized
      WidgetsFlutterBinding.ensureInitialized();
      
      final imagePaths = AppAssets.all.where((p) => p.endsWith('.png')).toList();
      await _loadImages(imagePaths);
      
      final svgPaths = AppAssets.all.where((p) => p.endsWith('.svg')).toList();
      // await _loadAndProcessSvgs(svgPaths);
      
      // Load audio
      await _loadAudio();
      
      Logger.log('AssetManager: All assets loaded successfully');
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

  // === Public API ===

  ui.Image? getImage(String path) => _imageCache[path];
  ui.Image? getSvgAsImage(String path) => _svgImageCache[path];
  String? getSvgString(String path) => _svgStrings[path];
  
  Widget? getSvgWidget(String path, {
    double? width, 
    double? height, 
    ColorFilter? colorFilter,
    BoxFit fit = BoxFit.contain,
  }) {
    final svgString = _svgStrings[path];
    if (svgString == null) return null;
    
    return SvgPicture.string(
      svgString,
      width: width ?? defaultSvgSize,
      height: height ?? defaultSvgSize,
      colorFilter: colorFilter,
      fit: fit,
    );
  }

  Widget? getSvgWidgetColored(String path, Color color, {double? width, double? height}) {
    return getSvgWidget(
      path,
      width: width,
      height: height,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }

  bool hasAsset(String path) {
    return _imageCache.containsKey(path) || 
           _svgStrings.containsKey(path) || 
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
      'svg_strings': _svgStrings.length,
      'svg_images': _svgImageCache.length,
      'total_assets': _imageCache.length + _svgStrings.length,
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
    _svgStrings.clear();
    Logger.log('AssetManager: All assets disposed');
  }
}