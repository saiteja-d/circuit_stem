import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../game/circuit_game.dart';
import '../game/ui_overlay.dart';
import '../routes.dart';
import 'win_screen.dart';
import '../widgets/pause_menu.dart';

class GameScreen extends StatefulWidget {
  final String levelId;
  const GameScreen({Key? key, required this.levelId}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late CircuitGame _game;
  bool isPaused = false;

  @override
  void initState() {
    super.initState();
    _game = CircuitGame(
      levelId: widget.levelId,
      onWin: () {
        _game.overlays.add('WinScreen');
      },
    );
  }

  void togglePause() {
    setState(() {
      isPaused = !isPaused;
      if (isPaused) {
        _game.pauseEngine();
      } else {
        _game.resumeEngine();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GameWidget<CircuitGame>(
            game: _game,
            overlayBuilderMap: {
              'UiOverlay': (context, gameRef) => UiOverlay(game: gameRef),
              'WinScreen': (context, gameRef) => WinScreen(
                levelId: widget.levelId,
                onNextLevel: () {
                  gameRef.overlays.remove('WinScreen');
                  // TODO: Navigate to next level
                },
                onLevelSelect: () {
                  Navigator.of(context).popUntil(ModalRoute.withName(AppRoutes.mainMenu));
                },
              ),
            },
            initialActiveOverlays: const ['UiOverlay'],
          ),
          if (isPaused) PauseMenu(onResume: togglePause),
        ],
      ),
    );
  }
}