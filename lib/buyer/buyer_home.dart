
import 'package:flutter/material.dart';

import '../services/sari_live_data.dart';
import 'buyer_product_details.dart';
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
  static const Color gold = Color(0xFFD9950B);
  static const Color dark = Color(0xFF292929);
  static const Color muted = Color(0xFF818A97);
  static const Color canvas = Color(0xFFF4F5F7);
  static const Color border = Color(0xFFE6E8EC);

  final List<BuyerProduct> _products = [];

  bool _loading = true;
  String? _error;

  final List<Map<String, String>> _categories = const [
    {
      'name': 'Fashion',
      'image': 'assets/images/buyer/cat-fashion.jpg',
    },
    {
      'name': 'Electronics',
      'image': 'assets/images/buyer/cat-electronics.jpg',
    },
    {
      'name': 'Home',
      'image': 'assets/images/buyer/cat-home.jpg',
    },
    {
      'name': 'Beauty',
      'image': 'assets/images/buyer/cat-beauty.jpg',
    },
    {
      'name': 'Accessories',
      'image': 'assets/images/buyer/cat-accessories.jpg',
    },
    {
      'name': 'Food',
      'image': 'assets/images/buyer/cat-food.jpg',
    },
    {
      'name': 'Sports',
      'image': 'assets/images/buyer/cat-sports.jpg',
    },
    {
      'name': 'Lifestyle',
      'image': 'assets/images/buyer/cat-lifestyle.jpg',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Map<String, dynamic> _map(dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return {};
  }

  String _text(dynamic value, [String fallback = '']) {
    if (value == null) return fallback;
    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }

  int _integer(dynamic value) {
    return int.tryParse(_text(value)) ?? 0;
  }

  double _decimal(dynamic value) {
    return double.tryParse(_text(value)) ?? 0;
  }

  BuyerProduct _parseProduct(dynamic raw) {
    final data = _map(raw);

    final price = _decimal(data['price']);
    final discount = _decimal(data['discount']);

    return BuyerProduct(
      id: _integer(data['id']),
      name: _text(data['name'], 'Unnamed Product'),
      category: _text(data['category'], 'Other'),
      brand: _text(data['brand']),
      description: _text(data['description']),
      image: _text(data['image_url']).isEmpty
          ? null
          : _text(data['image_url']),
      price: price,
      oldPrice: discount > 0 && discount < 100
          ? price / (1 - discount / 100)
          : null,
      stock: _integer(data['stock']),
      shopName: _text(data['store_name'], 'SARI Store'),
      sellerAccountId: _integer(data['seller_id']),
    );
  }

  Future<void> _loadProducts() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final response = await SariLiveData.instance.products(
        page: 1,
        perPage: 15,
      );

      final raw = response['data'];

      if (raw is! List) {
        throw const FormatException(
          'Invalid products response from Laravel.',
        );
      }

      final products = raw
          .map(_parseProduct)
          .where((product) => product.id > 0)
          .toList();

      if (!mounted) return;

      setState(() {
        _products
          ..clear()
          ..addAll(products);

        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  Future<void> _openProduct(BuyerProduct product) async {
    try {
      final response =
          await SariLiveData.instance.productDetails(
        product.id,
      );

      final data = _map(response['data']);
      final fullProduct = _parseProduct(data);

      if (fullProduct.id != product.id) {
        throw const FormatException(
          'Invalid product details received.',
        );
      }

      if (!mounted) return;

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => BuyerProductDetails(
            product: fullProduct,
            relatedProducts: _products
                .where((item) => item.id != product.id)
                .take(6)
                .toList(),
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to load product: $error'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _openShop() {
    widget.onTabChanged?.call(1);
  }

  Widget _sectionHeading(
    String title,
    String subtitle, {
    String action = 'View All',
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 23, 16, 12),
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
                    color: dark,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: muted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: _openShop,
            child: Text(
              action,
              style: const TextStyle(
                color: gold,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _hero() {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 14, 14, 0),
      constraints: const BoxConstraints(minHeight: 235),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6E5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFEEDCB7),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/buyer/sari-hero-bg.webp',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const SizedBox.shrink();
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'WELCOME TO SARI',
                    style: TextStyle(
                      color: gold,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  'Elevated\nEveryday.',
                  style: TextStyle(
                    color: dark,
                    fontSize: 30,
                    height: 1.1,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                const SizedBox(
                  width: 205,
                  child: Text(
                    'Discover products from local sellers, '
                    'all in one marketplace.',
                    style: TextStyle(
                      color: Color(0xFF675D4F),
                      fontSize: 11,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                ElevatedButton.icon(
                  onPressed: _openShop,
                  icon: const Icon(
                    Icons.shopping_bag_outlined,
                    size: 17,
                  ),
                  label: const Text('Shop Now'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: dark,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 19,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoriesSection() {
    return Column(
      children: [
        _sectionHeading(
          'Shop by Category',
          'Explore what you love',
        ),
        SizedBox(
          height: 135,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            separatorBuilder: (context, index) =>
                const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final category = _categories[index];

              return InkWell(
                onTap: _openShop,
                borderRadius: BorderRadius.circular(13),
                child: Container(
                  width: 106,
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: border),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(9),
                          child: Image.asset(
                            category['image']!,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (
                              context,
                              error,
                              stackTrace,
                            ) {
                              return const Icon(
                                Icons.category_outlined,
                                color: gold,
                                size: 30,
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        category['name']!,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: dark,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _loadingProducts() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 45),
      child: Center(
        child: CircularProgressIndicator(color: gold),
      ),
    );
  }

  Widget _emptyProducts() {
    return _statusPanel(
      icon: Icons.inventory_2_outlined,
      title: 'No products available',
      subtitle: 'No products were returned by the Laravel API.',
    );
  }

  Widget _errorProducts() {
    return _statusPanel(
      icon: Icons.wifi_off_rounded,
      title: 'Unable to load products',
      subtitle: _error ?? 'Please try again.',
      retry: true,
    );
  }

  Widget _statusPanel({
    required IconData icon,
    required String title,
    required String subtitle,
    bool retry = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.all(23),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          Icon(icon, size: 38, color: muted),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: dark,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: muted,
              fontSize: 11,
            ),
          ),
          if (retry) ...[
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: _loadProducts,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _productSection() {
    if (_loading) return _loadingProducts();
    if (_error != null) return _errorProducts();
    if (_products.isEmpty) return _emptyProducts();

    return Column(
      children: [
        _sectionHeading(
          'Latest Products',
          'Recently listed products from SARI sellers',
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns =
                constraints.maxWidth >= 650 ? 3 : 2;

            final items = _products.take(8).toList();

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                gridDelegate:
                    SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  mainAxisExtent: 312,
                ),
                itemBuilder: (context, index) {
                  final product = items[index];

                  return BuyerProductCard(
                    product: product,
                    showPromotions: false,
                    showStock: true,
                    showQuickAdd: false,
                    onTap: () => _openProduct(product),
                  );
                },
              ),
            );
          },
        ),
        const SizedBox(height: 18),
        OutlinedButton.icon(
          onPressed: _openShop,
          icon: const Icon(Icons.storefront_outlined),
          label: const Text('Explore More Products'),
          style: OutlinedButton.styleFrom(
            foregroundColor: dark,
            side: const BorderSide(color: border),
            padding: const EdgeInsets.symmetric(
              horizontal: 22,
              vertical: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _benefits() {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 26, 14, 12),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          const Text(
            'Why Shop with SARI?',
            style: TextStyle(
              color: dark,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 18),
          _benefitItem(
            Icons.storefront_outlined,
            'Local Marketplace',
            'Discover products from SARI sellers.',
          ),
          const Divider(color: border, height: 25),
          _benefitItem(
            Icons.phone_android_outlined,
            'Shop Anywhere',
            'Browse available products from your phone.',
          ),
          const Divider(color: border, height: 25),
          _benefitItem(
            Icons.receipt_long_outlined,
            'Order Information',
            'View your existing purchases through SARI.',
          ),
        ],
      ),
    );
  }

  Widget _benefitItem(
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF2DB),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, color: gold, size: 23),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: dark,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: muted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: canvas,
      body: Column(
        children: [
          BuyerHeader(
            pageTitle: 'Home',
            cartCount: 0,
            onSearchTap: _openShop,
            onCartTap: () => widget.onTabChanged?.call(2),
            onProfileTap: () => widget.onTabChanged?.call(6),
          ),
          Expanded(
            child: RefreshIndicator(
              color: gold,
              onRefresh: _loadProducts,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 25),
                children: [
                  _hero(),
                  _categoriesSection(),
                  _productSection(),
                  _benefits(),
                  const SizedBox(height: 13),
                  const Center(
                    child: Text(
                      'SARI • Elevated Everyday',
                      style: TextStyle(
                        color: muted,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
