import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../engine/game_engine.dart';
import '../routes.dart';
import '../services/level_manager.dart';
import '../ui/controllers/debug_overlay_controller.dart';
import '../ui/widgets/debug_overlay.dart';
import 'screens/win_screen.dart';
import 'widgets/pause_menu.dart';
import 'game_canvas.dart';
import '../common/asset_manager.dart';
import '../common/logger.dart';
import '../models/component.dart'; // For ComponentType
import '../ui/widgets/component_palette.dart'; // Import ComponentPalette

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late AnimationController _celebrationController;
  bool _showTutorial = false;
  ComponentModel? _selectedComponent; // Manage selected component for palette

  @override
  void initState() {
    super.initState();
    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    super.dispose();
  }

  void _showTutorialOverlay() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Welcome to Level 1!'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Use the battery and wires to light the bulb!'),
                SizedBox(height: 10),
                Text('• Drag the battery from the palette to the left side of the grid'),
                Text('• Drag wire segments to connect the battery to the bulb'),
                Text('• Tap placed components to rotate them'),
                Text('• The bulb will light up when the circuit is complete!'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Got it!'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _showTutorial = false;
                });
              },
            ),
          ],
        );
      },
    );
  }

  void _onComponentSelected(ComponentModel component) {
    setState(() {
      _selectedComponent = component;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LevelManager>(
      builder: (context, levelManager, child) {
        Logger.log('GameScreen: Consumer<LevelManager> builder called.');
        Logger.log(
            'GameScreen: levelManager.isLoading: ${levelManager.isLoading}');
        Logger.log(
            'GameScreen: levelManager.currentLevelDefinition: ${levelManager.currentLevelDefinition}');
        // Show a loading indicator while the manifest is being loaded.
        if (levelManager.isLoading ||
            levelManager.currentLevelDefinition == null) {
          Logger.log(
              'GameScreen: LevelManager is loading or has no level definition.');
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Provide the GameEngine, which is dependent on the LevelManager's data.
        return ChangeNotifierProvider(
          create: (ctx) {
            Logger.log(
                'GameScreen: Creating GameEngine for level ${levelManager.currentLevelDefinition!.id}');
            final assetManager = Provider.of<AssetManager>(ctx, listen: false);
            return GameEngine(
              levelDefinition: levelManager.currentLevelDefinition!,
              assetManager: assetManager,
              onWin: () {
                // When the level is won, notify the LevelManager.
                levelManager.completeCurrentLevel();
                _celebrationController.forward(from: 0.0); // Start celebration animation
              },
              onEvaluate: (evalResult) {
                Provider.of<DebugOverlayController>(ctx, listen: false)
                    .updateEvaluation(evalResult);
              },
            );
          },
          child: Consumer<GameEngine>(
            builder: (context, gameEngine, _) {
              // Show tutorial if needed
              if (_showTutorial && levelManager.currentLevelDefinition!.id == 'level_01') {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _showTutorialOverlay();
                });
              }

              // Filter available components based on what's allowed in the level
              final availableComponents = levelManager.currentLevelDefinition!.availableComponents.map((compDef) {
                // Create a dummy ComponentModel for display in the palette
                // This component won't be placed, just used for its type and initial state
                return ComponentModel(
                  id: 'palette_${compDef.type.toString()}',
                  type: compDef.type,
                  r: 0, c: 0, // Dummy position
                  rotation: 0,
                  state: compDef.state, // Use initial state from definition
                  shapeOffsets: compDef.shapeOffsets,
                  terminals: compDef.terminals,
                  isDraggable: true, // Palette items are draggable
                );
              }).toList();

              return Scaffold(
                appBar: AppBar(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Level ${levelManager.currentLevelDefinition!.levelNumber}: ${levelManager.currentLevelDefinition!.title}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        levelManager.currentLevelDefinition!.objective,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    IconButton(
                      onPressed: gameEngine.isPaused ? gameEngine.resume : gameEngine.pause,
                      icon: Icon(
                        gameEngine.isPaused ? Icons.play_arrow : Icons.pause,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    IconButton(
                      onPressed: gameEngine.reset,
                      icon: Icon(
                        Icons.refresh,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Consumer<DebugOverlayController>(
                      builder: (context, debugController, _) {
                        return IconButton(
                          icon: Icon(
                            Icons.bug_report,
                            color: debugController.isVisible ? Colors.cyanAccent : Theme.of(context).colorScheme.onSurface,
                          ),
                          onPressed: debugController.toggleVisibility,
                        );
                      },
                    ),
                  ],
                ),
                body: Column(
                  children: [
                    // Status bar
                    Consumer<GameEngine>(
                      builder: (context, gameEngine, _) {
                        Color statusBarColor = Theme.of(context).colorScheme.surfaceContainerHighest;
                        IconData statusIcon = Icons.info;
                        String statusText = levelManager.currentLevelDefinition!.description;
                        Color onStatusBarColor = Theme.of(context).colorScheme.onSurfaceVariant;

                        if (gameEngine.isShortCircuit) {
                          statusBarColor = Theme.of(context).colorScheme.errorContainer;
                          statusIcon = Icons.warning;
                          statusText = 'Short circuit detected! Check your connections.';
                          onStatusBarColor = Theme.of(context).colorScheme.onErrorContainer;
                        } else if (gameEngine.isWin) {
                          statusBarColor = Theme.of(context).colorScheme.tertiaryContainer;
                          statusIcon = Icons.celebration;
                          statusText = 'Level Complete! Well done! 🎉';
                          onStatusBarColor = Theme.of(context).colorScheme.onTertiaryContainer;
                        }

                        return Container(
                          padding: const EdgeInsets.all(16),
                          color: statusBarColor,
                          child: Row(
                            children: [
                              Icon(statusIcon, color: onStatusBarColor),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  statusText,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: onStatusBarColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    
                    // Main game area
                    Expanded(
                      child: Stack(
                        children: [
                          const GameCanvas(),
                          const DebugOverlay(),
                          if (gameEngine.isPaused) PauseMenu(onResume: gameEngine.resume),
                          if (gameEngine.isWin)
                            WinScreen(
                              levelId: levelManager.currentLevelId,
                              onNextLevel: () {
                                levelManager.goToNextLevel();
                              },
                              onLevelSelect: () {
                                Navigator.of(context).popUntil(ModalRoute.withName(AppRoutes.mainMenu));
                              },
                            ),
                          // Celebration overlay for win
                          if (gameEngine.isWin)
                            Positioned.fill(
                              child: IgnorePointer(
                                ignoring: true,
                                child: AnimatedBuilder(
                                  animation: _celebrationController,
                                  builder: (context, child) {
                                    return Opacity(
                                      opacity: _celebrationController.value,
                                      child: Center(
                                        child: Transform.scale(
                                          scale: 1.0 + (_celebrationController.value * 0.5),
                                          child: Icon(
                                            Icons.celebration,
                                            size: 200,
                                            color: Theme.of(context).colorScheme.tertiary.withOpacity(_celebrationController.value),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    
                    // Component palette
                    ComponentPalette(
                      availableComponents: availableComponents,
                      onComponentSelected: _onComponentSelected,
                      selectedComponent: _selectedComponent,
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}