import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/providers.dart';
import '../routes.dart';
import '../ui/controllers/debug_overlay_controller.dart';
import '../ui/widgets/debug_overlay.dart';
import 'widgets/pause_menu.dart';
import 'game_canvas.dart';
import '../models/component.dart';
import '../ui/widgets/component_palette.dart';
import '../common/theme.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> with TickerProviderStateMixin {
  ComponentModel? _selectedComponent; // Added to manage selected component

  @override
  Widget build(BuildContext context) {
    final levelManager = ref.watch(levelManagerProvider);
    final gameEngineNotifier = ref.watch(gameEngineProvider.notifier);
    final gameEngineState = ref.watch(gameEngineProvider);
    final debugController = ref.watch(debugOverlayControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Listen for win state to trigger celebration
    ref.listen<bool>(gameEngineProvider.select((state) => state.isWin), (prev, next) {
      if (next) {
        // You can trigger animations or dialogs here, e.g., WinScreen
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: isDark ? DarkModeColors.darkSurface : LightModeColors.lightSurface,
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: GameCanvas(
                    key: ValueKey(levelManager.currentLevel.id),
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: ComponentPalette(
                    availableComponents: levelManager.currentLevel.components,
                    onComponentSelected: (component) {
                      setState(() {
                        _selectedComponent = component;
                      });
                    },
                    selectedComponent: _selectedComponent,
                  ),
                ),
              ],
            ),
          ),
          if (debugController.isVisible)
            const Positioned(
              top: 16,
              right: 16,
              child: DebugOverlay(),
            ),
          if (gameEngineState.isPaused)
            PauseMenu(
              onResume: () {
                gameEngineNotifier.setPaused(false);
              },
              onRestart: () {
                gameEngineNotifier.resetLevel(); // Use gameEngineNotifier's resetLevel
              },
              onExit: () {
                Navigator.pushReplacementNamed(context, AppRoutes.levelSelect);
              },
            ),
        ],
      ),
    );
  }
}
