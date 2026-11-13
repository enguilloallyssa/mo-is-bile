import 'package:flutter/material.dart';
import '../../services/sari_foreground_updates.dart';

/// Shared entry point for the Rider shell's navigation drawer.
class RiderMenuController {
  static VoidCallback? open;
}

class RiderMenuButton extends StatelessWidget {
  const RiderMenuButton({
    super.key,
  });

  void _openMenu(
    BuildContext context,
  ) {
    ScaffoldState? targetScaffold;

    context.visitAncestorElements(
      (Element element) {
        final Widget widget = element.widget;

        if (widget is Scaffold &&
            widget.endDrawer != null &&
            element is StatefulElement &&
            element.state is ScaffoldState) {
          targetScaffold = element.state as ScaffoldState;
          return false;
        }

        return true;
      },
    );

    if (targetScaffold != null) {
      targetScaffold!.openEndDrawer();
      return;
    }

    final VoidCallback? callback = RiderMenuController.open;
    if (callback != null) {
      callback();
      return;
    }

    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      const SnackBar(
        content: Text('Rider menu is not connected to the current page.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Open Rider menu',
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      iconSize: 20,
      color: RiderColors.text,
      onPressed: () => _openMenu(context),
      icon: const Icon(Icons.menu_rounded),
    );
  }
}

/// Rider-only UI navigation callbacks set by RiderShell.
class RiderHeaderController {
  static VoidCallback? messages;
  static VoidCallback? notifications;
}

class RiderHeaderActions extends StatelessWidget {
  const RiderHeaderActions({super.key, this.unreadMessages = 0});

  /// Uses the existing server summary; no separate polling is introduced.
  final int unreadMessages;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: SariForegroundUpdates.instance,
          builder: (context, _) {
            final updates = SariForegroundUpdates.instance;
            return _headerIcon(
              tooltip: 'Messages', icon: Icons.chat_bubble_outline_rounded,
              onPressed: RiderHeaderController.messages,
              count: updates.loaded && updates.role == 'rider'
                  ? updates.unreadMessages : unreadMessages,
            );
          },
        ),
        const SizedBox(width: 8),
        AnimatedBuilder(
          animation: SariForegroundUpdates.instance,
          builder: (context, _) {
            final updates = SariForegroundUpdates.instance;
            return _headerIcon(
              tooltip: 'Notifications', icon: Icons.notifications_none_rounded,
              onPressed: RiderHeaderController.notifications,
              count: updates.loaded && updates.role == 'rider'
                  ? updates.unreadNotifications : 0,
            );
          },
        ),
        const SizedBox(width: 8),
        Padding(
          padding: const EdgeInsets.only(right: 4),
          child: Builder(
            builder: (context) => Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: RiderColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: RiderColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: RiderColors.isDark ? .18 : .04,
                    ),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const RiderMenuButton(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _headerIcon({
    required String tooltip,
    required IconData icon,
    required VoidCallback? onPressed,
    int count = 0,
  }) {
    return SizedBox(
      width: 40,
      height: 40,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: RiderColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: RiderColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: RiderColors.isDark ? .18 : .04,
                  ),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              tooltip: tooltip,
              onPressed: onPressed,
              padding: EdgeInsets.zero,
              icon: Icon(icon, size: 20, color: RiderColors.text),
            ),
          ),
          if (count > 0)
            Positioned(
              right: -3,
              top: -3,
              child: IgnorePointer(
                child: Container(
                  constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: RiderColors.gold,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: RiderColors.surface, width: 1.8),
                  ),
                  child: Text(
                    count > 9 ? '9+' : '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class RiderSearchField extends StatelessWidget {
  const RiderSearchField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onChanged,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        textInputAction: onSubmitted == null
            ? TextInputAction.done
            : TextInputAction.search,
        style: TextStyle(
          color: RiderColors.text,
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: RiderColors.muted,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: RiderColors.muted,
            size: 20,
          ),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Clear search',
                  icon: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: RiderColors.muted,
                  ),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                ),
          filled: true,
          fillColor: RiderColors.surface,
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: RiderColors.border),
            borderRadius: BorderRadius.circular(16),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: RiderColors.gold, width: 1.6),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
}

class RiderThemeController {
  static bool isDark = false;

  static void setDark(bool value) {
    isDark = value;
  }
}

class RiderColors {
  static bool get isDark => RiderThemeController.isDark;

  static Color get bg =>
      isDark ? const Color(0xFF121210) : const Color(0xFFF7F5F0);

  static Color get surface =>
      isDark ? const Color(0xFF1C1B18) : const Color(0xFFFFFFFF);

  static Color get surfaceElevated =>
      isDark ? const Color(0xFF24221E) : const Color(0xFFFFFFFF);

