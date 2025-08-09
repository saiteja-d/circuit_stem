import 'package:flutter/material.dart';
import 'screens/main_menu.dart';
import 'screens/level_select.dart';
import 'screens/game_screen.dart';

class AppRoutes {
  static const String mainMenu = '/';
  static const String levelSelect = '/levels';
  static const String gameScreen = '/game';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case mainMenu:
        return MaterialPageRoute(builder: (_) => const MainMenuScreen());
      case levelSelect:
        return MaterialPageRoute(builder: (_) => const LevelSelectScreen());
      case gameScreen:
        final levelId = settings.arguments as String;
        return MaterialPageRoute(builder: (_) => GameScreen(levelId: levelId));
      default:
        return MaterialPageRoute(builder: (_) => Scaffold( // Removed const
          appBar: AppBar(title: const Text('Error')),
          body: const Center(child: Text('Error: Unknown route')),
        ));
    }
  }
}

