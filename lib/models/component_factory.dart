
// lib/models/component_factory.dart
import 'component.dart';

/// A factory for creating ComponentModel instances from JSON data.
///
/// This centralizes the logic for component instantiation, making it easier
/// to add new component types in the future without modifying the core game engine.
class ComponentFactory {
  /// Creates a [ComponentModel] from a JSON map.
  ///
  /// It inspects the 'type' field in the JSON to determine which constructor
  /// or subclass to use. For now, it delegates directly to [ComponentModel.fromJson].
  static ComponentModel create(Map<String, dynamic> json) {
    // In the future, this could have a switch statement on json['type']
    // to call different constructors or even instantiate different subclasses
    // of ComponentModel.
    return ComponentModel.fromJson(json);
  }
}
