import 'package:flutter_test/flutter_test.dart';
import 'package:circuit_stem/models/grid.dart';
import 'package:circuit_stem/models/component.dart';

void main() {
  group('Grid Model Tests', () {
    test('addComponent places a component on the grid', () {
      final grid = Grid(rows: 3, cols: 3);
      final component = ComponentModel(id: 'c1', type: ComponentType.battery, r: 1, c: 1);
      final placed = grid.addComponent(component);
      expect(placed, isTrue);
      expect(grid.componentsAt(1, 1).first, component);
    });

    test('addComponent fails if component is out of bounds', () {
      final grid = Grid(rows: 3, cols: 3);
      final component = ComponentModel(id: 'c1', type: ComponentType.battery, r: 3, c: 3); // Out of bounds
      final placed = grid.addComponent(component);
      expect(placed, isFalse);
    });

    test('addComponent fails if component overlaps existing component', () {
      final grid = Grid(rows: 3, cols: 3);
      final component1 = ComponentModel(id: 'c1', type: ComponentType.battery, r: 1, c: 1);
      final component2 = ComponentModel(id: 'c2', type: ComponentType.bulb, r: 1, c: 1);
      grid.addComponent(component1);
      final placed = grid.addComponent(component2);
      expect(placed, isFalse);
    });

    test('removeComponent removes a component from the grid', () {
      final grid = Grid(rows: 3, cols: 3);
      final component = ComponentModel(id: 'c1', type: ComponentType.battery, r: 1, c: 1);
      grid.addComponent(component);
      expect(grid.componentsAt(1, 1).first, component);

      grid.removeComponent(component.id);
      expect(grid.componentsAt(1, 1), isEmpty);
    });

    test('updateComponent moves a component to a new valid position', () {
      final grid = Grid(rows: 3, cols: 3);
      final component = ComponentModel(id: 'c1', type: ComponentType.battery, r: 1, c: 1);
      grid.addComponent(component);

      final updatedComponent = component.copyWith(r: 2, c: 2);
      final success = grid.updateComponent(updatedComponent);

      expect(success, isTrue);
      expect(grid.componentsAt(1, 1), isEmpty);
      expect(grid.componentsAt(2, 2).first, updatedComponent);
    });

    test('updateComponent fails if new position overlaps existing component', () {
      final grid = Grid(rows: 3, cols: 3);
      final component1 = ComponentModel(id: 'c1', type: ComponentType.battery, r: 1, c: 1);
      final component2 = ComponentModel(id: 'c2', type: ComponentType.bulb, r: 2, c: 2);
      grid.addComponent(component1);
      grid.addComponent(component2);

      final updatedComponent1 = component1.copyWith(r: 2, c: 2);
      final success = grid.updateComponent(updatedComponent1);

      expect(success, isFalse);
      expect(grid.componentsAt(1, 1).first, component1); // Should not have moved
      expect(grid.componentsAt(2, 2).first, component2); // Should still be there
    });
  });
}
