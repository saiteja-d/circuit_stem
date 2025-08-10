
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/level_definition.dart';
import '../models/grid.dart';
import '../models/component.dart' as model;
import '../services/level_loader.dart';
import '../services/logic_engine.dart';
import 'render_state.dart';
import '../flame_integration/flame_adapter.dart';
import 'animation_scheduler.dart';
import '../common/constants.dart';

class GameEngine extends ChangeNotifier {
  final String? levelId;
  final VoidCallback? onWin;

  late final LevelDefinition levelDefinition;
  late Grid grid;
  final LogicEngine logicEngine = LogicEngine();
  bool isPaused = false;
  bool isWin = false;

  RenderState? _renderState;
  RenderState? get renderState => _renderState;

  String? _draggedComponentId;
  Offset? _dragPosition;

  final FlameAdapter _flameAdapter = FlameAdapter();
  final AnimationScheduler _animationScheduler = AnimationScheduler();

  GameEngine({this.levelId, this.onWin});

  Future<void> loadLevel() async {
    if (levelId != null) {
      isWin = false;
      _animationScheduler.reset();
      levelDefinition = await LevelLoader.loadLevel(levelId!);
      grid = Grid(
        rows: levelDefinition.rows,
        cols: levelDefinition.cols,
      );

      final components = <model.Component>[];
      for (final componentData in levelDefinition.components) {
        final componentModel = model.Component.fromJson(componentData);
        grid.cells[componentModel.r][componentModel.c].component = componentModel;
        components.add(componentModel);
      }
      
      _update();
    }
  }

  void update({double dt = 0.0}) {
    _animationScheduler.tick(dt);
    final evalResult = logicEngine.evaluateGrid(grid);
    _renderState = RenderState(
      grid: grid,
      components: grid.allCells().where((c) => c.hasComponent).map((c) => c.component!).toList(),
      evaluationResult: evalResult,
      draggedComponentId: _draggedComponentId,
      dragPosition: _dragPosition,
      bulbIntensity: _animationScheduler.bulbIntensity,
      wireOffset: _animationScheduler.wireOffset,
    );
    
    checkWinCondition(evalResult);
    notifyListeners();
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
        if (targetBulbModel == null ||
            !eval.poweredComponentIds.contains(targetBulbModel.id)) {
          allGoalsMet = false;
          break;
        }
      }
    }

    if (allGoalsMet) {
      isWin = true;
      _flameAdapter.playAudio('success.wav');
      onWin?.call();
    }
  }

  void toggleSwitch(String componentId) {
    final component = _findComponent(componentId);
    if (component != null && component.isSwitch) {
      component.state['switchOpen'] = !(component.state['switchOpen'] as bool? ?? false);
      _flameAdapter.playAudio('toggle.wav');
      _update();
    }
  }

  void startDrag(String componentId) {
    _draggedComponentId = componentId;
  }

  void updateDrag(String componentId, Offset position) {
    _dragPosition = position;
    _update();
  }

  void endDrag(String componentId) {
    final newCol = (_dragPosition!.dx / cellSize).floor();
    final newRow = (_dragPosition!.dy / cellSize).floor();

    final component = _findComponent(componentId);
    if (component != null) {
      // Check if the new position is valid and empty
      if (_isValidPosition(newRow, newCol) && grid.cells[newRow][newCol].component == null) {
        // Clear old grid cell
        grid.cells[component.r][component.c].component = null;
        // Update model position
        component.r = newRow;
        component.c = newCol;
        // Assign to new grid cell
        grid.cells[newRow][newCol].component = component;
      }
    }

    _draggedComponentId = null;
    _dragPosition = null;
    _update();
  }

  bool _isValidPosition(int r, int c) {
    return r >= 0 && r < grid.rows && c >= 0 && c < grid.cols;
  }

  void pause() {
    isPaused = true;
    notifyListeners();
  }

  void resume() {
    isPaused = false;
    notifyListeners();
  }

  void reset() {
    isWin = false;
    loadLevel();
  }

  model.Component? _findComponent(String componentId) {
    for (final cell in grid.allCells()) {
      if (cell.hasComponent && cell.component!.id == componentId) {
        return cell.component;
      }
    }
    return null;
  }

  model.Component? findComponentByPosition(int r, int c) {
    if (r >= 0 && r < grid.rows && c >= 0 && c < grid.cols) {
      return grid.cells[r][c].component;
    }
    return null;
  }

  void handleTap(int r, int c) {
    final component = findComponentByPosition(r, c);
    if (component != null && component.isSwitch) {
      toggleSwitch(component.id);
    }
  }
}
