// lib/main.dart
import 'package:flutter/material.dart';
import 'presentation/routes/app_routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateRoute: AppRoutes.generateRoute,
      initialRoute: AppRoutes.home,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1A1A1D), // fondo dark elegante
        primaryColor: const Color(0xFF0CECDD),            // verde turquesa PSI
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF0CECDD),
          secondary: Color(0xFFFFB800),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121212), // AppBar oscuro bonito
          elevation: 2,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
