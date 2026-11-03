import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/sari_live_data.dart';

import 'buyer_account.dart';
import 'buyer_cart.dart';
import 'buyer_home.dart';
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

  int _currentPage = 0;
  int _currentNavIndex = 0;

  bool _checkingAccess = false;

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
    return page == 2 ||
        page == 3 ||
        page == 4 ||
        page == 5;
  }

  Future<void> _openPage(
    int page,
  ) async {
    if (page < 0 || page > 5) {
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
  return BuyerNotifications(
    onTabChanged: _openPage,
  );

      default:
        return BuyerHome(
          onTabChanged:
              _openPage,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data:
          _buyerTheme(context),
      child: Scaffold(
        backgroundColor:
            BuyerTheme.canvas,
        body: _checkingAccess
            ? const Center(
                child:
                    CircularProgressIndicator(
                  color: _gold,
                ),
              )
            : _buildPage(
                _currentPage,
              ),
        bottomNavigationBar:
            BuyerBottomNav(
          currentIndex:
              _currentNavIndex,
          onTap:
              _onBottomNavTap,
        ),
      ),
    );
  }
}