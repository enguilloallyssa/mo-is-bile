import 'package:flutter/material.dart';

import '../services/sari_live_data.dart';
import 'buyer_product_details.dart';
import 'models/buyer_product_model.dart';
import 'widgets/buyer_header.dart';

class BuyerProducts extends StatefulWidget {
  final ValueChanged<int>? onTabChanged;
  final String initialSearch;

  const BuyerProducts({
    super.key,
    this.onTabChanged,
    this.initialSearch = '',
  });

  @override
  State<BuyerProducts> createState() =>
      _BuyerProductsState();
}

class _BuyerProductsState extends State<BuyerProducts> {
  static const Color gold = Color(0xFFCC8A0B);
  static const Color goldDark = Color(0xFFA96D07);
  static const Color dark = Color(0xFF24201C);
  static const Color muted = Color(0xFF7F776E);
  static const Color canvas = Color(0xFFFBFAF8);
  static const Color border = Color(0xFFE9E3DB);

  final TextEditingController _searchController =
      TextEditingController();

  final List<BuyerProduct> _products = [];

  bool _loading = true;
  bool _loadingMore = false;

  String? _error;

  String _sort = 'newest';

  int _page = 1;
  int _total = 0;
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

  Map<String, dynamic> _map(dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return {};
  }

  String _text(
    dynamic value, [
    String fallback = '',
  ]) {
    final text = value?.toString().trim() ?? '';

    return text.isEmpty ? fallback : text;
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

  BuyerProduct _parseProduct(dynamic raw) {
    final data = _map(raw);

    return BuyerProduct(
      id: _integer(data['id']),
      name: _text(
        data['name'],
        'Unnamed Product',
      ),
      category: _text(
        data['category'],
        'General',
      ),
      brand: _text(data['brand']),
      description: _text(data['description']),
      image: _text(data['image_url']).isEmpty
          ? null
          : _text(data['image_url']),
      price: _decimal(data['price']),

      // Mobile catalog API does not expose the same
      // buyer-facing old_price structure as the web
      // catalog, so do not invent one here.
      oldPrice: null,

      stock: _integer(data['stock']),
      shopName: _text(
        data['store_name'],
        'SARI Store',
      ),
      sellerAccountId: _integer(
        data['seller_id'],
      ),
    );
  }

  Future<void> _loadProducts({
    bool loadMore = false,
  }) async {
    if (loadMore &&
        (_loading || _loadingMore || !_hasMore)) {
      return;
    }

    final requestVersion = loadMore
        ? _requestVersion
        : ++_requestVersion;

    final requestedPage = loadMore ? _page + 1 : 1;

    setState(() {
      if (loadMore) {
        _loadingMore = true;
      } else {
        _loading = true;
        _error = null;
        _page = 1;
        _total = 0;
        _hasMore = true;
        _products.clear();
      }
    });

    try {
      final search = _searchController.text.trim();

      final response =
          await SariLiveData.instance.products(
        page: requestedPage,
        perPage: 15,
        search: search.isEmpty ? null : search,
        sort: _sort,
      );

      final rawData = response['data'];

      if (rawData is! List) {
        throw const FormatException(
          'Invalid product response from SARI.',
        );
      }

      final meta = _map(response['meta']);

      final loadedProducts = rawData
          .map(_parseProduct)
          .where(
            (product) => product.id > 0,
          )
          .toList();

      if (!mounted ||
          requestVersion != _requestVersion) {
        return;
      }

      setState(() {
        final existingIds =
            _products.map((e) => e.id).toSet();

        for (final product in loadedProducts) {
          if (existingIds.add(product.id)) {
            _products.add(product);
          }
        }

        _page = requestedPage;

        _total = _integer(
          meta['total'],
        );

        final lastPage = _integer(
          meta['last_page'],
        );

        _hasMore = lastPage > 0
            ? requestedPage < lastPage
            : rawData.length == 15;

        _loading = false;
        _loadingMore = false;
      });
    } catch (error) {
      if (!mounted ||
          requestVersion != _requestVersion) {
        return;
      }

      setState(() {
        _error = error.toString();
        _loading = false;
        _loadingMore = false;
      });
    }
  }

  Future<void> _openProduct(
    BuyerProduct product,
  ) async {
    try {
      final response =
          await SariLiveData.instance.productDetails(
        product.id,
      );

      final raw = response['data'];

      if (raw is! Map) {
        throw const FormatException(
          'Invalid product details from SARI.',
        );
      }

      final fullProduct = _parseProduct(raw);

      if (!mounted) return;

      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => BuyerProductDetails(
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
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
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

  Widget _pageHeading() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SHOP PRODUCTS',
          style: TextStyle(
            color: goldDark,
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 5),
        Text(
          'Shop Products',
          style: TextStyle(
            color: dark,
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.7,
          ),
        ),
        SizedBox(height: 5),
        Text(
          'Browse products across the SARI marketplace.',
          style: TextStyle(
            color: muted,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _searchField() {
    return TextField(
      controller: _searchController,
      textInputAction: TextInputAction.search,
      onSubmitted: (_) => _loadProducts(),
      decoration: InputDecoration(
        labelText: 'Search products',
        hintText:
            'Product name or brand...',
        prefixIcon: const Icon(
          Icons.search_rounded,
        ),
        suffixIcon: _searchController.text.isEmpty
            ? null
            : IconButton(
                tooltip: 'Clear search',
                onPressed: () {
                  _searchController.clear();

                  setState(() {});

                  _loadProducts();
                },
                icon: const Icon(
                  Icons.close_rounded,
                ),
              ),
      ),
      onChanged: (_) {
        setState(() {});
      },
    );
  }

  Widget _sortControl() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: border,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _sort,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
          ),
          items: const [
            DropdownMenuItem(
              value: 'newest',
              child: Text(
                'Newest',
              ),
            ),
            DropdownMenuItem(
              value: 'price_low',
              child: Text(
                'Price: Low to High',
              ),
            ),
            DropdownMenuItem(
              value: 'price_high',
              child: Text(
                'Price: High to Low',
              ),
            ),
          ],
          onChanged: (value) {
            if (value == null ||
                value == _sort) {
              return;
            }

            setState(() {
              _sort = value;
            });

            _loadProducts();
          },
        ),
      ),
    );
  }

  Widget _resultSummary() {
    final countText = _total > 0
        ? '$_total products'
        : '${_products.length} products';

    return Row(
      children: [
        Expanded(
          child: Text(
            countText,
            style: const TextStyle(
              color: muted,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (_searchController.text.trim().isNotEmpty)
          Text(
            'Search Results',
            style: const TextStyle(
              color: goldDark,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
      ],
    );
  }

  Widget _productGrid() {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(
          vertical: 60,
        ),
        child: Center(
          child: CircularProgressIndicator(
            color: gold,
          ),
        ),
      );
    }

    if (_error != null && _products.isEmpty) {
      return _statusCard(
        icon: Icons.wifi_off_rounded,
        title: 'Unable to load products',
        message: _error!,
        retry: true,
      );
    }

    if (_products.isEmpty) {
      return _statusCard(
        icon: Icons.inventory_2_outlined,
        title: 'No products match your filters',
        message:
            'Try another search term or sort option.',
      );
    }

    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics:
              const NeverScrollableScrollPhysics(),
          itemCount: _products.length,
          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            mainAxisExtent: 276,
          ),
          itemBuilder: (_, index) {
            return _productCard(
              _products[index],
            );
          },
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(
            'Some products could not be loaded.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: muted,
              fontSize: 10,
            ),
          ),
        ],
        if (_hasMore) ...[
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _loadingMore
                  ? null
                  : () => _loadProducts(
                        loadMore: true,
                      ),
              icon: _loadingMore
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(
                      Icons.expand_more_rounded,
                    ),
              label: Text(
                _loadingMore
                    ? 'Loading...'
                    : 'Load More Products',
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _productCard(
    BuyerProduct product,
  ) {
    final image =
        product.image?.trim() ?? '';

    return Material(
      color: Colors.white,
      borderRadius:
          BorderRadius.circular(14),
      child: InkWell(
        onTap: () =>
            _openProduct(product),
        borderRadius:
            BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(14),
            border: Border.all(
              color: border,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 158,
                width: double.infinity,
                child: image.isEmpty
                    ? _imagePlaceholder()
                    : Image.network(
                        image,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, __, ___) =>
                                _imagePlaceholder(),
                      ),
              ),
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.all(11),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.category
                            .toUpperCase(),
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: goldDark,
                          fontSize: 8,
                          fontWeight:
                              FontWeight.w800,
                          letterSpacing: .6,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow:
                            TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: dark,
                          fontSize: 11.5,
                          height: 1.2,
                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),
                      if (product.brand
                          .trim()
                          .isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          product.brand,
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: muted,
                            fontSize: 8.5,
                          ),
                        ),
                      ],
                      const Spacer(),
                      Text(
                        '₱${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: gold,
                          fontSize: 16,
                          fontWeight:
                              FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        product.stock > 0
                            ? '${product.stock} in stock'
                            : 'Out of Stock',
                        style: TextStyle(
                          color: product.stock > 0
                              ? muted
                              : Colors.redAccent,
                          fontSize: 8.5,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return const ColoredBox(
      color: Color(0xFFF4F4F4),
      child: Center(
        child: Icon(
          Icons.inventory_2_outlined,
          color: Color(0xFFAAAEB5),
          size: 42,
        ),
      ),
    );
  }

  Widget _statusCard({
    required IconData icon,
    required String title,
    required String message,
    bool retry = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color: border,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: muted,
            size: 42,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: dark,
              fontSize: 14,
              fontWeight:
                  FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: muted,
              fontSize: 10,
              height: 1.5,
            ),
          ),
          if (retry) ...[
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed:
                  _loadProducts,
              icon: const Icon(
                Icons.refresh_rounded,
              ),
              label: const Text(
                'Try Again',
              ),
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
      body: Column(
        children: [
          BuyerHeader(
            pageTitle: 'Shop Products',
            cartCount: 0,
            notificationCount: 0,
            onSearchTap: () {},
            onCartTap: _openCart,
            onNotificationTap:
                _openNotifications,
            onProfileTap: _openAccount,
          ),
          Expanded(
            child: RefreshIndicator(
              color: gold,
              onRefresh: () =>
                  _loadProducts(),
              child: ListView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                padding:
                    const EdgeInsets.fromLTRB(
                  14,
                  18,
                  14,
                  30,
                ),
                children: [
                  _pageHeading(),
                  const SizedBox(height: 20),
                  _searchField(),
                  const SizedBox(height: 12),
                  const Text(
                    'Sort By',
                    style: TextStyle(
                      color: dark,
                      fontSize: 10,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _sortControl(),
                  const SizedBox(height: 15),
                  _resultSummary(),
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