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

  late List<RiderDelivery> _assignments = [
    ...RiderDemoData.assignments,
  ];

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

  void _changeTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _advanceDelivery(RiderDelivery delivery) {
    final next = delivery.nextStatus;
    if (next == null) return;

    final updated = delivery.copyWith(status: next);

    setState(() {
      _currentDelivery = updated;

      final index = _assignments.indexWhere(
        (item) => item.id == delivery.id,
      );

      if (index >= 0) {
        _assignments[index] = updated;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Demo delivery updated to ${updated.statusLabel}.',
        ),
      ),
    );
  }

  void _openMessages() {
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => const RiderMessages(
          initialMessages: RiderDemoData.messages,
        ),
      ),
    );
  }

  void _openPickups() {
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => RiderPickups(
          orders: _assignments,
          onOpenWorkflow: () {
            Navigator.pop(context);
            _changeTab(0);
          },
        ),
      ),
    );
  }

  void _openHistory() {
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => const RiderHistory(
          history: RiderDemoData.history,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
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

    final baseTheme = Theme.of(context);

    return Theme(
      data: baseTheme.copyWith(
        textTheme: _addPesoFontFallback(
          baseTheme.textTheme,
        ),
        primaryTextTheme: _addPesoFontFallback(
          baseTheme.primaryTextTheme,
        ),
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
