
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/sari_live_data.dart';

import 'buyer_account.dart';
import 'buyer_cart.dart';
import 'buyer_home.dart';
import 'buyer_messages.dart';
import 'buyer_notifications.dart';
import 'buyer_orders.dart';
import 'buyer_products.dart';
import 'buyer_theme.dart';
import 'widgets/buyer_bottom_nav.dart';

class BuyerShell extends StatefulWidget {
  const BuyerShell({super.key});

  @override
  State<BuyerShell> createState() => _BuyerShellState();
}

class _BuyerShellState extends State<BuyerShell> {
  // Internal Buyer pages:
  // 0 - Home
  // 1 - Shop / Products
  // 2 - Cart
  // 3 - Orders
  // 4 - Account
  // 5 - Notifications
  // 6 - Messages

  int _currentPage = 0;
  int _currentNavIndex = 0;

  bool _loggingOut = false;
  bool _checkingAccess = false;

  static const Color _gold = Color(0xFFD9950B);

  static const FlutterSecureStorage _storage =
      FlutterSecureStorage();

  // ==========================================
  // NAVIGATION
  // ==========================================

  int _bottomIndexForPage(int page) {
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

  Future<void> _handlePageAction(int index) async {
    if (index < 0 || index > 6) return;

    if (index == 3 || index == 4) {
      await _openProtectedPage(index);
      return;
    }

    if (!mounted) return;

    setState(() {
      _currentPage = index;
      _currentNavIndex = _bottomIndexForPage(index);
    });
  }

  Future<void> _onBottomNavTap(int navIndex) async {
    const pages = <int>[0, 1, 3, 5, 4];

    if (navIndex < 0 || navIndex >= pages.length) {
      return;
    }

    final page = pages[navIndex];

    await _handlePageAction(page);
  }

  // ==========================================
  // AUTHENTICATION CHECK
  // ==========================================

  Future<void> _openProtectedPage(int page) async {
    if (_checkingAccess || _loggingOut) return;

    setState(() {
      _checkingAccess = true;
    });

    try {
      final hasToken =
          await SariLiveData.instance.hasAccessToken();

      if (!mounted) return;

      if (!hasToken) {
        _showLoginRequired();
        return;
      }

      setState(() {
        _currentPage = page;
        _currentNavIndex = _bottomIndexForPage(page);
      });
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        'Unable to verify login: $error',
      );
    } finally {
      if (mounted) {
        setState(() {
          _checkingAccess = false;
        });
      }
    }
  }

