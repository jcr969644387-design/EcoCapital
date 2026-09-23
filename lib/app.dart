import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'services/project_controller.dart';

/// Raíz de la aplicación EcoCapital.
class EcoCapitalApp extends StatefulWidget {
  const EcoCapitalApp({super.key});

  static const String appName = 'EcoCapital';

  @override
  State<EcoCapitalApp> createState() => _EcoCapitalAppState();
}

class _EcoCapitalAppState extends State<EcoCapitalApp> {
  final ProjectController _controller = ProjectController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: EcoCapitalApp.appName,
      debugShowCheckedModeBanner: false,
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      home: HomeScreen(controller: _controller),
    );
  }

  ThemeData _theme(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF14532D),
      brightness: brightness,
    );
    return ThemeData(colorScheme: scheme);
  }
}
