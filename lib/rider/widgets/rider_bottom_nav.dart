import 'package:flutter/material.dart';
import 'rider_ui.dart';

/// RiderShell owns this bottom navigation. Do not add another one to RiderHome.
class RiderBottomNav extends StatelessWidget {
  const RiderBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const List<_NavItem> _tabs = [
    _NavItem('Home', Icons.home_rounded, Icons.home_outlined),
    _NavItem('Jobs', Icons.assignment_rounded, Icons.assignment_outlined),
    _NavItem(
      'Deliveries',
      Icons.local_shipping_rounded,
      Icons.local_shipping_outlined,
    ),
    _NavItem(
      'Earnings',
      Icons.account_balance_wallet_rounded,
      Icons.account_balance_wallet_outlined,
    ),
    _NavItem('Account', Icons.person_rounded, Icons.person_outline_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final bool isDark = RiderColors.isDark;
    final Color navSurface = isDark ? RiderColors.nav : Colors.white;
    final Color borderColor =
        isDark ? RiderColors.border : const Color(0xFFEAE3D7);
    final Color activeText = isDark ? RiderColors.text : const Color(0xFF181715);
    final Color mutedText = isDark ? RiderColors.muted : const Color(0xFF7D7870);
    final Color goldAccent =
        isDark ? RiderColors.gold : const Color(0xFFD4952A);
    final Color activePillBg =
        isDark ? RiderColors.goldSoft : const Color(0xFFFFF1CE);

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 6),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
        child: Container(
          height: 66,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: navSurface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? .28 : .07),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: List.generate(_tabs.length, (index) {
                final selected = currentIndex == index;
                final item = _tabs[index];
                return Expanded(
                  child: Semantics(
                    button: true,
                    selected: selected,
                    label: item.title,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => onTap(index),
                        borderRadius: BorderRadius.circular(18),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOutCubic,
                              width: 40,
                              height: 32,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: selected
                                    ? activePillBg
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                selected ? item.activeIcon : item.normalIcon,
                                size: 21,
                                color: selected ? goldAccent : mutedText,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 2),
                              child: SizedBox(
                                height: 13,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.center,
                                  child: Text(
                                    item.title,
                                    maxLines: 1,
                                    softWrap: false,
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      height: 1.0,
                                      fontWeight: selected
                                          ? FontWeight.w800
                                          : FontWeight.w600,
                                      color: selected ? activeText : mutedText,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.title, this.activeIcon, this.normalIcon);

  final String title;
  final IconData activeIcon;
  final IconData normalIcon;
}