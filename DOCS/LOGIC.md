# Logic Reference — Circuit Kids

This document describes the core pure-Dart logic used by the game engine. Keep the logic engine independent from Flame rendering.

## Public API (high-level)
- `EvaluationResult evaluateGrid(Grid grid)`  
  Runs evaluation and returns:
  - `poweredComponentIds` Set<String>
  - `shortDetected` bool
  - `openEndpoints` List<Cell>
  - `debugMessages` List<String>

- `Map<String, List<String>> buildGraph(Grid grid)`  
  Build adjacency map of terminals.

- `bool detectShort(Map<String,List<String>> graph, Grid grid)`  
  Returns true if positive and negative battery terminals connect without passing a load (bulb).

## Terminal mapping overview
- Each component occupies a cell and exposes terminal directions (N/E/S/W)
- Node ID format: `"{r}_{c}_{dirIndex}"` where `dirIndex` = 0..3 for (N,E,S,W)

### Base orientations (rotation = 0)
| Component Type      | Base Terminals (rotation=0) |
|---------------------|-----------------------------|
| battery             | W (neg), E (pos)            |
| bulb                | W, E                        |
| wire_straight       | N, S                        |
| wire_corner         | N, E                        |
| wire_t               | N, E, W                     |
| switch              | N, S (acts like straight)   |

### Rotation rules
- Rotating 90° clockwise moves N→E, E→S, S→W, W→N. Rotation steps are integer multiples of 90.

## Short detection (algorithm)
1. Build adjacency graph `G` of terminals (all terminal nodes & edges).
2. Identify `posNodes` (battery positive terminals) and `negNodes` (battery negative).
3. Build `G_pruned` = `G` with all terminals belonging to loads (bulbs/resistors) removed.
4. If any `posNode` can reach any `negNode` in `G_pruned`, a short exists.

Rationale: removing loads emulates a path that bypasses resistance; if pos→neg still connects, current will short.

## Evaluation steps (simplified)
1. `graph = buildGraph(grid)`
2. `pos = findBatteryPositiveNodes(grid)`
3. `visited = bfs(graph, pos)`
4. `powered = components at visited nodes`
5. `short = detectShort(graph, grid)`
6. `openEndpoints = findOpenEndpoints(grid, graph)`
7. return `EvaluationResult(powered, short, openEndpoints, debugMessages)`

## Example scenarios
### Series (Correct)
- Battery @ (1,0) rotation 0 (pos E)
- Wire @ (1,1) orientation east-west
- Bulb  @ (1,2) orientation W-E
- Expected: bulb powered, short=false, openEndpoints=[]

### Parallel
- Battery @ (0,1)
- Two branches from battery positive to two bulbs in different columns.
- Expected: both bulbs powered independently if both branches complete.

### Short
- Battery with a direct conductive path from positive to negative without bulb in path.
- Expected: shortDetected=true, powered may include wire components but UI blocks success.

## Debug messages priority
1. Short (highest)
2. Switch open (if blocking)
3. Open endpoint (missing wire)
4. No battery found

## Integration notes
- `evaluateGrid()` must be synchronous for small grids (6×6). For larger grids, evaluate in background.
- UI must update visuals within 150ms of a user action. Run `evaluateGrid()` immediately after model mutation and start a visual change (even a single-frame change) without waiting for long animations.

## Terminal mapping table (explicit)
- For devs: copy the mapping rules into unit tests verifying each (component type, rotation) → expected Dir list.
