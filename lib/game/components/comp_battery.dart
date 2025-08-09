import 'package:flame/components.dart';
import 'game_component.dart'; // Import the new base class
import '../../models/component.dart' as model; // Alias for data model Component

class BatteryComponent extends GameComponent { // Extends GameComponent
  BatteryComponent({required model.Component componentModel})
      : super(componentModel: componentModel, size: Vector2.all(64)); // Pass componentModel to super

  @override
  Future<void> onLoad() async {
    await super.onLoad(); // Call super.onLoad()
    sprite = await Sprite.load('battery.png');
  }

  @override
  void updateVisuals() {
    // Battery visual doesn't change based on circuit state, so nothing to do here.
  }
}