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
  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Ticker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    // This ticker can be used to drive animations if needed.
    // The `elapsed` duration can be used to calculate animation frames.
    // For example: ref.read(gameEngineProvider.notifier).update(elapsed);
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameNotifier = ref.read(gameEngineProvider.notifier);
    final renderState = ref.watch(renderStateProvider);
    final assetManager = ref.watch(assetManagerProvider);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (details) {
        final tapPos = details.localPosition;
        final col = (tapPos.dx / cellSize).floor();
        final row = (tapPos.dy / cellSize).floor();
        gameNotifier.handleTap(row, col);
      },
      onPanStart: (details) {
        final startPos = details.localPosition;
        final col = (startPos.dx / cellSize).floor();
        final row = (startPos.dy / cellSize).floor();

        final component = ref.read(gameEngineProvider).grid.componentsAt(row, col).firstOrNull;
        if (component != null && component.isDraggable) {
          gameNotifier.startDrag(component.id, startPos);
        }
      },
      onPanUpdate: (details) {
        final draggedId = ref.read(gameEngineProvider).draggedComponentId;
        if (draggedId != null) {
          gameNotifier.updateDrag(draggedId, details.localPosition);
        }
      },
      onPanEnd: (details) {
        final draggedId = ref.read(gameEngineProvider).draggedComponentId;
        if (draggedId != null) {
          gameNotifier.endDrag(draggedId);
        }
      },
      child: CustomPaint(
        painter: CanvasPainter(
          renderState: renderState,
          assetManager: assetManager,
        ),
        size: Size.infinite,
      ),
    );
  }
}
