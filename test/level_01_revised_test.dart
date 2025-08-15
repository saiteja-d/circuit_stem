import 'package:circuit_stem/core/providers.dart';
import 'package:circuit_stem/models/component.dart';
import 'package:circuit_stem/models/position.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/level_01_test_helper.dart';

void main() {
  group('Level 01 Revised Tests - Foundation', () {
    testWidgets('Test environment setup successfully loads Level 1', (tester) async {
      // The setupTestEnvironment function contains the core logic.
      // If it completes without throwing an error, the foundation is considered working.
      final container = await Level1TestHelper.setupTestEnvironment(tester);

      // Verify that the game engine has loaded the correct level
      final level = container.read(gameEngineProvider).currentLevel!;
      expect(level.title, 'Introduction to Circuits');
      expect(level.levelNumber, 1);

      // Verify a known component from level 1 exists
      final battery = Level1TestHelper.findComponentById(container, 'bat1');
      expect(battery, isNotNull);
      expect(battery!.type, ComponentType.battery);
    });

    testWidgets('TC-L1-01: Toggle switch interaction', (WidgetTester tester) async {
      final container = await Level1TestHelper.setupTestEnvironment(tester);
      
      final switchComponent = Level1TestHelper.findComponentById(container, 'switch1');
      expect(switchComponent, isNotNull, reason: "Switch 'switch1' should exist in level 1");
      expect(switchComponent!.type, ComponentType.sw);

      final initialSwitchClosed = Level1TestHelper.getSwitchState(switchComponent);
      
      await Level1TestHelper.tapComponent(
        tester, 
        Position(r: switchComponent.r, c: switchComponent.c),
      );
      await Level1TestHelper.waitForCircuitUpdate(tester);

      final newSwitchComponent = Level1TestHelper.findComponentById(container, 'switch1')!;
      final finalSwitchClosed = Level1TestHelper.getSwitchState(newSwitchComponent);
      
      expect(finalSwitchClosed, !initialSwitchClosed, reason: 'Switch state should toggle after tap.');
    });

    testWidgets('TC-L1-02: Move timer component', (WidgetTester tester) async {
      final container = await Level1TestHelper.setupTestEnvironment(tester);
      
      final timerComponent = Level1TestHelper.findComponentById(container, 'timer1');
      expect(timerComponent, isNotNull, reason: "Timer 'timer1' should exist in level 1");
      expect(timerComponent!.isDraggable, isTrue, reason: 'Timer should be draggable');

      final fromPos = Position(r: timerComponent.r, c: timerComponent.c);
      // Define a valid, empty position to move to.
      // Based on level_01.json, (3,2) is empty.
      const toPos = Position(r: 3, c: 2);
      
      await Level1TestHelper.dragComponent(tester, fromPos, toPos);
      await Level1TestHelper.waitForCircuitUpdate(tester);

      final movedComponent = Level1TestHelper.findComponentById(container, 'timer1')!;
      expect(Level1TestHelper.isComponentAtPosition(movedComponent, toPos), isTrue, reason: 'Timer should be at the new position after dragging.');
    });
  });
}
