import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../common/constants.dart';
import '../engine/render_state.dart';
import '../models/component.dart';
import '../services/asset_manager.dart'; // Ensure this is the correct AssetManager

class CanvasPainter extends CustomPainter {
  final RenderState? renderState;
  final bool showDebugOverlay;
  final AssetManager assetManager;

  CanvasPainter({
    this.renderState,
    required this.showDebugOverlay,
    required this.assetManager,
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
      // _drawDebugOverlay(canvas, size, renderState!.evaluationResult.debugInfo);
      // Debug overlay drawing logic needs to be updated to match new DebugInfo structure
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
      final svgDrawable = assetManager.getSvg(imagePath); // Get SVG DrawableRoot
      
      if (svgDrawable != null) {
        final picture = svgDrawable.toPicture();

        // Apply simple powered tint
        if (isPowered &&
            (comp.type == ComponentType.wireLong || comp.type.toString().contains('wire'))) {
          paint.colorFilter =
              ColorFilter.mode(Colors.orange.withOpacity(0.45), BlendMode.srcATop);
        } else if (isPowered && comp.type == ComponentType.bulb) {
          final intensity = renderState!.bulbIntensity.clamp(0.0, 1.5);
          paint.colorFilter = ColorFilter.mode(
              Colors.yellow.withOpacity((intensity - 0.6).clamp(0.0, 1.0)),
              BlendMode.srcATop);
        } else {
          paint.colorFilter = null;
        }

        canvas.drawPicture(picture, Offset(x, y));
      } else {
        // Fallback drawing
        _drawFallbackComponent(canvas, x, y, isPowered, comp.type);
      }
    }
  }

  void _drawDraggedComponent(Canvas canvas, ComponentModel comp, Offset position) {
    final centerCellX = position.dx;
    final centerCellY = position.dy;
    final anchorX = centerCellX - (cellSize / 2);
    final anchorY = centerCellY - (cellSize / 2);

    for (final off in comp.shapeOffsets) {
      final x = anchorX + off.dc * cellSize;
      final y = anchorY + off.dr * cellSize;
      final imagePath = _getImagePathForComponent(comp, off);
      final svgDrawable = assetManager.getSvg(imagePath);
      
      if (svgDrawable != null) {
        final picture = svgDrawable.toPicture();
        
        final paint = Paint()..color = Colors.white.withOpacity(0.75);
        canvas.drawPicture(picture, Offset(x, y));
      } else {
        _drawFallbackComponent(canvas, x, y, false, comp.type, isDragged: true);
      }
    }
  }

  void _drawFallbackComponent(Canvas canvas, double x, double y, bool isPowered, ComponentType type, {bool isDragged = false}) {
    final rect = Rect.fromLTWH(x + 4, y + 4, cellSize - 8, cellSize - 8);
    
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

    if (isDragged) {
      baseColor = baseColor.withOpacity(0.7);
    }

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(6)),
      Paint()..color = baseColor
    );

    if (isPowered && type != ComponentType.bulb && !isDragged) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(6)),
        Paint()..color = Colors.orange.withOpacity(0.25)
      );
    }

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
        final batteryRect = Rect.fromCenter(center: center, width: iconSize, height: iconSize * 0.6);
        canvas.drawRect(batteryRect, paint);
        canvas.drawLine(
          Offset(batteryRect.right, batteryRect.top + batteryRect.height * 0.3),
          Offset(batteryRect.right, batteryRect.bottom - batteryRect.height * 0.3),
          paint..strokeWidth = 3
        );
        break;
        
      case ComponentType.bulb:
        canvas.drawCircle(center, iconSize / 2, paint);
        if (isPowered) {
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
        canvas.drawLine(
          Offset(center.dx - iconSize/2, center.dy),
          Offset(center.dx + iconSize/2, center.dy - iconSize/3),
          paint
        );
        canvas.drawCircle(Offset(center.dx - iconSize/2, center.dy), 2, paint..style = PaintingStyle.fill);
        canvas.drawCircle(Offset(center.dx + iconSize/2, center.dy), 2, paint..style = PaintingStyle.fill);
        break;
        
      default:
        canvas.drawLine(
          Offset(center.dx - iconSize/2, center.dy),
          Offset(center.dx + iconSize/2, center.dy),
          paint..strokeWidth = 3
        );
    }
  }

  String _getImagePathForComponent(ComponentModel comp, CellOffset partOffset) {
    switch (comp.type) {
      case ComponentType.battery:
        return 'assets/images/battery.svg';
      case ComponentType.bulb:
        final isPowered = renderState?.evaluationResult.poweredComponentIds.contains(comp.id) ?? false;
        return isPowered ? 'assets/images/bulb_on.svg' : 'assets/images/bulb_off.svg';
      case ComponentType.wireStraight:
        return 'assets/images/wire_straight.svg';
      case ComponentType.wireCorner:
        return 'assets/images/wire_corner.svg';
      case ComponentType.wireT:
        return 'assets/images/wire_t.svg';
      case ComponentType.wireLong:
        return 'assets/images/wire_long.svg';
      case ComponentType.sw:
        final isOpen = comp.state['closed'] == true ? false : true;
        return isOpen ? 'assets/images/switch_open.svg' : 'assets/images/switch_closed.svg';
      case ComponentType.timer:
        return 'assets/images/timer.svg';
      default:
        return 'assets/images/placeholder.svg';
    }
  }

  @override
  bool shouldRepaint(covariant CanvasPainter oldDelegate) =>
      oldDelegate.renderState != renderState || oldDelegate.assetManager != assetManager;
}