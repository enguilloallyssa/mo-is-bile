
import 'package:flutter/material.dart';

import '../services/sari_live_data.dart';
import 'models/buyer_product_model.dart';
import 'widgets/buyer_header.dart';
import 'widgets/buyer_product_card.dart';
import 'buyer_product_details.dart';

class BuyerProducts extends StatefulWidget {
  final ValueChanged<int>? onTabChanged;
  final String initialSearch;

  const BuyerProducts({
    super.key,
    this.onTabChanged,
    this.initialSearch = '',
  });

  @override
  State<BuyerProducts> createState() => _BuyerProductsState();
}

class _BuyerProductsState extends State<BuyerProducts> {
  static const Color gold = Color(0xFFD9950B);
  static const Color dark = Color(0xFF292929);
  static const Color canvas = Color(0xFFF4F5F7);
  static const Color border = Color(0xFFE6E8EC);

  final TextEditingController _searchController =
      TextEditingController();

  final List<BuyerProduct> _products = [];

  String _category = 'All';
  String _sort = 'newest';
  String? _error;

  bool _loading = false;
  bool _loadingMore = false;

  int _page = 1;
  bool _hasMore = true;
  int _requestVersion = 0;

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.initialSearch;
    _loadProducts();
  }

  @override
  void dispose() {
    _requestVersion++;
    _searchController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return {};
  }

  List<dynamic> _asList(dynamic value) {
    return value is List ? value : [];
  }

  String _string(dynamic value, [String fallback = '']) {
    if (value == null) return fallback;
    return value.toString();
  }

  int _integer(dynamic value) {
    return int.tryParse(_string(value)) ?? 0;
  }

  double _decimal(dynamic value) {
    return double.tryParse(_string(value)) ?? 0;
  }

  BuyerProduct _mapProduct(dynamic raw) {
    final data = _asMap(raw);

    final price = _decimal(data['price']);
    final discount = _decimal(data['discount']);

    return BuyerProduct(
      id: _integer(data['id']),
      name: _string(data['name'], 'Unnamed product'),
      category: _string(data['category'], 'Other'),
      brand: _string(data['brand']),
      description: _string(data['description']),
      image: _string(data['image_url']).isEmpty
          ? null
          : _string(data['image_url']),
      price: price,
      oldPrice: discount > 0 && discount < 100
          ? price / (1 - discount / 100)
          : null,
      stock: _integer(data['stock']),
      shopName: _string(data['store_name'], 'SARI Store'),
      sellerAccountId: _integer(data['seller_id']),
    );
  }

  Future<void> _loadProducts({
    bool loadMore = false,
  }) async {
    if (loadMore && (_loading || _loadingMore || !_hasMore)) {
      return;
    }

    final version = loadMore
        ? _requestVersion
        : ++_requestVersion;

    final requestedPage = loadMore ? _page + 1 : 1;

    setState(() {
      if (loadMore) {
        _loadingMore = true;
      } else {
        _loading = true;
        _error = null;
        _products.clear();
        _page = 1;
        _hasMore = true;
      }
    });

    try {
      final response = await SariLiveData.instance.products(
        page: requestedPage,
        perPage: 15,
        search: _searchController.text.trim().isEmpty
            ? null
            : _searchController.text.trim(),
        sort: _sort,
      );

      final records = _asList(response['data']);
      final meta = _asMap(response['meta']);

      final products = records
          .map(_mapProduct)
          .where((product) => product.id > 0)
          .toList();

      if (!mounted || version != _requestVersion) return;

      setState(() {
        _products.addAll(products);
        _page = requestedPage;

        final lastPage = _integer(meta['last_page']);

        _hasMore = lastPage > 0
            ? requestedPage < lastPage
            : records.length == 15;

        _loading = false;
        _loadingMore = false;
      });
    } catch (error) {
      if (!mounted || version != _requestVersion) return;

      setState(() {
        _error = error.toString();
        _loading = false;
        _loadingMore = false;
      });
    }
  }

  List<String> get _categories {
    final values = _products
        .map((product) => product.category)
        .where((value) => value.trim().isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    return ['All', ...values];
  }

  List<BuyerProduct> get _visibleProducts {
    final filtered = _products.where((product) {
      return _category == 'All' ||
          product.category == _category;
    }).toList();

    if (_sort == 'price-low') {
      filtered.sort((a, b) => a.price.compareTo(b.price));
    } else if (_sort == 'price-high') {
      filtered.sort((a, b) => b.price.compareTo(a.price));
    }

    return filtered;
  }

  Future<void> _openDetails(BuyerProduct product) async {
    try {
      final response =
          await SariLiveData.instance.productDetails(product.id);

      final raw = _asMap(response['data']);
      final fullProduct = _mapProduct(raw);

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
          content: Text(
            'Unable to load product details: $error',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _searchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        onSubmitted: (_) => _loadProducts(),
        decoration: InputDecoration(
          hintText: 'Search products...',
          hintStyle: const TextStyle(
            color: Color(0xFF98A0AA),
            fontSize: 13,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFF818A97),
          ),
          suffixIcon: IconButton(
            icon: const Icon(Icons.arrow_forward_rounded),
            onPressed: () => _loadProducts(),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 8,
          ),
        ),
      ),
    );
  }

  Widget _categoryFilters() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = _categories[index];
          final selected = category == _category;

          return ChoiceChip(
            label: Text(category),
            selected: selected,
            selectedColor: const Color(0xFFFFF2D5),
            backgroundColor: Colors.white,
            side: BorderSide(
              color: selected ? gold : border,
            ),
            labelStyle: TextStyle(
              color: selected ? gold : dark,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
            onSelected: (_) {
              setState(() => _category = category);
            },
          );
        },
      ),
    );
  }

  Widget _heading() {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Discover Products',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  color: dark,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Explore products from SARI sellers',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF818A97),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF2D5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.storefront_outlined,
            color: gold,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _sortAndCount() {
    return Row(
      children: [
        Expanded(
          child: Text(
            '${_visibleProducts.length} loaded products',
            style: const TextStyle(
              color: Color(0xFF667085),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        DropdownButton<String>(
          value: _sort,
          underline: const SizedBox.shrink(),
          style: const TextStyle(
            color: dark,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          items: const [
            DropdownMenuItem(
              value: 'newest',
              child: Text('Newest'),
            ),
            DropdownMenuItem(
              value: 'price-low',
              child: Text('Price: Low to High'),
            ),
            DropdownMenuItem(
              value: 'price-high',
              child: Text('Price: High to Low'),
            ),
          ],
          onChanged: (value) {
            if (value == null) return;

            setState(() {
              _sort = value;
            });

            _loadProducts();
          },
        ),
      ],
    );
  }

  Widget _messageState({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onRetry,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Column(
          children: [
            Icon(
              icon,
              size: 42,
              color: const Color(0xFFB0B7C3),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: dark,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF818A97),
                fontSize: 12,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _productGrid() {
    final items = _visibleProducts;

    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(
          child: CircularProgressIndicator(color: gold),
        ),
      );
    }

    if (_error != null && _products.isEmpty) {
      return _messageState(
        icon: Icons.wifi_off_rounded,
        title: 'Could not load products',
        subtitle: _error!,
        onRetry: () => _loadProducts(),
      );
    }

    if (items.isEmpty) {
      return _messageState(
        icon: Icons.inventory_2_outlined,
        title: 'No products found',
        subtitle: 'Try another search or category.',
      );
    }

    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            final columns = width >= 650
                ? 3
                : 2;

            return GridView.builder(
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
                  showPromotions: true,
                  showStock: true,
                  showQuickAdd: false,
                  onTap: () => _openDetails(product),
                );
              },
            );
          },
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              'More products could not be loaded: $_error',
              textAlign: TextAlign.center,
            ),
          ),
        if (_hasMore) ...[
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed:
                _loadingMore ? null : () => _loadProducts(loadMore: true),
            icon: _loadingMore
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.expand_more_rounded),
            label: Text(
              _loadingMore ? 'Loading...' : 'Load More Products',
            ),
          ),
        ],
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
            pageTitle: 'Shop Products',
            cartCount: 0,
            onSearchTap: () {},
            onCartTap: () => widget.onTabChanged?.call(2),
            onProfileTap: () => widget.onTabChanged?.call(4),
          ),
          Expanded(
            child: RefreshIndicator(
              color: gold,
              onRefresh: () => _loadProducts(),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  14, 18, 14, 28,
                ),
                children: [
                  _heading(),
                  const SizedBox(height: 20),
                  _searchBar(),
                  const SizedBox(height: 14),
                  _categoryFilters(),
                  const SizedBox(height: 16),
                  _sortAndCount(),
                  const SizedBox(height: 12),
                  _productGrid(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
