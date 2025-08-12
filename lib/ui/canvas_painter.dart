import 'dart:math';
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

  CanvasPainter({
    this.renderState,
    required this.assetManager,
    required this.showDebugOverlay,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (renderState == null) return;

    final grid = renderState!.grid;
    _drawGrid(canvas, size, grid.rows, grid.cols);

    // Draw all components except dragged preview
    for (final comp in renderState!.grid.componentsById.values) {
      if (comp.id != renderState!.draggedComponentId) {
        _drawComponent(canvas, comp);
      }
    }

    // Draw dragged preview
    if (renderState!.draggedComponentId != null && renderState!.dragPosition != null) {
      final comp = renderState!.grid.componentsById[renderState!.draggedComponentId!];
      if (comp != null) _drawDraggedComponent(canvas, comp, renderState!.dragPosition!);
    }

    // Draw debug overlay if enabled
    if (showDebugOverlay) {
      _drawDebugOverlay(canvas, size, renderState!.evaluationResult.debugInfo);
    }
  }

  void _drawGrid(Canvas canvas, Size size, int rows, int cols) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke;
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
        final src = Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
        final dst = Rect.fromLTWH(x, y, cellSize, cellSize);

        // Apply simple powered tint
        if (isPowered &&
            (comp.type == ComponentType.wireLong || comp.type.toString().contains('wire'))) {
          paint.colorFilter =
              ColorFilter.mode(Colors.orange.withAlpha((0.45 * 255).round()), BlendMode.srcATop);
        } else if (isPowered && comp.type == ComponentType.bulb) {
          final intensity = renderState!.bulbIntensity.clamp(0.0, 1.5);
          paint.colorFilter = ColorFilter.mode(
              Colors.yellow.withAlpha(((intensity - 0.6).clamp(0.0, 1.0) * 255).round()),
              BlendMode.srcATop);
        } else {
          paint.colorFilter = null;
        }

        canvas.drawImageRect(image, src, dst, paint);
      } else {
        // Enhanced fallback drawing with component-specific styling
        _drawFallbackComponent(canvas, x, y, isPowered, comp.type);
      }
    }
  }

  void _drawDraggedComponent(Canvas canvas, ComponentModel comp, Offset position) {
    // Center preview at pointer; draw all offsets relative to pointer
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
        
        // Apply transparency for drag preview
        final paint = Paint()..color = Colors.white.withAlpha((0.75 * 255).round());
        canvas.drawImageRect(image, src, dst, paint);
      } else {
        // Fallback for dragged component
        _drawFallbackComponent(canvas, x, y, false, comp.type, isDragged: true);
      }
    }
  }

  void _drawFallbackComponent(Canvas canvas, double x, double y, bool isPowered, ComponentType type, {bool isDragged = false}) {
    final rect = Rect.fromLTWH(x + 4, y + 4, cellSize - 8, cellSize - 8);
    
    // Base color based on component type
    Color baseColor;
    switch (type) {
      case ComponentType.battery:
        baseColor = Colors.red.shade200;
        break;
      case ComponentType.bulb:
        baseColor = isPowered ? Colors.yellow.shade300 : Colors.grey.shade300;
        break;
      case ComponentType.sw:
        baseColor = Colors.blue.shade200;
        break;
      case ComponentType.wireStraight:
      case ComponentType.wireCorner:
      case ComponentType.wireT:
      case ComponentType.wireLong:
        baseColor = isPowered ? Colors.orange.shade300 : Colors.blueGrey.shade200;
        break;
      default:
        baseColor = Colors.blueGrey.shade200;
    }

    // Apply drag transparency
    if (isDragged) {
      baseColor = baseColor.withAlpha((0.7 * 255).round());
    }

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(6)),
      Paint()..color = baseColor
    );

    // Add powered overlay (except for bulbs which change base color)
    if (isPowered && type != ComponentType.bulb && !isDragged) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(6)),
        Paint()..color = Colors.orange.withAlpha((0.25 * 255).round())
      );
    }

    // Draw simple component indicators
    _drawComponentIcon(canvas, rect, type, isPowered);
  }

  void _drawComponentIcon(Canvas canvas, Rect rect, ComponentType type, bool isPowered) {
    final paint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final center = rect.center;
    final iconSize = rect.width * 0.3;

    switch (type) {
      case ComponentType.battery:
        // Draw battery symbol
        final batteryRect = Rect.fromCenter(center: center, width: iconSize, height: iconSize * 0.6);
        canvas.drawRect(batteryRect, paint);
        // Battery terminal
        canvas.drawLine(
          Offset(batteryRect.right, batteryRect.top + batteryRect.height * 0.3),
          Offset(batteryRect.right, batteryRect.bottom - batteryRect.height * 0.3),
          paint..strokeWidth = 3
        );
        break;
        
      case ComponentType.bulb:
        // Draw light bulb circle
        canvas.drawCircle(center, iconSize / 2, paint);
        if (isPowered) {
          // Draw light rays
          for (int i = 0; i < 8; i++) {
            final angle = (i * 45) * (3.14159 / 180);
            final start = Offset(
              center.dx + (iconSize / 2 + 2) * cos(angle),
              center.dy + (iconSize / 2 + 2) * sin(angle)
            );
            final end = Offset(
              center.dx + (iconSize / 2 + 6) * cos(angle),
              center.dy + (iconSize / 2 + 6) * sin(angle)
            );
            canvas.drawLine(start, end, paint);
          }
        }
        break;
        
      case ComponentType.sw:
        // Draw switch
        canvas.drawLine(
          Offset(center.dx - iconSize/2, center.dy),
          Offset(center.dx + iconSize/2, center.dy - iconSize/3),
          paint
        );
        canvas.drawCircle(Offset(center.dx - iconSize/2, center.dy), 2, paint..style = PaintingStyle.fill);
        canvas.drawCircle(Offset(center.dx + iconSize/2, center.dy), 2, paint..style = PaintingStyle.fill);
        break;
        
      default:
        // Draw simple line for wires
        canvas.drawLine(
          Offset(center.dx - iconSize/2, center.dy),
          Offset(center.dx + iconSize/2, center.dy),
          paint..strokeWidth = 3
        );
    }
  }

  String _getImagePathForComponent(ComponentModel comp, CellOffset partOffset) {
    // Updated to use SVG files
    switch (comp.type) {
      case ComponentType.battery:
        return 'images/battery.svg';
      case ComponentType.bulb:
        final isPowered = renderState?.evaluationResult.poweredComponentIds.contains(comp.id) ?? false;
        return isPowered ? 'images/bulb_on.svg' : 'images/bulb_off.svg';
      case ComponentType.wireStraight:
        return 'images/wire_straight.svg';
      case ComponentType.wireCorner:
        return 'images/wire_corner.svg';
      case ComponentType.wireT:
        return 'images/wire_t.svg';
      case ComponentType.wireLong:
        return 'images/wire_long.svg';
      case ComponentType.sw:
        final isOpen = comp.state['closed'] == true ? false : true;
        return isOpen ? 'images/switch_open.svg' : 'images/switch_closed.svg';
      case ComponentType.timer:
        return 'images/timer.svg';
      default:
        return 'images/placeholder.svg';
    }
  }

  void _drawDebugOverlay(Canvas canvas, Size size, DebugInfo debugInfo) {
    final termPaint = Paint()..color = Colors.black;
    final adjPaint = Paint()
      ..color = Colors.blue.withAlpha((0.5 * 255).round())
      ..strokeWidth = 2;

    // Draw adjacency edges
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

    // Draw terminals and labels
    debugInfo.terminals.forEach((id, t) {
      final cx = (t.c + 0.5) * cellSize;
      final cy = (t.r + 0.5) * cellSize;
      canvas.drawCircle(Offset(cx, cy), 6, termPaint);
      if (t.label != null) {
        final tp = TextPainter(
          text: TextSpan(text: t.label, style: const TextStyle(color: Colors.black, fontSize: 10)),
          textDirection: TextDirection.ltr,
        );
        tp.layout();
        tp.paint(canvas, Offset(cx + 6, cy - tp.height / 2));
      }
    });

    // Highlight discovered pos->neg paths (if any)
    for (final path in debugInfo.posToNegPaths) {
      for (var i = 0; i + 1 < path.length; i++) {
        final a = debugInfo.terminals[path[i]];
        final b = debugInfo.terminals[path[i + 1]];
        if (a == null || b == null) continue;
        final ax = (a.c + 0.5) * cellSize, ay = (a.r + 0.5) * cellSize;
        final bx = (b.c + 0.5) * cellSize, by = (b.r + 0.5) * cellSize;
        canvas.drawLine(
          Offset(ax, ay),
          Offset(bx, by),
          Paint()
            ..color = Colors.red
            ..strokeWidth = 3,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CanvasPainter oldDelegate) =>
      oldDelegate.renderState != renderState;
}