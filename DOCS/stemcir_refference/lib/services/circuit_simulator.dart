import 'package:stemcir/models/circuit_component.dart';

class CircuitSimulator {
  static SimulationResult simulate(List<CircuitComponent> components) {
    // Reset all power states
    final updatedComponents = components.map((c) => c.copyWith(isPowered: false)).toList();
    
    // Find all batteries (power sources)
    final batteries = updatedComponents.where((c) => c.type == ComponentType.battery).toList();
    
    if (batteries.isEmpty) {
      return SimulationResult(
        components: updatedComponents,
        hasShortCircuit: false,
        poweredComponents: [],
      );
    }
    
    // For each battery, trace power flow
    final Set<String> poweredComponentIds = {};
    bool hasShortCircuit = false;
    
    for (final battery in batteries) {
      final visited = <String>{};
      final powerTrace = _tracePowerFlow(
        battery,
        updatedComponents,
        visited,
      );
      
      poweredComponentIds.addAll(powerTrace.poweredIds);
      if (powerTrace.hasShortCircuit) {
        hasShortCircuit = true;
      }
    }
    
    // Update power states
    for (int i = 0; i < updatedComponents.length; i++) {
      if (poweredComponentIds.contains(updatedComponents[i].id)) {
        updatedComponents[i] = updatedComponents[i].copyWith(isPowered: true);
      }
    }
    
    return SimulationResult(
      components: updatedComponents,
      hasShortCircuit: hasShortCircuit,
      poweredComponents: updatedComponents.where((c) => c.isPowered).toList(),
    );
  }
  
  static PowerTrace _tracePowerFlow(
    CircuitComponent source,
    List<CircuitComponent> components,
    Set<String> visited,
  ) {
    if (visited.contains(source.id)) {
      return PowerTrace(poweredIds: {}, hasShortCircuit: true);
    }
    
    visited.add(source.id);
    final Set<String> poweredIds = {source.id};
    bool hasShortCircuit = false;
    
    // Find connected components
    final connectedComponents = _findConnectedComponents(source, components);
    
    for (final connected in connectedComponents) {
      // Check if component allows power flow
      if (_canPowerFlowThrough(connected)) {
        final trace = _tracePowerFlow(connected, components, visited);
        poweredIds.addAll(trace.poweredIds);
        if (trace.hasShortCircuit) {
          hasShortCircuit = true;
        }
      }
    }
    
    visited.remove(source.id);
    
    return PowerTrace(
      poweredIds: poweredIds,
      hasShortCircuit: hasShortCircuit,
    );
  }
  
  static List<CircuitComponent> _findConnectedComponents(
    CircuitComponent component,
    List<CircuitComponent> allComponents,
  ) {
    final connected = <CircuitComponent>[];
    
    // Check adjacent grid positions for connections
    final adjacentPositions = [
      (component.x - 1, component.y), // Left
      (component.x + 1, component.y), // Right
      (component.x, component.y - 1), // Up
      (component.x, component.y + 1), // Down
    ];
    
    for (final pos in adjacentPositions) {
      final adjacentComponent = allComponents.where(
        (c) => c.x == pos.$1 && c.y == pos.$2
      ).firstOrNull;
      
      if (adjacentComponent != null && _areComponentsConnected(component, adjacentComponent)) {
        connected.add(adjacentComponent);
      }
    }
    
    return connected;
  }
  
  static bool _areComponentsConnected(CircuitComponent comp1, CircuitComponent comp2) {
    // Check if components can connect based on their types and orientations
    // For simplicity, assume components connect if they're adjacent
    // In a real implementation, you'd check connection points and orientations
    return true;
  }
  
  static bool _canPowerFlowThrough(CircuitComponent component) {
    switch (component.type) {
      case ComponentType.wire:
      case ComponentType.wireCorner:
      case ComponentType.wireTJunction:
      case ComponentType.wireCross:
        return true;
      case ComponentType.bulb:
        return true;
      case ComponentType.resistor:
        return true;
      case ComponentType.circuitSwitch:
        return component.isSwitchClosed;
      case ComponentType.battery:
        return false; // Don't flow through batteries to prevent loops
    }
  }
}

class SimulationResult {
  final List<CircuitComponent> components;
  final bool hasShortCircuit;
  final List<CircuitComponent> poweredComponents;
  
  const SimulationResult({
    required this.components,
    required this.hasShortCircuit,
    required this.poweredComponents,
  });
}

class PowerTrace {
  final Set<String> poweredIds;
  final bool hasShortCircuit;
  
  const PowerTrace({
    required this.poweredIds,
    required this.hasShortCircuit,
  });
}

extension<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    if (iterator.moveNext()) {
      return iterator.current;
    }
    return null;
  }
}