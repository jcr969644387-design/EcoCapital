import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'services/app_feedback.dart';
import 'services/project_controller.dart';
import 'theme/app_theme.dart';

/// Raíz de la aplicación EcoCapital.
class EcoCapitalApp extends StatefulWidget {
  const EcoCapitalApp({super.key});

  static const String appName = 'EcoCapital';
  static const String version = '1.0.3';

  @override
  State<EcoCapitalApp> createState() => _EcoCapitalAppState();
}

class _EcoCapitalAppState extends State<EcoCapitalApp> {
  final ProjectController _controller = ProjectController();

  @override
  void initState() {
    super.initState();
    AppFeedback.instance.load();
  }

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
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: HomeScreen(controller: _controller),
    );
  }
}
