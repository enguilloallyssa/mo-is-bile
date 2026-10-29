import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static const Color _gold = Color(0xFFD4A62A);
  static const Color _background = Color(0xFF09090B);
  static const Color _surface = Color(0xFF18181C);
  static const Color _border = Color(0xFF34343A);
  static const Color _muted = Color(0xFFAAAAB2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.65),
                radius: 1.15,
                colors: <Color>[
                  Color(0xFF35353A),
                  Color(0xFF17171A),
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
            right: -100,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -140,
            left: -120,
            child: Container(
              width: 310,
              height: 310,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _gold.withOpacity(0.08),
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
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    24,
                    20,
                    28,
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
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Container(
                                  width: 48,
                                  height: 48,
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF121214),
                                    borderRadius:
                                        BorderRadius.circular(14),
                                    border: Border.all(
                                      color:
                                          Colors.white.withOpacity(0.07),
                                    ),
                                  ),
                                  child: Image.asset(
                                    'assets/images/sari_s.png',
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
                                            fontSize: 27,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'Sari',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.6,
                                      ),
                                    ),
                                    Text(
                                      'ELEVATED EVERYDAY',
                                      style: TextStyle(
                                        color: Color(0xFF929299),
                                        fontSize: 7,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 1.6,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 50),
                            const Text(
                              'Local finds.\nReliable delivery.',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 37,
                                height: 1.08,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -1.1,
                              ),
                            ),
                            const SizedBox(height: 15),
                            const Text(
                              'Discover products from verified sellers '
                              'and follow every parcel from checkout '
                              'to your doorstep.',
                              style: TextStyle(
                                color: Color(0xFFC1C1C7),
                                fontSize: 13,
                                height: 1.6,
                              ),
                            ),
                            const SizedBox(height: 38),
                            Container(
                              padding: const EdgeInsets.fromLTRB(
                                19,
                                22,
                                19,
                                19,
                              ),
                              decoration: BoxDecoration(
                                color: _surface.withOpacity(0.97),
                                borderRadius:
                                    BorderRadius.circular(25),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.07),
                                ),
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.38),
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
                                    'Welcome to SARI',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Browse as a guest or sign in to '
                                    'access your orders, messages, '
                                    'and rider tools.',
                                    style: TextStyle(
                                      color: _muted,
                                      fontSize: 11.5,
                                      height: 1.55,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    height: 52,
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        Navigator
                                            .pushNamedAndRemoveUntil(
                                          context,
                                          '/buyer',
                                          (
                                            Route<dynamic> route,
                                          ) =>
                                              false,
                                        );
                                      },
                                      style:
                                          ElevatedButton.styleFrom(
                                        backgroundColor: _gold,
                                        foregroundColor:
                                            const Color(0xFF131313),
                                        elevation: 0,
                                        shape:
                                            RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                      ),
                                      icon: const Icon(
                                        Icons.storefront_outlined,
                                      ),
                                      label: const Text(
                                        'Continue as Guest',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 11),
                                  SizedBox(
                                    height: 50,
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        Navigator.pushNamed(
                                          context,
                                          '/login',
                                        );
                                      },
                                      style:
                                          OutlinedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        side: const BorderSide(
                                          color: _border,
                                        ),
                                        shape:
                                            RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                      ),
                                      icon: const Icon(
                                        Icons.login_rounded,
                                      ),
                                      label: const Text(
                                        'Sign In',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 7),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pushNamed(
                                        context,
                                        '/register',
                                      );
                                    },
                                    child: const Text(
                                      'Create a SARI account',
                                      style: TextStyle(
                                        color: _gold,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 25),
                            const Text(
                              'BUY • SELL • DELIVER',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF72727A),
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2.8,
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