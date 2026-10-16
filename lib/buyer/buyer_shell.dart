import 'package:flutter/material.dart';

import 'buyer_account.dart';
import 'buyer_cart.dart';
import 'buyer_home.dart';
import 'buyer_orders.dart';
import 'buyer_products.dart';
import 'widgets/buyer_bottom_nav.dart';

class BuyerShell extends StatefulWidget {
  const BuyerShell({super.key});

  @override
  State<BuyerShell> createState() => _BuyerShellState();
}

class _BuyerShellState extends State<BuyerShell> {
  int currentIndex = 0;

  void _changeTab(int index) {
    if (index < 0 || index > 4) return;
    setState(() => currentIndex = index);
  }

  TextTheme _addPesoFontFallback(TextTheme theme) {
    TextStyle? fix(TextStyle? style) {
      return style?.copyWith(
        fontFamilyFallback: const [
          'Roboto',
          'Noto Sans',
          'Arial',
          'sans-serif',
        ],
      );
    }

    return theme.copyWith(
      displayLarge: fix(theme.displayLarge),
      displayMedium: fix(theme.displayMedium),
      displaySmall: fix(theme.displaySmall),
      headlineLarge: fix(theme.headlineLarge),
      headlineMedium: fix(theme.headlineMedium),
      headlineSmall: fix(theme.headlineSmall),
      titleLarge: fix(theme.titleLarge),
      titleMedium: fix(theme.titleMedium),
      titleSmall: fix(theme.titleSmall),
      bodyLarge: fix(theme.bodyLarge),
      bodyMedium: fix(theme.bodyMedium),
      bodySmall: fix(theme.bodySmall),
      labelLarge: fix(theme.labelLarge),
      labelMedium: fix(theme.labelMedium),
      labelSmall: fix(theme.labelSmall),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      BuyerHome(onTabChanged: _changeTab),
      BuyerProducts(onTabChanged: _changeTab),
      BuyerCart(onTabChanged: _changeTab),
      BuyerOrders(onTabChanged: _changeTab),
      BuyerAccount(onTabChanged: _changeTab),
    ];

    final baseTheme = Theme.of(context);

    return Theme(
      data: baseTheme.copyWith(
        textTheme: _addPesoFontFallback(baseTheme.textTheme),
        primaryTextTheme: _addPesoFontFallback(baseTheme.primaryTextTheme),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFFBFAF8),
        body: IndexedStack(
          index: currentIndex,
          children: pages,
        ),
        bottomNavigationBar: BuyerBottomNav(
          currentIndex: currentIndex,
          onTap: _changeTab,
        ),
      ),
    );
  }
}
