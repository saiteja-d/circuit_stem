// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'services/asset_manager.dart';
import 'core/providers.dart';
import 'common/logger.dart';
import 'common/assets.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:async';
import 'dart:ui' as ui;
import 'ui/svg_capture.dart';

void main() async {
  Logger.log('main() called');
  WidgetsFlutterBinding.ensureInitialized();

  // Basic synchronous service setup
  final prefs = await SharedPreferences.getInstance();
  final assetManager = AssetManager();
  // Load non-svg assets (images .png, audio etc.)
  await assetManager.loadAllAssets();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        assetManagerProvider.overrideWithValue(assetManager),
      ],
      child: Initializer(), // NEW: app root that will process SVGs then show real App
    ),
  );
  Logger.log('runApp() called');
}

class Initializer extends ConsumerStatefulWidget {
  @override
  _InitializerState createState() => _InitializerState();
}

class _InitializerState extends ConsumerState<Initializer> {
  bool _ready = false;
  String _status = 'Preparing assets...';
  Map<String, String> _svgStrings = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _processSvgs());
  }

  Future<void> _processSvgs() async {
    final assetManager = ref.read(assetManagerProvider);

    try {
      setState(() => _status = 'Loading SVG source strings...');

      // Load SVGs as strings from assets
      final svgPaths = AppAssets.all.where((p) => p.endsWith('.svg')).toList();
      for (final p in svgPaths) {
        try {
          final svgString = await rootBundle.loadString(p);
          _svgStrings[p] = svgString;
        } catch (e) {
          Logger.log('Failed to read svg $p: $e');
        }
      }

      if (_svgStrings.isEmpty) {
        Logger.log('No SVG strings found; skipping rasterization.');
        setState(() => _ready = true);
        return;
      }

      setState(() => _status = 'Rasterizing SVGs...');

      // Wait for SvgCapture to capture (we will mount it in build)
      final imagesCompleter = Completer<Map<String, ui.Image>>();
      // place the completer into state so build() can pass it down via callback
      _captureCompleter = imagesCompleter;

      final images = await imagesCompleter.future;

      // Save images into AssetManager
      assetManager.setSvgImages(images);
      Logger.log('SVG rasterization complete. ${images.length} images set in AssetManager.');

      setState(() => _ready = true);
    } catch (e) {
      Logger.log('Error during SVG processing: $e');
      setState(() => _ready = true); // allow app to continue even if svg step failed
    }
  }

  Completer<Map<String, ui.Image>>? _captureCompleter;

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      // Show a spinner + mount the invisible SvgCapture when we have loaded svgStrings and the completer
      return MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text(_status),
                  ],
                ),
              ),

              // When we have svg strings and a completer, mount the invisible SvgCapture
              if (_svgStrings.isNotEmpty && _captureCompleter != null)
                // The SvgCapture will call onImagesCaptured when done.
                // We pass the map assetPath->svgString so keys are meaningful.
                Positioned(
                  left: 0,
                  top: 0,
                  child: SvgCapture(
                    svgMap: _svgStrings,
                    captureSize: 64.0,
                    onImagesCaptured: (images) {
                      if (!(_captureCompleter?.isCompleted ?? true)) {
                        _captureCompleter?.complete(images);
                      }
                    },
                  ),
                ),
            ],
          ),
        ),
      );
    }

    // Ready -> run real App
    return const App();
  }
}
