import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
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
  // ASSETS
  // ============================================================

  static const String _logoTile =
      'assets/images/sari-logo.png';

  static const String _goldS =
      'assets/images/sari_s.png';

  // ============================================================
  // STORAGE KEYS
  // ============================================================

  static const String _tokenKey =
      'sari_access_token';

  static const String _roleKey =
      'sari_account_role';

  // ============================================================
  // COLORS
  // ============================================================

  static const Color _gold =
      Color(0xFFE5B94E);

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

  late final Animation<double> _entrance;
  late final Animation<double> _entranceScale;

  late final Animation<double> _tileFadeOut;
  late final Animation<double> _standaloneSFadeIn;

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

    _api = SariApi(
      baseUrl: ApiConfig.apiBaseUrl,
      timeout: const Duration(seconds: 10),
      tokenProvider: () {
        return _storage.read(
          key: _tokenKey,
        );
      },
    );

    /*
     * Start validating the mobile session immediately.
     *
     * This runs at the same time as the splash animation,
     * so the user does not need to wait for another loading
     * screen after the animation.
     */
    _sessionRouteFuture =
        _resolveSessionRoute();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 4800,
      ),
    );

    // Original logo tile enters.
    _entrance = _interval(
      0.00,
      0.18,
      Curves.easeOut,
    );

    _entranceScale = Tween<double>(
      begin: 0.72,
      end: 1.0,
    ).animate(
      _interval(
        0.00,
        0.22,
        Curves.easeOutBack,
      ),
    );

    // Gold S appears.
    _standaloneSFadeIn = _interval(
      0.27,
      0.43,
      Curves.easeInOut,
    );

    // Original tile disappears.
    _tileFadeOut = _interval(
      0.32,
      0.50,
      Curves.easeInOut,
    );

    // S moves to the left.
    _moveLeft = _interval(
      0.45,
      0.69,
      Curves.easeInOutCubic,
    );

    // "ari" reveals.
    _ariReveal = _interval(
      0.50,
      0.72,
      Curves.easeOutCubic,
    );

    _ariFade = _interval(
      0.50,
      0.68,
      Curves.easeOut,
    );

    // Bottom line.
    _lineReveal = _interval(
      0.70,
      0.84,
      Curves.easeOutCubic,
    );

    // Tagline.
    _taglineFade = _interval(
      0.76,
      0.91,
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

    /*
     * No token means:
     *
     * - new user
     * - logged out user
     * - guest user
     *
     * Go to the normal Welcome page.
     */
    if (token.isEmpty) {
      return '/welcome';
    }

    try {
      /*
       * The Laravel backend is the source of truth.
       *
       * We do NOT automatically trust only the locally
       * saved role.
       */
      final SariJson response =
          await _api.me();

      final dynamic rawData =
          response['data'];

      if (rawData is! Map) {
        await _clearSession();

        return '/welcome';
      }

      final Map<String, dynamic> data =
          Map<String, dynamic>.from(
        rawData,
      );

      final dynamic rawUser =
          data['user'];

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

      /*
       * Keep the locally stored role synchronized with
       * whatever Laravel currently says the account is.
       */
      await _storage.write(
        key: _roleKey,
        value: serverRole,
      );

      return route;
    } on SariApiException catch (error) {
      /*
       * A 401 means the token no longer exists or is invalid.
       *
       * Examples:
       * - logout from another device using logout-all
       * - token revoked from Laravel
       * - expired/removed Sanctum token
       */
      if (error.isUnauthorized) {
        await _clearSession();

        return '/welcome';
      }

      /*
       * IMPORTANT:
       *
       * If Laravel is temporarily unavailable (500/502/530,
       * network timeout, etc.), DO NOT delete a potentially
       * valid login token.
       *
       * We can temporarily use the previously verified
       * stored role.
       *
       * The actual Rider/Buyer pages will still refresh
       * their data from Laravel when they open.
       */
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
    /*
     * Animation and API verification are running
     * simultaneously.
     */
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
  // IMAGE PRELOAD
  // ============================================================

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    precacheImage(
      const AssetImage(_logoTile),
      context,
    );

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
  // LOGO ANIMATION
  // ============================================================

  Widget _buildLogoAnimation() {
    /*
     * Fixed design canvas.
     *
     * FittedBox scales the complete animation instead of
     * allowing the S and "ari" to separate on phones with
     * different screen sizes.
     */
    return SizedBox(
      width: 340,
      height: 205,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          // ----------------------------------------------------
          // ORIGINAL BLACK LOGO TILE
          // ----------------------------------------------------

          Positioned(
            left: 67,
            top: 0,
            width: 206,
            height: 206,
            child: Opacity(
              opacity: (
                _entrance.value *
                    (1 - _tileFadeOut.value)
              ).clamp(
                0.0,
                1.0,
              ),
              child: Transform.scale(
                scale:
                    _entranceScale.value,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(
                      45,
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color:
                            _gold.withOpacity(
                          0.17,
                        ),
                        blurRadius: 55,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(
                      45,
                    ),
                    child:
                        Transform.scale(
                      scale: 1.05,
                      child: Image.asset(
                        _logoTile,
                        width: 206,
                        height: 206,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ----------------------------------------------------
          // TRANSPARENT GOLD S
          // ----------------------------------------------------

          AnimatedBuilder(
            animation: _controller,
            builder: (
              BuildContext context,
              Widget? child,
            ) {
              final double progress =
                  _moveLeft.value;

              final double left =
                  lerpDouble(
                111,
                31,
                progress,
              )!;

              final double top =
                  lerpDouble(
                27,
                40,
                progress,
              )!;

              final double width =
                  lerpDouble(
                118,
                108,
                progress,
              )!;

              final double height =
                  lerpDouble(
                156,
                132,
                progress,
              )!;

              return Positioned(
                left: left,
                top: top,
                width: width,
                height: height,
                child: Opacity(
                  opacity:
                      _standaloneSFadeIn
                          .value,
                  child: Image.asset(
                    _goldS,
                    width: width,
                    height: height,
                    fit: BoxFit.contain,
                  ),
                ),
              );
            },
          ),

          // ----------------------------------------------------
          // "ari"
          // ----------------------------------------------------

          Positioned(
            left: 101,
            top: 40,
            width: 220,
            height: 135,
            child: ClipRect(
              child: Align(
                alignment:
                    Alignment.centerLeft,
                widthFactor:
                    _ariReveal.value,
                child: Opacity(
                  opacity:
                      _ariFade.value,
                  child:
                      Transform.translate(
                    offset: Offset(
                      (1 -
                              _ariReveal
                                  .value) *
                          -25,
                      0,
                    ),
                    child: ShaderMask(
                      blendMode:
                          BlendMode.srcIn,
                      shaderCallback:
                          (Rect bounds) {
                        return const LinearGradient(
                          begin: Alignment
                              .topCenter,
                          end: Alignment
                              .bottomCenter,
                          colors: <Color>[
                            Color(
                              0xFFFFE99B,
                            ),
                            Color(
                              0xFFE8BD55,
                            ),
                            Color(
                              0xFFD39C2D,
                            ),
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
                        style: GoogleFonts
                            .playfairDisplay(
                          fontSize: 112,
                          fontWeight:
                              FontWeight.w600,
                          height: 1.0,
                          letterSpacing: -4,
                          color:
                              Colors.white,
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
        Container(
          width:
              52 * _lineReveal.value,
          height: 1.2,
          decoration: BoxDecoration(
            color: _gold.withOpacity(
              0.95 *
                  _lineReveal.value,
            ),
            borderRadius:
                BorderRadius.circular(
              10,
            ),
          ),
        ),

        const SizedBox(height: 13),

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
              style:
                  GoogleFonts.poppins(
                fontSize: 10.5,
                fontWeight:
                    FontWeight.w600,
                letterSpacing: 3.7,
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
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final double availableWidth =
        MediaQuery.sizeOf(context)
                .width *
            0.86;

    return Scaffold(
      backgroundColor:
          Colors.black,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration:
            const BoxDecoration(
          gradient: RadialGradient(
            center:
                Alignment(0, -0.08),
            radius: 1.10,
            colors: <Color>[
              Color(0xFF29292C),
              Color(0xFF151517),
              Color(0xFF050505),
            ],
            stops: <double>[
              0.0,
              0.55,
              1.0,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child:
                AnimatedBuilder(
              animation:
                  _controller,
              builder: (
                BuildContext context,
                Widget? child,
              ) {
                return Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: <Widget>[
                    SizedBox(
                      width:
                          availableWidth,
                      height: 205,
                      child: FittedBox(
                        fit:
                            BoxFit.contain,
                        alignment:
                            Alignment
                                .center,
                        child:
                            _buildLogoAnimation(),
                      ),
                    ),

                    const SizedBox(
                      height: 5,
                    ),

                    _buildTagline(),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}