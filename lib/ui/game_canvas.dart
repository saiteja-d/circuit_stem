import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart'; // For Ticker
import 'package:provider/provider.dart';
import '../common/constants.dart'; // For cellSize
import '../common/asset_manager.dart';
import '../engine/game_engine.dart';
import '../ui/canvas_painter.dart'; // Fixed relative import path
import '../ui/controllers/debug_overlay_controller.dart'; // Fixed relative import path

class GameCanvas extends StatefulWidget {
  const GameCanvas({Key? key}) : super(key: key);

  @override
  _GameCanvasState createState() => _GameCanvasState();
}

class _GameCanvasState extends State<GameCanvas> with TickerProviderStateMixin {
  String? _draggedComponentId;
  final AssetManager _assetManager = AssetManager();
  late final Ticker _ticker;
  Duration _lastElapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    // Pass the _onTick function directly, no need to wrap in TickerCallback
    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    final gameEngine = Provider.of<GameEngine>(context, listen: false);
    final dt = (elapsed - _lastElapsed).inMicroseconds / Duration.microsecondsPerSecond;
    _lastElapsed = elapsed;
    gameEngine.update(dt);
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
      behavior: HitTestBehavior.opaque,
      onTapDown: (details) {
        final tapPos = details.localPosition;
        final col = (tapPos.dx / cellSize).floor();
        final row = (tapPos.dy / cellSize).floor();
        gameEngine.handleTap(row, col);
      },
      onPanStart: (details) {
        final startPos = details.localPosition;
        final col = (startPos.dx / cellSize).floor();
        final row = (startPos.dy / cellSize).floor();

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
      child: Consumer2<GameEngine, DebugOverlayController>(
        builder: (context, engine, debugController, _) {
          return CustomPaint(
            painter: CanvasPainter(
              renderState: engine.renderState,
              assetManager: _assetManager,
              showDebugOverlay: debugController.isVisible,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}
