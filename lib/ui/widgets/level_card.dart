import 'package:flutter/material.dart';

class LevelCard extends StatelessWidget {
  final int levelNumber;
  final bool isLocked;
  final VoidCallback onTap;

  const LevelCard({Key? key, required this.levelNumber, required this.isLocked, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: isLocked ? null : onTap,
        child: Stack(
          children: [
            Center(
              child: Text('Level $levelNumber'),
            ),
            if (isLocked)
              const Center(
                child: Icon(Icons.lock, size: 50, color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }
}
