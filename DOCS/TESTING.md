# Comprehensive Testing Strategy

**Project:** Circuit STEM
**Last Updated:** 2025-08-14 9PM EST

---

This document outlines the comprehensive testing strategy for the Circuit STEM project. It includes a master list of test cases for Level 1, which will serve as a template for testing other levels, and a plan for achieving full test coverage.

## 1. Testing Principles

Our testing strategy is based on the following principles:

*   **Comprehensiveness:** We aim to test all aspects of the application, including the functional requirements, the user interface, and the user experience.
*   **Automation:** We will automate as much of the testing process as possible using Flutter's testing framework.
*   **Modularity:** We will write modular tests that are easy to read, understand, and maintain.
*   **Consistency:** We will use a consistent testing strategy across all levels of the application.

## 2. Level 1 – Comprehensive Circuit Test Cases

This table provides a comprehensive list of test cases for Level 1. It covers the core circuit logic, interaction constraints, visual feedback, audio feedback, responsiveness, and user experience.

| **Test Case ID** | **Scenario**                  | **User Action**                                           | **Expected Outcome**                                           |
| :--- | :--- | :--- | :--- |
| **TC-L1-01**     | Toggle switch                 | Tap `switch1`                                             | Switch toggles open/closed; visual state changes.              |
| **TC-L1-02**     | Move bulb                     | Drag `bulb1` to valid grid position                       | Bulb moves; snaps to grid.                                     |
| **TC-L1-03**     | Move timer                    | Drag `timer1` to valid grid position                      | Timer moves; snaps to grid.                                    |
| **TC-L1-04**     | Try moving battery            | Drag `bat1`                                               | No movement occurs.                                            |
| **TC-L1-05**     | Try moving switch             | Drag `switch1`                                            | No movement occurs.                                            |
| **TC-L1-06**     | Invalid placement             | Drag movable component onto occupied tile or outside grid | Component returns to original position; warning sound plays.   |
| **TC-L1-07**     | Partial circuit               | Arrange incomplete circuit                                | Bulb remains off; timer inactive.                              |
| **TC-L1-08**     | Complete circuit (no timer)   | Closed circuit without timer                              | Bulb lights; timer inactive.                                   |
| **TC-L1-09**     | Complete circuit with timer   | Closed circuit including timer                            | Bulb lights; timer activates.                                  |
| **TC-L1-10**     | All goals met                 | Closed circuit, switch closed, bulb lit, timer active     | Game enters win state; victory animation/message appears.      |
| **TC-L1-11**     | Hint visibility               | Start level                                               | Ghost wire visible until circuit complete, then disappears.    |
| **TC-L1-12**     | Switch break test             | Break circuit after win                                   | Bulb turns off; timer stops; win state canceled if applicable. |
| **TC-L1-13**     | Grid snap feedback            | Drag component near grid boundary                         | Preview “snap” position shown before release.                  |
| **TC-L1-14**     | Drag cancel                   | Drag component, release outside grid                      | Component returns to original position with animation.         |
| **TC-L1-15**     | Overlap highlight             | Drag onto occupied tile                                   | Target tile highlights red; placement rejected.                |
| **TC-L1-16**     | Switch visual state           | Toggle `switch1`                                          | Switch graphic updates (icon or animation).                    |
| **TC-L1-17**     | Bulb lit visual               | Complete closed circuit                                   | Bulb glow animation plays.                                     |
| **TC-L1-18**     | Timer running visual          | Timer in circuit                                          | Timer digits animate and increment.                            |
| **TC-L1-19**     | Timer stopped visual          | Break circuit with active timer                           | Timer freezes at last value.                                   |
| **TC-L1-20**     | Hint ghost wire fade          | Complete correct path                                     | Ghost wire fades out smoothly.                                 |
| **TC-L1-21**     | Component selection highlight | Long press movable component                              | Component highlights/scales to show selection.                 |
| **TC-L1-22**     | Placement sound               | Place in valid position                                   | Placement sound plays once.                                    |
| **TC-L1-23**     | Invalid placement sound       | Invalid drop                                              | Error/warning sound plays.                                     |
| **TC-L1-24**     | Tap accuracy                  | Tap edges of small component                              | Tap still registers if within visible bounds.                  |
| **TC-L1-25**     | Mobile responsiveness         | Rotate screen during play                                 | Layout repositions correctly; component positions preserved.   |
| **TC-L1-26**     | Goal tracker update           | Achieve partial goal                                      | Goal checklist updates in real time.                           |
| **TC-L1-27**     | Win animation                 | Win level                                                 | Victory animation plays; “Next Level” button appears.          |
| **TC-L1-28**     | Restart level                 | Tap restart mid-game                                      | Level resets to starting positions/states.                     |
| **TC-L1-29**     | Undo last move                | Tap undo after moving component                           | Component returns to previous position.                        |
| **TC-L1-30**     | Switch spam prevention        | Rapidly tap `switch1`                                     | Extra taps ignored until animation completes.                  |
| **TC-L2-01**     | Rotate wire                   | Tap `wire_rotatable`, then tap rotate button              | Wire rotates by 90 degrees; visual state changes.              |

## 3. Next Steps to Achieve Full Test Coverage

To achieve full test coverage for Level 1 and beyond, we will follow these steps:

