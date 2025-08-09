import 'package:flame/components.dart';
import 'game_component.dart'; // Import the new base class
import '../../models/component.dart' as model; // Alias for data model Component

class WireComponent extends GameComponent {
  bool hasCurrent = false; // Visual state

  WireComponent({required model.Component componentModel})
      : super(componentModel: componentModel, size: Vector2.all(64)); // Pass componentModel to super

  @override
  Future<void> onLoad() async {
    await super.onLoad(); // Call super.onLoad()
    // Initial sprite based on hasCurrent, or based on componentModel's state if applicable
    sprite = await Sprite.load(hasCurrent ? 'wire_active.png' : 'wire_inactive.png');
  }

  void setCurrent(bool current) async { // Make setCurrent async
    hasCurrent = current;
    // Update sprite immediately
    sprite = await Sprite.load(hasCurrent ? 'wire_active.png' : 'wire_inactive.png'); // Await Sprite.load
  }

  @override
  void updateVisuals() {
    // This method will be called to update the wire's visual state
    // based on the circuit's evaluation result.
    // For example, if componentModel.state['isPowered'] is true, set hasCurrent to true.
    // This will be properly integrated when CircuitGame is refactored.
  }
}