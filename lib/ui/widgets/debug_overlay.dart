// lib/ui/widgets/debug_overlay.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/debug_overlay_controller.dart';

/// A widget that displays debug information about the circuit evaluation.
///
/// It listens to a [DebugOverlayController] to know when to be visible and
/// what data to display.
class DebugOverlay extends StatelessWidget {
  const DebugOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<DebugOverlayController>(
      builder: (context, controller, child) {
        if (!controller.isVisible || controller.lastEvaluation == null) {
          return const SizedBox.shrink();
        }

        final eval = controller.lastEvaluation!;
        final debugInfo = eval.debugInfo;
        final textContent = [
          'Powered Components: ${eval.poweredComponentIds.join(", ")}',
          'Short Circuit: ${eval.isShortCircuit}',
          if (eval.isShortCircuit) 'Short Path: ${debugInfo.posToNegPaths.isNotEmpty ? debugInfo.posToNegPaths.first.join(" -> ") : "N/A"}',
          'Powered Terminals (BFS Order): ${debugInfo.bfsOrder.join(", ")}',
          if (debugInfo.notes.isNotEmpty) 'Notes: ${debugInfo.notes.join("; ")}',
        ].join('\n');

        return Positioned(
          bottom: 10,
          left: 10,
          right: 10,
          child: IgnorePointer(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                textContent,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'monospace',
                  fontSize: 10,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
