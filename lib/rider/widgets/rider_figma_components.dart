import 'package:flutter/material.dart';
import 'rider_hero.dart';

/// Shared SARI Rider visual language based on the supplied Figma screen.
/// Styling only: no API, account, or database changes.
class RiderFigmaColors {
  static const background = kPageBg;
  static const gold = kGold;
  static const lightGold = kGoldLight;
  static const ink = Color(0xFF14211C);
  static const muted = Color(0xFF838B88);
  static const green = Color(0xFF047857);
  static const mint = Color(0xFFD1FAE5);
  static const border = Color(0x11000000);
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

/// Exact Figma-inspired white metric card with a pastel icon and bottom bar.
class RiderStatCard extends StatelessWidget {
  const RiderStatCard({super.key, required this.data, this.onTap});
  final RiderStatData data;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.black.withValues(alpha: .05)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(14),
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
                              color: data.iconBackground,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(data.icon, color: data.iconColor, size: 21),
                          ),
                          Flexible(
                            child: Text(
                              '${data.count}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: RiderFigmaColors.ink,
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
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: RiderFigmaColors.ink,
                        ),
                      ),
                      Text(
                        data.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: data.barColors),
                    ),
                  ),
                ),
              ],
            ),
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
          style: const TextStyle(
            color: kGold,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [kGold.withValues(alpha: .5), Colors.transparent],
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 23,
                  height: 1.1,
                  fontWeight: FontWeight.w800,
                  color: RiderFigmaColors.ink,
                  letterSpacing: -.6,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.black54,
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
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isLive ? Icons.show_chart : Icons.cloud_off_outlined,
            size: 12,
            color: const Color(0xFFE3C77F),
          ),
          const SizedBox(width: 5),
          Text(
            isLive ? 'Live' : 'No data',
            style: const TextStyle(
              color: Color(0xFFE3C77F),
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom navigation shared by Home / Jobs / Deliveries / Earnings / Account.
/// The center delivery action uses the raised orange button from the mockup.
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
                    color: Colors.black.withValues(alpha: .15),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
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
                              color: const Color(0xFFF97316).withValues(alpha: .4),
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
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        50,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black,
            Color(0xFF17130A),
            Color(0xFF5E4B26),
            kPageBg,
          ],
          stops: [0, .45, .8, 1],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: kGold.withValues(alpha: .5)),
            ),
            child: IconButton(
              tooltip: onBack == null ? title : 'Back',
              onPressed: onBack,
              icon: Icon(onBack == null ? icon : Icons.arrow_back_rounded),
              color: const Color(0xFFE3C77F),
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
                    color: Colors.white60,
                    fontSize: 11,
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
/// Do not nest another Scaffold inside [child].
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

  /// Off by default because RiderShell already owns the app-wide bottom nav.
  final bool showBottomNavigation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: false,
      backgroundColor: kPageBg,
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
    this.iconColor = const Color(0xFFD97706),
    this.iconBackground = const Color(0xFFFEF3C7),
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color iconColor;
  final Color iconBackground;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: RiderFigmaColors.border),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                          color: RiderFigmaColors.ink,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        )),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 11,
                        )),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded,
                  size: 14, color: Colors.black38),
            ],
          ),
        ),
      ),
    );
  }
}
