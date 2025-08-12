import 'package:stemcir/models/circuit_component.dart';
import 'package:stemcir/models/game_level.dart';

class LevelService {
  static final List<GameLevel> _levels = [
    GameLevel(
      levelNumber: 1,
      title: "First Light",
      description: "Use the battery and wires to light the bulb!",
      objective: "Power the bulb using the battery and wire segments",
      gridWidth: 6,
      gridHeight: 4,
      initialComponents: [
        CircuitComponent(
          id: "bulb_1",
          type: ComponentType.bulb,
          x: 4,  // Fixed on the right side
          y: 2,
        ),
      ],
      availableComponents: [
        // Battery (1) - draggable from inventory
        CircuitComponent(
          id: "battery_1",
          type: ComponentType.battery,
          x: 0,
          y: 0,
          direction: Direction.right,
        ),
        // Wire segments: all shapes available in unlimited quantity
        ...List.generate(8, (i) => CircuitComponent(
          id: "wire_straight_${i + 1}",
          type: ComponentType.wire,
          x: 0,
          y: 0,
        )),
        ...List.generate(8, (i) => CircuitComponent(
          id: "wire_corner_${i + 1}",
          type: ComponentType.wireCorner,
          x: 0,
          y: 0,
        )),
        ...List.generate(4, (i) => CircuitComponent(
          id: "wire_tjunction_${i + 1}",
          type: ComponentType.wireTJunction,
          x: 0,
          y: 0,
        )),
        ...List.generate(4, (i) => CircuitComponent(
          id: "wire_cross_${i + 1}",
          type: ComponentType.wireCross,
          x: 0,
          y: 0,
        )),
      ],
      targetComponentIds: ["bulb_1"],
    ),
    GameLevel(
      levelNumber: 2,
      title: "Switch Control",
      description: "Use a switch to control when the bulb lights up",
      objective: "Connect the circuit with a switch to control the bulb",
      gridWidth: 8,
      gridHeight: 4,
      initialComponents: [
        CircuitComponent(
          id: "battery_2",
          type: ComponentType.battery,
          x: 1,
          y: 2,
          direction: Direction.right,
        ),
        CircuitComponent(
          id: "bulb_2",
          type: ComponentType.bulb,
          x: 6,
          y: 2,
        ),
      ],
      availableComponents: [
        CircuitComponent(
          id: "switch_1",
          type: ComponentType.circuitSwitch,
          x: 0,
          y: 0,
        ),
        CircuitComponent(
          id: "wire_3",
          type: ComponentType.wire,
          x: 0,
          y: 0,
        ),
        CircuitComponent(
          id: "wire_4",
          type: ComponentType.wire,
          x: 0,
          y: 0,
        ),
        CircuitComponent(
          id: "wire_5",
          type: ComponentType.wire,
          x: 0,
          y: 0,
        ),
      ],
      targetComponentIds: ["bulb_2"],
    ),
    GameLevel(
      levelNumber: 3,
      title: "Double Trouble",
      description: "Light up two bulbs with one battery",
      objective: "Create a parallel circuit to power both bulbs",
      gridWidth: 8,
      gridHeight: 6,
      initialComponents: [
        CircuitComponent(
          id: "battery_3",
          type: ComponentType.battery,
          x: 1,
          y: 3,
          direction: Direction.right,
        ),
        CircuitComponent(
          id: "bulb_3a",
          type: ComponentType.bulb,
          x: 5,
          y: 2,
        ),
        CircuitComponent(
          id: "bulb_3b",
          type: ComponentType.bulb,
          x: 5,
          y: 4,
        ),
      ],
      availableComponents: [
        CircuitComponent(
          id: "wire_6",
          type: ComponentType.wire,
          x: 0,
          y: 0,
        ),
        CircuitComponent(
          id: "wire_7",
          type: ComponentType.wire,
          x: 0,
          y: 0,
        ),
        CircuitComponent(
          id: "wire_8",
          type: ComponentType.wire,
          x: 0,
          y: 0,
        ),
        CircuitComponent(
          id: "wire_9",
          type: ComponentType.wire,
          x: 0,
          y: 0,
        ),
        CircuitComponent(
          id: "wire_10",
          type: ComponentType.wire,
          x: 0,
          y: 0,
        ),
        CircuitComponent(
          id: "wire_11",
          type: ComponentType.wire,
          x: 0,
          y: 0,
        ),
      ],
      targetComponentIds: ["bulb_3a", "bulb_3b"],
    ),
    GameLevel(
      levelNumber: 4,
      title: "Resistance",
      description: "Control current flow with resistors",
      objective: "Use resistors to properly power the sensitive bulb",
      gridWidth: 10,
      gridHeight: 6,
      initialComponents: [
        CircuitComponent(
          id: "battery_4",
          type: ComponentType.battery,
          x: 1,
          y: 3,
          direction: Direction.right,
        ),
        CircuitComponent(
          id: "bulb_4",
          type: ComponentType.bulb,
          x: 8,
          y: 3,
        ),
      ],
      availableComponents: [
        CircuitComponent(
          id: "resistor_1",
          type: ComponentType.resistor,
          x: 0,
          y: 0,
        ),
        CircuitComponent(
          id: "wire_12",
          type: ComponentType.wire,
          x: 0,
          y: 0,
        ),
        CircuitComponent(
          id: "wire_13",
          type: ComponentType.wire,
          x: 0,
          y: 0,
        ),
        CircuitComponent(
          id: "wire_14",
          type: ComponentType.wire,
          x: 0,
          y: 0,
        ),
      ],
      targetComponentIds: ["bulb_4"],
    ),
    GameLevel(
      levelNumber: 5,
      title: "Master Circuit",
      description: "Complex circuit with multiple switches and components",
      objective: "Create a circuit where each switch controls different bulbs",
      gridWidth: 12,
      gridHeight: 8,
      initialComponents: [
        CircuitComponent(
          id: "battery_5",
          type: ComponentType.battery,
          x: 2,
          y: 4,
          direction: Direction.right,
        ),
        CircuitComponent(
          id: "bulb_5a",
          type: ComponentType.bulb,
          x: 8,
          y: 2,
        ),
        CircuitComponent(
          id: "bulb_5b",
          type: ComponentType.bulb,
          x: 8,
          y: 4,
        ),
        CircuitComponent(
          id: "bulb_5c",
          type: ComponentType.bulb,
          x: 8,
          y: 6,
        ),
      ],
      availableComponents: [
        CircuitComponent(
          id: "switch_2",
          type: ComponentType.circuitSwitch,
          x: 0,
          y: 0,
        ),
        CircuitComponent(
          id: "switch_3",
          type: ComponentType.circuitSwitch,
          x: 0,
          y: 0,
        ),
        CircuitComponent(
          id: "resistor_2",
          type: ComponentType.resistor,
          x: 0,
          y: 0,
        ),
      ] + List.generate(12, (i) => CircuitComponent(
        id: "wire_${15 + i}",
        type: ComponentType.wire,
        x: 0,
        y: 0,
      )),
      targetComponentIds: ["bulb_5a", "bulb_5b", "bulb_5c"],
    ),
  ];

  static List<GameLevel> getAllLevels() => _levels;
  
  static GameLevel? getLevelByNumber(int levelNumber) {
    try {
      return _levels.firstWhere((level) => level.levelNumber == levelNumber);
    } catch (e) {
      return null;
    }
  }
  
  static bool isLevelUnlocked(int levelNumber, List<int> completedLevels) {
    if (levelNumber == 1) return true;
    return completedLevels.contains(levelNumber - 1);
  }
  
  static int getTotalLevels() => _levels.length;
  
  static List<GameLevel> getUnlockedLevels(List<int> completedLevels) {
    return _levels.where((level) => 
      isLevelUnlocked(level.levelNumber, completedLevels)
    ).toList();
  }
}