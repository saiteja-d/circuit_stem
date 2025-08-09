import 'package:flame/components.dart';
import '../../models/component.dart' as model;

abstract class GameComponent extends SpriteComponent {
  final model.Component componentModel;

  GameComponent({
    required this.componentModel,
    Vector2? position,
    Vector2? size,
    Sprite? sprite,
    Anchor? anchor,
    int? priority,
  }) : super(
          position: position,
          size: size,
          sprite: sprite,
          anchor: anchor,
          priority: priority,
        );

  void updateVisuals() {
    // This method will be implemented by concrete GameComponents
  }
}