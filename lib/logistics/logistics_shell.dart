import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../services/sari_live_data.dart';
import 'logistics_account.dart';
import 'logistics_home.dart';
import 'logistics_messages.dart';
import 'logistics_monitoring.dart';
import 'logistics_notifications.dart';
import 'logistics_remittances.dart';
import 'logistics_operations.dart';
import 'logistics_queues.dart';
import 'logistics_scanner.dart';
import 'logistics_transfers.dart';
import 'services/logistics_session.dart';
import 'widgets/logistics_ui.dart';

/// Root Logistics workspace. This replaces only the previous placeholder.
/// Buyer/Rider routes and files are untouched.
class LogisticsShell extends StatefulWidget {
  const LogisticsShell({super.key});

  @override
  State<LogisticsShell> createState() =>
      _LogisticsShellState();
}

class _LogisticsShellState extends State<LogisticsShell> {
  int _tab = 0;

  LogisticsSession _session =
      const LogisticsSession();

  bool _refreshing = false;
  bool _signingOut = false;

  String? _profileError;

  @override
  void initState() {
    super.initState();

    _refreshAccount();
  }

  Future<void> _refreshAccount() async {
    if (_refreshing) {
      return;
    }

    setState(() => _refreshing = true);

    try {
      final value =
          await LogisticsSessionService.load();

      if (!mounted) {
        return;
      }

      setState(() {
        _session = value;
        _profileError = null;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(
        () => _profileError =
            'Account details could not be refreshed.',
      );
    } finally {
      if (mounted) {
        setState(() => _refreshing = false);
      }
    }
  }

  void _go(int index) {
    if (index < 0 || index > 4) {
      return;
    }

    setState(() => _tab = index);
  }

  void _open(Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => page,
      ),
    );
  }

  void _openIncoming() =>
      _open(const LogisticsIncomingPage());

  void _openSorting() =>
      _open(const LogisticsSortingPage());

  void _openPickups() =>
      _open(const LogisticsPickupRequestsPage());

  void _openLastMile() =>
      _open(const LogisticsLastMilePage());

  void _openMonitoring() =>
      _open(const LogisticsMonitoring());

  void _openNotifications() =>
      _open(const LogisticsNotifications());

  void _openMessages() =>
      _open(const LogisticsMessages());

  void _openRemittances() =>
      _open(const LogisticsRemittances());

