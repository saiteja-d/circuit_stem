# Architecture & UI Design

**Project:** Circuit STEM
**Last Updated:** 2025-08-12 EST

---

This document provides visual diagrams of the system architecture, data flow, and UI layout to complement the code-level details in the TRD.

## 1. Architectural Principles

This project follows a modern, reactive architecture based on a few core principles:

*   **State Management (Riverpod & StateNotifier):** All complex view state is managed by `StateNotifier` classes, which are provided to the UI using `StateNotifierProvider` from the `flutter_riverpod` package. This pattern is preferred for its compile-time safety, testability, and for enforcing a unidirectional data flow with immutable state objects.

*   **Immutability (`freezed`):** All state and data model classes are immutable. We use the `freezed` package to generate boilerplate-free, immutable data classes. This prevents entire classes of bugs caused by accidental state mutation and makes state changes predictable and easy to debug.

*   **Dependency Injection (Riverpod):** All services and providers are exposed to the application via Riverpod. This decouples our UI from our business logic, improves testability, and allows services to be easily mocked or replaced.

## 2. System Architecture Diagram

This diagram shows the high-level relationship between the primary layers of the application.

```
+--------------------+ watches +---------------------------------+
|  Flutter UI Layer  | ------> | Riverpod StateNotifierProvider  | --provides--+ GameEngineNotifier              |
|  (GameCanvas, HUD) |         | (in lib/core/providers.dart)    |             | (StateNotifier<GameEngineState>) |
|  - Rebuilds on     |         +---------------------------------+             | - Manages Grid State            |
|    new State       |                                                       | - Processes Actions             |
+--------------------+                                                       +---------------------------------+
         ^                                                                                    |
         |                                                                                    v
         | receives input                                                                     | calls
         |                                                                                    |
+--------------------+                                                       +---------------------------------+
| User Input         |                                                       | LogicEngine (Pure Dart)         |
| (Tap, Drag)        |                                                       | - Evaluates Circuit             |
+--------------------+                                                       +---------------------------------+

```

## 3. Detailed Integration Diagram (State Update Flow)

This diagram illustrates how user input leads to a new state and a UI update.

```
[User] -> [GameCanvas (UI)]
   -> calls methods on GameEngineNotifier (e.g., handleTap(), endDrag())
      -> GameEngineNotifier creates a new, updated GameEngineState object
         -> It may call LogicEngine.evaluate(grid) to get data for the new state
            -> returns EvaluationResult
         <- GameEngineNotifier incorporates the result into the new state
      <- GameEngineNotifier updates its state via `state = newState;`

[Riverpod] -> detects a new state has been emitted
   -> Notifies all listening widgets

[GameCanvas (via ref.watch)] -> receives the new GameEngineState and rebuilds
   -> CanvasPainter receives new RenderState and redraws the frame
```

## 4. UI Layout & Interaction

### Screen Layout

The application features three primary screens, each designed for intuitive interaction and visual appeal:

*   **Main Menu (`lib/ui/screens/main_menu.dart`):**
    *   Features a dynamic `LinearGradient` background.
    *   Includes an animated app logo and buttons with slide transitions.
    *   Provides access to "How to Play" instructions (via a modal bottom sheet) and "About" information (via a dialog).

*   **Level Selection Screen (`lib/ui/screens/level_select.dart`):**
    *   Utilizes a `CustomScrollView` with a `SliverAppBar` for a dynamic, expanding header.
    *   Displays levels using animated `LevelCard` widgets in a grid layout, showing lock/completion status and level details.
    *   Includes a progress indicator to show overall level completion.

*   **Game Screen (`lib/ui/game_screen.dart`):**
    *   Features a dynamic "Status bar" at the top for immediate feedback (e.g., short circuits, level completion).
    *   Integrates a `ComponentPalette` for easy drag-and-drop component selection.
    *   The main game area (`GameCanvas`) renders the circuit grid and components.
    *   Components are drawn programmatically, allowing for dynamic visual feedback (e.g., wires changing color when powered, bulbs glowing).

### Interaction Details

*   **Grid & Snapping:** The game is played on a logical grid (e.g., 6x6). All components snap to the center of the grid cells.
*   **Touch Targets:** The logical size of each cell is designed to be large enough (e.g., `64x64` logical pixels) to be easily tappable on mobile devices.
*   **Drag & Drop:** Users can drag movable components. A semi-transparent preview of the component follows the user's finger. When the gesture ends, the component snaps to the nearest valid grid cell.
*   **Tapping:** Tapping on an interactive component like a switch toggles its state instantly.

### Visual States

*   **Bulb:** Has distinct visual states for `off` and `on`. The `on` state includes a subtle pulsing glow driven by the `AnimationScheduler`.
*   **Wires:** Have distinct visual states for `powered` and `unpowered`. The `powered` state includes an animated "flow" effect, also driven by the `AnimationScheduler`.
*   **Switch:** Has two distinct visuals for its `open` and `closed` states.
