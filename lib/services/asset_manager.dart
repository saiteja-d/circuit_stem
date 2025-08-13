import 'dart:async';
import 'dart:ui' as ui;

import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
    await FlameAudio.audioCache.loadAll([
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
        Logger.log('Failed to load image: \$path, Error: \$e');
      }
    }
  }

  Future<PictureInfo> _getPictureInfo(String rawSvg) {
    final completer = Completer<PictureInfo>();
    final pictureProvider = StringPicture(SvgPicture.svgStringDecoderBuilder, rawSvg);
    final stream = pictureProvider.resolve(PictureConfiguration.empty);
    stream.addListener(ImageStreamListener((image, sync) {
      completer.complete(image as PictureInfo);
    }, onError: (exception, stackTrace) {
      completer.completeError(exception, stackTrace);
    }));
    return completer.future;
  }

  Future<void> _loadSvgs(List<String> paths) async {
    for (final path in paths) {
      try {
        final rawSvg = await rootBundle.loadString(path);
        final pictureInfo = await _getPictureInfo(rawSvg);
        _svgCache[path] = pictureInfo;
      } catch (e) {
        Logger.log('Failed to load SVG: \$path, Error: \$e');
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
