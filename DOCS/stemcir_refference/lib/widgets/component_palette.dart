import 'package:flutter/material.dart';
import 'package:stemcir/models/circuit_component.dart';
import 'package:stemcir/widgets/circuit_component_widget.dart';

class ComponentPalette extends StatelessWidget {
  final List<CircuitComponent> availableComponents;
  final Function(CircuitComponent component) onComponentSelected;
  final CircuitComponent? selectedComponent;
  
  const ComponentPalette({
    super.key,
    required this.availableComponents,
    required this.onComponentSelected,
    this.selectedComponent,
  });

  @override
  Widget build(BuildContext context) {
    final componentCounts = <ComponentType, int>{};
    for (final component in availableComponents) {
      componentCounts[component.type] = (componentCounts[component.type] ?? 0) + 1;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🧩 Component Palette',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (availableComponents.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'All components have been placed! 🎉',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
            )
          else
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: componentCounts.entries.map((entry) {
                final componentType = entry.key;
                final count = entry.value;
                final component = availableComponents.firstWhere(
                  (c) => c.type == componentType,
                );
                
                return ComponentPaletteItem(
                  component: component,
                  count: count,
                  isSelected: selectedComponent?.type == componentType,
                  onTap: () => onComponentSelected(component),
                  onComponentSelected: onComponentSelected,
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

class ComponentPaletteItem extends StatelessWidget {
  final CircuitComponent component;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;
  final Function(CircuitComponent component) onComponentSelected;
  
  const ComponentPaletteItem({
    super.key,
    required this.component,
    required this.count,
    required this.isSelected,
    required this.onTap,
    required this.onComponentSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Draggable<CircuitComponent>(
      data: component,
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: CircuitComponentWidget(
            component: component,
            size: 40,
            isPreview: true,
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: _buildComponentItem(context),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: _buildComponentItem(context),
      ),
    );
  }
  
  Widget _buildComponentItem(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSelected 
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: isSelected 
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircuitComponentWidget(
            component: component,
            size: 32,
            isPreview: true,
          ),
          const SizedBox(height: 4),
          Text(
            _getComponentName(component.type),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected 
                  ? Theme.of(context).colorScheme.onPrimaryContainer
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ),
          if (count > 1)
            Container(
              margin: const EdgeInsets.only(top: 2),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'x$count',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSecondary,
                  fontSize: 10,
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  String _getComponentName(ComponentType type) {
    switch (type) {
      case ComponentType.wire:
        return 'Wire';
      case ComponentType.wireCorner:
        return 'Corner';
      case ComponentType.wireTJunction:
        return 'T-Junction';
      case ComponentType.wireCross:
        return 'Cross';
      case ComponentType.battery:
        return 'Battery';
      case ComponentType.bulb:
        return 'Bulb';
      case ComponentType.circuitSwitch:
        return 'Switch';
      case ComponentType.resistor:
        return 'Resistor';
    }
  }
}