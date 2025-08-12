
# Architecture & UI Design

**Project:** Circuit STEM

---

This document provides visual diagrams of the system architecture, data flow, and UI layout to complement the code-level details in the TRD.

## 1. System Architecture Diagram

This diagram shows the high-level relationship between the primary layers of the application.

```
+--------------------+        +---------------------+        +-------------------+
|  Flutter UI Layer  | <----> |   GameEngine        | <----> |   LogicEngine     |
|  (GameCanvas, HUD) |        |  (Stateful Notifier)|        |   (Pure Dart)     |
|  - Renders State   |        |  - Manages Grid     |        | - BFS Evaluation  |
|  - Handles Input   |        |  - Processes Actions|        | - Short Detection |
+--------------------+        +---------------------+        +-------------------+
         ^                                      ^
         |                                      |
         | listens to                           | receives data from
         |                                      |
+--------------------+        +---------------------+ 
| UI Controllers     |        |   Services          |
| (Debug, etc.)      |        |   (LevelManager)    |
+--------------------+        +---------------------+ 
```

## 2. Detailed Integration Diagram

This diagram illustrates how the core components interact with each other.

```
[User] -> [GameCanvas (UI)]
   -> calls GameEngine.handleTap() or .endDrag()
      -> GameEngine updates Grid model
         -> GameEngine calls LogicEngine.evaluate(grid)
            -> returns EvaluationResult
         <- GameEngine creates RenderState from result
         <- GameEngine calls onEvaluate() callback for DebugOverlayController
      <- GameEngine calls notifyListeners()
   <- GameCanvas (via Consumer) rebuilds
      -> CanvasPainter receives new RenderState and redraws
```

## 3. UI Layout & Interaction

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
