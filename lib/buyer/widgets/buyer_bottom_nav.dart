import 'package:flutter/material.dart';

import '../buyer_theme.dart';

class BuyerBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BuyerBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _items =
      <(IconData, IconData, String)>[
    (
      Icons.home_outlined,
      Icons.home_rounded,
      'Home',
    ),
    (
      Icons.storefront_outlined,
      Icons.storefront_rounded,
      'Shop',
    ),
    (
      Icons.receipt_long_outlined,
      Icons.receipt_long_rounded,
      'Orders',
    ),
    (
      Icons.chat_bubble_outline_rounded,
      Icons.chat_bubble_rounded,
      'Messages',
    ),
    (
      Icons.person_outline_rounded,
      Icons.person_rounded,
      'Account',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 360;
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 9),
        padding: const EdgeInsets.fromLTRB(5, 6, 5, 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: BuyerTheme.border),
          boxShadow: const [BoxShadow(color: Color(0x170B233F), blurRadius: 20, offset: Offset(0, 7))],
        ),
        child: Row(children: List.generate(_items.length, (index) {
          final item = _items[index];
          final selected = currentIndex == index;
          return Expanded(child: Semantics(
            selected: selected,
            button: true,
            label: '${item.$3} tab',
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onTap(index),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      height: 36,
                      width: compact ? 38 : 42,
                      decoration: BoxDecoration(
                        color: selected ? BuyerTheme.goldPale : Colors.transparent,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      alignment: Alignment.center,
                      child: AnimatedScale(
                        duration: const Duration(milliseconds: 220),
                        scale: selected ? 1.05 : 1,
                        child: Icon(selected ? item.$2 : item.$1,
                          color: selected ? BuyerTheme.goldDark : BuyerTheme.muted,
                          size: compact ? 19 : 21),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(item.$3,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: selected ? BuyerTheme.goldDark : BuyerTheme.muted,
                        fontSize: compact ? 9 : 10,
                        fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                      ),
                    ),
                  ]),
                ),
              ),
            ),
          ));
        })),
      ),
    );
  }
}
