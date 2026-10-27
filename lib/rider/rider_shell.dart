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
import 'widgets/rider_ui.dart';

class RiderShell extends StatefulWidget {
  const RiderShell({super.key});

  @override
  State<RiderShell> createState() => _RiderShellState();
}
class _RiderShellState extends State<RiderShell> {
  int _currentIndex = 0;
  bool _darkMode = false;
  RiderDelivery? _currentDelivery = RiderDemoData.currentDelivery;
  late final List<RiderDelivery> _assignments = <RiderDelivery>[
    ...RiderDemoData.assignments,
  ];

  @override
  void initState() {
    super.initState();
    RiderThemeController.setDark(_darkMode);
  }

  void _changeTab(int index) {
    if (index < 0 || index > 4) return;
    setState(() => _currentIndex = index);
  }

  void _setDarkMode(bool value) {
    RiderThemeController.setDark(value);
    setState(() => _darkMode = value);
  }

  void _replaceDelivery(RiderDelivery updated) {
    setState(() {
      _currentDelivery = updated;
      final index = _assignments.indexWhere((item) => item.id == updated.id);
      if (index >= 0) {
        _assignments[index] = updated;
      }
    });
  }

  void _advanceDelivery(RiderDelivery delivery) {
    final next = delivery.nextStatus;
    if (next == null) return;

    final updated = delivery.copyWith(status: next);
    _replaceDelivery(updated);

    if (next == 'delivery_assigned') {
      _changeTab(1);
    } else if (const [
      'delivery_accepted',
      'parcel_released',
      'out_for_delivery',
      'arrived_buyer',
    ].contains(next)) {
      _changeTab(2);
    } else if (next == 'completed') {
      _changeTab(0);
    }

    _toast(_transitionMessage(next, updated));
  }

  String _transitionMessage(String next, RiderDelivery delivery) {
    switch (next) {
      case 'pickup_accepted':
        return 'Pickup accepted. You can now proceed to the seller.';
      case 'heading_seller':
        return 'Seller route activated.';
      case 'parcel_collected':
        return 'Parcel collected. Confirm the package code before leaving.';
      case 'heading_sorting':
        return 'Parcel confirmed. Sorting center route activated.';
      case 'sorting_received':
        return 'Sorting center handoff recorded.';
      case 'delivery_assigned':
        return 'Demo delivery assignment received from the sorting center.';
      case 'out_for_delivery':
        return 'Parcel marked Out for Delivery.';
      case 'arrived_buyer':
        return 'Customer location reached. Record delivery result.';
      case 'completed':
        return 'Buyer receipt confirmed. Order completed.';
      default:
        return 'Status updated to ${delivery.statusLabel}.';
    }
  }

  void _markSuccessful(RiderDelivery delivery) {
    _replaceDelivery(delivery.copyWith(status: 'delivered'));
    _toast('Successful delivery recorded. Waiting for buyer confirmation.');
  }

  void _markFailed(RiderDelivery delivery, String reason) {
    _replaceDelivery(
      delivery.copyWith(
        status: 'delivery_failed',
        failureReason: reason,
      ),
    );
    _toast('Delivery failed reason recorded.');
  }

  void _rescheduleDelivery(RiderDelivery delivery) {
    _replaceDelivery(
      delivery.copyWith(
        status: 'out_for_delivery',
        failureReason: delivery.failureReason,
      ),
    );
    _toast('Delivery rescheduled. Customer route is active again.');
  }

  void _returnToSorting(RiderDelivery delivery) {
    _replaceDelivery(
      delivery.copyWith(
        status: 'returning_to_sorting',
        failureReason: delivery.failureReason,
      ),
    );
    _toast('Return-to-sorting route activated.');
  }

