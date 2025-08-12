import 'package:flutter/material.dart';
import 'package:circuit_stem/models/circuit_component.dart';
import 'package:circuit_stem/models/game_level.dart';
import 'package:circuit_stem/widgets/circuit_component_widget.dart';
// ...existing code...

class CircuitGrid extends StatefulWidget {
  final GameLevel level;
  final List<CircuitComponent> components;
  final Function(CircuitComponent component, int x, int y) onComponentPlaced;
  final Function(int x, int y)? onCellTap;
  final bool showGridLines;
  final Function(double) onPositionChanged;

  const CircuitGrid({
    Key? key,
    required this.level,
    required this.components,
    required this.onComponentPlaced,
    this.onCellTap,
    this.showGridLines = true,
    required this.onPositionChanged,
  }) : super(key: key);

  @override
  _CircuitGridState createState() => _CircuitGridState();
}

class _CircuitGridState extends State<CircuitGrid> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: CustomPaint(
        painter: _GridPainter(
          cellSize: widget.level.cellSize.toDouble(),
          showGridLines: widget.showGridLines,
          isDark: isDark,
        ),
        child: SizedBox(
          width: (widget.level.width * widget.level.cellSize).toDouble(),
          height: (widget.level.height * widget.level.cellSize).toDouble(),
          child: Stack(
            children: [
              ...widget.components.map((component) {
                final index = widget.components.indexOf(component);
                final cells = List.generate(widget.level.width, (x) {
                  return List.generate(widget.level.height, (y) {
                    if (x == widget.components[index].x && y == widget.components[index].y) {
                      return _GridCell(
                        x: x,
                        y: y,
                        component: component,
                        onDrop: widget.onComponentPlaced,
                        onTap: widget.onCellTap != null ? () => widget.onCellTap!(x, y) : null,
                        cellSize: widget.level.cellSize.toDouble(),
                        isDark: isDark,
                      );
                    }
                    return const SizedBox();
                  });
                }).expand((row) => row);
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: cells.toList(),
                );
              }).toList(),
              for (CircuitComponent component in widget.components)
                Positioned(
                  left: (component.x * widget.level.cellSize).toDouble(),
                  top: (component.y * widget.level.cellSize).toDouble(),
                  child: CircuitComponentWidget(
                    key: ValueKey('${component.type}_${component.x}_${component.y}'),
                    component: component,
                    size: widget.level.cellSize.toDouble(),
                    onTap: widget.onCellTap != null 
                        ? () => widget.onCellTap!(component.x, component.y)
                        : null,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GridCell extends StatelessWidget {
  final int x;
  final int y;
  final CircuitComponent? component;
  final Function(CircuitComponent component, int x, int y) onDrop;
  final VoidCallback? onTap;
  final double cellSize;
  final bool isDark;

  const _GridCell({
    Key? key,
    required this.x,
    required this.y,
    this.component,
    required this.onDrop,
    this.onTap,
    required this.cellSize,
    required this.isDark,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DragTarget<CircuitComponent>(
      onWillAcceptWithDetails: (details) => true,
      onAcceptWithDetails: (details) => onDrop(details.data, x, y),
      builder: (context, candidateData, rejectedData) {
        return GestureDetector(
          onTap: onTap,
          child: Container(
            width: cellSize,
            height: cellSize,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border.all(
                color: Colors.grey.withOpacity(0.3),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      },
    );
  }
}

class _GridPainter extends CustomPainter {
  final double cellSize;
  final bool showGridLines;
  final bool isDark;

  _GridPainter({
    required this.cellSize,
    required this.showGridLines,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!showGridLines) return;
    
    final paint = Paint()
      ..color = isDark ? Colors.grey[800]! : Colors.grey[300]!
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (double i = 0; i <= size.width; i += cellSize) {
      final p1 = Offset(i, 0);
      final p2 = Offset(i, size.height);
      canvas.drawLine(p1, p2, paint);
    }

    for (double i = 0; i <= size.height; i += cellSize) {
      final p1 = Offset(0, i);
      final p2 = Offset(size.width, i);
      canvas.drawLine(p1, p2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
