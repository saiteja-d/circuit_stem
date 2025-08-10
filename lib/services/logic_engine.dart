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
    for (final t in terminals.values) {
      adj[t.id] = <String>{};
    }

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

    // Renamed _key to key (no underscore)
    String key(String tid, bool seenLoad) => '$tid|${seenLoad ? 1 : 0}';

    for (final p in posTerminalIds) {
      if (!terminals.containsKey(p)) continue;
      if (terminalIsBlocked(p)) continue;
      q2.add(_BfsState(tid: p, seenLoad: false));
      seen.putIfAbsent(p, () => {}).add(false);
      parent[key(p, false)] = null;
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
        // reconstruct path using parent map with nullable curKey
        final path = <String>[];
        String? curKey = key(s.tid, s.seenLoad);
        while (curKey != null) {
          final parts = curKey.split('|');
          final tid = parts[0];
          path.insert(0, tid);
          curKey = parent[curKey];
        }
        // Add discovered short path
        parent[key(s.tid, s.seenLoad)]; // to satisfy unused var warning if any
        path.isNotEmpty ? path : null;
        q2.clear();
        return EvaluationResult(
          poweredComponentIds: poweredComponents,
          isShortCircuit: true,
          openEndpoints: [], // can collect more open endpoints if needed
          debugTrace: ['Short circuit detected'],
          debugInfo: DebugInfo(
            terminals: terminals,
            adjacency: adj.map((k, v) => MapEntry(k, v.toList())),
            bfsOrder: bfsOrder,
            posToNegPaths: [path],
            notes: notes,
          ),
        );
      }
      for (final n in adj[s.tid] ?? {}) {
        if (terminalIsBlocked(n)) continue;
        final set = seen.putIfAbsent(n, () => {});
        if (set.contains(seenLoadNow)) continue;
        set.add(seenLoadNow);
        parent[key(n, seenLoadNow)] = key(s.tid, s.seenLoad);
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
      posToNegPaths: [],
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
