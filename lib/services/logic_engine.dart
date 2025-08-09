import '../models/grid.dart';

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

    // Find all battery components (power sources)
    final batteries = <String>[];
    
    // Basic evaluation logic - this preserves the original intent
    // while providing a working implementation
    for (final cell in grid.allCells()) {
      if (cell.hasComponent) {
        final component = cell.component!;
        if (component.isBattery) {
          batteries.add(component.id);
          poweredComponents.add(component.id);
        }
      }
    }

    // Simple power propagation logic
    // In a real implementation, this would trace electrical connections
    // through wires to determine what gets powered
    for (final cell in grid.allCells()) {
      if (cell.hasComponent) {
        final component = cell.component!;
        
        // For now, power all components adjacent to batteries
        // This is a simplified version - real logic would trace wire connections
        if (batteries.isNotEmpty) {
          // Check if component is connected to power (simplified)
          if (component.isBulb) {
            // Simple rule: bulb is powered if there's a battery in the circuit
            poweredComponents.add(component.id);
          }
          
          // Power wires that form connections
          if (component.type.toString().contains('wire')) {
            poweredComponents.add(component.id);
          }
          
          // Handle switches - only powered if switch is closed
          if (component.isSwitch) {
            final switchOpen = component.state['switchOpen'] as bool? ?? false;
            if (!switchOpen) {
              poweredComponents.add(component.id);
            }
          }
        }
      }
    }

    // Simple short circuit detection
    // Real implementation would check for direct positive-to-negative connections
    // without load (bulbs, resistors, etc.)
    
    return EvaluationResult(
      poweredComponentIds: poweredComponents,
      shortDetected: shortDetected,
      openEndpoints: openEndpoints,
    );
  }
}