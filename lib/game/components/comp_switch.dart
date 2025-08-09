import 'package:flame/components.dart';
import 'game_component.dart'; // Import the new base class
import '../../models/component.dart' as model; // Alias for data model Component
import '../../services/sound_service.dart';

class SwitchComponent extends GameComponent {
  bool isOn = false; // Visual state
  final SoundService soundService = SoundService();

  SwitchComponent({required model.Component componentModel})
      : super(componentModel: componentModel, size: Vector2.all(64)); // Pass componentModel to super

  @override
  Future<void> onLoad() async {
    await super.onLoad(); // Call super.onLoad()
    // Initial sprite based on isOn, or based on componentModel's state if applicable
    sprite = await Sprite.load(isOn ? 'switch_closed.png' : 'switch_open.png');
  }

  void toggle() async { // Make toggle async
    isOn = !isOn;
    // Update sprite immediately
    sprite = await Sprite.load(isOn ? 'switch_closed.png' : 'switch_open.png'); // Await Sprite.load
    soundService.playSound('toggle.wav'); // Using 'toggle.wav' as per existing assets
  }

  @override
  void updateVisuals() {
    // This method will be called to update the switch's visual state
    // based on the componentModel's state.
    // For example, if componentModel.state['switchOpen'] is true, set isOn to false.
    // This will be properly integrated when CircuitGame is refactored.
  }
}