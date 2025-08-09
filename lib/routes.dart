import 'package:flutter/material.dart';
import 'screens/main_menu.dart';
import 'screens/level_select.dart';
import 'screens/game_screen.dart';

class AppRoutes {
  static const String mainMenu = '/';
  static const String levelSelect = '/levels';
  static const String gameScreen = '/game'; // Fixed name

  static Route<dynamic> onGenerateRoute(RouteSettings settings) { // Fixed method name
    switch (settings.name) {
      case mainMenu:
        return MaterialPageRoute(builder: (_) => const MainMenuScreen());
      case levelSelect:
        return MaterialPageRoute(builder: (_) => const LevelSelectScreen());
      case gameScreen:
        final levelId = settings.arguments as String;
        return MaterialPageRoute(builder: (_) => GameScreen(levelId: levelId));
      default:
        return MaterialPageRoute(builder: (_) => const Scaffold(
          appBar: AppBar(title: Text('Error')),
          body: Center(child: Text('Error: Unknown route')),
        ));
    }
  }
}

