// lib/models/grid.dart
// Grid model supporting occupancy mapping, safe add/update/remove and validation.

import 'component.dart';

/// Grid holds components and a simple occupancy map to detect overlaps.
class Grid {
  final int rows;
  final int cols;

  bool get isEmpty => componentsById.isEmpty;
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
