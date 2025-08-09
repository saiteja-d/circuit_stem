import 'package:flutter/material.dart';
import 'circuit_game.dart'; // Import CircuitGame

class UiOverlay extends StatelessWidget {
  final CircuitGame game; // Add a reference to the game instance

  const UiOverlay({Key? key, required this.game}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () {
                // Navigate back to level select
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.arrow_back),
            ),
            const Spacer(),
            IconButton(
              onPressed: () {}, // TODO: Implement settings
              icon: const Icon(Icons.settings),
            ),
          ],
        ),
        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                final hint = game.provideHint();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(hint)),
                );
              },
              child: const Text('Hint'),
            ),
            const SizedBox(width: 20),
            ElevatedButton(onPressed: () {
              game.resetLevel();
            }, child: const Text('Reset')),
          ],
        )
      ],
    );
  }
}


