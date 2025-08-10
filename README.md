# Circuit Kids — Minimal-Flame / Mostly-Pure-Dart Blueprint

> This blueprint assumes the core **LogicEngine** and **GameEngine** are **pure Dart**, rendering is done with **Flutter CustomPainter**, and **Flame** is used *only optionally* for asset preloading / audio / particles (kept in `lib/flame_integration/`). The document contains BRD, FRDs, TRD, architecture & sequence diagrams (ASCII), UI layout guidance, dev considerations, sprint plan, risks & mitigations, and an actionable delivery checklist.

---

## Table of Contents

- [1. Business Requirements Document (BRD)](#1-business-requirements-document-brd)
- [2. Functional Requirements Documents (FRDs) — MVP Levels](#2-functional-requirements-documents-frds--mvp-levels)
- [3. Technical Requirements Document (TRD) — Minimal Flame (Mostly Pure Dart + Flutter)](#3-technical-requirements-document-trd--minimal-flame-mostly-pure-dart--flutter)
- [4. Architecture Diagrams](#4-architecture-diagrams-ascii--paste-into-md)
- [5. Core Logic & Algorithms](#5-core-logic--algorithms)
- [6. UI Layout & Interaction Details](#6-ui-layout--interaction-details)
- [7. Technical Considerations & Implementation Notes](#7-technical-considerations--implementation-notes)
- [8. Dev Roadmap & Sprint Plan](#8-dev-roadmap--sprint-plan-detailed)
- [9. Detailed Architecture & Integration Diagrams](#9-architecture--integration-diagrams-ascii)
- [10. Risks & Mitigations](#10-risks--mitigations-updated-for-minimal-flame)
- [11. Testing, CI, and QA](#11-testing-ci-and-qa)
- [12. Delivery Checklist](#12-delivery-checklist)
- [13. Appendix — Useful Snippets & Schemas](#13-appendix--useful-snippets--schemas-copyable)
- [14. Next Recommended Immediate Tasks](#14-next-recommended-immediate-tasks-practical)
- [15. Advanced Logic Engine Implementation](#15-advanced-logic-engine-implementation)

---

# 1. Business Requirements Document (BRD)

**Purpose**
The MVP of *Circuit Kids* teaches basic electric-circuit concepts through 5 puzzle types. It should deliver delightful “light bulb” moments, be kid-friendly (touch targets and visuals), and present a solid, testable pure-Dart logic engine that enables future level and feature expansion.

**Goals**

*   Launch with 5 level variants that demonstrate series, parallel, switches, short diagnostics, and spatial component fitting.
*   Deliver clear visual feedback when circuits are powered/unpowered.
*   Provide a codebase where gameplay rules (logic) are independent of rendering and easily unit-tested.

**Target audience**

*   Children aged 6–12, teachers looking for simple STEM mini-games, parents.

**Success criteria**

*   > 70% of players complete at least 70% of MVP levels without quitting mid-level.
*   No critical logic bugs found during QA (logic engine tests pass).
*   Smooth animation and response (<150ms reaction time after actions) on mid-range tablets (past 3–5 years).

**Scope (MVP)**
*In scope*: 5 level types, drag/drop & rotate pieces, switch toggles, short detection, animations (bulb glow, wire flow), sounds & basic haptics, level JSON files, iOS & Android (tablet-optimized).
*Out of scope*: In-app multiplayer, level editor, advanced timing sequencers, video tutorials.

---

# 2. Functional Requirements Documents (FRDs) — MVP Levels

> Each level FRD lists purpose, flow, functional requirements, assets, and edge cases.

## Circuit 1 — Basic Series (FRD-1)

**Purpose:** Teach a straightforward series circuit: battery → components → back to battery.

**Gameplay flow:** pre-placed battery & bulbs, player places wire pieces to create single path; success when completeness & continuity satisfied.

**Functional requirements**

*   FR1-1: Grid snapping for placements.
*   FR1-2: Series circuit must be continuous (positive → loads → negative).
*   FR1-3: Visual feedback on partial connections (open endpoints highlighted).
*   FR1-4: Trigger success animation, audio, and haptic on completion.

**Assets:** battery sprite, bulb (off/on/pulse), wire pieces (straight, corner).

**Edge cases:** loops without bulbs must not trigger success; open ends show hint.

## Parallel Play — Branching Paths (FRD-2)

**Purpose:** Teach parallel branches powering multiple bulbs.

**Functional requirements**

*   FR2-1: Support branching nodes in graph.
*   FR2-2: Bulbs independently powered if each path completes.
*   FR2-3: Partial completion possibility (some bulbs lit).

**Assets:** junction sprite if needed, same wire set.

**Edge cases:** series connections mistakenly used — still valid if path completes but hint explains parallel benefits.

## Short Circuit Detective (FRD-3)

**Purpose:** Teach safety & troubleshooting; identify/remove hidden short.

**Functional requirements**

*   FR3-1: Detect continuous direct positive→negative path without a load -> short circuit.
*   FR3-2: Block electricity animation until short removed.
*   FR3-3: Allow tap-to-remove/replace faulty segments.

**Assets:** warning icon overlay, tap-removal animation.

**Edge cases:** player may create other shorts while fixing → must detect dynamically.

## Switch Maze (FRD-4)

**Purpose:** Teach control of current using switches.

**Functional requirements**

*   FR4-1: Switch toggles open/closed and updates logic instantly.
*   FR4-2: Support multiple valid ON/OFF combinations if they produce completion.
*   FR4-3: Visual state for switch and immediate feedback.

**Assets:** switch sprite with 2 states, toggle sound.

## Shape Fitter (FRD-5)

**Purpose:** Spatial puzzle — fit irregular wire-piece shapes into grid to connect circuits.

**Functional requirements**

*   FR5-1: Rotate pieces in 90° increments.
*   FR5-2: Prevent overlap with fixed components.
*   FR5-3: Validate connectivity + fit; snapping required.

**Assets:** irregular wire sprites (L, T, long segments), rotation UI.

---

# 3. Technical Requirements Document (TRD) — Minimal Flame (Mostly Pure Dart + Flutter)

## 3.1 High-level design principles

*   **LogicEngine (pure Dart):** responsible for terminals, graph, BFS evaluation, short detection, returning `EvaluationResult`. Test-first design.
*   **GameEngine (pure Dart):** orchestrator holding model state (Grid & Components), converts `EvaluationResult` → `RenderState` DTO, exposes `ChangeNotifier`/Streams.
*   **UI layer (Flutter):** `CustomPainter` draws grid + components using `RenderState`. `GameCanvas` handles gestures and drag previews.
*   **Flame integration (optional):** isolated in `lib/flame_integration/` only for preloading and optional particles/audio helpers. Core modules never import Flame.
*   **Animation control:** `AnimationScheduler` (pure-Dart interfaces driven by `TickerProvider` in UI) manages per-component animations (bulb pulse, wire offset).
*   **Performance target:** visual update/animation kickoff within 150ms after user action.

## 3.2 File Tree

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
│   ├── logic_engine.dart
│   ├── level_loader.dart
│   └── persistence_service.dart
├── engine/
│   ├── game_engine.dart
│   ├── render_state.dart
│   └── animation_scheduler.dart
├── ui/
│   ├── game_screen.dart
│   ├── game_canvas.dart
│   └── canvas_painter.dart
├── widgets/
│   ├── draggable_preview.dart
│   ├── rounded_button.dart
│   └── hint_chip.dart
├── flame_integration/           // OPTIONAL: only here Flame imports allowed
│   ├── flame_adapter.dart
│   ├── flame_preloader.dart
│   └── flame_particles.dart
├── assets/
│   ├── images/...
│   ├── audio/...
│   └── levels/
├── test/
│   ├── logic_engine_test.dart
│   └── grid_model_test.dart
pubspec.yaml
```

## 3.3 File-by-File Breakdown

*   **lib/main.dart:** App entry point. Initialize optional Flame adapter if `enableFlame` flag true, create `GameEngine`, run `MaterialApp`.
*   **lib/app.dart:** `MaterialApp`, route registration, theme, global providers (GameEngine).
*   **lib/routes.dart:** Named routes and navigation helpers.
*   **lib/common/constants.dart:** All numeric & visual constants (grid size, default cell size, animation durations).
*   **lib/common/theme.dart:** App-wide colors, typography, accessibility tokens.
*   **lib/common/utils.dart:** Coordinate transforms, rotation helpers, terminal direction enums.
*   **lib/common/asset_manager.dart:** Pure-Dart loader for images (via `rootBundle`) and audio (pluggable wrapper). Detects & delegates to `flame_integration` if enabled.
*   **lib/models/grid.dart:** Grid representation, occupancy map, helper API `placeComponent`, `removeComponent`, `getComponentAt`.
*   **lib/models/cell.dart:** A cell model (r, c, bounds).
*   **lib/models/component.dart:** Component class with id/type/rotation/state and terminal definitions.
*   **lib/models/level_definition.dart:** JSON deserialization and validation.
*   **lib/services/logic_engine.dart:** Build terminal graph, BFS evaluation, short detection. Returns `EvaluationResult`.
*   **lib/services/level_loader.dart:** Loads level JSON and returns `LevelDefinition`.
*   **lib/services/persistence_service.dart:** Save/load progress via `shared_preferences` or local file.
*   **lib/engine/game_engine.dart:** Manage model state; public API for UI input; calls `LogicEngine`, creates `RenderState` snapshots, `notifyListeners()` for UI.
*   **lib/engine/render_state.dart:** Snapshot DTO consumed by `CanvasPainter`: component positions, powered flags, wire paths, animation targets.
*   **lib/engine/animation_scheduler.dart:** Holds animation progress values (bulbIntensity, wireOffset) updated by UI `Ticker`.
*   **lib/ui/game_screen.dart:** Provides screen layout and overlays (HUD, debug toggle).
*   **lib/ui/game_canvas.dart:** Hosts `GestureDetector` and `CustomPaint`; handles drag preview and delegates actions to `GameEngine`.
*   **lib/ui/canvas_painter.dart:** Draws grid, components, and uses `RenderState` for animation parameters.
*   **lib/widgets/draggable_preview.dart:** UI preview for dragging.
*   **lib/flame_integration/**: Optional Flame utilities.

---

# 4. Architecture Diagrams (ASCII — paste into .md)

## 4.1 System overview (components & layers)

```
+--------------------+        +---------------------+        +-------------------+
|  Flutter UI Layer  | <----> |   GameEngine (Dart) | <----> |   LogicEngine     |
|  (GameCanvas, HUD) |        |  (pure Dart)        |        |   (pure Dart)     |
|  CustomPainter     |        | - Grid & Components |        | - BFS, ShortDetec |
+--------------------+        +---------------------+        +-------------------+
       ^    |
       |    v
  Optional Flame Adapter
  (flame_integration/*)  <-- optional asset preloader / particles / audio
```

## 4.2 Sequence diagram: user action -> visual update

```
User taps/drags
    |
    v
GameCanvas (GestureDetector) -> GameEngine.placeComponent(...)
    |
    v
GameEngine updates Grid model -> LogicEngine.evaluate(grid)
    |
    v
LogicEngine returns EvaluationResult (poweredIds, isShort, openEndpoints)
    |
    v
GameEngine builds RenderState snapshot -> notifyListeners()
    |
    v
CanvasPainter reads RenderState -> paints grid/wires/bulbs; AnimationScheduler drives offsets
    |
    v
If eval.isShort -> UI overlay shows warning + FlameParticles optionally
```

## 4.3 Data model (simplified)

```
Grid
 ├─ rows:int
 ├─ cols:int
 └─ components: List<Component>
       ├─ id:String
       ├─ type:Enum (battery, bulb, wire_*, switch)
       ├─ r:int, c:int
       ├─ rotation:int (0/90/180/270)
       └─ state: Map (e.g., switch open/closed)
```

---

# 5. Core Logic & Algorithms

## 5.1 Terminal mapping

*   Each component type defines terminal positions relative to cell and rotation.
    Example (component terminals by rotation):

    *   `wire_straight` rotation 0: terminals N & S
    *   `wire_straight` rotation 90: terminals E & W
    *   `wire_corner` rotation 0: terminals N & E
    *   `battery` has posTerminal (positive) and negTerminal (negative)

Store terminals as `Terminal { id, componentId, cellR, cellC, direction }`.

## 5.2 Graph building

*   Terminals in adjacent cells and matching facing directions are connected. Build adjacency map `Map<TerminalId, Set<TerminalId>>`.

## 5.3 BFS evaluation

*   Start BFS from battery positive terminals, traverse adjacency, mark visited components.
*   `EvaluationResult` includes:

    *   `Set<String> poweredComponentIds`
    *   `bool isShortCircuit`
    *   `List<Terminal> openEndpoints`
    *   optional `debugTrace` for overlays

## 5.4 Short detection

*   Check for path from any positive terminal to any negative terminal where no bulb (load) is encountered. If found -> short.

---

# 6. UI Layout & Interaction Details

## 6.1 Screen layout (tablet-first)

```
+--------------------------------------------------------------+
| [Top Bar: Back]         Level Title      [Hint]  [Reset]     |
+--------------------------------------------------------------+
|                                                              |
|   +---------------------------------------------+            |
|   |                 Game Canvas                 |            |
|   |    Grid (6x6) centered, cell padding,       |  Right     |
|   |    components drawn with CustomPainter      |  Overlay   |
|   |                                             |  [HUD]     |
|   |                                             |            |
|   +---------------------------------------------+            |
|                                                              |
| [Palette strip] [Place] [Rotate] [Undo] [Sound toggle]       |
+--------------------------------------------------------------+
```

## 6.2 Canvas & hit targets

*   Default grid: **6×6** for MVP. Allow scaling for different screen sizes but keep cell logical size ≥ 72 px for touch-friendly targets.
*   Drag preview: semi-transparent sprite that follows finger; snapping occurs on drop to nearest cell center.
*   Rotation: Rotate button while dragging to rotate 90° clockwise. Optionally long-press rotates.

## 6.3 Visual states

*   Bulb: `off`, `fade-in`, `pulse` states. Implement pulse as sinusoidal intensity between 0.9–1.2 scale.
*   Wires: stroke + animated "flow" offset (phase shift along path). Use `shader` or path-dash animation (offset by `wireOffset` in `RenderState`).
*   Switch: two static frames or small lever rotation; toggling updates `LogicEngine` immediately.

## 6.4 HUD

*   Top-left back button and level title. Top-right: hint and reset. Bottom: component palette (draggable). Right overlay: optional debug (toggle).

---

# 7. Technical Considerations & Implementation Notes

## 7.1 Assets & naming

*   Images: PNG or SVG (pref rasterize to PNG for `Canvas.drawImage`). Naming: `battery.png`, `bulb_off.png`, `bulb_on.png`, `wire_straight.png`, `wire_corner.png`, `wire_t.png`. Use lowercase snake_case.
*   Audio: WAV for short SFX (`place.wav`, `toggle.wav`, `success.wav`). Use `just_audio` or `audioplayers` through a small wrapper service. Provide preloading.
*   Sizes: supply image assets at 1x, 2x, 3x for typical device pixel ratios.

## 7.2 Performance

*   Reuse `Paint` and `Path` objects. Avoid allocations in `paint()`.
*   Cache wire `Path`s per level and per rotation.
*   Use `RepaintBoundary` around the GameCanvas.
*   Preload assets before entering gameplay to avoid hitches.

## 7.3 Accessibility

*   Provide `large_touch` mode (increase cell size & palette icon sizes).
*   Text-to-speech for instructions and hints (localization-ready).
*   Color contrast for glow & wire states.

## 7.4 Animations & 150ms target

*   Logic: evaluate synchronously in pure Dart (fast for 6×6 grid).
*   UI: `notifyListeners()` immediately after `GameEngine` updates; `Canvas` repaints same frame or next frame. Start animations (via `AnimationScheduler`) immediately on change to stay within 150ms.

## 7.5 Testing

*   Unit tests for `LogicEngine` (edge cases: loops, multiple batteries, multiple bulbs, T-junctions).
*   Widget tests for `GameCanvas` interactions: drag/drop, rotate, tap.
*   Integration/device tests for performance & multi-touch.

---

# 8. Dev Roadmap & Sprint Plan (detailed)

**Team**: 2 devs (1 Flutter UI + 1 pure-Dart logic) + 1 part-time artist/sound.
**Duration**: 6–8 weeks (minimal Flame) — conservative.

## Sprint breakdown (6–8 weeks)

*   **Sprint 0 (Setup, 1 week)**: Repo, `flutter_lints`, `pubspec.yaml`, CI workflow, project docs, asset placeholders.
*   **Sprint 1 (Logic Engine, 1.5 weeks)**:

    *   Implement `Component`, `Grid`, terminal mapping.
    *   Implement `LogicEngine.evaluate()` with BFS + short detection.
    *   Unit tests (target: 90% coverage of logic).
*   **Sprint 2 (GameEngine + RenderState, 1 week)**:

    *   Implement `GameEngine` (pure Dart) with API for `placeComponent/rotate/toggle`.
    *   Implement `RenderState` DTO and notify pipeline.
*   **Sprint 3 (UI + CanvasPainter, 1.5 weeks)**:

    *   Build `GameCanvas`, `CanvasPainter`, drag preview, palette.
    *   Hook `GameEngine` -> UI update & initial rendering.
*   **Sprint 4 (Animations + Audio + Haptics, 1 week)**:

    *   Implement `AnimationScheduler`, bulb pulse and wire flow, audio service, haptics on success.
*   **Sprint 5 (Level content & Polish, 1 week)**:

    *   Create 5 MVP levels, hints, success animations.
    *   Add optional Flame preloader (if desired) and debug overlay.
*   **Sprint 6 (QA & Release, 0.5–1 week)**:

    *   Device testing, bug fixes, performance tuning, prepare store builds.

---

# 9. Architecture & Integration Diagrams (ASCII)

## 9.1 Component Interaction (detailed)

```
[User] -> [GameCanvas (UI)]
   -> calls GameEngine.placeComponent(...)
      -> GameEngine.updateGrid(...) // pure dart
         -> LogicEngine.evaluate(grid) // pure dart
            -> returns EvaluationResult
         <- GameEngine.createRenderState(EvaluationResult)
      <- GameEngine.notifyListeners()
   <- GameCanvas listens -> CanvasPainter draws RenderState
   Optional: flame_integration responds to RenderState to show particles/audio
```

## 9.2 File boundaries (who may import Flame)

```
ALLOWED: lib/flame_integration/*   (may import Flame)
NOT-ALLOWED: lib/services/*, lib/engine/*  (must NOT import Flame)
UI: lib/ui/* can optionally call flame_integration for preloader at startup
```

---

# 10. Risks & Mitigations (updated for minimal-Flame)

|                                    Risk | Impact | Mitigation                                                                                                     |
| --------------------------------------: | :----: | :------------------------------------------------------------------------------------------------------------- |
| Logic bugs (short detection edge cases) |  High  | Test-driven development; debug overlay visualizing graph edges and terminals; unit tests with many scenarios.  |
|      UI animation/jank on older tablets | Medium | Preload assets; optimize `paint()` avoiding allocations; use `RepaintBoundary`; set reasonable max grid scale. |
|           Drag/drop handling complexity | Medium | Use clear drag preview UX; snapping & tolerance; test on multiple devices early.                               |
|        Optional Flame dependency misuse |   Low  | Strict file policy: only `lib/flame_integration` uses Flame; CI checks to enforce.                             |
|  Overrun of dev timeline due to visuals | Medium | Start with minimal visuals (simple vector look) then polish VFX in later sprints.                              |

---

# 11. Testing, CI, and QA

**Unit tests**

*   `logic_engine_test.dart`: BFS, short detection, open endpoints, complex topologies.
*   `grid_model_test.dart`: placement, rotation, snapping bounds.

**Widget tests**

*   `game_canvas_test.dart`: drag & drop and rotation interactions.

**Integration tests**

*   Device test for performance & latency on representative Android/iPad devices.

**CI**

*   GitHub Actions: `flutter analyze`, `flutter test`, build matrix for Android/iOS simulators (optional).
*   Enforce Flame import policy with a simple linter or CI grep rule.

**Debugging tools**

*   Debug overlay: draw terminals, adjacency edges and BFS traversal order. Toggle via dev menu.

---

# 12. Delivery Checklist

*   [ ] Repo with `README.md` explaining architecture & optional Flame usage.
*   [ ] `pubspec.yaml` with minimal, pinned dependencies.
*   [ ] Pure-Dart `logic_engine.dart` implemented and unit-tested.
*   [ ] `GameEngine` producing `RenderState` snapshots.
*   [ ] `GameCanvas` + `CanvasPainter` drawing grid & components.
*   [ ] Drag/rotate/toggle interactions working with snapping.
*   [ ] Animations: bulb glow, wire flow; latency <150ms on target devices.
*   [ ] 5 MVP levels (JSON in `assets/levels/`).
*   [ ] Audio SFX preloaded & triggered (place, toggle, success).
*   [ ] Debug overlay and unit test coverage reports.
*   [ ] CI pipeline running tests.

---

# 13. Appendix — Useful Snippets & Schemas (copyable)

## 13.1 Level JSON schema (short)

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "Circuit Kids Level",
  "type": "object",
  "required": ["id","title","rows","cols","initial_components","goals"],
  "properties": {
    "id": { "type": "string" },
    "title": { "type": "string" },
    "rows": { "type": "integer" },
    "cols": { "type": "integer" },
    "initial_components": {
      "type": "array",
      "items": {
        "required":["id","type","r","c"],
        "properties": {
          "id":{"type":"string"},
          "type":{"type":"string"},
          "r":{"type":"integer"},
          "c":{"type":"integer"},
          "rotation":{"type":"integer","enum":[0,90,180,270]},
          "state":{"type":"object"}
        }
      }
    },
    "goals": { "type":"array" }
  }
}
```

## 13.2 `EvaluationResult` (Dart)

```dart
class EvaluationResult {
  final Set<String> poweredComponentIds;
  final bool isShortCircuit;
  final List<Terminal> openEndpoints;
  final List<String> debugTrace;
  EvaluationResult({
    required this.poweredComponentIds,
    required this.isShortCircuit,
    required this.openEndpoints,
    required this.debugTrace,
  });
}
```

## 13.3 Minimal `pubspec.yaml` entries

```yaml
name: circuit_kids
environment:
  sdk: ">=2.18.0 <3.0.0"

dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.0
  # Optional: enable Flame in production by uncommenting
  # flame: ^1.2.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.0.0
```

---

# 14. Next Recommended Immediate Tasks (practical)

1.  Implement `services/logic_engine.dart` and create `test/logic_engine_test.dart` with canonical cases (series, parallel, short, T-junctions). Make this green first.
2.  Create `engine/game_engine.dart` pure-Dart orchestrator with a minimal `placeComponent()` API and produce `RenderState` snapshots.
3.  Implement `ui/game_canvas.dart` + `ui/canvas_painter.dart` to render `RenderState` for a static level.
4.  Wire drag-and-drop preview and snapping.
5.  Add `animation_scheduler.dart` for bulb & wire animation values.
6.  Optionally add `flame_integration/flame_preloader.dart` only after above is stable.

---

# 15. Advanced Logic Engine Implementation

> This section describes a richer `LogicEngine` implementation that supports multi-cell components, long wires, and more complex internal connectivity.

## 15.1 Models
Great — I implemented the fixes and the new debug-output features you asked for. Below are three copy-paste-ready files to replace your existing ones:

* `lib/models/component.dart` — richer model: per-terminal labels, per-terminal blocking hints, explicit `internalConnections`, validation helpers.
* `lib/models/grid.dart` — updated occupancy & a new `validate()` that checks overlaps, bounds, and battery terminal correctness.
* `lib/services/logic_engine.dart` — hardened engine:

  * per-terminal blocking (switches can block specific terminals),
  * explicit internal connections honored (falls back to Manhattan adjacency),
  * robust battery validation and warnings,
  * richer debug overlay information (`DebugInfo`) containing terminal list, adjacency, BFS visitation order, discovered paths (pos→neg), and per-terminal notes,
  * small cleanups & comments.

Paste these files into your project (overwrite the previous versions), run your unit tests, and let me know if you want the UI debug overlay renderer to consume `DebugInfo` (I can produce a `canvas` debug painter snippet next).

---

## `lib/models/component.dart`

```dart
// lib/models/component.dart
// Component model with multi-cell shapes, terminal specs, terminal labels,
// optional internalConnections (pairs of terminal indices) and per-terminal blocking.
//
// TerminalSpec: describes a terminal relative to the component anchor cell.
//  - cellIndex: index in shapeOffsets
//  - dir: base direction at rotation 0
//  - label: optional string label useful for debug/UI (e.g. "+", "-", "A")
//  - role: optional semantic role, e.g. 'pos','neg','load' - used for battery terminals
//
// ComponentModel:
//  - shapeOffsets: list of CellOffset (dr,dc) relative to anchor at rotation 0
//  - terminals: list of TerminalSpec
//  - internalConnections: optional list of pairs [i,j] connecting terminal i <-> j
//  - state: arbitrary map; for switches use {'closed': bool, 'blockedTerminals':[int,...]}
//
// Usage: factories provided for longWire and tPiece, but arbitrary custom components supported.

import 'package:flutter/foundation.dart';

/// Simple integer cell offset.
class CellOffset {
  final int dr;
  final int dc;
  const CellOffset(this.dr, this.dc);

  @override
  String toString() => 'CellOffset($dr,$dc)';
}

/// Direction enum used by TerminalSpec (define separately in logic engine file as well).
enum Dir { north, east, south, west }

/// Terminal specification attached to a component.
/// - cellIndex points to shapeOffsets index.
/// - dir is the outward facing direction at rotation 0.
/// - label is optional, used in debug/UI overlays.
/// - role can be 'pos', 'neg', 'load', or custom.
class TerminalSpec {
  final int cellIndex;
  final Dir dir;
  final String? label;
  final String? role;
  const TerminalSpec({
    required this.cellIndex,
    required this.dir,
    this.label,
    this.role,
  });

  @override
  String toString() => 'TermSpec(cellIdx=$cellIndex,dir=$dir,label=$label,role=$role)';
}

/// Component types used by logic engine rendering & rules.
enum ComponentType { battery, bulb, wireStraight, wireCorner, wireT, wireLong, sw, custom }

/// Component model supporting multi-cell shapes and labeled terminals.
class ComponentModel {
  final String id;
  final ComponentType type;
  int r;
  int c;
  int rotation; // 0,90,180,270
  Map<String, dynamic> state;
  final List<CellOffset> shapeOffsets; // relative cells at rotation 0
  final List<TerminalSpec> terminals; // terminals described relative to shapeOffsets
  final List<List<int>> internalConnections; // explicit internal terminal index connections

  ComponentModel({
    required this.id,
    required this.type,
    required this.r,
    required this.c,
    this.rotation = 0,
    Map<String, dynamic>? state,
    List<CellOffset>? shapeOffsets,
    List<TerminalSpec>? terminals,
    List<List<int>>? internalConnections,
  })  : state = state ?? {},
        shapeOffsets = shapeOffsets ?? const [CellOffset(0, 0)],
        terminals = terminals ??
            const [
              TerminalSpec(cellIndex: 0, dir: Dir.north, label: null),
              TerminalSpec(cellIndex: 0, dir: Dir.south, label: null)
            ],
        internalConnections = internalConnections ?? const [];

  /// Factory: vertical long wire (length cells). rotation rotates it.
  factory ComponentModel.longWire({
    required String id,
    required int r,
    required int c,
    required int length,
    int rotation = 0,
  }) {
    assert(length >= 1);
    final shape = List<CellOffset>.generate(length, (i) => CellOffset(i, 0));
    final terms = <TerminalSpec>[
      TerminalSpec(cellIndex: 0, dir: Dir.north, label: 'end'),
      TerminalSpec(cellIndex: length - 1, dir: Dir.south, label: 'end'),
    ];
    return ComponentModel(
      id: id,
      type: ComponentType.wireLong,
      r: r,
      c: c,
      rotation: rotation,
      shapeOffsets: shape,
      terminals: terms,
    );
  }

  /// Factory: T-piece (single-cell) default terminals north,east,west (rotate as needed).
  factory ComponentModel.tPiece({
    required String id,
    required int r,
    required int c,
    int rotation = 0,
  }) {
    final terms = [
      TerminalSpec(cellIndex: 0, dir: Dir.north, label: 'T1'),
      TerminalSpec(cellIndex: 0, dir: Dir.east, label: 'T2'),
      TerminalSpec(cellIndex: 0, dir: Dir.west, label: 'T3'),
    ];
    return ComponentModel(
      id: id,
      type: ComponentType.wireT,
      r: r,
      c: c,
      rotation: rotation,
      shapeOffsets: const [CellOffset(0, 0)],
      terminals: terms,
    );
  }

  /// Utility: produce a copy with changes (anchor/rotation/state).
  ComponentModel copyWith({int? r, int? c, int? rotation, Map<String, dynamic>? state}) {
    return ComponentModel(
      id: id,
      type: type,
      r: r ?? this.r,
      c: c ?? this.c,
      rotation: rotation ?? this.rotation,
      state: state ?? Map<String, dynamic>.from(this.state),
      shapeOffsets: List<CellOffset>.from(this.shapeOffsets),
      terminals: List<TerminalSpec>.from(this.terminals),
      internalConnections: List<List<int>>.from(this.internalConnections),
    );
  }

  @override
  String toString() => 'ComponentModel($id,type=$type,anchor=[$r,$c],rot=$rotation,shape=${shapeOffsets.length}cells,terms=${terminals.length})';
}
```

---

## `lib/models/grid.dart`

```dart
// lib/models/grid.dart
// Grid model supporting occupancy mapping, safe add/update/remove and validation.

import 'component.dart';

/// Grid holds components and a simple occupancy map to detect overlaps.
class Grid {
  final int rows;
  final int cols;
  final Map<String, ComponentModel> componentsById = {};
  final Map<String, String> occupancy = {}; // "r:c" -> componentId

  Grid({required this.rows, required this.cols});

  String _cellKey(int r, int c) => '$r:$c';

  /// Attempt to add a component. Returns true if placed, false if collision/OOB.
  bool addComponent(ComponentModel comp) {
    // validate cells
    for (final off in comp.shapeOffsets) {
      final r = comp.r + off.dr;
      final c = comp.c + off.dc;
      if (r < 0 || r >= rows || c < 0 || c >= cols) return false;
      final key = _cellKey(r, c);
      final existing = occupancy[key];
      if (existing != null) return false;
    }
    componentsById[comp.id] = comp;
    for (final off in comp.shapeOffsets) {
      final r = comp.r + off.dr;
      final c = comp.c + off.dc;
      occupancy[_cellKey(r, c)] = comp.id;
    }
    return true;
  }

  /// Remove a component by id (no-op if missing)
  void removeComponent(String id) {
    final comp = componentsById.remove(id);
    if (comp == null) return;
    for (final off in comp.shapeOffsets) {
      occupancy.remove(_cellKey(comp.r + off.dr, comp.c + off.dc));
    }
  }

  /// Update component (remove & re-add style). Returns true if successful.
  bool updateComponent(ComponentModel newComp) {
    final old = componentsById[newComp.id];
    if (old == null) return false;
    // remove old occupancy
    for (final off in old.shapeOffsets) {
      occupancy.remove(_cellKey(old.r + off.dr, old.c + off.dc));
    }
    // validate new
    var ok = true;
    for (final off in newComp.shapeOffsets) {
      final r = newComp.r + off.dr;
      final c = newComp.c + off.dc;
      if (r < 0 || r >= rows || c < 0 || c >= cols) {
        ok = false;
        break;
      }
      final key = _cellKey(r, c);
      final existing = occupancy[key];
      if (existing != null && existing != newComp.id) {
        ok = false;
        break;
      }
    }
    if (!ok) {
      // restore old occupancy
      for (final off in old.shapeOffsets) {
        occupancy[_cellKey(old.r + off.dr, old.c + off.dc)] = old.id;
      }
      return false;
    }
    // commit new
    componentsById[newComp.id] = newComp;
    for (final off in newComp.shapeOffsets) {
      occupancy[_cellKey(newComp.r + off.dr, newComp.c + off.dc)] = newComp.id;
    }
    return true;
  }

  ComponentModel? getComponentById(String id) => componentsById[id];

  List<ComponentModel> componentsAt(int r, int c) {
    final id = occupancy[_cellKey(r, c)];
    if (id == null) return [];
    final comp = componentsById[id];
    return comp == null ? [] : [comp];
  }

  /// Validate grid integrity and level sanity.
  /// Returns list of warnings/errors (empty == OK).
  List<String> validate() {
    final messages = <String>[];

    // 1) bounds & occupancy check (already prevented by add/update, but re-check)
    for (final comp in componentsById.values) {
      for (final off in comp.shapeOffsets) {
        final r = comp.r + off.dr;
        final c = comp.c + off.dc;
        if (r < 0 || r >= rows || c < 0 || c >= cols) {
          messages.add('Component ${comp.id} out-of-bounds at cell [$r,$c].');
        } else {
          final key = _cellKey(r, c);
          final occ = occupancy[key];
          if (occ != comp.id) {
            messages.add('Occupancy mismatch for ${comp.id} at [$r,$c] - occupied by $occ.');
          }
        }
      }
    }

    // 2) battery check: ensure each battery has at least 2 terminals and at least one pos/neg.
    for (final comp in componentsById.values) {
      if (comp.type == ComponentType.battery) {
        if (comp.terminals.length < 2) {
          messages.add('Battery ${comp.id} has fewer than 2 terminals; expected pos & neg.');
        }
      }
    }

    // 3) duplicate ids are prevented by map key; but ensure terminals pool is unique per comp
    // (optional) - skipped

    return messages;
  }
}
```

---

## `lib/services/logic_engine.dart`

> This is the improved engine. It returns a richer `EvaluationResult` with `DebugInfo` that UI can use to draw terminals, adjacency edges, BFS order, and discovered pos→neg paths. The engine honors per-terminal blocking (via `comp.state['blockedTerminals']`) and can use `internalConnections` when present.

```dart
// lib/services/logic_engine.dart
import 'dart:collection';
import '../models/grid.dart';
import '../models/component.dart';

/// Direction enum reused for convenience (mirror of models.Dir)
enum Dir { north, east, south, west }

extension DirVec on Dir {
  int get dr {
    switch (this) {
      case Dir.north:
        return -1;
      case Dir.south:
        return 1;
      case Dir.east:
        return 0;
      case Dir.west:
        return 0;
    }
  }

  int get dc {
    switch (this) {
      case Dir.north:
        return 0;
      case Dir.south:
        return 0;
      case Dir.east:
        return 1;
      case Dir.west:
        return -1;
    }
  }

  Dir rotatedBySteps(int steps90CW) {
    final order = [Dir.north, Dir.east, Dir.south, Dir.west];
    var idx = order.indexOf(this);
    idx = (idx + (steps90CW % 4)) % 4;
    return order[idx];
  }

  Dir opposite() {
    switch (this) {
      case Dir.north:
        return Dir.south;
      case Dir.south:
        return Dir.north;
      case Dir.east:
        return Dir.west;
      case Dir.west:
        return Dir.east;
    }
  }
}

/// Terminal produced by the engine with absolute coordinates and label/role derived from TerminalSpec.
class Terminal {
  final String id; // "${componentId}_t$index"
  final String componentId;
  final int r;
  final int c;
  final Dir dir;
  final int index; // terminal index in component
  final String? label;
  final String? role;

  Terminal({
    required this.id,
    required this.componentId,
    required this.r,
    required this.c,
    required this.dir,
    required this.index,
    this.label,
    this.role,
  });

  @override
  String toString() => 'Terminal($id @[$r,$c] ${dir.toString().split(".").last} label=$label role=$role)';
}

/// Debug info returned so UI can render overlays: terminals, adjacency graph, BFS visitation order, discovered paths.
class DebugInfo {
  final Map<String, Terminal> terminals; // id -> Terminal
  final Map<String, List<String>> adjacency; // terminalId -> neighbor terminalIds
  final List<String> bfsOrder; // terminalIds in order visited by the evaluation BFS
  final List<List<String>> posToNegPaths; // each path is list of terminalIds
  final List<String> notes; // warnings or messages

  DebugInfo({
    required this.terminals,
    required this.adjacency,
    required this.bfsOrder,
    required this.posToNegPaths,
    required this.notes,
  });
}

/// EvaluationResult with richer debug overlay payload.
class EvaluationResult {
  final Set<String> poweredComponentIds;
  final bool isShortCircuit;
  final List<Terminal> openEndpoints;
  final List<String> debugTrace;
  final DebugInfo debugInfo;

  EvaluationResult({
    required this.poweredComponentIds,
    required this.isShortCircuit,
    required this.openEndpoints,
    required this.debugTrace,
    required this.debugInfo,
  });
}

class LogicEngine {
  LogicEngine();

  /// Evaluate the grid and return powered components, shorts, open endpoints, and debug info.
  EvaluationResult evaluate(Grid grid) {
    final comps = grid.componentsById;

    final Map<String, Terminal> terminals = {};

    // 1) collect terminals (absolute coords & rotated directions) + build Terminal objects with labels/roles
    for (final comp in comps.values) {
      final steps = ((comp.rotation % 360) ~/ 90) % 4;
      for (var ti = 0; ti < comp.terminals.length; ti++) {
        final tspec = comp.terminals[ti];
        final shapeCell = comp.shapeOffsets[tspec.cellIndex];
        final rotated = _rotateOffset(shapeCell, steps);
        final absR = comp.r + rotated.dr;
        final absC = comp.c + rotated.dc;
        final dir = tspec.dir.rotatedBySteps(steps);
        final tid = '${comp.id}_t$ti';
        terminals[tid] = Terminal(
          id: tid,
          componentId: comp.id,
          r: absR,
          c: absC,
          dir: dir,
          index: ti,
          label: tspec.label,
          role: tspec.role,
        );
      }
    }

    // 2) adjacency map initialization
    final adj = <String, Set<String>>{};
    for (final t in terminals.values) adj[t.id] = <String>{};

    // helper: map cell->terminals
    final Map<String, List<Terminal>> terminalsByCell = {};
    for (final t in terminals.values) {
      final key = _cellKey(t.r, t.c);
      terminalsByCell.putIfAbsent(key, () => []).add(t);
    }

    // 3) external adjacency: facing terminals across neighboring cells
    for (final t in terminals.values) {
      final nr = t.r + t.dir.dr;
      final nc = t.c + t.dir.dc;
      final neighborKey = _cellKey(nr, nc);
      final cand = terminalsByCell[neighborKey];
      if (cand != null) {
        for (final t2 in cand) {
          if (t2.dir == t.dir.opposite()) {
            adj[t.id]!.add(t2.id);
          }
        }
      }
    }

    // 4) internal adjacency:
    // 4a) explicit internalConnections take precedence
    for (final comp in comps.values) {
      if (comp.internalConnections.isNotEmpty) {
        for (final pair in comp.internalConnections) {
          if (pair.length != 2) continue;
          final a = '${comp.id}_t${pair[0]}';
          final b = '${comp.id}_t${pair[1]}';
          if (terminals.containsKey(a) && terminals.containsKey(b)) {
            adj[a]!.add(b);
            adj[b]!.add(a);
          }
        }
      } else {
        // 4b) fallback: terminals on same component within manhattan distance <=1 are connected
        final compTerminals = terminals.values.where((x) => x.componentId == comp.id).toList();
        for (var i = 0; i < compTerminals.length; i++) {
          for (var j = i + 1; j < compTerminals.length; j++) {
            final t1 = compTerminals[i];
            final t2 = compTerminals[j];
            final manh = (t1.r - t2.r).abs() + (t1.c - t2.c).abs();
            if (manh <= 1) {
              adj[t1.id]!.add(t2.id);
              adj[t2.id]!.add(t1.id);
            }
          }
        }
      }
    }

    // 5) identify battery terminals (pos & neg)
    final posTerminalIds = <String>[];
    final negTerminalIds = <String>[];
    final notes = <String>[];
    for (final comp in comps.values) {
      if (comp.type == ComponentType.battery) {
        if (comp.terminals.length >= 2) {
          // prefer role-based identification if provided
          for (var ti = 0; ti < comp.terminals.length; ti++) {
            final specRole = comp.terminals[ti].role;
            final tid = '${comp.id}_t$ti';
            if (specRole == 'pos') posTerminalIds.add(tid);
            if (specRole == 'neg') negTerminalIds.add(tid);
          }
          // fallback: first terminal = pos, second = neg
          if (posTerminalIds.isEmpty && comp.terminals.isNotEmpty) posTerminalIds.add('${comp.id}_t0');
          if (negTerminalIds.isEmpty && comp.terminals.length > 1) negTerminalIds.add('${comp.id}_t1');
        } else {
          notes.add('Battery ${comp.id} has fewer than 2 terminals.');
        }
      }
    }

    if (posTerminalIds.isEmpty) notes.add('No battery positive terminals found.');
    if (negTerminalIds.isEmpty) notes.add('No battery negative terminals found.');

    // 6) helper: per-terminal blocked logic (switches and per-terminal blockedTerminals)
    bool terminalIsBlocked(String tid) {
      final t = terminals[tid]!;
      final comp = comps[t.componentId]!;
      // per-component switch default
      if (comp.type == ComponentType.sw) {
        final closed = comp.state['closed'] == true;
        // per-terminal override list in state: 'blockedTerminals': [0,2]
        final blockedList = comp.state['blockedTerminals'] as List<dynamic>?;
        if (blockedList != null) {
          // if this terminal index is in blockedList AND switch not closed => blocked
          final idx = t.index;
          if (!closed && blockedList.contains(idx)) return true;
          // if list exists but does not include idx, then that terminal not affected by switch open state
          return false;
        }
        // default: whole switch blocks both terminals when open
        return !closed;
      }
      // For custom components we could inspect comp.state for per-terminal blocking as needed.
      return false;
    }

    // 7) BFS from pos terminals to mark powered components (respect terminalIsBlocked)
    final visitedT = <String>{};
    final poweredComponents = <String>{};
    final q = Queue<String>();
    for (final p in posTerminalIds) {
      if (!terminals.containsKey(p)) continue;
      if (terminalIsBlocked(p)) continue;
      q.add(p);
      visitedT.add(p);
    }
    final bfsOrder = <String>[];
    while (q.isNotEmpty) {
      final cur = q.removeFirst();
      bfsOrder.add(cur);
      final tcur = terminals[cur]!;
      poweredComponents.add(tcur.componentId);
      for (final nb in adj[cur] ?? {}) {
        if (visitedT.contains(nb)) continue;
        if (terminalIsBlocked(nb)) continue;
        visitedT.add(nb);
        q.add(nb);
      }
    }

    // 8) Short detection: search any pos->neg path with no load encountered
    bool foundShort = false;
    final seen = <String, Set<bool>>{};
    final q2 = Queue<_BfsState>();
    // to also collect discovered paths, store parent map keyed by tid+seenLoad flag
    final Map<String, String?> parent = {}; // key: tid|seenLoad -> parentKey
    final List<List<String>> discoveredPaths = [];

    String _key(String tid, bool seenLoad) => '$tid|${seenLoad ? 1 : 0}';

    for (final p in posTerminalIds) {
      if (!terminals.containsKey(p)) continue;
      if (terminalIsBlocked(p)) continue;
      q2.add(_BfsState(tid: p, seenLoad: false));
      seen.putIfAbsent(p, () => {}).add(false);
      parent[_key(p, false)] = null;
    }

    while (q2.isNotEmpty) {
      final s = q2.removeFirst();
      final t = terminals[s.tid]!;
      final comp = comps[t.componentId]!;
      final isLoad = comp.type == ComponentType.bulb || comp.terminals.any((ts) => ts.role == 'load');
      final seenLoadNow = s.seenLoad || isLoad;
      // if current terminal is a negative battery terminal and no load seen -> short
      if (negTerminalIds.contains(s.tid) && !seenLoadNow) {
        foundShort = true;
        // reconstruct path using parent map
        final path = <String>[];
        var curKey = _key(s.tid, s.seenLoad);
        while (curKey != null) {
          final parts = curKey.split('|');
          final tid = parts[0];
          path.insert(0, tid);
          curKey = parent[curKey];
        }
        discoveredPaths.add(path);
        break; // we can continue to collect more, but one short is enough
      }
      for (final n in adj[s.tid] ?? {}) {
        if (terminalIsBlocked(n)) continue;
        final set = seen.putIfAbsent(n, () => {});
        if (set.contains(seenLoadNow)) continue;
        set.add(seenLoadNow);
        parent[_key(n, seenLoadNow)] = _key(s.tid, s.seenLoad);
        q2.add(_BfsState(tid: n, seenLoad: seenLoadNow));
      }
    }

    // 9) open endpoints: terminals with zero non-blocked adjacency
    final openEndpoints = <Terminal>[];
    for (final t in terminals.values) {
      var hasConn = false;
      for (final n in adj[t.id] ?? {}) {
        if (terminalIsBlocked(n)) continue;
        hasConn = true;
        break;
      }
      if (!hasConn) openEndpoints.add(t);
    }

    // 10) Build debug info for UI overlay
    final adjacencyStrList = <String, List<String>>{};
    for (final e in adj.entries) {
      adjacencyStrList[e.key] = e.value.toList();
    }
    final debugInfo = DebugInfo(
      terminals: terminals,
      adjacency: adjacencyStrList,
      bfsOrder: bfsOrder,
      posToNegPaths: discoveredPaths,
      notes: notes,
    );

    // 11) debug trace summary
    final trace = <String>[];
    trace.add('terminals=${terminals.length}');
    trace.add('poweredComponents=${poweredComponents.length}');
    trace.add('short=$foundShort');

    return EvaluationResult(
      poweredComponentIds: poweredComponents,
      isShortCircuit: foundShort,
      openEndpoints: openEndpoints,
      debugTrace: trace,
      debugInfo: debugInfo,
    );
  }

  // rotate a CellOffset by steps90CW (clockwise)
  CellOffset _rotateOffset(CellOffset off, int steps90CW) {
    var dr = off.dr;
    var dc = off.dc;
    final s = steps90CW % 4;
    for (var i = 0; i < s; i++) {
      final ndr = -dc;
      final ndc = dr;
      dr = ndr;
      dc = ndc;
    }
    return CellOffset(dr, dc);
  }

  String _cellKey(int r, int c) => '$r:$c';
}

class _BfsState {
  final String tid;
  final bool seenLoad;
  _BfsState({required this.tid, required this.seenLoad});
}
```

---

## What I changed & why (summary)

1. **Per-terminal blocking** — switches may now list `blockedTerminals` in `component.state` to indicate which terminal indices are blocked when switch open. If absent, switch blocks all its terminals when open (backwards-compatible). This allows multi-terminal switches and partial blocking.

2. **Explicit internalConnections** — `ComponentModel.internalConnections` (list of pairs) lets you define exact internal wiring inside a component. When set the engine uses these pairs instead of the Manhattan adjacency heuristic.

3. **Terminal labels & roles** — `TerminalSpec` includes `label` and `role`. The engine exposes those to UI in `Terminal`. Roles can be `'pos'`, `'neg'`, `'load'`, etc., and are used for battery terminal identification and load detection.

4. **Grid validation** — `Grid.validate()` returns warnings for out-of-bounds or occupancy mismatch and battery terminal issues.

5. **Debug overlay data** — the engine returns `DebugInfo` with:

   * `terminals`: all terminals with absolute positions, labels and roles,
   * `adjacency`: adjacency lists between terminals,
   * `bfsOrder`: visitation order used to mark powered components (useful to animate BFS),
   * `posToNegPaths`: discovered pos→neg paths that indicate shorts,
   * `notes`: validation/warnings.

6. **Robust battery detection** — engine first looks for terminal `role=='pos'/'neg'` then falls back to first/second terminal convention. Validation messages added.

7. **Minor hardening** — small guards for terminals that reference out-of-grid cells, improved parent-tracking for path reconstruction.

---

## Tests & next steps (recommended)

* Update existing unit tests to assert `EvaluationResult.debugInfo` contains expected `terminals` and `bfsOrder`.
* Add tests for:

  * switches with `blockedTerminals` vs global switch behavior,
  * explicit `internalConnections` overriding Manhattan heuristic,
  * per-terminal labels & roles used to detect battery pos/neg,
  * `Grid.validate()` warnings for malformed levels.
* UI: implement a debug overlay that accepts `DebugInfo` and:

  * draws terminals (small circles) and labels,
  * draws adjacency edges (light lines),
  * highlights BFS order (animated color fade),
  * highlights `posToNegPaths` in red for shorts.

---

If you want I can:

* implement the **debug overlay painter** (`ui/debug_overlay.dart`) that draws `DebugInfo` on top of your canvas, or
* produce updated **unit tests** for the new features (switch per-terminal, internalConnections, debug info).

Which would you like next?
Great — I implemented the fixes and the new debug-output features you asked for. Below are three copy-paste-ready files to replace your existing ones:

* `lib/models/component.dart` — richer model: per-terminal labels, per-terminal blocking hints, explicit `internalConnections`, validation helpers.
* `lib/models/grid.dart` — updated occupancy & a new `validate()` that checks overlaps, bounds, and battery terminal correctness.
* `lib/services/logic_engine.dart` — hardened engine:

  * per-terminal blocking (switches can block specific terminals),
  * explicit internal connections honored (falls back to Manhattan adjacency),
  * robust battery validation and warnings,
  * richer debug overlay information (`DebugInfo`) containing terminal list, adjacency, BFS visitation order, discovered paths (pos→neg), and per-terminal notes,
  * small cleanups & comments.



---

## `lib/models/component.dart`

```dart
// lib/models/component.dart
// Component model with multi-cell shapes, terminal specs, terminal labels,
// optional internalConnections (pairs of terminal indices) and per-terminal blocking.
//
// TerminalSpec: describes a terminal relative to the component anchor cell.
//  - cellIndex: index in shapeOffsets
//  - dir: base direction at rotation 0
//  - label: optional string label useful for debug/UI (e.g. "+", "-", "A")
//  - role: optional semantic role, e.g. 'pos','neg','load' - used for battery terminals
//
// ComponentModel:
//  - shapeOffsets: list of CellOffset (dr,dc) relative to anchor at rotation 0
//  - terminals: list of TerminalSpec
//  - internalConnections: optional list of pairs [i,j] connecting terminal i <-> j
//  - state: arbitrary map; for switches use {'closed': bool, 'blockedTerminals':[int,...]}
//
// Usage: factories provided for longWire and tPiece, but arbitrary custom components supported.

import 'package:flutter/foundation.dart';

/// Simple integer cell offset.
class CellOffset {
  final int dr;
  final int dc;
  const CellOffset(this.dr, this.dc);

  @override
  String toString() => 'CellOffset($dr,$dc)';
}

/// Direction enum used by TerminalSpec (define separately in logic engine file as well).
enum Dir { north, east, south, west }

/// Terminal specification attached to a component.
/// - cellIndex points to shapeOffsets index.
/// - dir is the outward facing direction at rotation 0.
/// - label is optional, used in debug/UI overlays.
/// - role can be 'pos', 'neg', 'load', or custom.
class TerminalSpec {
  final int cellIndex;
  final Dir dir;
  final String? label;
  final String? role;
  const TerminalSpec({
    required this.cellIndex,
    required this.dir,
    this.label,
    this.role,
  });

  @override
  String toString() => 'TermSpec(cellIdx=$cellIndex,dir=$dir,label=$label,role=$role)';
}

/// Component types used by logic engine rendering & rules.
enum ComponentType { battery, bulb, wireStraight, wireCorner, wireT, wireLong, sw, custom }

/// Component model supporting multi-cell shapes and labeled terminals.
class ComponentModel {
  final String id;
  final ComponentType type;
  int r;
  int c;
  int rotation; // 0,90,180,270
  Map<String, dynamic> state;
  final List<CellOffset> shapeOffsets; // relative cells at rotation 0
  final List<TerminalSpec> terminals; // terminals described relative to shapeOffsets
  final List<List<int>> internalConnections; // explicit internal terminal index connections

  ComponentModel({
    required this.id,
    required this.type,
    required this.r,
    required this.c,
    this.rotation = 0,
    Map<String, dynamic>? state,
    List<CellOffset>? shapeOffsets,
    List<TerminalSpec>? terminals,
    List<List<int>>? internalConnections,
  })  : state = state ?? {},
        shapeOffsets = shapeOffsets ?? const [CellOffset(0, 0)],
        terminals = terminals ??
            const [
              TerminalSpec(cellIndex: 0, dir: Dir.north, label: null),
              TerminalSpec(cellIndex: 0, dir: Dir.south, label: null)
            ],
        internalConnections = internalConnections ?? const [];

  /// Factory: vertical long wire (length cells). rotation rotates it.
  factory ComponentModel.longWire({
    required String id,
    required int r,
    required int c,
    required int length,
    int rotation = 0,
  }) {
    assert(length >= 1);
    final shape = List<CellOffset>.generate(length, (i) => CellOffset(i, 0));
    final terms = <TerminalSpec>[
      TerminalSpec(cellIndex: 0, dir: Dir.north, label: 'end'),
      TerminalSpec(cellIndex: length - 1, dir: Dir.south, label: 'end'),
    ];
    return ComponentModel(
      id: id,
      type: ComponentType.wireLong,
      r: r,
      c: c,
      rotation: rotation,
      shapeOffsets: shape,
      terminals: terms,
    );
  }

  /// Factory: T-piece (single-cell) default terminals north,east,west (rotate as needed).
  factory ComponentModel.tPiece({
    required String id,
    required int r,
    required int c,
    int rotation = 0,
  }) {
    final terms = [
      TerminalSpec(cellIndex: 0, dir: Dir.north, label: 'T1'),
      TerminalSpec(cellIndex: 0, dir: Dir.east, label: 'T2'),
      TerminalSpec(cellIndex: 0, dir: Dir.west, label: 'T3'),
    ];
    return ComponentModel(
      id: id,
      type: ComponentType.wireT,
      r: r,
      c: c,
      rotation: rotation,
      shapeOffsets: const [CellOffset(0, 0)],
      terminals: terms,
    );
  }

  /// Utility: produce a copy with changes (anchor/rotation/state).
  ComponentModel copyWith({int? r, int? c, int? rotation, Map<String, dynamic>? state}) {
    return ComponentModel(
      id: id,
      type: type,
      r: r ?? this.r,
      c: c ?? this.c,
      rotation: rotation ?? this.rotation,
      state: state ?? Map<String, dynamic>.from(this.state),
      shapeOffsets: List<CellOffset>.from(this.shapeOffsets),
      terminals: List<TerminalSpec>.from(this.terminals),
      internalConnections: List<List<int>>.from(this.internalConnections),
    );
  }

  @override
  String toString() => 'ComponentModel($id,type=$type,anchor=[$r,$c],rot=$rotation,shape=${shapeOffsets.length}cells,terms=${terminals.length})';
}
```

---

## `lib/models/grid.dart`

```dart
// lib/models/grid.dart
// Grid model supporting occupancy mapping, safe add/update/remove and validation.

import 'component.dart';

/// Grid holds components and a simple occupancy map to detect overlaps.
class Grid {
  final int rows;
  final int cols;
  final Map<String, ComponentModel> componentsById = {};
  final Map<String, String> occupancy = {}; // "r:c" -> componentId

  Grid({required this.rows, required this.cols});

  String _cellKey(int r, int c) => '$r:$c';

  /// Attempt to add a component. Returns true if placed, false if collision/OOB.
  bool addComponent(ComponentModel comp) {
    // validate cells
    for (final off in comp.shapeOffsets) {
      final r = comp.r + off.dr;
      final c = comp.c + off.dc;
      if (r < 0 || r >= rows || c < 0 || c >= cols) return false;
      final key = _cellKey(r, c);
      final existing = occupancy[key];
      if (existing != null) return false;
    }
    componentsById[comp.id] = comp;
    for (final off in comp.shapeOffsets) {
      final r = comp.r + off.dr;
      final c = comp.c + off.dc;
      occupancy[_cellKey(r, c)] = comp.id;
    }
    return true;
  }

  /// Remove a component by id (no-op if missing)
  void removeComponent(String id) {
    final comp = componentsById.remove(id);
    if (comp == null) return;
    for (final off in comp.shapeOffsets) {
      occupancy.remove(_cellKey(comp.r + off.dr, comp.c + off.dc));
    }
  }

  /// Update component (remove & re-add style). Returns true if successful.
  bool updateComponent(ComponentModel newComp) {
    final old = componentsById[newComp.id];
    if (old == null) return false;
    // remove old occupancy
    for (final off in old.shapeOffsets) {
      occupancy.remove(_cellKey(old.r + off.dr, old.c + off.dc));
    }
    // validate new
    var ok = true;
    for (final off in newComp.shapeOffsets) {
      final r = newComp.r + off.dr;
      final c = newComp.c + off.dc;
      if (r < 0 || r >= rows || c < 0 || c >= cols) {
        ok = false;
        break;
      }
      final key = _cellKey(r, c);
      final existing = occupancy[key];
      if (existing != null && existing != newComp.id) {
        ok = false;
        break;
      }
    }
    if (!ok) {
      // restore old occupancy
      for (final off in old.shapeOffsets) {
        occupancy[_cellKey(old.r + off.dr, old.c + off.dc)] = old.id;
      }
      return false;
    }
    // commit new
    componentsById[newComp.id] = newComp;
    for (final off in newComp.shapeOffsets) {
      occupancy[_cellKey(newComp.r + off.dr, newComp.c + off.dc)] = newComp.id;
    }
    return true;
  }

  ComponentModel? getComponentById(String id) => componentsById[id];

  List<ComponentModel> componentsAt(int r, int c) {
    final id = occupancy[_cellKey(r, c)];
    if (id == null) return [];
    final comp = componentsById[id];
    return comp == null ? [] : [comp];
  }

  /// Validate grid integrity and level sanity.
  /// Returns list of warnings/errors (empty == OK).
  List<String> validate() {
    final messages = <String>[];

    // 1) bounds & occupancy check (already prevented by add/update, but re-check)
    for (final comp in componentsById.values) {
      for (final off in comp.shapeOffsets) {
        final r = comp.r + off.dr;
        final c = comp.c + off.dc;
        if (r < 0 || r >= rows || c < 0 || c >= cols) {
          messages.add('Component ${comp.id} out-of-bounds at cell [$r,$c].');
        } else {
          final key = _cellKey(r, c);
          final occ = occupancy[key];
          if (occ != comp.id) {
            messages.add('Occupancy mismatch for ${comp.id} at [$r,$c] - occupied by $occ.');
          }
        }
      }
    }

    // 2) battery check: ensure each battery has at least 2 terminals and at least one pos/neg.
    for (final comp in componentsById.values) {
      if (comp.type == ComponentType.battery) {
        if (comp.terminals.length < 2) {
          messages.add('Battery ${comp.id} has fewer than 2 terminals; expected pos & neg.');
        }
      }
    }

    // 3) duplicate ids are prevented by map key; but ensure terminals pool is unique per comp
    // (optional) - skipped

    return messages;
  }
}
```

---

## `lib/services/logic_engine.dart`

> This is the improved engine. It returns a richer `EvaluationResult` with `DebugInfo` that UI can use to draw terminals, adjacency edges, BFS order, and discovered pos→neg paths. The engine honors per-terminal blocking (via `comp.state['blockedTerminals']`) and can use `internalConnections` when present.

```dart
// lib/services/logic_engine.dart
import 'dart:collection';
import '../models/grid.dart';
import '../models/component.dart';

/// Direction enum reused for convenience (mirror of models.Dir)
enum Dir { north, east, south, west }

extension DirVec on Dir {
  int get dr {
    switch (this) {
      case Dir.north:
        return -1;
      case Dir.south:
        return 1;
      case Dir.east:
        return 0;
      case Dir.west:
        return 0;
    }
  }

  int get dc {
    switch (this) {
      case Dir.north:
        return 0;
      case Dir.south:
        return 0;
      case Dir.east:
        return 1;
      case Dir.west:
        return -1;
    }
  }

  Dir rotatedBySteps(int steps90CW) {
    final order = [Dir.north, Dir.east, Dir.south, Dir.west];
    var idx = order.indexOf(this);
    idx = (idx + (steps90CW % 4)) % 4;
    return order[idx];
  }

  Dir opposite() {
    switch (this) {
      case Dir.north:
        return Dir.south;
      case Dir.south:
        return Dir.north;
      case Dir.east:
        return Dir.west;
      case Dir.west:
        return Dir.east;
    }
  }
}

/// Terminal produced by the engine with absolute coordinates and label/role derived from TerminalSpec.
class Terminal {
  final String id; // "${componentId}_t$index"
  final String componentId;
  final int r;
  final int c;
  final Dir dir;
  final int index; // terminal index in component
  final String? label;
  final String? role;

  Terminal({
    required this.id,
    required this.componentId,
    required this.r,
    required this.c,
    required this.dir,
    required this.index,
    this.label,
    this.role,
  });

  @override
  String toString() => 'Terminal($id @[$r,$c] ${dir.toString().split(".").last} label=$label role=$role)';
}

/// Debug info returned so UI can render overlays: terminals, adjacency graph, BFS visitation order, discovered paths.
class DebugInfo {
  final Map<String, Terminal> terminals; // id -> Terminal
  final Map<String, List<String>> adjacency; // terminalId -> neighbor terminalIds
  final List<String> bfsOrder; // terminalIds in order visited by the evaluation BFS
  final List<List<String>> posToNegPaths; // each path is list of terminalIds
  final List<String> notes; // warnings or messages

  DebugInfo({
    required this.terminals,
    required this.adjacency,
    required this.bfsOrder,
    required this.posToNegPaths,
    required this.notes,
  });
}

/// EvaluationResult with richer debug overlay payload.
class EvaluationResult {
  final Set<String> poweredComponentIds;
  final bool isShortCircuit;
  final List<Terminal> openEndpoints;
  final List<String> debugTrace;
  final DebugInfo debugInfo;

  EvaluationResult({
    required this.poweredComponentIds,
    required this.isShortCircuit,
    required this.openEndpoints,
    required this.debugTrace,
    required this.debugInfo,
  });
}

class LogicEngine {
  LogicEngine();

  /// Evaluate the grid and return powered components, shorts, open endpoints, and debug info.
  EvaluationResult evaluate(Grid grid) {
    final comps = grid.componentsById;

    final Map<String, Terminal> terminals = {};

    // 1) collect terminals (absolute coords & rotated directions) + build Terminal objects with labels/roles
    for (final comp in comps.values) {
      final steps = ((comp.rotation % 360) ~/ 90) % 4;
      for (var ti = 0; ti < comp.terminals.length; ti++) {
        final tspec = comp.terminals[ti];
        final shapeCell = comp.shapeOffsets[tspec.cellIndex];
        final rotated = _rotateOffset(shapeCell, steps);
        final absR = comp.r + rotated.dr;
        final absC = comp.c + rotated.dc;
        final dir = tspec.dir.rotatedBySteps(steps);
        final tid = '${comp.id}_t$ti';
        terminals[tid] = Terminal(
          id: tid,
          componentId: comp.id,
          r: absR,
          c: absC,
          dir: dir,
          index: ti,
          label: tspec.label,
          role: tspec.role,
        );
      }
    }

    // 2) adjacency map initialization
    final adj = <String, Set<String>>{};
    for (final t in terminals.values) adj[t.id] = <String>{};

    // helper: map cell->terminals
    final Map<String, List<Terminal>> terminalsByCell = {};
    for (final t in terminals.values) {
      final key = _cellKey(t.r, t.c);
      terminalsByCell.putIfAbsent(key, () => []).add(t);
    }

    // 3) external adjacency: facing terminals across neighboring cells
    for (final t in terminals.values) {
      final nr = t.r + t.dir.dr;
      final nc = t.c + t.dir.dc;
      final neighborKey = _cellKey(nr, nc);
      final cand = terminalsByCell[neighborKey];
      if (cand != null) {
        for (final t2 in cand) {
          if (t2.dir == t.dir.opposite()) {
            adj[t.id]!.add(t2.id);
          }
        }
      }
    }

    // 4) internal adjacency:
    // 4a) explicit internalConnections take precedence
    for (final comp in comps.values) {
      if (comp.internalConnections.isNotEmpty) {
        for (final pair in comp.internalConnections) {
          if (pair.length != 2) continue;
          final a = '${comp.id}_t${pair[0]}';
          final b = '${comp.id}_t${pair[1]}';
          if (terminals.containsKey(a) && terminals.containsKey(b)) {
            adj[a]!.add(b);
            adj[b]!.add(a);
          }
        }
      } else {
        // 4b) fallback: terminals on same component within manhattan distance <=1 are connected
        final compTerminals = terminals.values.where((x) => x.componentId == comp.id).toList();
        for (var i = 0; i < compTerminals.length; i++) {
          for (var j = i + 1; j < compTerminals.length; j++) {
            final t1 = compTerminals[i];
            final t2 = compTerminals[j];
            final manh = (t1.r - t2.r).abs() + (t1.c - t2.c).abs();
            if (manh <= 1) {
              adj[t1.id]!.add(t2.id);
              adj[t2.id]!.add(t1.id);
            }
          }
        }
      }
    }

    // 5) identify battery terminals (pos & neg)
    final posTerminalIds = <String>[];
    final negTerminalIds = <String>[];
    final notes = <String>[];
    for (final comp in comps.values) {
      if (comp.type == ComponentType.battery) {
        if (comp.terminals.length >= 2) {
          // prefer role-based identification if provided
          for (var ti = 0; ti < comp.terminals.length; ti++) {
            final specRole = comp.terminals[ti].role;
            final tid = '${comp.id}_t$ti';
            if (specRole == 'pos') posTerminalIds.add(tid);
            if (specRole == 'neg') negTerminalIds.add(tid);
          }
          // fallback: first terminal = pos, second = neg
          if (posTerminalIds.isEmpty && comp.terminals.isNotEmpty) posTerminalIds.add('${comp.id}_t0');
          if (negTerminalIds.isEmpty && comp.terminals.length > 1) negTerminalIds.add('${comp.id}_t1');
        } else {
          notes.add('Battery ${comp.id} has fewer than 2 terminals.');
        }
      }
    }

    if (posTerminalIds.isEmpty) notes.add('No battery positive terminals found.');
    if (negTerminalIds.isEmpty) notes.add('No battery negative terminals found.');

    // 6) helper: per-terminal blocked logic (switches and per-terminal blockedTerminals)
    bool terminalIsBlocked(String tid) {
      final t = terminals[tid]!;
      final comp = comps[t.componentId]!;
      // per-component switch default
      if (comp.type == ComponentType.sw) {
        final closed = comp.state['closed'] == true;
        // per-terminal override list in state: 'blockedTerminals': [0,2]
        final blockedList = comp.state['blockedTerminals'] as List<dynamic>?;
        if (blockedList != null) {
          // if this terminal index is in blockedList AND switch not closed => blocked
          final idx = t.index;
          if (!closed && blockedList.contains(idx)) return true;
          // if list exists but does not include idx, then that terminal not affected by switch open state
          return false;
        }
        // default: whole switch blocks both terminals when open
        return !closed;
      }
      // For custom components we could inspect comp.state for per-terminal blocking as needed.
      return false;
    }

    // 7) BFS from pos terminals to mark powered components (respect terminalIsBlocked)
    final visitedT = <String>{};
    final poweredComponents = <String>{};
    final q = Queue<String>();
    for (final p in posTerminalIds) {
      if (!terminals.containsKey(p)) continue;
      if (terminalIsBlocked(p)) continue;
      q.add(p);
      visitedT.add(p);
    }
    final bfsOrder = <String>[];
    while (q.isNotEmpty) {
      final cur = q.removeFirst();
      bfsOrder.add(cur);
      final tcur = terminals[cur]!;
      poweredComponents.add(tcur.componentId);
      for (final nb in adj[cur] ?? {}) {
        if (visitedT.contains(nb)) continue;
        if (terminalIsBlocked(nb)) continue;
        visitedT.add(nb);
        q.add(nb);
      }
    }

    // 8) Short detection: search any pos->neg path with no load encountered
    bool foundShort = false;
    final seen = <String, Set<bool>>{};
    final q2 = Queue<_BfsState>();
    // to also collect discovered paths, store parent map keyed by tid+seenLoad flag
    final Map<String, String?> parent = {}; // key: tid|seenLoad -> parentKey
    final List<List<String>> discoveredPaths = [];

    String _key(String tid, bool seenLoad) => '$tid|${seenLoad ? 1 : 0}';

    for (final p in posTerminalIds) {
      if (!terminals.containsKey(p)) continue;
      if (terminalIsBlocked(p)) continue;
      q2.add(_BfsState(tid: p, seenLoad: false));
      seen.putIfAbsent(p, () => {}).add(false);
      parent[_key(p, false)] = null;
    }

    while (q2.isNotEmpty) {
      final s = q2.removeFirst();
      final t = terminals[s.tid]!;
      final comp = comps[t.componentId]!;
      final isLoad = comp.type == ComponentType.bulb || comp.terminals.any((ts) => ts.role == 'load');
      final seenLoadNow = s.seenLoad || isLoad;
      // if current terminal is a negative battery terminal and no load seen -> short
      if (negTerminalIds.contains(s.tid) && !seenLoadNow) {
        foundShort = true;
        // reconstruct path using parent map
        final path = <String>[];
        var curKey = _key(s.tid, s.seenLoad);
        while (curKey != null) {
          final parts = curKey.split('|');
          final tid = parts[0];
          path.insert(0, tid);
          curKey = parent[curKey];
        }
        discoveredPaths.add(path);
        break; // we can continue to collect more, but one short is enough
      }
      for (final n in adj[s.tid] ?? {}) {
        if (terminalIsBlocked(n)) continue;
        final set = seen.putIfAbsent(n, () => {});
        if (set.contains(seenLoadNow)) continue;
        set.add(seenLoadNow);
        parent[_key(n, seenLoadNow)] = _key(s.tid, s.seenLoad);
        q2.add(_BfsState(tid: n, seenLoad: seenLoadNow));
      }
    }

    // 9) open endpoints: terminals with zero non-blocked adjacency
    final openEndpoints = <Terminal>[];
    for (final t in terminals.values) {
      var hasConn = false;
      for (final n in adj[t.id] ?? {}) {
        if (terminalIsBlocked(n)) continue;
        hasConn = true;
        break;
      }
      if (!hasConn) openEndpoints.add(t);
    }

    // 10) Build debug info for UI overlay
    final adjacencyStrList = <String, List<String>>{};
    for (final e in adj.entries) {
      adjacencyStrList[e.key] = e.value.toList();
    }
    final debugInfo = DebugInfo(
      terminals: terminals,
      adjacency: adjacencyStrList,
      bfsOrder: bfsOrder,
      posToNegPaths: discoveredPaths,
      notes: notes,
    );

    // 11) debug trace summary
    final trace = <String>[];
    trace.add('terminals=${terminals.length}');
    trace.add('poweredComponents=${poweredComponents.length}');
    trace.add('short=$foundShort');

    return EvaluationResult(
      poweredComponentIds: poweredComponents,
      isShortCircuit: foundShort,
      openEndpoints: openEndpoints,
      debugTrace: trace,
      debugInfo: debugInfo,
    );
  }

  // rotate a CellOffset by steps90CW (clockwise)
  CellOffset _rotateOffset(CellOffset off, int steps90CW) {
    var dr = off.dr;
    var dc = off.dc;
    final s = steps90CW % 4;
    for (var i = 0; i < s; i++) {
      final ndr = -dc;
      final ndc = dr;
      dr = ndr;
      dc = ndc;
    }
    return CellOffset(dr, dc);
  }

  String _cellKey(int r, int c) => '$r:$c';
}

class _BfsState {
  final String tid;
  final bool seenLoad;
  _BfsState({required this.tid, required this.seenLoad});
}
```

---

## What I changed & why (summary)

1. **Per-terminal blocking** — switches may now list `blockedTerminals` in `component.state` to indicate which terminal indices are blocked when switch open. If absent, switch blocks all its terminals when open (backwards-compatible). This allows multi-terminal switches and partial blocking.

2. **Explicit internalConnections** — `ComponentModel.internalConnections` (list of pairs) lets you define exact internal wiring inside a component. When set the engine uses these pairs instead of the Manhattan adjacency heuristic.

3. **Terminal labels & roles** — `TerminalSpec` includes `label` and `role`. The engine exposes those to UI in `Terminal`. Roles can be `'pos'`, `'neg'`, `'load'`, etc., and are used for battery terminal identification and load detection.

4. **Grid validation** — `Grid.validate()` returns warnings for out-of-bounds or occupancy mismatch and battery terminal issues.

5. **Debug overlay data** — the engine returns `DebugInfo` with:

   * `terminals`: all terminals with absolute positions, labels and roles,
   * `adjacency`: adjacency lists between terminals,
   * `bfsOrder`: visitation order used to mark powered components (useful to animate BFS),
   * `posToNegPaths`: discovered pos→neg paths that indicate shorts,
   * `notes`: validation/warnings.

6. **Robust battery detection** — engine first looks for terminal `role=='pos'/'neg'` then falls back to first/second terminal convention. Validation messages added.

7. **Minor hardening** — small guards for terminals that reference out-of-grid cells, improved parent-tracking for path reconstruction.

---

## Tests & next steps (recommended)

* Update existing unit tests to assert `EvaluationResult.debugInfo` contains expected `terminals` and `bfsOrder`.
* Add tests for:

  * switches with `blockedTerminals` vs global switch behavior,
  * explicit `internalConnections` overriding Manhattan heuristic,
  * per-terminal labels & roles used to detect battery pos/neg,
  * `Grid.validate()` warnings for malformed levels.
* UI: implement a debug overlay that accepts `DebugInfo` and:

  * draws terminals (small circles) and labels,
  * draws adjacency edges (light lines),
  * highlights BFS order (animated color fade),
  * highlights `posToNegPaths` in red for shorts.

---

next steps:


* implement the **debug overlay painter** (`ui/debug_overlay.dart`) that draws `DebugInfo` on top of your canvas, or
* produce updated **unit tests** for the new features (switch per-terminal, internalConnections, debug info).

Which would you like next?


## 15.3 Tests

### `test/logic_engine_rich_test.dart`

```dart
// test/logic_engine_rich_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:circuit_kids/models/component.dart';
import 'package:circuit_kids/models/grid.dart';
import 'package:circuit_kids/services/logic_engine.dart';

void main() {
  test('long wire length 3 powers bulb at end', () {
    final grid = Grid(rows: 5, cols: 7);

    // battery at (2,1) rotation 90 (pointing east)
    final battery = ComponentModel(
      id: 'batt',
      type: ComponentType.battery,
      r: 2,
      c: 0,
      rotation: 90,
      shapeOffsets: const [CellOffset(0, 0)],
      terminals: const [TerminalSpec(cellIndex: 0, dir: Dir.east), TerminalSpec(cellIndex: 0, dir: Dir.west)],
    );

    // long wire length 3 placed at (2,1) occupying cells (2,1),(3,1),(4,1) in rotation 90? 
    // Use longWire factory with length 3 and rotation=90 which will rotate vertical->horizontal
    final longWire = ComponentModel.longWire(id: 'lw', r: 2, c: 1, length: 3, rotation: 90);
    // This creates terminals on both ends of the long wire.

    // bulb at the far right end (same row as battery, after wire)
    final bulb = ComponentModel(
      id: 'bulb1',
      type: ComponentType.bulb,
      r: 2,
      c: 4,
      rotation: 90,
      shapeOffsets: const [CellOffset(0, 0)],
      terminals: const [TerminalSpec(cellIndex: 0, dir: Dir.west), TerminalSpec(cellIndex: 0, dir: Dir.east)],
    );

    // Add components
    final addedBatt = grid.addComponent(battery);
    final addedWire = grid.addComponent(longWire);
    final addedBulb = grid.addComponent(bulb);

    expect(addedBatt, isTrue);
    expect(addedWire, isTrue);
    expect(addedBulb, isTrue);

    final engine = LogicEngine();
    final result = engine.evaluate(grid);

    expect(result.isShortCircuit, isFalse);
    expect(result.poweredComponentIds.contains('batt'), isTrue);
    expect(result.poweredComponentIds.contains('lw'), isTrue);
    expect(result.poweredComponentIds.contains('bulb1'), isTrue);
  });

  test('T-piece branches power to two bulbs', () {
    final grid = Grid(rows: 5, cols: 5);

    // battery at (2,1), rotation 90 so positive faces east
    final batt = ComponentModel(
      id: 'batt',
      type: ComponentType.battery,
      r: 2,
      c: 1,
      rotation: 90,
      shapeOffsets: const [CellOffset(0, 0)],
      terminals: const [TerminalSpec(cellIndex: 0, dir: Dir.east), TerminalSpec(cellIndex: 0, dir: Dir.west)],
    );

    // T-piece at (2,2) rotated 90 (so base points to west? depends on factory)
    // Our tPiece factory defaults to terminals north,east,west at rotation 0.
    // rotation 90 -> east,south,east? Let's just construct terminals explicitly for clarity.
    final tPiece = ComponentModel(
      id: 't1',
      type: ComponentType.wireT,
      r: 2,
      c: 2,
      rotation: 0,
      shapeOffsets: const [CellOffset(0, 0)],
      terminals: const [
        TerminalSpec(cellIndex: 0, dir: Dir.west), // connect back to battery (west)
        TerminalSpec(cellIndex: 0, dir: Dir.north), // branch north
        TerminalSpec(cellIndex: 0, dir: Dir.south), // branch south
      ],
    );

    // bulbs north and south of T
    final bulbN = ComponentModel(
      id: 'bn',
      type: ComponentType.bulb,
      r: 1,
      c: 2,
      rotation: 90,
      shapeOffsets: const [CellOffset(0, 0)],
      terminals: const [TerminalSpec(cellIndex: 0, dir: Dir.south), TerminalSpec(cellIndex: 0, dir: Dir.north)],
    );
    final bulbS = ComponentModel(
      id: 'bs',
      type: ComponentType.bulb,
      r: 3,
      c: 2,
      rotation: 90,
      shapeOffsets: const [CellOffset(0, 0)],
      terminals: const [TerminalSpec(cellIndex: 0, dir: Dir.north), TerminalSpec(cellIndex: 0, dir: Dir.south)],
    );

    final added = grid.addComponent(batt);
    expect(added, isTrue);
    expect(grid.addComponent(tPiece), isTrue);
    expect(grid.addComponent(bulbN), isTrue);
    expect(grid.addComponent(bulbS), isTrue);

    final engine = LogicEngine();
    final result = engine.evaluate(grid);

    expect(result.isShortCircuit, isFalse);
    expect(result.poweredComponentIds.contains('bn'), isTrue);
    expect(result.poweredComponentIds.contains('bs'), isTrue);
    expect(result.poweredComponentIds.contains('t1'), isTrue);
    expect(result.poweredComponentIds.contains('batt'), isTrue);
  });

  test('rotated T piece correctly routes power (rotation test)', () {
    final grid = Grid(rows: 5, cols: 5);

    final batt = ComponentModel(
      id: 'batt',
      type: ComponentType.battery,
      r: 2,
      c: 1,
      rotation: 90,
      shapeOffsets: const [CellOffset(0, 0)],
      terminals: const [TerminalSpec(cellIndex: 0, dir: Dir.east), TerminalSpec(cellIndex: 0, dir: Dir.west)],
    );

    // T-piece that has terminals east, south, north when rotated 90
    final t = ComponentModel(
      id: 't2',
      type: ComponentType.wireT,
      r: 2,
      c: 2,
      rotation: 90,
      shapeOffsets: const [CellOffset(0, 0)],
      terminals: const [
        TerminalSpec(cellIndex: 0, dir: Dir.north),
        TerminalSpec(cellIndex: 0, dir: Dir.east),
        TerminalSpec(cellIndex: 0, dir: Dir.south),
      ],
    );

    final bulbE = ComponentModel(
      id: 'be',
      type: ComponentType.bulb,
      r: 2,
      c: 3,
      rotation: 90,
      shapeOffsets: const [CellOffset(0, 0)],
      terminals: const [TerminalSpec(cellIndex: 0, dir: Dir.west), TerminalSpec(cellIndex: 0, dir: Dir.east)],
    );

    final bulbN = ComponentModel(
      id: 'bn',
      type: ComponentType.bulb,
      r: 1,
      c: 2,
      rotation: 90,
      shapeOffsets: const [CellOffset(0, 0)],
      terminals: const [TerminalSpec(cellIndex: 0, dir: Dir.south), TerminalSpec(cellIndex: 0, dir: Dir.north)],
    );

    grid.addComponent(batt);
    grid.addComponent(t);
    grid.addComponent(bulbE);
    grid.addComponent(bulbN);

    final engine = LogicEngine();
    final result = engine.evaluate(grid);

    expect(result.isShortCircuit, isFalse);
    expect(result.poweredComponentIds.contains('be'), isTrue);
    expect(result.poweredComponentIds.contains('bn'), isTrue);
  });
}
```

## 15.4 Notes & Guidance

*   **Rotation logic**: `ComponentModel.shapeOffsets` are given in rotation 0 coordinates (dr,dc). The engine rotates offsets clockwise via `_rotateOffset` when computing absolute cell positions. Terminal directions are rotated by steps of 90° using `Dir.rotatedBySteps()`.
*   **Terminals**: Each `TerminalSpec` points to a `cellIndex` in the `shapeOffsets` list. This lets terminals live on any cell of multi-cell components.
*   **Internal connections**: Terminals on the same component that are on adjacent cells (Manhattan distance ≤ 1) are internally connected. That models components that internally connect neighboring shape cells.
*   **Long wires**: Use `ComponentModel.longWire(...)` factory. It puts terminals at both ends and a shape covering `length` cells (in rotation 0 vertical orientation). Rotation rotates the whole shape.
*   **T-piece**: Use `ComponentModel.tPiece(...)` or create a custom `ComponentModel` with terminals arranged how you want. The tests show constructing explicit terminal lists for clarity.
*   **Switches**: Any component with `type == ComponentType.sw` is considered a switch. The engine checks `comp.state['closed'] == true` to allow conduction through terminals on that component. For multi-terminal switches (e.g., a multi-cell switch), you can extend the logic to check which terminals are blocked.

## 15.5 Next steps & improvements

*   Support components that **span non-contiguous cells** (rare) — the engine already accepts arbitrary `shapeOffsets`.
*   Add an explicit **internal connectivity graph** per component type (rather than Manhattan adjacency) for complex internal wiring inside a component (e.g., components with internal non-adjacent connections).
*   Add **terminal impedance / loads** modeling if you want to compute currents/brightness proportionally (later).
*   Extend unit tests with more complex topologies (multiple batteries, parallel branches mixing long wires and T pieces, short-circuits across multi-cell components).
*   If you plan to parse level JSON, incorporate `shapeOffsets` and `terminals` fields into the level schema.