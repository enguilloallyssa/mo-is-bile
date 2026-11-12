import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config/api_config.dart';
import '../services/sari_api.dart';
import 'sari_splash_visual.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  static const String _tokenKey = 'sari_access_token';
  static const String _roleKey = 'sari_account_role';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  late final SariApi _api;
  late final Future<String> _sessionRouteFuture;
  late final AnimationController _reveal;
  late final AnimationController _exit;
  bool _openingLogin = false;
  bool _started = false;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _api = SariApi(
      baseUrl: ApiConfig.apiBaseUrl,
      timeout: const Duration(seconds: 10),
      tokenProvider: () => _storage.read(key: _tokenKey),
    );
    _sessionRouteFuture = Future<String>.sync(_resolveSessionRoute)
        .then<String>(
          (route) => route,
          onError: (Object error, StackTrace stackTrace) => '/welcome',
        );
    _reveal = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000),
    );
    _exit = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _precacheThenRun(MediaQuery.disableAnimationsOf(context));
  }

  Future<void> _precacheThenRun(bool reducedMotion) async {
    // Load the actual letter images BEFORE advancing the animation clock.
    // Otherwise early letter movements may be skipped during image decoding.
    const logoAssets = <String>[
      'assets/images/sari_onboarding/letter_s.png',
      'assets/images/sari_onboarding/letter_a.png',
      'assets/images/sari_onboarding/letter_r.png',
      'assets/images/sari_onboarding/letter_i.png',
      'assets/images/sari_onboarding/original_tagline.png',
    ];

    for (final path in logoAssets) {
      try {
        await precacheImage(AssetImage(path), context);
      } catch (error) {
        debugPrint('SARI SPLASH ASSET ERROR ($path): $error');
      }
      if (!mounted) return;
    }

    // Start loading the welcome gallery before it becomes visible.
    for (final file in <String>[
      'fashion.jpg',
      'beauty.jpg',
      'tech.jpg',
      'home.jpg',
      'lifestyle.jpg',
      'accessories.jpg',
      'food.jpg',
      'sports.jpg',
    ]) {
      // Do not delay logo animation waiting for gallery photos.
      precacheImage(AssetImage('assets/images/sari_onboarding/$file'), context);
    }
    if (!mounted) return;
    await _runSplash(reducedMotion);
  }

  Future<void> _runSplash(bool reducedMotion) async {
    if (reducedMotion) {
      _reveal.value = 1;
    } else {
      await _reveal.forward(from: 0);
    }
    if (!mounted) return;
    setState(() => _ready = true);

    final route = await _sessionRouteFuture;
    if (!mounted) return;
    if (route != '/welcome') _navigate(route);
  }

  // Explicitly animate the old screen OUT before opening Login.
  // This avoids an invisible/double-opacity transition on some devices.
  Future<void> _openLogin() async {
    if (!mounted || _openingLogin || !_ready) return;
    setState(() => _openingLogin = true);
    await _exit.forward();
    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LoginScreen(),
        transitionDuration: const Duration(milliseconds: 480),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final eased = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: eased,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, .025),
                end: Offset.zero,
              ).animate(eased),
              child: child,
            ),
          );
        },
      ),
      (_) => false,
    );
  }

  void _navigate(String route) {
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(route, (_) => false);
  }

  Future<String> _resolveSessionRoute() async {
    final String token = (await _storage.read(key: _tokenKey) ?? '').trim();

    final String storedRole = (await _storage.read(key: _roleKey) ?? '')
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

      final Map<String, dynamic> data = Map<String, dynamic>.from(rawData);

      final dynamic rawUser = data['user'];

      if (rawUser is! Map) {
        await _clearSession();
        return '/welcome';
      }

      final Map<String, dynamic> user = Map<String, dynamic>.from(rawUser);

      final String serverRole = (user['role'] ?? data['role'] ?? storedRole)
          .toString()
          .trim()
          .toLowerCase();

      final String? route = _routeForRole(serverRole);

      if (route == null) {
        await _clearSession();
        return '/welcome';
      }

      await _storage.write(key: _roleKey, value: serverRole);

      return route;
    } on SariApiException catch (error) {
      // Invalid / revoked token.
      if (error.isUnauthorized) {
        await _clearSession();
        return '/welcome';
      }

      // Do not erase a valid token just because
      // the backend is temporarily unreachable.
      final String? fallback = _routeForRole(storedRole);

      if (fallback != null) {
        return fallback;
      }

      return '/welcome';
    } catch (error, stackTrace) {
      debugPrint('SARI SESSION RESTORE ERROR: $error');

      debugPrintStack(label: 'SESSION RESTORE STACK', stackTrace: stackTrace);

      final String? fallback = _routeForRole(storedRole);

      if (fallback != null) {
        return fallback;
      }

      return '/welcome';
    }
  }

  String? _routeForRole(String role) {
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
    await _storage.delete(key: _tokenKey);

    await _storage.delete(key: _roleKey);
  }

  @override
  void dispose() {
    _exit.dispose();
    _reveal.dispose();
    _api.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: _ready ? Brightness.dark : Brightness.light,
        statusBarBrightness: _ready ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: _ready
            ? const Color(0xFFF9F8F5)
            : const Color(0xFF111210),
        systemNavigationBarIconBrightness: _ready
            ? Brightness.dark
            : Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: _ready
            ? const Color(0xFFF8F4EE)
            : const Color(0xFF111210),
        body: AnimatedBuilder(
          animation: Listenable.merge([_reveal, _exit]),
          builder: (context, child) {
            final fade = Curves.easeInOutCubic.transform(_exit.value);
            return Opacity(
              opacity: 1 - fade,
              child: Transform.translate(
                offset: Offset(0, -14 * fade),
                child: IgnorePointer(
                  ignoring: _openingLogin,
                  child: SariSplashVisual(
                    progress: _reveal.value,
                    ready: _ready,
                    onGetStarted: _openLogin,
                    onExplore: () => _navigate('/buyer'),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
