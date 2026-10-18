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
      elevation: 0,
      child: SafeArea(
        bottom: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 9, 12, 10),
          decoration: const BoxDecoration(
            color: Color(0xFFFFFDF9),
            border: Border(
              bottom: BorderSide(color: Color(0xFFEEE6DA)),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: onSearchTap,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    height: 46,
                    padding: const EdgeInsets.symmetric(horizontal: 13),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFE4DACB),
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0D513E20),
                          blurRadius: 16,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3DA),
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: const Icon(
                            Icons.search_rounded,
                            size: 17,
                            color: Color(0xFFC47C05),
                          ),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pageTitle == 'Home'
                                    ? 'Search on SARI'
                                    : pageTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF403930),
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 1),
                              const Text(
                                'Products, shops, brands...',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Color(0xFFA0978C),
                                  fontSize: 8,
                                ),
                              ),
                            ],
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
                tooltip: 'Cart',
                onTap: onCartTap,
              ),
              const SizedBox(width: 7),
              _HeaderIconButton(
                icon: Icons.chat_bubble_outline_rounded,
                tooltip: 'Messages',
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
  final String tooltip;
  final VoidCallback onTap;

  const _HeaderIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.badge = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE7DED1)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A3C2E18),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Icon(
                icon,
                color: const Color(0xFF3C352C),
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
                      color: const Color(0xFFE4930A),
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
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
