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
  static const Color _field = Color(0xFF222226);
  static const Color _border = Color(0xFF34343A);
  static const Color _gold = Color(0xFFD7A72C);
  static const Color _muted = Color(0xFFAAAAB2);

  static const String _tokenKey = 'sari_access_token';
  static const String _roleKey = 'sari_account_role';

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
      tokenProvider: () {
        return _secureStorage.read(key: _tokenKey);
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
      final SariJson response = await _api.login(
        role: _selectedRole,
        email: _emailController.text.trim().toLowerCase(),
        password: _passwordController.text,
        deviceName: 'SARI Flutter Android',
      );

      final Object? rawData = response['data'];

      if (rawData is! Map) {
        throw const SariApiException(
          'The server returned an invalid login response.',
        );
      }

      final Map<String, dynamic> data =
          Map<String, dynamic>.from(rawData);

      final String token =
          (data['access_token'] ?? data['token'])
                  ?.toString()
                  .trim() ??
              '';

      if (token.isEmpty) {
        throw const SariApiException(
          'The server did not return an access token.',
        );
      }

      final String role =
          (data['role'] ?? response['role'] ?? _selectedRole)
              .toString()
              .trim()
              .toLowerCase();

      await _secureStorage.write(
        key: _tokenKey,
        value: token,
      );

      await _secureStorage.write(
        key: _roleKey,
        value: role,
      );

      if (!mounted) {
        return;
      }

      final String route;

      switch (role) {
        case 'rider':
        case 'courier':
          route = '/rider';
          break;

        case 'logistics':
          route = '/logistics';
          break;

        case 'buyer':
          route = '/buyer';
          break;

        default:
          await _secureStorage.delete(key: _tokenKey);
          await _secureStorage.delete(key: _roleKey);

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
        message = 'Incorrect email, password, or account type.';
      } else if (error.isForbidden) {
        message =
            'This account is not allowed to access the mobile app.';
      } else if (error.isValidationError) {
        message = error.message;
      }

      _showMessage(message);
    } catch (_) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Unable to connect to SARI. Check your internet connection and try again.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSigningIn = false;
        });
      }
    }
  }

  void _continueAsGuest() {
    FocusScope.of(context).unfocus();

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/buyer',
      (Route<dynamic> route) => false,
    );
  }

  void _createAccount() {
    Navigator.pushNamed(
      context,
      '/register',
    );
  }

  void _forgotPassword() {
    _showMessage(
      'Password reset will be connected in the next update.',
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF29292D),
        ),
      );
  }

  InputDecoration _decoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xFF73737B),
        fontSize: 13,
      ),
      prefixIcon: Icon(
        icon,
        color: const Color(0xFF94949C),
        size: 20,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: _field,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: _border,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: _gold,
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
      errorStyle: const TextStyle(
        color: Color(0xFFFF8A8A),
      ),
    );
  }

  Widget _buildRoleSelector() {
    return DropdownButtonFormField<String>(
      value: _selectedRole,
      dropdownColor: _field,
      iconEnabledColor: const Color(0xFF9999A1),
      style: const TextStyle(
        color: Colors.white,
        fontSize: 13,
      ),
      decoration: _decoration(
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
          return 'Please select your account type.';
        }

        return null;
      },
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
                center: Alignment(0, -0.7),
                radius: 1.2,
                colors: <Color>[
                  Color(0xFF303035),
                  Color(0xFF151518),
                  Color(0xFF08080A),
                ],
                stops: <double>[
                  0,
                  0.52,
                  1,
                ],
              ),
            ),
          ),
          Positioned(
            top: -110,
            right: -90,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.04),
                ),
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
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    28,
                    20,
                    24,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 52,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 430,
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment:
                                CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Center(
                                child: Container(
                                  width: 94,
                                  height: 94,
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF111113),
                                    borderRadius:
                                        BorderRadius.circular(26),
                                    border: Border.all(
                                      color:
                                          Colors.white.withOpacity(0.08),
                                    ),
                                    boxShadow: <BoxShadow>[
                                      BoxShadow(
                                        color:
                                            Colors.black.withOpacity(0.45),
                                        blurRadius: 30,
                                        offset: const Offset(0, 14),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius:
                                        BorderRadius.circular(20),
                                    child: Image.asset(
                                      'assets/images/sari-logo.png',
                                      fit: BoxFit.contain,
                                      errorBuilder: (
                                        BuildContext context,
                                        Object error,
                                        StackTrace? stackTrace,
                                      ) {
                                        return const Center(
                                          child: Text(
                                            'S',
                                            style: TextStyle(
                                              color: _gold,
                                              fontSize: 48,
                                              fontWeight:
                                                  FontWeight.bold,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              const Text(
                                'SARI',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 5,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'ELEVATED EVERYDAY',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFF929299),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 2.5,
                                ),
                              ),
                              const SizedBox(height: 28),
                              Container(
                                padding: const EdgeInsets.fromLTRB(
                                  20,
                                  24,
                                  20,
                                  20,
                                ),
                                decoration: BoxDecoration(
                                  color: _surface.withOpacity(0.96),
                                  borderRadius:
                                      BorderRadius.circular(24),
                                  border: Border.all(
                                    color:
                                        Colors.white.withOpacity(0.07),
                                  ),
                                  boxShadow: <BoxShadow>[
                                    BoxShadow(
                                      color:
                                          Colors.black.withOpacity(0.35),
                                      blurRadius: 35,
                                      offset: const Offset(0, 14),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: <Widget>[
                                    const Text(
                                      'Welcome back',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 25,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    const Text(
                                      'Sign in using your SARI account',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: _muted,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
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
                                    const SizedBox(height: 16),
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
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                      decoration: _decoration(
                                        hint: 'you@example.com',
                                        icon:
                                            Icons.mail_outline_rounded,
                                      ),
                                      validator: (String? value) {
                                        final String email =
                                            value?.trim() ?? '';

                                        if (email.isEmpty) {
                                          return 'Please enter your email.';
                                        }

                                        final RegExp emailPattern =
                                            RegExp(
                                          r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                                        );

                                        if (!emailPattern
                                            .hasMatch(email)) {
                                          return 'Enter a valid email address.';
                                        }

                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),
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
                                      ),
                                      onFieldSubmitted: (_) {
                                        _login();
                                      },
                                      decoration: _decoration(
                                        hint: 'Enter your password',
                                        icon:
                                            Icons.lock_outline_rounded,
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
                                                ? Icons
                                                    .visibility_outlined
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
                                          return 'Please enter your password.';
                                        }

                                        return null;
                                      },
                                    ),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        onPressed: _isSigningIn
                                            ? null
                                            : _forgotPassword,
                                        child: const Text(
                                          'Forgot password?',
                                          style: TextStyle(
                                            color: _gold,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 51,
                                      child: ElevatedButton(
                                        onPressed: _isSigningIn
                                            ? null
                                            : _login,
                                        style:
                                            ElevatedButton.styleFrom(
                                          backgroundColor: _gold,
                                          foregroundColor:
                                              const Color(0xFF141414),
                                          disabledBackgroundColor:
                                              const Color(0xFF5E5130),
                                          elevation: 0,
                                          shape:
                                              RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                        ),
                                        child: _isSigningIn
                                            ? const SizedBox(
                                                width: 21,
                                                height: 21,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: Colors.white,
                                                ),
                                              )
                                            : const Text(
                                                'Sign In',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight:
                                                      FontWeight.w700,
                                                ),
                                              ),
                                      ),
                                    ),
                                    const SizedBox(height: 17),
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
                                                  .withOpacity(0.45),
                                              fontSize: 9,
                                              fontWeight:
                                                  FontWeight.w600,
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
                                    const SizedBox(height: 17),
                                    SizedBox(
                                      height: 49,
                                      child: OutlinedButton.icon(
                                        onPressed: _isSigningIn
                                            ? null
                                            : _continueAsGuest,
                                        icon: const Icon(
                                          Icons.storefront_outlined,
                                          size: 19,
                                        ),
                                        label: const Text(
                                          'Continue as Guest',
                                        ),
                                        style:
                                            OutlinedButton.styleFrom(
                                          foregroundColor:
                                              Colors.white,
                                          side: const BorderSide(
                                            color: _border,
                                          ),
                                          shape:
                                              RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        const Text(
                                          'No account yet?',
                                          style: TextStyle(
                                            color: _muted,
                                            fontSize: 11,
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: _isSigningIn
                                              ? null
                                              : _createAccount,
                                          child: const Text(
                                            'Create account',
                                            style: TextStyle(
                                              color: _gold,
                                              fontSize: 11,
                                              fontWeight:
                                                  FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
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