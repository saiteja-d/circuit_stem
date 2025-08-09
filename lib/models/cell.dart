import 'component.dart';

/// Represents a single cell in the circuit grid.
class Cell {
  final int r, c; // Row and column position
  Component? component; // The component placed in this cell

  Cell({required int row, required int col}) : r = row, c = col;

  /// Creates a [Cell] from a JSON map.
  factory Cell.fromJson(Map<String, dynamic> json) {
    final cell = Cell(row: json['r'] as int, col: json['c'] as int);
    if (json['component'] != null) {
      cell.component = Component.fromJson(json['component'] as Map<String, dynamic>);
    }
    return cell;
  }

  /// Converts this [Cell] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'r': r,
      'c': c,
      'component': component?.toJson(),
    };
  }

  /// Returns `true` if this cell contains a component, `false` otherwise.
  bool get hasComponent => component != null;

  /// Returns `true` if this cell is empty, `false` otherwise.
  bool get isEmpty => component == null;
}