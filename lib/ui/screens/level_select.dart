import 'package:flutter/material.dart';
import '../routes.dart';

class LevelSelectScreen extends StatelessWidget {
  final int unlockedLevels;

  const LevelSelectScreen({Key? key, this.unlockedLevels = 1}) : super(key: key);

  void _onLevelTap(BuildContext context, int index, bool isLocked) {
    if (isLocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Level ${index + 1} is locked.')),
      );
      return;
    }
    Navigator.of(context).pushNamed(
      AppRoutes.gameScreen,
      arguments: 'level_${index + 1}',
    );
  }

  @override
  Widget build(BuildContext context) {
    const totalLevels = 10;
    const crossAxisCount = 4;

    return Scaffold(
      appBar: AppBar(title: const Text('Select a Level')),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: totalLevels,
          itemBuilder: (context, index) {
            final isLocked = index >= unlockedLevels;
            return Card(
              color: isLocked ? Colors.grey.shade300 : null,
              child: InkWell(
                onTap: () => _onLevelTap(context, index, isLocked),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${index + 1}',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: isLocked ? Colors.grey : null,
                        ),
                      ),
                      if (isLocked)
                        const Icon(Icons.lock, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
