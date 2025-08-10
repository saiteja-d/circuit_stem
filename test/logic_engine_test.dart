// test/logic_engine_test.dart
import 'package:test/test.dart';
import 'package:your_package_name/lib/services/logic_engine.dart';
import 'package:your_package_name/lib/models/grid.dart';
import 'package:your_package_name/lib/models/component.dart';

void main() {
  group('LogicEngine', () {
    late LogicEngine engine;

    setUp(() {
      engine = LogicEngine();
    });

    test('Empty grid returns no powered components and no shorts', () {
      final grid = Grid(componentsById: {});
      final result = engine.evaluate(grid);

      expect(result.poweredComponentIds, isEmpty);
      expect(result.isShortCircuit, isFalse);
      expect(result.openEndpoints, isEmpty);
      expect(result.debugTrace, isNotEmpty);
    });

    test('Battery with no terminals warns and no power', () {
      final battery = Component(
        id: 'b1',
        type: ComponentType.battery,
        r: 0,
        c: 0,
        rotation: 0,
        terminals: [],
        shapeOffsets: [],
        internalConnections: [],
        state: {},
      );
      final grid = Grid(componentsById: {'b1': battery});

      final result = engine.evaluate(grid);

      expect(result.poweredComponentIds, isEmpty);
      expect(result.debugInfo.notes, contains('Battery b1 has fewer than 2 terminals.'));
    });

    test('Simple battery powering a bulb with connection', () {
      // Define terminals with roles 'pos', 'neg' for battery
      final battery = Component(
        id: 'bat1',
        type: ComponentType.battery,
        r: 0,
        c: 0,
        rotation: 0,
        terminals: [
          TerminalSpec(cellIndex: 0, dir: Dir.east, label: 'positive', role: 'pos'),
          TerminalSpec(cellIndex: 1, dir: Dir.west, label: 'negative', role: 'neg'),
        ],
        shapeOffsets: [CellOffset(0, 0), CellOffset(0, 1)],
        internalConnections: [],
        state: {},
      );

      final bulb = Component(
        id: 'bulb1',
        type: ComponentType.bulb,
        r: 0,
        c: 1,
        rotation: 0,
        terminals: [
          TerminalSpec(cellIndex: 0, dir: Dir.west, label: 'load', role: 'load'),
          TerminalSpec(cellIndex: 1, dir: Dir.east, label: 'load', role: 'load'),
        ],
        shapeOffsets: [CellOffset(0, 0), CellOffset(0, 1)],
        internalConnections: [[0, 1]],
        state: {},
      );

      final grid = Grid(componentsById: {
        'bat1': battery,
        'bulb1': bulb,
      });

      final result = engine.evaluate(grid);

      expect(result.poweredComponentIds, containsAll(['bat1', 'bulb1']));
      expect(result.isShortCircuit, isFalse);
      expect(result.openEndpoints, isEmpty);
      expect(result.debugTrace, contains('short=false'));
    });

    test('Detects short circuit when no load between battery terminals', () {
      final battery = Component(
        id: 'bat1',
        type: ComponentType.battery,
        r: 0,
        c: 0,
        rotation: 0,
        terminals: [
          TerminalSpec(cellIndex: 0, dir: Dir.east, label: 'positive', role: 'pos'),
          TerminalSpec(cellIndex: 1, dir: Dir.west, label: 'negative', role: 'neg'),
        ],
        shapeOffsets: [CellOffset(0, 0), CellOffset(0, 1)],
        internalConnections: [],
        state: {},
      );

      final wire = Component(
        id: 'wire1',
        type: ComponentType.wire,
        r: 0,
        c: 1,
        rotation: 0,
        terminals: [
          TerminalSpec(cellIndex: 0, dir: Dir.west),
          TerminalSpec(cellIndex: 1, dir: Dir.east),
        ],
        shapeOffsets: [CellOffset(0, 0), CellOffset(0, 1)],
        internalConnections: [[0, 1]],
        state: {},
      );

      final grid = Grid(componentsById: {
        'bat1': battery,
        'wire1': wire,
      });

      final result = engine.evaluate(grid);

      expect(result.isShortCircuit, isTrue);
      expect(result.debugTrace, contains('Short circuit detected'));
      expect(result.openEndpoints, isEmpty);
    });
  });
}
