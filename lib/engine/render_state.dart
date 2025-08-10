
import 'package:flutter/material.dart';
import '../models/grid.dart';
import '../models/component.dart' as model;

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

class RenderState {
  final Grid grid;
  final List<model.Component> components;
  final EvaluationResult evaluationResult;
  final String? draggedComponentId;
  final Offset? dragPosition;
  final double bulbIntensity;
  final double wireOffset;

  RenderState({
    required this.grid,
    required this.components,
    required this.evaluationResult,
    this.draggedComponentId,
    this.dragPosition,
    required this.bulbIntensity,
    required this.wireOffset,
  });
}
