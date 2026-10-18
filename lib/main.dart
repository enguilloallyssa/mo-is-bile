// ignore_for_file: duplicate_import

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';

import 'buyer/buyer_shell.dart';
import 'logistics/logistics_shell.dart';
import 'rider/rider_shell.dart';
import 'screen/login_screen.dart';
import 'screen/register_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
        '/buyer': (context) => const BuyerShell(),
        '/rider': (context) => const RiderShell(),
        '/logistics': (context) => const LogisticsShell(),
      },
    );
  }
}
