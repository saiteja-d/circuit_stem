import 'package:flutter/material.dart';
import 'package:stemcir/models/circuit_component.dart';
import 'package:stemcir/models/game_level.dart';
import 'package:stemcir/widgets/circuit_component_widget.dart';
import 'package:stemcir/theme.dart';

class CircuitGrid extends StatefulWidget {
  final GameLevel level;
  final List<CircuitComponent> components;
  final Function(CircuitComponent component, int x, int y) onComponentPlaced;
  final Function(CircuitComponent component) onComponentTapped;
  final CircuitComponent? selectedComponent;
  
  const CircuitGrid({
    super.key,
    required this.level,
    required this.components,
    required this.onComponentPlaced,
    required this.onComponentTapped,
    this.selectedComponent,
  });

  @override
  State<CircuitGrid> createState() => _CircuitGridState();
}

class _CircuitGridState extends State<CircuitGrid> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cellSize = 50.0;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? DarkModeColors.circuitBoard : LightModeColors.circuitBoard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: CustomPaint(
        painter: _GridPainter(
          gridWidth: widget.level.gridWidth,
          gridHeight: widget.level.gridHeight,
          cellSize: cellSize,
          isDark: isDark,
        ),
        child: SizedBox(
          width: widget.level.gridWidth * cellSize,
          height: widget.level.gridHeight * cellSize,
          child: Stack(
            children: [
              // Grid interaction layer
              ...List.generate(
                widget.level.gridHeight,
                (y) => Row(
                  children: List.generate(
                    widget.level.gridWidth,
                    (x) => _GridCell(
                      x: x,
                      y: y,
                      size: cellSize,
                      onTap: () => _onGridCellTapped(x, y),
                      hasComponent: _hasComponentAt(x, y),
                      onComponentDropped: (component) => widget.onComponentPlaced(component, x, y),
                    ),
                  ),
                ),
              ),
              // Components layer
              ...widget.components.map((component) => Positioned(
                left: component.x * cellSize,
                top: component.y * cellSize,
                child: CircuitComponentWidget(
                  component: component,
                  size: cellSize,
                  onTap: () => widget.onComponentTapped(component),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
  
  void _onGridCellTapped(int x, int y) {
    if (widget.selectedComponent != null && !_hasComponentAt(x, y)) {
      widget.onComponentPlaced(widget.selectedComponent!, x, y);
    }
  }
  
  bool _hasComponentAt(int x, int y) {
    return widget.components.any((c) => c.x == x && c.y == y);
  }
}

class _GridCell extends StatelessWidget {
  final int x;
  final int y;
  final double size;
  final VoidCallback onTap;
  final bool hasComponent;
  final Function(CircuitComponent component) onComponentDropped;
  
  const _GridCell({
    required this.x,
    required this.y,
    required this.size,
    required this.onTap,
    required this.hasComponent,
    required this.onComponentDropped,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<CircuitComponent>(
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
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)
                  : Colors.transparent,
              border: Border.all(
                color: hasComponent 
                    ? Colors.transparent 
                    : isHighlighted
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).brightness == Brightness.dark
                            ? DarkModeColors.gridLines.withValues(alpha: 0.3)
                            : LightModeColors.gridLines.withValues(alpha: 0.5),
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
          ? DarkModeColors.gridLines.withValues(alpha: 0.2)
          : LightModeColors.gridLines.withValues(alpha: 0.3)
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