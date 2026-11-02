
import 'package:flutter/material.dart';

import '../services/sari_live_data.dart';
import 'buyer_product_details.dart';
import 'models/buyer_product_model.dart';
import 'models/buyer_shop_model.dart';
import 'widgets/buyer_product_card.dart';

class BuyerShop extends StatefulWidget {
  final BuyerShopData shop;

  const BuyerShop({
    super.key,
    required this.shop,
  });

  @override
  State<BuyerShop> createState() => _BuyerShopState();
}

class _BuyerShopState extends State<BuyerShop> {
  static const Color gold = Color(0xFFD9950B);
  static const Color dark = Color(0xFF292929);
  static const Color canvas = Color(0xFFF4F5F7);
  static const Color border = Color(0xFFE6E8EC);
  static const Color muted = Color(0xFF818A97);

  final TextEditingController _search = TextEditingController();

  final List<BuyerProduct> _products = [];

  bool _loading = true;
  bool _incomplete = false;
  String? _error;
  int _loadVersion = 0;

  // The current public API does not have a confirmed
  // seller-specific listing endpoint. Check up to
  // five pages rather than claiming all seller products
  // have been retrieved.
  static const int _maxPages = 5;
  static const int _perPage = 30;

  @override
  void initState() {
    super.initState();
    _loadShopProducts();
  }

  @override
  void dispose() {
    _loadVersion++;
    _search.dispose();
    super.dispose();
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return <String, dynamic>{};
  }

  String _text(dynamic value, [String fallback = '']) {
    if (value == null) return fallback;

    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }

  int _integer(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(_text(value)) ?? 0;
  }

  double _decimal(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(_text(value)) ?? 0;
  }