  static Color get surfaceSoft =>
      isDark ? const Color(0xFF2C2923) : const Color(0xFFF1EDE4);

  static Color get text =>
      isDark ? const Color(0xFFF6F5F2) : const Color(0xFF161513);

  static Color get muted =>
      isDark ? const Color(0xFFA39E93) : const Color(0xFF6E6A63);

  static Color get border =>
      isDark ? const Color(0xFF36322B) : const Color(0xFFE6E0D5);

  static Color get nav =>
      isDark ? const Color(0xFF1A1916) : const Color(0xFFFFFFFF);

  static Color get field =>
      isDark ? const Color(0xFF25231E) : const Color(0xFFFBF9F5);

  static Color get overlay =>
      isDark ? const Color(0x660D0D0C) : const Color(0x44FFFFFF);

  static Color get gold =>
      isDark ? const Color(0xFFF2B84B) : const Color(0xFFD4952A);

  static Color get goldDark =>
      isDark ? const Color(0xFFFFCC66) : const Color(0xFF9E6B14);

  static Color get goldSoft =>
      isDark ? const Color(0xFF3D3220) : const Color(0xFFFFF3D6);

  static Color get blue =>
      isDark ? const Color(0xFF58B4F5) : const Color(0xFF1D74B8);

  static Color get blueSoft =>
      isDark ? const Color(0xFF1D3347) : const Color(0xFFE6F2FC);

  static Color get green =>
      isDark ? const Color(0xFF4ADE80) : const Color(0xFF15803D);

  static Color get greenSoft =>
      isDark ? const Color(0xFF193827) : const Color(0xFFE3F9EB);

  static Color get red =>
      isDark ? const Color(0xFFF87171) : const Color(0xFFC83A3A);

  static Color get redSoft =>
      isDark ? const Color(0xFF422123) : const Color(0xFFFDECEC);

  static Color get purple =>
      isDark ? const Color(0xFFB794F4) : const Color(0xFF6D48C7);

  static Color get purpleSoft =>
      isDark ? const Color(0xFF322745) : const Color(0xFFF0EBFA);

  static List<Color> get heroGradient => isDark
      ? const <Color>[
          Color(0xFF181714),
          Color(0xFF27221A),
          Color(0xFF4A391E),
        ]
      : const <Color>[
          Color(0xFF181715),
          Color(0xFF2C251B),
          Color(0xFF6E501E),
        ];

  static List<Color> get earningsGradient => isDark
      ? const <Color>[
          Color(0xFF221F1A),
          Color(0xFF332B1F),
        ]
      : const <Color>[
          Color(0xFFFFFFFF),
          Color(0xFFF7F4EC),
        ];
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
      children: <Widget>[
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: RiderColors.text,
            fontSize: 17,
            fontWeight: FontWeight.w900,
            letterSpacing: -.4,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: RiderColors.muted,
            fontSize: 10.5,
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
    final Color background = color ??
        (elevated ? RiderColors.surfaceElevated : RiderColors.surface);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: RiderColors.border),
        boxShadow: (shadow || elevated)
            ? <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: RiderColors.isDark
                        ? .22
                        : (shadow ? .06 : .03),
                  ),
                  blurRadius: shadow ? 18 : 12,
                  offset: Offset(0, shadow ? 6 : 3),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: .22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
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
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: .2,
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: TextStyle(
                  color: RiderColors.text,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -.3,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: TextStyle(
                    color: RiderColors.muted,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
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
    final Color iconBackground =
        RiderColors.isDark ? accent.withValues(alpha: .16) : softColor;

    return RiderSurface(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 14),
      radius: 18,
      elevated: true,
      child: Row(
        children: <Widget>[
          RiderIconBadge(
            icon: icon,
            color: accent,
            background: iconBackground,
            size: 40,
            iconSize: 20,
            radius: 13,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: RiderColors.text,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: RiderColors.muted,
                    fontSize: 11,
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
      radius: 22,
      elevated: true,
      child: Column(
        children: <Widget>[
          RiderIconBadge(
            icon: icon,
            color: RiderColors.goldDark,
            background: RiderColors.goldSoft,
            size: 62,
            iconSize: 29,
            radius: 22,
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: RiderColors.text,
              fontSize: 15.5,
              fontWeight: FontWeight.w900,
              letterSpacing: -.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: RiderColors.muted,
              fontSize: 12,
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


/// Small, dimensional icon language shared by Rider operational pages.
/// All colors are UI-only; callers still own actions and API data.
class RiderIconBadge extends StatelessWidget {
  const RiderIconBadge({
    super.key,
    required this.icon,
    required this.color,
    this.background,
    this.size = 42,
    this.iconSize = 21,
    this.radius = 14,
  });

  final IconData icon;
  final Color color;
  final Color? background;
  final double size;
  final double iconSize;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final Color base = background ?? color.withValues(alpha: .11);
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              base,
              Color.lerp(base, RiderColors.surface, .36)!,
            ],
          ),
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: color.withValues(alpha: .10)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: .085),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Positioned(
              right: 6,
              top: 6,
              child: Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: .26),
                ),
              ),
            ),
            Icon(icon, color: color, size: iconSize),
          ],
        ),
      ),
    );
  }
}

