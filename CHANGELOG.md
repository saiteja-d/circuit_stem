
## [Unreleased] - 2025-08-18

### Changed

- **Drawing Logic Refinement**:
    - Refined `lib/ui/canvas_painter.dart` to make grid and dragged component colors theme-aware.
    - Updated `lib/ui/game_canvas.dart` to pass these theme-aware colors to the painter.
    - Fixed analyzer warnings by removing unused imports and replacing a deprecated `withOpacity` call.
- **New Component Implementation (Cross Wire & Buzzer)**:
    - Added `crossWire` and `buzzer` to the `ComponentType` enum in `lib/models/component.dart`.
    - Updated the `isDraggable` property for the new components.
    - Regenerated the `freezed` and `g` files using `build_runner`.
    - Implemented the drawing logic for `crossWire` and `buzzer` in `lib/ui/painters/circuit_component_painter.dart`.
    - Integrated a sound effect for the buzzer, playing it when the buzzer becomes powered, by modifying `lib/engine/game_engine_notifier.dart` and `lib/engine/game_engine_state.dart`.
- **Component Placement in Levels**:
    - Reverted the `level_01.json` palette to its original state.
    - Created a new `level_02.json` file, incorporating the new `crossWire` and `buzzer` components into its initial setup and palette.
- **Rotatable Wire Feature**:
    - Implemented a `rotateComponent` method in `lib/engine/game_engine_notifier.dart` to allow rotation of draggable components.
    - Modified the `handleTap` method in `GameEngineNotifier` to select components.
    - Updated the UI in `lib/ui/game_canvas.dart` to show a rotate button when a draggable component is selected.
    - Added a rotatable `wire_straight` component to `level_02.json` to demonstrate the new feature.