  void _buyerConfirmed(RiderDelivery delivery) {
    _replaceDelivery(delivery.copyWith(status: 'completed'));
    _changeTab(0);
    _toast('Buyer confirmed receipt. Delivery completed.');
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(message),
        ),
      );
  }

  void _openMessages() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => RiderMessages(
          initialMessages: RiderDemoData.messages,
        ),
      ),
    );
  }

  void _openPickups() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => RiderPickups(
          orders: _assignments,
          onAdvanceDelivery: _advanceDelivery,
          onOpenWorkflow: () {
            Navigator.of(context).pop();
            _changeTab(0);
          },
        ),
      ),
    );
  }

  void _openHistory() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => RiderHistory(
          history: RiderDemoData.history,
        ),
      ),
    );
  }

  TextTheme _withPesoFallback(TextTheme theme) {
    TextStyle? fallback(TextStyle? style) {
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
    RiderThemeController.setDark(_darkMode);

    final pages = <Widget>[
      RiderHome(
        currentDelivery: _currentDelivery,
        assignments: _assignments,
        profile: RiderDemoData.profile,
        isDarkMode: _darkMode,
        onDarkModeChanged: _setDarkMode,
        onTabChanged: _changeTab,
        onAdvanceDelivery: _advanceDelivery,
        onOpenMessages: _openMessages,
        onOpenHistory: _openHistory,
        onOpenPickups: _openPickups,
      ),
      RiderRequests(
        activeOrder: _currentDelivery,
        orders: _assignments,
        onAdvanceDelivery: _advanceDelivery,
        onOpenWorkflow: () => _changeTab(0),
        onOpenPickups: _openPickups,
        onOpenDelivery: () => _changeTab(2),
      ),
      RiderDeliveries(
        orders: _assignments,
        onAdvanceDelivery: _advanceDelivery,
        onOpenWorkflow: () => _changeTab(0),
        onOpenHistory: _openHistory,
        onMarkSuccessful: _markSuccessful,
        onMarkFailed: _markFailed,
        onReschedule: _rescheduleDelivery,
        onReturnToSorting: _returnToSorting,
        onBuyerConfirmed: _buyerConfirmed,
      ),
      RiderEarnings(
        daily: RiderDemoData.dailyEarnings,
        transactions: RiderDemoData.transactions,
        onOpenHistory: _openHistory,
      ),
      RiderProfilePage(
        profile: RiderDemoData.profile,
        isDarkMode: _darkMode,
        onDarkModeChanged: _setDarkMode,
      ),
    ];

    final currentTheme = Theme.of(context);
    final brightness = _darkMode ? Brightness.dark : Brightness.light;
    final baseTextTheme = _withPesoFallback(currentTheme.textTheme).apply(
      bodyColor: RiderColors.text,
      displayColor: RiderColors.text,
    );

    final scheme = ColorScheme.fromSeed(
      seedColor: RiderColors.blue,
      brightness: brightness,
    ).copyWith(
      primary: RiderColors.gold,
      secondary: RiderColors.blue,
      surface: RiderColors.surface,
      onSurface: RiderColors.text,
      error: RiderColors.red,
    );

    return Theme(
      data: ThemeData(
        useMaterial3: true,
        brightness: brightness,
        colorScheme: scheme,
        scaffoldBackgroundColor: RiderColors.bg,
        textTheme: baseTextTheme,
        primaryTextTheme: baseTextTheme,
        appBarTheme: AppBarTheme(
          backgroundColor: RiderColors.bg,
          foregroundColor: RiderColors.text,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
        ),
        dividerColor: RiderColors.border,
        iconTheme: IconThemeData(color: RiderColors.text),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: RiderColors.field,
          labelStyle: TextStyle(color: RiderColors.muted),
          hintStyle: TextStyle(color: RiderColors.muted),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: RiderColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: RiderColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: RiderColors.blue, width: 1.4),
          ),
        ),
        bottomSheetTheme: BottomSheetThemeData(
          backgroundColor: RiderColors.surfaceElevated,
          surfaceTintColor: Colors.transparent,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: RiderColors.isDark
              ? RiderColors.surfaceElevated
              : RiderColors.text,
          contentTextStyle: TextStyle(
            color: RiderColors.isDark ? RiderColors.text : Colors.white,
            fontSize: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      child: Scaffold(
        backgroundColor: RiderColors.bg,
        body: AnimatedSwitcher(
          duration: Duration(milliseconds: 220),
          child: IndexedStack(
            key: ValueKey<bool>(_darkMode),
            index: _currentIndex,
            children: pages,
          ),
        ),
        bottomNavigationBar: RiderBottomNav(
          currentIndex: _currentIndex,
          onTap: _changeTab,
        ),
      ),
    );
  }
}
