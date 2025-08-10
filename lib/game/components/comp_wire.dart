import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
// Import for ColorFilter
import 'package:flutter/services.dart'; // Import for rootBundle
// Import for ColorFilter
import '../../models/component.dart' as model;
import 'game_component.dart';

class WireComponent extends GameComponent {
  bool hasCurrent = false;
  late SpriteComponent wireBody;

  WireComponent({required model.Component componentModel})
      : super(
          componentModel: componentModel,
          size: Vector2(64, 64),
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    String imagePath;
    switch (componentModel.type) {
      case model.ComponentType.wireStraight:
        imagePath = 'assets/images/wire_straight.png';
        break;
      case model.ComponentType.wireCorner:
        imagePath = 'assets/images/wire_corner.png';
        break;
      case model.ComponentType.wireT:
        imagePath = 'assets/images/wire_t.png';
        break;
      default:
        imagePath = 'assets/images/wire_straight.png'; // Fallback
    }

    final byteData = await rootBundle.load(imagePath);
    final image = await Flame.images.fromByteData(imagePath, byteData);
    wireBody = SpriteComponent.fromImage(image, size: size);
    add(wireBody);
    
    // Remove TextComponent related code
  }

  @override
  void updateVisuals() {
    if (hasCurrent) {
      wireBody.paint = Paint()..colorFilter = ColorFilter.mode(Colors.orange.withOpacity(0.5), BlendMode.srcATop);
    } else {
      wireBody.paint = Paint();
    }
  }
}