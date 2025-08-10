import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../common/asset_manager.dart';
import '../common/constants.dart';
import '../engine/render_state.dart';
import '../models/component.dart' as model;

class CanvasPainter extends CustomPainter {
  final RenderState? renderState;
  final AssetManager assetManager;

  CanvasPainter({this.renderState, required this.assetManager});

  @override
  void paint(Canvas canvas, Size size) {
    if (renderState == null) return;

    // Draw grid
    _drawGrid(canvas, size, renderState!.grid.rows, renderState!.grid.cols);

    // Draw components
    for (final component in renderState!.components) {
      if (component.id != renderState!.draggedComponentId) {
        _drawComponent(canvas, component);
      }
    }

    // Draw dragged component
    if (renderState!.draggedComponentId != null && renderState!.dragPosition != null) {
      final draggedComponent = renderState!.components.firstWhere((c) => c.id == renderState!.draggedComponentId);
      _drawDraggedComponent(canvas, draggedComponent, renderState!.dragPosition!);
    }
  }

  void _drawGrid(Canvas canvas, Size size, int rows, int cols) {
    final paint = Paint()
      ..color = Colors.grey.shade800
      ..style = PaintingStyle.stroke;

    final cellWidth = cellSize;
    final cellHeight = cellSize;

    for (int i = 0; i <= rows; i++) {
      final y = i * cellHeight;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    for (int i = 0; i <= cols; i++) {
      final x = i * cellWidth;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  void _drawComponent(Canvas canvas, model.Component component) {
    final image = assetManager.getImageFromCache(_getImagePathForComponent(component));
    if (image != null) {
      final x = component.c * cellSize;
      final y = component.r * cellSize;
      
      final paint = Paint();
      if (component.type.toString().contains('wire') && renderState!.evaluationResult.poweredComponentIds.contains(component.id)) {
        // Apply a color filter for powered wires
        paint.colorFilter = ColorFilter.mode(Colors.orange.withOpacity(0.5), BlendMode.srcATop);
      } else if (component.type == 'bulb' && renderState!.evaluationResult.poweredComponentIds.contains(component.id)) {
        // Apply a color filter for powered bulbs with intensity
        final intensity = renderState!.bulbIntensity;
        paint.colorFilter = ColorFilter.mode(Colors.yellow.withOpacity(intensity - 0.8), BlendMode.srcATop);
      }

      canvas.drawImageRect(
        image,
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
        Rect.fromLTWH(x, y, cellSize, cellSize),
        paint,
      );
    }
  }

  void _drawDraggedComponent(Canvas canvas, model.Component component, Offset position) {
    final image = assetManager.getImageFromCache(_getImagePathForComponent(component));
    if (image != null) {
      final x = position.dx - cellSize / 2;
      final y = position.dy - cellSize / 2;
      canvas.drawImageRect(
        image,
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
        Rect.fromLTWH(x, y, cellSize, cellSize),
        Paint()..color = Colors.white.withOpacity(0.7),
      );
    }
  }

  String _getImagePathForComponent(model.Component component) {
    switch (component.type) {
      case 'battery':
        return 'images/battery.png';
      case 'bulb':
        final isPowered = renderState?.evaluationResult.poweredComponentIds.contains(component.id) ?? false;
        return isPowered ? 'images/bulb_on.png' : 'images/bulb_off.png';
      case 'wire_straight':
        return 'images/wire_straight.png';
      case 'wire_corner':
        return 'images/wire_corner.png';
      case 'wire_t':
        return 'images/wire_t.png';
      case 'circuit_switch':
        final isSwitchOpen = component.state['switchOpen'] as bool? ?? false;
        return isSwitchOpen ? 'images/switch_open.png' : 'images/switch_closed.png';
      default:
        return '';
    }
  }

  @override
  bool shouldRepaint(covariant CanvasPainter oldDelegate) {
    return oldDelegate.renderState != renderState;
  }
}