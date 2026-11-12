import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';

import '../config/api_config.dart';
import '../services/sari_api.dart';
import 'mobile_password_reset_screen.dart';

// Complete replacement for lib/screen/login_screen.dart.
// Uses assets/images/sari_login_background.png.
// Google sign-in remains a UI placeholder until API OAuth is implemented.

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  static const Color _background = Color(0xFFF8F4EE);
  static const Color _ink = Color(0xFF28241F);
  static const Color _muted = Color(0xFF817A74);
  static const Color _border = Color(0xFFE8DED2);
  static const Color _goldDark = Color(0xFFAA7418);

  static const String _tokenKey = 'sari_access_token';
  static const String _roleKey = 'sari_account_role';

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _storage = const FlutterSecureStorage();

  late final SariApi _api;
  late final AnimationController _entrance;

  String _role = 'buyer';
  bool _obscurePassword = true;
  bool _signingIn = false;

  @override
  void initState() {
    super.initState();
    _api = SariApi(
      baseUrl: ApiConfig.apiBaseUrl,
      timeout: const Duration(seconds: 15),
      tokenProvider: () => _storage.read(key: _tokenKey),
    );
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _entrance.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _api.dispose();
    super.dispose();
  }

  Future<void> _clearSession() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _roleKey);
  }

  Future<void> _signIn() async {
    FocusScope.of(context).unfocus();
    if (_signingIn || !(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _signingIn = true);

    try {
      final SariJson response = await _api.login(
        role: _role,
        email: _emailController.text.trim().toLowerCase(),
        password: _passwordController.text,
        deviceName: 'SARI Flutter Android',
      );
      final rawData = response['data'];
      if (rawData is! Map) {
        throw const SariApiException('Invalid login response from server.');
      }
      final data = Map<String, dynamic>.from(rawData);
      final token = (data['access_token'] ?? data['token'] ?? '')
          .toString()
          .trim();
      final rawUser = data['user'];
      if (token.isEmpty || rawUser is! Map) {
        throw const SariApiException(
          'Login response is missing account details.',
        );
      }
      final user = Map<String, dynamic>.from(rawUser);
      final role = (user['role'] ?? data['role'] ?? _role)
          .toString()
          .trim()
          .toLowerCase();

      await _storage.write(key: _tokenKey, value: token);
      await _storage.write(key: _roleKey, value: role);

      try {
        final SariJson checked = await _api.me();
        final verifiedData = checked['data'];
        if (verifiedData is! Map || verifiedData['user'] is! Map) {
          throw const SariApiException('Unable to verify your session.');
        }
        final verifiedUser = Map<String, dynamic>.from(
          verifiedData['user'] as Map,
        );
        final verifiedRole = (verifiedUser['role'] ?? role)
            .toString()
            .trim()
            .toLowerCase();
        if (verifiedRole != role) {
          throw const SariApiException(
            'Account role does not match the session.',
          );
        }
      } catch (_) {
        await _clearSession();
        rethrow;
      }

      final String route;
      switch (role) {
        case 'buyer':
          route = '/buyer';
          break;
        case 'rider':
        case 'courier':
          route = '/rider';
          break;
        case 'logistics':
          route = '/logistics';
          break;
        default:
          await _clearSession();
          throw SariApiException('Unsupported mobile role: $role');
      }

      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(route, (_) => false);
    } on SariApiException catch (error) {
      if (!mounted) return;
      _showMessage(
        error.isUnauthorized
            ? 'Incorrect email, password, or account type.'
            : error.isForbidden
            ? 'This account cannot access the mobile app.'
            : error.isValidationError
            ? 'Please review your login details.'
            : error.message,
        isError: true,
      );
    } catch (error, stackTrace) {
      debugPrint('SARI LOGIN ERROR: $error');
      debugPrintStack(label: 'SARI LOGIN STACK', stackTrace: stackTrace);
      if (mounted) {
        _showMessage('Unable to sign in. Please try again.', isError: true);
      }
    } finally {
      if (mounted) setState(() => _signingIn = false);
    }
  }

  void _forgotPassword() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const MobilePasswordResetScreen(),
      ),
    );
  }

  void _googleSignIn() {
    _showMessage(
      'Google sign-in is not connected yet. Use email and password.',
    );
  }

  void _showMessage(String text, {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
          behavior: SnackBarBehavior.floating,
          backgroundColor: isError ? const Color(0xFFB44D44) : _ink,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  // VISUAL SYSTEM — premium details without extra panels or clutter.
  InputDecoration _fieldDecoration(
    String hint,
    IconData icon, {
    Widget? suffix,
  }) {
    OutlineInputBorder outline(Color color, double width) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: width),
    );
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.dmSans(color: _muted, fontSize: 12.4),
      isDense: true,
      filled: true,
      fillColor: const Color(0xE0FFFDF9),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      prefixIcon: Padding(
        padding: const EdgeInsets.only(left: 9, right: 7),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFF5E7), Color(0xFFF3E5D0)],
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFF0DEC4)),
          ),
          child: Icon(icon, color: _goldDark, size: 17),
        ),
      ),
      prefixIconConstraints: const BoxConstraints(minWidth: 52, minHeight: 44),
      suffixIcon: suffix,
      enabledBorder: outline(_border, 1),
      focusedBorder: outline(_goldDark, 1.5),
      errorBorder: outline(const Color(0xFFB7564E), 1),
      focusedErrorBorder: outline(const Color(0xFFB7564E), 1.5),
    );
  }

  Widget _fieldLabel(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      title,
      style: GoogleFonts.dmSans(
        color: _ink,
        fontSize: 11.6,
        fontWeight: FontWeight.w700,
      ),
    ),
  );

  Widget _roleOption(String value, String label, IconData icon) {
    final selected = _role == value;
    return Expanded(
      child: Semantics(
        selected: selected,
        button: true,
        label: '$label account',
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: _signingIn ? null : () => setState(() => _role = value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            height: 51,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: selected
                    ? const [Color(0xFFFFEFD0), Color(0xFFFFF8EA)]
                    : const [Colors.white, Color(0xFFF9F6F1)],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected ? _goldDark : _border,
                width: selected ? 1.3 : 1,
              ),
              boxShadow: selected
                  ? const [
                      BoxShadow(
                        color: Color(0x20C79A50),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Stack(
              children: [
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 25,
                        width: 25,
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xFFF3D9A8)
                              : const Color(0xFFF3EFE9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          icon,
                          size: 15,
                          color: selected ? _goldDark : _muted,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.dmSans(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: selected ? const Color(0xFF825A24) : _muted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (selected)
                  Positioned(
                    right: 6,
                    top: 5,
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: _goldDark,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _goldDivider() => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Container(width: 24, height: 1, color: const Color(0xFFE1CDAA)),
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 7),
        width: 5,
        height: 5,
        transform: Matrix4.rotationZ(.785398),
        decoration: const BoxDecoration(color: _goldDark),
      ),
      Container(width: 24, height: 1, color: const Color(0xFFE1CDAA)),
    ],
  );

  Widget _googleMark() => ShaderMask(
    shaderCallback: (bounds) => const LinearGradient(
      colors: [
        Color(0xFF4285F4),
        Color(0xFFEA4335),
        Color(0xFFFBBC05),
        Color(0xFF34A853),
      ],
      stops: [0, .36, .68, 1],
    ).createShader(bounds),
    child: const Text(
      'G',
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w900,
        fontSize: 22,
      ),
    ),
  );

  Widget _floatingCard(bool compact) {
    final gap = compact ? 10.0 : 14.0;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(29),
        border: Border.all(color: const Color(0xD7D6AE66), width: 1.5),
        boxShadow: const [
          // A restrained gold halo around the glass card.
          BoxShadow(
            color: Color(0x35C89B48),
            blurRadius: 23,
            spreadRadius: 1.0,
            offset: Offset.zero,
          ),
          BoxShadow(
            color: Color(0x220B0804),
            offset: Offset(0, 14),
            blurRadius: 32,
            spreadRadius: -12,
          ),
          BoxShadow(
            color: Color(0x18BC924B),
            offset: Offset(0, 5),
            blurRadius: 18,
            spreadRadius: -5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8.5, sigmaY: 8.5),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0xB8DDBE80), width: 1.15),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xC6FFFFFF), // 78% opaque
                  Color(0xBFFFFEFC), // 75% opaque
                  Color(0xB7FBF5EB), // 72% opaque
                ],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -95,
                  right: -74,
                  child: IgnorePointer(
                    child: Container(
                      width: 210,
                      height: 210,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [Color(0x27E2BF80), Color(0x00FFFFFF)],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 64,
                  right: 64,
                  child: Container(
                    height: 2,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0x00C18B36),
                          Color(0xFFCA9A49),
                          Color(0x00C18B36),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    18,
                    compact ? 15 : 20,
                    18,
                    compact ? 10 : 16,
                  ),
                  child: Form(
                    key: _formKey,
                    child: AutofillGroup(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Sign in to SARI',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.dmSans(
                              fontSize: compact ? 23 : 26,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -.9,
                              height: 1.08,
                              color: _ink,
                            ),
                          ),
                          const SizedBox(height: 11),
                          _goldDivider(),
                          SizedBox(height: compact ? 13 : 19),
                          _fieldLabel('Account type'),
                          Row(
                            children: [
                              _roleOption(
                                'buyer',
                                'Buyer',
                                Icons.shopping_bag_outlined,
                              ),
                              const SizedBox(width: 6),
                              _roleOption(
                                'rider',
                                'Rider',
                                Icons.two_wheeler_outlined,
                              ),
                              const SizedBox(width: 6),
                              _roleOption(
                                'logistics',
                                'Logistics',
                                Icons.local_shipping_outlined,
                              ),
                            ],
                          ),
                          SizedBox(height: gap),
                          _fieldLabel('Email address'),
                          TextFormField(
                            controller: _emailController,
                            enabled: !_signingIn,
                            autocorrect: false,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.email],
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              color: _ink,
                            ),
                            decoration: _fieldDecoration(
                              'you@example.com',
                              Icons.mail_outline_rounded,
                            ),
                            validator: (value) {
                              final email = (value ?? '').trim();
                              if (email.isEmpty)
                                return 'Enter your email address.';
                              if (!RegExp(
                                r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                              ).hasMatch(email)) {
                                return 'Enter a valid email address.';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: gap),
                          _fieldLabel('Password'),
                          TextFormField(
                            controller: _passwordController,
                            enabled: !_signingIn,
                            obscureText: _obscurePassword,
                            keyboardType: TextInputType.visiblePassword,
                            textInputAction: TextInputAction.done,
                            autofillHints: const [AutofillHints.password],
                            onFieldSubmitted: (_) => _signIn(),
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              color: _ink,
                            ),
                            decoration: _fieldDecoration(
                              'Enter your password',
                              Icons.lock_outline_rounded,
                              suffix: IconButton(
                                tooltip: _obscurePassword
                                    ? 'Show password'
                                    : 'Hide password',
                                constraints: const BoxConstraints(
                                  minWidth: 42,
                                  minHeight: 42,
                                ),
                                onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: _muted,
                                  size: 19,
                                ),
                              ),
                            ),
                            validator: (value) => (value ?? '').isEmpty
                                ? 'Enter your password.'
                                : null,
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _signingIn ? null : _forgotPassword,
                              style: TextButton.styleFrom(
                                minimumSize: const Size(0, 30),
                                visualDensity: VisualDensity.compact,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 2,
                                ),
                              ),
                              child: Text(
                                'Forgot password?',
                                style: GoogleFonts.dmSans(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: _goldDark,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            height: compact ? 45 : 49,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFFB98528), Color(0xFFE3B754)],
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x39BD8D31),
                                  blurRadius: 13,
                                  offset: Offset(0, 6),
                                ),
                              ],
                            ),
                            child: FilledButton(
                              onPressed: _signingIn ? null : _signIn,
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                disabledBackgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: _signingIn
                                  ? const SizedBox(
                                      width: 19,
                                      height: 19,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Sign in',
                                          style: GoogleFonts.dmSans(
                                            fontSize: 13.8,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        const SizedBox(width: 9),
                                        const Icon(
                                          Icons.arrow_forward_rounded,
                                          size: 16,
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                          SizedBox(height: compact ? 10 : 14),
                          Row(
                            children: [
                              const Expanded(child: Divider(color: _border)),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: Text(
                                  'OR',
                                  style: GoogleFonts.dmSans(
                                    color: _muted,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                              const Expanded(child: Divider(color: _border)),
                            ],
                          ),
                          SizedBox(height: compact ? 10 : 14),
                          SizedBox(
                            height: compact ? 44 : 47,
                            child: OutlinedButton(
                              onPressed: _signingIn ? null : _googleSignIn,
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: _ink,
                                side: const BorderSide(
                                  color: Color(0xFFDCC9A7),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _googleMark(),
                                  const SizedBox(width: 9),
                                  Flexible(
                                    child: Text(
                                      'Continue with Google',
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.dmSans(
                                        fontSize: 12.8,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: compact ? 4 : 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'New to SARI?',
                                style: GoogleFonts.dmSans(
                                  color: _muted,
                                  fontSize: 11.5,
                                ),
                              ),
                              Flexible(
                                child: TextButton(
                                  onPressed: _signingIn
                                      ? null
                                      : () => Navigator.pushNamed(
                                          context,
                                          '/register',
                                        ),
                                  style: TextButton.styleFrom(
                                    visualDensity: VisualDensity.compact,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 7,
                                    ),
                                  ),
                                  child: Text(
                                    'Create an account',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w800,
                                      color: _goldDark,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ), // Stack
          ), // Translucent Container
        ), // BackdropFilter
      ),
    );
  }

  Widget _footer() => Padding(
    padding: const EdgeInsets.fromLTRB(0, 14, 0, 15),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(width: 22, height: 1, color: const Color(0xFFDEBD7B)),
        const SizedBox(width: 12),
        Text(
          'B U Y   •   S E L L   •   D E L I V E R',
          style: GoogleFonts.dmSans(
            color: const Color(0xFF98774B),
            fontSize: 9.0,
            letterSpacing: 1.3,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(width: 12),
        Container(width: 22, height: 1, color: const Color(0xFFDEBD7B)),
      ],
    ),
  );

  // Full-screen SARI artwork is the background; no separate hero image.
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFFFAEEE2),
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFFF7EADC),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: _background,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final viewport = constraints.maxHeight;
              final compact = viewport < 750;
              // Reserve space for the SARI logo drawn inside the image.
              final logoClearance = (viewport * .225)
                  .clamp(138.0, 185.0)
                  .toDouble();

              return Stack(
                fit: StackFit.expand,
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      'assets/images/sari_login_background.png',
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      filterQuality: FilterQuality.high,
                      errorBuilder: (context, error, stackTrace) {
                        return const ColoredBox(
                          color: Color(0xFFF8EFE5),
                          child: Center(child: Text('SARI')),
                        );
                      },
                    ),
                  ),
                  // Fine wash helps the glass card blend into the artwork.
                  Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: const [0, .26, .7, 1],
                            colors: [
                              Colors.transparent,
                              Colors.transparent,
                              const Color(0xFFFFF7EC).withValues(alpha: .05),
                              const Color(0xFFFFF5E8).withValues(alpha: .11),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 480),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minHeight: viewport),
                          child: IntrinsicHeight(
                            child: Column(
                              children: [
                                SizedBox(height: logoClearance),
                                AnimatedBuilder(
                                  animation: _entrance,
                                  builder: (context, child) {
                                    final t = Curves.easeOutCubic.transform(
                                      _entrance.value,
                                    );
                                    return Opacity(
                                      opacity: .20 + .80 * t,
                                      child: Transform.translate(
                                        offset: Offset(0, 18 * (1 - t)),
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: _floatingCard(compact),
                                ),
                                const Spacer(),
                                _footer(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
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
