import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:circuit_stem/models/component.dart';
import 'package:circuit_stem/models/level_definition.dart';
import 'package:circuit_stem/ui/widgets/circuit_component_display.dart';
import 'package:circuit_stem/common/theme.dart';
import 'package:circuit_stem/common/constants.dart';

class CircuitGrid extends StatefulWidget {
  final LevelDefinition level;
  final List<ComponentModel> components;
  final Function(ComponentModel component, int x, int y) onComponentPlaced;
  final Function(ComponentModel component) onComponentTapped;
  final ComponentModel? selectedComponent; // Component selected from palette

  const CircuitGrid({
    Key? key,
    required this.level,
    required this.components,
    required this.onComponentPlaced,
    required this.onComponentTapped,
    this.selectedComponent,
  }) : super(key: key);

  @override
  State<CircuitGrid> createState() => _CircuitGridState();
}

class _CircuitGridState extends State<CircuitGrid> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? DarkModeColors.circuitBoard : LightModeColors.circuitBoard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: CustomPaint(
        painter: _GridPainter(
          gridWidth: widget.level.cols,
          gridHeight: widget.level.rows,
          cellSize: cellSize,
          isDark: isDark,
        ),
        child: SizedBox(
          width: widget.level.cols * cellSize,
          height: widget.level.rows * cellSize,
          child: Stack(
            children: [
              // Grid interaction layer (DragTargets)
              ...List.generate(
                widget.level.rows,
                (y) => Row(
                  children: List.generate(
                    widget.level.cols,
                    (x) => _GridCell(
                      x: x,
                      y: y,
                      size: cellSize,
                      onTap: () => _onGridCellTapped(x, y),
                      hasComponent: _hasComponentAt(x, y),
                      onComponentDropped: (component) =>
                          widget.onComponentPlaced(component, x, y),
                      isDark: isDark,
                    ),
                  ),
                ),
              ),
              // Components layer
              ...widget.components.map((component) => Positioned(
                    left: component.c * cellSize,
                    top: component.r * cellSize,
                    child: GestureDetector(
                      onTap: () => widget.onComponentTapped(component),
                      child: CircuitComponentDisplay(
                        component: component,
                        size: cellSize,
                      ),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  void _onGridCellTapped(int x, int y) {
    // If a component is selected from the palette, attempt to place it
    if (widget.selectedComponent != null && !_hasComponentAt(x, y)) {
      widget.onComponentPlaced(widget.selectedComponent!, x, y);
    } else {
      // If no component is selected, or if there's already a component, handle tap on existing component
      final tappedComponent = widget.components.firstWhereOrNull(
        (c) => c.c == x && c.r == y,
      );
      if (tappedComponent != null) {
        widget.onComponentTapped(tappedComponent);
      }
    }
  }

  bool _hasComponentAt(int x, int y) {
    return widget.components.any((c) => c.c == x && c.r == y);
  }
}

class _GridCell extends StatelessWidget {
  final int x;
  final int y;
  final double size;
  final VoidCallback onTap;
  final bool hasComponent;
  final Function(ComponentModel component) onComponentDropped;
  final bool isDark;

  const _GridCell({
    Key? key,
    required this.x,
    required this.y,
    required this.size,
    required this.onTap,
    required this.hasComponent,
    required this.onComponentDropped,
    required this.isDark,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DragTarget<ComponentModel>(
      onAcceptWithDetails: (details) {
        if (!hasComponent) {
          onComponentDropped(details.data);
        }
      },
      builder: (context, candidateData, rejectedData) {
        final isHighlighted = candidateData.isNotEmpty && !hasComponent;

        return GestureDetector(
          onTap: onTap,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: isHighlighted
                  ? Theme.of(context).colorScheme.primary.withAlpha(51)
                  : Colors.transparent,
              border: Border.all(
                color: hasComponent
                    ? Colors.transparent
                    : isHighlighted
                        ? Theme.of(context).colorScheme.primary
                        : isDark
                            ? DarkModeColors.gridLines.withAlpha(77)
                            : LightModeColors.gridLines.withAlpha(128),
                width: isHighlighted ? 2.0 : 0.5,
              ),
              borderRadius: isHighlighted ? BorderRadius.circular(4) : null,
            ),
          ),
        );
      },
    );
  }
}

class _GridPainter extends CustomPainter {
  final int gridWidth;
  final int gridHeight;
  final double cellSize;
  final bool isDark;

  _GridPainter({
    required this.gridWidth,
    required this.gridHeight,
    required this.cellSize,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark
          ? DarkModeColors.gridLines.withAlpha(51)
          : LightModeColors.gridLines.withAlpha(77)
      ..strokeWidth = 0.5;

    // Draw vertical lines
    for (int i = 0; i <= gridWidth; i++) {
      canvas.drawLine(
        Offset(i * cellSize, 0),
        Offset(i * cellSize, gridHeight * cellSize),
        paint,
      );
    }

    // Draw horizontal lines
    for (int i = 0; i <= gridHeight; i++) {
      canvas.drawLine(
        Offset(0, i * cellSize),
        Offset(gridWidth * cellSize, i * cellSize),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_GridPainter oldDelegate) => false;
}