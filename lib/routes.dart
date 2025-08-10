import 'package:flutter/material.dart';
import 'package:circuit_stem/ui/screens/main_menu.dart';
import 'package:circuit_stem/ui/screens/level_select.dart';
import 'package:circuit_stem/ui/game_screen.dart'; // Corrected import path

class AppRoutes {
  static const String mainMenu = '/';
  static const String levelSelect = '/levels';
  static const String gameScreen = '/game';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case mainMenu:
        return MaterialPageRoute(builder: (_) => const MainMenuScreen());

      case levelSelect:
        final args = settings.arguments;
        int unlockedLevels = 1;
        if (args is int) {
          unlockedLevels = args;
        }
        return MaterialPageRoute(
          builder: (_) => LevelSelectScreen(unlockedLevels: unlockedLevels),
        );

      case gameScreen:
        final levelId = settings.arguments;
        if (levelId is String) {
          return MaterialPageRoute(builder: (_) => GameScreen(levelId: levelId));
        }
        return MaterialPageRoute(builder: (_) => _errorPage('Missing or invalid levelId'));

      default:
        return MaterialPageRoute(builder: (_) => _errorPage('Unknown route: ${settings.name}'));
    }
  }

  static Widget _errorPage(String message) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(child: Text(message)),
    );
  }
}
