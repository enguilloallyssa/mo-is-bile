import 'package:flutter/material.dart';

import 'account_registration_screen.dart';
import 'rider_logistics_screen.dart';
import 'logistics_register_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({
    super.key,
  });

  @override
  State<RegisterScreen> createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState
    extends State<RegisterScreen> {
  static const Color _background =
      Color(0xFF0B0B0D);

  static const Color _surface =
      Color(0xFF18181C);

  static const Color _surfaceLight =
      Color(0xFF222226);

  static const Color _border =
      Color(0xFF37373D);

  static const Color _gold =
      Color(0xFFD4A62A);

  static const Color _muted =
      Color(0xFFA7A7AF);

  String? _selectedRole;

  static const List<_RoleOption> _roles =
      <_RoleOption>[
    _RoleOption(
      keyName: 'buyer',
      title: 'Buyer',
      subtitle:
          'Shop products, manage your cart, track orders and message sellers.',
      icon:
          Icons.shopping_bag_outlined,
      available: true,
    ),

    _RoleOption(
      keyName: 'rider',
      title: 'Rider',
      subtitle:
          'Apply to a Logistics provider and manage pickup and delivery work.',
      icon:
          Icons.delivery_dining_outlined,
      available: true,
    ),

    _RoleOption(
      keyName: 'logistics',
      title: 'Logistics',
      subtitle:
          'Register a SARI Logistics provider account.',
      icon:
          Icons.hub_outlined,
      available: true,
    ),
  ];

  void _continue() {
    final String? role =
        _selectedRole;

    if (role == null) {
      _show(
        'Select an account type first.',
      );

      return;
    }

    if (role == 'buyer') {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) =>
              const AccountRegistrationScreen(
            role: 'buyer',
          ),
        ),
      );

      return;
    }

    if (role == 'rider') {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) =>
              const RiderLogisticsScreen(),
        ),
      );

      return;
    }

    if (role == 'logistics') {
      Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => const LogisticsRegisterScreen(),
      ));
      return;
    }
  }

  void _show(
    String message,
  ) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content:
              Text(message),
          behavior:
              SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          _background,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          const DecoratedBox(
            decoration:
                BoxDecoration(
              gradient:
                  RadialGradient(
                center:
                    Alignment(
                  0,
                  -.8,
                ),
                radius: 1.15,
                colors: <Color>[
                  Color(
                    0xFF343129,
                  ),
                  Color(
                    0xFF171719,
                  ),
                  Color(
                    0xFF09090B,
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            top: -105,
            right: -90,
            child: Container(
              width: 250,
              height: 250,
              decoration:
                  BoxDecoration(
                shape:
                    BoxShape.circle,
                border:
                    Border.all(
                  color:
                      _gold.withOpacity(
                    .07,
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child:
                SingleChildScrollView(
              padding:
                  const EdgeInsets.fromLTRB(
                17,
                8,
                17,
                30,
              ),
              child: Center(
                child:
                    ConstrainedBox(
                  constraints:
                      const BoxConstraints(
                    maxWidth: 560,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .stretch,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          IconButton(
                            onPressed: () {
                              Navigator.pop(
                                context,
                              );
                            },
                            icon:
                                const Icon(
                              Icons
                                  .arrow_back_rounded,
                              color:
                                  Colors.white,
                            ),
                          ),
                          const Expanded(
                            child: Text(
                              'Create Account',
                              textAlign:
                                  TextAlign.center,
                              style:
                                  TextStyle(
                                color:
                                    Colors.white,
                                fontSize:
                                    17,
                                fontWeight:
                                    FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 48,
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      Container(
                        width: 72,
                        height: 72,
                        alignment:
                            Alignment.center,
                        margin:
                            const EdgeInsets.symmetric(
                          horizontal:
                              220,
                        ),
                        decoration:
                            BoxDecoration(
                          color: _gold,
                          borderRadius:
                              BorderRadius.circular(
                            22,
                          ),
                        ),
                        child:
                            const Text(
                          'S',
                          style:
                              TextStyle(
                            color:
                                Colors.black,
                            fontSize:
                                33,
                            fontWeight:
                                FontWeight.w900,
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 22,
                      ),

                      const Text(
                        'Join SARI',
                        textAlign:
                            TextAlign.center,
                        style:
                            TextStyle(
                          color:
                              Colors.white,
                          fontSize: 27,
                          fontWeight:
                              FontWeight.w900,
                          letterSpacing:
                              -.7,
                        ),
                      ),

                      const SizedBox(
                        height: 7,
                      ),

                      const Text(
                        'Choose how you want to use the SARI mobile app.',
                        textAlign:
                            TextAlign.center,
                        style:
                            TextStyle(
                          color: _muted,
                          fontSize: 11,
                        ),
                      ),

                      const SizedBox(
                        height: 28,
                      ),

                      ..._roles.map(
                        _roleCard,
                      ),

                      const SizedBox(
                        height: 15,
                      ),

                      SizedBox(
                        height: 53,
                        child:
                            FilledButton(
                          onPressed:
                              _continue,
                          style:
                              FilledButton.styleFrom(
                            backgroundColor:
                                _gold,
                            foregroundColor:
                                Colors.black,
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                15,
                              ),
                            ),
                          ),
                          child:
                              const Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                'Continue',
                                style:
                                    TextStyle(
                                  fontWeight:
                                      FontWeight.w900,
                                ),
                              ),
                              SizedBox(
                                width: 7,
                              ),
                              Icon(
                                Icons
                                    .arrow_forward_rounded,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 15,
                      ),

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: <Widget>[
                          const Text(
                            'Already registered?',
                            style:
                                TextStyle(
                              color: _muted,
                              fontSize: 10,
                            ),
                          ),

                          TextButton(
                            onPressed: () {
                              Navigator.of(
                                context,
                              ).pushNamedAndRemoveUntil(
                                '/login',
                                (
                                  Route<dynamic>
                                      route,
                                ) =>
                                    false,
                              );
                            },
                            child:
                                const Text(
                              'Sign In',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _roleCard(
    _RoleOption role,
  ) {
    final bool selected =
        _selectedRole ==
            role.keyName;

    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 11,
      ),
      child: Material(
        color:
            Colors.transparent,
        child: InkWell(
          onTap: () {
            if (!role.available) {
              _show(
                'Logistics registration is not connected to the mobile API yet.',
              );

              return;
            }

            setState(() {
              _selectedRole =
                  role.keyName;
            });
          },
          borderRadius:
              BorderRadius.circular(
            18,
          ),
          child:
              AnimatedContainer(
            duration:
                const Duration(
              milliseconds: 180,
            ),
            padding:
                const EdgeInsets.all(
              15,
            ),
            decoration:
                BoxDecoration(
              color: selected
                  ? const Color(
                      0xFF2D291C,
                    )
                  : _surface,
              borderRadius:
                  BorderRadius.circular(
                18,
              ),
              border:
                  Border.all(
                color: selected
                    ? _gold
                    : _border,
                width: selected
                    ? 1.5
                    : 1,
              ),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 50,
                  height: 50,
                  alignment:
                      Alignment.center,
                  decoration:
                      BoxDecoration(
                    color: role.available
                        ? _surfaceLight
                        : const Color(
                            0xFF202024,
                          ),
                    borderRadius:
                        BorderRadius.circular(
                      15,
                    ),
                  ),
                  child: Icon(
                    role.icon,
                    color: role.available
                        ? selected
                            ? _gold
                            : Colors.white70
                        : Colors.white30,
                    size: 25,
                  ),
                ),

                const SizedBox(
                  width: 13,
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              role.title,
                              style:
                                  TextStyle(
                                color: role
                                        .available
                                    ? Colors
                                        .white
                                    : Colors
                                        .white38,
                                fontSize:
                                    14,
                                fontWeight:
                                    FontWeight
                                        .w800,
                              ),
                            ),
                          ),

                          if (!role
                              .available)
                            Container(
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal:
                                    8,
                                vertical:
                                    4,
                              ),
                              decoration:
                                  BoxDecoration(
                                color:
                                    Colors
                                        .white
                                        .withOpacity(
                                  .06,
                                ),
                                borderRadius:
                                    BorderRadius.circular(
                                  20,
                                ),
                              ),
                              child:
                                  const Text(
                                'API PENDING',
                                style:
                                    TextStyle(
                                  color:
                                      Colors.white38,
                                  fontSize:
                                      7,
                                  fontWeight:
                                      FontWeight.w800,
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(
                        height: 4,
                      ),

                      Text(
                        role.subtitle,
                        style:
                            TextStyle(
                          color: role
                                  .available
                              ? _muted
                              : Colors
                                  .white30,
                          fontSize: 9,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  width: 7,
                ),

                if (role.available)
                  Icon(
                    selected
                        ? Icons
                            .check_circle_rounded
                        : Icons
                            .chevron_right_rounded,
                    color: selected
                        ? _gold
                        : _muted,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleOption {
  final String keyName;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool available;

  const _RoleOption({
    required this.keyName,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.available,
  });
}