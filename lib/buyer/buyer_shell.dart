import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../services/sari_live_data.dart';

import 'buyer_account.dart';
import 'buyer_cart.dart';
import 'buyer_home.dart';
import 'buyer_messages.dart';
import 'buyer_shipping.dart';
import 'widgets/buyer_navigation_scope.dart';
import 'buyer_notifications.dart';
import 'buyer_orders.dart';
import 'buyer_products.dart';
import 'buyer_theme.dart';
import 'widgets/buyer_bottom_nav.dart';

class BuyerShell extends StatefulWidget {
  const BuyerShell({
    super.key,
  });

  @override
  State<BuyerShell> createState() =>
      _BuyerShellState();
}

class _BuyerShellState
    extends State<BuyerShell> {
  // ------------------------------------------
  // BUYER MOBILE PAGE MAP
  // ------------------------------------------
  //
  // 0 = Home
  // 1 = Shop Products
  // 2 = Shopping Cart
  // 3 = My Orders
  // 4 = Account
  // 5 = Notifications
  //
  // Other Laravel Buyer pages will be added
  // after their mobile content/flow is aligned.
  // ------------------------------------------

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentPage = 0;
  int _currentNavIndex = 0;

  bool _checkingAccess = false;
  bool _loggingOut = false;

  static const Color _gold =
      Color(0xFFD9950B);

  int _navIndexForPage(
    int page,
  ) {
    switch (page) {
      case 0:
        return 0;

      case 1:
        return 1;

      case 3:
        return 2;

      case 5:
        return 3;

      case 4:
        return 4;

      default:
        return _currentNavIndex;
    }
  }

  bool _requiresLogin(
    int page,
  ) {
    return page == 2 || page == 3 || page == 4 ||
        page == 5 || page == 6 || page == 7;
  }

  Future<void> _openPage(
    int page,
  ) async {
    if (page < 0 || page > 7) {
      return;
    }

    if (_requiresLogin(page)) {
      await _openProtectedPage(
        page,
      );

      return;
    }

    if (!mounted) return;

    setState(() {
      _currentPage = page;
      _currentNavIndex =
          _navIndexForPage(page);
    });
  }

  Future<void> _openProtectedPage(
    int page,
  ) async {
    if (_checkingAccess) {
      return;
    }

    setState(() {
      _checkingAccess = true;
    });

    try {
      final hasToken =
          await SariLiveData.instance
              .hasAccessToken();

      if (!mounted) return;

      if (!hasToken) {
        _showLoginRequired();
        return;
      }

      setState(() {
        _currentPage = page;
        _currentNavIndex =
            _navIndexForPage(page);
      });
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        'Unable to verify your session: $error',
      );
    } finally {
      if (mounted) {
        setState(() {
          _checkingAccess = false;
        });
      }
    }
  }

  Future<void> _onBottomNavTap(
    int index,
  ) async {
    const pages = <int>[
      0,
      1,
      3,
      5,
      4,
    ];

    if (index < 0 ||
        index >= pages.length) {
      return;
    }

    await _openPage(
      pages[index],
    );
  }

  void _showLoginRequired() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Login Required',
            style: TextStyle(
              fontWeight:
                  FontWeight.w800,
            ),
          ),
          content: const Text(
            'Please log in to your SARI Buyer account to access this page.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop();
              },
              child:
                  const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop();

                Navigator.of(context)
                    .pushNamed(
                  '/login',
                );
              },
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    _gold,
                foregroundColor:
                    Colors.white,
              ),
              child:
                  const Text('Login'),
            ),
          ],
        );
      },
    );
  }

  void _showMessage(
    String message,
  ) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior:
              SnackBarBehavior.floating,
        ),
      );
  }

  ThemeData _buyerTheme(
    BuildContext context,
  ) {
    final base =
        Theme.of(context);

    final textTheme =
        GoogleFonts.poppinsTextTheme(
      base.textTheme,
    ).apply(
      bodyColor: BuyerTheme.ink,
      displayColor: BuyerTheme.ink,
    );

    return base.copyWith(
      scaffoldBackgroundColor:
          BuyerTheme.canvas,
      canvasColor:
          BuyerTheme.canvas,
      textTheme: textTheme,
      primaryTextTheme: textTheme,

      colorScheme:
          base.colorScheme.copyWith(
        primary: BuyerTheme.gold,
        secondary:
            BuyerTheme.goldDark,
        surface:
            BuyerTheme.surface,
        onSurface:
            BuyerTheme.ink,
        error:
            BuyerTheme.danger,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor:
            BuyerTheme.surface,
        foregroundColor:
            BuyerTheme.inkCool,
        surfaceTintColor:
            Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle:
            GoogleFonts.poppins(
          color: BuyerTheme.inkCool,
          fontSize: 17,
          fontWeight:
              FontWeight.w700,
        ),
      ),

      inputDecorationTheme:
          InputDecorationTheme(
        filled: true,
        fillColor:
            BuyerTheme.surface,
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 12,
        ),
        border:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            BuyerTheme.controlRadius,
          ),
        ),
        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            BuyerTheme.controlRadius,
          ),
          borderSide:
              const BorderSide(
            color:
                BuyerTheme.border,
          ),
        ),
        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            BuyerTheme.controlRadius,
          ),
          borderSide:
              const BorderSide(
            color:
                BuyerTheme.gold,
            width: 1.2,
          ),
        ),
      ),

      elevatedButtonTheme:
          ElevatedButtonThemeData(
        style:
            ElevatedButton.styleFrom(
          backgroundColor:
              BuyerTheme.gold,
          foregroundColor:
              Colors.white,
          elevation: 0,
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              BuyerTheme.controlRadius,
            ),
          ),
          textStyle:
              GoogleFonts.poppins(
            fontWeight:
                FontWeight.w700,
          ),
        ),
      ),

      outlinedButtonTheme:
          OutlinedButtonThemeData(
        style:
            OutlinedButton.styleFrom(
          foregroundColor:
              BuyerTheme.goldDark,
          side:
              const BorderSide(
            color:
                BuyerTheme.border,
          ),
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              BuyerTheme.controlRadius,
            ),
          ),
        ),
      ),

      snackBarTheme:
          SnackBarThemeData(
        backgroundColor:
            const Color(
          0xFF292929,
        ),
        contentTextStyle:
            GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 11,
        ),
        behavior:
            SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildPage(
    int page,
  ) {
    switch (page) {
      case 0:
        return BuyerHome(
          onTabChanged:
              _openPage,
        );

      case 1:
        return BuyerProducts(
          onTabChanged:
              _openPage,
        );

      case 2:
        return BuyerCart(
          onTabChanged:
              _openPage,
        );

      case 3:
        return BuyerOrders(
          onTabChanged:
              _openPage,
        );

      case 4:
        return BuyerAccount(
          onTabChanged:
              _openPage,
        );

      case 5:
        return BuyerNotifications(onTabChanged: _openPage);
      case 6:
        return BuyerMessages(onTabChanged: _openPage);
      case 7:
        return const BuyerShipping();

      default:
        return BuyerHome(
          onTabChanged:
              _openPage,
        );
    }
  }

  void _openAccountSettings() {
    if (_currentPage == 4) {
      _scaffoldKey.currentState?.openEndDrawer();
    }
  }

  void _openSettingsPage(int page) {
    _scaffoldKey.currentState?.closeEndDrawer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _openPage(page);
    });
  }

  Future<void> _logout() async {
    if (_loggingOut) return;
    _scaffoldKey.currentState?.closeEndDrawer();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Log out of SARI?'),
        content: const Text('You will need to sign in again to access your Buyer account.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Stay signed in')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Log out')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _loggingOut = true);
    bool revokedRemotely = false;
    try {
      await SariLiveData.instance.logout();
      revokedRemotely = true;
    } catch (_) {
      // Server can be offline. Still clear local credentials for device logout.
    }
    try {
      const storage = FlutterSecureStorage();
      await storage.delete(key: 'sari_access_token');
      await storage.delete(key: 'sari_account_role');
      if (!mounted) return;
      if (!revokedRemotely) {
        _showMessage('Logged out on this device. Server session revocation could not be confirmed.');
      }
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
    } catch (error) {
      if (mounted) _showMessage('Unable to clear the local session: $error');
    } finally {
      if (mounted) setState(() => _loggingOut = false);
    }
  }

  Widget _settingsDrawer() {
    return Drawer(
      width: MediaQuery.sizeOf(context).width > 430 ? 335 : MediaQuery.sizeOf(context).width * .86,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(left: Radius.circular(26)),
      ),
      backgroundColor: BuyerTheme.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 16, 12),
              child: Row(children: [
                Container(
                  height: 43, width: 43,
                  decoration: BoxDecoration(color: BuyerTheme.goldPale, borderRadius: BorderRadius.circular(14)),
                  child: const Icon(Icons.tune_rounded, color: BuyerTheme.goldDark),
                ),
                const SizedBox(width: 12),
                const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Account settings', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: BuyerTheme.ink)),
                  Text('More options for your account', style: TextStyle(fontSize: 10, color: BuyerTheme.muted)),
                ])),
                IconButton(tooltip: 'Close settings', onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close_rounded)),
              ]),
            ),
            const Divider(height: 1, color: BuyerTheme.border),
            const Padding(
              padding: EdgeInsets.fromLTRB(22, 20, 16, 8),
              child: Text('MORE SERVICES', style: TextStyle(color: BuyerTheme.goldDark, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.3)),
            ),
            _settingsLink(Icons.chat_bubble_outline_rounded, 'Messages', 'Conversations with sellers', () => _openSettingsPage(6)),
            _settingsLink(Icons.local_shipping_outlined, 'Shipping & tracking', 'Track your orders in transit', () => _openSettingsPage(7)),
            const Spacer(),
            const Divider(height: 1, color: BuyerTheme.border),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 5),
              child: Material(
                color: const Color(0xFFFFF1EF),
                borderRadius: BorderRadius.circular(15),
                child: ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  leading: const Icon(Icons.logout_rounded, color: BuyerTheme.danger),
                  title: Text(_loggingOut ? 'Signing out...' : 'Log out', style: const TextStyle(fontWeight: FontWeight.w800, color: BuyerTheme.danger)),
                  subtitle: const Text('End your Buyer session on this device', style: TextStyle(fontSize: 10)),
                  onTap: _loggingOut ? null : _logout,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(22, 6, 22, 12),
              child: Text('SARI Marketplace · Buyer account', style: TextStyle(fontSize: 10, color: BuyerTheme.muted)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _settingsLink(IconData icon, String title, String subtitle, VoidCallback onTap) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
    child: Material(
      color: BuyerTheme.canvas,
      borderRadius: BorderRadius.circular(15),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        leading: Icon(icon, color: BuyerTheme.goldDark),
        title: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: BuyerTheme.ink)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 10, color: BuyerTheme.muted)),
        trailing: const Icon(Icons.chevron_right_rounded, color: BuyerTheme.muted, size: 20),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Theme(
      data:
          _buyerTheme(context),
      child: BuyerNavigationScope(
        openSettings: _openAccountSettings,
        child: Scaffold(
        key: _scaffoldKey,
        endDrawer: _currentPage == 4 ? _settingsDrawer() : null,
        endDrawerEnableOpenDragGesture: false,
        backgroundColor:
            BuyerTheme.canvas,
        body: Stack(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: child,
              ),
              child: KeyedSubtree(
                key: ValueKey<int>(_currentPage),
                child: _buildPage(_currentPage),
              ),
            ),
            if (_checkingAccess)
              Positioned.fill(
                child: ColoredBox(
                  color: const Color(0x55FFFFFF),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BuyerTheme.card(),
                      child: const CircularProgressIndicator(color: _gold),
                    ),
                  ),
                ),
              ),
          ],
        ),
        bottomNavigationBar:
            BuyerBottomNav(
          currentIndex:
              _currentNavIndex,
          onTap:
              _onBottomNavTap,
        ),
        ), // Scaffold
      ), // BuyerNavigationScope
    ); // Theme
  }
}
