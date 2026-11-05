import 'package:flutter/material.dart';

/// Shared visual tokens for the SARI Buyer module.
///
/// Gamitin ito sa Buyer pages para consistent ang:
/// - colors
/// - cards
/// - radius
/// - shadows
/// - accents
class BuyerTheme {
  const BuyerTheme._();

  // ============================================================
  // BRAND
  // ============================================================

  static const Color gold =
      Color(0xFFD49A32);

  static const Color goldDark =
      Color(0xFFA96B0B);

  static const Color goldLight =
      Color(0xFFFFF0CE);

  static const Color goldPale =
      Color(0xFFFFF8EA);

  // ============================================================
  // TEXT
  // ============================================================

  static const Color ink =
      Color(0xFF222B38);

  static const Color inkCool =
      Color(0xFF283241);

  static const Color body =
      Color(0xFF576274);

  static const Color muted =
      Color(0xFF8390A0);

  // ============================================================
  // SURFACES
  // ============================================================

  static const Color canvas =
      Color(0xFFF5F7FB);

  static const Color surface =
      Colors.white;

  static const Color border =
      Color(0xFFE7EAF0);

  // ============================================================
  // STATUS
  // ============================================================

  static const Color danger =
      Color(0xFFC84141);

  static const Color success =
      Color(0xFF228762);

  static const Color successSoft =
      Color(0xFFE7F7EF);

  static const Color blue =
      Color(0xFF4A75CA);

  static const Color blueSoft =
      Color(0xFFEAF1FF);

  // ============================================================
  // SIZING
  // ============================================================

  static const double cardRadius = 20;

  static const double controlRadius = 14;

  // ============================================================
  // HERO
  // ============================================================

  static const List<Color> heroGradient = <Color>[
    Color(0xFF1F2B3C),
    Color(0xFF364253),
    Color(0xFF635331),
  ];

  // ============================================================
  // CARD STYLE
  // ============================================================

  static BoxDecoration card({
    double radius = cardRadius,
  }) {
    return BoxDecoration(
      color: surface,
      borderRadius: BorderRadius.circular(
        radius,
      ),
      border: Border.all(
        color: border,
      ),
      boxShadow: const <BoxShadow>[
        BoxShadow(
          color: Color(0x120B233F),
          blurRadius: 26,
          offset: Offset(0, 10),
        ),
        BoxShadow(
          color: Color(0x06D49A32),
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ],
    );
  }
}