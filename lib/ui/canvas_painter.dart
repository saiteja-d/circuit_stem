// lib/ui/canvas_painter.dart
import 'package:flutter/material.dart';
import '../common/asset_manager.dart';
import '../common/constants.dart';
import '../engine/render_state.dart';
import '../models/component.dart';
import '../services/logic_engine.dart';

class CanvasPainter extends CustomPainter {
  final RenderState? renderState;
  final AssetManager assetManager;
  final bool showDebugOverlay;

  CanvasPainter({this.renderState, required this.assetManager, required this.showDebugOverlay});

  @override
  void paint(Canvas canvas, Size size) {
    if (renderState == null) return;

    final grid = renderState!.grid;
    _drawGrid(canvas, size, grid.rows, grid.cols);

    // draw all components except dragged preview
    for (final comp in renderState!.grid.componentsById.values) {
      if (comp.id != renderState!.draggedComponentId) {
        _drawComponent(canvas, comp);
      }
    }

    // dragged preview
    if (renderState!.draggedComponentId != null && renderState!.dragPosition != null) {
      final comp = renderState!.grid.componentsById[renderState!.draggedComponentId!];
      if (comp != null) _drawDraggedComponent(canvas, comp, renderState!.dragPosition!);
    }

    // debug overlay (terminals, adjacency, BFS)
    if (showDebugOverlay) {
      _drawDebugOverlay(canvas, size, renderState!.evaluationResult.debugInfo);
    }
  }

  void _drawGrid(Canvas canvas, Size size, int rows, int cols) {
    final paint = Paint()..color = Colors.grey.shade300..style = PaintingStyle.stroke;
    const double cw = cellSize, ch = cellSize;
    for (int i = 0; i <= rows; i++) {
      canvas.drawLine(Offset(0, i * ch), Offset(cols * cw, i * ch), paint);
    }
    for (int j = 0; j <= cols; j++) {
      canvas.drawLine(Offset(j * cw, 0), Offset(j * cw, rows * ch), paint);
    }
  }