  void _showLoginRequired() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Login Required',
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
          content: const Text(
            'Please log in to your SARI Buyer '
            'account to view your orders or '
            'account information.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();

                Navigator.of(context)
                    .pushNamed('/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _gold,
                foregroundColor: Colors.white,
              ),
              child: const Text('Login'),
            ),
          ],
        );
      },
    );
  }

  // ==========================================
  // LOGOUT
  // ==========================================

  Future<void> _confirmLogout() async {
    if (_loggingOut) return;

    final hasToken =
        await SariLiveData.instance.hasAccessToken();

    if (!mounted) return;

    if (!hasToken) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login',
        (route) => false,
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Log Out',
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
          content: const Text(
            'Are you sure you want to log out '
            'of your SARI account?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF292929),
                foregroundColor: Colors.white,
              ),
              child: const Text('Log Out'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _logout();
    }
  }

  Future<void> _logout() async {
    if (_loggingOut) return;

    setState(() {
      _loggingOut = true;
    });

    try {
      // Revoke the mobile access token in Laravel.
      await SariLiveData.instance.logout();

      // Clear the local token and role only after
      // Laravel confirms successful logout.
      await SariLiveData.instance.clearLocalAccessToken();

      await _storage.delete(
        key: 'sari_account_role',
      );

      if (!mounted) return;

      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login',
        (route) => false,
      );
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        'Logout failed: $error',
      );
    } finally {
      if (mounted) {
        setState(() {
          _loggingOut = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  // ==========================================
  // BUYER THEME
  // ==========================================

  ThemeData _buyerTheme(BuildContext context) {
    final baseTheme = Theme.of(context);

    final poppins = GoogleFonts.poppinsTextTheme(
      baseTheme.textTheme,
    ).apply(
      bodyColor: BuyerTheme.ink,
      displayColor: BuyerTheme.ink,
    );

    return baseTheme.copyWith(
      scaffoldBackgroundColor: BuyerTheme.canvas,
      canvasColor: BuyerTheme.canvas,
      colorScheme: baseTheme.colorScheme.copyWith(
        primary: BuyerTheme.gold,
        secondary: BuyerTheme.goldDark,
        surface: BuyerTheme.surface,
        onSurface: BuyerTheme.ink,
        error: BuyerTheme.danger,
      ),
      textTheme: poppins,
      primaryTextTheme: poppins,

      appBarTheme: AppBarTheme(
        backgroundColor: BuyerTheme.surface,
        foregroundColor: BuyerTheme.inkCool,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.poppins(
          color: BuyerTheme.inkCool,
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: const IconThemeData(
          color: BuyerTheme.body,
          size: 20,
        ),
      ),

      cardTheme: CardThemeData(
        color: BuyerTheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            BuyerTheme.cardRadius,
          ),
          side: const BorderSide(
            color: BuyerTheme.border,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: BuyerTheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 12,
        ),
        hintStyle: GoogleFonts.poppins(
          color: BuyerTheme.muted,
          fontSize: 11,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            BuyerTheme.controlRadius,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            BuyerTheme.controlRadius,
          ),
          borderSide: const BorderSide(
            color: BuyerTheme.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            BuyerTheme.controlRadius,
          ),
          borderSide: const BorderSide(
            color: BuyerTheme.gold,
            width: 1.2,
          ),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: BuyerTheme.gold,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(0, 42),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              BuyerTheme.controlRadius,
            ),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: BuyerTheme.goldDark,
          side: const BorderSide(
            color: Color(0xFFE2C98F),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              BuyerTheme.controlRadius,
            ),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: BuyerTheme.goldDark,
          textStyle: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: BuyerTheme.border,
        thickness: 1,
        space: 1,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF292929),
        contentTextStyle: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 11,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // ==========================================
  // PAGE BUILDING
  // ==========================================

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return BuyerHome(
          onTabChanged: _handlePageAction,
        );

      case 1:
        return BuyerProducts(
          onTabChanged: _handlePageAction,
        );

      case 2:
        return BuyerCart(
          onTabChanged: _handlePageAction,
        );

      case 3:
        return BuyerOrders(
          onTabChanged: _handlePageAction,
        );

      case 4:
        return BuyerAccount(
          onTabChanged: _handlePageAction,
        );

      case 5:
        return const BuyerNotifications();

      case 6:
        return BuyerMessages(
          onTabChanged: _handlePageAction,
        );

      default:
        return BuyerHome(
          onTabChanged: _handlePageAction,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _buyerTheme(context),
      child: Scaffold(
        backgroundColor: BuyerTheme.canvas,

        appBar: _currentPage == 4
            ? AppBar(
                title: const Text('Account'),
                actions: [
                  if (_loggingOut)
                    const Padding(
                      padding: EdgeInsets.all(14),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: _gold,
                        ),
                      ),
                    )
                  else
                    IconButton(
                      tooltip: 'Log Out',
                      onPressed: _confirmLogout,
                      icon: const Icon(
                        Icons.logout_rounded,
                      ),
                    ),
                ],
              )
            : null,

        body: _checkingAccess
            ? const Center(
                child: CircularProgressIndicator(
                  color: _gold,
                ),
              )
            : _buildPage(_currentPage),

        bottomNavigationBar: BuyerBottomNav(
          currentIndex: _currentNavIndex,
          onTap: (index) {
            _onBottomNavTap(index);
          },
        ),
      ),
    );
  }
}
