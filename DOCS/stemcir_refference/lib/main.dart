import 'package:flutter/material.dart';
import 'package:stemcir/theme.dart';
import 'package:stemcir/screens/home_screen.dart';

void main() {
  runApp(const StemCircApp());
}

class StemCircApp extends StatelessWidget {
  const StemCircApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StemCir - Circuit Simulation Game',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}
