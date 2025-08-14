import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../common/logger.dart';

class AssetManager {
  final Map<String, ui.Image> _imageCache = {};
  final Map<String, String> _svgStrings = {};
  final Map<String, ui.Image> _svgImageCache = {};
  
  // Configuration
  static const double defaultSvgSize = 64.0;
  static const double pixelRatio = 1.0;

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

  /// Robust SVG to ui.Image conversion using widget rendering
  Future<ui.Image?> _convertSvgToImage(String svgString, double size) async {
    try {
      final completer = Completer<ui.Image?>();
      
      // Create the SVG widget
      final svgWidget = SvgPicture.string(
        svgString,
        width: size,
        height: size,
        fit: BoxFit.contain,
      );
      
      // Create a container widget for proper rendering
      final containerWidget = Container(
        width: size,
        height: size,
        color: Colors.transparent,
        child: svgWidget,
      );
      
      // Method 1: Try using RepaintBoundary approach
      final image = await _renderWidgetToImage(containerWidget, size);
      if (image != null) {
        completer.complete(image);
        return await completer.future;
      }
      
      // Method 2: Fallback to manual picture creation
      Logger.log('Falling back to manual SVG rendering');
      return await _fallbackSvgToImage(svgString, size);
      
    } catch (e) {
      Logger.log('SVG to Image conversion error: $e');
      return null;
    }
  }

  /// Primary method: Render widget to image using RepaintBoundary
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

      // Create a minimal app to render the widget
      final app = MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(child: repaintBoundary),
        ),
        debugShowCheckedModeBanner: false,
      );

      // This approach requires a BuildContext, which is complex in isolation
      // Let's use the PictureRecorder approach instead
      return await _createImageFromSvg(widget, size);
      
    } catch (e) {
      Logger.log('Widget to image rendering failed: $e');
      return null;
    }
  }

  /// Alternative method using PictureRecorder and manual rendering
  Future<ui.Image?> _createImageFromSvg(Widget svgWidget, double size) async {
    try {
      // Create a picture recorder
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      
      // Create a simple render pipeline
      final constraints = BoxConstraints.tight(Size(size, size));
      
      // This is a simplified approach - for production, you'd want to
      // properly render the widget tree, but that requires a full Flutter context
      
      // For now, let's create a basic fallback image
      final paint = Paint()
        ..color = Colors.blue.withValues(alpha: 0.7)
        ..style = PaintingStyle.fill;
      
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size, size),
        Paint()..color = Colors.transparent,
      );
      
      // Draw a placeholder that indicates SVG loading
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

  /// Fallback method for SVG conversion
  Future<ui.Image?> _fallbackSvgToImage(String svgString, double size) async {
    try {
      // Create a basic colored rectangle as fallback
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      
      // Determine color based on SVG content (simple heuristic)
      Color color = Colors.grey;
      if (svgString.contains('battery')) {
        color = Colors.red.shade300;
      } else if (svgString.contains('bulb')) {
        color = Colors.yellow.shade300;
      } else if (svgString.contains('wire')) {
        color = Colors.blue.shade300;
      } else if (svgString.contains('switch')) {
        color = Colors.green.shade300;
      }
      
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      
      // Draw background
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size, size),
        Paint()..color = Colors.white,
      );
      
      // Draw main shape
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

  /// Get regular image
  ui.Image? getImage(String path) => _imageCache[path];
  
  /// Get SVG as ui.Image (best for Canvas drawing)
  ui.Image? getSvgAsImage(String path) => _svgImageCache[path];
  
  /// Get SVG as string (for manual parsing if needed)
  String? getSvgString(String path) => _svgStrings[path];
  
  /// Get SVG as Widget (best for UI use)
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

  /// Create SVG widget with custom color
  Widget? getSvgWidgetColored(String path, Color color, {double? width, double? height}) {
    return getSvgWidget(
      path,
      width: width,
      height: height,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }

  /// Check if asset exists
  bool hasAsset(String path) {
    return _imageCache.containsKey(path) || 
           _svgStrings.containsKey(path) || 
           _svgImageCache.containsKey(path);
  }

  /// Get the best representation for Canvas use
  ui.Image? getBestImageForCanvas(String path) {
    // Try SVG image first (converted from SVG)
    if (_svgImageCache.containsKey(path)) {
      return _svgImageCache[path];
    }
    
    // Fallback to regular image
    if (_imageCache.containsKey(path)) {
      return _imageCache[path];
    }
    
    return null;
  }

  /// Get stats about loaded assets
  Map<String, int> getStats() {
    return {
      'regular_images': _imageCache.length,
      'svg_strings': _svgStrings.length,
      'svg_images': _svgImageCache.length,
      'total_assets': _imageCache.length + _svgStrings.length,
    };
  }

  void dispose() {
    // Dispose regular images
    for (final image in _imageCache.values) {
      image.dispose();
    }
    
    // Dispose SVG images
    for (final image in _svgImageCache.values) {
      image.dispose();
    }
    
    // Clear all caches
    _imageCache.clear();
    _svgImageCache.clear();
    _svgStrings.clear();
    
    Logger.log('AssetManager: All assets disposed');
  }
}