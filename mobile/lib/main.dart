import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'core/app_routes.dart';

void main() => runApp(const QuartinhoApp());

class QuartinhoApp extends StatelessWidget {
  const QuartinhoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quartinho',
      theme: buildAppTheme(),
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.home,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
