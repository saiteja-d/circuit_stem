import 'package:flame/components.dart';
import 'game_component.dart'; // Import the new base class
import '../../models/component.dart' as model; // Alias for data model Component

class BulbComponent extends GameComponent {
  bool isOn = false; // Visual state

  BulbComponent({required model.Component componentModel})
      : super(componentModel: componentModel, size: Vector2.all(64)); // Pass componentModel to super

  @override
  Future<void> onLoad() async {
    await super.onLoad(); // Call super.onLoad()
    // Initial sprite based on isOn, or based on componentModel's state if applicable
    sprite = await Sprite.load(isOn ? 'bulb_on.png' : 'bulb_off.png');
  }

  void togglePower() async { // Make togglePower async
    isOn = !isOn;
    // Update sprite immediately
    sprite = await Sprite.load(isOn ? 'bulb_on.png' : 'bulb_off.png'); // Await Sprite.load
  }

  @override
  void updateVisuals() {
    // This method will be called to update the bulb's visual state
    // based on the circuit's evaluation result.
    // For example, if componentModel.state['isPowered'] is true, set isOn to true.
    // For now, we'll just use the existing isOn.
    // This will be properly integrated when CircuitGame is refactored.
  }
}