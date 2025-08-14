import 'package:flutter_test/flutter_test.dart';
import 'package:circuit_stem/models/component.dart';
import 'package:circuit_stem/models/grid.dart';
import 'package:circuit_stem/services/logic_engine.dart';

void main() {
  test('long wire length 3 powers bulb at end', () {
    final components = [
      ComponentModel(
        id: 'batt',
        type: ComponentType.battery,
        r: 2,
        c: 0,
        rotation: 90,
        terminals: const [TerminalSpec(cellIndex: 0, dir: Dir.east), TerminalSpec(cellIndex: 0, dir: Dir.west)],
      ),
      ComponentModel.longWire(id: 'lw', r: 2, c: 1, length: 3, rotation: 90),
      ComponentModel(
        id: 'bulb1',
        type: ComponentType.bulb,
        r: 2,
        c: 4,
        rotation: 90,
        terminals: const [TerminalSpec(cellIndex: 0, dir: Dir.west), TerminalSpec(cellIndex: 0, dir: Dir.east)],
      ),
    ];

    final grid = Grid(
      rows: 5,
      cols: 7,
      componentsById: {for (var c in components) c.id: c},
    );

    final engine = LogicEngine();
    final result = engine.evaluate(grid);

    expect(result.isShortCircuit, isFalse);
    expect(result.poweredComponentIds.contains('batt'), isTrue);
    expect(result.poweredComponentIds.contains('lw'), isTrue);
    expect(result.poweredComponentIds.contains('bulb1'), isTrue);
  });

  test('T-piece branches power to two bulbs', () {
    final components = [
      ComponentModel(
        id: 'batt',
        type: ComponentType.battery,
        r: 2,
        c: 1,
        rotation: 90,
        terminals: const [TerminalSpec(cellIndex: 0, dir: Dir.east), TerminalSpec(cellIndex: 0, dir: Dir.west)],
      ),
      ComponentModel(
        id: 't1',
        type: ComponentType.wireT,
        r: 2,
        c: 2,
        rotation: 0,
        terminals: const [
          TerminalSpec(cellIndex: 0, dir: Dir.west),
          TerminalSpec(cellIndex: 0, dir: Dir.north),
          TerminalSpec(cellIndex: 0, dir: Dir.south),
        ],
      ),
      ComponentModel(
        id: 'bn',
        type: ComponentType.bulb,
        r: 1,
        c: 2,
        rotation: 90,
        terminals: const [TerminalSpec(cellIndex: 0, dir: Dir.south), TerminalSpec(cellIndex: 0, dir: Dir.north)],
      ),
      ComponentModel(
        id: 'bs',
        type: ComponentType.bulb,
        r: 3,
        c: 2,
        rotation: 90,
        terminals: const [TerminalSpec(cellIndex: 0, dir: Dir.north), TerminalSpec(cellIndex: 0, dir: Dir.south)],
      ),
    ];

    final grid = Grid(
      rows: 5,
      cols: 5,
      componentsById: {for (var c in components) c.id: c},
    );

    final engine = LogicEngine();
    final result = engine.evaluate(grid);

    expect(result.isShortCircuit, isFalse);
    expect(result.poweredComponentIds.contains('bn'), isTrue);
    expect(result.poweredComponentIds.contains('bs'), isTrue);
    expect(result.poweredComponentIds.contains('t1'), isTrue);
    expect(result.poweredComponentIds.contains('batt'), isTrue);
  });

  test('rotated T piece correctly routes power (rotation test)', () {
    final components = [
      ComponentModel(
        id: 'batt',
        type: ComponentType.battery,
        r: 2,
        c: 1,
        rotation: 90,
        terminals: const [TerminalSpec(cellIndex: 0, dir: Dir.east), TerminalSpec(cellIndex: 0, dir: Dir.west)],
      ),
      ComponentModel(
        id: 't2',
        type: ComponentType.wireT,
        r: 2,
        c: 2,
        rotation: 90,
        terminals: const [
          TerminalSpec(cellIndex: 0, dir: Dir.north),
          TerminalSpec(cellIndex: 0, dir: Dir.east),
          TerminalSpec(cellIndex: 0, dir: Dir.south),
        ],
      ),
      ComponentModel(
        id: 'be',
        type: ComponentType.bulb,
        r: 2,
        c: 3,
        rotation: 90,
        terminals: const [TerminalSpec(cellIndex: 0, dir: Dir.west), TerminalSpec(cellIndex: 0, dir: Dir.east)],
      ),
      ComponentModel(
        id: 'bn',
        type: ComponentType.bulb,
        r: 1,
        c: 2,
        rotation: 90,
        terminals: const [TerminalSpec(cellIndex: 0, dir: Dir.south), TerminalSpec(cellIndex: 0, dir: Dir.north)],
      ),
    ];

    final grid = Grid(
      rows: 5,
      cols: 5,
      componentsById: {for (var c in components) c.id: c},
    );

    final engine = LogicEngine();
    final result = engine.evaluate(grid);

    expect(result.isShortCircuit, isFalse);
    expect(result.poweredComponentIds.contains('be'), isTrue);
    expect(result.poweredComponentIds.contains('bn'), isTrue);
  });
}