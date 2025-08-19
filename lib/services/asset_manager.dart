import 'dart:async';
import 'dart:ui';

import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/logger.dart';
import '../common/assets.dart';
import 'asset_manager_state.dart';

class AssetManagerNotifier extends StateNotifier<AssetState> {
  AssetManagerNotifier() : super(const AssetState());

  Future<void> loadAllAssets() async {
    Logger.log('AssetManager: Starting robust asset loading...');
    try {
      final imagePaths = AppAssets.all.where((p) => p.endsWith('.png')).toList();
      await _loadImages(imagePaths);
      await _loadAudio();
      Logger.log('AssetManager: All non-SVG assets loaded successfully');
    } catch (e) {
      Logger.log('AssetManager: Error during loading: $e');
    }
  }

  Future<void> _loadImages(List<String> paths) async {
    final newImages = Map<String, Image>.from(state.imageCache);
    for (final path in paths) {
      try {
        final byteData = await rootBundle.load(path);
        final codec = await instantiateImageCodec(byteData.buffer.asUint8List());
        final frameInfo = await codec.getNextFrame();
        newImages[path] = frameInfo.image;
        Logger.log('✓ Loaded image: $path');
      } catch (e) {
        Logger.log('✗ Failed to load image: $path - $e');
      }
    }
    state = state.copyWith(imageCache: newImages);
  }

  void setSvgImages(Map<String, Image> images) {
    state = state.copyWith(svgImageCache: images);
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

  Image? getImage(String path) => state.imageCache[path];
  Image? getSvgAsImage(String path) => state.svgImageCache[path];

  bool hasAsset(String path) {
    return state.imageCache.containsKey(path) || state.svgImageCache.containsKey(path);
  }

  Image? getBestImageForCanvas(String path) {
    if (state.svgImageCache.containsKey(path)) return state.svgImageCache[path];
    if (state.imageCache.containsKey(path)) return state.imageCache[path];
    return null;
  }

  Map<String, int> getStats() {
    return {
      'regular_images': state.imageCache.length,
      'svg_images': state.svgImageCache.length,
      'total_assets': state.imageCache.length + state.svgImageCache.length,
    };
  }

  @override
  void dispose() {
    for (final image in state.imageCache.values) {
      image.dispose();
    }
    for (final image in state.svgImageCache.values) {
      image.dispose();
    }
    state = const AssetState(); // Reset state
    Logger.log('AssetManager: All assets disposed');
    super.dispose();
  }
}