1.  **Create a Test Plan:** For each level, we will create a test plan that is based on the master list of test cases in this document. The test plan will be a markdown file in the `test/plans` directory.

2.  **Simulate Gestures by Coordinate:** The game grid is rendered by a `CustomPainter`, not by individual widgets. Therefore, tests must simulate user interactions by calculating the pixel coordinates of a grid cell and using the `WidgetTester`'s gesture methods (e.g., `tester.tapAt(position)`). Other interactive UI elements outside the canvas (like buttons) should have `Key`s added to them for easy discovery.

3.  **Implement the Test Suite:** We will create a new test file for each level (e.g., `test/ui/level_01_interaction_test.dart`) and implement the test cases in the test plan.

4.  **Prioritize Bug Fixes:** We will prioritize the implementation of test cases that are most likely to help us find and fix bugs.

5.  **Continuously Integrate:** We will integrate the tests into our CI/CD pipeline to ensure that they are run automatically on every commit.

By following this plan, we can build a comprehensive and robust suite of automated tests that will help us to improve the quality of the Circuit STEM project and to ensure that it provides a great user experience.

## Known Testing Issues (as of 2025-08-14 9PM EST)

During recent debugging efforts, several critical issues impacting test compilation and execution were identified:

*   **Persistent Test Compilation Error:** Tests consistently fail to compile with `Error: Type 'Component' not found` in `test/helpers/level_01_test_helper.dart`. This issue remains unresolved despite extensive debugging, project cleaning (`flutter clean`), and repeated verification of import statements. This indicates a deeper problem with how the test environment resolves package imports.
*   **macOS Build Environment Issue:** The macOS application build and test execution are blocked by a missing `xcodebuild` utility. This is a system-level configuration issue (missing Xcode command-line tools) that needs to be addressed by running `xcode-select --install`.
*   **Outdated Package Dependencies:** The project has 26 packages with newer versions incompatible with current dependency constraints. While not directly causing the compilation error, this can lead to instability and should be addressed by running `flutter pub outdated` and updating `pubspec.yaml`.

---

## Legacy Testing Notes

This section contains the previous version of the testing documentation for historical reference.

# Testing Strategy

**Project:** Circuit STEM
**Last Updated:** 2025-08-12 EST

---

This document outlines the testing philosophy, strategy, and procedures for the Circuit STEM project.

## 1. Testing Philosophy

Our testing strategy is based on the principle of the "Testing Pyramid." We prioritize fast, isolated tests and use slower, more integrated tests more sparingly.

-   **Unit Tests (High Priority):** Core logic, especially the `LogicEngine`, should be covered extensively by unit tests. These tests are fast, stable, and ensure the fundamental rules of the game are correct.
-   **Widget Tests (Medium Priority):** Core UI components and user interactions should be covered by widget tests. This ensures that tapping, dragging, and other gestures correctly trigger state changes in the `GameEngineNotifier`.
-   **Integration Tests (Low Priority):** A few key user flows should be covered by integration tests. These are the slowest and most brittle tests but are valuable for ensuring that all the different parts of the application work together correctly.

## 2. How to Run Tests

All automated tests can be run from the root of the project directory.

```sh
# Run all unit and widget tests
flutter test

# Run a specific test file
flutter test test/services/logic_engine_test.dart
```

## 3. Where to Add New Tests

-   **New Logic Engine Feature:** If you add a new rule, component behavior, or edge case to the `LogicEngine`, a corresponding unit test **must** be added in `test/services/logic_engine_test.dart`.
-   **New UI Widget/Interaction:** If you create a new interactive widget, a widget test should be added in the `test/ui/widgets/` directory to verify its behavior.
-   **New Service/Controller:** Any new service or `StateNotifier` controller should have its own unit test file in the appropriate `test/` subdirectory.

## 4. Testing with Riverpod

To test a widget that depends on a Riverpod provider, you should wrap the widget in a `ProviderScope` and override the necessary providers with mock instances for the test.

**Example: Testing a widget that uses `gameEngineProvider`**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

// 1. Create mock versions of your notifier and its state
class MockGameEngineNotifier extends Mock implements GameEngineNotifier {}
class MockGameEngineState extends Mock implements GameEngineState {}

void main() {
  testWidgets('MyWidget shows a win state correctly', (tester) async {
    // 2. Create an instance of your mock notifier
    final mockNotifier = MockGameEngineNotifier();

    // 3. Stub the state of the mock notifier
    when(() => mockNotifier.state).thenReturn(
      GameEngineState(isWin: true, ...), // Provide a mock state
    );

    // 4. Pump the widget inside a ProviderScope with an override
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          gameEngineProvider.overrideWithValue(mockNotifier),
        ],
        child: MaterialApp(home: MyWidget()),
      ),
    );

    // 5. Verify the UI reflects the mocked state
    expect(find.text('You Win!'), findsOneWidget);
  });
}
```

## 5. Current Test Coverage

-   **`LogicEngine`**: This is the most critical component for testing. The goal is to maintain near 100% test coverage for its evaluation logic.
-   **Models & Grid**: The data models and `Grid` class are tested to ensure component placement, collision detection, and validation work as expected.
-   **UI/Widgets**: Key widgets are tested to ensure they respond correctly to state changes from their providers. Note: The recent UI/UX overhaul has introduced several new widgets and significantly modified existing ones. Comprehensive widget tests for these new and updated UI components are crucial and should be prioritized.