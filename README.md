# Circuit STEM

![Circuit STEM Banner](https://user-images.githubusercontent.com/1296468/269848727-e3d72b33-5783-4043-80a7-051b5133a05c.png)

An engaging and educational puzzle game built with Flutter, designed to teach the fundamentals of electrical circuits in a fun, hands-on way.

---

## ✨ Features

*   **Interactive Puzzles:** Drag, drop, and rotate components to build working circuits.
*   **Real Logic:** A pure-Dart logic engine accurately simulates power flow, open circuits, and shorts.
*   **Level Progression:** Advance through a series of increasingly challenging levels, with progress saved automatically.
*   **Data-Driven:** Levels are loaded from simple JSON files, making it easy to add new content.
*   **Clean Architecture:** Built with a modular, service-oriented architecture for maintainability and scalability.

## � Changelog

### 2025-08-12

#### Code Structure and Organization
- **Removed**: Legacy MVP reference files to resolve analyzer conflicts
- **Fixed**: `LevelManager` class structure and organization
  - Removed duplicate class definitions
  - Fixed field declarations and access modifiers
  - Streamlined provider implementations
  - Added proper imports for Riverpod and SharedPreferences
- **Optimized**: Removed unused fields and improved code organization

## �🚀 Getting Started

1.  Ensure you have the Flutter SDK installed.
2.  Clone the repository:
    ```sh
    git clone https://github.com/your-username/circuit_stem.git
    ```
3.  Navigate to the project directory and install dependencies:
    ```sh
    cd circuit_stem
    flutter pub get
    ```
4.  Run the app:
    ```sh
    flutter run
    ```

## 🏛️ Architecture

The project follows a clean, modular architecture that separates logic, state management, and UI.

*   **Services (`/lib/services`):** Stateless, reusable services like the `LogicEngine` and `LevelManager`.
*   **Engine (`/lib/engine`):** The `GameEngine` orchestrates the state and rules for an active game session.
*   **Models (`/lib/models`):** Plain Dart objects representing the game's data, such as `Grid`, `Component`, and `LevelDefinition`.
*   **UI (`/lib/ui`):** Flutter widgets, screens, and `CustomPainter`s responsible for rendering the game state.

For a complete overview of the technical design, please see the **[Technical Requirements Document (TRD)](./DOCS/TRD.md)**.

## 📚 Documentation

This project is documented using the following standards. All documents can be found in the `/DOCS` directory.

*   **[📄 Business Requirements (BRD)](./DOCS/BRD.md):** High-level goals, vision, and scope of the project.
*   **[📄 Functional Requirements (FRD)](./DOCS/FRD.md):** Detailed descriptions of what the application does from a user's perspective.
*   **[📄 Technical Requirements (TRD)](./DOCS/TRD.md):** A deep dive into the technical architecture, components, and data flow.

## 🔮 Future Improvements and Refactoring

This section outlines potential areas for improving and refactoring the codebase. These are great opportunities for new contributors to get familiar with the project.

### 1. Consolidate State Management Approach

*   **Current Situation:** The project currently uses a mix of state management patterns. The `GameEngine` is a `ChangeNotifier`, but it's provided to the UI using a `StateNotifierProvider` in `lib/providers/game_provider.dart`.
*   **Suggestion:** To make the state management more consistent and easier to understand, we should refactor this to use a `ChangeNotifierProvider` for the `GameEngine`. This aligns better with the `GameEngine`'s design and simplifies the provider setup.
*   **File to look at:** `lib/providers/game_provider.dart`

### 2. Enhance Error Handling in `LevelManager`

*   **Current Situation:** The `LevelManager` has basic error handling. If a level fails to load, it sets a generic error message.
*   **Suggestion:** We should make the error handling more robust and user-friendly. For example, if a specific level's JSON file is missing or corrupt, the UI should display a specific message (e.g., "Error loading Level 5. Please try again.") and potentially offer a "Retry" button.
*   **File to look at:** `lib/services/level_manager.dart`

### 3. Refactor `AssetManager` for Single Responsibility

*   **Current Situation:** The `AssetManager` is currently responsible for both *loading* assets (images, audio) and *drawing* some of the component assets to a canvas.
*   **Suggestion:** To follow the Single Responsibility Principle, we should refactor the `AssetManager`. The drawing logic should be extracted into a separate class, for example, a `ComponentPainter`. This would make the `AssetManager` solely responsible for loading and caching, leading to cleaner, more modular code.
*   **File to look at:** `lib/common/asset_manager.dart`

### 4. Centralize Constants and Remove Hardcoded Values

*   **Current Situation:** There are some "magic numbers" (hardcoded values) in the UI code, for example, the width of the component palette in `GameScreen`.
*   **Suggestion:** All hardcoded values should be replaced with constants defined in a central place, like `lib/common/constants.dart`. This makes the code easier to maintain and avoids inconsistencies.
*   **File to look at:** `lib/ui/game_screen.dart`

### 5. Implement Persistent Tutorial State

*   **Current Situation:** The `GameScreen` shows a tutorial overlay, but it doesn't remember if the user has seen it before.
*   **Suggestion:** We should use `shared_preferences` to save a flag indicating that the user has completed the tutorial for a specific level. This way, the tutorial is only shown the very first time a user plays a level, making for a better user experience.
*   **File to look at:** `lib/ui/game_screen.dart`

### 6. Ensure Consistent Use of Immutable Models

*   **Current Situation:** The project uses the `freezed` package for some of its models, which is great for ensuring immutability. However, not all models use it.
*   **Suggestion:** We should audit all the classes in the `lib/models` directory and ensure that any data class that would benefit from immutability is implemented using `freezed`. This makes our state more predictable and prevents accidental mutations.
*   **Files to look at:** The `lib/models` directory.

---

*This README was updated to reflect the new modular architecture. The previous, highly-detailed content was split into the formal documents linked above.*

---

## Changelog

### 2025-08-12 9 pm EST

This is a major stabilization and modernization update that completes a previously unfinished architectural refactoring. The result is a more robust, stable, and maintainable codebase aligned with modern Flutter best practices.

**Key Changes:**

*   **Architectural Refactoring:**
    *   **State Management:** Solidified the migration to a `StateNotifier` and Riverpod-based architecture. Removed legacy provider files and ensured a consistent, unidirectional data flow.
    *   **Immutability:** Refactored core data models (`LevelMetadata`) to be immutable using the `freezed` package, improving state predictability and safety.
    *   **Services:** Corrected the `AssetManager` service to use the modern `flutter_svg` v2 API for high-performance SVG caching.

*   **Bug Fixes & Stability:**
    *   Resolved dozens of analyzer errors caused by the incomplete refactoring, including incorrect widget constructors, broken import paths, type mismatches, and null-safety issues across the entire UI layer.
    *   Fixed logic errors in widgets like `CircuitGrid` and `CanvasPainter`.

*   **Documentation Overhaul:**
    *   Updated all core technical documents (`Architecture.md`, `CodeExecutionFlow.md`, `TRD.md`) to accurately reflect the new `StateNotifier` architecture, removing misleading and obsolete information.
    *   Added new sections explaining architectural principles and best practices for testing.
    *   Corrected file paths and minor inaccuracies in `ASSETS.md` and `TESTING.md`.
    *   Added timestamps to all updated documents.

### 2025-08-12 16:55:59 EDT

### 2025-08-12: Codebase Refactoring and Simplification

This update focuses on a major refactoring of the codebase to improve maintainability, reduce redundancy, and establish a single source of truth for the application's data models and UI components.

**Key Changes:**

*   **Model Consolidation:**
    *   The `Goal` and `LevelGoal` models have been merged into a single, consistent `Goal` class.
    *   The `Position` and `BlockedCell` models have been consolidated, with `Position` now being used throughout the application.
*   **Component Model Unification:**
    *   The legacy `CircuitComponent` model has been removed.
    *   The entire application now uses the more robust and feature-rich `ComponentModel`.
*   **UI and Widget Cleanup:**
    *   The duplicated `CircuitGrid` and `CircuitComponentWidget` widgets have been removed.
    *   The UI has been updated to use the single, canonical set of widgets, ensuring a consistent user experience and a more maintainable codebase.

### 2025-08-12: State Management Refactor & Feature Enhancements

This update introduces a more robust state management system and several feature enhancements to improve gameplay and progression.

**Key Changes:**

*   **State Management Overhaul:** Refactored the core game state management to use `StateNotifierProvider` with a new `GameEngineNotifier`. This provides a more robust and scalable pattern for managing game state.
*   **Persistent Level Progression:** The `LevelManager` can now track completed levels and save the progress. When a level is completed, the next level is automatically unlocked.
*   **Enhanced Game Models:** The `LevelDefinition` and `LevelMetadata` models have been updated with more descriptive fields.
*   **Improved Audio Feedback:** The `AudioService` has been enhanced with new methods for more specific audio cues.
*   **Dependency Updates:** Updated `flutter_riverpod`, `hooks_riverpod`, and `riverpod` to the latest versions to leverage new features and performance improvements.

### 2025-08-12: Architectural Improvements and UI/UX Refinements

This update focuses on enhancing the game's underlying architecture, improving state management, and refining the user experience through targeted UI/UX adjustments.

**Key Changes:**

*   **Enhanced Level Management:** Implemented a robust system for tracking completed levels, providing persistent player progress. Improved error handling for level loading operations ensures a more stable experience.
*   **Improved Code Architecture:** Refactored `CanvasPainter` to utilize dependency injection for `AssetManager`, promoting modularity, testability, and adherence to best practices.
*   **Streamlined UI Flow:** Optimized navigation and level loading logic. The `GameScreen` is now simplified, with `LevelManager` handling complex loading processes. The level selection screen offers clearer error feedback, and the main menu features a smoother screen transition.

### 2025-08-12: UI/UX Overhaul from `stem_cir` Reference

This update integrates significant UI/UX enhancements inspired by the `stem_cir` reference project, focusing on creating a more modern, engaging, and user-friendly experience.

**Key Changes:**

*   **Revamped Main Menu:** The main menu now features a `LinearGradient` background, an animated logo, and slide transitions for buttons. It also includes "How to Play" and "About" sections.
*   **Dynamic Level Selection:** The level selection screen has been rebuilt with a `CustomScrollView` and `SliverAppBar` for a more dynamic layout. It now uses animated `LevelCard` widgets to display level information.
*   **Interactive Game Screen:** The game screen has been enhanced with a `ComponentPalette` for dragging and dropping components, a status bar for immediate feedback, and improved component rendering with a `CustomPainter`.
*   **New UI Components:** Added several new widgets, including `LevelCard`, `ComponentPalette`, and `CircuitGrid`, to support the new UI.
*   **Improved Theming:** The app's theme has been updated with a more comprehensive `ColorScheme`.

### 2025-08-11: Major Refactoring & Simplification

The project underwent a significant refactoring to simplify its architecture, remove redundant code, and improve maintainability.

**Key Changes:**

*   **Unified Asset Management:** The `AssetManager` is now fully self-contained. The separate `FlamePreloader` class was merged into it, and the abstract `Preloader` interface was removed. This simplifies the app's startup sequence in `main.dart`.
*   **Streamlined Services:**
    *   The `FlameAdapter` was refactored into a dedicated `AudioService` and moved to the `lib/services` directory.
    *   Redundant or unused services (`SoundService`, `PersistenceService`) were removed.
*   **Code Deletion and Cleanup:**
    *   **Models:** Deleted the deprecated `cell.dart` and the unnecessary `ComponentFactory`.
    *   **Widgets:** Removed unused widgets `LevelCard` and `RoundedButton`.
    *   **Placeholders:** Deleted several empty or placeholder component files.
    *   **Directories:** Removed the `flame_integration`, `flame_components_optional` and `game/components` directories after their contents were refactored or deleted.


    ### 2025-08-11: Major Refactoring & Simplification

The project underwent a significant refactoring to simplify its architecture, remove redundant code, and improve maintainability.

**Key Changes:**

*   **Unified Asset Management:** The `AssetManager` is now fully self-contained. The separate `FlamePreloader` class was merged into it, and the abstract `Preloader` interface was removed. This simplifies the app's startup sequence in `main.dart`.
*   **Streamlined Services:**
    *   The `FlameAdapter` was refactored into a dedicated `AudioService` and moved to the `lib/services` directory.
    *   Redundant or unused services (`SoundService`, `PersistenceService`) were removed.
*   **Code Deletion and Cleanup:**
    *   **Models:** Deleted the deprecated `cell.dart` and the unnecessary `ComponentFactory`.
    *   **Widgets:** Removed unused widgets `LevelCard` and `RoundedButton`.
    *   **Placeholders:** Deleted several empty or placeholder component files.
    *   **Directories:** Removed the `flame_integration`, `flame_components_optional` and `game/components` directories after their contents were refactored or deleted.

---

## Changelog