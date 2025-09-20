import 'package:flutter/material.dart';
import 'package:mobile/pages/home/home_page.dart';
import 'package:mobile/pages/login/login_home_page.dart';
import 'package:mobile/pages/register/register_location.dart';

class AppRoutes {
  static const String home = '/';
  static const String loginHome = '/loginHome';
  static const String registerLocation = '/registerLocation';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case loginHome:
        return MaterialPageRoute(builder: (_) => const LoginHomePage());
      case registerLocation:
        return MaterialPageRoute(builder: (_) => RegisterLocation());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Rota não encontrada: \'${settings.name}\'')),
          ),
        );
    }
  }
}
