import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';
import '../services/logic_engine.dart';

part 'component.freezed.dart';
part 'component.g.dart';

@freezed
class CellOffset with _$CellOffset {
  const CellOffset._();
  const factory CellOffset(
    int dr,
    int dc,
  ) = _CellOffset;

  factory CellOffset.fromJson(Map<String, dynamic> json) {
    return CellOffset(
      (json['dr'] ?? json['r']) as int,
      (json['dc'] ?? json['c']) as int,
    );
  }

  Map<String, dynamic> toJson() => {'dr': dr, 'dc': dc};
}

@freezed
class TerminalSpec with _$TerminalSpec {
  const factory TerminalSpec({
    required int cellIndex,
    required Dir dir,
    String? label,
    String? role,
  }) = _TerminalSpec;

  factory TerminalSpec.fromJson(Map<String, dynamic> json) =>
      _$TerminalSpecFromJson(json);
}



enum ComponentType {
  battery,
  bulb,
  wireStraight,
  wireCorner,
  wireT,
  wireLong,
  sw,
  timer,
  resistor,
  blocked,
  custom,
  crossWire,
  buzzer
}

ComponentType _componentTypeFromString(String type) {
  if (type == 'circuit_switch') type = 'sw';
  if (type == 'wire_straight') type = 'wireStraight';
  if (type == 'wire_corner') type = 'wireCorner';
  if (type == 'wire_t') type = 'wireT';
  return ComponentType.values.firstWhere(
    (e) => e.name == type,
    orElse: () => ComponentType.custom,
  );
}

String _componentTypeToString(ComponentType type) => type.name;

Dir _dirFromString(String dir) {
  final lowerDir = dir.toLowerCase();
  if (lowerDir == 'up') return Dir.north;
  if (lowerDir == 'down') return Dir.south;
  if (lowerDir == 'left') return Dir.west;
  if (lowerDir == 'right') return Dir.east;
  return Dir.values.firstWhere(
    (e) => e.name.toLowerCase() == lowerDir,
    orElse: () {
      // For backward compatibility with older level files
      if (lowerDir == 'n') return Dir.north;
      if (lowerDir == 'e') return Dir.east;
      if (lowerDir == 's') return Dir.south;
      if (lowerDir == 'w') return Dir.west;
      throw Exception('Unknown direction string: $dir');
    },
  );
}

@freezed
class ComponentModel with _$ComponentModel {
  const ComponentModel._();

  const factory ComponentModel({
    required String id,
    required ComponentType type,
    required int r,
    required int c,
    @Default(0) int rotation,
    @Default({}) Map<String, dynamic> state,
    @Default([CellOffset(0, 0)]) List<CellOffset> shapeOffsets,
    @Default([
      TerminalSpec(cellIndex: 0, dir: Dir.north),
      TerminalSpec(cellIndex: 0, dir: Dir.south)
    ]) List<TerminalSpec> terminals,
    @Default([]) List<List<int>> internalConnections,
  }) = _ComponentModel;

  /// Factory: vertical long wire (length cells). Rotation rotates it.
  factory ComponentModel.longWire({
    required String id,
    required int r,
    required int c,
    required int length,
    int rotation = 0,
  }) {
    assert(length >= 1);
    final shape = List<CellOffset>.generate(length, (i) => CellOffset(i, 0));
    final terms = <TerminalSpec>[
      const TerminalSpec(cellIndex: 0, dir: Dir.north, label: 'end'),
      TerminalSpec(cellIndex: length - 1, dir: Dir.south, label: 'end'),
    ];
    return ComponentModel(
      id: id,
      type: ComponentType.wireLong,
      r: r,
      c: c,
      rotation: rotation,
      shapeOffsets: shape,
      terminals: terms,
    );
  }

  /// Factory: T-piece (single-cell) default terminals north, east, west.
  factory ComponentModel.tPiece({
    required String id,
    required int r,
    required int c,
    int rotation = 0,
  }) {
    final terms = [
      const TerminalSpec(cellIndex: 0, dir: Dir.north, label: 'T1'),
      const TerminalSpec(cellIndex: 0, dir: Dir.east, label: 'T2'),
      const TerminalSpec(cellIndex: 0, dir: Dir.west, label: 'T3'),
    ];
    return ComponentModel(
      id: id,
      type: ComponentType.wireT,
      r: r,
      c: c,
      rotation: rotation,
      shapeOffsets: const [CellOffset(0, 0)],
      terminals: terms,
    );
  }

  factory ComponentModel.fromJson(Map<String, dynamic> json) {
    final shapeOffsets = (json['shapeOffsets'] as List<dynamic>?)
            ?.map((e) => CellOffset.fromJson(e as Map<String, dynamic>))
            .toList() ??
        const [CellOffset(0, 0)];

    final terminalsJson = json['terminals'] as List<dynamic>?;
    final terminals = terminalsJson != null
        ? terminalsJson.map((e) {
            final termJson = e as Map<String, dynamic>;
            int cellIndex = -1;
            if (termJson.containsKey('offset')) {
              final offset = CellOffset.fromJson(termJson['offset'] as Map<String, dynamic>);
              cellIndex = shapeOffsets.indexWhere((e) => e.dr == offset.dr && e.dc == offset.dc);
            } else if (termJson.containsKey('cellIndex')) {
              cellIndex = termJson['cellIndex'] as int;
            }
            if (cellIndex == -1) {
              throw Exception('TerminalSpec.fromJson: could not determine cellIndex');
            }
            return TerminalSpec(
              cellIndex: cellIndex,
              dir: _dirFromString(termJson['dir'] as String),
              label: termJson['label'] as String?,
              role: termJson['role'] as String?,
            );
          }).toList()
        : const [
            TerminalSpec(cellIndex: 0, dir: Dir.north),
            TerminalSpec(cellIndex: 0, dir: Dir.south)
          ];

    return ComponentModel(
      id: json['id'] as String,
      type: _componentTypeFromString(json['type'] as String),
      r: (json['position']?['r'] ?? json['r']) as int,
      c: (json['position']?['c'] ?? json['c']) as int,
      rotation: json['rotation'] as int? ?? 0,
      state: (json['state'] as Map<String, dynamic>?) ?? {},
      shapeOffsets: shapeOffsets,
      terminals: terminals,
      internalConnections: (json['internalConnections'] as List<dynamic>?)
              ?.map((e) => (e as List<dynamic>).map((x) => x as int).toList())
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': _componentTypeToString(type),
      'r': r,
      'c': c,
      'rotation': rotation,
      'state': state,
      'shapeOffsets': shapeOffsets.map((e) => e.toJson()).toList(),
      'terminals': terminals.map((e) => e.toJson()).toList(),
      'internalConnections': internalConnections,
    };
  }

  bool get isDraggable => type != ComponentType.battery && type != ComponentType.bulb && type != ComponentType.buzzer;
}

// Type alias for backward compatibility with tests
typedef Component = ComponentModel;
