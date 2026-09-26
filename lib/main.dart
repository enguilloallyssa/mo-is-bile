import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screen/dashboard_screen.dart';
import 'screen/login_screen.dart';
import 'screen/register_screen.dart';

void main() {
  runApp(const SariApp());
}

class SariApp extends StatelessWidget {
  const SariApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SARI',
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(),
        scaffoldBackgroundColor: const Color(0xFFF7F4EE),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD48F08),
          brightness: Brightness.light,
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/dashboard': (context) => const DashboardScreen(),
      },
    );
  }
}