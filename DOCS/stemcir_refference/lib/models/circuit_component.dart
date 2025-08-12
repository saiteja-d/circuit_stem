import 'package:flutter/material.dart';

enum ComponentType {
  wire,
  wireCorner,
  wireTJunction,
  wireCross,
  battery,
  bulb,
  circuitSwitch,
  resistor,
}

enum Direction { up, down, left, right }

class CircuitComponent {
  final String id;
  final ComponentType type;
  final int x;
  final int y;
  Direction direction;
  bool isActive;
  bool isPowered;
  
  // Switch-specific properties
  bool isSwitchClosed;
  
  // Connection points for the component
  List<Offset> connectionPoints;
  
  CircuitComponent({
    required this.id,
    required this.type,
    required this.x,
    required this.y,
    this.direction = Direction.right,
    this.isActive = false,
    this.isPowered = false,
    this.isSwitchClosed = true,
    this.connectionPoints = const [],
  });
  
  CircuitComponent copyWith({
    String? id,
    ComponentType? type,
    int? x,
    int? y,
    Direction? direction,
    bool? isActive,
    bool? isPowered,
    bool? isSwitchClosed,
    List<Offset>? connectionPoints,
  }) => CircuitComponent(
    id: id ?? this.id,
    type: type ?? this.type,
    x: x ?? this.x,
    y: y ?? this.y,
    direction: direction ?? this.direction,
    isActive: isActive ?? this.isActive,
    isPowered: isPowered ?? this.isPowered,
    isSwitchClosed: isSwitchClosed ?? this.isSwitchClosed,
    connectionPoints: connectionPoints ?? this.connectionPoints,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'x': x,
    'y': y,
    'direction': direction.name,
    'isActive': isActive,
    'isPowered': isPowered,
    'isSwitchClosed': isSwitchClosed,
  };

  factory CircuitComponent.fromJson(Map<String, dynamic> json) => CircuitComponent(
    id: json['id'] as String,
    type: ComponentType.values.firstWhere((e) => e.name == json['type']),
    x: json['x'] as int,
    y: json['y'] as int,
    direction: Direction.values.firstWhere((e) => e.name == json['direction']),
    isActive: json['isActive'] as bool? ?? false,
    isPowered: json['isPowered'] as bool? ?? false,
    isSwitchClosed: json['isSwitchClosed'] as bool? ?? true,
  );
}