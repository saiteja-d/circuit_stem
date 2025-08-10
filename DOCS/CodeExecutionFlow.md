
# Code Execution Flow

**Project:** Circuit STEM

---

This document provides a step-by-step narrative of how the application executes, from the initial launch to a complete gameplay loop. It is designed to help developers trace the flow of logic and data through the architecture.

## 1. Application Startup

1.  **`main.dart`**: Execution begins here.
    -   `WidgetsFlutterBinding.ensureInitialized()` prepares the Flutter framework.
    -   `Flame.device` is used to set the screen to landscape mode.
    -   An instance of `AssetManager` is created.
    -   A `FlamePreloader` is passed to the `AssetManager`, which then calls `loadAllAssets()` to pre-load all critical images and audio into memory before the app displays anything. This prevents stutter during gameplay.
    -   `runApp(const App())` inflates the root widget.

2.  **`app.dart`**: The `App` widget builds the `MaterialApp`.
    -   It sets the global theme, title, and initial route (`/`).
    -   Crucially, it assigns `AppRoutes.onGenerateRoute` to handle all named navigation.

## 2. Navigating to the Game

1.  **`routes.dart`**: The initial route `/` is mapped to `MainMenuScreen`.

2.  **`ui/screens/main_menu.dart`**: The user sees the main menu.
    -   When the user taps "Start Game", `Navigator.of(context).pushNamed(AppRoutes.levelSelect)` is called.

3.  **`ui/screens/level_select.dart`**: The level selection grid is displayed.
    -   When the user taps on an unlocked level (e.g., Level 1), `Navigator.of(context).pushNamed(AppRoutes.gameScreen, arguments: 'level_01')` is called. The level ID is passed as an argument.

## 3. Initializing the Game Screen

This is the most critical part of the setup, where all services and controllers are initialized.

1.  **`routes.dart`**: The `/game` route is mapped to the `GameScreen` widget, passing along the `levelId`.

2.  **`ui/game_screen.dart`**: The `GameScreen` widget's `build` method is executed.
    -   A `MultiProvider` is created to provide services to all descendant widgets.
        -   `ChangeNotifierProvider(create: (_) => LevelManager())`: Creates the `LevelManager`. Its constructor immediately starts loading `level_manifest.json` and the user's saved progress from `shared_preferences`.
        -   `ChangeNotifierProvider(create: (_) => DebugOverlayController())`: Creates the controller for the debug UI.
    -   A `Consumer<LevelManager>` listens to the `LevelManager`. While the manager is loading the manifest (`levelManager.isLoading`), it displays a `CircularProgressIndicator`.
    -   Once loading is complete, the `Consumer` rebuilds and now has the level data. It creates the final piece of the architecture:
        -   `ChangeNotifierProvider(create: (ctx) => GameEngine(...))`: An instance of `GameEngine` is created. The crucial `LevelDefinition` for the current level is passed to it from the `levelManager`.

## 4. The Gameplay Loop

Once the `GameEngine` is provided, the main gameplay UI (`_GameScreenContent`) is built.

1.  **The Ticker (`ui/game_canvas.dart`)**:
    -   `GameCanvas` is a `StatefulWidget` that creates a `Ticker`.
    -   On every screen refresh (typically 60 times per second), the ticker calls `gameEngine.update(dt)`, where `dt` is the delta time since the last frame.

2.  **Engine Update (`engine/game_engine.dart`)**:
    -   The `update()` method first checks if the game is paused. If so, it does nothing.
    -   It calls `_animationScheduler.tick(dt)` to advance the timers for visual effects like bulb pulsing.
    -   It then calls `_evaluateAndUpdateRenderState()`.

3.  **Evaluation (`services/logic_engine.dart`)**:
    -   `_evaluateAndUpdateRenderState()` calls `logicEngine.evaluate(grid)`.
    -   The `LogicEngine` builds the circuit graph and runs its BFS algorithm to determine which components are powered.
    -   It returns a comprehensive `EvaluationResult` object.

4.  **State Update & Re-render (`engine/game_engine.dart` -> `ui/canvas_painter.dart`)**:
    -   The `GameEngine` uses the `EvaluationResult` to create a new `RenderState` snapshot.
    -   It calls the `onEvaluate` callback, which the `DebugOverlayController` listens to.
    -   It checks for a win condition.
    -   Finally, it calls `notifyListeners()`.

5.  **Painting the Frame (`ui/game_canvas.dart`)**:
    -   The `Consumer<GameEngine>` in `GameCanvas` hears the notification and rebuilds.
    -   It passes the new `renderState` to the `CanvasPainter`.
    -   The `CanvasPainter`'s `paint()` method executes, drawing the grid, wires, bulbs, and all other components exactly as defined in the `RenderState` snapshot.

This entire loop, from ticker to paint, happens on every frame, creating the illusion of animation and immediate feedback.

## 5. Winning a Level

1.  In the `_evaluateAndUpdateRenderState` method, after getting a new `EvaluationResult`, the `_checkWinCondition` method is called.
2.  It determines that all goals for the level are met.
3.  The `onWin` callback, which was passed into the `GameEngine` from `GameScreen`, is executed.
4.  This callback calls `levelManager.completeCurrentLevel()`.
5.  The `LevelManager` unlocks the next level and saves the new list of unlocked levels to `shared_preferences`.
6.  Simultaneously, the `gameEngine.isWin` flag is set to `true`, and `notifyListeners()` is called.
7.  Back in `game_screen.dart`, the UI rebuilds, and because `gameEngine.isWin` is true, the `WinScreen` overlay is now displayed.
