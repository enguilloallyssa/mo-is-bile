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
    final double width =
        MediaQuery.sizeOf(context).width;

    final bool compact =
        width < 360;

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: BuyerTheme.border,
          ),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Color(0x140B233F),
            blurRadius: 18,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            5,
            5,
            5,
            4,
          ),
          child: Row(
            children:
                List<Widget>.generate(
              _items.length,
              (int index) {
                final item =
                    _items[index];

                final bool active =
                    index ==
                        currentIndex;

                return Expanded(
                  child: InkWell(
                    onTap: () {
                      onTap(index);
                    },
                    borderRadius:
                        BorderRadius.circular(
                      14,
                    ),
                    child: AnimatedContainer(
                      duration:
                          const Duration(
                        milliseconds: 180,
                      ),
                      padding:
                          const EdgeInsets.symmetric(
                        vertical: 6,
                      ),
                      decoration:
                          BoxDecoration(
                        color: active
                            ? BuyerTheme
                                .goldPale
                            : Colors
                                .transparent,
                        borderRadius:
                            BorderRadius.circular(
                          14,
                        ),
                      ),
                      child: Column(
                        mainAxisSize:
                            MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            active
                                ? item.$2
                                : item.$1,
                            size: compact
                                ? 19
                                : 21,
                            color: active
                                ? BuyerTheme
                                    .goldDark
                                : BuyerTheme
                                    .muted,
                          ),
                          const SizedBox(
                            height: 3,
                          ),
                          Text(
                            item.$3,
                            maxLines: 1,
                            overflow:
                                TextOverflow
                                    .ellipsis,
                            style:
                                TextStyle(
                              color: active
                                  ? BuyerTheme
                                      .goldDark
                                  : BuyerTheme
                                      .muted,
                              fontSize:
                                  compact
                                      ? 8
                                      : 8.5,
                              fontWeight:
                                  active
                                      ? FontWeight
                                          .w800
                                      : FontWeight
                                          .w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}