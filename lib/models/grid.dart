import 'cell.dart';
import 'component.dart';

/// Represents the game grid, composed of [Cell] objects.
class Grid {
  final int rows, cols;
  late final List<List<Cell>> cells;

  Grid({required this.rows, required this.cols}) {
    cells = List.generate(rows, (r) => List.generate(cols, (c) => Cell(row: r, col: c)));
  }

  /// Creates a [Grid] from a JSON map.
  factory Grid.fromJson(Map<String, dynamic> json) {
    final rows = json['rows'] as int;
    final cols = json['cols'] as int;
    final List<dynamic> cellData = json['cells'] as List<dynamic>;

    final grid = Grid(rows: rows, cols: cols);
    for (final cellJson in cellData) {
      final cell = Cell.fromJson(cellJson as Map<String, dynamic>);
      grid.cells[cell.r][cell.c] = cell;
    }
    return grid;
  }

  /// Converts this [Grid] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'rows': rows,
      'cols': cols,
      'cells': allCells().map((cell) => cell.toJson()).toList(),
    };
  }

  /// Checks if the given row and column are within the grid boundaries.
  bool inBounds(int r, int c) => r >= 0 && r < rows && c >= 0 && c < cols;

  /// Returns the [Cell] at the specified row and column.
  /// Throws a [RangeError] if the coordinates are out of bounds.
  Cell cellAt(int r, int c) {
    if (!inBounds(r, c)) throw RangeError('Cell out of bounds: $r,$c');
    return cells[r][c];
  }

  /// Places a [Component] at the specified row and column.
  /// Returns `true` if the component was successfully placed, `false` otherwise.
  bool placeComponent(int r, int c, Component comp, {bool overwrite = false}) {
    if (!inBounds(r, c)) return false;
    if (!overwrite && cells[r][c].component != null) return false;
    cells[r][c].component = comp;
    comp.normalizeRotation();
    comp.r = r;
    comp.c = c;
    return true;
  }

  /// Removes the [Component] from the specified row and column.
  /// Returns `true` if a component was successfully removed, `false` otherwise.
  bool removeComponent(int r, int c) {
    if (!inBounds(r, c)) return false;
    if (cells[r][c].component == null) return false;
    cells[r][c].component = null;
    return true;
  }

  /// Returns an iterable of all [Cell] objects in the grid.
  Iterable<Cell> allCells() sync* {
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        yield cells[r][c];
      }
    }
  }
}
