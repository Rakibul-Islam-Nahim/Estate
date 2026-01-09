import 'package:flutter/material.dart';
import 'package:real_state/pages/Login.dart';
import 'package:real_state/pages/SignUp.dart';
import 'package:real_state/pages/HomePage.dart';
import 'package:real_state/pages/AdminLogin.dart';
import 'package:real_state/pages/AdminDashboard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return PageRouteBuilder(
              pageBuilder: (_, __, ___) => const DarkSignInPage(),
              transitionsBuilder: (_, animation, __, child) =>
                  FadeTransition(opacity: animation, child: child),
            );

          case '/signup':
            return PageRouteBuilder(
              pageBuilder: (_, __, ___) => const signup(),
              transitionsBuilder: (_, animation, __, child) =>
                  FadeTransition(opacity: animation, child: child),
            );

          case '/home':
            final userName = settings.arguments as String? ?? 'User';
            return PageRouteBuilder(
              pageBuilder: (_, __, ___) => HomePage(userName: userName),
              transitionsBuilder: (_, animation, __, child) =>
                  FadeTransition(opacity: animation, child: child),
            );

          case '/admin/login':
            return PageRouteBuilder(
              pageBuilder: (_, __, ___) => const AdminLoginPage(),
              transitionsBuilder: (_, animation, __, child) =>
                  FadeTransition(opacity: animation, child: child),
            );

          case '/admin/dashboard':
            return PageRouteBuilder(
              pageBuilder: (_, __, ___) => const AdminDashboard(),
              transitionsBuilder: (_, animation, __, child) =>
                  FadeTransition(opacity: animation, child: child),
            );

          default:
            return null;
        }
      },
    );
  }
}
