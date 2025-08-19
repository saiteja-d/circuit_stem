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
| wire_t              | N, E, W                     |
| switch              | N, S (acts like straight)   |
| crossWire           | N, E, S, W                  |
| buzzer              | W, E                        |

### Rotation rules
- Rotating 90° clockwise moves N→E, E→S, S→W, W→N. Rotation steps are integer multiples of 90.

## Short detection (algorithm)
The detection algorithm is integrated directly into the main `evaluate` function for efficiency, avoiding multiple graph traversals. It uses a Breadth-First Search (BFS) that originates from the battery's positive terminals.

1. **Build Adjacency Graph `G`**: A single graph of all component terminals is constructed.
2. **Initialize BFS**: The search queue is initialized with the battery's positive terminals. Each state in the queue tracks two pieces of information: the current `terminalId` and a boolean flag `seenLoad`.
3. **Traverse Graph**: The BFS explores the graph. When it traverses from one terminal to another, it checks the component type.
    - If the component is a "load" (e.g., a bulb), the `seenLoad` flag for that path is set to `true`.
    - The `seenLoad` flag is carried forward along each path in the search.
4. **Detect Short**: A short circuit is detected if the BFS reaches a negative battery terminal and the `seenLoad` flag for that specific path is still `false`.

**Rationale**: This approach is more efficient than building a pruned graph. It allows the engine to check for shorts and calculate power flow in a single pass, and it enables the reconstruction of the exact short-circuit path for debugging purposes.

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
