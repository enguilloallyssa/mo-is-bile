import 'package:flutter/material.dart';

/// RiderShell owns this bottom navigation. Do not add another one to RiderHome.
/// The compact, fixed-height content avoids RenderFlex bottom overflow on
/// narrow Android devices and with larger system text settings.
class RiderBottomNav extends StatelessWidget {
  const RiderBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const Color _ink = Color(0xFF262523);
  static const Color _muted = Color(0xFF888789);
  static const Color _gold = Color(0xFFD39112);
  static const Color _border = Color(0xFFF0E7DD);

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
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 6),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
        child: Container(
          height: 65,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _border),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF594025).withValues(alpha: .10),
                blurRadius: 22,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
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
                              duration: const Duration(milliseconds: 190),
                              curve: Curves.easeOutCubic,
                              width: 33,
                              height: 32,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: selected
                                    ? const Color(0xFFFFF0CF)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                selected ? item.activeIcon : item.normalIcon,
                                size: 21,
                                color: selected ? _gold : _muted,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 1),
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
                                      fontSize: 10,
                                      height: 1.0,
                                      fontWeight: selected
                                          ? FontWeight.w800
                                          : FontWeight.w600,
                                      color: selected ? _ink : _muted,
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
