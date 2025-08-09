import 'package:flutter/material.dart';
import '../routes.dart';
import '../widgets/level_card.dart';

class LevelSelectScreen extends StatelessWidget {
  const LevelSelectScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select a Level'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: 10,
          itemBuilder: (context, index) {
            return LevelCard(
              levelNumber: index + 1,
              isLocked: index > 0,
              onTap: () {
                Navigator.of(context).pushNamed(AppRoutes.gameScreen, arguments: 'level_${index + 1}');
              },
            );
          },
        ),
      ),
    );
  }
}