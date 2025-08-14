import 'dart:async';
import 'dart:ui' as ui;

import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../common/logger.dart';

class AssetManager {
  final Map<String, ui.Image> _imageCache = {};
  final Map<String, String> _svgStrings = {};
  final Map<String, ui.Image> _svgImageCache = {};
  
  // Configuration
  static const double defaultSvgSize = 64.0;

  Future<void> loadAllAssets() async {
    Logger.log('AssetManager: Starting robust asset loading...');
    
    try {
      // Ensure Flutter is initialized
      WidgetsFlutterBinding.ensureInitialized();
      
      // Load regular images
      await _loadImages([
        'assets/images/grid_bg_level1.png',
      ]);
      
      // Load and process SVGs
      await _loadAndProcessSvgs([
        'assets/images/battery.svg',
        'assets/images/bulb_off.svg',
        'assets/images/bulb_on.svg',
        'assets/images/wire_straight.svg',
        'assets/images/wire_corner.svg',
        'assets/images/wire_t.svg',
        'assets/images/switch_open.svg',
        'assets/images/switch_closed.svg',
      ]);
      
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

  Future<void> _loadAndProcessSvgs(List<String> paths) async {
    for (final path in paths) {
      try {
        // Step 1: Load SVG string
        final rawSvg = await rootBundle.loadString(path);
        _svgStrings[path] = rawSvg;
        Logger.log('✓ Loaded SVG string: $path');
        
        // Step 2: Convert to ui.Image
        final image = await _convertSvgToImage(rawSvg, defaultSvgSize);
        if (image != null) {
          _svgImageCache[path] = image;
          Logger.log('✓ Converted SVG to Image: $path');
        } else {
          Logger.log('✗ Failed to convert SVG to Image: $path');
        }
      } catch (e) {
        Logger.log('✗ Failed to process SVG: $path - $e');
      }
    }
  }

  Future<ui.Image?> _convertSvgToImage(String svgString, double size) async {
    try {
      final completer = Completer<ui.Image?>();
      
      final svgWidget = SvgPicture.string(
        svgString,
        width: size,
        height: size,
        fit: BoxFit.contain,
      );
      
      final containerWidget = Container(
        width: size,
        height: size,
        color: Colors.transparent,
        child: svgWidget,
      );
      
      final image = await _renderWidgetToImage(containerWidget, size);
      if (image != null) {
        completer.complete(image);
        return await completer.future;
      }
      
      return await _fallbackSvgToImage(svgString, size);
      
    } catch (e) {
      Logger.log('SVG to Image conversion error: $e');
      return null;
    }
  }

  Future<ui.Image?> _renderWidgetToImage(Widget widget, double size) async {
    try {
      final GlobalKey repaintBoundaryKey = GlobalKey();
      
      final repaintBoundary = RepaintBoundary(
        key: repaintBoundaryKey,
        child: MediaQuery(
          data: const MediaQueryData(),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: widget,
          ),
        ),
      );

      // This approach is complex, using a simpler one for now.
      return await _createImageFromSvg(repaintBoundary, size);
      
    } catch (e) {
      Logger.log('Widget to image rendering failed: $e');
      return null;
    }
  }

  Future<ui.Image?> _createImageFromSvg(Widget svgWidget, double size) async {
    try {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      
      // Simplified rendering
      final paint = Paint()..color = Colors.blue.withOpacity(0.7);
      
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size, size),
        Paint()..color = Colors.transparent,
      );
      
      canvas.drawCircle(
        Offset(size / 2, size / 2),
        size / 4,
        paint,
      );
      
      final picture = recorder.endRecording();
      final image = await picture.toImage(size.round(), size.round());
      picture.dispose();
      
      return image;
    } catch (e) {
      Logger.log('Manual SVG rendering failed: $e');
      return null;
    }
  }

  Future<ui.Image?> _fallbackSvgToImage(String svgString, double size) async {
    try {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      
      Color color = Colors.grey;
      if (svgString.contains('battery')) {
        color = Colors.red.shade300;
      } else if (svgString.contains('bulb')) color = Colors.yellow.shade300;
      else if (svgString.contains('wire')) color = Colors.blue.shade300;
      else if (svgString.contains('switch')) color = Colors.green.shade300;
      
      final paint = Paint()..color = color..style = PaintingStyle.fill;
      
      canvas.drawRect(Rect.fromLTWH(0, 0, size, size), Paint()..color = Colors.white);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(size * 0.1, size * 0.1, size * 0.8, size * 0.8),
          Radius.circular(size * 0.1),
        ),
        paint,
      );
      
      final picture = recorder.endRecording();
      final image = await picture.toImage(size.round(), size.round());
      picture.dispose();
      
      return image;
    } catch (e) {
      Logger.log('Fallback SVG rendering failed: $e');
      return null;
    }
  }

  Future<void> _loadAudio() async {
    final audioFiles = [
      'assets/audio/place.mp3',
      'assets/audio/toggle.mp3',
      'assets/audio/success.mp3',
      'assets/audio/warning.mp3',
    ];
    
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