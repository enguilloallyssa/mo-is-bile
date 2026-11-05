import 'package:flutter/material.dart';

import 'rider_ui.dart';

class RiderBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const RiderBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const List<_RiderNavItem> _items =
      <_RiderNavItem>[
    _RiderNavItem(
      icon: Icons.dashboard_outlined,
      selectedIcon:
          Icons.dashboard_rounded,
      label: 'Home',
    ),
    _RiderNavItem(
      icon:
          Icons.assignment_outlined,
      selectedIcon:
          Icons.assignment_rounded,
      label: 'Jobs',
    ),
    _RiderNavItem(
      icon:
          Icons.local_shipping_outlined,
      selectedIcon:
          Icons.local_shipping_rounded,
      label: 'Deliveries',
    ),
    _RiderNavItem(
      icon: Icons
          .account_balance_wallet_outlined,
      selectedIcon: Icons
          .account_balance_wallet_rounded,
      label: 'Earnings',
    ),
    _RiderNavItem(
      icon:
          Icons.person_outline_rounded,
      selectedIcon:
          Icons.person_rounded,
      label: 'Account',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        margin:
            const EdgeInsets.fromLTRB(
          10,
          0,
          10,
          8,
        ),
        padding:
            const EdgeInsets.symmetric(
          horizontal: 5,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: RiderColors.nav,
          borderRadius:
              BorderRadius.circular(20),
          border: Border.all(
            color: RiderColors.border,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(
                alpha: RiderColors.isDark
                    ? .25
                    : .08,
              ),
              blurRadius: 20,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          children: List<Widget>.generate(
            _items.length,
            (int index) {
              final _RiderNavItem item =
                  _items[index];

              final bool selected =
                  currentIndex == index;

              return Expanded(
                child: Material(
                  color:
                      Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      onTap(index);
                    },
                    borderRadius:
                        BorderRadius.circular(
                      15,
                    ),
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(
                        vertical: 4,
                      ),
                      child: Column(
                        mainAxisSize:
                            MainAxisSize.min,
                        children: <Widget>[
                          AnimatedContainer(
                            duration:
                                const Duration(
                              milliseconds: 180,
                            ),
                            width: 38,
                            height: 35,
                            alignment:
                                Alignment.center,
                            decoration:
                                BoxDecoration(
                              color: selected
                                  ? RiderColors
                                      .goldSoft
                                  : Colors
                                      .transparent,
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                12,
                              ),
                            ),
                            child: Icon(
                              selected
                                  ? item.selectedIcon
                                  : item.icon,
                              size: 21,
                              color: selected
                                  ? RiderColors
                                      .goldDark
                                  : RiderColors
                                      .muted,
                            ),
                          ),

                          const SizedBox(
                            height: 3,
                          ),

                          AnimatedDefaultTextStyle(
                            duration:
                                const Duration(
                              milliseconds: 180,
                            ),
                            style: TextStyle(
                              color: selected
                                  ? RiderColors
                                      .goldDark
                                  : RiderColors
                                      .muted,
                              fontSize: 9,
                              fontWeight: selected
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                            ),
                            child: Text(
                              item.label,
                              maxLines: 1,
                              overflow:
                                  TextOverflow
                                      .ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _RiderNavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const _RiderNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}