import 'package:circuit_stem/common/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:circuit_stem/routes.dart';
import 'package:circuit_stem/ui/widgets/level_card.dart';
import 'package:circuit_stem/common/theme.dart';
import 'package:circuit_stem/core/providers.dart';

class LevelSelectScreen extends ConsumerStatefulWidget {
  const LevelSelectScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends ConsumerState<LevelSelectScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    Logger.log('LevelSelectScreen: initState');
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();
    // Initialize the level manager when the screen is first created.
    // We use a post-frame callback to ensure that the provider is available.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(levelManagerProvider.notifier).init();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _navigateToLevel(int index) {
    ref.read(levelManagerProvider.notifier).loadLevelByIndex(index);
    Navigator.of(context).pushNamed(AppRoutes.gameScreen);
  }

  @override
  Widget build(BuildContext context) {
    final levelManagerState = ref.watch(levelManagerProvider);
    final levels = levelManagerState.levels;
    final completedLevelIds = levelManagerState.completedLevelIds;

    if (levelManagerState.errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Text(
            levelManagerState.errorMessage!,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (levelManagerState.isLoading && levels.isEmpty) {
        return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
        );
    }

    final completedLevelsCount = completedLevelIds.length;
    final totalLevels = levels.length;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Circuit Kids',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppGradients.levelSelectBackgroundGradient,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Icon(
                        Icons.electrical_services,
                        size: 64,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Select a Level',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.emoji_events,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Progress: $completedLevelsCount/$totalLevels Levels',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value:
                        totalLevels > 0 ? completedLevelsCount / totalLevels : 0.0,
                    backgroundColor:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.0,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final level = levels[index];
                  final isUnlocked = level.unlocked;
                  final isCompleted = completedLevelIds.contains(level.id);

                  return FadeTransition(
                    opacity: _fadeController,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: Offset(0, 0.5 + (index * 0.1)),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: _fadeController,
                        curve: Interval(
                          index * 0.1,
                          (index * 0.1) + 0.6,
                          curve: Curves.easeOutCubic,
                        ),
                      )),
                      child: LevelCard(
                        level: level,
                        isUnlocked: isUnlocked,
                        isCompleted: isCompleted,
                        onTap:
                            isUnlocked ? () => _navigateToLevel(index) : null,
                      ),
                    ),
                  );
                },
                childCount: levels.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 32),
          ),
        ],
      ),
    );
  }
}