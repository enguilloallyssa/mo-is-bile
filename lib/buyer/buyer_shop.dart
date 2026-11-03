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
  State<BuyerShop> createState() =>
      _BuyerShopState();
}

class _BuyerShopState
    extends State<BuyerShop> {
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

  static const int _maxPages = 5;
  static const int _perPage = 30;

  final TextEditingController
      _searchController =
      TextEditingController();

  final List<BuyerProduct>
      _products = [];

  bool _loading = true;
  bool _incomplete = false;

  String? _error;

  int _loadVersion = 0;

  @override
  void initState() {
    super.initState();

    _loadProducts();
  }

  @override
  void dispose() {
    _loadVersion++;

    _searchController.dispose();

    super.dispose();
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

  int _integer(
    dynamic value,
  ) {
    if (value is num) {
      return value.toInt();
    }

    return int.tryParse('$value') ?? 0;
  }

  double _decimal(
    dynamic value,
  ) {
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
      brand:
          _text(data['brand']),
      description:
          _text(data['description']),
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
        widget.shop.storeName,
      ),
      sellerAccountId:
          _integer(
        data['seller_id'],
      ),
    );
  }

  Future<void> _loadProducts()
      async {
    final version =
        ++_loadVersion;

    setState(() {
      _loading = true;
      _error = null;
      _incomplete = false;
      _products.clear();
    });

    try {
      final found =
          <BuyerProduct>[];

      var lastPage =
          _maxPages;

      for (var page = 1;
          page <= _maxPages;
          page++) {
        final response =
            await SariLiveData.instance
                .products(
          page: page,
          perPage: _perPage,
        );

        final raw =
            response['data'];

        if (raw is! List) {
          throw const FormatException(
            'Invalid products response from SARI.',
          );
        }

        for (final item in raw) {
          final product =
              _parseProduct(
            item,
          );

          if (product.id > 0 &&
              product.sellerAccountId ==
                  widget.shop
                      .sellerAccountId) {
            found.add(
              product,
            );
          }
        }

        final meta =
            _map(
          response['meta'],
        );

        final apiLastPage =
            _integer(
          meta['last_page'],
        );

        if (apiLastPage > 0) {
          lastPage =
              apiLastPage;
        }

        if (page >= lastPage ||
            raw.length <
                _perPage) {
          break;
        }
      }

      if (!mounted ||
          version !=
              _loadVersion) {
        return;
      }

      final unique =
          <int, BuyerProduct>{};

      for (final product in found) {
        unique[product.id] =
            product;
      }

      setState(() {
        _products
          ..clear()
          ..addAll(
            unique.values,
          );

        _incomplete =
            lastPage >
                _maxPages;

        _loading = false;
      });
    } catch (error) {
      if (!mounted ||
          version !=
              _loadVersion) {
        return;
      }

      setState(() {
        _loading = false;
        _error =
            error.toString();
      });
    }
  }

  List<BuyerProduct>
      get _filteredProducts {
    final query =
        _searchController.text
            .trim()
            .toLowerCase();

    if (query.isEmpty) {
      return _products;
    }

    return _products.where(
      (product) {
        return product.name
                .toLowerCase()
                .contains(query) ||
            product.category
                .toLowerCase()
                .contains(query) ||
            product.brand
                .toLowerCase()
                .contains(query);
      },
    ).toList();
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

      final raw =
          response['data'];

      if (raw is! Map) {
        throw const FormatException(
          'Invalid product details from SARI.',
        );
      }

      final details =
          _parseProduct(raw);

      if (!mounted) return;

      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) =>
              BuyerProductDetails(
            product: details,
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
              'Unable to load product details: $error',
            ),
            behavior:
                SnackBarBehavior.floating,
          ),
        );
    }
  }

  Widget _shopHeader() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
        border:
            Border.all(color: border),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            height: 64,
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
                14,
              ),
            ),
            child: const Icon(
              Icons.storefront_outlined,
              color: goldDark,
              size: 31,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  widget.shop.storeName,
                  style:
                      const TextStyle(
                    color: dark,
                    fontSize: 19,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
                if (widget.shop.description
                    .trim()
                    .isNotEmpty) ...[
                  const SizedBox(
                    height: 6,
                  ),
                  Text(
                    widget.shop.description,
                    maxLines: 3,
                    overflow:
                        TextOverflow
                            .ellipsis,
                    style:
                        const TextStyle(
                      color: muted,
                      fontSize: 10,
                      height: 1.5,
                    ),
                  ),
                ],
                const SizedBox(
                  height: 7,
                ),
                const Text(
                  'SARI marketplace seller',
                  style: TextStyle(
                    color: goldDark,
                    fontSize: 8,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusCard(
    IconData icon,
    String title,
    String message,
  ) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(25),
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
            size: 43,
            color: muted,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign:
                TextAlign.center,
            style:
                const TextStyle(
              color: dark,
              fontWeight:
                  FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign:
                TextAlign.center,
            style:
                const TextStyle(
              color: muted,
              fontSize: 9,
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
    final products =
        _filteredProducts;

    return Scaffold(
      backgroundColor: canvas,
      appBar: AppBar(
        title: Text(
          widget.shop.storeName,
        ),
        backgroundColor:
            Colors.white,
        foregroundColor: dark,
        surfaceTintColor:
            Colors.white,
      ),
      body: RefreshIndicator(
        color: gold,
        onRefresh:
            _loadProducts,
        child: ListView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          padding:
              const EdgeInsets.fromLTRB(
            14,
            14,
            14,
            30,
          ),
          children: [
            _shopHeader(),
            const SizedBox(
              height: 14,
            ),
            TextField(
              controller:
                  _searchController,
              onChanged: (value) {
                setState(() {});
              },
              decoration:
                  const InputDecoration(
                hintText:
                    'Search this shop...',
                prefixIcon:
                    Icon(
                  Icons.search_rounded,
                ),
              ),
            ),
            if (_incomplete) ...[
              const SizedBox(
                height: 10,
              ),
              Container(
                padding:
                    const EdgeInsets.all(
                  10,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      const Color(
                    0xFFFFF8E8,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    10,
                  ),
                  border:
                      Border.all(
                    color:
                        const Color(
                      0xFFEED39B,
                    ),
                  ),
                ),
                child:
                    const Text(
                  'Only part of this seller\'s catalog could be loaded from the current mobile catalog API.',
                  style:
                      TextStyle(
                    color:
                        goldDark,
                    fontSize:
                        8.5,
                  ),
                ),
              ),
            ],
            const SizedBox(
              height: 16,
            ),
            if (_loading)
              const Padding(
                padding:
                    EdgeInsets.symmetric(
                  vertical: 60,
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
                'Unable to load shop products',
                _error!,
              )
            else if (products.isEmpty)
              _statusCard(
                Icons.inventory_2_outlined,
                'No products found',
                'No matching products are currently available from this seller.',
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(),
                itemCount:
                    products.length,
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
                      products[index];

                  return BuyerProductCard(
                    product:
                        product,
                    showPromotions:
                        false,
                    showStock:
                        true,
                    showQuickAdd:
                        false,
                    onTap: () =>
                        _openProduct(
                      product,
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}