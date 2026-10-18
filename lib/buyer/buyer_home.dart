import 'package:flutter/material.dart';

import 'buyer_rewards.dart';
import 'models/buyer_product_model.dart';
import 'widgets/buyer_header.dart';
import 'widgets/buyer_product_card.dart';

class BuyerHome extends StatefulWidget {
  final ValueChanged<int>? onTabChanged;

  const BuyerHome({
    super.key,
    this.onTabChanged,
  });

  @override
  State<BuyerHome> createState() => _BuyerHomeState();
}

class _BuyerHomeState extends State<BuyerHome> {
  static const Color _brand = Color(0xFFD98D08);
  static const Color _text = Color(0xFF211D17);
  static const Color _muted = Color(0xFF82786D);
  static const Color _border = Color(0xFFE8DFD2);

  final List<_BuyerCategory> categories = const [
    _BuyerCategory('Fashion', Icons.checkroom_outlined, Color(0xFFFFEBDD)),
    _BuyerCategory('Beauty', Icons.spa_outlined, Color(0xFFFDE8EE)),
    _BuyerCategory('Home', Icons.chair_outlined, Color(0xFFEAF2E9)),
    _BuyerCategory('Electronics', Icons.devices_other_outlined, Color(0xFFE7EFF8)),
  ];

  final List<BuyerProduct> featuredProducts = const [
    BuyerProduct(
      id: 1,
      name: 'Everyday Wireless Earbuds',
      category: 'Electronics',
      brand: 'SARI Mall',
      image: 'assets/images/sample-earbuds.jpg',
      rating: 4.8,
      sold: 426,
      stock: 34,
      price: 899,
      oldPrice: 1299,
      freeShipping: true,
      description: 'Compact wireless earbuds for everyday listening and calls.',
    ),
    BuyerProduct(
      id: 2,
      name: 'Minimal Everyday Tote',
      category: 'Fashion',
      brand: 'SARI Mall',
      image: 'assets/images/sample-tote.jpg',
      rating: 4.7,
      sold: 238,
      stock: 18,
      price: 349,
      oldPrice: 499,
      freeShipping: true,
    ),
    BuyerProduct(
      id: 3,
      name: 'Soft Glow Desk Lamp',
      category: 'Home & Living',
      brand: 'SARI Mall',
      image: 'assets/images/sample-lamp.jpg',
      rating: 4.9,
      sold: 312,
      stock: 22,
      price: 549,
      oldPrice: 699,
    ),
    BuyerProduct(
      id: 4,
      name: 'Daily Skin Essentials Set',
      category: 'Beauty',
      brand: 'SARI Mall',
      image: 'assets/images/sample-beauty.jpg',
      rating: 4.6,
      sold: 177,
      stock: 12,
      price: 699,
      oldPrice: 999,
      freeShipping: true,
    ),
  ];

