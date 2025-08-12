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

## 🚀 Getting Started

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

---

*This README was updated to reflect the new modular architecture. The previous, highly-detailed content was split into the formal documents linked above.*

---

## Changelog

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
