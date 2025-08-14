import 'package:flutter/material.dart';
import 'package:state_notifier/state_notifier.dart';
import 'package:collection/collection.dart';
import '../models/level_definition.dart';
import '../models/grid.dart';
import '../models/component.dart';
import '../services/logic_engine.dart';
import 'render_state.dart';
import '../services/audio_service.dart';
import 'animation_scheduler.dart';
import '../common/logger.dart';
import '../common/constants.dart';
import '../models/goal.dart';
import 'game_engine_state.dart';
import '../common/assets.dart';

/// GameEngineNotifier: Immutable state management for the game engine
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
    _initializeEngine(initialLevel);
  }

  GameEngineNotifier.forNoLevel({
    this.onEvaluate,
    this.onWin,
    LogicEngine? logicEngine,
    AudioService? audioService,
    AnimationScheduler? animationScheduler,
  }) : _logicEngine = logicEngine ?? LogicEngine(),
       _audioService = audioService ?? AudioService(),
       _animationScheduler = animationScheduler ?? AnimationScheduler(),
       super(GameEngineState.initial(null));

  void _initializeEngine(LevelDefinition? initialLevel) {
    _animationScheduler.addCallback((dt) {
      if (!state.isPaused) {
        _evaluateAndUpdateRenderState();
      }
    });
    if (initialLevel != null) {
      loadLevel(initialLevel);
    }
    _animationScheduler.start();
  }

  void loadLevel(LevelDefinition level) {
    Logger.log('GameEngine: Loading new level ${level.id}');
    _animationScheduler.reset();

    final components = <String, ComponentModel>{};
    for (final comp in level.components) {
      components[comp.id] = comp;
    }

    state = GameEngineState(
      currentLevel: level,
      grid: Grid(rows: level.rows, cols: level.cols, componentsById: components),
      isPaused: false,
      isWin: false,
    );

    _evaluateAndUpdateRenderState();
    Logger.log('GameEngine: Level setup complete.');
  }

  void _evaluateAndUpdateRenderState() {
    if (state.currentLevel == null) return;

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
      _audioService.play(AppAssets.audioSuccess);
      onWin?.call();
      Logger.log('GameEngine: Win condition met!');
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

  void togglePause() => setPaused(!state.isPaused);

  void startDrag(String componentId, Offset position) {
    Logger.log('GameEngineNotifier: startDrag for component $componentId');
    state = state.copyWith(draggedComponentId: componentId, dragPosition: position);
  }

  void updateDrag(String componentId, Offset position) {
    if (state.draggedComponentId != componentId) return;
    state = state.copyWith(dragPosition: position);
    _evaluateAndUpdateRenderState();
  }

  void endDrag(String componentId) {
    Logger.log('GameEngineNotifier: endDrag for component $componentId');
    if (state.draggedComponentId != componentId || state.dragPosition == null) {
      state = state.copyWith(draggedComponentId: null, dragPosition: null);
      return;
    }

    final newCol = (state.dragPosition!.dx / cellSize).floor();
    final newRow = (state.dragPosition!.dy / cellSize).floor();
    Logger.log('GameEngineNotifier: new position ($newRow, $newCol)');

    final componentToMove = state.grid.componentsById[componentId];
    if (componentToMove != null) {
      final newComponent = componentToMove.copyWith(r: newRow, c: newCol);
      final newComponents = Map<String, ComponentModel>.from(state.grid.componentsById);
      newComponents[componentId] = newComponent;
      
      final newGrid = state.grid.copyWith(componentsById: newComponents);
      
      // Basic validation before committing the state
      // A more robust validation would check for collisions
      if (newGrid.validate().isEmpty) {
          Logger.log('GameEngineNotifier: new position is valid');
          state = state.copyWith(grid: newGrid);
      } else {
        Logger.log('GameEngineNotifier: new position is invalid');
        _audioService.play(AppAssets.audioWarning);
      }
    }

    state = state.copyWith(draggedComponentId: null, dragPosition: null);
    _evaluateAndUpdateRenderState();
  }

  void toggleSwitch(String componentId) {
    final component = state.grid.componentsById[componentId];
    if (component == null || component.type != ComponentType.sw) return;

    final currentState = component.state['closed'] as bool? ?? false;
    final newComponentState = Map<String, dynamic>.from(component.state);
    newComponentState['closed'] = !currentState;

    final updatedComponent = component.copyWith(state: newComponentState);
    final newComponents = Map<String, ComponentModel>.from(state.grid.componentsById);
    newComponents[componentId] = updatedComponent;

    state = state.copyWith(grid: state.grid.copyWith(componentsById: newComponents));
    _audioService.play(AppAssets.audioToggle);
    _evaluateAndUpdateRenderState();
  }

  void handleTap(int r, int c) {
    final component = state.grid.componentsAt(r, c).firstOrNull;
    if (component != null && component.type == ComponentType.sw) {
      toggleSwitch(component.id);
    }
  }

  void reset() {
    if (state.currentLevel != null) {
      loadLevel(state.currentLevel!);
    }
  }

  @override
  void dispose() {
    _animationScheduler.dispose();
    super.dispose();
  }
}