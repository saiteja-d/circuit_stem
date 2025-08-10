// lib/engine/game_engine.dart
import 'package:flutter/material.dart';
import '../models/level_definition.dart';
import '../models/grid.dart';
import '../models/component.dart';
import '../models/component_factory.dart'; // New import
import '../services/logic_engine.dart';
import 'render_state.dart';
import '../flame_integration/flame_adapter.dart';
import 'animation_scheduler.dart';
import '../common/constants.dart';

/// GameEngine: pure-Dart orchestrator for game logic and state.
///
/// This class is now decoupled from level loading and debug UI management.
class GameEngine extends ChangeNotifier {
  final LevelDefinition levelDefinition;
  final VoidCallback? onWin;
  final Function(EvaluationResult)? onEvaluate;

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

  GameEngine({
    required this.levelDefinition,
    this.onWin,
    this.onEvaluate,
  }) {
    _setupLevel();
  }

  /// Sets up the level based on the provided LevelDefinition.
Future<void> _setupLevel() async {
  isWin = false;
  _animationScheduler.reset();
  grid = Grid(rows: levelDefinition.rows, cols: levelDefinition.cols);

  for (final comp in levelDefinition.components) {
    final placed = grid.addComponent(comp);
    if (!placed) {
      debugPrint('Warning: failed to place component ${comp.id} at ${comp.r},${comp.c}');
    }
  }

  _evaluateAndUpdateRenderState();
}


  /// Called each frame / tick from the UI loop.
  void update({double dt = 0.0}) {
    if (isPaused) return;
    _animationScheduler.tick(dt);
    _evaluateAndUpdateRenderState();
  }

  void _evaluateAndUpdateRenderState() {
    final evalResult = logicEngine.evaluate(grid);
    _renderState = RenderState.fromEvaluation(
      grid: grid,
      eval: evalResult,
      bulbIntensity: _animationScheduler.bulbIntensity,
      wireOffset: _animationScheduler.wireOffset,
      draggedComponentId: _draggedComponentId,
      dragPosition: _dragPosition,
    );

    // Notify listeners (like the debug overlay) about the new evaluation.
    onEvaluate?.call(evalResult);

    _checkWinCondition(evalResult);
    notifyListeners();
  }

void _checkWinCondition(EvaluationResult eval) {
  if (isWin || eval.isShortCircuit) return;

  bool allGoalsMet = true;
  for (final goal in levelDefinition.goals) {
    final type = goal.type;
    if (type == 'power_bulb') {
      final r = goal.r;
      final c = goal.c;
      if (r == null || c == null) {
        allGoalsMet = false;
        break;
      }
      final comps = grid.componentsAt(r, c);
      final target = comps.isNotEmpty ? comps.first : null;
      if (target == null || !eval.poweredComponentIds.contains(target.id)) {
        allGoalsMet = false;
        break;
      }
    } else {
      // TODO: handle other goal types
    }
  }

  if (allGoalsMet) {
    isWin = true;
    _flameAdapter.playAudio('success.wav');
    onWin?.call();
  }
}


  /// Toggles a switch component.
  void toggleSwitch(String componentId) {
    final comp = grid.componentsById[componentId];
    if (comp == null || comp.type != ComponentType.sw) return;

    final closed = comp.state['closed'] == true;
    comp.state['closed'] = !closed;
    _flameAdapter.playAudio('toggle.wav');
    _evaluateAndUpdateRenderState();
  }

  void startDrag(String componentId) {
    _draggedComponentId = componentId;
  }

  void updateDrag(String componentId, Offset position) {
    _dragPosition = position;
    _evaluateAndUpdateRenderState();
  }

  /// Ends a drag operation and attempts to place the component.
  void endDrag(String componentId) {
    if (_dragPosition == null) {
      _draggedComponentId = null;
      return;
    }

    final newCol = (_dragPosition!.dx / cellSize).floor();
    final newRow = (_dragPosition!.dy / cellSize).floor();

    final comp = grid.componentsById[componentId];
    if (comp != null) {
      final attempted = comp.copyWith(r: newRow, c: newCol);
      final success = grid.updateComponent(attempted);
      if (!success) {
        _flameAdapter.playAudio('short_warning.wav');
      }
    }

    _draggedComponentId = null;
    _dragPosition = null;
    _evaluateAndUpdateRenderState();
  }

  ComponentModel? findComponentByPosition(int r, int c) {
    final comps = grid.componentsAt(r, c);
    return comps.isNotEmpty ? comps.first : null;
  }

  void handleTap(int r, int c) {
    final comp = findComponentByPosition(r, c);
    if (comp != null && comp.type == ComponentType.sw) {
      toggleSwitch(comp.id);
    }
  }

  void pause() {
    isPaused = true;
    notifyListeners();
  }

  void resume() {
    isPaused = false;
    notifyListeners();
  }

  /// Resets the game to the initial state of the current level.
  Future<void> reset() async {
    await _setupLevel();
  }
}
