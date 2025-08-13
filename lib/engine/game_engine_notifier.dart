import 'package:flutter/material.dart';
import 'package:state_notifier/state_notifier.dart';
import 'package:collection/collection.dart'; // For firstWhereOrNull and firstOrNull
import '../models/level_definition.dart';
import '../models/grid.dart';
import '../models/component.dart';
import '../services/logic_engine.dart';
import 'render_state.dart';
import '../services/audio_service.dart';
import 'animation_scheduler.dart';
import '../common/logger.dart';
import '../models/goal.dart';
import 'game_engine_state.dart';

class GameEngineNotifier extends StateNotifier<GameEngineState> {
  final LogicEngine _logicEngine;
  final AudioService _audioService;
  final AnimationScheduler _animationScheduler;
  final void Function(EvaluationResult)? onEvaluate;
  final VoidCallback? onWin;

  GameEngineNotifier({
    LevelDefinition? initialLevel,
    this.onEvaluate,
    this.onWin,
    LogicEngine? logicEngine,
    AudioService? audioService,
    AnimationScheduler? animationScheduler,
  }) : _logicEngine = logicEngine ?? LogicEngine(),
       _audioService = audioService ?? AudioService(),
       _animationScheduler = animationScheduler ?? AnimationScheduler(),
       super(GameEngineState.initial(initialLevel)) {
    if (initialLevel != null) {
      _setupLevel(initialLevel);
    }
    _animationScheduler.addCallback((dt) {
      if (!state.isPaused) {
        _evaluateAndUpdateRenderState();
      }
    });
    _animationScheduler.start();
  }

  // Constructor for when no level is initially selected (e.g., app startup)
  GameEngineNotifier.forNoLevel() : 
    _logicEngine = LogicEngine(),
    _audioService = AudioService(),
    _animationScheduler = AnimationScheduler(),
    onEvaluate = null,
    onWin = null,
    super(GameEngineState.initial(null));

  Future<void> _setupLevel(LevelDefinition level) async {
    Logger.log('GameEngine: Setting up level...');
    
    // Reset state
    _animationScheduler.reset();
    state = state.copyWith(
      isWin: false,
      isShortCircuit: false,
      draggedComponentId: null,
      dragPosition: null,
      currentLevel: level,
    );

    // Setup grid with components
    final grid = Grid(rows: state.currentLevel!.rows, cols: state.currentLevel!.cols);
    for (final comp in state.currentLevel!.components) {
      final placed = grid.addComponent(comp);
      if (!placed) {
        Logger.log('Warning: failed to place component ${comp.id} at ${comp.r},${comp.c}');
      }
    }
    
    state = state.copyWith(grid: grid);
    _evaluateAndUpdateRenderState();
    Logger.log('GameEngine: Level setup complete.');
  }

  void update(double dt) {
    if (state.isPaused) return;
    _evaluateAndUpdateRenderState();
  }

  void _evaluateAndUpdateRenderState() {
    if (state.currentLevel == null) return; // Cannot evaluate without a level

    final evalResult = _logicEngine.evaluate(state.grid);
    final newRenderState = RenderState.fromEvaluation(
      grid: state.grid,
      eval: evalResult,
      bulbIntensity: _animationScheduler.bulbIntensity,
      wireOffset: _animationScheduler.wireOffset,
      draggedComponentId: state.draggedComponentId,
      dragPosition: state.dragPosition,
    );

    state = state.copyWith(
      renderState: newRenderState,
      isShortCircuit: evalResult.isShortCircuit,
    );

    onEvaluate?.call(evalResult);
    _checkWinCondition(evalResult);
  }

  void _checkWinCondition(EvaluationResult eval) {
    if (state.currentLevel == null || state.isWin || eval.isShortCircuit) return;

    bool allGoalsMet = true;
    for (final goal in state.currentLevel!.goals) {
      if (!_isGoalMet(goal, eval)) {
        allGoalsMet = false;
        break;
      }
    }

    if (allGoalsMet) {
      state = state.copyWith(isWin: true);
      _audioService.playSuccess();
      onWin?.call();
    }
  }

  bool _isGoalMet(Goal goal, EvaluationResult eval) {
    switch (goal.type) {
      case 'power_bulb':
        final component = state.grid.componentsById.values
            .firstWhereOrNull((c) => c.r == goal.r && c.c == goal.c);
        return component != null && eval.poweredComponentIds.contains(component.id);
      default:
        Logger.log('Warning: Unknown goal type ${goal.type}');
        return false;
    }
  }

  void setPaused(bool paused) {
    if (state.isPaused == paused) return;
    state = state.copyWith(isPaused: paused);
    
    if (paused) {
      _animationScheduler.pause();
    } else {
      _animationScheduler.resume();
    }
  }

  void startDragging(String componentId, Offset position) {
    state = state.copyWith(
      draggedComponentId: componentId,
      dragPosition: position,
    );
  }

  void updateDragPosition(Offset position) {
    if (state.draggedComponentId == null) return;
    state = state.copyWith(dragPosition: position);
  }

  void endDragging() {
    state = state.copyWith(
      draggedComponentId: null,
      dragPosition: null,
    );
    _evaluateAndUpdateRenderState();
  }

  void toggleComponent(String componentId) {
    final component = state.grid.componentsById[componentId];
    if (component == null || component.type != ComponentType.sw) return;

    final currentState = component.state['closed'] as bool? ?? false;
    component.state['closed'] = !currentState;
    
    _audioService.playToggle();
    _evaluateAndUpdateRenderState();
  }

  ComponentModel? findComponentByPosition(int r, int c) {
    return state.grid.componentsAt(r, c).firstOrNull;
  }

  void handleTap(int r, int c) {
    final component = findComponentByPosition(r, c);
    if (component != null && component.type == ComponentType.sw) {
      toggleComponent(component.id);
    }
  }

  void resetLevel() {
    if (state.currentLevel != null) {
      _setupLevel(state.currentLevel!);
    }
  }

  void togglePause() {
    setPaused(!state.isPaused);
  }

  @override
  void dispose() {
    _animationScheduler.dispose();
    super.dispose();
  }
}