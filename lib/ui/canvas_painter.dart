
import 'package:flutter/material.dart';
import '../common/constants.dart';
import '../engine/render_state.dart';
import '../models/component.dart';
import '../services/asset_manager_state.dart';

import 'painters/circuit_component_painter.dart';

class CanvasPainter extends CustomPainter {
  final RenderState? renderState;
  final bool showDebugOverlay;
  final AssetState assetState;
  final bool isDark;
  final Color gridColor;
  final Color draggedComponentBackgroundColor;

  CanvasPainter({
    this.renderState,
    this.showDebugOverlay = false,
    required this.assetState,
    required this.isDark,
    required this.gridColor,
    required this.draggedComponentBackgroundColor,
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
  }

  void _drawGrid(Canvas canvas, Size size, int rows, int cols) {
    final paint = Paint()
      ..color = gridColor
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
    final isSwitchClosed = comp.type == ComponentType.sw ? (comp.state['closed'] == true) : false;

    for (final off in comp.shapeOffsets) {
      final x = (comp.c + off.dc) * cellSize;
      final y = (comp.r + off.dr) * cellSize;

      final painter = CircuitComponentPainter(
        component: comp,
        isPowered: isPowered,
        isSwitchClosed: isSwitchClosed,
        isDark: isDark,
        partOffset: off,
      );

      canvas.save();
      canvas.translate(x, y);
      painter.paint(canvas, const Size(cellSize, cellSize));
      canvas.restore();
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
      
      final painter = CircuitComponentPainter(
        component: comp,
        isPowered: false, // No power effect on dragged component
        isSwitchClosed: false,
        isDark: isDark,
        partOffset: off,
      );

      canvas.save();
      canvas.translate(x, y);
      final paint = Paint()..color = draggedComponentBackgroundColor;
      canvas.drawRect(const Offset(0,0) & const Size(cellSize, cellSize), paint);
      painter.paint(canvas, const Size(cellSize, cellSize));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CanvasPainter oldDelegate) =>
      oldDelegate.renderState != renderState ||
      oldDelegate.assetState != assetState ||
      oldDelegate.isDark != isDark ||
      oldDelegate.gridColor != gridColor ||
      oldDelegate.draggedComponentBackgroundColor != draggedComponentBackgroundColor;
}