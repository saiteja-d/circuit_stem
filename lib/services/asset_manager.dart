import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:flutter_svg/flutter_svg.dart';
import '../common/logger.dart';

class CachedAsset<T> {
  final T data;
  final DateTime loadTime;

  CachedAsset(this.data) : loadTime = DateTime.now();
}

class AssetManagerState {
  final Map<String, CachedAsset<dynamic>> _cache = {};
  final Set<String> _preloadQueue = {};
  bool _isPreloading = false;

  Future<T> getAsset<T>(String path, Future<T> Function(String) loader) async {
    if (_cache.containsKey(path)) {
      final cached = _cache[path]!;
      if (cached.data is T) {
        return cached.data as T;
      }
    }

    final data = await loader(path);
    _cache[path] = CachedAsset<T>(data);
    return data;
  }

  Future<void> preloadAssets(List<String> assets) async {
    _preloadQueue.addAll(assets);
    if (!_isPreloading) {
      await _processPreloadQueue();
    }
  }

  Future<void> _processPreloadQueue() async {
    if (_preloadQueue.isEmpty) return;

    _isPreloading = true;
    Logger.log('Starting asset preload...');

    try {
      for (final path in _preloadQueue.toList()) {
        if (path.endsWith('.svg')) {
          await getAsset<DrawableRoot>(path, 
            (p) => svg.fromAsset(p).then((s) => s.root));
        } else if (path.endsWith('.json')) {
          await getAsset<Map<String, dynamic>>(path, 
            (p) => rootBundle.loadString(p).then((s) => json.decode(s)));
        }
        _preloadQueue.remove(path);
      }
    } finally {
      _isPreloading = false;
    }

    Logger.log('Asset preload complete');
  }

  void clearCache() {
    _cache.clear();
  }

  void removeCachedAsset(String path) {
    _cache.remove(path);
  }
}

class AssetManager extends StateNotifier<AssetManagerState> {
  AssetManager() : super(AssetManagerState());

  Future<T> getAsset<T>(String path, Future<T> Function(String) loader) {
    return state.getAsset<T>(path, loader);
  }

  Future<void> preloadAssets(List<String> assets) {
    return state.preloadAssets(assets);
  }

  void clearCache() {
    state.clearCache();
  }

  void removeCachedAsset(String path) {
    state.removeCachedAsset(path);
  }
}
