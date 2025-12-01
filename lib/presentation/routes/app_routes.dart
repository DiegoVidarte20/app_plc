import 'package:flutter/material.dart';
import '../views/home_screen.dart';


class AppRoutes {
  static const home = '/home';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {

      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      default:
        // fallback: siempre ir a home
        return MaterialPageRoute(builder: (_) => const HomeScreen());
    }
  }
}
