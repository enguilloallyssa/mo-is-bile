import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const String _assets = 'assets/images/sari_onboarding/';

const Color _paper = Color(0xFFF8F7F3);
const Color _ink = Color(0xFF242821);
const Color _gold = Color(0xFFA78351);
const Color _muted = Color(0xFF777A74);

class SariSplashVisual extends StatefulWidget {
  const SariSplashVisual({
    super.key,
    required this.progress,
    required this.ready,
    required this.onGetStarted,
    required this.onExplore,
  });

  final double progress;
  final bool ready;
  final VoidCallback onGetStarted;
  final VoidCallback onExplore;

  @override
  State<SariSplashVisual> createState() => _SariSplashVisualState();
}

class _SariSplashVisualState extends State<SariSplashVisual> {
  double _parentInterval(double start, double end) {
    return ((widget.progress - start) / (end - start))
        .clamp(0.0, 1.0)
        .toDouble();
  }

  double _letterInterval(double start, double end) {
    return ((widget.progress - start) / (end - start))
        .clamp(0.0, 1.0)
        .toDouble();
  }

  // ============================================================
  // CURVED LETTER ANIMATION
  // ============================================================

  Offset _curvedRoute({
    required double t,
    required Offset from,
    required Offset control,
    required double wobble,
  }) {
    final double u = Curves.easeInOutCubic.transform(t);
    final double inv = 1.0 - u;

    final Offset curve = from * (inv * inv) + control * (2 * inv * u);

    final double decay = 1.0 - u;

    return curve +
        Offset(
          math.sin(u * math.pi * 2.4) * wobble * decay,
          math.sin(u * math.pi * 1.8 + 0.65) * wobble * .7 * decay,
        );
  }

