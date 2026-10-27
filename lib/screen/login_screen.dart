import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const Color sariGold = Color(0xFFD48F08);
  static const Color sariDark = Color(0xFF211C16);
  static const Color sariMuted = Color(0xFF786E62);
  static const Color sariBorder = Color(0xFFE7DED1);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isSigningIn = false;

  // Local demo accounts for testing.
  static const Map<String, Map<String, String>> _accounts = {
    'buyer@sari.com': {
      'password': 'Buyer123!',
      'route': '/buyer',
    },
    'rider@sari.com': {
      'password': 'Rider123!',
      'route': '/rider',
    },
    'logistics@sari.com': {
      'password': 'Logistics123!',
      'route': '/logistics',
    },
  };

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSigningIn = true;
    });

    await Future<void>.delayed(
      const Duration(milliseconds: 500),
    );

    if (!mounted) {
      return;
    }

    final String email = _emailController.text.trim().toLowerCase();
    final String password = _passwordController.text;

    final Map<String, String>? account = _accounts[email];

    if (account == null || account['password'] != password) {
      setState(() {
        _isSigningIn = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Incorrect email or password.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

      return;
    }

    final String route = account['route']!;

    Navigator.pushReplacementNamed(
      context,
      route,
    );
  }

  void _continueAsGuest() {
    FocusScope.of(context).unfocus();

    Navigator.pushReplacementNamed(
      context,
      '/buyer',
    );
  }

  void _createAccount() {
    Navigator.pushNamed(
      context,
      '/register',
    );
  }

  void _forgotPassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Password reset will be available soon.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xFFA49A8E),
        fontSize: 13,
      ),
      prefixIcon: Icon(
        icon,
        color: const Color(0xFF9B8D7B),
        size: 20,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFFFFDFC),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 15,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: sariBorder,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: sariGold,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.redAccent,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.redAccent,
          width: 1.5,
        ),
      ),
    );
  }

  Widget _backgroundCircle({
    required double size,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.16),
        border: Border.all(
          color: Colors.white.withOpacity(0.20),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFFFCF7),
                  Color(0xFFF7EBD3),
                  Color(0xFFE7B451),
                ],
                stops: [
                  0.0,
                  0.62,
                  1.0,
                ],
              ),
            ),
          ),

          Positioned(
            top: -90,
            right: -80,
            child: _backgroundCircle(
              size: 250,
            ),
          ),

          Positioned(
            bottom: -120,
            left: -80,
            child: _backgroundCircle(
              size: 300,
            ),
          ),

          SafeArea(
            child: LayoutBuilder(
              builder: (
                BuildContext context,
                BoxConstraints constraints,
              ) {
                return SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    22,
                    20,
                    24,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 46,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 430,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 92,
                              height: 92,
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: const Color(0xFF17130F),
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF6E4500,
                                    ).withOpacity(0.25),
                                    blurRadius: 28,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.asset(
                                  'assets/images/sari-logo.png',
                                  fit: BoxFit.cover,
                                  errorBuilder: (
                                    BuildContext context,
                                    Object error,
                                    StackTrace? stackTrace,
                                  ) {
                                    return const Center(
                                      child: Text(
                                        'S',
                                        style: TextStyle(
                                          color: Color(0xFFFFD67A),
                                          fontSize: 48,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            const Text(
                              'SARI',
                              style: TextStyle(
                                color: sariDark,
                                fontSize: 23,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 5,
                              ),
                            ),

                            const SizedBox(height: 18),

                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.fromLTRB(
                                22,
                                24,
                                22,
                                22,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.96),
                                borderRadius: BorderRadius.circular(26),
                                border: Border.all(
                                  color: Colors.white,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF725119,
                                    ).withOpacity(0.13),
                                    blurRadius: 35,
                                    offset: const Offset(0, 14),
                                  ),
                                ],
                              ),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    const Text(
                                      'Welcome back',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: sariDark,
                                        fontSize: 25,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),

                                    const SizedBox(height: 5),

                                    const Text(
                                      'Sign in to continue to your Sari account',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: sariMuted,
                                        fontSize: 12,
                                      ),
                                    ),

                                    const SizedBox(height: 22),

                                    const Text(
                                      'Email address',
                                      style: TextStyle(
                                        color: sariDark,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),

                                    const SizedBox(height: 7),

                                    TextFormField(
                                      controller: _emailController,
                                      keyboardType:
                                          TextInputType.emailAddress,
                                      textInputAction:
                                          TextInputAction.next,
                                      decoration: _inputDecoration(
                                        hint: 'you@example.com',
                                        icon: Icons.mail_outline_rounded,
                                      ),
                                      validator: (String? value) {
                                        final String email =
                                            value?.trim() ?? '';

                                        if (email.isEmpty) {
                                          return 'Please enter your email.';
                                        }

                                        final RegExp emailPattern = RegExp(
                                          r'^[^@]+@[^@]+\.[^@]+$',
                                        );

                                        if (!emailPattern.hasMatch(email)) {
                                          return 'Please enter a valid email.';
                                        }

                                        return null;
                                      },
                                    ),

                                    const SizedBox(height: 15),

                                    const Text(
                                      'Password',
                                      style: TextStyle(
                                        color: sariDark,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),

                                    const SizedBox(height: 7),

                                    TextFormField(
                                      controller: _passwordController,
                                      obscureText: _obscurePassword,
                                      textInputAction:
                                          TextInputAction.done,
                                      onFieldSubmitted: (
                                        String value,
                                      ) {
                                        _login();
                                      },
                                      decoration: _inputDecoration(
                                        hint: 'Enter your password',
                                        icon: Icons.lock_outline_rounded,
                                        suffixIcon: IconButton(
                                          tooltip: _obscurePassword
                                              ? 'Show password'
                                              : 'Hide password',
                                          onPressed: () {
                                            setState(() {
                                              _obscurePassword =
                                                  !_obscurePassword;
                                            });
                                          },
                                          icon: Icon(
                                            _obscurePassword
                                                ? Icons.visibility_outlined
                                                : Icons
                                                    .visibility_off_outlined,
                                            color: const Color(0xFF94887A),
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                      validator: (String? value) {
                                        if ((value ?? '').isEmpty) {
                                          return 'Please enter your password.';
                                        }

                                        return null;
                                      },
                                    ),

                                    const SizedBox(height: 8),

                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: Checkbox(
                                            value: _rememberMe,
                                            activeColor: sariGold,
                                            onChanged: (bool? value) {
                                              setState(() {
                                                _rememberMe =
                                                    value ?? false;
                                              });
                                            },
                                          ),
                                        ),

                                        const SizedBox(width: 5),

                                        const Text(
                                          'Remember me',
                                          style: TextStyle(
                                            color: sariMuted,
                                            fontSize: 11,
                                          ),
                                        ),

                                        const Spacer(),

                                        TextButton(
                                          onPressed: _forgotPassword,
                                          child: const Text(
                                            'Forgot password?',
                                            style: TextStyle(
                                              color: Color(0xFFA86B06),
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 8),

                                    SizedBox(
                                      height: 50,
                                      child: ElevatedButton(
                                        onPressed: _isSigningIn
                                            ? null
                                            : _login,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: sariGold,
                                          foregroundColor: Colors.white,
                                          disabledBackgroundColor:
                                              sariGold.withOpacity(0.60),
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(14),
                                          ),
                                        ),
                                        child: _isSigningIn
                                            ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: Colors.white,
                                                ),
                                              )
                                            : const Text(
                                                'Sign In',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight:
                                                      FontWeight.w700,
                                                ),
                                              ),
                                      ),
                                    ),

                                    const SizedBox(height: 14),

                                    const Row(
                                      children: [
                                        Expanded(
                                          child: Divider(
                                            color: sariBorder,
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 12,
                                          ),
                                          child: Text(
                                            'OR',
                                            style: TextStyle(
                                              color: sariMuted,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Divider(
                                            color: sariBorder,
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 14),

                                    SizedBox(
                                      height: 48,
                                      child: OutlinedButton.icon(
                                        onPressed: _continueAsGuest,
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: sariDark,
                                          side: const BorderSide(
                                            color: sariBorder,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(14),
                                          ),
                                        ),
                                        icon: const Icon(
                                          Icons.person_outline_rounded,
                                          size: 20,
                                        ),
                                        label: const Text(
                                          'Continue as Guest',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 18),

                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Text(
                                          "Don't have an account? ",
                                          style: TextStyle(
                                            color: sariMuted,
                                            fontSize: 11,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: _createAccount,
                                          child: const Text(
                                            'Create one',
                                            style: TextStyle(
                                              color: Color(0xFFA86B06),
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 17),

                            Text(
                              '© ${DateTime.now().year} Sari. '
                              'All rights reserved.',
                              style: TextStyle(
                                color: sariDark.withOpacity(0.62),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}