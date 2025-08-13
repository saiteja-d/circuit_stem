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