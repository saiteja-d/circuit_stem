import 'dart:ui' as ui;
import 'dart:math';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart' as flutter_svg;
import 'package:flame/flame.dart'; // Import Flame
import '../common/logger.dart';

class AssetManager {
  final Map<String, ui.Image> _imageCache = {};
  final Map<String, DrawableRoot> _svgCache = {};

  Future<void> loadAllAssets() async {
    Logger.log('AssetManager: Preloading all assets...');
    // Preload images, SVGs, and audio files
    await _loadImages([
      'assets/images/grid_bg_level1.png',
    ]);
    await _loadSvgs([
      'assets/images/battery.svg',
      'assets/images/bulb_off.svg',
      'assets/images/bulb_on.svg',
      'assets/images/wire_straight.svg',
      'assets/images/wire_corner.svg',
      'assets/images/wire_t.svg',
      'assets/images/switch_open.svg',
      'assets/images/switch_closed.svg',
    ]);
    await Flame.audio.audioCache.loadAll([
      'place.wav',
      'toggle.wav',
      'success.wav',
      'short_warning.wav',
    ]);
    Logger.log('AssetManager: Preloading complete.');
  }

  Future<void> _loadImages(List<String> paths) async {
    for (final path in paths) {
      try {
        final byteData = await rootBundle.load(path);
        final image = await decodeImageFromList(byteData.buffer.asUint8List());
        _imageCache[path] = image;
      } catch (e) {
        Logger.log('Failed to load image: $path, Error: $e');
      }
    }
  }

  Future<void> _loadSvgs(List<String> paths) async {
    for (final path in paths) {
      try {
        final rawSvg = await rootBundle.loadString(path);
        final drawable = await flutter_svg.SvgPicture.fromSvgString(rawSvg, rawSvg);
        _svgCache[path] = drawable;
      } catch (e) {
        Logger.log('Failed to load SVG: $path, Error: $e');
      }
    }
  }

  ui.Image? getImage(String path) => _imageCache[path];

  DrawableRoot? getSvg(String path) => _svgCache[path];

  void dispose() {
    for (final image in _imageCache.values) {
      image.dispose();
    }
    _imageCache.clear();
    _svgCache.clear();
  }
}
