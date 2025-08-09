/// Defines the types of components available in the circuit game.
enum ComponentType { 
  battery, 
  bulb, 
  wireStraight,
  wireCorner, 
  wireT, 
  circuitSwitch 
}

/// Represents a single component in the circuit grid.
class Component {
  final String id;
  final ComponentType type;
  int rotation; // 0, 90, 180, 270
  Map<String, dynamic> state; // e.g. {'switchOpen': true}
  bool isDraggable;
  int r, c; // Row and Column for grid position

  Component({
    required this.id,
    required this.type,
    this.rotation = 0,
    Map<String, dynamic>? state,
    this.isDraggable = true,
    this.r = 0,
    this.c = 0,
  }) : state = state ?? {};

  /// Creates a [Component] from a JSON map.
  factory Component.fromJson(Map<String, dynamic> json) {
    return Component(
      id: json['id'] as String,
      type: ComponentType.values.firstWhere(
          (e) => e.toString() == 'ComponentType.${json['type'] as String}'),
      rotation: json['rotation'] as int? ?? 0,
      state: (json['state'] as Map<String, dynamic>?) ?? {},
      isDraggable: json['isDraggable'] as bool? ?? true,
      r: json['r'] as int? ?? 0,
      c: json['c'] as int? ?? 0,
    );
  }

  /// Converts this [Component] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'rotation': rotation,
      'state': state,
      'isDraggable': isDraggable,
      'r': r,
      'c': c,
    };
  }

  bool get isSwitch => type == ComponentType.circuitSwitch;
  bool get isBulb => type == ComponentType.bulb;
  bool get isBattery => type == ComponentType.battery;

  void normalizeRotation() {
    rotation = ((rotation % 360) + 360) % 360;
    if (rotation % 90 != 0) rotation = (rotation / 90).round() * 90;
  }
}
