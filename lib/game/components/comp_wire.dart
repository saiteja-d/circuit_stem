import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../models/component.dart' as model;
import 'game_component.dart';

class WireComponent extends GameComponent {
  bool hasCurrent = false;
  late RectangleComponent wireBody;

  WireComponent({required model.Component componentModel})
      : super(
          componentModel: componentModel,
          size: Vector2(64, 64),
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    wireBody = RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.brown,
    );
    add(wireBody);
    
    // Add wire visual based on type
    String wireSymbol = '─';
    switch (componentModel.type) {
      case model.ComponentType.wireStraight:
        wireSymbol = componentModel.rotation == 0 || componentModel.rotation == 180 ? '│' : '─';
        break;
      case model.ComponentType.wireCorner:
        wireSymbol = '└';
        break;
      case model.ComponentType.wireT:
        wireSymbol = '┬';
        break;
      default:
        wireSymbol = '─';
    }
    
    add(TextComponent(
      text: wireSymbol,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.black,
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
    wireBody.paint = Paint()..color = hasCurrent ? Colors.orange : Colors.brown;
  }
}