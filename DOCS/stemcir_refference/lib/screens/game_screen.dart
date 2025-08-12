import 'package:flutter/material.dart';
import 'package:stemcir/models/circuit_component.dart';
import 'package:stemcir/models/game_level.dart';
import 'package:stemcir/models/game_state.dart';
import 'package:stemcir/services/circuit_simulator.dart';
import 'package:stemcir/widgets/circuit_grid.dart';
import 'package:stemcir/widgets/component_palette.dart';

class GameScreen extends StatefulWidget {
  final GameLevel level;
  final Function(bool isComplete) onLevelComplete;
  
  const GameScreen({
    super.key,
    required this.level,
    required this.onLevelComplete,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late GameState _gameState;
  CircuitComponent? _selectedComponent;
  late AnimationController _pulseController;
  late AnimationController _celebrationController;
  bool _showTutorial = false;
  
  @override
  void initState() {
    super.initState();
    _gameState = GameState(
      level: widget.level,
      placedComponents: [...widget.level.initialComponents],
      startTime: DateTime.now(),
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);
    
    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // Show tutorial for Level 1
    if (widget.level.levelNumber == 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _showTutorial = true;
        });
      });
    }
    
    _runSimulation();
  }
  
  @override
  void dispose() {
    _pulseController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }
  
  void _runSimulation() {
    final result = CircuitSimulator.simulate(_gameState.placedComponents);
    
    setState(() {
      _gameState = _gameState.copyWith(
        placedComponents: result.components,
        hasShortCircuit: result.hasShortCircuit,
      );
    });
    
    _checkLevelCompletion();
  }
  
  void _checkLevelCompletion() {
    final targetsPowered = widget.level.targetComponentIds.every((id) {
      final component = _gameState.placedComponents.where((c) => c.id == id).firstOrNull;
      return component?.isPowered ?? false;
    });
    
    if (targetsPowered && !_gameState.isLevelComplete) {
      setState(() {
        _gameState = _gameState.copyWith(isLevelComplete: true);
      });
      
      _celebrationController.forward();
      
      // Delay before calling completion callback
      Future.delayed(const Duration(milliseconds: 2000), () {
        widget.onLevelComplete(true);
      });
    }
  }
  
  void _onComponentSelected(CircuitComponent component) {
    setState(() {
      _selectedComponent = component;
    });
  }
  
  void _onComponentPlaced(CircuitComponent component, int x, int y) {
    if (_selectedComponent == null) return;
    
    // Check Level 1 specific placement restrictions
    if (widget.level.levelNumber == 1 && component.type == ComponentType.battery) {
      // Battery can only be placed on the left side of the grid (x <= 2)
      if (x > 2) {
        // Show feedback that battery must be placed on left side
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Place the battery on the left side of the grid'),
            duration: Duration(seconds: 2),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }
    }
    
    // Create new component at the specified position
    final newComponent = component.copyWith(x: x, y: y);
    
    // Remove one instance from available components
    final availableComponents = [...widget.level.availableComponents];
    final index = availableComponents.indexWhere((c) => c.type == component.type);
    if (index != -1) {
      availableComponents.removeAt(index);
    }
    
    setState(() {
      _gameState = _gameState.copyWith(
        placedComponents: [..._gameState.placedComponents, newComponent],
      );
      _selectedComponent = availableComponents.any((c) => c.type == component.type) 
          ? component 
          : null;
    });
    
    _runSimulation();
  }
  
  void _onComponentTapped(CircuitComponent component) {
    if (component.type == ComponentType.circuitSwitch) {
      // Toggle switch state
      final updatedComponents = _gameState.placedComponents.map((c) {
        if (c.id == component.id) {
          return c.copyWith(isSwitchClosed: !c.isSwitchClosed);
        }
        return c;
      }).toList();
      
      setState(() {
        _gameState = _gameState.copyWith(placedComponents: updatedComponents);
      });
      
      _runSimulation();
    } else {
      // Rotate component
      final newDirection = Direction.values[
        (component.direction.index + 1) % Direction.values.length
      ];
      
      final updatedComponents = _gameState.placedComponents.map((c) {
        if (c.id == component.id) {
          return c.copyWith(direction: newDirection);
        }
        return c;
      }).toList();
      
      setState(() {
        _gameState = _gameState.copyWith(placedComponents: updatedComponents);
      });
      
      _runSimulation();
    }
  }
  
  void _resetLevel() {
    setState(() {
      _gameState = GameState(
        level: widget.level,
        placedComponents: [...widget.level.initialComponents],
        startTime: DateTime.now(),
      );
      _selectedComponent = null;
    });
    
    _runSimulation();
  }
  
  void _pauseGame() {
    setState(() {
      _gameState = _gameState.copyWith(isPaused: !_gameState.isPaused);
    });
  }

  @override
  Widget build(BuildContext context) {
    final availableComponents = widget.level.availableComponents
        .where((available) {
          final placedCount = _gameState.placedComponents
              .where((placed) => placed.type == available.type)
              .length;
          final initialCount = widget.level.initialComponents
              .where((initial) => initial.type == available.type)
              .length;
          final totalAvailable = widget.level.availableComponents
              .where((c) => c.type == available.type)
              .length;
          return placedCount - initialCount < totalAvailable;
        }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Level ${widget.level.levelNumber}: ${widget.level.title}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              widget.level.objective,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _pauseGame,
            icon: Icon(
              _gameState.isPaused ? Icons.play_arrow : Icons.pause,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          IconButton(
            onPressed: _resetLevel,
            icon: Icon(
              Icons.refresh,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Status bar
              Container(
                padding: const EdgeInsets.all(16),
                color: _gameState.hasShortCircuit 
                    ? Theme.of(context).colorScheme.errorContainer
                    : _gameState.isLevelComplete 
                        ? Theme.of(context).colorScheme.tertiaryContainer
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Row(
                  children: [
                    Icon(
                      _gameState.hasShortCircuit 
                          ? Icons.warning 
                          : _gameState.isLevelComplete 
                              ? Icons.celebration 
                              : Icons.info,
                      color: _gameState.hasShortCircuit 
                          ? Theme.of(context).colorScheme.onErrorContainer
                          : _gameState.isLevelComplete 
                              ? Theme.of(context).colorScheme.onTertiaryContainer
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _gameState.hasShortCircuit 
                            ? 'Short circuit detected! Check your connections.'
                            : _gameState.isLevelComplete 
                                ? 'Level Complete! Well done! 🎉'
                                : widget.level.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: _gameState.hasShortCircuit 
                              ? Theme.of(context).colorScheme.onErrorContainer
                              : _gameState.isLevelComplete 
                                  ? Theme.of(context).colorScheme.onTertiaryContainer
                                  : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Main game area
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _gameState.isLevelComplete ? _celebrationController : _pulseController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _gameState.isLevelComplete 
                              ? 1.0 + (_celebrationController.value * 0.1)
                              : 1.0,
                          child: CircuitGrid(
                            level: widget.level,
                            components: _gameState.placedComponents,
                            onComponentPlaced: _onComponentPlaced,
                            onComponentTapped: _onComponentTapped,
                            selectedComponent: _selectedComponent,
                          ),
                        );
                      },
                    ),
                  ),
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
          
          // Pause overlay
          if (_gameState.isPaused)
            Container(
              color: Colors.black.withValues(alpha: 0.7),
              child: Center(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.pause_circle_filled,
                          size: 64,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Game Paused',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap pause button to continue',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          
          // Level 1 Tutorial overlay
          if (_showTutorial && widget.level.levelNumber == 1)
            Container(
              color: Colors.black.withValues(alpha: 0.8),
              child: Center(
                child: Card(
                  margin: const EdgeInsets.all(32),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          size: 64,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Welcome to Level 1!',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Use the battery and wires to light the bulb!',
                          style: Theme.of(context).textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '• Drag the battery from the palette to the left side of the grid\n'
                          '• Drag wire segments to connect the battery to the bulb\n'
                          '• Tap placed components to rotate them\n'
                          '• The bulb will light up when the circuit is complete!',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _showTutorial = false;
                            });
                          },
                          child: const Text('Got it!'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
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