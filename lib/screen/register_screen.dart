import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'account_registration_screen.dart';
import 'rider_logistics_screen.dart';
import 'logistics_register_screen.dart';

/// Registration step 1. This screen only chooses the account type;
/// the existing Buyer, Rider and Logistics registration forms are unchanged.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  static const Color _ink = Color(0xFF29241F);
  static const Color _muted = Color(0xFF81756B);
  static const Color _gold = Color(0xFFBE8B35);
  static const Color _goldDeep = Color(0xFF95641F);
  static const Color _paper = Color(0xFFF9F3E9);
  static const Color _line = Color(0xFFE9DAC3);

  late final AnimationController _entrance;
  String? _selectedRole;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..forward();
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  void _openForm(Widget page) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 380),
        reverseTransitionDuration: const Duration(milliseconds: 260),
        pageBuilder: (_, animation, secondaryAnimation) => page,
        transitionsBuilder: (_, animation, secondaryAnimation, child) {
          final motion = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: motion,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(.035, .025),
                end: Offset.zero,
              ).animate(motion),
              child: child,
            ),
          );
        },
      ),
    );
  }

  void _continue() {
    switch (_selectedRole) {
      case 'buyer':
        _openForm(const AccountRegistrationScreen(role: 'buyer'));
        break;
      case 'rider':
        _openForm(const RiderLogisticsScreen());
        break;
      case 'logistics':
        _openForm(const LogisticsRegisterScreen());
        break;
      default:
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: const Text('Please choose an account type.'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: _ink,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
    }
  }

  /// The existing full SARI PNG includes "ELEVATED EVERYDAY" underneath.
  /// Showing only its top 610/724 portion retains the actual SARI letters
  /// and removes that tagline from the Join heading.
  Widget _wordmark(bool compact) {
    final width = compact ? 118.0 : 138.0;
    final fullHeight = width * 724 / 2172;
    final visibleHeight = width * 610 / 2172;

    return SizedBox(
      width: width,
      height: visibleHeight,
      child: ClipRect(
        child: Align(
          alignment: Alignment.topCenter,
          child: ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF29241F), Color(0xFF936526), Color(0xFF29241F)],
            ).createShader(bounds),
            child: Image.asset(
              'assets/images/sari-logo.png',
              width: width,
              height: fullHeight,
              fit: BoxFit.fill,
              filterQuality: FilterQuality.high,
              errorBuilder: (_, error, stack) => Text(
                'SARI',
                style: GoogleFonts.instrumentSerif(
                  color: _ink,
                  fontSize: compact ? 34 : 40,
                  height: 1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _brandTitle(bool compact) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Join',
          style: GoogleFonts.instrumentSerif(
            fontSize: compact ? 34 : 40,
            color: _ink,
            height: 1,
          ),
        ),
        const SizedBox(width: 9),
        _wordmark(compact),
      ],
    );
  }

  Widget _roleCard({
    required String keyName,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool compact,
  }) {
    final selected = _selectedRole == keyName;
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Semantics(
        button: true,
        selected: selected,
        label: '$title account',
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => setState(() => _selectedRole = keyName),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 230),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: compact ? 9 : 12,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: selected
                      ? [const Color(0xFFFFE9C5), const Color(0xFFFFFAF0)]
                      : [
                          Colors.white.withValues(alpha: .90),
                          const Color(0xFFFFFAF3).withValues(alpha: .78),
                        ],
                ),
                border: Border.all(
                  color: selected ? _gold : _line,
                  width: selected ? 1.5 : 1,
                ),
                boxShadow: selected
                    ? const [
                        BoxShadow(
                          color: Color(0x20BB8628),
                          blurRadius: 14,
                          offset: Offset(0, 5),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Container(
                    width: compact ? 41 : 46,
                    height: compact ? 41 : 46,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: selected
                            ? [const Color(0xFFE6C48A), const Color(0xFFF8E9C8)]
                            : [
                                const Color(0xFFF8EDDE),
                                const Color(0xFFF2E3CE),
                              ],
                      ),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(
                      icon,
                      color: selected ? _goldDeep : const Color(0xFF94784E),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.dmSans(
                            fontWeight: FontWeight.w800,
                            fontSize: compact ? 13.5 : 14.5,
                            color: _ink,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          subtitle,
                          maxLines: 2,
                          style: GoogleFonts.dmSans(
                            fontSize: compact ? 9.5 : 10.3,
                            height: 1.32,
                            color: _muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 5),
                  Icon(
                    selected
                        ? Icons.check_circle_rounded
                        : Icons.arrow_forward_ios_rounded,
                    size: selected ? 22 : 15,
                    color: selected ? _goldDeep : const Color(0xFFBFAF97),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _registrationCard(bool compact) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFD9AF6D), width: 1.3),
        boxShadow: const [
          BoxShadow(color: Color(0x26C8933C), blurRadius: 24),
          BoxShadow(
            color: Color(0x200B0804),
            blurRadius: 28,
            spreadRadius: -9,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(27),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 9, sigmaY: 9),
          child: Container(
            padding: EdgeInsets.fromLTRB(
              18,
              compact ? 15 : 20,
              18,
              compact ? 9 : 14,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: .83),
                  const Color(0xFFFFFCF6).withValues(alpha: .77),
                  const Color(0xFFF8EEDC).withValues(alpha: .73),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'YOUR SARI JOURNEY',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    color: _goldDeep,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.8,
                    fontSize: 9,
                  ),
                ),
                SizedBox(height: compact ? 9 : 13),
                _brandTitle(compact),
                const SizedBox(height: 8),
                Text(
                  'Choose how you want to be part of the SARI community.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    fontSize: compact ? 10 : 11,
                    color: _muted,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: compact ? 15 : 20),
                _roleCard(
                  keyName: 'buyer',
                  title: 'Buyer',
                  subtitle:
                      'Shop local finds, save favorites, and track orders.',
                  icon: Icons.shopping_bag_outlined,
                  compact: compact,
                ),
                _roleCard(
                  keyName: 'rider',
                  title: 'Rider',
                  subtitle: 'Manage pickups and deliveries as a SARI rider.',
                  icon: Icons.two_wheeler_outlined,
                  compact: compact,
                ),
                _roleCard(
                  keyName: 'logistics',
                  title: 'Logistics',
                  subtitle: 'Manage delivery hubs, teams, and operations.',
                  icon: Icons.local_shipping_outlined,
                  compact: compact,
                ),
                SizedBox(height: compact ? 5 : 8),
                Container(
                  height: compact ? 46 : 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFB88028), Color(0xFFE2B85B)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33C18E35),
                        blurRadius: 13,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: FilledButton(
                    onPressed: _continue,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Continue',
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.w800,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account?',
                      style: GoogleFonts.dmSans(fontSize: 10.5, color: _muted),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(
                        context,
                      ).pushNamedAndRemoveUntil('/login', (_) => false),
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                      ),
                      child: Text(
                        'Sign in',
                        style: GoogleFonts.dmSans(
                          fontSize: 10.8,
                          fontWeight: FontWeight.w800,
                          color: _goldDeep,
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
    );
  }

  Widget _footer() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 14, 0, 16),
      child: Text(
        'B U Y   •   S E L L   •   D E L I V E R',
        textAlign: TextAlign.center,
        style: GoogleFonts.dmSans(
          color: const Color(0xFF8E6536),
          letterSpacing: 1.15,
          fontWeight: FontWeight.w800,
          fontSize: 9,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFFF9F3E9),
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFFF9F3E9),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: _paper,
        body: Stack(
          children: [
            // Custom registration artwork, without the baked-in logo.
            // Keep the artwork fully covered behind the floating card.
            Positioned.fill(
              child: ClipRect(
                child: Transform.scale(
                  scale: 1.0,
                  alignment: Alignment.bottomCenter,
                  child: Image.asset(
                    'assets/images/sari_register_background.png',
                    fit: BoxFit.cover,
                    alignment: Alignment.bottomCenter,
                    errorBuilder: (_, error, stack) =>
                        const ColoredBox(color: _paper),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      _paper.withValues(alpha: .10),
                      _paper.withValues(alpha: .01),
                      _paper.withValues(alpha: .13),
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, bounds) {
                  final compact = bounds.maxHeight < 735;
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 480),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: bounds.maxHeight,
                          ),
                          child: IntrinsicHeight(
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    17,
                                    8,
                                    17,
                                    0,
                                  ),
                                  child: Row(
                                    children: [
                                      Material(
                                        color: Colors.white.withValues(
                                          alpha: .82,
                                        ),
                                        shape: CircleBorder(
                                          side: BorderSide(color: _line),
                                        ),
                                        child: IconButton(
                                          tooltip: 'Back',
                                          onPressed: () =>
                                              Navigator.of(context).maybePop(),
                                          icon: const Icon(
                                            Icons.arrow_back_rounded,
                                            color: _ink,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        'CREATE ACCOUNT',
                                        style: GoogleFonts.dmSans(
                                          color: _goldDeep,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: compact ? 46 : 79),
                                AnimatedBuilder(
                                  animation: _entrance,
                                  builder: (context, child) {
                                    final t = Curves.easeOutCubic.transform(
                                      _entrance.value,
                                    );
                                    return Opacity(
                                      opacity: t,
                                      child: Transform.translate(
                                        offset: Offset(0, 19 * (1 - t)),
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: _registrationCard(compact),
                                ),
                                const Spacer(),
                                _footer(),
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
      ),
    );
  }
}