  Future<void> _refresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 550));
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F1),
      body: Column(
        children: [
          BuyerHeader(
            pageTitle: 'Home',
            cartCount: 0,
            onSearchTap: () => widget.onTabChanged?.call(1),
            onCartTap: () => widget.onTabChanged?.call(2),
            onProfileTap: () => widget.onTabChanged?.call(4),
          ),
          Expanded(
            child: RefreshIndicator(
              color: _brand,
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  _hero(),
                  _quickActions(),
                  _sectionHeader(
                    title: 'Categories',
                    subtitle: 'Find what you need faster',
                    actionText: 'See all',
                    onAction: () => widget.onTabChanged?.call(1),
                  ),
                  _categories(),
                  _sectionHeader(
                    title: 'Featured Deals',
                    subtitle: 'Limited picks worth checking',
                    actionText: 'View deals',
                    onAction: () => widget.onTabChanged?.call(1),
                  ),
                  _dealRail(),
                  _recommendedProducts(),
                  _rewardsBanner(),
                  _buyerProtection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _hero() {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 380;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      height: compact ? 228 : 242,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE7D9C2)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x124D3514),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFFFDF9),
                  Color(0xFFFFFAF0),
                  Color(0xFFF7E9CC),
                ],
                stops: [0, .58, 1],
              ),
            ),
          ),

          // Soft decorative shapes only — no harsh image/highlight band.
          Positioned(
            right: -48,
            top: -42,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFD98D08).withValues(alpha: .07),
              ),
            ),
          ),
          Positioned(
            right: 24,
            bottom: -30,
            child: Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: .34),
                border: Border.all(
                  color: const Color(0xFFE1B661).withValues(alpha: .22),
                ),
              ),
            ),
          ),

          // Small visual accent on the right side.
          Positioned(
            right: compact ? 16 : 22,
            top: compact ? 24 : 28,
            child: Container(
              width: compact ? 52 : 58,
              height: compact ? 52 : 58,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .88),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFFE4D4B8),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x104D3514),
                    blurRadius: 12,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                color: _brand,
                size: 24,
              ),
            ),
          ),
          Positioned(
            right: compact ? 20 : 28,
            top: compact ? 83 : 94,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8EA).withValues(alpha: .94),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFE6C98F),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.verified_rounded,
                    color: Color(0xFF4F7D63),
                    size: 11,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Trusted',
                    style: TextStyle(
                      color: Color(0xFF665A49),
                      fontSize: 6.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.fromLTRB(
              compact ? 18 : 22,
              18,
              compact ? 12 : 16,
              17,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: compact ? width * .69 : width * .67,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .90),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFE5C98F),
                        ),
                      ),
                      child: const Text(
                        'EVERYDAY SHOPPING • MADE EASY',
                        style: TextStyle(
                          color: Color(0xFF9F6509),
                          fontSize: 6.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: .65,
                        ),
                      ),
                    ),
                    const SizedBox(height: 11),
                    Text(
                      'Everything you need,\nright where you shop.',
                      style: TextStyle(
                        color: _text,
                        fontSize: compact ? 22.5 : 26,
                        height: 1.05,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -.8,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      'Shop trusted sellers, discover great finds, and track every order with ease.',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _muted,
                        fontSize: compact ? 8.5 : 9.5,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        SizedBox(
                          height: 38,
                          child: ElevatedButton.icon(
                            onPressed: () => widget.onTabChanged?.call(1),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _brand,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 13,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(11),
                              ),
                            ),
                            icon: const Icon(
                              Icons.shopping_bag_outlined,
                              size: 14,
                            ),
                            label: const Text(
                              'Shop Now',
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Container(
                            height: 38,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: .78),
                              borderRadius: BorderRadius.circular(11),
                              border: Border.all(
                                color: const Color(0xFFE1D4C1),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.shield_outlined,
                                  color: Color(0xFF4F7D63),
                                  size: 13,
                                ),
                                SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    'Buyer safe',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Color(0xFF635A50),
                                      fontSize: 7,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickActions() {
    final items = <(IconData, String, Color, VoidCallback)>[
      (Icons.grid_view_rounded, 'Categories', const Color(0xFFFFEBD1), () => widget.onTabChanged?.call(1)),
      (Icons.local_shipping_outlined, 'Free Ship', const Color(0xFFE6F4EA), () => widget.onTabChanged?.call(1)),
      (Icons.sell_outlined, 'Vouchers', const Color(0xFFFBE8DF), () => widget.onTabChanged?.call(1)),
      (Icons.card_giftcard_outlined, 'Rewards', const Color(0xFFECE7F5), () => Navigator.push<void>(context, MaterialPageRoute(builder: (_) => const BuyerRewards()))),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A4D3514),
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: items.map((item) {
          return Expanded(
            child: InkWell(
              onTap: item.$4,
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Column(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: item.$3,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        item.$1,
                        color: const Color(0xFF9E6509),
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.$2,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF5C5349),
                        fontSize: 8.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _sectionHeader({
    required String title,
    required String subtitle,
    required String actionText,
    required VoidCallback onAction,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 21, 12, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _text,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -.25,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onAction,
            child: Text('$actionText  ›'),
          ),
        ],
      ),
    );
  }

  Widget _categories() {
    return SizedBox(
      height: 103,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final category = categories[index];
          return InkWell(
            onTap: () => widget.onTabChanged?.call(1),
            borderRadius: BorderRadius.circular(18),
            child: Container(
              width: 86,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _border),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: category.color,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      category.icon,
                      color: const Color(0xFF9C650C),
                      size: 23,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    category.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF4B433A),
                      fontSize: 8.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _dealRail() {
    const deals = <(String, String, String, String, Color)>[
      ('Watch Essentials', 'UP TO 50% OFF', 'Fresh styles for everyday wear.', 'assets/images/weekend-watch.png', Color(0xFF6E4F2E)),
      ('Beauty Must-Haves', 'UP TO 40% OFF', 'Everyday self-care favorites.', 'assets/images/beauty-bestsellers.png', Color(0xFF8B535C)),
      ('Home Upgrades', 'UP TO 35% OFF', 'Small changes, better spaces.', 'assets/images/home-essentials.png', Color(0xFF496A5C)),
    ];

    return SizedBox(
      height: 154,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        itemCount: deals.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final deal = deals[index];
          return InkWell(
            onTap: () => widget.onTabChanged?.call(1),
            borderRadius: BorderRadius.circular(18),
            child: Container(
              width: 278,
              decoration: BoxDecoration(
                color: deal.$5,
                borderRadius: BorderRadius.circular(18),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned(
                    left: 128,
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: Image.asset(
                      deal.$4,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          deal.$5,
                          deal.$5.withValues(alpha: .94),
                          deal.$5.withValues(alpha: .28),
                        ],
                        stops: const [0, .52, 1],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: 145,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            deal.$2,
                            style: const TextStyle(
                              color: Color(0xFFFFD98C),
                              fontSize: 7.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: .7,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            deal.$1,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              height: 1.12,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            deal.$3,
                            style: const TextStyle(
                              color: Color(0xFFEDE5DB),
                              fontSize: 8,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Shop now  ›',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _recommendedProducts() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 22, 12, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'JUST FOR YOU',
                      style: TextStyle(
                        color: Color(0xFFAE7210),
                        fontSize: 7.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Recommended for You',
                      style: TextStyle(
                        color: _text,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0D3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.auto_awesome, color: _brand, size: 13),
                    SizedBox(width: 4),
                    Text(
                      'Fresh picks',
                      style: TextStyle(
                        color: Color(0xFF9B640C),
                        fontSize: 7.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          SizedBox(
            height: 32,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _filterChip('All', active: true),
                ...categories.map((item) => _filterChip(item.name)),
              ],
            ),
          ),
          const SizedBox(height: 11),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: featuredProducts.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              mainAxisExtent: 312,
            ),
            itemBuilder: (context, index) {
              final product = featuredProducts[index];
              return BuyerProductCard(
                product: product,
                showPromotions: true,
                showStock: true,
                showQuickAdd: true,
                onTap: () => _showProductPreview(product),
                onAddToCart: () => _toast('${product.name} added to cart'),
                onBuyNow: () => _showProductPreview(product),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, {bool active = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 7),
      padding: const EdgeInsets.symmetric(horizontal: 13),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: active ? const Color(0xFFFFEDD0) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: active ? const Color(0xFFE7B75E) : _border,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: active ? const Color(0xFFA86B08) : const Color(0xFF6E655B),
          fontSize: 8,
          fontWeight: active ? FontWeight.w800 : FontWeight.w600,
        ),
      ),
    );
  }

  Widget _rewardsBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 22, 12, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF29241F), Color(0xFF40362A)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1B000000),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: const Color(0xFFFFD88A).withValues(alpha: .12),
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Icon(
              Icons.card_giftcard_rounded,
              color: Color(0xFFFFC55B),
              size: 30,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rewards & Vouchers',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Earn points from delivered orders and unlock more savings.',
                  style: TextStyle(
                    color: Color(0xFFD3C8BC),
                    fontSize: 8.2,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed: () => Navigator.push<void>(
              context,
              MaterialPageRoute(builder: (_) => const BuyerRewards()),
            ),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFE39A15),
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.arrow_forward_rounded, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buyerProtection() {
    const items = <(IconData, String, String)>[
      (Icons.verified_user_outlined, 'Verified sellers', 'Trusted marketplace listings'),
      (Icons.lock_outline_rounded, 'Safe checkout', 'Protected payment flow'),
      (Icons.assignment_return_outlined, 'Easy support', 'Help for eligible concerns'),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 22, 12, 0),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Shop with confidence',
            style: TextStyle(
              color: _text,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 11),
          ...items.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3DE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(item.$1, color: const Color(0xFFAF710A), size: 19),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.$2,
                          style: const TextStyle(
                            color: Color(0xFF403930),
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.$3,
                          style: const TextStyle(
                            color: _muted,
                            fontSize: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF5D8B6B),
                    size: 18,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showProductPreview(BuyerProduct product) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 2, 18, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    color: _text,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '₱${product.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Color(0xFFD77F00),
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  product.description?.trim().isNotEmpty == true
                      ? product.description!
                      : 'Tap Shop Products to view the complete product information, variants, seller and checkout options.',
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 10,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      widget.onTabChanged?.call(1);
                    },
                    icon: const Icon(Icons.storefront_outlined, size: 17),
                    label: const Text('View in Shop'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFFFFC55B), size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}

class _BuyerCategory {
  final String name;
  final IconData icon;
  final Color color;

  const _BuyerCategory(this.name, this.icon, this.color);
}