  BuyerProduct _parseProduct(dynamic raw) {
    final data = _asMap(raw);

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
      shopName: _text(
        data['store_name'],
        widget.shop.storeName,
      ),
      sellerAccountId: _integer(data['seller_id']),
    );
  }

  Future<void> _loadShopProducts() async {
    final version = ++_loadVersion;

    setState(() {
      _loading = true;
      _error = null;
      _incomplete = false;
      _products.clear();
    });

    final found = <int, BuyerProduct>{};
    bool incomplete = false;
    String? fetchError;

    try {
      for (int page = 1; page <= _maxPages; page++) {
        final response =
            await SariLiveData.instance.products(
          page: page,
          perPage: _perPage,
        );

        final raw = response['data'];

        if (raw is! List) {
          throw const FormatException(
            'Invalid product list returned by Laravel.',
          );
        }

        for (final item in raw) {
          final product = _parseProduct(item);

          if (product.id <= 0) continue;

          if (product.sellerAccountId ==
              widget.shop.sellerAccountId) {
            found[product.id] = product;
          }
        }

        final meta = _asMap(response['meta']);
        final lastPage = _integer(meta['last_page']);

        if (lastPage > 0 && page >= lastPage) {
          break;
        }

        if (raw.length < _perPage) {
          break;
        }

        if (page == _maxPages) {
          incomplete = true;
        }
      }
    } catch (error) {
      fetchError = error.toString();
      incomplete = true;
    }

    if (!mounted || version != _loadVersion) return;

    setState(() {
      _products
        ..clear()
        ..addAll(found.values);

      _incomplete = incomplete;
      _error = fetchError;
      _loading = false;
    });
  }

  List<BuyerProduct> get _filteredProducts {
    final query = _search.text.trim().toLowerCase();

    if (query.isEmpty) {
      return List<BuyerProduct>.from(_products);
    }

    return _products.where((product) {
      return product.name.toLowerCase().contains(query) ||
          product.category.toLowerCase().contains(query) ||
          product.brand.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> _openProduct(BuyerProduct product) async {
    try {
      final response =
          await SariLiveData.instance.productDetails(
        product.id,
      );

      final details = _parseProduct(response['data']);

      if (details.id != product.id ||
          details.sellerAccountId !=
              widget.shop.sellerAccountId) {
        throw const FormatException(
          'Product details do not match this shop.',
        );
      }

      if (!mounted) return;

      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => BuyerProductDetails(
            product: details,
            relatedProducts: _products
                .where((item) => item.id != details.id)
                .take(6)
                .toList(),
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to load product details: $error',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _panel({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(16),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _shopProfile() {
    final shop = widget.shop;

    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 110,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3DD),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.storefront_outlined,
              color: gold,
              size: 55,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0D0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.store_rounded,
                  color: gold,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SARI SELLER SHOP',
                      style: TextStyle(
                        color: gold,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      shop.storeName,
                      style: const TextStyle(
                        color: dark,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Seller ID: ${shop.sellerAccountId}',
                      style: const TextStyle(
                        color: muted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: border),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.inventory_2_outlined,
                color: gold,
                size: 19,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  '${_products.length} products loaded',
                  style: const TextStyle(
                    color: dark,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (_loading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    color: gold,
                    strokeWidth: 2,
                  ),
                ),
            ],
          ),
          if (shop.description.trim().isNotEmpty) ...[
            const SizedBox(height: 15),
            const Text(
              'ABOUT THIS SHOP',
              style: TextStyle(
                color: dark,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              shop.description,
              style: const TextStyle(
                color: muted,
                fontSize: 12,
                height: 1.6,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _searchField() {
    return TextField(
      controller: _search,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: 'Search products in this shop...',
        hintStyle: const TextStyle(
          color: muted,
          fontSize: 12,
        ),
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: muted,
        ),
        suffixIcon: _search.text.isNotEmpty
            ? IconButton(
                onPressed: () {
                  _search.clear();
                  setState(() {});
                },
                icon: const Icon(
                  Icons.close_rounded,
                  size: 19,
                ),
              )
            : null,
        filled: true,
        fillColor: canvas,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: gold,
            width: 1.3,
          ),
        ),
      ),
    );
  }

  Widget _status({
    required IconData icon,
    required String title,
    required String message,
    bool retry = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 35),
      child: Center(
        child: Column(
          children: [
            Icon(
              icon,
              color: muted,
              size: 43,
            ),
            const SizedBox(height: 13),
            Text(
              title,
              style: const TextStyle(
                color: dark,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: muted,
                fontSize: 12,
                height: 1.6,
              ),
            ),
            if (retry) ...[
              const SizedBox(height: 15),
              OutlinedButton.icon(
                onPressed: _loadShopProducts,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _productsSection() {
    final products = _filteredProducts;

    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Shop Products',
            style: TextStyle(
              color: dark,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Browse available product listings.',
            style: TextStyle(
              color: muted,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 15),
          _searchField(),
          const SizedBox(height: 15),
          if (_incomplete)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF5E4),
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Text(
                'Only part of the marketplace listings '
                'could be checked. Some seller products '
                'may not appear here yet.',
                style: TextStyle(
                  color: Color(0xFF99670D),
                  fontSize: 11,
                  height: 1.5,
                ),
              ),
            ),
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: CircularProgressIndicator(
                  color: gold,
                ),
              ),
            )
          else if (_error != null && products.isEmpty)
            _status(
              icon: Icons.wifi_off_rounded,
              title: 'Unable to load products',
              message: _error!,
              retry: true,
            )
          else if (products.isEmpty)
            _status(
              icon: Icons.inventory_2_outlined,
              title: 'No products found',
              message: _incomplete
                  ? 'No matching products were found '
                      'in the pages checked.'
                  : 'No matching products are available.',
            )
          else ...[
            Text(
              '${products.length} matching loaded products',
              style: const TextStyle(
                color: muted,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns =
                    constraints.maxWidth >= 650 ? 3 : 2;

                return GridView.builder(
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(),
                  itemCount: products.length,
                  gridDelegate:
                      SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 9,
                    mainAxisSpacing: 9,
                    mainAxisExtent: 312,
                  ),
                  itemBuilder: (context, index) {
                    final product = products[index];

                    return BuyerProductCard(
                      product: product,
                      showPromotions: false,
                      showStock: true,
                      showQuickAdd: false,
                      onTap: () => _openProduct(product),
                    );
                  },
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: canvas,
      appBar: AppBar(
        title: const Text(
          'Seller Shop',
          style: TextStyle(
            color: dark,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: dark,
        surfaceTintColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loading ? null : _loadShopProducts,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: gold,
        onRefresh: _loadShopProducts,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            14, 18, 14, 30,
          ),
          children: [
            _shopProfile(),
            const SizedBox(height: 14),
            _productsSection(),
            const SizedBox(height: 22),
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
    );
  }
}
