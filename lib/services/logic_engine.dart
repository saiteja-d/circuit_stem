import '../models/grid.dart';
import '../models/component.dart';

/// Result of circuit evaluation.
class EvaluationResult {
  final Set<String> poweredComponentIds;
  final bool shortDetected;
  final List<String> openEndpoints;

  const EvaluationResult({
    required this.poweredComponentIds,
    required this.shortDetected,
    required this.openEndpoints,
  });
}

/// Handles the logic for evaluating circuit connections and power flow.
class LogicEngine {
  /// Evaluates the circuit grid and returns the evaluation result.
  EvaluationResult evaluateGrid(Grid grid) {
    final poweredComponents = <String>{};
    bool shortDetected = false;
    final openEndpoints = <String>[];

    // Basic evaluation logic - this would need to be expanded
    // For now, just return a basic result
    for (final cell in grid.allCells()) {
      if (cell.hasComponent) {
        final component = cell.component!;
        if (component.isBattery) {
          poweredComponents.add(component.id);
        }
        // Add more logic here for circuit evaluation
      }
    }

    return EvaluationResult(
      poweredComponentIds: poweredComponents,
      shortDetected: shortDetected,
      openEndpoints: openEndpoints,
    );
  }
}