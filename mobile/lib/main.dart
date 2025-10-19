import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'core/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final alreadyReset = prefs.getBool('firstRunResetPerformed') ?? false;
  if (!alreadyReset) {
    await prefs.clear();
    await prefs.setBool('firstRunResetPerformed', true);
  }
  runApp(const QuartinhoApp());
}

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
