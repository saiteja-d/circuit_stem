import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../common/constants.dart';
import '../core/providers.dart';
import '../ui/canvas_painter.dart';
import '../common/logger.dart';
import '../models/component.dart';

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

    return DragTarget<ComponentModel>(
      onWillAccept: (data) => true,
      onAcceptWithDetails: (details) {
        final component = details.data;
        final offset = details.offset;
        final col = (offset.dx / cellSize).floor();
        final row = (offset.dy / cellSize).floor();
        Logger.log('GameCanvas: Dropped component ${component.id} of type ${component.type} at ($row, $col)');
        final newComponent = component.copyWith(id: 'comp_${DateTime.now().millisecondsSinceEpoch}');
        gameNotifier.addComponent(newComponent, row, col);
      },
      builder: (context, candidateData, rejectedData) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (details) {
            final tapPos = details.localPosition;
            final col = (tapPos.dx / cellSize).floor();
            final row = (tapPos.dy / cellSize).floor();
            Logger.log('GameCanvas: Tap down at ($row, $col)');
            gameNotifier.handleTap(row, col);
          },
          onPanStart: (details) {
        final startPos = details.localPosition;
        final col = (startPos.dx / cellSize).floor();
        final row = (startPos.dy / cellSize).floor();
        Logger.log('GameCanvas: Pan start at ($row, $col)');

        final component = ref.read(gameEngineProvider).grid.componentsAt(row, col).firstOrNull;
        if (component != null) {
          Logger.log('GameCanvas: Tapped on component ${component.id} of type ${component.type}, isDraggable: ${component.isDraggable}');
          if (component.isDraggable) {
            Logger.log('GameCanvas: Starting drag for component ${component.id}');
            gameNotifier.startDrag(component.id, startPos);
          }
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
              Logger.log('GameCanvas: Pan end for component $draggedId');
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
      },
    );
  }
}
