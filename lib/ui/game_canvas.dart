import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import '../common/asset_manager.dart';
import '../common/constants.dart';
import '../engine/game_engine.dart';
import 'canvas_painter.dart';

class GameCanvas extends StatefulWidget {
  const GameCanvas({Key? key}) : super(key: key);

  @override
  _GameCanvasState createState() => _GameCanvasState();
}

class _GameCanvasState extends State<GameCanvas> with TickerProviderStateMixin {
  String? _draggedComponentId;
  final AssetManager _assetManager = AssetManager();
  late Ticker _ticker;
  Duration _lastElapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      final gameEngine = Provider.of<GameEngine>(context, listen: false);
      final dt = (elapsed - _lastElapsed).inMicroseconds / Duration.microsecondsPerSecond;
      _lastElapsed = elapsed;
      gameEngine.update(dt);
    });
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameEngine = Provider.of<GameEngine>(context, listen: false);
    
    return GestureDetector(
      onTapDown: (details) {
        final tapPosition = details.localPosition;
        final col = (tapPosition.dx / cellSize).floor();
        final row = (tapPosition.dy / cellSize).floor();
        gameEngine.handleTap(row, col);
      },
      onPanStart: (details) {
        final tapPosition = details.localPosition;
        final col = (tapPosition.dx / cellSize).floor();
        final row = (tapPosition.dy / cellSize).floor();
        final component = gameEngine.findComponentByPosition(row, col);
        if (component != null && component.isDraggable) {
          setState(() {
            _draggedComponentId = component.id;
          });
          gameEngine.startDrag(component.id);
        }
      },
      onPanUpdate: (details) {
        if (_draggedComponentId != null) {
          gameEngine.updateDrag(_draggedComponentId!, details.localPosition);
        }
      },
      onPanEnd: (details) {
        if (_draggedComponentId != null) {
          gameEngine.endDrag(_draggedComponentId!);
          setState(() {
            _draggedComponentId = null;
          });
        }
      },
      child: Consumer<GameEngine>(
        builder: (context, engine, child) {
          return CustomPaint(
            painter: CanvasPainter(
              renderState: engine.renderState,
              assetManager: _assetManager,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}