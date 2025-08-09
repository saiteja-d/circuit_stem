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

class CircuitGame extends FlameGame with HasDragRecognizer, HasTapRecognizer {
  final String? levelId;
  late final LevelDefinition levelDefinition;
  late final Grid grid;
  late final RectangleComponent shortCircuitOverlay;
  final LogicEngine logicEngine = LogicEngine();
  bool isPaused = false;
  final Function? onWin;

  CircuitGame({this.levelId, this.onWin});

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    if (levelId != null) {
      levelDefinition = await LevelLoader.loadLevel(levelId!);
      grid = Grid(
        rows: levelDefinition.gridSize['rows'],
        cols: levelDefinition.gridSize['cols'],
      );

      shortCircuitOverlay = RectangleComponent(
        size: Vector2(grid.cols * 64.0, grid.rows * 64.0),
        paint: Paint()..color = Colors.red.withValues(alpha: 0.5),
      );
      add(shortCircuitOverlay);
      shortCircuitOverlay.priority = 100;
      shortCircuitOverlay.opacity = 0;

      // Load initial components
      for (final componentData in levelDefinition.components) {
        final componentModel = model.Component.fromJson(componentData);
        grid.cells[componentModel.r][componentModel.c].component = componentModel;

        final gameComponent = _createGameComponent(componentModel);
        add(gameComponent);
      }
      // Initial evaluation
      applyEvaluationResult(evaluate());
    }
  }

  @override
  void update(double dt) {
    if (!isPaused) {
      super.update(dt);
    }
  }

  @override // Fixed missing override annotation
  void pauseEngine() {
    isPaused = true;
  }

  @override // Fixed missing override annotation
  void resumeEngine() {
    isPaused = false;
  }

  GameComponent _createGameComponent(model.Component componentModel) {
    GameComponent gameComponent;
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
    gameComponent.position = Vector2(componentModel.c * 64.0, componentModel.r * 64.0);
    return gameComponent;
  }

  EvaluationResult evaluate() => logicEngine.evaluateGrid(grid);

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
        gameComponent.isOn = gameComponent.componentModel.state['switchOpen'] == false;
      }
      gameComponent.updateVisuals();
    }

    shortCircuitOverlay.opacity = r.shortDetected ? 1.0 : 0.0;
    if (r.shortDetected) {
      FlameAudio.play('short_warning.wav');
    }
  }

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
        if (targetBulbModel == null || !eval.poweredComponentIds.contains(targetBulbModel.id)) {
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

  @override
  bool onDragUpdate(DragUpdateEvent event) {
    for (final gameComponent in children.whereType<GameComponent>()) {
      if (gameComponent.componentModel.isDraggable && gameComponent.containsLocalPoint(event.localPosition)) {
        gameComponent.position.add(event.localDelta);
        break;
      }
    }
    return true;
  }

  @override
  bool onDragEnd(DragEndEvent event) {
    for (final gameComponent in children.whereType<GameComponent>()) {
      if (gameComponent.componentModel.isDraggable) {
        _snapComponentToGrid(gameComponent);
      }
    }
    return true;
  }

  @override
  bool onTapDown(TapDownEvent event) {
    for (final gameComponent in children.whereType<GameComponent>()) {
      if (gameComponent is SwitchComponent && gameComponent.containsLocalPoint(event.localPosition)) {
        gameComponent.toggle();
        gameComponent.componentModel.state['switchOpen'] = !gameComponent.componentModel.state['switchOpen'];
        applyEvaluationResult(evaluate());
        checkWinCondition(evaluate());
        break;
      }
    }
    return true;
  }

  void _snapComponentToGrid(GameComponent gameComponent) {
    final newCol = (gameComponent.position.x / 64).round();
    final newRow = (gameComponent.position.y / 64).round();

    if (newRow >= 0 && newRow < grid.rows && newCol >= 0 && newCol < grid.cols) {
      final targetCell = grid.cells[newRow][newCol];
      if (targetCell.component == null || (targetCell.component!.id == gameComponent.componentModel.id)) {
        grid.cells[gameComponent.componentModel.r][gameComponent.componentModel.c].component = null;

        gameComponent.componentModel.r = newRow;
        gameComponent.componentModel.c = newCol;

        targetCell.component = gameComponent.componentModel;

        gameComponent.position = Vector2(newCol * 64.0, newRow * 64.0);

        applyEvaluationResult(evaluate());
        checkWinCondition(evaluate());
      } else {
        gameComponent.position = Vector2(gameComponent.componentModel.c * 64.0, gameComponent.componentModel.r * 64.0);
      }
    }
    else {
      gameComponent.position = Vector2(gameComponent.componentModel.c * 64.0, gameComponent.componentModel.r * 64.0);
    }
  }

  Future<void> resetLevel() async {
    removeAll(children.whereType<GameComponent>());

    grid = Grid(
      rows: levelDefinition.gridSize['rows'],
      cols: levelDefinition.gridSize['cols'],
    );

    for (final componentData in levelDefinition.components) {
      final componentModel = model.Component.fromJson(componentData);
      grid.cells[componentModel.r][componentModel.c].component = componentModel;

      final gameComponent = _createGameComponent(componentModel);
      add(gameComponent);
    }
    applyEvaluationResult(evaluate());
  }
}