  Widget _piece({
    required String file,
    required double left,
    required double sourceWidth,
    required double ratio,
    required double begin,
    required double end,
    required Offset origin,
    required Offset bend,
    required double rotation,
  }) {
    final double t = _letterInterval(begin, end);

    final double appear = Curves.easeOut.transform(
      _letterInterval(begin, begin + .05),
    );

    final Offset offset = _curvedRoute(
      t: t,
      from: origin,
      control: bend,
      wobble: 7,
    );

    final double settle = Curves.easeOutBack.transform(t);

    return Positioned(
      left: left * ratio,
      top: 0,
      width: sourceWidth * ratio,
      height: 610 * ratio,
      child: Opacity(
        opacity: appear,
        child: Transform.translate(
          offset: offset,
          child: Transform.rotate(
            angle:
                rotation * (1.0 - t) +
                math.sin(t * math.pi * 2.0) * .055 * (1 - t),
            child: Transform.scale(
              scale: .93 + .07 * settle,
              child: Image.asset(
                '$_assets$file',
                fit: BoxFit.fill,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ORIGINAL SARI LOGO INTRO
  // ============================================================

  Widget _logoIntro(BuildContext context) {
    final Size screen = MediaQuery.sizeOf(context);

    final double logoWidth = math.min(screen.width * .87, 430.0);

    final double ratio = logoWidth / 2172.0;
    final double logoHeight = 724 * ratio;

    final double exit = Curves.easeInCubic.transform(_parentInterval(.85, 1.0));

    return ColoredBox(
      color: const Color(0xFF101210),
      child: SafeArea(
        child: Builder(
          builder: (context) {
            final double tagline = Curves.easeOutCubic.transform(
              _letterInterval(.62, .72),
            );

            return Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Opacity(
                  opacity: 1.0 - exit,
                  child: Center(
                    child: Transform.scale(
                      scale: 1.0 + exit * .035,
                      child: SizedBox(
                        width: logoWidth,
                        height: logoHeight,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: <Widget>[
                            // Letter S
                            _piece(
                              file: 'letter_s.png',
                              left: 0,
                              sourceWidth: 550,
                              ratio: ratio,
                              begin: 0.0,
                              end: .28,
                              origin: const Offset(-34, -65),
                              bend: const Offset(14, 29),
                              rotation: -.19,
                            ),

                            // Letter A
                            _piece(
                              file: 'letter_a.png',
                              left: 550,
                              sourceWidth: 650,
                              ratio: ratio,
                              begin: .08,
                              end: .39,
                              origin: const Offset(60, 68),
                              bend: const Offset(-22, -30),
                              rotation: .17,
                            ),

                            // Letter R
                            _piece(
                              file: 'letter_r.png',
                              left: 1200,
                              sourceWidth: 730,
                              ratio: ratio,
                              begin: .19,
                              end: .50,
                              origin: const Offset(54, -57),
                              bend: const Offset(-18, 26),
                              rotation: -.16,
                            ),

                            // Letter I
                            _piece(
                              file: 'letter_i.png',
                              left: 1930,
                              sourceWidth: 242,
                              ratio: ratio,
                              begin: .29,
                              end: .60,
                              origin: const Offset(-45, 61),
                              bend: const Offset(19, -25),
                              rotation: .18,
                            ),

                            // Original SARI tagline only
                            Positioned(
                              left: 0,
                              top: 610 * ratio,
                              width: logoWidth,
                              height: 114 * ratio,
                              child: Opacity(
                                opacity: tagline,
                                child: Transform.translate(
                                  offset: Offset(0, (1.0 - tagline) * 12),
                                  child: Image.asset(
                                    '${_assets}original_tagline.png',
                                    fit: BoxFit.fill,
                                    filterQuality: FilterQuality.high,
                                  ),
                                ),
                              ),
                            ),
                          ],
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
    );
  }

  // ============================================================
  // PREMIUM WELCOME SCREEN
  // ============================================================

  Widget _welcome(BuildContext context) {
    return ColoredBox(
      color: _paper,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double availableHeight = constraints.maxHeight;

            final bool compact = availableHeight < 690;
            final bool veryCompact = availableHeight < 550;

            final double headingSize = veryCompact ? 29 : (compact ? 33 : 40);

            final double italicSize = veryCompact ? 32 : (compact ? 36 : 43);

            final double headerHeight = veryCompact ? 49 : 61;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: SizedBox(
                  height: availableHeight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      // =================================================
                      // FULL SARI WORDMARK
                      // =================================================
                      SizedBox(
                        height: headerHeight,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 5, 24, 4),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Image.asset(
                              'assets/images/sari-logo.png',
                              width: 117,
                              height: 40,
                              fit: BoxFit.contain,
                              alignment: Alignment.centerLeft,
                              color: _ink,
                              colorBlendMode: BlendMode.srcIn,
                              filterQuality: FilterQuality.high,
                            ),
                          ),
                        ),
                      ),

                      // =================================================
                      // CONTINUOUSLY SCROLLING PRODUCT GALLERY
                      // =================================================
                      const Expanded(child: _SeamlessCategoryGallery()),

                      // =================================================
                      // WELCOME MESSAGE AND ACTIONS
                      // =================================================
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 720),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, (1 - value) * 14),
                              child: child,
                            ),
                          );
                        },
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            22,
                            veryCompact ? 0 : 2,
                            22,
                            veryCompact ? 2 : 8,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              // =================================================
                              // HEADLINE
                              // =================================================
                              Text(
                                'Everyday finds,',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.instrumentSerif(
                                  fontSize: headingSize,
                                  height: .99,
                                  color: _ink,
                                ),
                              ),

                              Text(
                                'made special.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.instrumentSerif(
                                  fontSize: italicSize,
                                  fontStyle: FontStyle.italic,
                                  height: .99,
                                  color: _gold,
                                ),
                              ),

                              SizedBox(height: veryCompact ? 7 : 11),

                              // =================================================
                              // DESCRIPTION
                              // =================================================
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 325,
                                ),
                                child: Text(
                                  'Find your style, discover local favorites, '
                                  'and make room for the little things that '
                                  'make every day feel special. Only at SARI.',
                                  textAlign: TextAlign.center,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.dmSans(
                                    color: _muted,
                                    fontSize: veryCompact
                                        ? 10
                                        : (compact ? 10.5 : 11.2),
                                    height: 1.45,
                                    letterSpacing: .05,
                                  ),
                                ),
                              ),

                              SizedBox(
                                height: veryCompact ? 11 : (compact ? 15 : 20),
                              ),

                              // =================================================
                              // GET STARTED BUTTON - NO ARROW
                              // =================================================
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: const <BoxShadow>[
                                    BoxShadow(
                                      color: Color(0x18242821),
                                      blurRadius: 17,
                                      offset: Offset(0, 7),
                                    ),
                                  ],
                                ),
                                child: SizedBox(
                                  height: veryCompact ? 46 : 52,
                                  width: double.infinity,
                                  child: FilledButton(
                                    onPressed: widget.onGetStarted,
                                    style: FilledButton.styleFrom(
                                      backgroundColor: _ink,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 17,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                    child: Text(
                                      'Get started',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.dmSans(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13.5,
                                        letterSpacing: .1,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // =================================================
                              // EXPLORE AS GUEST
                              // =================================================
                              SizedBox(
                                height: veryCompact ? 37 : 43,
                                child: TextButton(
                                  onPressed: widget.onExplore,
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    foregroundColor: _muted,
                                  ),
                                  child: Text(
                                    'Explore SARI as a guest',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 11.3,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.ready ? _welcome(context) : _logoIntro(context);
  }
}

// ============================================================
// CATEGORY MODEL
// ============================================================

class _Category {
  const _Category(this.asset, this.title);

  final String asset;
  final String title;
}

// ============================================================
// SEAMLESS SCROLLING CATEGORY GALLERY
// ============================================================

class _SeamlessCategoryGallery extends StatefulWidget {
  const _SeamlessCategoryGallery();

  @override
  State<_SeamlessCategoryGallery> createState() =>
      _SeamlessCategoryGalleryState();
}

class _SeamlessCategoryGalleryState extends State<_SeamlessCategoryGallery>
    with TickerProviderStateMixin {
  late final AnimationController _leftScroll;
  late final AnimationController _rightScroll;
  late final AnimationController _entrance;

  // All eight SARI shopping categories.
  static const List<_Category> _left = <_Category>[
    _Category('fashion.jpg', 'FASHION'),
    _Category('accessories.jpg', 'ACCESSORIES'),
    _Category('home.jpg', 'HOME'),
    _Category('sports.jpg', 'SPORTS'),
  ];

  static const List<_Category> _right = <_Category>[
    _Category('beauty.jpg', 'BEAUTY'),
    _Category('tech.jpg', 'ELECTRONICS'),
    _Category('lifestyle.jpg', 'LIFESTYLE'),
    _Category('food.jpg', 'FOOD'),
  ];

  @override
  void initState() {
    super.initState();

    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1050),
    )..forward();

    _leftScroll = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();

    _rightScroll = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 21),
    )..repeat();
  }

  @override
  void dispose() {
    _entrance.dispose();
    _leftScroll.dispose();
    _rightScroll.dispose();

    super.dispose();
  }

  // ============================================================
  // VERTICAL SCROLLING LANE
  // ============================================================

  Widget _lane({
    required List<_Category> categories,
    required double x,
    required double laneWidth,
    required double height,
    required double progress,
    required bool startLeft,
  }) {
    final double cardHeight = (height * .45).clamp(105.0, 205.0).toDouble();

    const double gap = 14.0;

    final double stride = cardHeight + gap;
    final double period = categories.length * stride;
    final double offset = progress * period;

    final double entered = Curves.easeOutCubic.transform(_entrance.value);

    return Positioned(
      left: x,
      top: 0,
      width: laneWidth,
      height: height,
      child: Opacity(
        opacity: entered,
        child: Transform.translate(
          offset: Offset(
            (startLeft ? -24.0 : 24.0) * (1 - entered),
            42 * (1 - entered),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              for (int cycle = -1; cycle <= 2; cycle++)
                for (int index = 0; index < categories.length; index++)
                  Positioned(
                    left: index.isEven ? 1 : 7,
                    right: index.isEven ? 7 : 1,
                    top:
                        (cycle * period) +
                        (index * stride) -
                        offset -
                        stride * .42,
                    height: cardHeight,
                    child: Transform.rotate(
                      angle:
                          (index.isEven ? -1 : 1) * (startLeft ? .057 : .068),
                      child: _CategoryCard(category: categories[index]),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // GALLERY BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge(<Listenable>[
        _leftScroll,
        _rightScroll,
        _entrance,
      ]),
      builder: (context, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final double w = constraints.maxWidth;
            final double h = constraints.maxHeight;
            final double laneWidth = w * .43;

            return ClipRect(
              child: Stack(
                children: <Widget>[
                  const Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: _paper),
                    ),
                  ),

                  // Left scrolling column.
                  _lane(
                    categories: _left,
                    x: w * .055,
                    laneWidth: laneWidth,
                    height: h,
                    progress: _leftScroll.value,
                    startLeft: true,
                  ),

                  // Right scrolling column.
                  _lane(
                    categories: _right,
                    x: w * .515,
                    laneWidth: laneWidth,
                    height: h,
                    progress: _rightScroll.value,
                    startLeft: false,
                  ),

                  // =================================================
                  // TOP GRADIENT
                  // =================================================
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 35,
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: <double>[0, .46, 1],
                            colors: <Color>[
                              _paper,
                              _paper.withValues(alpha: .62),
                              _paper.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // =================================================
                  // BOTTOM GRADIENT INTO WELCOME MESSAGE
                  // =================================================
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: math.min(120.0, h * .32),
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: <double>[0, .31, .68, 1],
                            colors: <Color>[
                              _paper.withValues(alpha: 0),
                              _paper.withValues(alpha: .24),
                              _paper.withValues(alpha: .83),
                              _paper,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ============================================================
// PRODUCT CATEGORY CARD
// ============================================================

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category});

  final _Category category;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFFEAE6DE),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xFFFDFCF9), width: 2.5),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x27000000),
            blurRadius: 20,
            spreadRadius: -4,
            offset: Offset(0, 9),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image.asset(
            '$_assets${category.asset}',
            fit: BoxFit.cover,
            filterQuality: FilterQuality.medium,
            errorBuilder: (context, error, stack) {
              return const ColoredBox(
                color: Color(0xFFE8E3DA),
                child: Center(child: Icon(Icons.image_outlined, color: _muted)),
              );
            },
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 27, 12, 12),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[Color(0x000C100C), Color(0xC810140F)],
                ),
              ),
              child: Text(
                category.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.dmSans(
                  color: Colors.white,
                  fontSize: 9.2,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
