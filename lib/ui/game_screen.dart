
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../engine/game_engine.dart';
import '../routes.dart';
import 'screens/win_screen.dart';
import 'widgets/pause_menu.dart';
import 'game_canvas.dart';

class GameScreen extends StatelessWidget {
  final String levelId;
  const GameScreen({Key? key, required this.levelId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameEngine(levelId: levelId)..loadLevel(),
      child: const _GameScreenContent(),
    );
  }
}

class _GameScreenContent extends StatelessWidget {
  const _GameScreenContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gameEngine = Provider.of<GameEngine>(context);

    return Scaffold(
      body: Stack(
        children: [
          const GameCanvas(),
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.pause, color: Colors.white),
              onPressed: () {
                gameEngine.pause();
              },
            ),
          ),
          Positioned(
            top: 40,
            right: 80,
            child: IconButton(
              icon: const Icon(Icons.bug_report, color: Colors.white),
              onPressed: () {
                gameEngine.toggleDebugOverlay();
              },
            ),
          ),
          if (gameEngine.isPaused)
            PauseMenu(onResume: gameEngine.resume),
          if (gameEngine.isWin)
            WinScreen(
              levelId: gameEngine.levelId!,
              onNextLevel: () {
                // TODO: Navigate to next level
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
