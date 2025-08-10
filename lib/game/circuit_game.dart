import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import '../models/grid.dart';
import '../models/component.dart' as model;
import '../models/level_definition.dart';
import '../services/level_loader.dart';
import '../services/logic_engine.dart';
import 'components/comp_battery.dart';
import 'components/comp_bulb.dart';
import 'components/comp_wire.dart';
import 'components/comp_switch.dart';
import 'components/game_component.dart';

/// The main game class for the circuit puzzle game.
/// 
/// This class manages game state, loading levels, components on a grid,
/// and handles user interactions such as dragging components,
/// toggling switches, and game evaluation logic.
class CircuitGame extends FlameGame
    with HasCollisionDetection, TapCallbacks, DragCallbacks {
  /// Optional level identifier to load a specific level.
  final String? levelId;

  /// Loaded level definition containing grid and components data.
  late final LevelDefinition levelDefinition;

  /// The grid representing the circuit board layout.
  late final Grid grid;

  /// Overlay component shown when a short circuit is detected.
  late final RectangleComponent shortCircuitOverlay;

  /// The logic engine for evaluating the circuit state.
  final LogicEngine logicEngine = LogicEngine();

  /// Indicates whether the game update loop is paused.
  bool isPaused = false;

  /// Optional callback triggered when the player wins the level.
  final Function? onWin;

  // Drag state variables to track dragging behavior.
  model.Component? draggingComponentModel;
  GameComponent? draggingGameComponent;
  Vector2 dragStartPosition = Vector2.zero();
  Vector2 componentStartPosition = Vector2.zero();
  Vector2 currentDragOffset = Vector2.zero();

  /// Creates a [CircuitGame] instance.
  CircuitGame({this.levelId, this.onWin});

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    if (levelId != null) {
      // Load level definition asynchronously.
      levelDefinition = await LevelLoader.loadLevel(levelId!);

      // Initialize the grid based on level size.
      grid = Grid(
        rows: levelDefinition.rows,
        cols: levelDefinition.cols,
      );

      // Create a semi-transparent red overlay for short circuit indication.
      shortCircuitOverlay = RectangleComponent(
        size: Vector2(grid.cols * 64.0, grid.rows * 64.0),
        paint: Paint()..color = Colors.red.withOpacity(0.5),
      );
      add(shortCircuitOverlay);
      shortCircuitOverlay.priority = 100;
      shortCircuitOverlay.opacity = 0;

      // Load initial components from level data and add to game.
      for (final componentData in levelDefinition.components) {
        final componentModel = model.Component.fromJson(componentData);
        grid.cells[componentModel.r][componentModel.c].component =
            componentModel;

        final gameComponent = _createGameComponent(componentModel);
        add(gameComponent);
      }

      // Perform initial circuit evaluation and update visuals.
      applyEvaluationResult(evaluate());
    }
  }

  @override
  void update(double dt) {
    if (!isPaused) {
      super.update(dt);
    }
  }

  @override
  void pauseEngine() {
    isPaused = true;
  }

  @override
  void resumeEngine() {
    isPaused = false;
  }

  /// Creates a [GameComponent] instance based on the [componentModel]'s type.
  GameComponent _createGameComponent(model.Component componentModel) {
    late final GameComponent gameComponent;

    switch (componentModel.type) {
      case model.ComponentType.battery:
        gameComponent = BatteryComponent(componentModel: componentModel);
        break;
      case model.ComponentType.bulb:
        gameComponent = BulbComponent(componentModel: componentModel);
        break;
      case model.ComponentType.wireStraight:
      case model.ComponentType.wireCorner:
      case model.ComponentType.wireT:
        gameComponent = WireComponent(componentModel: componentModel);
        break;
      case model.ComponentType.circuitSwitch:
        gameComponent = SwitchComponent(componentModel: componentModel);
        break;
      default:
        throw Exception('Unknown component type: ${componentModel.type}');
    }

    // Position component based on grid coordinates.
    gameComponent.position =
        Vector2(componentModel.c * 64.0, componentModel.r * 64.0);
    return gameComponent;
  }

  /// Evaluates the current grid state using the logic engine.
  EvaluationResult evaluate() => logicEngine.evaluateGrid(grid);

  /// Applies the evaluation results to update component visuals and state.
  ///
  /// Shows powered state for bulbs and wires, switch states,
  /// and displays a short circuit overlay with sound if detected.
  void applyEvaluationResult(EvaluationResult r) {
    for (final gameComponent in children.whereType<GameComponent>()) {
      if (r.poweredComponentIds.contains(gameComponent.componentModel.id)) {
        if (gameComponent is BulbComponent) {
          gameComponent.isOn = true;
        } else if (gameComponent is WireComponent) {
          gameComponent.hasCurrent = true;
        }
      } else {
        if (gameComponent is BulbComponent) {
          gameComponent.isOn = false;
        } else if (gameComponent is WireComponent) {
          gameComponent.hasCurrent = false;
        }
      }
      if (gameComponent is SwitchComponent) {
        gameComponent.isOn =
            gameComponent.componentModel.state['switchOpen'] == false;
      }
      gameComponent.updateVisuals();
    }

    shortCircuitOverlay.opacity = r.shortDetected ? 1.0 : 0.0;
    if (r.shortDetected) {
      FlameAudio.play('short_warning.wav');
    }
  }

  /// Checks whether the player has met the win condition.
  ///
  /// Calls [onWin] callback if all goals are met and no shorts exist.
  void checkWinCondition(EvaluationResult eval) {
    if (eval.shortDetected) return;

    bool allGoalsMet = true;
    for (final goal in levelDefinition.goals) {
      final goalType = goal['type'];
      if (goalType == 'power_bulb') {
        final r = goal['r'];
        final c = goal['c'];
        final targetCell = grid.cells[r][c];
        final targetBulbModel = targetCell.component;
        if (targetBulbModel == null ||
            !eval.poweredComponentIds.contains(targetBulbModel.id)) {
          allGoalsMet = false;
          break;
        }
      }
    }

    if (allGoalsMet) {
      FlameAudio.play('success.wav');
      onWin?.call();
    }
  }

  /// Provides hints to the player based on current evaluation state.
  String provideHint() {
    final eval = evaluate();
    if (eval.shortDetected) {
      return 'Hint: There\'s a short circuit!';
    } else if (eval.openEndpoints.isNotEmpty) {
      return 'Hint: There\'s an open connection.';
    } else {
      return 'Hint: Keep going!';
    }
  }

  /// Handles drag start event to detect which component is being dragged.
  ///
  /// Tracks the drag start position and component's initial position.
  @override
  bool onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    final localPos = event.localPosition;

    for (final gameComponent in children.whereType<GameComponent>()) {
      if (gameComponent.componentModel.isDraggable &&
          gameComponent.containsLocalPoint(localPos)) {
        draggingGameComponent = gameComponent;
        draggingComponentModel = gameComponent.componentModel;
        dragStartPosition = localPos;
        componentStartPosition = gameComponent.position.clone();
        currentDragOffset = Vector2.zero();
        break;
      }
    }
    return true;
  }

  /// Handles drag update event by updating the dragged component's position.
  ///
  /// Moves the component smoothly following the drag delta.
  @override
  bool onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    if (draggingGameComponent == null) return false;

    currentDragOffset += event.delta;

    draggingGameComponent!.position = componentStartPosition + currentDragOffset;
    return true;
  }

  /// Handles drag end event by snapping the component to the nearest grid cell.
  ///
  /// Validates the new position and updates the grid and model accordingly.
  /// Reverts position if invalid. Resets drag state after snapping.
  @override
  bool onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    if (draggingGameComponent != null) {
      _snapComponentToGrid(draggingGameComponent!);
    }

    draggingGameComponent = null;
    draggingComponentModel = null;
    currentDragOffset = Vector2.zero();
    return true;
  }

  /// Snaps a [gameComponent] to the nearest valid grid cell.
  ///
  /// Updates the underlying model and grid cells.
  /// Reverts position if the target cell is invalid or occupied.
  void _snapComponentToGrid(GameComponent gameComponent) {
    final newCol = (gameComponent.position.x / 64).round();
    final newRow = (gameComponent.position.y / 64).round();

    if (_isValidPosition(newRow, newCol)) {
      // Clear old grid cell
      grid.cells[gameComponent.componentModel.r]
          [gameComponent.componentModel.c]
          .component = null;

      // Update model position
      gameComponent.componentModel.r = newRow;
      gameComponent.componentModel.c = newCol;

      // Assign to new grid cell
      grid.cells[newRow][newCol].component = gameComponent.componentModel;

      // Snap component visually to grid
      gameComponent.position = Vector2(newCol * 64.0, newRow * 64.0);

      // Re-evaluate circuit state and check win condition
      applyEvaluationResult(evaluate());
      checkWinCondition(evaluate());
    } else {
      // Revert to previous position if invalid
      gameComponent.position = Vector2(
          gameComponent.componentModel.c * 64.0,
          gameComponent.componentModel.r * 64.0);
    }
  }

  /// Validates whether the given grid coordinates are within bounds and
  /// either empty or occupied by the dragged component itself.
  bool _isValidPosition(int r, int c) {
    if (r < 0 || r >= grid.rows || c < 0 || c >= grid.cols) return false;

    final cellComponent = grid.cells[r][c].component;
    if (cellComponent == null) return true;

    if (draggingComponentModel != null &&
        cellComponent.id == draggingComponentModel!.id) {
      return true;
    }

    return false;
  }

  /// Handles tap down events, specifically toggling switches.
  ///
  /// Updates the circuit evaluation and checks win condition after toggle.
  @override
  bool onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    for (final gameComponent in children.whereType<GameComponent>()) {
      if (gameComponent is SwitchComponent &&
          gameComponent.containsLocalPoint(event.localPosition)) {
        gameComponent.toggle();
        gameComponent.componentModel.state['switchOpen'] =
            !gameComponent.componentModel.state['switchOpen'];
        applyEvaluationResult(evaluate());
        checkWinCondition(evaluate());
        break;
      }
    }
    return true;
  }

  /// Resets the current level, clearing all components and reloading from level data.
  Future<void> resetLevel() async {
    removeAll(children.whereType<GameComponent>());

    grid = Grid(
      rows: levelDefinition.rows,
      cols: levelDefinition.cols,
    );

    for (final componentData in levelDefinition.components) {
      final componentModel = model.Component.fromJson(componentData);
      grid.cells[componentModel.r][componentModel.c].component =
          componentModel;

      final gameComponent = _createGameComponent(componentModel);
      add(gameComponent);
    }
    applyEvaluationResult(evaluate());
  }
}
