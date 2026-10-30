import 'package:flutter/material.dart';

import 'rider_ui.dart';

class RiderBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  RiderBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final items = <_RiderNavItem>[
      const _RiderNavItem(Icons.home_outlined, Icons.home_rounded, 'Home'),
      const _RiderNavItem(Icons.assignment_outlined, Icons.assignment_rounded, 'Pickups'),
      const _RiderNavItem(Icons.navigation_outlined, Icons.navigation_rounded, 'Deliveries'),
      const _RiderNavItem(Icons.account_balance_wallet_outlined, Icons.account_balance_wallet_rounded, 'Earnings'),
      const _RiderNavItem(Icons.person_outline_rounded, Icons.person_rounded, 'Account'),
    ];

    return SafeArea(
      top: false,
      child: Container(
        margin: EdgeInsets.fromLTRB(10, 0, 10, 8),
        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 6),
        decoration: BoxDecoration(
          color: RiderColors.nav,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: RiderColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: RiderColors.isDark ? .28 : .10),
              blurRadius: 22,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: List.generate(items.length, (index) {
            final item = items[index];
            final selected = index == currentIndex;
            final isRoute = index == 2;
            final activeColor = isRoute ? RiderColors.gold : RiderColors.blue;

            return Expanded(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onTap(index),
                  borderRadius: BorderRadius.circular(17),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: Duration(milliseconds: 180),
                          width: isRoute ? 42 : 36,
                          height: isRoute ? 42 : 36,
                          decoration: BoxDecoration(
                            color: selected
                                ? activeColor.withValues(alpha: isRoute ? .95 : .14)
                                : (isRoute
                                    ? RiderColors.gold.withValues(alpha: .14)
                                    : Colors.transparent),
                            borderRadius: BorderRadius.circular(isRoute ? 15 : 13),
                            border: isRoute
                                ? Border.all(
                                    color: RiderColors.gold.withValues(alpha: .35),
                                  )
                                : null,
                          ),
                          child: Icon(
                            selected ? item.selectedIcon : item.icon,
                            size: isRoute ? 21 : 20,
                            color: selected
                                ? (isRoute ? Color(0xFF182128) : activeColor)
                                : (isRoute ? RiderColors.gold : RiderColors.muted),
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          item.label,
                          style: TextStyle(
                            color: selected ? activeColor : RiderColors.muted,
                            fontSize: 9,
                            fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
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
    );
  }
}

class _RiderNavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const _RiderNavItem(this.icon, this.selectedIcon, this.label);
}
