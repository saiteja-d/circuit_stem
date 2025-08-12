import 'package:circuit_stem/models/component.dart';
// Use ComponentType from component.dart

enum Direction {
  up,
  right,
  down,
  left
}

class CircuitComponent {
  final ComponentType type;
  final Direction direction;
  final bool powered;
  final bool interactive;
  final bool isLocked;
  final String? customImage;
  final bool isSwitchClosed;
  final int x;
  final int y;
  
  CircuitComponent({
    required this.type,
    required this.direction,
    required this.x,
    required this.y,
    this.powered = false,
    this.interactive = true,
    this.isLocked = false,
    this.customImage,
    this.isSwitchClosed = false,
  });

  bool get isPowered => powered;
}
