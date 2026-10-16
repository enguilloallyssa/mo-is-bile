import 'package:flutter/material.dart';
import 'models/buyer_product_model.dart';
import 'widgets/buyer_header.dart';
import 'widgets/buyer_product_card.dart';
import 'buyer_rewards.dart';

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
  final List<_BuyerCategory> categories = const [
    _BuyerCategory(
      name: 'Fashion',
      icon: Icons.checkroom_outlined,
    ),
    _BuyerCategory(
      name: 'Beauty',
      icon: Icons.spa_outlined,
    ),
    _BuyerCategory(
      name: 'Home & Living',
      icon: Icons.chair_outlined,
    ),
    _BuyerCategory(
      name: 'Electronics',
      icon: Icons.devices_other_outlined,
    ),
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
      description:
          'Compact wireless earbuds for everyday listening and calls.',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFAF8),
      body: Column(
        children: [
          BuyerHeader(
            cartCount: 0,
            onSearchTap: () => widget.onTabChanged?.call(1),
            onCartTap: () => widget.onTabChanged?.call(2),
            onProfileTap: () => widget.onTabChanged?.call(4),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _hero(context),
                  _benefits(context),
                  _sectionHeader(
                    title: 'Shop by Category',
                    actionText: 'View all categories',
                    onAction: () => widget.onTabChanged?.call(1),
                  ),
                  _categoryRail(),
                  _sectionHeader(
                    title: 'Featured Deals',
                    actionText: 'View all deals',
                    onAction: () => widget.onTabChanged?.call(1),
                  ),
                  _featuredDeals(),
                  _recommendedProducts(),
                  _rewardsBanner(context),
                  _trustSection(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _hero(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final compact = width < 380;

    return Container(
      margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEADFCE)),
        color: const Color(0xFFFFFAF1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/sari-hero-bg.webp',
              fit: BoxFit.cover,
              alignment: Alignment.centerRight,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFFFFCF7),
                    const Color(0xFFFFFAF1).withValues(alpha: .97),
                    const Color(0xFFFFF9EF).withValues(alpha: .78),
                    Colors.transparent,
                  ],
                  stops: const [0, .42, .72, 1],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              compact ? 16 : 22,
              compact ? 21 : 28,
              compact ? 16 : 22,
              compact ? 20 : 24,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: compact ? 305 : 330,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: compact ? width * .72 : 285,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _smallPill('Elevated Everyday'),
                      const SizedBox(height: 13),
                      Text(
                        'Variety You Need,',
                        style: TextStyle(
                          color: const Color(0xFF171411),
                          fontSize: compact ? 27 : 32,
                          height: 1.03,
                          fontWeight: FontWeight.w700,
                          letterSpacing: compact ? -.8 : -1.2,
                        ),
                      ),
                      Text(
                        'Convenience You Deserve.',
                        style: TextStyle(
                          color: const Color(0xFFB8790F),
                          fontSize: compact ? 27 : 32,
                          height: 1.03,
                          fontWeight: FontWeight.w700,
                          letterSpacing: compact ? -.8 : -1.2,
                        ),
                      ),
                      const SizedBox(height: 11),
                      Text(
                        'Discover brand new finds, everyday essentials, and everything in between — all in one trusted marketplace.',
                        style: TextStyle(
                          color: const Color(0xFF6F675F),
                          fontSize: compact ? 8.5 : 9.5,
                          height: 1.55,
                        ),
                      ),
                      const SizedBox(height: 13),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          SizedBox(
                            height: 40,
                            child: ElevatedButton(
                              onPressed: () => widget.onTabChanged?.call(1),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFCC8A0B),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 17),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(11),
                                ),
                              ),
                              child: const Text(
                                'Shop Now  →',
                                style: TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 40,
                            child: OutlinedButton(
                              onPressed: () => widget.onTabChanged?.call(1),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF514940),
                                padding: const EdgeInsets.symmetric(horizontal: 13),
                                side: const BorderSide(color: Color(0xFFDDD3C6)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(11),
                                ),
                              ),
                              child: const Text(
                                'Explore Categories',
                                style: TextStyle(
                                  fontSize: 7.8,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Wrap(
                        spacing: 10,
                        runSpacing: 7,
                        children: [
                          _TrustMini(label: 'Trusted Sellers'),
                          _TrustMini(label: 'Secure Payments'),
                          _TrustMini(label: 'Easy Returns'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _benefits(BuildContext context) {
    final compact = MediaQuery.of(context).size.width < 380;

    final items = const [
      (Icons.local_shipping_outlined, 'Free Shipping', 'On eligible orders'),
      (Icons.card_giftcard_outlined, 'Earn Rewards', 'Shop and earn points'),
      (Icons.shield_outlined, 'Secure Payments', 'Safe and protected'),
      (Icons.storefront_outlined, 'Verified Sellers', 'Quality and trusted'),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C0F172A),
            blurRadius: 22,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: GridView.builder(
        itemCount: items.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: compact ? 1.92 : 2.15,
        ),
        itemBuilder: (context, index) {
          final item = items[index];
          return Container(
            padding: EdgeInsets.all(compact ? 8 : 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE8EDF3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: compact ? 34 : 36,
                  height: compact ? 34 : 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F6F8),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE8EDF3)),
                  ),
                  child: Icon(
                    item.$1,
                    color: const Color(0xFFB77905),
                    size: compact ? 16 : 18,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.$2,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: const Color(0xFF111827),
                          fontSize: compact ? 7.7 : 8.5,
                          height: 1.12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.$3,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: const Color(0xFF7B8493),
                          fontSize: compact ? 6.1 : 6.5,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _sectionHeader({
    required String title,
    required String actionText,
    required VoidCallback onAction,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 18, 12, 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFF201B17),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          TextButton(
            onPressed: onAction,
            child: Text(
              '$actionText  →',
              style: const TextStyle(
                color: Color(0xFF9A6815),
                fontSize: 8,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryRail() {
    return SizedBox(
      height: 130,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final category = categories[index];

          return InkWell(
            onTap: () => widget.onTabChanged?.call(1),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 118,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE8E1D8)),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      color: const Color(0xFFF6F2EB),
                      child: Icon(
                        category.icon,
                        color: const Color(0xFFB97810),
                        size: 34,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(9),
                    child: Text(
                      category.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF3A332C),
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
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

  Widget _featuredDeals() {
    const deals = [
      (
        'Watch Essentials',
        'Up to 50% OFF',
        'Timeless picks, better prices.',
        'assets/images/weekend-watch.png',
      ),
      (
        'Beauty Must-Haves',
        'Up to 40% OFF',
        'Everyday beauty essentials.',
        'assets/images/beauty-bestsellers.png',
      ),
      (
        'Home Upgrades',
        'Up to 35% OFF',
        'Simple upgrades for your space.',
        'assets/images/home-essentials.png',
      ),
    ];

    return SizedBox(
      height: 160,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        scrollDirection: Axis.horizontal,
        itemCount: deals.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final deal = deals[index];

          return InkWell(
            onTap: () => widget.onTabChanged?.call(1),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 260,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7E9),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFEADFCE)),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned(
                    left: 110,
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
                          const Color(0xFFFFF8EB),
                          const Color(0xFFFFF8EB).withValues(alpha: .92),
                          Colors.transparent,
                        ],
                        stops: const [0, .52, 1],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: 135,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              deal.$1,
                              style: const TextStyle(
                                color: Color(0xFF2A241F),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              deal.$2,
                              style: const TextStyle(
                                color: Color(0xFFBA7B0E),
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              deal.$3,
                              style: const TextStyle(
                                color: Color(0xFF7C7369),
                                fontSize: 7,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Shop Now →',
                              style: TextStyle(
                                color: Color(0xFFC98A17),
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
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
      padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CURATED MARKETPLACE',
            style: TextStyle(
              color: Color(0xFFAA7415),
              fontSize: 7,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 3),
          const Text(
            'Recommended for You',
            style: TextStyle(
              color: Color(0xFF201B17),
              fontSize: 19,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 30,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _filterChip('All', active: true),
                ...categories.map((category) {
                  return _filterChip(category.name);
                }),
              ],
            ),
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: featuredProducts.length,
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 9,
              mainAxisSpacing: 9,
              childAspectRatio: .45,
            ),
            itemBuilder: (context, index) {
              final product = featuredProducts[index];

              return BuyerProductCard(
                product: product,
                showPromotions: true,
                showStock: true,
                showQuickAdd: true,
                onTap: () => _showProductPreview(product),
                onAddToCart: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${product.name} added to cart'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                onBuyNow: () => _showProductPreview(product),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String text, {bool active = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 5),
      padding: const EdgeInsets.symmetric(horizontal: 11),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: active ? const Color(0xFFCB8B16) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: active
              ? const Color(0xFFCB8B16)
              : const Color(0xFFE8E1D8),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: active ? Colors.white : const Color(0xFF746B61),
          fontSize: 7,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _rewardsBanner(BuildContext context) {
    final compact = MediaQuery.of(context).size.width < 380;

    final copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Rewards & Vouchers',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Shop more. Earn more. Enjoy exclusive deals and vouchers.',
          style: TextStyle(
            color: Color(0xFFC8C0B7),
            fontSize: 7.6,
            height: 1.4,
          ),
        ),
      ],
    );

    final button = SizedBox(
      height: 38,
      child: ElevatedButton(
        onPressed: () => Navigator.push<void>(
          context,
          MaterialPageRoute(builder: (_) => const BuyerRewards()),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD39211),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 13),
        ),
        child: const Text('View Rewards', style: TextStyle(fontSize: 7.7)),
      ),
    );

    return Container(
      margin: const EdgeInsets.fromLTRB(10, 20, 10, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF272522),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF3A3732)),
      ),
      child: compact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _rewardImage(68),
                    const SizedBox(width: 10),
                    Expanded(child: copy),
                  ],
                ),
                const SizedBox(height: 11),
                button,
              ],
            )
          : Row(
              children: [
                _rewardImage(82),
                const SizedBox(width: 10),
                Expanded(child: copy),
                const SizedBox(width: 8),
                button,
              ],
            ),
    );
  }

  Widget _rewardImage(double size) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        'assets/images/reward-voucher.png',
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Icon(
          Icons.card_giftcard,
          color: Color(0xFFD39211),
          size: 44,
        ),
      ),
    );
  }

  Widget _trustSection(BuildContext context) {
    final compact = MediaQuery.of(context).size.width < 380;
    const items = [
      (Icons.verified_user_outlined, 'Quality Products', 'Shop with confidence from approved listings.'),
      (Icons.lock_outline, 'Secure Payments', 'Your checkout data stays protected.'),
      (Icons.inventory_2_outlined, 'Easy Returns', 'Hassle-free support for eligible purchases.'),
      (Icons.support_agent, '24/7 Support', 'Help is available whenever you need it.'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Trust & Buyer Protection',
            style: TextStyle(
              color: Color(0xFF201B17),
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          GridView.builder(
            itemCount: items.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: compact ? 1.70 : 1.90,
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              return Container(
                padding: EdgeInsets.all(compact ? 9 : 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE9E3DB)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: compact ? 32 : 35,
                      height: compact ? 32 : 35,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFFFF4DE),
                      ),
                      child: Icon(item.$1, color: const Color(0xFFB97810), size: 16),
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.$2,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: const Color(0xFF39322C),
                              fontSize: compact ? 7.5 : 8,
                              height: 1.12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.$3,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: const Color(0xFF938B82),
                              fontSize: compact ? 5.9 : 6.4,
                              height: 1.25,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _smallPill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .92),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFE4C98F)),
      ),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF996514),
          fontSize: 7,
          fontWeight: FontWeight.w700,
          letterSpacing: .7,
        ),
      ),
    );
  }

  void _showProductPreview(BuyerProduct product) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '₱${product.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Color(0xFFC67F08),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Product details screen will be connected when we convert product-details.blade.php.',
                style: TextStyle(
                  color: Color(0xFF7F776E),
                  fontSize: 10,
                  height: 1.5,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BuyerCategory {
  final String name;
  final IconData icon;

  const _BuyerCategory({
    required this.name,
    required this.icon,
  });
}

class _TrustMini extends StatelessWidget {
  final String label;

  const _TrustMini({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: const BoxDecoration(
            color: Color(0xFFC98A17),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: const Text(
            '✓',
            style: TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF6F675F),
            fontSize: 7.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
