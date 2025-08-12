import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../common/constants.dart';
import '../core/providers.dart';
import '../ui/canvas_painter.dart';

class GameCanvas extends ConsumerStatefulWidget {
  const GameCanvas({Key? key}) : super(key: key);

  @override
  ConsumerState<GameCanvas> createState() => _GameCanvasState();
}

class _GameCanvasState extends ConsumerState<GameCanvas> with TickerProviderStateMixin {
  String? _draggedComponentId;
  late final Ticker _ticker;
  Duration _lastElapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _ticker = Ticker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    final gameEngineNotifier = ref.read(gameEngineProvider.notifier);
    final dt = (elapsed - _lastElapsed).inMilliseconds / 1000.0;
    _lastElapsed = elapsed;
    gameEngineNotifier.update(dt);
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameEngineNotifier = ref.read(gameEngineProvider.notifier);
    final gameEngineState = ref.watch(gameEngineProvider);
    final debugController = ref.watch(debugOverlayControllerProvider);
    final assetManager = ref.watch(assetManagerProvider);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (details) {
        final tapPos = details.localPosition;
        final col = (tapPos.dx / cellSize).floor();
        final row = (tapPos.dy / cellSize).floor();
        gameEngineNotifier.handleTap(row, col);
      },
      onPanStart: (details) {
        final startPos = details.localPosition;
        final col = (startPos.dx / cellSize).floor();
        final row = (startPos.dy / cellSize).floor();

        final component = gameEngineNotifier.findComponentByPosition(row, col);
        if (component != null && component.isDraggable) {
          setState(() {
            _draggedComponentId = component.id;
          });
          gameEngineNotifier.startDragging(component.id, startPos);
        }
      },
      onPanUpdate: (details) {
        if (_draggedComponentId != null) {
          gameEngineNotifier.updateDragPosition(details.localPosition);
        }
      },
      onPanEnd: (details) {
        if (_draggedComponentId != null) {
          gameEngineNotifier.endDragging();
          setState(() {
            _draggedComponentId = null;
          });
        }
      },
      child: CustomPaint(
        painter: CanvasPainter(
          renderState: gameEngineState.renderState,
          showDebugOverlay: debugController.isVisible,
          assetManager: assetManager,
        ),
        size: Size.infinite,
      ),
    );
  }
}