/// Shared palette for the quick actions/drawer. No page-specific hardcoding.
Color riderIconAccent(IconData icon) {
  if (icon == Icons.local_shipping_outlined ||
      icon == Icons.local_shipping_rounded ||
      icon == Icons.route_outlined ||
      icon == Icons.navigation_outlined ||
      icon == Icons.map_outlined) return RiderColors.blue;
  if (icon == Icons.check_circle_outline_rounded ||
      icon == Icons.done_all ||
      icon == Icons.task_alt_rounded ||
      icon == Icons.verified_outlined ||
      icon == Icons.check_circle_outline) return RiderColors.green;
  if (icon == Icons.chat_bubble_outline_rounded ||
      icon == Icons.notifications_none_rounded ||
      icon == Icons.mail_outline_rounded ||
      icon == Icons.message_outlined) return RiderColors.purple;
  if (icon == Icons.logout_rounded) return RiderColors.red;
  return RiderColors.goldDark;
}

/// Titled section with the tiny gold rule used on the Rider Home overview.
class RiderKicker extends StatelessWidget {
  const RiderKicker({super.key, required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: RiderColors.goldDark,
            fontSize: 10,
            letterSpacing: 2.1,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  RiderColors.gold.withValues(alpha: .45),
                  RiderColors.gold.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}


/// Tappable action circle that matches the Home header controls.
class RiderTopActionButton extends StatelessWidget {
  const RiderTopActionButton({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.accent,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final Color tint = accent ?? RiderColors.goldDark;
    return Padding(
      padding: const EdgeInsets.only(right: 7),
      child: Container(
        width: 39,
        height: 39,
        decoration: BoxDecoration(
          color: RiderColors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: RiderColors.border),
          boxShadow: [
            BoxShadow(
              color: tint.withValues(alpha: .06),
              blurRadius: 9,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: IconButton(
          tooltip: tooltip,
          onPressed: onPressed,
          padding: EdgeInsets.zero,
          icon: Icon(icon, size: 20, color: onPressed == null ? RiderColors.muted : tint),
        ),
      ),
    );
  }
}

/// Shared light editorial hero for every Rider operational page.
/// Decorative only; the original page owns all network operations and buttons.
class RiderEditorialHero extends StatelessWidget {
  const RiderEditorialHero({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.icon,
    this.footer,
  });

  final String eyebrow;
  final String title;
  final String description;
  final IconData icon;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final bool dark = RiderColors.isDark;
    final Color accent = riderIconAccent(icon);
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: RiderColors.border),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: dark
              ? const [Color(0xFF29251E), Color(0xFF221F1A)]
              : const [Color(0xFFFFFEFB), Color(0xFFF7EFE3), Color(0xFFF9F7F2)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: dark ? .18 : .045),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -55,
            top: -54,
            child: IgnorePointer(
              child: Container(
                width: 176,
                height: 176,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: RiderColors.gold.withValues(alpha: dark ? .08 : .055),
                  border: Border.all(
                    color: RiderColors.gold.withValues(alpha: .12),
                    width: 1.2,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: -8,
            bottom: -14,
            child: IgnorePointer(
              child: Icon(
                icon,
                size: 118,
                color: accent.withValues(alpha: dark ? .055 : .038),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(17, 18, 17, 19),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    RiderIconBadge(
                      icon: icon,
                      color: accent,
                      size: 44,
                      iconSize: 24,
                      radius: 15,
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Text(
                        eyebrow.toUpperCase(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: RiderColors.goldDark,
                          fontSize: 10,
                          letterSpacing: 1.25,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.auto_awesome_rounded,
                      color: RiderColors.gold.withValues(alpha: .63),
                      size: 16,
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: RiderColors.text,
                    fontSize: 24,
                    height: 1.06,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -.65,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    color: RiderColors.muted,
                    fontSize: 12,
                    height: 1.42,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (footer != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    height: 1,
                    color: RiderColors.gold.withValues(alpha: .19),
                  ),
                  const SizedBox(height: 13),
                  footer!,
                ],
              ],
            ),
          ),
          Positioned(
            left: 18,
            right: 18,
            bottom: 0,
            child: Container(
              height: 3,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                gradient: LinearGradient(
                  colors: [
                    RiderColors.gold.withValues(alpha: .92),
                    RiderColors.gold.withValues(alpha: .23),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
