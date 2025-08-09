import 'package:flutter/material.dart';
import '../routes.dart';
import '../widgets/rounded_button.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Circuit Kids',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const SizedBox(height: 50),
            RoundedButton(
              text: 'Play',
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.levelSelect);
              },
            ),
            const SizedBox(height: 20),
            RoundedButton(
              text: 'Settings',
              onPressed: () {
                // Navigate to settings screen
              },
            ),
          ],
        ),
      ),
    );
  }
}
