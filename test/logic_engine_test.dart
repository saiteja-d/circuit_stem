import 'package:flutter_test/flutter_test.dart';
import 'package:circuit_stem/models/grid.dart';
import 'package:circuit_stem/models/component.dart';
import 'package:circuit_stem/services/logic_engine.dart';

void main() {
  test('simple series powers bulb', () {
    final grid = Grid(rows: 3, cols: 3);
    final battery = Component(id: 'batt', type: ComponentType.battery, rotation: 0);
    final bulb = Component(id: 'bulb', type: ComponentType.bulb, rotation: 0);
    final wire1 = Component(id: 'w1', type: ComponentType.wireStraight, rotation: 90); // Fixed enum name
    grid.placeComponent(1, 0, battery);
    grid.placeComponent(1, 1, wire1);
    grid.placeComponent(1, 2, bulb);
    final logicEngine = LogicEngine(); // Create LogicEngine instance
    final res = logicEngine.evaluateGrid(grid); // Call method on instance
    expect(res.poweredComponentIds.contains('bulb'), true);
    expect(res.shortDetected, false);
  });

  test('short detection when positive connects to negative without bulb', () {
    final grid = Grid(rows: 1, cols: 3);
    final batt = Component(id: 'b', type: ComponentType.battery, rotation: 0);
    final wire1 = Component(id: 'w1', type: ComponentType.wireStraight, rotation: 90);
    grid.placeComponent(0, 0, batt);
    grid.placeComponent(0, 1, wire1);
    final wire2 = Component(id: 'w2', type: ComponentType.wireStraight, rotation: 90);
    grid.placeComponent(0, 2, wire2);
    final logicEngine = LogicEngine(); // Create LogicEngine instance
    final res = logicEngine.evaluateGrid(grid); // Call method on instance
    expect(res.shortDetected, true);
  });
}
