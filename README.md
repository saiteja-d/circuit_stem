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

## Next Work: UI/UX Improvements from `stem_cir` Reference

Analysis of the `DOCS/stemcir_refference` project (`stem_cir`) reveals significant UI/UX enhancements that can be integrated into the main `circuit_stem` project. The `stem_cir` project showcases a more modern, visually engaging, and user-friendly design.

**Key Takeaways & Proposed Improvements:**

1.  **Main Menu (`lib/ui/screens/main_menu.dart`):**
    *   **Visuals:** Adopt the `LinearGradient` background, animated logo (rotation, scale), and button slide transitions from `stem_cir`'s `home_screen.dart`.
    *   **Content:** Replace the simple "Settings" button with richer "How to Play" (modal bottom sheet with structured instructions) and "About" (dialog with detailed info) sections.
    *   **Impact:** Transforms the app's first impression, making it more dynamic and informative. This will increase code complexity due to animations and richer UI elements.

2.  **Level Selection Screen (`lib/ui/screens/level_select.dart`):**
    *   **Layout:** Implement `CustomScrollView` with `SliverAppBar` for a dynamic, expanding header and a progress indicator showing level completion.
    *   **Level Cards:** Integrate the `LevelCard` widget (to be extracted from `stem_cir`'s `level_selection_screen.dart` into `lib/ui/widgets/level_card.dart`). This includes:
        *   Fade and slide animations for card entry.
        *   Hover/tap scale animations.
        *   Detailed visual feedback for locked, unlocked, and completed states (borders, checkmarks, icons).
        *   Display of level title and description on each card.
    *   **Integration with `LevelManager`:** Adapt the `LevelCard` and level selection logic to consume data from `circuit_stem`'s existing `LevelManager` via `Provider`, ensuring consistency and leveraging persistence.
    *   **Impact:** Significantly enhances visual appeal, user experience, and clarity of progress. This will increase code complexity due to advanced Flutter widgets and animations.

3.  **Game UI (Component Rendering & Layout):**
    *   **Dynamic Component Rendering:** Refactor component drawing in `lib/ui/canvas_painter.dart` to use a `CustomPainter` approach similar to `stem_cir`'s `_ComponentPainter`. This allows for:
        *   Programmatic drawing of components (lines, shapes) instead of relying solely on SVG assets.
        *   Dynamic visual feedback (e.g., wires changing color when powered, bulbs glowing) based on circuit state.
        *   Better theming integration (dark/light mode).
    *   **Game Screen Layout (`lib/ui/game_screen.dart`):**
        *   Implement a dynamic "Status bar" for immediate feedback on short circuits or level completion.
        *   Integrate `stem_cir`'s `ComponentPalette` for a dedicated, visually clear area for component selection and drag-and-drop.
        *   Consider context-sensitive tutorial overlays for new mechanics.
    *   **Drag-and-Drop:** Refactor component placement to use Flutter's idiomatic `Draggable` and `DragTarget` widgets.
    *   **Impact:** Transforms the core gameplay visual experience, making it more interactive, informative, and polished. This will be a major refactoring effort for the game's rendering and interaction system.

4.  **General UI/UX Principles:**
    *   **Animations:** Incorporate more subtle animations throughout the application for fluid transitions and responsive interactions.
    *   **Theming:** Review and update `lib/common/theme.dart` to adopt a more comprehensive `ColorScheme` and potentially dark mode support, aligning with `stem_cir`'s cohesive visual style.
    *   **Component Reusability:** Promote the creation of well-encapsulated, reusable UI widgets (like `LevelCard`).

**What NOT to take from `stem_cir` (Core Logic):**

*   **Circuit Simulation Logic:** The `LogicEngine` in `circuit_stem` (`lib/services/logic_engine.dart`) is significantly more robust, accurate, and well-designed for circuit simulation than `stem_cir`'s `CircuitSimulator`. It should be retained as is.
