import 'package:flutter/material.dart';

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
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      BuyerHome(onTabChanged: _changeTab),
      BuyerProducts(onTabChanged: _changeTab),
      BuyerCart(onTabChanged: _changeTab),
      BuyerOrders(onTabChanged: _changeTab),
      const _BuyerPlaceholder(
        icon: Icons.person_outline,
        title: 'My Account',
        subtitle: 'Next: account.blade.php → buyer_account.dart',
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFBFAF8),
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: BuyerBottomNav(
        currentIndex: currentIndex,
        onTap: _changeTab,
      ),
    );
  }
}

class _BuyerPlaceholder extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _BuyerPlaceholder({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 54,
                color: const Color(0xFFC98A17),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF302A24),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF91887D),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
