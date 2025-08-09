# Project: Circuit Kids - The Blueprint

This document serves as the comprehensive blueprint for the "Circuit Kids" mobile game MVP. It includes business requirements, functional specifications, technical architecture, and a development roadmap.

## Table of Contents

1.  [Business Requirements Document (BRD)](#1-business-requirements-document-brd)
2.  [Functional Requirements Documents (FRDs) for MVP Levels](#2-functional-requirements-documents-frds-for-mvp-levels)
3.  [Technical Requirements Document (TRD) - Flutter + Flame](#3-technical-requirements-document-trd---flutter--flame)
4.  [Project Documentation and Guides](#4-project-documentation-and-guides)
5.  [Core Code Implementation](#5-core-code-implementation)

---

## 1. Business Requirements Document (BRD)

### 1.1. Purpose

The MVP of Circuit Kids aims to launch with 5 engaging puzzle types that teach basic electrical concepts while providing interactive, visually appealing gameplay. The goal is to:
*   Attract initial users with satisfying “light bulb” moments.
*   Establish a core puzzle engine that supports future expansions.
*   Demonstrate variety and replayability within the first release.

### 1.2. Scope

#### In Scope (MVP)

*   **5 Level Variants:**
    *   **Circuit 1 (Basic Series):** Introduces series circuit logic.
    *   **Parallel Play:** Demonstrates parallel circuit behavior.
    *   **Short Circuit Detective:** Identify and fix faults.
    *   **Switch Maze:** Toggle switches to complete the path.
    *   **Shape Fitter (Spatial Circuits):** Fit components into the grid to complete the circuit.
*   **Core Features:**
    *   Drag-and-drop placement of components.
    *   Real-time visual feedback for powered/unpowered states.
    *   Bulb glow animation (fade-in and pulsing).
    *   Wire “electricity flowing” animation when powered.
    *   Distinct sound effects for placing components, toggling switches, and circuit completion.
    *   Circuit validation engine (detects open paths, short circuits, and incomplete states).
*   **Platforms:** iOS & Android (tablet-optimized).

#### Out of Scope (MVP)

*   Custom level creation tools.
*   Sandbox/free-build mode.
*   Multiplayer or online leaderboard features.
*   Complex timing/sequencer puzzles.
*   Video-guided tutorials.

### 1.3. Requirements

#### 1.3.1 Functional Requirements

| ID    | Requirement                                                       | Priority |
| :---- | :---------------------------------------------------------------- | :------- |
| FR-01 | Implement series and parallel circuit validation logic.           | High     |
| FR-02 | Enable component dragging with scale-up & glow effect.            | High     |
| FR-03 | Show animated electricity flow in powered wires.                  | High     |
| FR-04 | Bulbs glow with smooth fade-in & pulse when powered.              | High     |
| FR-05 | Detect and prevent short circuits in “Short Circuit Detective” mode.| High     |
| FR-06 | Allow toggling of switch components with visual ON/OFF states.    | High     |
| FR-07 | Play unique sound effects for placing, toggling, and completion.  | Medium   |
| FR-08 | Display “Circuit Complete” celebration animation upon success.    | Medium   |

#### 1.3.2 Non-Functional Requirements

*   **Performance:** All animations and feedback must trigger within 150ms of action.
*   **Accessibility:** Components should be large enough for children’s touch interaction.
*   **Device Support:** Must run smoothly on devices from the past 5 years.
*   **Localization Ready:** UI text and instructions easily replaceable for different languages.

### 1.4. Level Details

| Level Name                  | Description                                                  | Learning Objective                         | Unique Challenge                     | Difficulty   |
| :-------------------------- | :----------------------------------------------------------- | :----------------------------------------- | :----------------------------------- | :----------- |
| **Circuit 1 (Basic Series)**| Connect all components in a single series path.              | Understand basic current flow.             | Linear path, 1 possible solution.    | Easy         |
| **Parallel Play**           | Create two or more parallel paths to power multiple bulbs.   | Learn parallel connections & power sharing.| Branching paths, multiple solutions. | Easy–Medium  |
| **Short Circuit Detective** | Find and remove a faulty connection causing a short circuit. | Teach circuit safety & troubleshooting.    | Player must identify hidden fault.   | Medium       |
| **Switch Maze**             | Use multiple switches to control circuit flow.               | Learn control of current using switches.   | Toggle in correct order to light all bulbs. | Medium       |
| **Shape Fitter**            | Fit oddly shaped components into grid to complete a circuit. | Combine spatial reasoning with circuit logic.| Limited space, rotation matters.     | Medium       |

### 1.5. Risks & Mitigation

| Risk                                | Impact | Mitigation                                           |
| :---------------------------------- | :----- | :--------------------------------------------------- |
| Complex validation logic leads to bugs | High   | Build and test a modular circuit-checking engine early.|
| Younger players find puzzles too hard | Medium | Include easy tutorial hints in first 2 levels.       |
| Animation lag on older devices      | Medium | Optimize animations and use lightweight effects.     |
| Overlap issues with drag-and-drop   | Low    | Use grid snapping for component placement.           |

### 1.6. Success Criteria

*   Players complete at least 70% of MVP levels without quitting mid-level.
*   Positive player feedback on fun factor and visual feedback in early reviews.
*   Codebase ready for expansion with additional level types after MVP launch.

---

## 2. Functional Requirements Documents (FRDs) for MVP Levels

### 2.1. FRD 1 – Circuit 1 (Basic Series)

*   **Purpose:** Introduce the player to a simple series circuit where all components are connected end-to-end.
*   **Gameplay Flow:**
    1.  Player sees an empty grid with a battery, one or more bulbs, and a few wire pieces.
    2.  Battery is pre-placed; bulbs are fixed in position.
    3.  Player drags and drops wire pieces into the grid to connect battery → bulb(s) → back to battery.
    4.  On completion:
        *   Circuit validation runs.
        *   If correct, electricity flow animation starts along wires, bulbs fade in and pulse.
        *   “Circuit Complete” message with sound and haptic feedback.
*   **Functional Requirements:**
    *   `FR1-1`: Drag-and-drop must snap components to grid cells.
    *   `FR1-2`: Series circuit logic must require all components connected in a single unbroken path.
    *   `FR1-3`: Power flows from positive battery terminal through all components back to negative terminal.
    *   `FR1-4`: Show immediate visual feedback when circuit is complete.
    *   `FR1-5`: Trigger success audio and haptic feedback.
*   **Assets Needed:** Battery sprite, Bulb sprite (with OFF, glow fade-in, and pulse animation states), Wire sprites (straight, corner), Electricity flow effect.
*   **Edge Cases:**
    *   Player creates a loop without the bulb — must not trigger success.
    *   Player leaves open ends — no animation should play.
    *   Multiple paths but only one complete path to bulb — still valid if all bulbs light.

### 2.2. FRD 2 – Parallel Play

*   **Purpose:** Teach parallel circuit connections where multiple branches share the same power source.
*   **Gameplay Flow:**
    1.  Player starts with battery and multiple bulbs fixed on grid.
    2.  Player has wire pieces to connect bulbs so each has a path from battery positive to negative.
    3.  When at least two parallel branches are complete:
        *   Electricity animation runs simultaneously through all active paths.
        *   All bulbs glow independently.
*   **Functional Requirements:**
    *   `FR2-1`: Circuit logic must support branching from a single node.
    *   `FR2-2`: Each bulb must be independently powered.
    *   `FR2-3`: If one branch is incomplete, other branches still work.
    *   `FR2-4`: Animation must show simultaneous electricity flow in all complete branches.
*   **Assets Needed:** Same as FRD 1, plus possible junction piece sprites.
*   **Edge Cases:**
    *   Player connects bulbs in series by mistake — should still light if path is complete, but show hint that they are not in parallel.
    *   Player connects one bulb correctly, leaves others unpowered — partial success but no full completion animation until all powered.

### 2.3. FRD 3 – Short Circuit Detective

*   **Purpose:** Teach safety and troubleshooting by introducing a short circuit that must be fixed.
*   **Gameplay Flow:**
    1.  Circuit is pre-built but has one hidden fault — direct connection from battery positive to negative without a load.
    2.  Player taps wire segments to remove or replace them.
    3.  Circuit works only when short is removed.
    4.  Success triggers animation and message: “Fault Fixed!”
*   **Functional Requirements:**
    *   `FR3-1`: Detect any direct positive → negative connection with no load as a short circuit.
    *   `FR3-2`: Prevent electricity flow animation if short circuit exists.
    *   `FR3-3`: Allow player to replace faulty part with correct wire/bulb.
    *   `FR3-4`: Display warning icon when short is detected (optional).
*   **Assets Needed:** Warning icon overlay, Tap-to-remove animation, Pre-configured faulty circuit layout.
*   **Edge Cases:**
    *   Player fixes short but leaves another part disconnected — should not pass.
    *   Player creates a different short while fixing — should still block completion.

### 2.4. FRD 4 – Switch Maze

*   **Purpose:** Teach current control using switches in multiple positions.
*   **Gameplay Flow:**
    1.  Pre-placed switches and wires form a maze-like path from battery to bulbs.
    2.  Player taps switches to toggle between ON/OFF.
    3.  Correct ON/OFF combination completes the circuit.
    4.  On correct configuration, electricity flows and bulbs glow.
*   **Functional Requirements:**
    *   `FR4-1`: Switch states must toggle between open (no flow) and closed (flow).
    *   `FR4-2`: Circuit validation must recalculate instantly after any switch toggle.
    *   `FR4-3`: Visual state change on switch (lever flips, color change).
    *   `FR4-4`: Success triggers standard animation, audio, and haptic feedback.
*   **Assets Needed:** Switch sprite with two states, Switch toggle sound, Maze-style grid background.
*   **Edge Cases:**
    *   Multiple valid ON/OFF combinations possible — system should accept any that complete circuit.
    *   Player toggles rapidly — must handle without lag.

### 2.5. FRD 5 – Shape Fitter (Spatial Circuits)

*   **Purpose:** Combine spatial reasoning with circuit logic by using irregularly shaped wire pieces.
*   **Gameplay Flow:**
    1.  Player starts with fixed battery and bulb positions.
    2.  Irregular-shaped wire pieces (L-shapes, T-shapes) are available.
    3.  Player rotates and places pieces to connect components.
    4.  Circuit must be complete in both shape and connectivity.
*   **Functional Requirements:**
    *   `FR5-1`: Allow rotation of pieces (90° increments).
    *   `FR5-2`: Circuit validation must check both shape placement and connectivity.
    *   `FR5-3`: Pieces snap to grid cells.
    *   `FR5-4`: Success triggers standard completion effects.
*   **Assets Needed:** Multiple irregular wire shapes, Rotation button/icon, Placement snap animation.
*   **Edge Cases:**
    *   Piece overlaps battery/bulb — must be prevented.
    *   Player forms closed loop without powering bulbs — not valid.

---
## 3. Technical Requirements Document (TRD) - Flutter + Flame

### 3.1. High-Level Architecture

*   **Stack:** Flutter (stable), Flame (latest stable), no physics engine.
*   **Target:** iOS + Android (tablet-ready).
*   **Team size for MVP:** 2 devs (1 UI/Flutter + Flame, 1 gameplay/engine), + 1 part-time artist/sound.
*   **Estimated MVP timeline:** 6–10 weeks.
*   **Key Design Choice:** Keep circuit logic in a pure-Dart layer, separate from Flame rendering, to ensure testability and isolation.

### 3.2. File Tree

```
lib/
├── main.dart
├── app.dart
├── routes.dart
├── common/
│   ├── constants.dart
│   ├── theme.dart
│   ├── utils.dart
│   └── asset_manager.dart
├── models/
│   ├── grid.dart
│   ├── cell.dart
│   ├── component.dart
│   └── level_definition.dart
├── services/
│   ├── logic_engine.dart         // pure Dart: build_graph + evaluate
│   ├── level_loader.dart         // load JSON levels
│   └── persistence_service.dart  // save progress
├── game/
│   ├── circuit_game.dart         // FlameGame subclass
│   ├── components/               // Flame PositionComponents
│   │   ├── comp_battery.dart
│   │   ├── comp_bulb.dart
│   │   ├── comp_wire.dart
│   │   └── comp_switch.dart
│   └── ui_overlay.dart           // HUD overlay (Flutter)
├── screens/
│   ├── main_menu.dart
│   ├── level_select.dart
│   └── game_screen.dart          // hosts a GameWidget with overlays
├── widgets/
│   ├── rounded_button.dart
│   ├── level_card.dart
│   └── hint_chip.dart
├── assets/
│   ├── images/ ...
│   ├── audio/  ...
│   └── levels/ (level1.json ...)
├── test/
│   ├── logic_engine_test.dart
│   └── grid_model_test.dart
pubspec.yaml
```

### 3.3. File-by-File Breakdown

*   **lib/main.dart:** App entry point.
*   **lib/app.dart:** MaterialApp / top-level app configuration.
*   **lib/routes.dart:** Route definitions and helpers.
*   **lib/common/constants.dart:** App-wide constants.
*   **lib/common/theme.dart:** UI styling and typography.
*   **lib/common/utils.dart:** Small helpers used everywhere.
*   **lib/common/asset_manager.dart:** Preload & access assets.
*   **lib/models/grid.dart:** Grid data model.
*   **lib/models/cell.dart:** Single grid cell model.
*   **lib/models/component.dart:** Component model & enums.
*   **lib/models/level_definition.dart:** Level JSON schema model.
*   **lib/services/logic_engine.dart:** Pure-Dart circuit evaluator.
*   **lib/services/level_loader.dart:** Load levels from assets.
*   **lib/services/persistence_service.dart:** Save/load progress.
*   **lib/game/circuit_game.dart:** FlameGame subclass and orchestrator.
*   **lib/game/components/*.dart:** Flame components for battery, bulb, wire, switch.
*   **lib/game/ui_overlay.dart:** Flutter overlay HUD for the GameWidget.
*   **lib/screens/main_menu.dart:** Main menu screen widget.
*   **lib/screens/level_select.dart:** Level list/grid UI.
*   **lib/screens/game_screen.dart:** Hosts GameWidget and overlays.
*   **lib/widgets/*.dart:** Reusable UI widgets.
*   **assets/images/:** Image assets.
*   **assets/audio/:** Audio assets.
*   **assets/levels/:** Level data in JSON format.
*   **test/logic_engine_test.dart:** Unit tests for the logic engine.
*   **test/grid_model_test.dart:** Unit tests for the grid model.
*   **pubspec.yaml:** Flutter config & assets.

### 3.4. Level Data Format (JSON Schema)

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "Circuit Kids Level Schema",
  "type": "object",
  "required": ["id","title","rows","cols","initial_components","goals"],
  "properties": {
    "id": { "type": "string" },
    "title": { "type": "string" },
    "rows": { "type": "integer", "minimum": 3, "maximum": 12 },
    "cols": { "type": "integer", "minimum": 3, "maximum": 12 },
    "initial_components": {
      "type": "array",
      "items": {
        "type": "object",
        "required": ["type","r","c","id"],
        "properties": {
          "id": { "type": "string" },
          "type": { "type": "string", "enum": ["battery","bulb","wire_straight","wire_corner","wire_t","switch"] },
          "r": { "type": "integer" },
          "c": { "type": "integer" },
          "rotation": { "type": "integer", "enum": [0,90,180,270] },
          "state": { "type": "object" }
        }
      }
    },
    "goals": {
      "type": "array",
      "items": {
        "type": "object",
        "required": ["type"],
        "properties": {
          "type": { "type": "string", "enum": ["power_bulb"] },
          "r": { "type": "integer" },
          "c": { "type": "integer" }
        }
      }
    },
    "hints": { "type": "array", "items": { "type": "string" } }
  }
}
```

### 3.5. Core Logic: Precise Responsibilities & Pseudocode

*   **Terminal Mapping:** For each component type and rotation, define the terminal positions and directions (N, E, S, W).
*   **Graph Building:** Create a graph representation of the circuit, where nodes are component terminals.
*   **Evaluation (BFS):** Use a Breadth-First Search (BFS) algorithm to determine which components are powered, starting from the battery's positive terminal.
*   **Short Detection:** Detect short circuits by checking for a direct path from the battery's positive to negative terminal without passing through a load (e.g., a bulb).
*   **Evaluation Result:** The logic engine should return a result object containing the set of powered component IDs, a boolean indicating if a short circuit was detected, a list of open endpoints, and any debug messages.

### 3.6. UX & Interaction Details

*   **Drag & Drop:** Implement drag and drop for components using Flame's `Draggable` mixin or custom pointer handling.
*   **Immediate Feedback:** Provide immediate visual feedback after a component is placed or a switch is toggled.
*   **Hints:** The logic engine should be able to provide hints, such as highlighting open endpoints.
*   **Animation Latency:** Ensure that all visual updates start within 150ms of a user action.

### 3.7. Assets & Naming Conventions

*   **Image Assets:** Use SVG or PNG formats for all image assets (e.g., `battery.png`, `bulb_off.png`).
*   **Audio Assets:** Use WAV format for all audio assets (e.g., `place.wav`, `toggle.wav`).
*   **Level JSON:** Store level data in JSON files (e.g., `level_01.json`).
*   **Naming Convention:** Use lowercase snake_case for all asset files.

### 3.8. Testing Strategy

*   **Unit Tests:** Write unit tests for the core logic engine and the grid model.
*   **Test Coverage:** Aim for high test coverage of the logic engine to prevent regressions.

### 3.9. Anticipated Issues & Fixes

*   **Tight Coupling:** Keep the rendering and logic layers separate to avoid tight coupling.
*   **Drag & Drop Issues:** Use cell snapping and test on multiple screen sizes to avoid drag and drop issues.
*   **Complex Wire Shapes:** Start with a simple set of wire shapes and add more complex shapes later.
*   **Audio & Animation Latency:** Preload sounds and sprites to avoid latency.
*   **Performance on Older Devices:** Keep the grid size small and optimize animations to ensure good performance on older devices.
*   **Short Detection Edge Cases:** Use a pruning approach to detect short circuits and provide a debug overlay to trace paths during QA.

### 3.10. Simplifications for a Small Team

*   **Grid Size:** Fix the grid size to 6x6 for the MVP.
*   **Component Set:** Use a limited set of components for the MVP.
*   **No Physics:** Do not integrate a physics engine for the MVP.
*   **No Level Editor:** Postpone the development of a level editor to a future release.
*   **State Management:** Use a simple state management solution like `ChangeNotifier`.

### 3.11. Suggested Dev Workflow & Sprint Plan (6–10 weeks)

*   **Sprint 0 (Setup):** Initialize the repository, set up CI/CD, and define the code style.
*   **Sprint 1 (Core Logic):** Implement the models and the logic engine.
*   **Sprint 2 (Flame Integration & Grid UI):** Implement the `CircuitGame` class and load the grid background.
*   **Sprint 3 (Drag & Drop + Placement Flow):** Implement the drag and drop functionality.
*   **Sprint 4 (Evaluation & Visuals):** Hook up the evaluation to the UI updates and implement the visual feedback.
*   **Sprint 5 (Levels & Polish):** Build the MVP levels and add hints and reset/undo functionality.
*   **Sprint 6 (QA & Release Prep):** Test the game on multiple devices, fix bugs, and prepare for release.

### 3.12. Delivery Checklist

*   Repository with a `README.md` file.
*   `pubspec.yaml` file with all the dependencies and assets.
*   JSON files for all the MVP levels.
*   Unit tests passing.
*   CI pipeline with `flutter test`.
*   Pixel distance guidelines documented in `common/constants.dart`.
*   A toggle to enable a debug overlay.

### 3.13. Code Skeletons

(See the original document for the code skeletons)

### 3.14. Tools & Dev Environment

*   Flutter stable SDK
*   Android Studio or VSCode
*   iOS toolchain for Mac
*   Flame package
*   `flutter_lints` for linting
*   GitHub Actions for CI
*   GitHub for source control

### 3.15. Final Recommendations

*   Implement the logic first.
*   Integrate Flame for the visuals.
*   Keep the UI simple.
*   Preload assets.
*   Expose a debug overlay.

---

## 4. Project Documentation and Guides

### 4.1. Logic Reference & Terminal Mapping (`DOCS/LOGIC.md`)

(See the original document for the logic reference)

### 4.2. Level JSON Schema (`assets/levels/level-schema.json`)

(See the original document for the JSON schema)

### 4.3. CI Workflow (`.github/workflows/ci.yml`)

(See the original document for the CI workflow)

---

## 5. Core Code Implementation

### 5.1. Core Models (`lib/models/*.dart`)

(See the original document for the core models)

### 5.2. Core Logic Engine (`lib/services/logic_engine.dart`)

(See the original document for the core logic engine)

### 5.3. Integration API

(See the original document for the integration API)

### 5.4. Unit Test Examples

(See the original document for the unit test examples)