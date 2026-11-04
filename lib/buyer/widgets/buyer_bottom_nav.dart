import 'package:flutter/material.dart';
import '../buyer_theme.dart';

/// Five primary destinations. Secondary screens live in the Buyer drawer.
class BuyerBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BuyerBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _items = <(IconData, IconData, String)>[
    (Icons.home_outlined, Icons.home_rounded, 'Home'),
    (Icons.storefront_outlined, Icons.storefront_rounded, 'Shop'),
    (Icons.receipt_long_outlined, Icons.receipt_long_rounded, 'Orders'),
    (Icons.notifications_none_rounded, Icons.notifications_rounded, 'Updates'),
    (Icons.person_outline_rounded, Icons.person_rounded, 'Account'),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: BuyerTheme.border)),
        boxShadow: [BoxShadow(color: Color(0x140B233F), blurRadius: 22, offset: Offset(0, -4))],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(6, 7, 6, 5),
          child: Row(
            children: List.generate(_items.length, (index) {
              final item = _items[index];
              final active = index == currentIndex;
              return Expanded(
                child: Semantics(
                  button: true,
                  selected: active,
                  label: item.$3,
                  child: InkWell(
                    onTap: () => onTap(index),
                    borderRadius: BorderRadius.circular(16),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      decoration: BoxDecoration(
                        color: active ? BuyerTheme.goldPale : Colors.transparent,
                        borderRadius: BorderRadius.circular(17),
                      ),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Icon(active ? item.$2 : item.$1,
                          color: active ? BuyerTheme.goldDark : BuyerTheme.muted,
                          size: width < 350 ? 21 : 23),
                        const SizedBox(height: 4),
                        Text(item.$3, maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: active ? BuyerTheme.goldDark : BuyerTheme.muted,
                            fontSize: width < 350 ? 10 : 10.5,
                            fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                          )),
                      ]),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
