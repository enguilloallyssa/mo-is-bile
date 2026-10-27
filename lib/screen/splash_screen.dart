import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  // Original logo with black rounded background.
  static const String _logoTile =
      'assets/images/sari-logo.png';

  // Transparent gold S only.
  static const String _goldS =
      'assets/images/sari_s.png';

  static const Color _gold = Color(0xFFE5B94E);

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

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4800),
    );

    // Original tile enters.
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

    // Transparent S appears over the S inside the tile.
    _standaloneSFadeIn = _interval(
      0.27,
      0.43,
      Curves.easeInOut,
    );

    // Black tile disappears while the standalone S remains.
    _tileFadeOut = _interval(
      0.32,
      0.50,
      Curves.easeInOut,
    );

    // S moves from the center toward the left.
    _moveLeft = _interval(
      0.45,
      0.69,
      Curves.easeInOutCubic,
    );

    // "ari" slides out beside the S.
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

    // Tagline and line.
    _lineReveal = _interval(
      0.70,
      0.84,
      Curves.easeOutCubic,
    );

    _taglineFade = _interval(
      0.76,
      0.91,
      Curves.easeOut,
    );

    _controller.forward().whenComplete(() {
      if (!mounted) return;

      Navigator.of(context).pushReplacementNamed('/login');
    });
  }

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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildLogoAnimation() {
    /*
      Fixed design canvas.

      Using a fixed internal canvas prevents the S and "ari"
      from separating on different phone sizes. FittedBox scales
      the entire animation proportionally.
    */
    return SizedBox(
      width: 340,
      height: 205,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          /*
           * ORIGINAL BLACK LOGO TILE
           *
           * Centered at the beginning and fades away.
           */
          Positioned(
            left: 67,
            top: 0,
            width: 206,
            height: 206,
            child: Opacity(
              opacity: (
                _entrance.value *
                (1 - _tileFadeOut.value)
              ).clamp(0.0, 1.0),
              child: Transform.scale(
                scale: _entranceScale.value,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(45),
                    boxShadow: [
                      BoxShadow(
                        color: _gold.withOpacity(0.17),
                        blurRadius: 55,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(45),
                    child: Transform.scale(
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

          /*
           * TRANSPARENT GOLD S
           *
           * Starts on top of the S in the logo tile.
           * Then moves left while slightly resizing.
           */
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final double progress = _moveLeft.value;

              // Center position over the original tile.
              final double left = lerpDouble(
                111,
                31,
                progress,
              )!;

              final double top = lerpDouble(
                27,
                40,
                progress,
              )!;

              final double width = lerpDouble(
                118,
                108,
                progress,
              )!;

              final double height = lerpDouble(
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
                  opacity: _standaloneSFadeIn.value,
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

          /*
           * "ari"
           *
           * Positioned manually so it stays attached to the S.
           */
          Positioned(
            left: 101,
            top: 40,
            width: 220,
            height: 135,
            child: ClipRect(
              child: Align(
                alignment: Alignment.centerLeft,
                widthFactor: _ariReveal.value,
                child: Opacity(
                  opacity: _ariFade.value,
                  child: Transform.translate(
                    offset: Offset(
                      (1 - _ariReveal.value) * -25,
                      0,
                    ),
                    child: ShaderMask(
                      blendMode: BlendMode.srcIn,
                      shaderCallback: (Rect bounds) {
                        return const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFFFFE99B),
                            Color(0xFFE8BD55),
                            Color(0xFFD39C2D),
                          ],
                          stops: [0.0, 0.58, 1.0],
                        ).createShader(bounds);
                      },
                      child: Text(
                        'ari',
                        maxLines: 1,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 112,
                          fontWeight: FontWeight.w600,
                          height: 1.0,
                          letterSpacing: -4,
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

  Widget _buildTagline() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 52 * _lineReveal.value,
          height: 1.2,
          decoration: BoxDecoration(
            color: _gold.withOpacity(
              0.95 * _lineReveal.value,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(height: 13),
        Opacity(
          opacity: _taglineFade.value,
          child: Transform.translate(
            offset: Offset(
              0,
              7 * (1 - _taglineFade.value),
            ),
            child: Text(
              'ELEVATED EVERYDAY',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                letterSpacing: 3.7,
                color: const Color(0xFFE0C886),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final double availableWidth =
        MediaQuery.sizeOf(context).width * 0.86;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.08),
            radius: 1.10,
            colors: [
              Color(0xFF29292C),
              Color(0xFF151517),
              Color(0xFF050505),
            ],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: availableWidth,
                      height: 205,
                      child: FittedBox(
                        fit: BoxFit.contain,
                        alignment: Alignment.center,
                        child: _buildLogoAnimation(),
                      ),
                    ),
                    const SizedBox(height: 5),
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