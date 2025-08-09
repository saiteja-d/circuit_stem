import 'package:flutter/material.dart';

class WinScreen extends StatelessWidget {
  final String levelId;
  final VoidCallback onNextLevel;
  final VoidCallback onLevelSelect;

  const WinScreen({Key? key, required this.levelId, required this.onNextLevel, required this.onLevelSelect}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54, // Semi-transparent background
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(32.0),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Level $levelId Completed!',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: onNextLevel,
                  child: const Text('Next Level'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: onLevelSelect,
                  child: const Text('Level Select'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
