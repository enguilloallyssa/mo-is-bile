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
  State<BuyerHome> createState() =>
      _BuyerHomeState();
}

class _BuyerHomeState extends State<BuyerHome> {
  static const Color gold =
      Color(0xFFCC8A0B);
  static const Color goldDark =
      Color(0xFFA96D07);
  static const Color dark =
      Color(0xFF24201C);
  static const Color muted =
      Color(0xFF7F776E);
  static const Color canvas =
      Color(0xFFFBFAF8);
  static const Color border =
      Color(0xFFE9E3DB);

  final List<BuyerProduct> _products = [];

  bool _loading = true;
  String? _error;

  static const _categoryItems = <
      ({
        String name,
        IconData icon,
      })>[
    (
      name: 'Fashion',
      icon: Icons.checkroom_outlined,
    ),
    (
      name: 'Electronics',
      icon: Icons.devices_outlined,
    ),
    (
      name: 'Home & Living',
      icon: Icons.chair_outlined,
    ),
    (
      name: 'Beauty',
      icon: Icons.spa_outlined,
    ),
    (
      name: 'Accessories',
      icon: Icons.watch_outlined,
    ),
    (
      name: 'Food & Essentials',
      icon: Icons.shopping_basket_outlined,
    ),
    (
      name: 'Sports',
      icon: Icons.sports_basketball_outlined,
    ),
    (
      name: 'Lifestyle',
      icon: Icons.self_improvement_outlined,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Map<String, dynamic> _map(
    dynamic value,
  ) {
    if (value is Map) {
      return Map<String, dynamic>.from(
        value,
      );
    }

    return {};
  }

  String _text(
    dynamic value, [
    String fallback = '',
  ]) {
    final text =
        value?.toString().trim() ?? '';

    return text.isEmpty
        ? fallback
        : text;
  }

  int _integer(dynamic value) {
    if (value is num) {
      return value.toInt();
    }

    return int.tryParse('$value') ?? 0;
  }

  double _decimal(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse('$value') ?? 0;
  }

  BuyerProduct _parseProduct(
    dynamic raw,
  ) {
    final data = _map(raw);

    return BuyerProduct(
      id: _integer(
        data['id'],
      ),
      name: _text(
        data['name'],
        'Unnamed Product',
      ),
      category: _text(
        data['category'],
        'General',
      ),
      brand: _text(
        data['brand'],
      ),
      description: _text(
        data['description'],
      ),
      image: _text(
        data['image_url'],
      ).isEmpty
          ? null
          : _text(
              data['image_url'],
            ),
      price: _decimal(
        data['price'],
      ),
      oldPrice: null,
      stock: _integer(
        data['stock'],
      ),
      shopName: _text(
        data['store_name'],
        'SARI Store',
      ),
      sellerAccountId: _integer(
        data['seller_id'],
      ),
    );
  }

  Future<void> _loadProducts() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response =
          await SariLiveData.instance.products(
        page: 1,
        perPage: 8,
      );

      final raw = response['data'];

      if (raw is! List) {
        throw const FormatException(
          'Invalid product response from SARI.',
        );
      }

      final products = raw
          .map(_parseProduct)
          .where(
            (product) => product.id > 0,
          )
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

  void _openShop() {
    widget.onTabChanged?.call(1);
  }

  void _openCart() {
    widget.onTabChanged?.call(2);
  }

  void _openNotifications() {
    widget.onTabChanged?.call(5);
  }

  void _openAccount() {
    widget.onTabChanged?.call(4);
  }

  Future<void> _openProduct(
    BuyerProduct product,
  ) async {
    try {
      final response =
          await SariLiveData.instance
              .productDetails(
        product.id,
      );

      final raw = response['data'];

      if (raw is! Map) {
        throw const FormatException(
          'Invalid product details.',
        );
      }

      final fullProduct =
          _parseProduct(raw);

      if (!mounted) return;

      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) =>
              BuyerProductDetails(
            product: fullProduct,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              'Unable to load product: $error',
            ),
            behavior:
                SnackBarBehavior.floating,
          ),
        );
    }
  }

  Widget _hero() {
    return Container(
      margin:
          const EdgeInsets.fromLTRB(
        14,
        14,
        14,
        0,
      ),
      padding:
          const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color:
            const Color(0xFFFFFAF1),
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color:
              const Color(0xFFEADFCE),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'SARI MARKETPLACE',
            style: TextStyle(
              color: goldDark,
              fontSize: 9,
              fontWeight:
                  FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            'Variety You Need,',
            style: TextStyle(
              color: dark,
              fontSize: 28,
              height: 1.08,
              fontWeight:
                  FontWeight.w800,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 3),
          const Text(
            'Convenience You Deserve.',
            style: TextStyle(
              color: goldDark,
              fontSize: 28,
              height: 1.08,
              fontWeight:
                  FontWeight.w800,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 13),
          const Text(
            'A trusted marketplace for curated finds, everyday essentials, and effortless shopping.',
            style: TextStyle(
              color: muted,
              fontSize: 11,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _openShop,
              icon: const Icon(
                Icons
                    .shopping_bag_outlined,
              ),
              label: const Text(
                'Shop Now',
              ),
              style:
                  ElevatedButton.styleFrom(
                backgroundColor: gold,
                foregroundColor:
                    Colors.white,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(
                  vertical: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _benefits() {
    const items = [
      (
        Icons.local_shipping_outlined,
        'Free Shipping',
        'On eligible orders',
      ),
      (
        Icons.card_giftcard_outlined,
        'Earn Rewards',
        'Shop and earn points',
      ),
      (
        Icons.shield_outlined,
        'Secure Payments',
        'Safe and protected',
      ),
      (
        Icons.storefront_outlined,
        'Verified Sellers',
        'Quality and trusted',
      ),
    ];

    return Container(
      margin:
          const EdgeInsets.fromLTRB(
        14,
        12,
        14,
        0,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(14),
        border:
            Border.all(color: border),
      ),
      child: Column(
        children: List.generate(
          items.length,
          (index) {
            final item = items[index];

            return Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.all(
                    13,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        alignment:
                            Alignment.center,
                        decoration:
                            BoxDecoration(
                          color:
                              const Color(
                            0xFFFFF3DA,
                          ),
                          borderRadius:
                              BorderRadius.circular(
                            10,
                          ),
                        ),
                        child: Icon(
                          item.$1,
                          color: goldDark,
                          size: 20,
                        ),
                      ),
                      const SizedBox(
                        width: 11,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Text(
                              item.$2,
                              style:
                                  const TextStyle(
                                color: dark,
                                fontSize: 12,
                                fontWeight:
                                    FontWeight
                                        .w700,
                              ),
                            ),
                            Text(
                              item.$3,
                              style:
                                  const TextStyle(
                                color: muted,
                                fontSize: 9,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (index <
                    items.length - 1)
                  const Divider(
                    height: 1,
                    color: border,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _categoriesSection() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Padding(
          padding:
              EdgeInsets.fromLTRB(
            14,
            24,
            14,
            12,
          ),
          child: Text(
            'Shop by Category',
            style: TextStyle(
              color: dark,
              fontSize: 19,
              fontWeight:
                  FontWeight.w800,
            ),
          ),
        ),
        SizedBox(
          height: 112,
          child: ListView.separated(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 14,
            ),
            scrollDirection:
                Axis.horizontal,
            itemCount:
                _categoryItems.length,
            separatorBuilder:
                (context, index) =>
                    const SizedBox(
              width: 9,
            ),
            itemBuilder:
                (context, index) {
              final category =
                  _categoryItems[index];

              return InkWell(
                onTap: _openShop,
                borderRadius:
                    BorderRadius.circular(
                  12,
                ),
                child: Container(
                  width: 103,
                  padding:
                      const EdgeInsets.all(
                    10,
                  ),
                  decoration:
                      BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
                    border: Border.all(
                      color: border,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .center,
                    children: [
                      Icon(
                        category.icon,
                        color: goldDark,
                        size: 28,
                      ),
                      const SizedBox(
                        height: 9,
                      ),
                      Text(
                        category.name,
                        maxLines: 2,
                        textAlign:
                            TextAlign.center,
                        overflow:
                            TextOverflow
                                .ellipsis,
                        style:
                            const TextStyle(
                          color: dark,
                          fontSize: 9,
                          fontWeight:
                              FontWeight
                                  .w700,
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

  Widget _recommended() {
    return Column(
      children: [
        Padding(
          padding:
              const EdgeInsets.fromLTRB(
            14,
            25,
            14,
            12,
          ),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Recommended for You',
                  style: TextStyle(
                    color: dark,
                    fontSize: 19,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
              ),
              TextButton(
                onPressed: _openShop,
                child: const Text(
                  'View All',
                ),
              ),
            ],
          ),
        ),
        if (_loading)
          const Padding(
            padding:
                EdgeInsets.symmetric(
              vertical: 50,
            ),
            child: Center(
              child:
                  CircularProgressIndicator(
                color: gold,
              ),
            ),
          )
        else if (_error != null)
          _statusCard(
            Icons.wifi_off_rounded,
            'Unable to load products',
            _error!,
          )
        else if (_products.isEmpty)
          _statusCard(
            Icons.inventory_2_outlined,
            'No products available',
            'Approved seller products will appear here.',
          )
        else
          Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 14,
            ),
            child: GridView.builder(
              shrinkWrap: true,
              physics:
                  const NeverScrollableScrollPhysics(),
              itemCount:
                  _products.length,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                mainAxisExtent: 285,
              ),
              itemBuilder:
                  (context, index) {
                final product =
                    _products[index];

                return BuyerProductCard(
                  product: product,
                  showPromotions: false,
                  showStock: true,
                  showQuickAdd: false,
                  onTap: () =>
                      _openProduct(
                    product,
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _statusCard(
    IconData icon,
    String title,
    String message,
  ) {
    return Container(
      margin:
          const EdgeInsets.symmetric(
        horizontal: 14,
      ),
      padding:
          const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(14),
        border:
            Border.all(color: border),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: muted,
            size: 40,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: dark,
              fontWeight:
                  FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: muted,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _loadProducts,
            icon: const Icon(
              Icons.refresh,
            ),
            label: const Text(
              'Try Again',
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: canvas,
      body: Column(
        children: [
          BuyerHeader(
            pageTitle: 'Home',
            cartCount: 0,
            notificationCount: 0,
            onSearchTap: _openShop,
            onCartTap: _openCart,
            onNotificationTap:
                _openNotifications,
            onProfileTap:
                _openAccount,
          ),
          Expanded(
            child: RefreshIndicator(
              color: gold,
              onRefresh:
                  _loadProducts,
              child: ListView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                padding:
                    const EdgeInsets.only(
                  bottom: 30,
                ),
                children: [
                  _hero(),
                  _benefits(),
                  _categoriesSection(),
                  _recommended(),
                  const SizedBox(
                    height: 24,
                  ),
                  const Center(
                    child: Text(
                      'SARI • Elevated Everyday',
                      style: TextStyle(
                        color: muted,
                        fontSize: 10,
                        fontWeight:
                            FontWeight.w600,
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