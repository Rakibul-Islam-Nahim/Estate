import 'package:flutter/material.dart';
import 'package:real_state/pages/Login.dart';
import 'package:real_state/pages/SignUp.dart';

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
              // transitionDuration: const Duration(milliseconds: 600),
              pageBuilder: (_, __, ___) => const signup(),
              // transitionsBuilder: (_, animation, __, child) {
              //   // Example: Slide + Fade
              //   final slide = Tween(begin: const Offset(1, 0), end: Offset.zero)
              //       .animate(
              //         CurvedAnimation(
              //           parent: animation,
              //           curve: Curves.easeInOut,
              //         ),
              //       );
              //   final fade = Tween(begin: 0.0, end: 1.0).animate(
              //     CurvedAnimation(parent: animation, curve: Curves.easeInOut),
              //   );
              //
              //   return SlideTransition(
              //     position: slide,
              //     child: FadeTransition(opacity: fade, child: child),
              //   );
              // },
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
