import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../models/component.dart' as model;
import 'game_component.dart';

class BulbComponent extends GameComponent {
  bool isOn = false;
  late RectangleComponent bulbBody;

  BulbComponent({required model.Component componentModel})
      : super(
          componentModel: componentModel,
          size: Vector2(64, 64),
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    bulbBody = RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.grey,
    );
    add(bulbBody);
    
    // Add bulb symbol
    add(TextComponent(
      text: '💡',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 32,
        ),
      ),
      position: Vector2(size.x / 2, size.y / 2),
      anchor: Anchor.center,
    ));
  }

  @override
  void updateVisuals() {
    bulbBody.paint = Paint()..color = isOn ? Colors.yellow : Colors.grey;
  }
}