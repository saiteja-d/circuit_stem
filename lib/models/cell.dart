// lib/models/cell.dart
@Deprecated('Grid now uses ComponentModel.shapeOffsets for occupancy. Use Grid.componentsAt() instead.')
class Cell {
  final int r, c;
  String? componentId;

  Cell({required int row, required int col}) : r = row, c = col;

  bool get hasComponent => componentId != null;
  bool get isEmpty => componentId == null;
}
