import 'package:flutter/material.dart';

class BuyerBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BuyerBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _items = <(
    IconData,
    IconData,
    String
  )>[
    (
      Icons.home_outlined,
      Icons.home_rounded,
      'Home',
    ),
    (
      Icons.storefront_outlined,
      Icons.storefront_rounded,
      'Shop Products',
    ),
    (
      Icons.receipt_long_outlined,
      Icons.receipt_long_rounded,
      'My Orders',
    ),
    (
      Icons.notifications_none_rounded,
      Icons.notifications_rounded,
      'Notifications',
    ),
    (
      Icons.person_outline_rounded,
      Icons.person_rounded,
      'Account',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 10,
      shadowColor: const Color(0x14000000),
      child: SafeArea(
        top: false,
        child: Container(
          height: 68,
          padding: const EdgeInsets.fromLTRB(
            4,
            6,
            4,
            5,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(
                color: Color(0xFFE6E8EC),
              ),
            ),
          ),
          child: Row(
            children: List.generate(
              _items.length,
              (index) {
                final item = _items[index];
                final active =
                    currentIndex == index;

                return Expanded(
                  child: InkWell(
                    onTap: () => onTap(index),
                    borderRadius:
                        BorderRadius.circular(14),
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(
                            milliseconds: 180,
                          ),
                          curve: Curves.easeOut,
                          width: 38,
                          height: 30,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: active
                                ? const Color(
                                    0xFFFFF1D3,
                                  )
                                : Colors.transparent,
                            borderRadius:
                                BorderRadius.circular(
                              11,
                            ),
                          ),
                          child: Icon(
                            active
                                ? item.$2
                                : item.$1,
                            size: 20,
                            color: active
                                ? const Color(
                                    0xFFD9950B,
                                  )
                                : const Color(
                                    0xFF8A919B,
                                  ),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.$3,
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: active
                                ? const Color(
                                    0xFFB87908,
                                  )
                                : const Color(
                                    0xFF8A919B,
                                  ),
                            fontSize: 7.5,
                            height: 1,
                            fontWeight: active
                                ? FontWeight.w800
                                : FontWeight.w600,
                          ),
                        ),
                      ],
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