import 'dart:ui' as ui;

import 'package:circuit_stem/core/providers.dart';
import 'package:circuit_stem/engine/game_engine_notifier.dart';
import 'package:circuit_stem/models/component.dart';
import 'package:circuit_stem/models/level_definition.dart';
import 'package:circuit_stem/models/position.dart';
import 'package:circuit_stem/services/asset_manager.dart';
import 'package:circuit_stem/services/level_manager.dart';
import 'package:circuit_stem/ui/game_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';


// Mocks
class MockSharedPreferences extends Mock implements SharedPreferences {}
class MockAssetManager extends Mock implements AssetManager {
  @override
  ui.Image? getSvgAsImage(String path) {
    // Return a simple 1x1 test image for all SVG requests
    return _createTestImage();
  }

  static ui.Image _createTestImage() {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, 64, 64));
    canvas.drawRect(const Rect.fromLTWH(0, 0, 64, 64), Paint()..color = Colors.grey);
    final picture = recorder.endRecording();
    return picture.toImageSync(64, 64);
  }
}

class Level1TestHelper {
  static const double cellSize = 64.0;
  static const Size testCanvasSize = Size(384, 384); // 6x6 grid * 64px

  static Future<ProviderContainer> setupTestEnvironment(WidgetTester tester) async {
    final mockPrefs = MockSharedPreferences();
    final mockAssetManager = MockAssetManager();

    // Mock SharedPreferences behavior
    when(() => mockPrefs.getInt(any())).thenReturn(0);
    when(() => mockPrefs.setInt(any(), any())).thenAnswer((_) async => true);

    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(mockPrefs),
        assetManagerProvider.overrideWithValue(mockAssetManager),
      ],
    );

    // Pre-load the level into the LevelManager
    final levelManager = container.read(levelManagerProvider.notifier);
    // Manifest is loaded automatically by the notifier constructor
    final level = await levelManager.loadLevelByIndex(0);
    
    expect(level, isNotNull, reason: "Test setup failed: Level 01 could not be loaded.");

    // Now, create the GameEngineNotifier with the pre-loaded level
    final gameEngineNotifier = GameEngineNotifier(initialLevel: level);

    await tester.pumpWidget(
      ProviderScope(
        parent: container,
        overrides: [
          // Override the gameEngineProvider with our pre-initialized instance
          gameEngineProvider.overrideWith((ref) => gameEngineNotifier),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: testCanvasSize.width,
                height: testCanvasSize.height,
                child: const GameScreen(),
              ),
            ),
          ),
        ),
      ),
    );
    
    // Wait for any initial frame rendering to complete
    await tester.pumpAndSettle();

    return container;
  }

  static Offset gridToPixel(Position pos) {
    return Offset(
      (pos.c * cellSize) + (cellSize / 2),
      (pos.r * cellSize) + (cellSize / 2),
    );
  }

  static Position pixelToGrid(Offset pixel) {
    return Position(
      r: (pixel.dy / cellSize).floor(),
      c: (pixel.dx / cellSize).floor(),
    );
  }

  static Component? findComponentById(ProviderContainer container, String id) {
    final state = container.read(gameEngineProvider);
    return state.grid.componentsById.values.where((c) => c.id == id).firstOrNull;
  }

  static bool isComponentAtPosition(Component component, Position pos) {
    return component.r == pos.r && component.c == pos.c;
  }
  
  static bool getSwitchState(Component component) {
    assert(component.type == ComponentType.sw, "Component must be a switch");
    return component.state['closed'] as bool? ?? false;
  }

  static Future<void> tapComponent(WidgetTester tester, Position pos) async {
    await tester.tapAt(gridToPixel(pos));
  }

  static Future<void> dragComponent(WidgetTester tester, Position from, Position to) async {
    final startPixel = gridToPixel(from);
    final endPixel = gridToPixel(to);
    await tester.dragFrom(startPixel, endPixel - startPixel);
  }
  
  static Future<void> waitForCircuitUpdate(WidgetTester tester) async {
    // pumpAndSettle is usually sufficient to wait for state changes and animations
    await tester.pumpAndSettle();
  }
}