import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../models/component.dart' as model;
import 'game_component.dart';

class BatteryComponent extends GameComponent {
  BatteryComponent({required model.Component componentModel})
      : super(
          componentModel: componentModel,
          size: Vector2(64, 64),
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Load battery sprite or create a simple rectangle
    add(RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.red,
    ));
    
    // Add battery symbol
    add(TextComponent(
      text: '+',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(size.x / 2, size.y / 2),
      anchor: Anchor.center,
    ));
  }

  @override
  void updateVisuals() {
    // Battery visual doesn't change based on circuit state
  }
}