import 'package:flutter/material.dart';

class RiderThemeController {
  static bool isDark = false;

  static void setDark(bool value) {
    isDark = value;
  }
}

class RiderColors {
  static bool get isDark => RiderThemeController.isDark;

  static Color get bg => isDark ? const Color(0xFF17232B) : const Color(0xFFF0F3F5);
  static Color get surface => isDark ? const Color(0xFF22313A) : const Color(0xFFF8FAFB);
  static Color get surfaceElevated => isDark ? const Color(0xFF2A3A44) : const Color(0xFFFFFFFF);
  static Color get surfaceSoft => isDark ? const Color(0xFF30414B) : const Color(0xFFE8EDF0);
  static Color get text => isDark ? const Color(0xFFF4F7F8) : const Color(0xFF1B252D);
  static Color get muted => isDark ? const Color(0xFFAEBBC3) : const Color(0xFF6E7B84);
  static Color get border => isDark ? const Color(0xFF40525D) : const Color(0xFFD3DBE0);
  static Color get nav => isDark ? const Color(0xFF1D2A32) : const Color(0xFFF8FAFB);
  static Color get field => isDark ? const Color(0xFF1E2C34) : const Color(0xFFF4F6F7);
  static Color get overlay => isDark ? const Color(0x66101A20) : const Color(0x44FFFFFF);

  static Color get gold => isDark ? const Color(0xFFF0B84A) : const Color(0xFFD9930A);
  static Color get goldDark => isDark ? const Color(0xFFFFCA68) : const Color(0xFFA96800);
  static Color get goldSoft => isDark ? const Color(0xFF4A3D28) : const Color(0xFFFFEFD0);

  static Color get blue => isDark ? const Color(0xFF7AA8C7) : const Color(0xFF3C6E91);
  static Color get blueSoft => isDark ? const Color(0xFF294352) : const Color(0xFFEAF2F7);

  static Color get green => isDark ? const Color(0xFF72B98C) : const Color(0xFF4F7D63);
  static Color get greenSoft => isDark ? const Color(0xFF294638) : const Color(0xFFEAF3ED);

  static Color get red => isDark ? const Color(0xFFE18484) : const Color(0xFFB95555);
  static Color get redSoft => isDark ? const Color(0xFF4B3034) : const Color(0xFFFCEDED);

  static Color get purple => isDark ? const Color(0xFFB096C6) : const Color(0xFF715A86);
  static Color get purpleSoft => isDark ? const Color(0xFF40364A) : const Color(0xFFF1EDF5);

  static List<Color> get heroGradient => isDark
      ? const [Color(0xFF1C2A33), Color(0xFF263843), Color(0xFF314752)]
      : const [Color(0xFF476F88), Color(0xFF5E8298), Color(0xFF7492A3)];

  static List<Color> get earningsGradient => isDark
      ? const [Color(0xFF24343D), Color(0xFF2D3F49)]
      : const [Color(0xFFFFFFFF), Color(0xFFF2F5F7)];
}

class RiderHeaderTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const RiderHeaderTitle({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: TextStyle(
            color: RiderColors.text,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: -.35,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: TextStyle(
            color: RiderColors.muted,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class RiderSurface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final double radius;
  final bool shadow;
  final bool elevated;

  const RiderSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color,
    this.radius = 20,
    this.shadow = false,
    this.elevated = false,
  });

  @override
  Widget build(BuildContext context) {
    final background = color ??
        (elevated ? RiderColors.surfaceElevated : RiderColors.surface);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: RiderColors.border),
        boxShadow: shadow
            ? [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: RiderColors.isDark ? .22 : .08,
                  ),
                  blurRadius: RiderColors.isDark ? 24 : 18,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: child,
    );
  }
}

class RiderStatusPill extends StatelessWidget {
  final String label;
  final Color color;
  final Color background;
  final IconData? icon;

  const RiderStatusPill({
    super.key,
    required this.label,
    required this.color,
    required this.background,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: .22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 5),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RiderSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const RiderSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: RiderColors.text,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -.2,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 3),
                Text(
                  subtitle!,
                  style: TextStyle(
                    color: RiderColors.muted,
                    fontSize: 11,
                    height: 1.35,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 10),
          trailing!,
        ],
      ],
    );
  }
}

class RiderMetricTile extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color accent;
  final Color softColor;

  const RiderMetricTile({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    required this.accent,
    required this.softColor,
  });

  @override
  Widget build(BuildContext context) {
    final iconBackground = RiderColors.isDark
        ? accent.withValues(alpha: .16)
        : softColor;

    return RiderSurface(
      padding: const EdgeInsets.all(13),
      radius: 17,
      elevated: true,
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accent, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: RiderColors.text,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: RiderColors.muted,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RiderEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const RiderEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return RiderSurface(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 34),
      elevated: true,
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: RiderColors.goldSoft,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: RiderColors.goldDark, size: 29),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: RiderColors.text,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: RiderColors.muted,
              fontSize: 11,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

Color riderStatusColor(String status) {
  if (status == 'completed' || status == 'delivered') {
    return RiderColors.green;
  }
  if (status == 'delivery_failed') {
    return RiderColors.red;
  }
  if (status.contains('sorting') || status.contains('delivery_')) {
    return RiderColors.blue;
  }
  return RiderColors.goldDark;
}

Color riderStatusSoftColor(String status) {
  if (status == 'completed' || status == 'delivered') {
    return RiderColors.greenSoft;
  }
  if (status == 'delivery_failed') {
    return RiderColors.redSoft;
  }
  if (status.contains('sorting') || status.contains('delivery_')) {
    return RiderColors.blueSoft;
  }
  return RiderColors.goldSoft;
}
