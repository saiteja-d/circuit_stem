import 'dart:async';
import 'dart:ui' as ui;

import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vector_graphics/vector_graphics.dart' as vg;

import '../common/logger.dart';

class AssetManager {
  final Map<String, ui.Image> _imageCache = {};
  final Map<String, PictureInfo> _svgCache = {};

  Future<void> loadAllAssets() async {
    Logger.log('AssetManager: Preloading all assets...');
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
    Logger.log('FlameAudio prefix: ${FlameAudio.audioCache.prefix}');
    final audioFiles = [
      'assets/audio/place.mp3',
      'assets/audio/toggle.mp3',
      'assets/audio/success.mp3',
      'assets/audio/short_warning.mp3',
    ];
    for (final file in audioFiles) {
      Logger.log('Loading audio file: $file');
      try {
        await FlameAudio.audioCache.load(file);
      } catch (e) {
        Logger.log('Error loading audio file: $file, Error: $e');
      }
    }
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
        final loader = SvgStringLoader(rawSvg);
        final pictureInfo = await vg.loadPicture(loader, null);
        _svgCache[path] = pictureInfo;
      } catch (e) {
        Logger.log('Failed to load SVG: $path, Error: $e');
      }
    }
  }

  ui.Image? getImage(String path) => _imageCache[path];

  PictureInfo? getSvg(String path) => _svgCache[path];

  void dispose() {
    for (final image in _imageCache.values) {
      image.dispose();
    }
    _imageCache.clear();
    _svgCache.clear();
  }
}
