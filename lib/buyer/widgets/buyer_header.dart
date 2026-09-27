import 'package:flutter/material.dart';

class BuyerHeader extends StatelessWidget {
  final String pageTitle;
  final int cartCount;
  final VoidCallback onSearchTap;
  final VoidCallback onCartTap;
  final VoidCallback onProfileTap;

  const BuyerHeader({
    super.key,
    this.pageTitle = 'Home',
    this.cartCount = 0,
    required this.onSearchTap,
    required this.onCartTap,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFFFDF9),
      elevation: 1,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 11),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: onSearchTap,
                  borderRadius: BorderRadius.circular(13),
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(
                        color: const Color(0xFFE6DDCF),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.search,
                          size: 19,
                          color: Color(0xFF9A9184),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Search products, brands...',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Color(0xFFA89F92),
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _HeaderIconButton(
                icon: Icons.shopping_cart_outlined,
                badge: cartCount,
                onTap: onCartTap,
              ),
              const SizedBox(width: 6),
              _HeaderIconButton(
                icon: Icons.person_outline,
                onTap: onProfileTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final int badge;
  final VoidCallback onTap;

  const _HeaderIconButton({
    required this.icon,
    required this.onTap,
    this.badge = 0,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE8DFD0)),
        ),
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Icon(
              icon,
              color: const Color(0xFF443D33),
              size: 21,
            ),
            if (badge > 0)
              Positioned(
                right: -4,
                top: -5,
                child: Container(
                  constraints: const BoxConstraints(minWidth: 20),
                  height: 20,
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9930A),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFFFFDF9),
                      width: 2,
                    ),
                  ),
                  child: Text(
                    badge > 99 ? '99+' : '$badge',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
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
