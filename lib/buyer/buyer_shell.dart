import 'package:flutter/material.dart';

import 'buyer_account.dart';
import 'buyer_cart.dart';
import 'buyer_home.dart';
import 'buyer_messages.dart';
import 'buyer_notifications.dart';
import 'buyer_orders.dart';
import 'buyer_products.dart';
import 'widgets/buyer_bottom_nav.dart';

class BuyerShell extends StatefulWidget {
  const BuyerShell({super.key});

  @override
  State<BuyerShell> createState() => _BuyerShellState();
}

class _BuyerShellState extends State<BuyerShell> {
  static const Color _brand = Color(0xFFD98D08);
  static const Color _surface = Color(0xFFFFFDF9);
  static const Color _background = Color(0xFFF7F5F1);
  static const Color _border = Color(0xFFE8DFD2);
  static const Color _text = Color(0xFF211D17);

  // Internal pages:
  // 0 Home, 1 Shop, 2 Cart, 3 Orders, 4 Account, 5 Notifications, 6 Messages.
  int _currentPage = 0;

  // Bottom navigation: Home, Shop, Orders, Updates, Me.
  int _currentNavIndex = 0;

  void _handlePageAction(int index) {
    // Legacy top-right profile callbacks now open Messages.
    final targetPage = index == 4 ? 6 : index;
    if (targetPage < 0 || targetPage > 6) return;

    setState(() {
      _currentPage = targetPage;
      switch (targetPage) {
        case 0:
          _currentNavIndex = 0;
          break;
        case 1:
          _currentNavIndex = 1;
          break;
        case 3:
          _currentNavIndex = 2;
          break;
        case 5:
          _currentNavIndex = 3;
          break;
        case 4:
          _currentNavIndex = 4;
          break;
        case 2:
        case 6:
          break;
      }
    });
  }

  void _onBottomNavTap(int navIndex) {
    const pageForNavIndex = <int>[0, 1, 3, 5, 4];
    if (navIndex < 0 || navIndex >= pageForNavIndex.length) return;

    setState(() {
      _currentNavIndex = navIndex;
      _currentPage = pageForNavIndex[navIndex];
    });
  }

  TextTheme _buyerTextTheme(TextTheme theme) {
    TextStyle? polish(TextStyle? style) {
      return style?.copyWith(
        color: _text,
        fontFamilyFallback: const <String>[
          'Roboto',
          'Noto Sans',
          'Arial',
          'sans-serif',
        ],
      );
    }

    return theme.copyWith(
      displayLarge: polish(theme.displayLarge),
      displayMedium: polish(theme.displayMedium),
      displaySmall: polish(theme.displaySmall),
      headlineLarge: polish(theme.headlineLarge),
      headlineMedium: polish(theme.headlineMedium),
      headlineSmall: polish(theme.headlineSmall),
      titleLarge: polish(theme.titleLarge),
      titleMedium: polish(theme.titleMedium),
      titleSmall: polish(theme.titleSmall),
      bodyLarge: polish(theme.bodyLarge),
      bodyMedium: polish(theme.bodyMedium),
      bodySmall: polish(theme.bodySmall),
      labelLarge: polish(theme.labelLarge),
      labelMedium: polish(theme.labelMedium),
      labelSmall: polish(theme.labelSmall),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      BuyerHome(onTabChanged: _handlePageAction),
      BuyerProducts(onTabChanged: _handlePageAction),
      BuyerCart(onTabChanged: _handlePageAction),
      BuyerOrders(onTabChanged: _handlePageAction),
      BuyerAccount(onTabChanged: _handlePageAction),
      const BuyerNotifications(),
      BuyerMessages(onTabChanged: _handlePageAction),
    ];

    final baseTheme = Theme.of(context);
    final textTheme = _buyerTextTheme(baseTheme.textTheme);

    return Theme(
      data: baseTheme.copyWith(
        useMaterial3: true,
        scaffoldBackgroundColor: _background,
        colorScheme: baseTheme.colorScheme.copyWith(
          primary: _brand,
          secondary: const Color(0xFF3C6E91),
          surface: _surface,
          onSurface: _text,
        ),
        textTheme: textTheme,
        primaryTextTheme: _buyerTextTheme(baseTheme.primaryTextTheme),
        appBarTheme: const AppBarTheme(
          backgroundColor: _surface,
          foregroundColor: _text,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: _text,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          labelStyle: const TextStyle(
            color: Color(0xFF756B60),
            fontSize: 11,
          ),
          hintStyle: const TextStyle(
            color: Color(0xFFA49A8D),
            fontSize: 11,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _brand, width: 1.4),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: _brand,
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: const Size(0, 44),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(13),
            ),
            textStyle: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF8D5B09),
            side: const BorderSide(color: Color(0xFFE0C58D)),
            minimumSize: const Size(0, 44),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(13),
            ),
            textStyle: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFFA76C0A),
            textStyle: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: Color(0xFF2B2824),
          contentTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: _surface,
          surfaceTintColor: Colors.transparent,
          showDragHandle: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: Color(0xFFEEE7DC),
          thickness: 1,
          space: 1,
        ),
      ),
      child: Scaffold(
        backgroundColor: _background,
        body: IndexedStack(
          index: _currentPage,
          children: pages,
        ),
        bottomNavigationBar: BuyerBottomNav(
          currentIndex: _currentNavIndex,
          onTap: _onBottomNavTap,
        ),
      ),
    );
  }
}
