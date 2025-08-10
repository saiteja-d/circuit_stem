// lib/models/component.dart
import '../services/logic_engine.dart';

/// Simple integer cell offset.
class CellOffset {
  final int dr;
  final int dc;
  const CellOffset(this.dr, this.dc);

  factory CellOffset.fromJson(Map<String, dynamic> json) {
    return CellOffset(json['dr'] as int, json['dc'] as int);
  }

  Map<String, dynamic> toJson() => {'dr': dr, 'dc': dc};

  @override
  String toString() => 'CellOffset($dr,$dc)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CellOffset && runtimeType == other.runtimeType && dr == other.dr && dc == other.dc;

  @override
  int get hashCode => dr.hashCode ^ dc.hashCode;
}

/// Terminal specification attached to a component.
class TerminalSpec {
  final int cellIndex;
  final Dir dir;
  final String? label;
  final String? role;
  const TerminalSpec({
    required this.cellIndex,
    required this.dir,
    this.label,
    this.role,
  });

  factory TerminalSpec.fromJson(Map<String, dynamic> json, {List<CellOffset>? shapeOffsets}) {
    int cellIndex = -1;
    if (json.containsKey('offset')) {
      final offset = CellOffset.fromJson(json['offset'] as Map<String, dynamic>);
      if (shapeOffsets != null) {
        cellIndex = shapeOffsets.indexWhere((e) => e.dr == offset.dr && e.dc == offset.dc);
      }
    } else if (json.containsKey('cellIndex')) {
      cellIndex = json['cellIndex'] as int;
    }

    if (cellIndex == -1) {
      throw Exception('TerminalSpec.fromJson: could not determine cellIndex');
    }

    return TerminalSpec(
      cellIndex: cellIndex,
      dir: Dir.values.firstWhere(
        (e) => e.name == (json['dir'] as String),
        orElse: () => Dir.north,
      ),
      label: json['label'] as String?,
      role: json['role'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cellIndex': cellIndex,
      'dir': dir.name,
      if (label != null) 'label': label,
      if (role != null) 'role': role,
    };
  }

  @override
  String toString() =>
      'TerminalSpec(cellIndex=$cellIndex,dir=$dir,label=$label,role=$role)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TerminalSpec &&
          runtimeType == other.runtimeType &&
          cellIndex == other.cellIndex &&
          dir == other.dir &&
          label == other.label &&
          role == other.role;

  @override
  int get hashCode => cellIndex.hashCode ^ dir.hashCode ^ (label?.hashCode ?? 0) ^ (role?.hashCode ?? 0);
}

/// Component types used by logic engine rendering & rules.
enum ComponentType {
  battery,
  bulb,
  wireStraight,
  wireCorner,
  wireT,
  wireLong,
  sw,
  timer,
  custom
}

ComponentType _componentTypeFromString(String type) {
  if (type == 'circuit_switch') type = 'sw';
  return ComponentType.values.firstWhere(
    (e) => e.name == type,
    orElse: () => ComponentType.custom,
  );
}

String _componentTypeToString(ComponentType type) => type.name;

/// Component model supporting multi-cell shapes and labeled terminals.
class ComponentModel {
  final String id;
  final ComponentType type;
  int r;
  int c;
  int rotation; // 0, 90, 180, 270
  Map<String, dynamic> state;
  final List<CellOffset> shapeOffsets; // relative cells at rotation 0
  final List<TerminalSpec> terminals; // terminals described relative to shapeOffsets
  final List<List<int>> internalConnections; // explicit internal terminal index connections

  ComponentModel({
    required this.id,
    required this.type,
    required this.r,
    required this.c,
    this.rotation = 0,
    Map<String, dynamic>? state,
    List<CellOffset>? shapeOffsets,
    List<TerminalSpec>? terminals,
    List<List<int>>? internalConnections,
  })  : state = Map<String, dynamic>.from(state ?? {}),
        shapeOffsets = shapeOffsets ?? const [CellOffset(0, 0)],
        terminals = terminals ??
            const [
              TerminalSpec(cellIndex: 0, dir: Dir.north, label: null),
              TerminalSpec(cellIndex: 0, dir: Dir.south, label: null)
            ],
        internalConnections = internalConnections ?? const [];

  factory ComponentModel.fromJson(Map<String, dynamic> json) {
    return ComponentModel(
      id: json['id'] as String,
      type: _componentTypeFromString(json['type'] as String),
      r: json['r'] as int,
      c: json['c'] as int,
      rotation: json['rotation'] as int? ?? 0,
      state: (json['state'] as Map<String, dynamic>?) ?? {},
      shapeOffsets: (json['shapeOffsets'] as List<dynamic>?)
              ?.map((e) => CellOffset.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [CellOffset(0, 0)],
      terminals: (json['terminals'] as List<dynamic>?)?
              .map((e) => TerminalSpec.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [
            TerminalSpec(cellIndex: 0, dir: Dir.north, label: null),
            TerminalSpec(cellIndex: 0, dir: Dir.south, label: null)
          ],
      internalConnections:
          (json['internalConnections'] as List<dynamic>?)
                  ?.map((e) =>
                      (e as List<dynamic>).map((x) => x as int).toList())
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

  /// Copy with changes.
  ComponentModel copyWith({
    int? r,
    int? c,
    int? rotation,
    Map<String, dynamic>? state,
  }) {
    return ComponentModel(
      id: id,
      type: type,
      r: r ?? this.r,
      c: c ?? this.c,
      rotation: rotation ?? this.rotation,
      state: state != null ? Map<String, dynamic>.from(state) : Map.from(this.state),
      shapeOffsets: List<CellOffset>.from(shapeOffsets),
      terminals: List<TerminalSpec>.from(terminals),
      internalConnections: internalConnections
          .map((pair) => List<int>.from(pair))
          .toList(),
    );
  }

  bool get isDraggable => type != ComponentType.battery && type != ComponentType.bulb;

  @override
  String toString() =>
      'ComponentModel($id,type=$type,anchor=[$r,$c],rot=$rotation,shape=${shapeOffsets.length}cells,terms=${terminals.length})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ComponentModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          type == other.type &&
          r == other.r &&
          c == other.c &&
          rotation == other.rotation &&
          mapEquals(state, other.state) &&
          listEquals(shapeOffsets, other.shapeOffsets) &&
          listEquals(terminals, other.terminals) &&
          listEquals(internalConnections, other.internalConnections);

  @override
  int get hashCode =>
      id.hashCode ^
      type.hashCode ^
      r.hashCode ^
      c.hashCode ^
      rotation.hashCode ^
      state.hashCode ^
      shapeOffsets.hashCode ^
      terminals.hashCode ^
      internalConnections.hashCode;
}
