// lib/engine/game_engine.dart
import 'package:flutter/material.dart';
import '../models/level_definition.dart';
import '../models/grid.dart';
import '../models/component.dart';
import '../services/level_loader.dart';
import '../services/logic_engine.dart';
import 'render_state.dart';
import '../flame_integration/flame_adapter.dart';
import 'animation_scheduler.dart';
import '../common/constants.dart';

/// GameEngine: pure-Dart orchestrator adapted for multi-cell ComponentModel and enriched LogicEngine.
class GameEngine extends ChangeNotifier {
  final String? levelId;
  final VoidCallback? onWin;

  late final LevelDefinition levelDefinition;
  late Grid grid;
  final LogicEngine logicEngine = LogicEngine();
  bool isPaused = false;
  bool isWin = false;
  bool showDebugOverlay = false;

  RenderState? _renderState;
  RenderState? get renderState => _renderState;

  String? _draggedComponentId;
  Offset? _dragPosition;

  final FlameAdapter _flameAdapter = FlameAdapter();
  final AnimationScheduler _animationScheduler = AnimationScheduler();

  GameEngine({this.levelId, this.onWin});

  /// Load level and add components using Grid.addComponent (multi-cell aware).
  Future<void> loadLevel() async {
    if (levelId == null) return;
    isWin = false;
    _animationScheduler.reset();
    levelDefinition = await LevelLoader.loadLevel(levelId!);
    grid = Grid(rows: levelDefinition.rows, cols: levelDefinition.cols);

    // Add components (ComponentModel.fromJson should build shapeOffsets/terminals)
    for (final compJson in levelDefinition.components) {
      final comp = ComponentModel.fromJson(compJson);
      final placed = grid.addComponent(comp);
      if (!placed) {
        // handle placement failure - log or collect warnings
        debugPrint('Warning: failed to place component ${comp.id} at ${comp.r},${comp.c}');
      }
    }

    _evaluateAndUpdateRenderState();
  }

  /// Called each frame / tick from UI loop (dt in seconds)
  void update({double dt = 0.0}) {
    _animationScheduler.tick(dt);
    // Use evaluate() to recompute state
    _evaluateAndUpdateRenderState();
  }

  void _evaluateAndUpdateRenderState() {
    final evalResult = logicEngine.evaluate(grid);
    _renderState = RenderState.fromEvaluation(grid: grid, eval: evalResult, bulbIntensity: _animationScheduler.bulbIntensity, wireOffset: _animationScheduler.wireOffset, draggedComponentId: _draggedComponentId, dragPosition: _dragPosition);
    _checkWinCondition(evalResult);
    notifyListeners();
  }

  void _checkWinCondition(EvaluationResult eval) {
    if (eval.isShortCircuit) return;

    bool allGoalsMet = true;
    for (final goal in levelDefinition.goals) {
      final type = goal['type'];
      if (type == 'power_bulb') {
        final r = goal['r'] as int;
        final c = goal['c'] as int;
        final comps = grid.componentsAt(r, c);
        final target = (comps.isNotEmpty) ? comps.first : null;
        if (target == null || !eval.poweredComponentIds.contains(target.id)) {
          allGoalsMet = false;
          break;
        }
      }
    }

    if (allGoalsMet && !isWin) {
      isWin = true;
      _flameAdapter.playAudio('success.wav');
      onWin?.call();
    }
  }

  /// Toggle a switch component (per-component `closed` state). Accepts multi-terminal semantics via state['blockedTerminals'].
  void toggleSwitch(String componentId) {
    final comp = grid.componentsById[componentId];
    if (comp == null) return;
    if (comp.type != ComponentType.sw) return;
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
    // keep renderState reactive so drag preview draws
    _evaluateAndUpdateRenderState();
  }

  /// When drag finishes attempt to place the component using Grid.updateComponent (handles multi-cell collisions).
  void endDrag(String componentId) {
    if (_dragPosition == null) {
      _draggedComponentId = null;
      return;
    }

    // convert pixel position to cell coordinates (assumes cellSize constant)
    final newCol = (_dragPosition!.dx / cellSize).floor();
    final newRow = (_dragPosition!.dy / cellSize).floor();

    final comp = grid.componentsById[componentId];
    if (comp != null) {
      // create a copy with new anchor to test placement
      final attempted = comp.copyWith(r: newRow, c: newCol);
      final ok = grid.updateComponent(attempted);
      if (!ok) {
        // placement failed - optionally snap back or show invalid feedback
        _flameAdapter.playAudio('invalid.wav');
      }
    }

    _draggedComponentId = null;
    _dragPosition = null;
    _evaluateAndUpdateRenderState();
  }

  bool _isValidPosition(int r, int c) => r >= 0 && r < grid.rows && c >= 0 && c < grid.cols;

  /// Find a component by its id quickly using the map.
  ComponentModel? _findComponent(String componentId) => grid.componentsById[componentId];

  /// Get first component that occupies a cell (accounts for multi-cell shapes).
  ComponentModel? findComponentByPosition(int r, int c) {
    final comps = grid.componentsAt(r, c);
    return comps.isNotEmpty ? comps.first : null;
  }

  void handleTap(int r, int c) {
    final comp = findComponentByPosition(r, c);
    if (comp != null && comp.type == ComponentType.sw) toggleSwitch(comp.id);
  }

  void pause() {
    isPaused = true;
    notifyListeners();
  }

  void resume() {
    isPaused = false;
    notifyListeners();
  }

  Future<void> reset() async {
    isWin = false;
    await loadLevel();
  }

  void toggleDebugOverlay() {
    showDebugOverlay = !showDebugOverlay;
    notifyListeners();
  }
}
}