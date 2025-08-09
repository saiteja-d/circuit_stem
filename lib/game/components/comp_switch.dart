import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../models/component.dart' as model;
import 'game_component.dart';

class SwitchComponent extends GameComponent {
  bool isOn = false;
  late RectangleComponent switchBody;
  late TextComponent switchLabel;

  SwitchComponent({required model.Component componentModel})
      : super(
          componentModel: componentModel,
          size: Vector2(64, 64),
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    switchBody = RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.blue,
    );
    add(switchBody);
    
    switchLabel = TextComponent(
      text: 'OFF',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(size.x / 2, size.y / 2),
      anchor: Anchor.center,
    );
    add(switchLabel);
  }

  void toggle() {
    isOn = !isOn;
    updateVisuals();
  }

  @override
  void updateVisuals() {
    switchBody.paint = Paint()..color = isOn ? Colors.green : Colors.blue;
    switchLabel.text = isOn ? 'ON' : 'OFF';
  }
}