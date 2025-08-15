Plan for review and robust testing of Level 01

Overview
- Objective: Review Level 01 testing implementation, align with DOCS/TESTING.md and DOCS/Architecture.md, identify gaps, and architect a robust testing build for level gameplay. Create concrete, executable steps that can be implemented incrementally.

Goals
- Align tests with published testing docs
- Improve reliability and coverage of Level 01 tests
- Establish a clear testing plan for CI integration
- Provide visual diagrams of testing workflow to aid understanding

High-level Architecture of Testing (Mermaid)
```mermaid
graph TD
  A[User Interactions (UI)] --> B[GameEngineNotifier (Riverpod)]
  B --> C[LogicEngine (Pure Dart)]
  C --> D[EvaluationResult]
  D --> E[Grid & Components State]
  E --> F[UI Canvas & Widgets]
  F --> G[Test Helpers / Test Harness]
  subgraph Test Loop
    H[Widget Test] --> I[Simulated Gestures]
    I --> J[Provider Overrides]
    J --> K[State Assertion]
  end
```

What we will change (targeted, surgical edits)
- Improve test helpers to better simulate grid gestures
- Ensure LevelSelect navigation is robust in tests
- Add explicit tests for toggling switches, grid snapping, and invalid moves
- Integrate with DOCS/TESTING.md bypassing non-deterministic cues
- Add or refine mocks/overrides for Riverpod providers to stabilize tests

Planned Tasks mapped to TODO items
- T1: Review current level01 testing implementation and related helpers
- T2: Read and align with DOCS/TESTING.md and DOCS/Architecture.md
- T3: Identify failing or flaky test scenarios and map to root causes
- T4: Propose robust testing strategy for level01 and overall level game testing
- T5: Design improvement plan for test harness, including level_01_test_helpers.dart and interaction tests
- T6: Create initial testing build plan and high-level architecture diagram (Mermaid)
- T7: Implement scaffolding changes to enable robust testing build
- T8: Validate changes by running test suite locally
- T9: Create plan.md documenting testing plan, Mermaid diagram, and CI steps
- T10: Add initial Mermaid diagram illustrating Level 1 testing workflow and data flow

Risks and assumptions
- Tests rely on a deterministic UI state; where randomness exists, we will mock or seed inputs
- Level 01 is ultimately driven by Riverpod state; tests will override providers to isolate logic
- The CustomPainter grid interactions will be simulated by precise pixel coordinates derived from grid mapping

Acceptance criteria
- plan.md exists with a clear, actionable plan and Mermaid diagram
- Updated test scaffolding improves stability of Level 01 tests
- Documentation reflects the current testing strategy and next steps
- CI can be wired to run Level 01 tests reliably

Next actions
- Implement the plan.md content into the repository
- Create/adjust tests in test/ui/ to exercise the listed TC-L1 test cases with coordinate-based gestures
- Add or adjust Mermaid diagrams in plan.md to reflect Level 01 testing workflow

Notes
- I will proceed to create plan.md as described above and then update the TODO list accordingly after confirmation.
## 3. TC-L1-01a Plan: Level 1 Toggle Switch double-tap interaction

- Objective: verify that tapping the toggle switch twice returns to the original state, ensuring idempotent behavior across rapid user interactions.

- Patch overview:
  - Update test/ui/level_01_interaction_test.dart to add a new test TC-L1-01a that:
    - Locates switch1 via Level1TestHelper.findComponentById.
    - Reads the initial switchOpen state.
    - Taps the switch once using Level1TestHelper.tapComponent at the switch's grid position.
    - Waits for the circuit/state to settle (Level1TestHelper.waitForCircuitUpdate).
    - Taps the switch a second time at the same position.
    - Waits for state stabilization again.
    - Asserts that the final switchOpen state equals the initial state.

  - Add a minimal companion helper or helper usage in test/ui/level_01_test_helpers.dart if needed to ensure waitForCircuitUpdate is invoked between taps and to expose a stable grid position for the switch.

- Validation:
  - Run flutter test test/ui/level_01_interaction_test.dart to verify TC-L1-01a passes in isolation.
  - Ensure test does not introduce flakiness by picking deterministic delays via waitForCircuitUpdate.

- Scope: This is a focused, surgical step to validate double-tap behavior. If successful, extend the same pattern to additional TC-L1 test cases as planned.

- Dependencies and notes:
  - Assumes TC-L1-01 (single tap toggle) remains in place and functional.
  - If the component state is stored in a non-serializable map, ensure proper casting for the boolean value retrieval.

- Next actions after applying:
  - Run the test suite for Level 1 interaction tests and iterate on any failures.
  - Document results in plan.md and update the TODO state accordingly.
## 3. TC-L1-01a Plan: Level 1 Toggle Switch double-tap interaction

- Objective: verify that tapping the toggle switch twice returns to the original state, ensuring idempotent behavior across rapid user interactions.

- Patch overview:
  - Update test/ui/level_01_interaction_test.dart to add a new test TC-L1-01a that:
    - Locates switch1 via Level1TestHelper.findComponentById.
    - Reads the initial switchOpen state.
    - Taps the switch once using Level1TestHelper.tapComponent at the switch's grid position.
    - Waits for the circuit/state to settle (Level1TestHelper.waitForCircuitUpdate).
    - Taps the switch a second time at the same position.
    - Waits for state stabilization again.
    - Asserts that the final switchOpen state equals the initial state.

  - Add a minimal companion helper or helper usage in test/ui/level_01_test_helpers.dart if needed to ensure waitForCircuitUpdate is invoked between taps and to expose a stable grid position for the switch.

- Validation:
  - Run flutter test test/ui/level_01_interaction_test.dart to verify TC-L1-01a passes in isolation.
  - Ensure test does not introduce flakiness by picking deterministic delays via waitForCircuitUpdate.

- Scope: This is a focused, surgical step to validate double-tap behavior. If successful, extend the same pattern to additional TC-L1 test cases as planned.

- Dependencies and notes:
  - Assumes TC-L1-01 (single tap toggle) remains in place and functional.
  - If the component state is stored in a non-serializable map, ensure proper casting for the boolean value retrieval.

- Next actions after applying:
  - Run the test suite for Level 1 interaction tests and iterate on any failures.
  - Document results in plan.md and update the TODO state accordingly.