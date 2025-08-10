import 'package:flutter/material.dart';
import '../routes.dart';

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
            return Card(
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pushNamed(
                    AppRoutes.gameScreen, 
                    arguments: 'level_${index + 1}'
                  );
                },
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${index + 1}',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      if (index > 0) 
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