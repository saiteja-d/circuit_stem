import 'package:flutter/material.dart';
import 'routes.dart';
import 'common/theme.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Circuit Kids',
      theme: AppTheme.light,
      initialRoute: AppRoutes.mainMenu,
      onGenerateRoute: AppRoutes.onGenerateRoute, // Fixed method name
      debugShowCheckedModeBanner: false,
    );
  }
}