import 'package:freezed_annotation/freezed_annotation.dart';
import 'component.dart';

part 'grid.freezed.dart';

@freezed
class Grid with _$Grid {
  const Grid._(); // Private constructor for getters and methods

  const factory Grid({
    required int rows,
    required int cols,
    @Default({}) Map<String, ComponentModel> componentsById,
  }) = _Grid;

  // Computed property for occupancy map. This is derived from the components.
  Map<String, String> get occupancy {
    final map = <String, String>{};
    for (final comp in componentsById.values) {
      for (final off in comp.shapeOffsets) {
        final r = comp.r + off.dr;
        final c = comp.c + off.dc;
        map['$r:$c'] = comp.id;
      }
    }
    return map;
  }

  ComponentModel? getComponentById(String id) => componentsById[id];

  List<ComponentModel> componentsAt(int r, int c) {
    final id = occupancy['$r:$c'];
    if (id == null) return [];
    final comp = componentsById[id];
    return comp == null ? [] : [comp];
  }

  /// Validates the grid state, returning a list of error messages.
  List<String> validate() {
    final messages = <String>[];
    for (final comp in componentsById.values) {
      for (final off in comp.shapeOffsets) {
        final r = comp.r + off.dr;
        final c = comp.c + off.dc;
        if (r < 0 || r >= rows || c < 0 || c >= cols) {
          messages.add('Component ${comp.id} out-of-bounds at cell [$r,$c].');
        } else {
          final key = '$r:$c';
          final occ = occupancy[key];
          if (occ != comp.id) {
            messages.add('Occupancy mismatch for ${comp.id} at [$r,$c] - occupied by $occ.');
          }
        }
      }
      if (comp.type == ComponentType.battery) {
        if (comp.terminals.length < 2) {
          messages.add('Battery ${comp.id} has fewer than 2 terminals; expected pos & neg.');
        }
      }
    }
    return messages;
  }
}