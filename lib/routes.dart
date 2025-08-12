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
        return MaterialPageRoute(
          builder: (_) => const LevelSelectScreen(),
        );

      case gameScreen:
        return MaterialPageRoute(builder: (_) => const GameScreen());

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