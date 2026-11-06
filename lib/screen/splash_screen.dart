import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';

import '../config/api_config.dart';
import '../services/sari_api.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  // ============================================================
  // ASSET
  // ============================================================

  // The splash now uses ONLY the transparent gold S.
  static const String _goldS = 'assets/images/sari_s.png';

  // ============================================================
  // STORAGE KEYS
  // ============================================================

  static const String _tokenKey = 'sari_access_token';
  static const String _roleKey = 'sari_account_role';

  // ============================================================
  // COLORS
  // ============================================================

  static const Color _gold = Color(0xFFE5B94E);
  static const Color _lightGold = Color(0xFFFFE99B);
  static const Color _deepGold = Color(0xFFC88C27);

  // ============================================================
  // STORAGE / API
  // ============================================================

  static const FlutterSecureStorage _storage =
      FlutterSecureStorage();

  late final SariApi _api;
  late final Future<String> _sessionRouteFuture;

  // ============================================================
  // ANIMATION
  // ============================================================

  late final AnimationController _controller;

  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;

  late final Animation<double> _moveLeft;

  late final Animation<double> _ariReveal;
  late final Animation<double> _ariFade;

  late final Animation<double> _lineReveal;
  late final Animation<double> _taglineFade;

  Animation<double> _interval(
    double begin,
    double end,
    Curve curve,
  ) {
    return CurvedAnimation(
      parent: _controller,
      curve: Interval(
        begin,
        end,
        curve: curve,
      ),
    );
  }

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    // Keep the splash completely dark and premium-looking.
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    _api = SariApi(
      baseUrl: ApiConfig.apiBaseUrl,
      timeout: const Duration(seconds: 10),
      tokenProvider: () {
        return _storage.read(
          key: _tokenKey,
        );
      },
    );

    // Validate the existing session while the animation is running.
    _sessionRouteFuture = _resolveSessionRoute();

    // Shorter and cleaner than the previous 4.8 second animation.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 3400,
      ),
    );

    // ------------------------------------------------------------
    // S APPEARS
    // ------------------------------------------------------------

    _logoFade = _interval(
      0.00,
      0.07,
      Curves.easeOut,
    );

    _logoScale = Tween<double>(
      begin: 0.92,
      end: 1.0,
    ).animate(
      _interval(
        0.00,
        0.10,
        Curves.easeOutCubic,
      ),
    );

    // ------------------------------------------------------------
    // S IMMEDIATELY MOVES LEFT
    // ------------------------------------------------------------

    _moveLeft = _interval(
      0.08,
      0.34,
      Curves.easeInOutCubic,
    );

    // ------------------------------------------------------------
    // "ari" REVEALS AFTER S STARTS MOVING
    // ------------------------------------------------------------

    _ariReveal = _interval(
      0.28,
      0.53,
      Curves.easeOutCubic,
    );

    _ariFade = _interval(
      0.30,
      0.48,
      Curves.easeOut,
    );

    // ------------------------------------------------------------
    // ACCENT LINE
    // ------------------------------------------------------------

    _lineReveal = _interval(
      0.54,
      0.67,
      Curves.easeOutCubic,
    );

    // ------------------------------------------------------------
    // TAGLINE
    // ------------------------------------------------------------

    _taglineFade = _interval(
      0.61,
      0.77,
      Curves.easeOut,
    );

    _runSplash();
  }

  // ============================================================
  // SESSION RESTORATION
  // ============================================================

  Future<String> _resolveSessionRoute() async {
    final String token =
        (await _storage.read(
                  key: _tokenKey,
                ) ??
                '')
            .trim();

    final String storedRole =
        (await _storage.read(
                  key: _roleKey,
                ) ??
                '')
            .trim()
            .toLowerCase();

    // No token:
    // new user, logged-out user, or guest.
    if (token.isEmpty) {
      return '/welcome';
    }

    try {
      // Laravel remains the source of truth.
      final SariJson response = await _api.me();

      final dynamic rawData = response['data'];

      if (rawData is! Map) {
        await _clearSession();
        return '/welcome';
      }

      final Map<String, dynamic> data =
          Map<String, dynamic>.from(
        rawData,
      );

      final dynamic rawUser = data['user'];

      if (rawUser is! Map) {
        await _clearSession();
        return '/welcome';
      }

      final Map<String, dynamic> user =
          Map<String, dynamic>.from(
        rawUser,
      );

      final String serverRole =
          (user['role'] ??
                  data['role'] ??
                  storedRole)
              .toString()
              .trim()
              .toLowerCase();

      final String? route =
          _routeForRole(serverRole);

      if (route == null) {
        await _clearSession();
        return '/welcome';
      }

      await _storage.write(
        key: _roleKey,
        value: serverRole,
      );

      return route;
    } on SariApiException catch (error) {
      // Invalid / revoked token.
      if (error.isUnauthorized) {
        await _clearSession();
        return '/welcome';
      }

      // Do not erase a valid token just because
      // the backend is temporarily unreachable.
      final String? fallback =
          _routeForRole(storedRole);

      if (fallback != null) {
        return fallback;
      }

      return '/welcome';
    } catch (error, stackTrace) {
      debugPrint(
        'SARI SESSION RESTORE ERROR: $error',
      );

      debugPrintStack(
        label: 'SESSION RESTORE STACK',
        stackTrace: stackTrace,
      );

      final String? fallback =
          _routeForRole(storedRole);

      if (fallback != null) {
        return fallback;
      }

      return '/welcome';
    }
  }

  String? _routeForRole(
    String role,
  ) {
    switch (role.trim().toLowerCase()) {
      case 'buyer':
        return '/buyer';

      case 'rider':
      case 'courier':
        return '/rider';

      case 'logistics':
        return '/logistics';

      default:
        return null;
    }
  }

  Future<void> _clearSession() async {
    await _storage.delete(
      key: _tokenKey,
    );

    await _storage.delete(
      key: _roleKey,
    );
  }

  // ============================================================
  // SPLASH FLOW
  // ============================================================

  Future<void> _runSplash() async {
    await _controller.forward();

    if (!mounted) {
      return;
    }

    final String route =
        await _sessionRouteFuture;

    if (!mounted) {
      return;
    }

    Navigator.of(context)
        .pushNamedAndRemoveUntil(
      route,
      (Route<dynamic> route) => false,
    );
  }

  // ============================================================
  // PRELOAD
  // ============================================================

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    precacheImage(
      const AssetImage(_goldS),
      context,
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _api.dispose();
    _controller.dispose();

    super.dispose();
  }

  // ============================================================
  // GOLD S
  // ============================================================

  Widget _buildGoldS() {
    /*
     * sari_s.png contains transparent space around the visible S.
     *
     * BoxFit.cover intentionally crops that transparent padding,
     * allowing the actual gold S to look larger and cleaner
     * without creating another image asset.
     */

    return SizedBox(
      width: 95,
      height: 250,
      child: Image.asset(
        _goldS,
        fit: BoxFit.cover,
        alignment: Alignment.center,
        filterQuality: FilterQuality.high,
      ),
    );
  }

  // ============================================================
  // LOGO / WORD ANIMATION
  // ============================================================

  Widget _buildLogoAnimation() {
    /*
     * Fixed design canvas.
     *
     * The complete canvas is scaled as one unit by FittedBox,
     * keeping the S and "ari" aligned on phones of different sizes.
     */

    const double canvasWidth = 340;
    const double canvasHeight = 180;

    return SizedBox(
      width: canvasWidth,
      height: canvasHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          // ------------------------------------------------------
          // SUBTLE GOLD AMBIENT GLOW
          // ------------------------------------------------------

          Positioned(
            left: 75,
            top: 9,
            width: 190,
            height: 150,
            child: Opacity(
              opacity:
                  0.18 * _logoFade.value,
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Color(
                        0x22E5B94E,
                      ),
                      blurRadius: 85,
                      spreadRadius: 15,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ------------------------------------------------------
          // GOLD S
          //
          // Starts exactly in the middle.
          // Then moves left to become the first letter of "Sari".
          // ------------------------------------------------------

          Builder(
            builder: (
              BuildContext context,
            ) {
              final double left =
                  lerpDouble(
                122.5,
                63.0,
                _moveLeft.value,
              )!;

              return Positioned(
                left: left,
                top: -35,
                width: 95,
                height: 250,
                child: Opacity(
                  opacity: _logoFade.value,
                  child: Transform.scale(
                    scale:
                        _logoScale.value,
                    alignment:
                        Alignment.center,
                    child: _buildGoldS(),
                  ),
                ),
              );
            },
          ),

          // ------------------------------------------------------
          // "ari"
          // ------------------------------------------------------

          Positioned(
            left: 125,
            top: 30,
            width: 195,
            height: 125,
            child: ClipRect(
              child: Align(
                alignment:
                    Alignment.centerLeft,
                widthFactor:
                    _ariReveal.value,
                child: Opacity(
                  opacity:
                      _ariFade.value,
                  child: Transform.translate(
                    offset: Offset(
                      (1 -
                              _ariReveal
                                  .value) *
                          -14,
                      0,
                    ),
                    child: ShaderMask(
                      blendMode:
                          BlendMode.srcIn,
                      shaderCallback:
                          (Rect bounds) {
                        return const LinearGradient(
                          begin:
                              Alignment.topCenter,
                          end:
                              Alignment.bottomCenter,
                          colors: <Color>[
                            _lightGold,
                            _gold,
                            _deepGold,
                          ],
                          stops: <double>[
                            0.0,
                            0.58,
                            1.0,
                          ],
                        ).createShader(
                          bounds,
                        );
                      },
                      child: Text(
                        'ari',
                        maxLines: 1,
                        softWrap: false,
                        style:
                            GoogleFonts.playfairDisplay(
                          fontSize: 102,
                          fontWeight:
                              FontWeight.w600,
                          height: 0.98,
                          letterSpacing: -3.6,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TAGLINE
  // ============================================================

  Widget _buildTagline() {
    return Column(
      mainAxisSize:
          MainAxisSize.min,
      children: <Widget>[
        // Gold separator line
        Container(
          width:
              50 *
              _lineReveal.value,
          height: 1.25,
          decoration: BoxDecoration(
            color: _gold.withOpacity(
              0.92 *
                  _lineReveal.value,
            ),
            borderRadius:
                BorderRadius.circular(
              20,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color:
                    _gold.withOpacity(
                  0.12 *
                      _lineReveal.value,
                ),
                blurRadius: 9,
                spreadRadius: 1,
              ),
            ],
          ),
        ),

        const SizedBox(
          height: 13,
        ),

        Opacity(
          opacity:
              _taglineFade.value,
          child: Transform.translate(
            offset: Offset(
              0,
              7 *
                  (1 -
                      _taglineFade
                          .value),
            ),
            child: Text(
              'ELEVATED EVERYDAY',
              textAlign:
                  TextAlign.center,
              maxLines: 1,
              style:
                  GoogleFonts.poppins(
                fontSize: 10,
                fontWeight:
                    FontWeight.w600,
                letterSpacing: 3.5,
                color: const Color(
                  0xFFE0C886,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // BACKGROUND
  // ============================================================

  BoxDecoration _backgroundDecoration() {
    return const BoxDecoration(
      gradient: RadialGradient(
        center: Alignment(
          0,
          -0.02,
        ),
        radius: 1.05,
        colors: <Color>[
          Color(0xFF272729),
          Color(0xFF171719),
          Color(0xFF0C0C0D),
          Color(0xFF020202),
        ],
        stops: <double>[
          0.0,
          0.38,
          0.70,
          1.0,
        ],
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final Size screen =
        MediaQuery.sizeOf(context);

    final double availableWidth =
        screen.width * 0.88;

    return Scaffold(
      backgroundColor:
          Colors.black,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration:
            _backgroundDecoration(),

        /*
         * No SafeArea here intentionally.
         *
         * This makes the actual logo composition use the true
         * physical center of the display rather than the center
         * of the remaining safe-area space.
         */
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (
              BuildContext context,
              Widget? child,
            ) {
              return Stack(
                clipBehavior:
                    Clip.none,
                alignment:
                    Alignment.center,
                children: <Widget>[
                  // ------------------------------------------------
                  // MAIN S / SARI WORD
                  // ------------------------------------------------

                  SizedBox(
                    width:
                        availableWidth,
                    height: 180,
                    child: FittedBox(
                      fit:
                          BoxFit.contain,
                      alignment:
                          Alignment.center,
                      child:
                          _buildLogoAnimation(),
                    ),
                  ),

                  // ------------------------------------------------
                  // TAGLINE
                  // ------------------------------------------------

                  Transform.translate(
                    offset:
                        const Offset(
                      0,
                      118,
                    ),
                    child:
                        _buildTagline(),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}