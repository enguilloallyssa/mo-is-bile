
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'models/rider_delivery_model.dart';
import 'rider_deliveries.dart';
import 'rider_earnings.dart';
import 'rider_history.dart';
import 'rider_home.dart';
import 'rider_last_mile.dart';
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

  RiderDelivery? _currentDelivery =
      RiderDemoData.currentDelivery;

  late final List<RiderDelivery> _assignments = [
    ...RiderDemoData.assignments,
  ];

  // Empty until the authenticated Laravel API
  // supplies genuine last-mile batch data.
  final List<RiderLastMileBatch> _lastMileBatches = [];

  @override
  void initState() {
    super.initState();
    RiderThemeController.setDark(_darkMode);
  }

  void _changeTab(int index) {
    if (index < 0 || index > 4) return;

    setState(() {
      _currentIndex = index;
    });
  }

  void _setDarkMode(bool value) {
    RiderThemeController.setDark(value);

    setState(() {
      _darkMode = value;
    });
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

  void _replaceDelivery(RiderDelivery updated) {
    setState(() {
      _currentDelivery = updated;

      final index = _assignments.indexWhere(
        (item) => item.id == updated.id,
      );

      if (index >= 0) {
        _assignments[index] = updated;
      }
    });
  }

  // Existing local/demo progression.
  // This does not update Laravel.
  void _advanceDelivery(RiderDelivery delivery) {
    final next = delivery.nextStatus;

    if (next == null) return;

    final updated = delivery.copyWith(status: next);

    _replaceDelivery(updated);

    if (next == 'delivery_assigned' ||
        next == 'pickup_assigned') {
      _changeTab(1);
    } else if (const {
      'delivery_accepted',
      'parcel_released',
      'out_for_delivery',
      'arrived_buyer',
    }.contains(next)) {
      _changeTab(2);
    }

    _toast(
      'Preview status: ${updated.statusLabel}. '
      'Not saved to Laravel.',
    );
  }

  void _markSuccessful(RiderDelivery delivery) {
    // Do not mark a real order delivered without
    // server-confirmed parcel scanning and POD.
    _toast(
      'Delivery confirmation requires Laravel '
      'proof-of-delivery verification.',
    );
  }

  void _markFailed(
    RiderDelivery delivery,
    String reason,
  ) {
    _toast(
      'Failed delivery submission requires '
      'the Laravel Rider API.',
    );
  }

  void _rescheduleDelivery(RiderDelivery delivery) {
    _toast(
      'Rescheduling requires the Laravel Rider API.',
    );
  }

  void _returnToSorting(RiderDelivery delivery) {
    _toast(
      'Return-to-hub confirmation requires '
      'the Laravel Rider API.',
    );
  }

  void _buyerConfirmed(RiderDelivery delivery) {
    _toast(
      'Buyer receipt confirmation requires '
      'the Laravel API.',
    );
  }

  void _openMessages() {
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => RiderMessages(
          initialMessages: RiderDemoData.messages,
        ),
      ),
    );
  }

  void _openHistory() {
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => RiderHistory(
          history: RiderDemoData.history,
        ),
      ),
    );
  }

  void _openPickups() {
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => RiderPickups(
          orders: _assignments,
          onAdvanceDelivery: _advanceDelivery,
          onOpenWorkflow: () {
            Navigator.of(context).pop();
            _changeTab(1);
          },
        ),
      ),
    );
  }

  void _openLastMile() {
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => RiderLastMile(
          batches: _lastMileBatches,
          onBackToDashboard: () {
            Navigator.of(context).pop();
            _changeTab(0);
          },
          onScanParcel: (parcel) {
            _openScanner(expectedCode: parcel.parcelCode);
          },
          onOpenParcel: (parcel) {
            _toast(
              'POD for ${parcel.orderNumber} '
              'requires an authenticated last-mile '
              'delivery record.',
            );
          },
        ),
      ),
    );
  }

  Future<void> _openScanner({
    String? expectedCode,
  }) async {
    final scannedCode =
        await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => _RiderScannerPage(
          expectedCode: expectedCode,
        ),
      ),
    );

    if (!mounted || scannedCode == null) return;

    if (expectedCode != null) {
      if (scannedCode.trim().toUpperCase() ==
          expectedCode.trim().toUpperCase()) {
        _toast(
          'Parcel code verified locally. '
          'No Laravel status was updated.',
        );
      } else {
        _toast(
          'Scanned parcel does not match '
          'the expected parcel.',
        );
      }
      return;
    }

    final matches = _assignments.where(
      (order) =>
          order.packageCode.trim().toUpperCase() ==
          scannedCode.trim().toUpperCase(),
    );

    if (matches.isEmpty) {
      _toast(
        'No matching parcel in locally loaded assignments.',
      );
      return;
    }

    final order = matches.first;

    _showOrderDetails(order);
  }

  void _showOrderDetails(RiderDelivery order) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              20, 10, 20, 28,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Parcel Details',
                  style: TextStyle(
                    color: RiderColors.text,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 15),
                _infoRow(
                  'Order Number',
                  order.orderNumber,
                ),
                _infoRow(
                  'Parcel Code',
                  order.packageCode,
                ),
                _infoRow(
                  'Seller',
                  order.sellerName,
                ),
                _infoRow(
                  'Customer',
                  order.buyerName,
                ),
                _infoRow(
                  'Status',
                  order.statusLabel,
                ),
                const SizedBox(height: 14),
                Text(
                  'This parcel was matched against '
                  'locally loaded Rider data. '
                  'It has not been verified by Laravel.',
                  style: TextStyle(
                    color: RiderColors.muted,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(sheetContext);

                      if (order.isPickupFlow) {
                        _openPickups();
                      } else {
                        _replaceDelivery(order);
                        _changeTab(2);
                      }
                    },
                    icon: const Icon(
                      Icons.arrow_forward_rounded,
                    ),
                    label: const Text(
                      'Open Related Workflow',
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
            child: Text(
              label,
              style: TextStyle(
                color: RiderColors.muted,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: RiderColors.text,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openMoreFeatures() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: RiderColors.surface,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              16, 8, 16, 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Rider Operations',
                  style: TextStyle(
                    color: RiderColors.text,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 13),
                _moreTile(
                  sheetContext,
                  Icons.inventory_2_outlined,
                  'Seller Pickups',
                  'Collection workflow',
                  _openPickups,
                ),
                _moreTile(
                  sheetContext,
                  Icons.route_outlined,
                  'Last-Mile Deliveries',
                  'Hub-to-buyer batches',
                  _openLastMile,
                ),
                _moreTile(
                  sheetContext,
                  Icons.qr_code_scanner_rounded,
                  'Parcel Scanner',
                  'QR and barcode reader',
                  _openScanner,
                ),
                _moreTile(
                  sheetContext,
                  Icons.history_rounded,
                  'Delivery History',
                  'Previous assignments',
                  _openHistory,
                ),
                _moreTile(
                  sheetContext,
                  Icons.chat_bubble_outline,
                  'Messages',
                  'Logistics communication',
                  _openMessages,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _moreTile(
    BuildContext sheetContext,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback action,
  ) {
    return ListTile(
      leading: Icon(
        icon,
        color: RiderColors.blue,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: RiderColors.text,
          fontWeight: FontWeight.w800,
          fontSize: 13,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: RiderColors.muted,
          fontSize: 11,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: RiderColors.muted,
      ),
      onTap: () {
        Navigator.pop(sheetContext);
        action();
      },
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
        onOpenWorkflow: _openPickups,
        onOpenPickups: _openPickups,
        onOpenDelivery: () => _changeTab(2),
      ),

      RiderDeliveries(
        orders: _assignments,
        onAdvanceDelivery: _advanceDelivery,
        onOpenWorkflow: _openMoreFeatures,
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

    final baseTheme = Theme.of(context);
    final brightness =
        _darkMode ? Brightness.dark : Brightness.light;

    final textTheme = _withPesoFallback(
      baseTheme.textTheme,
    ).apply(
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
        textTheme: textTheme,
        primaryTextTheme: textTheme,
        appBarTheme: AppBarTheme(
          backgroundColor: RiderColors.bg,
          foregroundColor: RiderColors.text,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
        ),
        dividerColor: RiderColors.border,
        iconTheme: IconThemeData(
          color: RiderColors.text,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: RiderColors.field,
          labelStyle: TextStyle(
            color: RiderColors.muted,
          ),
          hintStyle: TextStyle(
            color: RiderColors.muted,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: RiderColors.border,
            ),
          ),
        ),
        bottomSheetTheme: BottomSheetThemeData(
          backgroundColor: RiderColors.surface,
          surfaceTintColor: Colors.transparent,
        ),
      ),
      child: Scaffold(
        backgroundColor: RiderColors.bg,
        body: IndexedStack(
          index: _currentIndex,
          children: pages,
        ),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Shortcuts for web features that don't fit
            // into the five-item mobile bottom nav.
            Padding(
              padding: const EdgeInsets.fromLTRB(
                16, 4, 16, 5,
              ),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _openMoreFeatures,
                  icon: const Icon(
                    Icons.apps_rounded,
                    size: 18,
                  ),
                  label: const Text(
                    'More Rider Features',
                  ),
                ),
              ),
            ),
            RiderBottomNav(
              currentIndex: _currentIndex,
              onTap: _changeTab,
            ),
          ],
        ),
      ),
    );
  }
}

// Dedicated scanner accessible from the Rider shell.
class _RiderScannerPage extends StatefulWidget {
  const _RiderScannerPage({
    this.expectedCode,
  });

  final String? expectedCode;

  @override
  State<_RiderScannerPage> createState() =>
      _RiderScannerPageState();
}

class _RiderScannerPageState
    extends State<_RiderScannerPage> {
  bool _handled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Parcel Scanner'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Icon(
                  Icons.qr_code_scanner_rounded,
                  size: 42,
                  color: Colors.white,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Scan Parcel',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.expectedCode == null
                      ? 'Scan an assigned parcel QR or barcode.'
                      : 'Expected parcel: ${widget.expectedCode}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: MobileScanner(
                onDetect: (capture) {
                  if (_handled) return;

                  for (final barcode in capture.barcodes) {
                    final code = barcode.rawValue;

                    if (code == null ||
                        code.trim().isEmpty) {
                      continue;
                    }

                    _handled = true;

                    Navigator.of(context).pop(
                      code.trim(),
                    );
                    return;
                  }
                },
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Position the parcel QR or barcode '
              'inside the camera frame.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
