import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config/api_config.dart';
import '../services/sari_api.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const Color _background = Color(0xFF0B0B0D);
  static const Color _surface = Color(0xFF18181B);
  static const Color _surfaceLight = Color(0xFF202024);
  static const Color _field = Color(0xFF222226);
  static const Color _border = Color(0xFF34343A);
  static const Color _gold = Color(0xFFD7A72C);
  static const Color _goldLight = Color(0xFFF0C85B);
  static const Color _muted = Color(0xFFAAAAB2);

  static const String _tokenKey = 'sari_access_token';
  static const String _roleKey = 'sari_account_role';

  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  final FlutterSecureStorage _secureStorage =
      const FlutterSecureStorage();

  late final SariApi _api;

  String _selectedRole = 'buyer';

  bool _obscurePassword = true;
  bool _isSigningIn = false;

  @override
  void initState() {
    super.initState();

    _api = SariApi(
      baseUrl: ApiConfig.apiBaseUrl,
      timeout: const Duration(seconds: 15),
      tokenProvider: () async {
        return _secureStorage.read(
          key: _tokenKey,
        );
      },
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _api.dispose();

    super.dispose();
  }

  // ============================================================
  // LOGIN
  // ============================================================

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    if (_isSigningIn) {
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isSigningIn = true;
    });

    try {
      /*
       * IMPORTANT:
       *
       * Laravel MobileAuthController currently requires:
       *
       * role
       * email
       * password
       * device_name
       *
       * The returned Sanctum access token is then used by
       * both Buyer and Rider APIs.
       */
      final SariJson response = await _api.login(
        role: _selectedRole,
        email: _emailController.text
            .trim()
            .toLowerCase(),
        password: _passwordController.text,
        deviceName: 'SARI Flutter Android',
      );

      final dynamic rawData = response['data'];

      if (rawData is! Map) {
        throw const SariApiException(
          'The server returned an invalid login response.',
        );
      }

      final Map<String, dynamic> data =
          Map<String, dynamic>.from(rawData);

      final String token =
          (data['access_token'] ??
                  data['token'] ??
                  '')
              .toString()
              .trim();

      if (token.isEmpty) {
        throw const SariApiException(
          'The server did not return an access token.',
        );
      }

      final dynamic rawUser = data['user'];

      if (rawUser is! Map) {
        throw const SariApiException(
          'The server did not return the account profile.',
        );
      }

      final Map<String, dynamic> user =
          Map<String, dynamic>.from(rawUser);

      final String role =
          (user['role'] ??
                  data['role'] ??
                  _selectedRole)
              .toString()
              .trim()
              .toLowerCase();

      // --------------------------------------------------------
      // SAVE TOKEN FIRST
      // --------------------------------------------------------

      await _secureStorage.write(
        key: _tokenKey,
        value: token,
      );

      await _secureStorage.write(
        key: _roleKey,
        value: role,
      );

      /*
       * Verify the newly issued token against Laravel.
       *
       * This prevents the app from navigating to Buyer/Rider
       * when the token cannot actually authenticate.
       */
      try {
        final SariJson verifyResponse =
            await _api.me();

        final dynamic verifyData =
            verifyResponse['data'];

        if (verifyData is! Map) {
          throw const SariApiException(
            'Unable to verify the mobile session.',
          );
        }

        final dynamic verifiedUser =
            verifyData['user'];

        if (verifiedUser is! Map) {
          throw const SariApiException(
            'Unable to verify the account.',
          );
        }

        final String verifiedRole =
            (verifiedUser['role'] ?? role)
                .toString()
                .trim()
                .toLowerCase();

        if (verifiedRole != role) {
          await _secureStorage.delete(
            key: _tokenKey,
          );

          await _secureStorage.delete(
            key: _roleKey,
          );

          throw const SariApiException(
            'The account role returned by the server does not match the mobile session.',
          );
        }
      } catch (_) {
        await _secureStorage.delete(
          key: _tokenKey,
        );

        await _secureStorage.delete(
          key: _roleKey,
        );

        rethrow;
      }

      if (!mounted) {
        return;
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
          await _secureStorage.delete(
            key: _tokenKey,
          );

          await _secureStorage.delete(
            key: _roleKey,
          );

          throw SariApiException(
            'Unsupported account role: $role',
          );
      }

      if (!mounted) {
        return;
      }

      Navigator.pushNamedAndRemoveUntil(
        context,
        route,
        (Route<dynamic> route) => false,
      );
    } on SariApiException catch (error) {
      if (!mounted) {
        return;
      }

      String message = error.message;

      if (error.isUnauthorized) {
        message =
            'Incorrect email, password, or selected account type.';
      } else if (error.isForbidden) {
        message =
            'This account is not allowed to access the mobile app.';
      } else if (error.isValidationError) {
        message =
            'Please check your login information and try again.';
      }

      _showMessage(
        message,
        error: true,
      );
    } catch (error, stackTrace) {
      debugPrint(
        'SARI LOGIN ERROR: $error',
      );

      debugPrintStack(
        label: 'SARI LOGIN STACK',
        stackTrace: stackTrace,
      );

      if (!mounted) {
        return;
      }

      _showMessage(
        'Unable to sign in right now. Please try again.',
        error: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSigningIn = false;
        });
      }
    }
  }

  // ============================================================
  // GUEST
  // ============================================================

  Future<void> _continueAsGuest() async {
    FocusScope.of(context).unfocus();

    /*
     * Very important:
     *
     * Remove an old authenticated token before entering
     * guest mode.
     *
     * Without this, a previous Rider/Buyer session can
     * accidentally remain available while the UI says Guest.
     */
    await _secureStorage.delete(
      key: _tokenKey,
    );

    await _secureStorage.delete(
      key: _roleKey,
    );

    if (!mounted) {
      return;
    }

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/buyer',
      (Route<dynamic> route) => false,
    );
  }

  void _createAccount() {
    if (_isSigningIn) {
      return;
    }

    Navigator.pushNamed(
      context,
      '/register',
    );
  }

  void _forgotPassword() {
    _showMessage(
      'Password reset is not connected to the mobile API yet.',
    );
  }

  // ============================================================
  // UI HELPERS
  // ============================================================

  void _showMessage(
    String message, {
    bool error = false,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: <Widget>[
              Icon(
                error
                    ? Icons.error_outline_rounded
                    : Icons.info_outline_rounded,
                color: Colors.white,
                size: 19,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: error
              ? const Color(0xFFB43B3B)
              : const Color(0xFF29292D),
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }

  InputDecoration _fieldDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xFF74747C),
        fontSize: 13,
      ),
      prefixIcon: Icon(
        icon,
        color: const Color(0xFF9999A1),
        size: 20,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: _field,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 17,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: _border,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: _gold,
          width: 1.4,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: Color(0xFFE45C5C),
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: Color(0xFFE45C5C),
          width: 1.4,
        ),
      ),
      errorStyle: const TextStyle(
        color: Color(0xFFFF9696),
        fontSize: 11,
      ),
    );
  }

  Widget _buildRoleSelector() {
    return DropdownButtonFormField<String>(
      value: _selectedRole,
      dropdownColor: _surfaceLight,
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: _muted,
      ),
      style: const TextStyle(
        color: Colors.white,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      decoration: _fieldDecoration(
        hint: 'Select account type',
        icon: Icons.person_outline_rounded,
      ),
      items: const <DropdownMenuItem<String>>[
        DropdownMenuItem<String>(
          value: 'buyer',
          child: Text('Buyer'),
        ),
        DropdownMenuItem<String>(
          value: 'rider',
          child: Text('Rider'),
        ),
        DropdownMenuItem<String>(
          value: 'logistics',
          child: Text('Logistics'),
        ),
      ],
      onChanged: _isSigningIn
          ? null
          : (String? value) {
              if (value == null) {
                return;
              }

              setState(() {
                _selectedRole = value;
              });
            },
      validator: (String? value) {
        if (value == null || value.isEmpty) {
          return 'Select your account type.';
        }

        return null;
      },
    );
  }

  Widget _buildHeader() {
    return Column(
      children: <Widget>[
        Container(
          width: 74,
          height: 74,
          decoration: BoxDecoration(
            color: _gold,
            borderRadius: BorderRadius.circular(23),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: _gold.withOpacity(0.23),
                blurRadius: 30,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'S',
              style: TextStyle(
                color: Color(0xFF111111),
                fontSize: 35,
                fontWeight: FontWeight.w900,
                letterSpacing: -2,
              ),
            ),
          ),
        ),
        const SizedBox(height: 22),
        const Text(
          'Welcome back',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 27,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Sign in to continue to SARI',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _muted,
            fontSize: 13,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surface.withOpacity(0.94),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.055),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.30),
            blurRadius: 34,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Account type',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            _buildRoleSelector(),

            const SizedBox(height: 18),

            const Text(
              'Email address',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            TextFormField(
              controller: _emailController,
              enabled: !_isSigningIn,
              keyboardType:
                  TextInputType.emailAddress,
              textInputAction:
                  TextInputAction.next,
              autocorrect: false,
              enableSuggestions: false,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
              decoration: _fieldDecoration(
                hint: 'you@example.com',
                icon: Icons.mail_outline_rounded,
              ),
              validator: (String? value) {
                final String email =
                    (value ?? '').trim();

                if (email.isEmpty) {
                  return 'Enter your email address.';
                }

                if (!email.contains('@') ||
                    !email.contains('.')) {
                  return 'Enter a valid email address.';
                }

                return null;
              },
            ),

            const SizedBox(height: 18),

            const Text(
              'Password',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            TextFormField(
              controller: _passwordController,
              enabled: !_isSigningIn,
              obscureText: _obscurePassword,
              textInputAction:
                  TextInputAction.done,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
              onFieldSubmitted: (_) {
                _login();
              },
              decoration: _fieldDecoration(
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
                    color: const Color(
                      0xFF9999A1,
                    ),
                    size: 20,
                  ),
                ),
              ),
              validator: (String? value) {
                if ((value ?? '').isEmpty) {
                  return 'Enter your password.';
                }

                return null;
              },
            ),

            const SizedBox(height: 4),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _isSigningIn
                    ? null
                    : _forgotPassword,
                style: TextButton.styleFrom(
                  foregroundColor: _gold,
                ),
                child: const Text(
                  'Forgot password?',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 4),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed:
                    _isSigningIn ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _gold,
                  foregroundColor:
                      const Color(0xFF121212),
                  disabledBackgroundColor:
                      const Color(0xFF65562F),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(15),
                  ),
                ),
                child: _isSigningIn
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Sign In',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight:
                                  FontWeight.w800,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons
                                .arrow_forward_rounded,
                            size: 19,
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 22),

            Row(
              children: <Widget>[
                const Expanded(
                  child: Divider(
                    color: _border,
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 12,
                  ),
                  child: Text(
                    'OR',
                    style: TextStyle(
                      color: Colors.white
                          .withOpacity(0.38),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Expanded(
                  child: Divider(
                    color: _border,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: _isSigningIn
                    ? null
                    : _continueAsGuest,
                icon: const Icon(
                  Icons.storefront_outlined,
                  size: 20,
                ),
                label: const Text(
                  'Continue as Guest',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(
                    color: _border,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      resizeToAvoidBottomInset: true,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.85),
                radius: 1.35,
                colors: <Color>[
                  Color(0xFF35332B),
                  Color(0xFF17171A),
                  Color(0xFF09090B),
                ],
                stops: <double>[
                  0,
                  0.46,
                  1,
                ],
              ),
            ),
          ),

          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      _gold.withOpacity(0.08),
                ),
              ),
            ),
          ),

          Positioned(
            top: 45,
            left: -115,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _gold.withOpacity(0.025),
              ),
            ),
          ),

          SafeArea(
            child: LayoutBuilder(
              builder: (
                BuildContext context,
                BoxConstraints constraints,
              ) {
                return SingleChildScrollView(
                  padding:
                      const EdgeInsets.fromLTRB(
                    22,
                    28,
                    22,
                    28,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight:
                          constraints.maxHeight -
                              56,
                    ),
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: <Widget>[
                        _buildHeader(),

                        const SizedBox(height: 30),

                        ConstrainedBox(
                          constraints:
                              const BoxConstraints(
                            maxWidth: 470,
                          ),
                          child: _buildLoginCard(),
                        ),

                        const SizedBox(height: 24),

                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: <Widget>[
                            const Text(
                              'New to SARI?',
                              style: TextStyle(
                                color: _muted,
                                fontSize: 12,
                              ),
                            ),
                            TextButton(
                              onPressed:
                                  _isSigningIn
                                      ? null
                                      : _createAccount,
                              style:
                                  TextButton.styleFrom(
                                foregroundColor:
                                    _goldLight,
                              ),
                              child: const Text(
                                'Create account',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight:
                                      FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'SARI • Elevated Everyday',
                          style: TextStyle(
                            color: Colors.white
                                .withOpacity(0.30),
                            fontSize: 10,
                            letterSpacing: 0.7,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ],
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