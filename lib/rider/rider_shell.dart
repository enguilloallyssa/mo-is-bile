import 'package:flutter/material.dart';

import 'models/rider_delivery_model.dart';
import 'rider_deliveries.dart';
import 'rider_earnings.dart';
import 'rider_history.dart';
import 'rider_home.dart';
import 'rider_messages.dart';
import 'rider_pickups.dart';
import 'rider_profile.dart';
import 'rider_requests.dart';
import 'services/rider_demo_data.dart';
import 'widgets/rider_bottom_nav.dart';

class RiderShell extends StatefulWidget {
  const RiderShell({super.key});

  @override
  State<RiderShell> createState() => _RiderShellState();
}

class _RiderShellState extends State<RiderShell> {
  int _currentIndex = 0;

  RiderDelivery? _currentDelivery = RiderDemoData.currentDelivery;

  late final List<RiderDelivery> _assignments = <RiderDelivery>[
    ...RiderDemoData.assignments,
  ];

  void _changeTab(int index) {
    if (index < 0 || index > 4) return;

    setState(() {
      _currentIndex = index;
    });
  }

  void _advanceDelivery(RiderDelivery delivery) {
    final String? next = delivery.nextStatus;
    if (next == null) return;

    final RiderDelivery updated = delivery.copyWith(status: next);

    setState(() {
      _currentDelivery = updated;

      final int index = _assignments.indexWhere(
        (RiderDelivery item) => item.id == delivery.id,
      );

      if (index >= 0) {
        _assignments[index] = updated;
      }

      // Once the Seller handoff is confirmed, jump directly to the
      // Deliveries tab where the Buyer map is visible.
      if (next == 'in_transit') {
        _currentIndex = 2;
      }

      // After completion, return to Home so completed stats/earnings
      // are immediately visible.
      if (next == 'delivered') {
        _currentIndex = 0;
      }
    });

    final String message;
    if (next == 'in_transit') {
      message = 'Package picked up. Buyer delivery map is now active.';
    } else if (next == 'delivered') {
      message = 'Delivery completed successfully.';
    } else {
      message = 'Delivery updated to ${updated.statusLabel}.';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _openMessages() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const RiderMessages(
          initialMessages: RiderDemoData.messages,
        ),
      ),
    );
  }

  void _openPickups() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (BuildContext pageContext) => RiderPickups(
          orders: _assignments,
          onOpenWorkflow: () {
            Navigator.of(pageContext).pop();
            _changeTab(0);
          },
        ),
      ),
    );
  }

  void _openHistory() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const RiderHistory(
          history: RiderDemoData.history,
        ),
      ),
    );
  }

  TextTheme _withPesoFallback(TextTheme theme) {
    TextStyle? fallback(TextStyle? style) {
      return style?.copyWith(
        fontFamilyFallback: const <String>[
          'Roboto',
          'Noto Sans',
          'Arial',
          'sans-serif',
        ],
      );
    }

    return theme.copyWith(
      displayLarge: fallback(theme.displayLarge),
      displayMedium: fallback(theme.displayMedium),
      displaySmall: fallback(theme.displaySmall),
      headlineLarge: fallback(theme.headlineLarge),
      headlineMedium: fallback(theme.headlineMedium),
      headlineSmall: fallback(theme.headlineSmall),
      titleLarge: fallback(theme.titleLarge),
      titleMedium: fallback(theme.titleMedium),
      titleSmall: fallback(theme.titleSmall),
      bodyLarge: fallback(theme.bodyLarge),
      bodyMedium: fallback(theme.bodyMedium),
      bodySmall: fallback(theme.bodySmall),
      labelLarge: fallback(theme.labelLarge),
      labelMedium: fallback(theme.labelMedium),
      labelSmall: fallback(theme.labelSmall),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = <Widget>[
      RiderHome(
        currentDelivery: _currentDelivery,
        assignments: _assignments,
        onTabChanged: _changeTab,
        onAdvanceDelivery: _advanceDelivery,
        onOpenMessages: _openMessages,
      ),
      RiderRequests(
        activeOrder: _currentDelivery,
        orders: _assignments,
        onOpenWorkflow: () => _changeTab(0),
        onOpenPickups: _openPickups,
      ),
      RiderDeliveries(
        orders: _assignments,
        onAdvanceDelivery: _advanceDelivery,
        onOpenWorkflow: () => _changeTab(0),
        onOpenHistory: _openHistory,
      ),
      RiderEarnings(
        daily: RiderDemoData.dailyEarnings,
        transactions: RiderDemoData.transactions,
        onOpenHistory: _openHistory,
      ),
      RiderProfilePage(
        profile: RiderDemoData.profile,
      ),
    ];

    final ThemeData currentTheme = Theme.of(context);

    return Theme(
      data: currentTheme.copyWith(
        textTheme: _withPesoFallback(currentTheme.textTheme),
        primaryTextTheme: _withPesoFallback(currentTheme.primaryTextTheme),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFFBF8F1),
        body: IndexedStack(
          index: _currentIndex,
          children: pages,
        ),
        bottomNavigationBar: RiderBottomNav(
          currentIndex: _currentIndex,
          onTap: _changeTab,
        ),
      ),
    );
  }
}
