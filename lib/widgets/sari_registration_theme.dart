import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color sariInk = Color(0xFF29241F);
const Color sariGold = Color(0xFFBB8531);
const Color sariGoldDeep = Color(0xFF95641F);
const Color sariMuted = Color(0xFF82776B);
const Color sariLine = Color(0xFFE2C9A4);

/// Same image and layering across Buyer / Rider / Logistics registration.
class SariRegistrationArtwork extends StatelessWidget {
  const SariRegistrationArtwork({super.key});
  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      const ColoredBox(color: Color(0xFFF9F3EA)),
      Image.asset(
        'assets/images/sari_register_background.png',
        alignment: Alignment.center,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) =>
            const ColoredBox(color: Color(0xFFF9F3EA)),
      ),
      const IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [Color(0x16FFFFFF), Color(0x07FFF9F0), Color(0x2DFFF5E7)],
            ),
          ),
        ),
      ),
    ],
  );
}

class SariRegistrationBackdrop extends StatelessWidget {
  const SariRegistrationBackdrop({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [const Positioned.fill(child: SariRegistrationArtwork()), child],
  );
}

/// Shared frosted glass with soft gold border and glow. Still readable and tappable.
class SariGlassPanel extends StatelessWidget {
  const SariGlassPanel({super.key, required this.child,
    this.padding = const EdgeInsets.all(17), this.radius = 22});
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius);
    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: const [
          BoxShadow(color: Color(0x32C49754), blurRadius: 24, spreadRadius: -7),
          BoxShadow(color: Color(0x1F281607), blurRadius: 22, offset: Offset(0, 9)),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 9, sigmaY: 9),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              gradient: const LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [Color(0xE6FFFFFF), Color(0xDBFFFDF7), Color(0xD3F8EEDD)],
              ),
              border: Border.all(color: const Color(0xC2D3AE71), width: 1.25),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Matching top bars for every role, respecting the safe area of the host Scaffold.
class SariRegistrationTopBar extends StatelessWidget {
  const SariRegistrationTopBar({super.key, required this.title, required this.onBack});
  final String title;
  final VoidCallback onBack;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(10, 6, 16, 7),
    child: Row(children: [
      IconButton(
        tooltip: 'Back', onPressed: onBack,
        icon: const Icon(Icons.arrow_back_rounded, color: sariInk),
      ),
      Expanded(child: Text(title, textAlign: TextAlign.center,
        style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w800,
          color: sariInk, letterSpacing: -.2))),
      const SizedBox(width: 44),
    ]),
  );
}

class SariRegistrationIntro extends StatelessWidget {
  const SariRegistrationIntro({super.key, required this.eyebrow,
    required this.title, required this.description, required this.icon});
  final String eyebrow;
  final String title;
  final String description;
  final IconData icon;
  @override
  Widget build(BuildContext context) => SariGlassPanel(
    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
    child: Row(children: [
      Container(width: 44, height: 44, alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFFFFEAC6), Color(0xFFF9F1DE)]),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: const Color(0xFFECCB92)),
        ),
        child: Icon(icon, size: 22, color: sariGoldDeep),
      ),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(eyebrow.toUpperCase(), style: GoogleFonts.dmSans(fontSize: 8,
          fontWeight: FontWeight.w900, letterSpacing: 1.5, color: sariGoldDeep)),
        const SizedBox(height: 3),
        Text(title, style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w800,
          color: sariInk)),
        const SizedBox(height: 3),
        Text(description, style: GoogleFonts.dmSans(fontSize: 10, height: 1.35,
          color: sariMuted)),
      ])),
    ]),
  );
}

class SariRegistrationProgress extends StatelessWidget {
  const SariRegistrationProgress({super.key, required this.step,
    required this.labels});
  final int step;
  final List<String> labels;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Row(children: List.generate(labels.length, (i) => Expanded(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          height: 5,
          margin: EdgeInsets.only(right: i == labels.length - 1 ? 0 : 6),
          decoration: BoxDecoration(
            color: i <= step ? sariGold : const Color(0xFFE4D7C3),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ))),
      const SizedBox(height: 9),
      Text('Step ${step + 1} of ${labels.length}  •  ${labels[step]}',
        style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w700,
          color: sariMuted)),
    ],
  );
}

class SariSectionHeading extends StatelessWidget {
  const SariSectionHeading({super.key, required this.title, required this.subtitle});
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(children: [
        Container(width: 4, height: 21,
          decoration: BoxDecoration(color: sariGold, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 9),
        Expanded(child: Text(title, style: GoogleFonts.dmSans(fontSize: 16,
          fontWeight: FontWeight.w800, color: sariInk))),
      ]),
      const SizedBox(height: 5),
      Text(subtitle, style: GoogleFonts.dmSans(fontSize: 10.2,
        height: 1.45, color: sariMuted)),
    ],
  );
}

class SariRegistrationSection extends StatelessWidget {
  const SariRegistrationSection({super.key, required this.title,
    required this.subtitle, required this.children});
  final String title;
  final String subtitle;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => SariGlassPanel(
    padding: const EdgeInsets.all(17),
    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      SariSectionHeading(title: title, subtitle: subtitle),
      const SizedBox(height: 15),
      ...children,
    ]),
  );
}
