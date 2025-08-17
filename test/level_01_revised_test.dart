import 'dart:io';
import 'package:circuit_stem/core/providers.dart';
import 'package:circuit_stem/engine/animation_scheduler.dart';
import 'package:circuit_stem/engine/game_engine_notifier.dart';
import 'package:circuit_stem/models/component.dart';
import 'package:circuit_stem/models/position.dart';
import 'package:circuit_stem/ui/game_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/level_01_test_helper.dart';
import 'helpers/mock_asset_manager.dart';
import 'helpers/mock_animation_scheduler.dart';
import 'helpers/mock_audio_service.dart';

void main() {
  late ProviderContainer container;
  late MockAssetManager mockAssetManager;
  late MockAnimationScheduler mockAnimationScheduler;
  late MockAudioService mockAudioService;

  // This setup is run once for all tests in this file
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    final mockPrefs = await SharedPreferences.getInstance();
    mockAssetManager = MockAssetManager();
    mockAnimationScheduler = MockAnimationScheduler();
    mockAudioService = MockAudioService();

    final manifestContent =
        await File('assets/levels/level_manifest.json').readAsString();
    final level1Content =
        await File('assets/levels/level_01.json').readAsString();
    mockAssetManager.primeFile(
        'assets/levels/level_manifest.json', manifestContent);
    mockAssetManager.primeFile('assets/levels/level_01.json', level1Content);

    container = ProviderContainer(
      overrides: [
        assetManagerProvider.overrideWithValue(mockAssetManager),
        sharedPreferencesProvider.overrideWithValue(mockPrefs),
        gameEngineProvider.overrideWith((ref) {
          return GameEngineNotifier(
            initialLevel: null, // Will be set by loadLevelByIndex
            animationScheduler: mockAnimationScheduler,
            audioService: mockAudioService,
          );
        }),
      ],
    );

    // Pre-load the manifest
    await container.read(levelManagerProvider.notifier).init();
  });

  Future<void> pumpGameScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        parent: container,
        child: const MaterialApp(
          home: GameScreen(),
        ),
      ),
    );
    // Load the level and wait for the UI to react
    await container.read(levelManagerProvider.notifier).loadLevelByIndex(0);
    final loadedLevel = container.read(currentLevelDefinitionProvider);
    expect(loadedLevel, isNotNull, reason: 'Loaded level should not be null');

    // Explicitly load the level into the GameEngineNotifier
    container.read(gameEngineProvider.notifier).loadLevel(loadedLevel!);

    // Trigger the animation scheduler callback to update the game engine with the loaded level
    mockAnimationScheduler.triggerCallback(0.016); // Simulate one frame
    await tester.pump(); // Let the UI build
  }

  group('Level 01 Revised Tests - Foundation', () {
    tearDown(() {
      container.dispose();
      TestWidgetsFlutterBinding.instance.renderView.prepareForTest();
    });
    testWidgets('TC-L1-01: Toggle switch interaction',
        (WidgetTester tester) async {
      // ARRANGE: Load the game screen and level
      await pumpGameScreen(tester);

      // ACT: Find the switch and get its initial state
      final switchComponent =
          Level1TestHelper.findComponentById(container, 'switch1');
      expect(switchComponent, isNotNull,
          reason: "Switch 'switch1' should exist in level 1");
      final initialSwitchClosed =
          Level1TestHelper.getSwitchState(switchComponent!);

      // ACT: Tap the switch
      await Level1TestHelper.tapComponent(
        tester,
        Position(r: switchComponent.r, c: switchComponent.c),
      );
      // Trigger the animation scheduler callback to process the tap and update the game engine
      mockAnimationScheduler.triggerCallback(0.016); // Simulate one frame
      await tester.pump(); // Allow the state to update
      await tester.pumpAndSettle();

      // ASSERT: Check that the switch state has toggled
      final newSwitchComponent =
          Level1TestHelper.findComponentById(container, 'switch1')!;
      final finalSwitchClosed =
          Level1TestHelper.getSwitchState(newSwitchComponent);

      expect(finalSwitchClosed, !initialSwitchClosed,
          reason: 'Switch state should toggle after tap.');
    });

    testWidgets('TC-L1-02: Move timer component', (WidgetTester tester) async {
      // ARRANGE: Load the game screen and level
      await pumpGameScreen(tester);

      // ACT: Find the timer component
      final timerComponent =
          Level1TestHelper.findComponentById(container, 'timer1');
      expect(timerComponent, isNotNull,
          reason: "Timer 'timer1' should exist in level 1");
      expect(timerComponent!.isDraggable, isTrue,
          reason: 'Timer should be draggable');

      final fromPos = Position(r: timerComponent.r, c: timerComponent.c);
      const toPos = Position(r: 3, c: 2); // Valid empty position

      // ACT: Drag the timer
      await Level1TestHelper.dragComponent(tester, fromPos, toPos);
      // Trigger the animation scheduler callback to process the drag and update the game engine
      mockAnimationScheduler.triggerCallback(0.016); // Simulate one frame
      await tester.pump(); // Allow the state to update
      await tester.pumpAndSettle();

      // ASSERT: Check the timer's new position
      final movedComponent =
          Level1TestHelper.findComponentById(container, 'timer1')!;
      expect(Level1TestHelper.isComponentAtPosition(movedComponent, toPos),
          isTrue,
          reason: 'Timer should be at the new position after dragging.');
    });
  });
}