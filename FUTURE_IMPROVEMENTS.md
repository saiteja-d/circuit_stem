# Future Improvements & Project Roadmap

**Last Updated:** 2025-08-14

This document outlines the recommended next steps and potential future improvements for the `circuit_stem` project. It is based on the project's own documentation, code analysis, and established Flutter development best practices.

## 1. Testing & Quality Assurance

**Status:** **IN PROGRESS**. A major effort to stabilize the test suite has been completed, but a final `TimeoutException` issue persists in the main level 1 test.

### 1.1. Resolve Final Test Timeout

-   **Action:** The immediate priority is to resolve the final `TimeoutException` in `test/level_01_revised_test.dart`. The new testing architecture is documented in `REVISED_TESTING_ARCHITECTURE.md`.
-   **Next Steps:** Follow the recommendations outlined in `DOCS/LEVEL_01_DEBUG_REPORT.md`, which include creating a minimal, reproducible example to isolate the root cause of the timeout.

### 1.2. Expand Test Coverage

-   **Rationale:** Once the testing foundation is stable, coverage must be expanded.
-   **Action: Test StateNotifiers & UI Widgets:** Following the patterns in `REVISED_TESTING_ARCHITECTURE.md`, create new tests for all major `StateNotifier` classes and UI widgets to ensure they render all possible states correctly (e.g., loading, error, win-state).

## 2. Code Refactoring & Architecture

**Status:** High Priority. The project's architecture is strong, but completing the planned refactoring will improve consistency and maintainability.

### 2.1. Complete Immutability Migration

-   **Rationale:** A "pending improvement" noted in the `CHANGELOG.md`. Universal immutability is a core principle of the new architecture.
-   **Action:** Audit the `lib/models/` directory. Convert any remaining plain Dart classes to immutable classes using the `freezed` package and ensure all `copyWith` methods are utilized correctly in the notifiers.

### 2.2. Refactor Large Methods

-   **Rationale:** Another "pending improvement" from the `CHANGELOG.md`. Smaller, single-purpose methods are easier to read, test, and maintain.
-   **Action:** In `GameEngineNotifier` and `CanvasPainter`, identify methods that handle multiple distinct responsibilities. Refactor them into smaller, well-named private methods. For example, a large `handleTap` method could be broken down into `_getTappedComponent`, `_toggleComponentState`, and `_re_evaluateGrid`.

### 2.3. Modernize Riverpod Usage (Future Consideration)

-   **Rationale:** Web best practices indicate a shift in the Riverpod community from `StateNotifier` to the newer `Notifier` and `AsyncNotifier` providers due to their simpler API and more powerful features.
-   **Action:** This is not an urgent change. However, for any *new* providers created, prefer using `NotifierProvider` or `AsyncNotifierProvider`. A gradual migration of existing `StateNotifier`s can be considered in the long term.

## 3. Error Handling

**Status:** High Priority. This is explicitly listed as a "Next Priority" in the `CHANGELOG.md`.

### 3.1. Implement the `Result` Type

-   **Rationale:** Using an explicit `Result` or `Either` type (from packages like `fpdart`) makes error handling robust and predictable, preventing unexpected runtime exceptions.
-   **Action:**
    1.  Refactor `LevelManager` methods like `loadLevelByIndex` to return `Future<Result<LevelDefinition, Exception>>` instead of `Future<LevelDefinition>`.
    2.  Update the call sites in the UI layer to handle the `Result` type. This typically involves using a `when` or `fold` method to explicitly define the UI for both the success and failure cases (e.g., showing a `SnackBar` or an error message if a level fails to load).
    3.  Extend this pattern to other services involving I/O, such as file operations or future network calls.

## 4. Performance Optimization

**Status:** Medium Priority. These are valuable improvements that can be implemented incrementally.

### 4.1. Apply Static Analysis Fixes

-   **Rationale:** The `CHANGELOG.md` notes 16 remaining `prefer_const_constructors` warnings. These are easy performance wins.
-   **Action:** Run `dart fix --apply` or manually add the `const` keyword where suggested by the analyzer. This reduces widget rebuilds.

### 4.2. Use `RepaintBoundary`

-   **Rationale:** The `TRD.md` and general Flutter best practices recommend this for isolating complex animations.
-   **Action:** Wrap the `GameCanvas` widget in a `RepaintBoundary` widget. This ensures that the frequent repaints of the canvas do not trigger unnecessary repaints of other UI elements like the app bar or component palette.
