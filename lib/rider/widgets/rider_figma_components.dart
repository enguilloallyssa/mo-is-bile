import 'package:flutter/material.dart';
import 'rider_hero.dart';
import 'rider_ui.dart';

/// Shared SARI Rider visual language based on the supplied Figma screen.
/// Styling only: no API, account, or database changes.
class RiderFigmaColors {
  static const background = kPageBg;
  static const gold = kGold;
  static const lightGold = kGoldLight;
  static const ink = Color(0xFF161513);
  static const muted = Color(0xFF6E6A63);
  static const green = Color(0xFF047857);
  static const mint = Color(0xFFD1FAE5);
  static const border = Color(0xFFE6E0D5);
  static const surface = Colors.white;
}

class RiderStatData {
  const RiderStatData({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.count,
    required this.iconBackground,
    required this.iconColor,
    required this.barColors,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final int count;
  final Color iconBackground;
  final Color iconColor;
  final List<Color> barColors;
}

/// Polished Bento metric card with a tinted icon badge and clipped bottom accent bar.
class RiderStatCard extends StatelessWidget {
  const RiderStatCard({super.key, required this.data, this.onTap});
  final RiderStatData data;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool isDark = RiderColors.isDark;
    final Color cardBg = isDark ? RiderColors.surface : Colors.white;
    final Color borderColor =
        isDark ? RiderColors.border : const Color(0xFFE8E2D7);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? .20 : .035),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(15, 14, 15, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? data.iconColor.withValues(alpha: .16)
                                  : data.iconBackground,
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: Icon(
                              data.icon,
                              color: data.iconColor,
                              size: 20,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              '${data.count}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -.6,
                                color: isDark
                                    ? RiderColors.text
                                    : RiderFigmaColors.ink,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        data.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -.2,
                          color:
                              isDark ? RiderColors.text : RiderFigmaColors.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        data.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? RiderColors.muted
                              : RiderFigmaColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                height: 4,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: data.barColors),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RiderEyebrow extends StatelessWidget {
  const RiderEyebrow({super.key, required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: RiderColors.gold,
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 2.2,
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
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class RiderSectionHeading extends StatelessWidget {
  const RiderSectionHeading({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });
  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final bool isDark = RiderColors.isDark;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 21,
                  height: 1.12,
                  fontWeight: FontWeight.w900,
                  color: isDark ? RiderColors.text : RiderFigmaColors.ink,
                  letterSpacing: -.5,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 3),
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: isDark ? RiderColors.muted : RiderFigmaColors.muted,
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

class RiderLiveChip extends StatelessWidget {
  const RiderLiveChip({super.key, this.isLive = true});
  final bool isLive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF181715),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: const Color(0xFF3E3524)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isLive ? Icons.trending_up_rounded : Icons.cloud_off_outlined,
            size: 13,
            color: const Color(0xFFF3C663),
          ),
          const SizedBox(width: 5),
          Text(
            isLive ? 'Live' : 'No data',
            style: const TextStyle(
              color: Color(0xFFF3C663),
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom navigation shared by Home / Jobs / Deliveries / Earnings / Account.
class RiderFloatingNav extends StatelessWidget {
  const RiderFloatingNav({
    super.key,
    required this.index,
    required this.onTap,
  });

  final int index;
  final ValueChanged<int> onTap;

  static const items = [
    (Icons.home_outlined, 'Home'),
    (Icons.assignment_outlined, 'Jobs'),
    (Icons.local_shipping_outlined, 'Deliveries'),
    (Icons.account_balance_wallet_outlined, 'Earnings'),
    (Icons.person_outline, 'Account'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 30, 20, 12),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: 68,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .96),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .12),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  for (var i = 0; i < items.length; i++)
                    Expanded(
                      child: i == 2
                          ? const SizedBox.shrink()
                          : GestureDetector(
                              onTap: () => onTap(i),
                              behavior: HitTestBehavior.opaque,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: index == i
                                          ? RiderFigmaColors.mint
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Icon(
                                      items[i].$1,
                                      size: 20,
                                      color: index == i
                                          ? RiderFigmaColors.green
                                          : Colors.black38,
                                    ),
                                  ),
                                  Text(
                                    items[i].$2,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: index == i
                                          ? RiderFigmaColors.green
                                          : Colors.black38,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                ],
              ),
            ),
            Positioned(
              top: -28,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () => onTap(2),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFFBBF24), Color(0xFFF97316)],
                          ),
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  const Color(0xFFF97316).withValues(alpha: .4),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.local_shipping_outlined,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Deliveries',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: index == 2
                              ? RiderFigmaColors.green
                              : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Consistent page header to reuse for Jobs, Deliveries, Earnings and Account.
class RiderInnerHeader extends StatelessWidget {
  const RiderInnerHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onBack,
    this.actions = const [],
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onBack;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF161513),
            Color(0xFF282219),
            Color(0xFF6B4F1D),
            kPageBg,
          ],
          stops: [0, .45, .8, 1],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: kGold.withValues(alpha: .45)),
            ),
            child: IconButton(
              tooltip: onBack == null ? title : 'Back',
              onPressed: onBack,
              icon: Icon(onBack == null ? icon : Icons.arrow_back_rounded),
              color: const Color(0xFFF3C663),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  subtitle,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
          ...actions,
        ],
      ),
    );
  }
}

/// Keep your existing API-connected page BODY and simply wrap it in this shell.
class RiderFigmaPage extends StatelessWidget {
  const RiderFigmaPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selectedTab,
    required this.onTabChanged,
    required this.child,
    this.showBottomNavigation = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final int selectedTab;
  final ValueChanged<int> onTabChanged;
  final Widget child;
  final bool showBottomNavigation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: false,
      backgroundColor: RiderColors.bg,
      body: SafeArea(
        top: true,
        bottom: false,
        child: ClipRect(
          child: Column(
            children: [
              RiderInnerHeader(title: title, subtitle: subtitle, icon: icon),
              Expanded(child: child),
            ],
          ),
        ),
      ),
      bottomNavigationBar: showBottomNavigation
          ? RiderFloatingNav(index: selectedTab, onTap: onTabChanged)
          : null,
    );
  }
}

class RiderActionCard extends StatelessWidget {
  const RiderActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor = const Color(0xFFD4952A),
    this.iconBackground = const Color(0xFFFFF3D6),
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color iconColor;
  final Color iconBackground;

  @override
  Widget build(BuildContext context) {
    final bool isDark = RiderColors.isDark;
    return Material(
      color: isDark ? RiderColors.surface : Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            border: Border.all(color: RiderColors.border),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isDark
                      ? iconColor.withValues(alpha: .16)
                      : iconBackground,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: iconColor, size: 21),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: RiderColors.text,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: RiderColors.muted,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: RiderColors.muted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}