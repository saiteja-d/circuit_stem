import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../screens/game_screen.dart';

class LevelGrid extends ConsumerWidget {
  const LevelGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final levelManager = ref.watch(levelManagerProvider);
    final levels = levelManager.levels;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Select Level',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: levels.length,
            itemBuilder: (context, index) {
              final level = levels[index];
              return _LevelCard(
                level: level,
                onTap: level.unlocked ? () => _startLevel(context, level.id) : null,
              );
            },
          ),
        ),
      ],
    );
  }

  void _startLevel(BuildContext context, String levelId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameScreen(levelId: levelId),
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final LevelMetadata level;
  final VoidCallback? onTap;

  const _LevelCard({
    required this.level,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLocked = !level.unlocked;

    return Card(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isLocked ? Icons.lock : Icons.lightbulb_outline,
                size: 32,
                color: isLocked ? Colors.grey : Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 8),
              Text(
                'Level ${level.id}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isLocked ? Colors.grey : null,
                ),
              ),
              if (!isLocked) ...[
                const SizedBox(height: 4),
                Text(
                  level.title,
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
