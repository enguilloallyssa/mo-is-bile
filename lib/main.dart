import 'package:flutter/material.dart';

import 'buyer/buyer_shell.dart';
import 'logistics/logistics_shell.dart';
import 'rider/rider_shell.dart';
import 'screen/login_screen.dart';
import 'screen/register_screen.dart';
import 'screen/splash_screen.dart';
import 'screen/welcome_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const SariApp());
}

class SariApp extends StatelessWidget {
  const SariApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sari',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD4A62A),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F5F1),
        fontFamilyFallback: const <String>[
          'Roboto',
          'Arial',
          'sans-serif',
        ],
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
        ),
      ),
      initialRoute: '/splash',
      routes: <String, WidgetBuilder>{
        '/splash': (BuildContext context) =>
            const SplashScreen(),

        '/welcome': (BuildContext context) =>
            const WelcomeScreen(),

        '/login': (BuildContext context) =>
            const LoginScreen(),

        '/register': (BuildContext context) =>
            const RegisterScreen(),

        '/buyer': (BuildContext context) =>
            const BuyerShell(),

        '/rider': (BuildContext context) =>
            const RiderShell(),

        '/logistics': (BuildContext context) =>
            const LogisticsShell(),
      },
      onUnknownRoute: (RouteSettings settings) {
        return MaterialPageRoute<void>(
          builder: (BuildContext context) =>
              const WelcomeScreen(),
        );
      },
    );
  }
}