  Future<void> _logout() async {
    if (_signingOut) {
      return;
    }

    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) =>
          AlertDialog(
        title: const Text(
          'Log out of SARI Logistics?',
        ),
        content: const Text(
          'End this session on your device?',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(
              dialogContext,
              false,
            ),
            child: const Text(
              'Cancel',
            ),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(
              dialogContext,
              true,
            ),
            child: const Text(
              'Log out',
            ),
          ),
        ],
      ),
    );

    if (confirmed != true ||
        !mounted) {
      return;
    }

    setState(() => _signingOut = true);

    try {
      await SariLiveData
          .instance
          .logout();

      const storage =
          FlutterSecureStorage();

      await storage.delete(
        key: 'sari_access_token',
      );

      await storage.delete(
        key: 'sari_account_role',
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context)
          .pushNamedAndRemoveUntil(
        '/login',
        (_) => false,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Logout failed. Please check your connection and try again.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(
          () => _signingOut = false,
        );
      }
    }
  }

  Widget _currentPage() {
    switch (_tab) {
      case 0:
        return LogisticsHome(
          session: _session,
          onRefresh: _refreshAccount,
          onOperations: () => _go(1),
          onScan: () => _go(2),
          onTransfers: () => _go(3),
          onIncoming: _openIncoming,
          onSorting: _openSorting,
        );

      case 1:
        return LogisticsOperations(
          onScan: () => _go(2),
          onIncoming: _openIncoming,
          onSorting: _openSorting,
          onPickups: _openPickups,
          onLastMile: _openLastMile,
          onMonitoring: _openMonitoring,
          onRemittances: _openRemittances,
        );

      case 2:
        return const LogisticsScanner();

      case 3:
        return LogisticsTransfers(
          onScan: () => _go(2),
        );

      default:
        return LogisticsAccount(
          session: _session,
          profileError: _profileError,
          refreshing: _refreshing,
          signingOut: _signingOut,
          onRefresh: _refreshAccount,
          onLogout: _logout,
        );
    }
  }

  static const _titles = [
    'Operations Overview',
    'Parcel Operations',
    'Parcel Scanner',
    'Hub Transfers',
    'My Account',
  ];

  Widget _menuEntry(
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(
        icon,
        color: LogisticsPalette.body,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        size: 18,
      ),
      onTap: () {
        Navigator.of(context).pop();

        onTap();
      },
    );
  }

  Widget _endDrawer() => Drawer(
        width:
            MediaQuery.sizeOf(context).width *
                .82,
        backgroundColor:
            LogisticsPalette.surface,
        shape:
            const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.horizontal(
            left: Radius.circular(
              25,
            ),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding:
                      const EdgeInsets.fromLTRB(
                    13,
                    14,
                    13,
                    0,
                  ),
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.all(
                        17,
                      ),
                      decoration:
                          BoxDecoration(
                        gradient:
                            const LinearGradient(
                          colors: [
                            LogisticsPalette.navy,
                            Color(
                              0xFF75571E,
                            ),
                            LogisticsPalette.gold,
                          ],
                        ),
                        borderRadius:
                            BorderRadius.circular(
                          20,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          const Icon(
                            Icons
                                .warehouse_outlined,
                            color:
                                Colors.white,
                            size: 30,
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          Text(
                            _session.name,
                            maxLines: 1,
                            overflow:
                                TextOverflow
                                    .ellipsis,
                            style:
                                const TextStyle(
                              color:
                                  Colors.white,
                              fontSize: 17,
                              fontWeight:
                                  FontWeight
                                      .w900,
                            ),
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          Text(
                            _session.email
                                    .isEmpty
                                ? 'SARI Logistics'
                                : _session.email,
                            maxLines: 1,
                            overflow:
                                TextOverflow
                                    .ellipsis,
                            style:
                                const TextStyle(
                              color:
                                  Colors.white70,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 19,
                    ),
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                      child: Text(
                        'COMMUNICATION & TOOLS',
                        style: TextStyle(
                          color:
                              LogisticsPalette
                                  .goldDark,
                          fontSize: 10,
                          letterSpacing: .9,
                          fontWeight:
                              FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 7,
                    ),
                    _menuEntry(
                      'Notifications',
                      Icons
                          .notifications_none_rounded,
                      _openNotifications,
                    ),
                    _menuEntry(
                      'Messages',
                      Icons
                          .chat_bubble_outline_rounded,
                      _openMessages,
                    ),
                    _menuEntry(
                      'Delivery Monitoring',
                      Icons.route_outlined,
                      _openMonitoring,
                    ),
                    _menuEntry(
                      'COD Cash Intake',
                      Icons.payments_outlined,
                      _openRemittances,
                    ),
                    _menuEntry(
                      'Pickup Requests',
                      Icons
                          .assignment_turned_in_outlined,
                      _openPickups,
                    ),
                    _menuEntry(
                      'Last-Mile Queue',
                      Icons
                          .local_shipping_outlined,
                      _openLastMile,
                    ),
                    const Divider(
                      color:
                          LogisticsPalette
                              .border,
                      height: 30,
                    ),
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                      child: Text(
                        'Main navigation is available below.',
                        style: TextStyle(
                          color:
                              LogisticsPalette
                                  .muted,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(
                height: 1,
                color:
                    LogisticsPalette.border,
              ),
              ListTile(
                leading: const Icon(
                  Icons.logout_rounded,
                  color:
                      LogisticsPalette.danger,
                ),
                title: const Text(
                  'Log Out',
                  style: TextStyle(
                    fontWeight:
                        FontWeight.w800,
                    color:
                        LogisticsPalette
                            .danger,
                  ),
                ),
                onTap: () {
                  Navigator.of(context)
                      .pop();

                  _logout();
                },
              ),
              const SizedBox(
                height: 7,
              ),
            ],
          ),
        ),
      );

  /// Logistics keeps its existing five destinations; the scan tab is
  /// deliberately prominent because it is a frequent on-hub action.
  Widget _bottomBar() {
    const destinations = <(String, IconData, IconData)>[
      ('Home', Icons.grid_view_outlined, Icons.grid_view_rounded),
      ('Operations', Icons.inventory_2_outlined, Icons.inventory_2_rounded),
      ('Scan', Icons.qr_code_scanner_rounded, Icons.qr_code_scanner_rounded),
      ('Transfers', Icons.swap_horiz_outlined, Icons.swap_horiz_rounded),
      ('Account', Icons.person_outline_rounded, Icons.person_rounded),
    ];

    final compact = MediaQuery.sizeOf(context).width < 365;
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(11, 0, 11, 9),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        decoration: BoxDecoration(
          color: LogisticsPalette.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: LogisticsPalette.border),
          boxShadow: const [BoxShadow(color: Color(0x180E1B2E), blurRadius: 19, offset: Offset(0, 7))],
        ),
        child: Row(
          children: List.generate(destinations.length, (index) {
            final item = destinations[index];
            final active = _tab == index;
            final scan = index == 2;
            return Expanded(child: Semantics(
              button: true,
              selected: active,
              label: '${item.$1} tab',
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _go(index),
                  borderRadius: BorderRadius.circular(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 210),
                        curve: Curves.easeOutCubic,
                        height: 38,
                        width: compact ? 40 : 45,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: scan ? LogisticsPalette.navy : active ? LogisticsPalette.goldPale : Colors.transparent,
                          borderRadius: BorderRadius.circular(13),
                          boxShadow: scan ? const [BoxShadow(color: Color(0x221A2638), blurRadius: 10, offset: Offset(0, 3))] : null,
                        ),
                        child: Icon(active ? item.$3 : item.$2,
                          size: scan ? 23 : 21,
                          color: scan ? Colors.white : active ? LogisticsPalette.goldDark : LogisticsPalette.muted),
                      ),
                      const SizedBox(height: 4),
                      Text(item.$1,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: compact ? 9 : 10,
                          fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                          color: active ? LogisticsPalette.goldDark : LogisticsPalette.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ));
          }),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          LogisticsPalette.canvas,
      endDrawer:
          _endDrawer(),
      appBar: AppBar(
        backgroundColor:
            LogisticsPalette.surface,
        surfaceTintColor:
            Colors.transparent,
        automaticallyImplyLeading:
            false,
        titleSpacing:
            15,
        title: Row(
          children: [
            Container(
              height: 38,
              width: 38,
              decoration:
                  BoxDecoration(
                color:
                    LogisticsPalette
                        .goldPale,
                borderRadius:
                    BorderRadius.circular(
                  12,
                ),
              ),
              child: const Icon(
                Icons.hub_outlined,
                color:
                    LogisticsPalette
                        .goldDark,
                size: 21,
              ),
            ),
            const SizedBox(
              width: 9,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Text(
                    _titles[_tab],
                    maxLines: 1,
                    overflow:
                        TextOverflow
                            .ellipsis,
                    style:
                        const TextStyle(
                      fontSize: 15,
                      fontWeight:
                          FontWeight.w900,
                      color:
                          LogisticsPalette
                              .ink,
                    ),
                  ),
                  const Text(
                    'SARI Logistics',
                    style: TextStyle(
                      fontSize: 9,
                      color:
                          LogisticsPalette
                              .muted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip:
                'Notifications',
            onPressed:
                _openNotifications,
            icon: const Icon(
              Icons
                  .notifications_none_rounded,
              color:
                  LogisticsPalette.body,
              size: 22,
            ),
          ),
          Builder(
            builder:
                (menuContext) =>
                    IconButton(
              tooltip:
                  'Open menu',
              onPressed: () =>
                  Scaffold.of(
                    menuContext,
                  ).openEndDrawer(),
              icon: const Icon(
                Icons.menu_rounded,
                color:
                    LogisticsPalette
                        .ink,
                size: 24,
              ),
            ),
          ),
          const SizedBox(
            width: 4,
          ),
        ],
        bottom: _refreshing
            ? const PreferredSize(
                preferredSize:
                    Size.fromHeight(
                  2,
                ),
                child:
                    LinearProgressIndicator(
                  minHeight: 2,
                  color:
                      LogisticsPalette
                          .gold,
                  backgroundColor:
                      Colors.transparent,
                ),
              )
            : null,
      ),
      body:
          _currentPage(),
      bottomNavigationBar:
          _bottomBar(),
    );
  }
}