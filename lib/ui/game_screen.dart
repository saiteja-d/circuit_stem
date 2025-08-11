
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../engine/game_engine.dart';
import '../routes.dart';
import '../services/level_manager.dart';
import '../ui/controllers/debug_overlay_controller.dart';
import '../ui/widgets/debug_overlay.dart';
import 'screens/win_screen.dart';
import 'widgets/pause_menu.dart';
import 'game_canvas.dart';
import '../common/asset_manager.dart';
import '../common/logger.dart';

class GameScreen extends StatelessWidget {
  final String levelId; // The initial level to load.
  const GameScreen({Key? key, required this.levelId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Logger.log('GameScreen: Building with levelId: $levelId');
    return MultiProvider(
      providers: [
        // The LevelManager now starts loading its manifest upon creation.
        ChangeNotifierProvider(create: (_) => LevelManager()),
        ChangeNotifierProvider(create: (_) => DebugOverlayController()),
      ],
      child: Consumer<LevelManager>(
        builder: (context, levelManager, child) {
          // Show a loading indicator while the manifest is being loaded.
          if (levelManager.isLoading || levelManager.currentLevelDefinition == null) {
            Logger.log('GameScreen: LevelManager is loading or has no level definition.');
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // Once loaded, find the correct starting index.
          final initialIndex = levelManager.levels.indexWhere((l) => l.id == levelId);
          if (levelManager.currentLevelId != levelId) {
            Logger.log('GameScreen: Loading level by index: $initialIndex');
            levelManager.loadLevelByIndex(initialIndex >= 0 ? initialIndex : 0);
          }

          // Provide the GameEngine, which is dependent on the LevelManager's data.
          return ChangeNotifierProvider(
            create: (ctx) {
              Logger.log('GameScreen: Creating GameEngine for level ${levelManager.currentLevelDefinition!.id}');
              return GameEngine(
                levelDefinition: levelManager.currentLevelDefinition!,
                assetManager: AssetManager(),
                onWin: () {
                  // When the level is won, notify the LevelManager.
                  levelManager.completeCurrentLevel();
                },
                onEvaluate: (evalResult) {
                  Provider.of<DebugOverlayController>(ctx, listen: false)
                      .updateEvaluation(evalResult);
                },
              );
            },
            child: const _GameScreenContent(),
          );
        },
      ),
    );
  }
}

/// The main content of the game screen, including the canvas and UI overlays.
class _GameScreenContent extends StatelessWidget {
  const _GameScreenContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gameEngine = Provider.of<GameEngine>(context);
    final levelManager = Provider.of<LevelManager>(context);
    final debugController = Provider.of<DebugOverlayController>(context);

    return Scaffold(
      body: Stack(
        children: [
          const GameCanvas(),
          const DebugOverlay(),
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.pause, color: Colors.white),
              onPressed: gameEngine.pause,
            ),
          ),
          Positioned(
            top: 40,
            right: 80,
            child: IconButton(
              icon: Icon(
                Icons.bug_report,
                color: debugController.isVisible ? Colors.cyanAccent : Colors.white,
              ),
              onPressed: debugController.toggleVisibility,
            ),
          ),
          if (gameEngine.isPaused) PauseMenu(onResume: gameEngine.resume),
          if (gameEngine.isWin)
            WinScreen(
              levelId: levelManager.currentLevelId,
              onNextLevel: () {
                levelManager.goToNextLevel();
              },
              onLevelSelect: () {
                Navigator.of(context).popUntil(ModalRoute.withName(AppRoutes.mainMenu));
              },
            ),
        ],
      ),
    );
  }
}
