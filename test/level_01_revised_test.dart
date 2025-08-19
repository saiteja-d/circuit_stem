import 'dart:io';
import 'package:circuit_stem/core/providers.dart';
import 'package:circuit_stem/engine/game_engine_notifier.dart';
import 'package:circuit_stem/models/position.dart';
import 'package:circuit_stem/services/level_manager.dart';
import 'package:circuit_stem/ui/game_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_async/fake_async.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:circuit_stem/services/asset_manager_state.dart';

import 'helpers/level_01_test_helper.dart';
import 'helpers/mock_asset_manager.dart';
import 'helpers/mock_animation_scheduler.dart';
import 'helpers/mock_audio_service.dart';

void main() {
  group('Level 01 Revised Tests - Foundation', () {
    Future<void> pumpGameScreenWithOverrides(WidgetTester tester) async {
      final mockAssetManager = MockAssetManager(const AssetState());
      final mockAnimationScheduler = MockAnimationScheduler();
      final mockAudioService = MockAudioService();
      SharedPreferences.setMockInitialValues({});
      final mockPrefs = await SharedPreferences.getInstance();

      final manifestContent =
          await File('assets/levels/level_manifest.json').readAsString();
      final level1Content =
          await File('assets/levels/level_01.json').readAsString();
      mockAssetManager.primeFile(
          'assets/levels/level_manifest.json', manifestContent);
      mockAssetManager.primeFile('assets/levels/level_01.json', level1Content);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            assetManagerProvider.overrideWith((_) => mockAssetManager),
            sharedPreferencesProvider.overrideWithValue(mockPrefs),
            // Explicitly override the level manager to ensure it uses the mock asset manager.
            levelManagerProvider.overrideWith((ref) {
              return LevelManagerNotifier(
                ref.watch(sharedPreferencesProvider),
                mockAssetManager,
              );
            }),
            gameEngineProvider.overrideWith((ref) {
              return GameEngineNotifier(
                animationScheduler: mockAnimationScheduler,
                audioService: mockAudioService,
              );
            }),
          ],
          child: const MaterialApp(
            home: GameScreen(),
          ),
        ),
      );

      final container = ProviderScope.containerOf(tester.element(find.byType(GameScreen)));
      await container.read(levelManagerProvider.notifier).init();
      await container.read(levelManagerProvider.notifier).loadLevelByIndex(0);
      await tester.pump();
    }

    testWidgets(
      'TC-L1-01: Toggle switch interaction',
      (WidgetTester tester) => fakeAsync((async) async {
        await pumpGameScreenWithOverrides(tester);
        final container = ProviderScope.containerOf(tester.element(find.byType(GameScreen)));
        final mockAnimationScheduler = container.read(gameEngineProvider.notifier).animationScheduler as MockAnimationScheduler;

        final switchComponent = Level1TestHelper.findComponentById(container, 'switch1');
        expect(switchComponent, isNotNull);
        final initialSwitchClosed = Level1TestHelper.getSwitchState(switchComponent!);

        await Level1TestHelper.tapComponent(tester, Position(r: switchComponent.r, c: switchComponent.c));
        mockAnimationScheduler.triggerCallback(0.016);
        await tester.pump();

        final newSwitchComponent = Level1TestHelper.findComponentById(container, 'switch1')!;
        final finalSwitchClosed = Level1TestHelper.getSwitchState(newSwitchComponent);

        expect(finalSwitchClosed, !initialSwitchClosed);
      }),
      timeout: const Timeout(Duration(minutes: 1)),
    );

    testWidgets(
      'TC-L1-02: Move timer component',
      (WidgetTester tester) async {
        await pumpGameScreenWithOverrides(tester);
        final container = ProviderScope.containerOf(tester.element(find.byType(GameScreen)));
        final mockAnimationScheduler = container.read(gameEngineProvider.notifier).animationScheduler as MockAnimationScheduler;

        final timerComponent = Level1TestHelper.findComponentById(container, 'timer1');
        expect(timerComponent, isNotNull);
        expect(timerComponent!.isDraggable, isTrue);

        final fromPos = Position(r: timerComponent.r, c: timerComponent.c);
        const toPos = Position(r: 3, c: 2);

        await Level1TestHelper.dragComponent(tester, fromPos, toPos);
        mockAnimationScheduler.triggerCallback(0.016);
        await tester.pump();

        final movedComponent = Level1TestHelper.findComponentById(container, 'timer1')!;
        expect(Level1TestHelper.isComponentAtPosition(movedComponent, toPos), isTrue);
      },
      timeout: const Timeout(Duration(minutes: 1)),
    );
  });
}