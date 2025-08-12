import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart'; // For Ticker
import 'package:provider/provider.dart';
import '../common/constants.dart'; // For cellSize
import '../engine/game_engine.dart';
import '../ui/canvas_painter.dart';
import '../ui/controllers/debug_overlay_controller.dart';

class GameCanvas extends StatefulWidget {
  const GameCanvas({Key? key}) : super(key: key);

  @override
  _GameCanvasState createState() => _GameCanvasState();
}

class _GameCanvasState extends State<GameCanvas> with TickerProviderStateMixin {
  String? _draggedComponentId;
  late final Ticker _ticker;
  Duration _lastElapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    // Alternative: create Ticker via constructor and pass this as vsync
    _ticker = Ticker(_onTick)..start();
  }

void _onTick(Duration elapsed) {
  final gameEngine = Provider.of<GameEngine>(context, listen: false);
  final dt = (elapsed - _lastElapsed).inMilliseconds / 1000.0;
  _lastElapsed = elapsed;
  gameEngine.update(dt: dt);
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
              showDebugOverlay: debugController.isVisible,
              context: context, // Pass context here
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}
