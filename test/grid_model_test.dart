import 'package:flutter_test/flutter_test.dart';
import 'package:circuit_stem/models/grid.dart';
import 'package:circuit_stem/models/component.dart';

void main() {
  test('placeComponent places a component on the grid', () {
    final grid = Grid(rows: 3, cols: 3);
    final component = Component(id: 'c1', type: ComponentType.battery);
    grid.placeComponent(1, 1, component);
    expect(grid.cellAt(1, 1).component, component);
  });

  test('removeComponent removes a component from the grid', () {
    final grid = Grid(rows: 3, cols: 3);
    final component = Component(id: 'c1', type: ComponentType.battery);
    grid.placeComponent(1, 1, component);
    grid.removeComponent(1, 1);
    expect(grid.cellAt(1, 1).component, null);
  });
}