  void _drawComponent(Canvas canvas, ComponentModel comp) {
    final isPowered = renderState!.evaluationResult.poweredComponentIds.contains(comp.id);
    final paint = Paint();
    for (final off in comp.shapeOffsets) {
      final x = (comp.c + off.dc) * cellSize;
      final y = (comp.r + off.dr) * cellSize;
      final imagePath = _getImagePathForComponent(comp, off);
      final image = assetManager.getImageFromCache(imagePath);
      if (image != null) {
        // source rect
        final src = Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
        final dst = Rect.fromLTWH(x, y, cellSize, cellSize);

        // apply simple powered tint
        if (isPowered && (comp.type == ComponentType.wireLong || comp.type.toString().contains('wire'))) {
          paint.colorFilter = ColorFilter.mode(Colors.orange.withOpacity(0.45), BlendMode.srcATop);
        } else if (isPowered && comp.type == ComponentType.bulb) {
          final intensity = renderState!.bulbIntensity.clamp(0.0, 1.5);
          paint.colorFilter = ColorFilter.mode(Colors.yellow.withOpacity((intensity - 0.6).clamp(0.0, 1.0)), BlendMode.srcATop);
        } else {
          paint.colorFilter = null;
        }

        canvas.drawImageRect(image, src, dst, paint);
      } else {
        // fallback simple vector drawing
        final rect = Rect.fromLTWH(x + 4, y + 4, cellSize - 8, cellSize - 8);
        canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(6)), Paint()..color = Colors.blueGrey.shade200);
        if (isPowered) {
          canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(6)), Paint()..color = Colors.orange.withOpacity(0.25));
        }
      }
    }
  }

  void _drawDraggedComponent(Canvas canvas, ComponentModel comp, Offset position) {
    // center preview at pointer; draw all offsets relative to pointer
    final centerCellX = position.dx;
    final centerCellY = position.dy;
    final anchorX = centerCellX - (cellSize / 2);
    final anchorY = centerCellY - (cellSize / 2);

    for (final off in comp.shapeOffsets) {
      final x = anchorX + off.dc * cellSize;
      final y = anchorY + off.dr * cellSize;
      final imagePath = _getImagePathForComponent(comp, off);
      final image = assetManager.getImageFromCache(imagePath);
      if (image != null) {
        final src = Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
        final dst = Rect.fromLTWH(x, y, cellSize, cellSize);
        canvas.drawImageRect(image, src, dst, Paint()..color = Colors.white.withOpacity(0.75));
      } else {
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x + 4, y + 4, cellSize - 8, cellSize - 8), const Radius.circular(6)), Paint()..color = Colors.white.withOpacity(0.7));
      }
    }
  }

  String _getImagePathForComponent(ComponentModel comp, CellOffset partOffset) {
    // Basic mapping by ComponentType; extend to map offsets -> sub-images if needed.
    switch (comp.type) {
      case ComponentType.battery:
        return 'images/battery.png';
      case ComponentType.bulb:
        final isPowered = renderState?.evaluationResult.poweredComponentIds.contains(comp.id) ?? false;
        return isPowered ? 'images/bulb_on.png' : 'images/bulb_off.png';
      case ComponentType.wireStraight:
        return 'images/wire_straight.png';
      case ComponentType.wireCorner:
        return 'images/wire_corner.png';
      case ComponentType.wireT:
        return 'images/wire_t.png';
      case ComponentType.wireLong:
        return 'images/wire_long.png';
      case ComponentType.sw:
        final isOpen = comp.state['closed'] == true ? false : true;
        return isOpen ? 'images/switch_open.png' : 'images/switch_closed.png';
      default:
        return 'images/placeholder.png';
    }
  }

  void _drawDebugOverlay(Canvas canvas, Size size, DebugInfo debugInfo) {
    final termPaint = Paint()..color = Colors.black;
    final adjPaint = Paint()..color = Colors.blue.withOpacity(0.5)..strokeWidth = 2;
    final bfsPaint = Paint()..color = Colors.green.withOpacity(0.9);

    // draw adjacency edges
    for (final entry in debugInfo.adjacency.entries) {
      final from = debugInfo.terminals[entry.key];
      if (from == null) continue;
      for (final toId in entry.value) {
        final to = debugInfo.terminals[toId];
        if (to == null) continue;
        final fx = (from.c + 0.5) * cellSize;
        final fy = (from.r + 0.5) * cellSize;
        final tx = (to.c + 0.5) * cellSize;
        final ty = (to.r + 0.5) * cellSize;
        canvas.drawLine(Offset(fx, fy), Offset(tx, ty), adjPaint);
      }
    }

    // draw terminals and labels
    debugInfo.terminals.forEach((id, t) {
      final cx = (t.c + 0.5) * cellSize;
      final cy = (t.r + 0.5) * cellSize;
      canvas.drawCircle(Offset(cx, cy), 6, termPaint);
      if (t.label != null) {
        final tp = TextPainter(text: TextSpan(text: t.label, style: const TextStyle(color: Colors.black, fontSize: 10)), textDirection: TextDirection.ltr);
        tp.layout();
        tp.paint(canvas, Offset(cx + 6, cy - tp.height / 2));
      }
    });

    // highlight discovered pos->neg paths (if any)
    for (final path in debugInfo.posToNegPaths) {
      for (var i = 0; i + 1 < path.length; i++) {
        final a = debugInfo.terminals[path[i]];
        final b = debugInfo.terminals[path[i + 1]];
        if (a == null || b == null) continue;
        final ax = (a.c + 0.5) * cellSize, ay = (a.r + 0.5) * cellSize;
        final bx = (b.c + 0.5) * cellSize, by = (b.r + 0.5) * cellSize;
        canvas.drawLine(Offset(ax, ay), Offset(bx, by), Paint()..color = Colors.red..strokeWidth = 3);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CanvasPainter oldDelegate) => oldDelegate.renderState != renderState;
}
