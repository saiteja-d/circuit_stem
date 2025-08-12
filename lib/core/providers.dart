import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../common/asset_manager.dart';
import '../services/level_manager.dart';
import '../core/state/game_state.dart';
import '../engine/render_state.dart';
import '../engine/animation_scheduler.dart';
import '../services/logic_engine.dart';
import '../ui/controllers/debug_overlay_controller.dart';

/// Global provider for AssetManager
final assetManagerProvider = Provider<AssetManager>((ref) {
  throw UnimplementedError('Needs to be overridden with a value');
});

/// Global provider for LevelManager
final levelManagerProvider = Provider<LevelManager>((ref) {
  throw UnimplementedError('Needs to be overridden with a value');
});

/// Global provider for the animation scheduler
final animationSchedulerProvider = Provider((ref) => AnimationScheduler());

/// Global provider for the logic engine
final logicEngineProvider = Provider((ref) => LogicEngine());

/// Primary game state provider
final gameStateProvider = StateNotifierProvider<GameStateNotifier, GameState>((ref) {
  return GameStateNotifier();
});

/// Debug overlay controller provider
final debugOverlayControllerProvider = Provider<DebugOverlayController>((ref) {
  throw UnimplementedError('Needs to be overridden with a value');
});

/// Computed render state based on game state
final renderStateProvider = Provider<RenderState?>((ref) {
  final gameState = ref.watch(gameStateProvider);
  final animationScheduler = ref.watch(animationSchedulerProvider);
  final logicEngine = ref.watch(logicEngineProvider);

  if (gameState.grid.componentsById.isEmpty) return null;

  final evalResult = logicEngine.evaluate(gameState.grid);
  
  return RenderState.fromEvaluation(
    grid: gameState.grid,
    eval: evalResult,
    bulbIntensity: animationScheduler.bulbIntensity,
    wireOffset: animationScheduler.wireOffset,
    draggedComponentId: gameState.draggedComponentId,
    dragPosition: null, // Handled by gesture provider
  );
});
