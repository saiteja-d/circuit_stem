// test/logic_engine_rich_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:circuit_stem/models/component.dart';
import 'package:circuit_stem/models/grid.dart';
import 'package:circuit_stem/services/logic_engine.dart';

void main() {
  test('long wire length 3 powers bulb at end', () {
    final grid = Grid(rows: 5, cols: 7);

    // battery at (2,1) rotation 90 (pointing east)
    final battery = ComponentModel(
      id: 'batt',
      type: ComponentType.battery,
      r: 2,
      c: 0,
      rotation: 90,
      shapeOffsets: const [CellOffset(0, 0)],
      terminals: const [TerminalSpec(cellIndex: 0, dir: Dir.east), TerminalSpec(cellIndex: 0, dir: Dir.west)],
    );

    // long wire length 3 placed at (2,1) occupying cells (2,1),(3,1),(4,1) in rotation 90? 
    // Use longWire factory with length 3 and rotation=90 which will rotate vertical->horizontal
    final longWire = ComponentModel.longWire(id: 'lw', r: 2, c: 1, length: 3, rotation: 90);
    // This creates terminals on both ends of the long wire.

    // bulb at the far right end (same row as battery, after wire)
    final bulb = ComponentModel(
      id: 'bulb1',
      type: ComponentType.bulb,
      r: 2,
      c: 4,
      rotation: 90,
      shapeOffsets: const [CellOffset(0, 0)],
      terminals: const [TerminalSpec(cellIndex: 0, dir: Dir.west), TerminalSpec(cellIndex: 0, dir: Dir.east)],
    );

    // Add components
    final addedBatt = grid.addComponent(battery);
    final addedWire = grid.addComponent(longWire);
    final addedBulb = grid.addComponent(bulb);

    expect(addedBatt, isTrue);
    expect(addedWire, isTrue);
    expect(addedBulb, isTrue);

    final engine = LogicEngine();
    final result = engine.evaluate(grid);

    expect(result.isShortCircuit, isFalse);
    expect(result.poweredComponentIds.contains('batt'), isTrue);
    expect(result.poweredComponentIds.contains('lw'), isTrue);
    expect(result.poweredComponentIds.contains('bulb1'), isTrue);
  });

  test('T-piece branches power to two bulbs', () {
    final grid = Grid(rows: 5, cols: 5);

    // battery at (2,1), rotation 90 so positive faces east
    final batt = ComponentModel(
      id: 'batt',
      type: ComponentType.battery,
      r: 2,
      c: 1,
      rotation: 90,
      shapeOffsets: const [CellOffset(0, 0)],
      terminals: const [TerminalSpec(cellIndex: 0, dir: Dir.east), TerminalSpec(cellIndex: 0, dir: Dir.west)],
    );

    // T-piece at (2,2) rotated 90 (so base points to west? depends on factory)
    // Our tPiece factory defaults to terminals north,east,west at rotation 0.
    // rotation 90 -> east,south,east? Let's just construct terminals explicitly for clarity.
    final tPiece = ComponentModel(
      id: 't1',
      type: ComponentType.wireT,
      r: 2,
      c: 2,
      rotation: 0,
      shapeOffsets: const [CellOffset(0, 0)],
      terminals: const [
        TerminalSpec(cellIndex: 0, dir: Dir.west), // connect back to battery (west)
        TerminalSpec(cellIndex: 0, dir: Dir.north), // branch north
        TerminalSpec(cellIndex: 0, dir: Dir.south), // branch south
      ],
    );

    // bulbs north and south of T
    final bulbN = ComponentModel(
      id: 'bn',
      type: ComponentType.bulb,
      r: 1,
      c: 2,
      rotation: 90,
      shapeOffsets: const [CellOffset(0, 0)],
      terminals: const [TerminalSpec(cellIndex: 0, dir: Dir.south), TerminalSpec(cellIndex: 0, dir: Dir.north)],
    );
    final bulbS = ComponentModel(
      id: 'bs',
      type: ComponentType.bulb,
      r: 3,
      c: 2,
      rotation: 90,
      shapeOffsets: const [CellOffset(0, 0)],
      terminals: const [TerminalSpec(cellIndex: 0, dir: Dir.north), TerminalSpec(cellIndex: 0, dir: Dir.south)],
    );

    final added = grid.addComponent(batt);
    expect(added, isTrue);
    expect(grid.addComponent(tPiece), isTrue);
    expect(grid.addComponent(bulbN), isTrue);
    expect(grid.addComponent(bulbS), isTrue);

    final engine = LogicEngine();
    final result = engine.evaluate(grid);

    expect(result.isShortCircuit, isFalse);
    expect(result.poweredComponentIds.contains('bn'), isTrue);
    expect(result.poweredComponentIds.contains('bs'), isTrue);
    expect(result.poweredComponentIds.contains('t1'), isTrue);
    expect(result.poweredComponentIds.contains('batt'), isTrue);
  });

  test('rotated T piece correctly routes power (rotation test)', () {
    final grid = Grid(rows: 5, cols: 5);

    final batt = ComponentModel(
      id: 'batt',
      type: ComponentType.battery,
      r: 2,
      c: 1,
      rotation: 90,
      shapeOffsets: const [CellOffset(0, 0)],
      terminals: const [TerminalSpec(cellIndex: 0, dir: Dir.east), TerminalSpec(cellIndex: 0, dir: Dir.west)],
    );

    // T-piece that has terminals east, south, north when rotated 90
    final t = ComponentModel(
      id: 't2',
      type: ComponentType.wireT,
      r: 2,
      c: 2,
      rotation: 90,
      shapeOffsets: const [CellOffset(0, 0)],
      terminals: const [
        TerminalSpec(cellIndex: 0, dir: Dir.north),
        TerminalSpec(cellIndex: 0, dir: Dir.east),
        TerminalSpec(cellIndex: 0, dir: Dir.south),
      ],
    );

    final bulbE = ComponentModel(
      id: 'be',
      type: ComponentType.bulb,
      r: 2,
      c: 3,
      rotation: 90,
      shapeOffsets: const [CellOffset(0, 0)],
      terminals: const [TerminalSpec(cellIndex: 0, dir: Dir.west), TerminalSpec(cellIndex: 0, dir: Dir.east)],
    );

    final bulbN = ComponentModel(
      id: 'bn',
      type: ComponentType.bulb,
      r: 1,
      c: 2,
      rotation: 90,
      shapeOffsets: const [CellOffset(0, 0)],
      terminals: const [TerminalSpec(cellIndex: 0, dir: Dir.south), TerminalSpec(cellIndex: 0, dir: Dir.north)],
    );

    grid.addComponent(batt);
    grid.addComponent(t);
    grid.addComponent(bulbE);
    grid.addComponent(bulbN);

    final engine = LogicEngine();
    final result = engine.evaluate(grid);

    expect(result.isShortCircuit, isFalse);
    expect(result.poweredComponentIds.contains('be'), isTrue);
    expect(result.poweredComponentIds.contains('bn'), isTrue);
  });
}
