import 'dart:async';

import 'package:flutter/material.dart';

import '../config/api_config.dart';
import '../services/sari_live_data.dart';
import 'buyer_product_details.dart';
import 'buyer_theme.dart';
import 'models/buyer_product_model.dart';
import 'widgets/buyer_header.dart';
import 'widgets/buyer_product_card.dart';

class BuyerProducts extends StatefulWidget {
  final ValueChanged<int>? onTabChanged;

  final String initialSearch;
  final String? initialCategory;

  const BuyerProducts({
    super.key,
    this.onTabChanged,
    this.initialSearch = '',
    this.initialCategory,
  });

  @override
  State<BuyerProducts> createState() =>
      _BuyerProductsState();
}

class _BuyerProductsState
    extends State<BuyerProducts> {
  final TextEditingController
      _searchController =
      TextEditingController();

  final List<BuyerProduct> _products =
      <BuyerProduct>[];

  Timer? _debounce;

  bool _loading = true;
  bool _loadingMore = false;

  String? _error;

  String _sort = 'newest';

  String? _category;

  int _page = 1;
  int _lastPage = 1;
  int _total = 0;

  int _requestVersion = 0;

  static const Color _ink =
      Color(0xFF17191D);

  static const Color _gold =
      Color(0xFFC88912);

  static const Color _muted =
      Color(0xFF77736E);

  static const List<_ShopCategory>
      _categories =
      <_ShopCategory>[
    _ShopCategory(
      name: 'Fashion',
      value: 'Fashion',
      image:
          '/images/cat-fashion.jpg',
    ),
    _ShopCategory(
      name: 'Electronics',
      value: 'Electronics',
      image:
          '/images/cat-electronics.jpg',
    ),
    _ShopCategory(
      name: 'Home & Living',
      value: 'Home & Living',
      image:
          '/images/cat-home.jpg',
    ),
    _ShopCategory(
      name: 'Beauty',
      value: 'Beauty',
      image:
          '/images/cat-beauty.jpg',
    ),
    _ShopCategory(
      name: 'Accessories',
      value: 'Accessories',
      image:
          '/images/cat-accessories.jpg',
    ),
    _ShopCategory(
      name: 'Food & Essentials',
      value: 'Food & Essentials',
      image:
          '/images/cat-food.jpg',
    ),
    _ShopCategory(
      name: 'Sports',
      value: 'Sports',
      image:
          '/images/cat-sports.jpg',
    ),
    _ShopCategory(
      name: 'Lifestyle',
      value: 'Lifestyle',
      image:
          '/images/cat-lifestyle.jpg',
    ),
  ];

  @override
  void initState() {
    super.initState();

    _searchController.text =
        widget.initialSearch;

    _category =
        widget.initialCategory;

    _loadProducts();
  }

  @override
  void dispose() {
    _requestVersion++;

    _debounce?.cancel();

    _searchController.dispose();

    super.dispose();
  }

  String _asset(
    String path,
  ) {
    final String base =
        ApiConfig.baseUrl.replaceFirst(
      RegExp(r'/+$'),
      '',
    );

    if (path.startsWith('/')) {
      return '$base$path';
    }

    return '$base/$path';
  }

  Map<String, dynamic> _map(
    dynamic value,
  ) {
    return value is Map
        ? Map<String, dynamic>.from(
            value,
          )
        : <String, dynamic>{};
  }

  String _text(
    dynamic value, [
    String fallback = '',
  ]) {
    final String result =
        value?.toString().trim() ??
            '';

    return result.isEmpty
        ? fallback
        : result;
  }

  int _integer(
    dynamic value,
  ) {
    return value is num
        ? value.toInt()
        : int.tryParse('$value') ??
            0;
  }

  double _decimal(
    dynamic value,
  ) {
    return value is num
        ? value.toDouble()
        : double.tryParse('$value') ??
            0;
  }

  BuyerProduct _parseProduct(
    dynamic raw,
  ) {
    final Map<String, dynamic> data =
        _map(raw);

    final double price =
        _decimal(
      data['price'],
    );

    final double discount =
        _decimal(
      data['discount'],
    );

    double? oldPrice;

    if (discount > 0 &&
        discount < 100 &&
        price > 0) {
      oldPrice =
          price /
              (1 -
                  discount / 100);
    }

    final String image =
        _text(
      data['image_url'],
    );

    return BuyerProduct(
      id:
          _integer(
        data['id'],
      ),
      name:
          _text(
        data['name'],
        'SARI Product',
      ),
      category:
          _text(
        data['category'],
        'General',
      ),
      brand:
          _text(
        data['brand'],
      ),
      description:
          _text(
        data['description'],
      ),
      image:
          image.isEmpty
              ? null
              : image,
      price:
          price,
      oldPrice:
          oldPrice,
      stock:
          _integer(
        data['stock'],
      ),
      shopName:
          _text(
        data['store_name'],
        'SARI Store',
      ),
      sellerAccountId:
          _integer(
        data['seller_id'],
      ),
    );
  }

  Future<void> _loadProducts({
    bool loadMore = false,
  }) async {
    if (loadMore &&
        (_loading ||
            _loadingMore ||
            _page >= _lastPage)) {
      return;
    }

    final int requestVersion =
        loadMore
            ? _requestVersion
            : ++_requestVersion;

    final int requestedPage =
        loadMore
            ? _page + 1
            : 1;

    setState(() {
      if (loadMore) {
        _loadingMore = true;
      } else {
        _loading = true;
        _error = null;

        _page = 1;
        _lastPage = 1;
        _total = 0;

        _products.clear();
      }
    });

    try {
      final String search =
          _searchController.text
              .trim();

      final Map<String, dynamic>
          response =
          await SariLiveData
              .instance
              .products(
        page:
            requestedPage,
        perPage: 20,
        search:
            search.isEmpty
                ? null
                : search,
        category:
            _category,
        sort:
            _sort,
      );

      final dynamic raw =
          response['data'];

      if (raw is! List) {
        throw const FormatException(
          'Invalid product response.',
        );
      }

      final Map<String, dynamic> meta =
          _map(
        response['meta'],
      );

      final List<BuyerProduct>
          loaded =
          raw
              .map(
                _parseProduct,
              )
              .where(
                (
                  BuyerProduct product,
                ) =>
                    product.id > 0,
              )
              .toList();

      if (!mounted ||
          requestVersion !=
              _requestVersion) {
        return;
      }

      setState(() {
        if (loadMore) {
          final Set<int> existing =
              _products
                  .map(
                    (
                      BuyerProduct product,
                    ) =>
                        product.id,
                  )
                  .toSet();

          for (final BuyerProduct product
              in loaded) {
            if (existing.add(
              product.id,
            )) {
              _products.add(
                product,
              );
            }
          }
        } else {
          _products
            ..clear()
            ..addAll(
              loaded,
            );
        }

        _page =
            _integer(
          meta['current_page'],
        );

        if (_page <= 0) {
          _page =
              requestedPage;
        }

        _lastPage =
            _integer(
          meta['last_page'],
        );

        if (_lastPage <= 0) {
          _lastPage =
              _page;
        }

        _total =
            _integer(
          meta['total'],
        );

        _loading = false;
        _loadingMore = false;
      });
    } catch (error) {
      if (!mounted ||
          requestVersion !=
              _requestVersion) {
        return;
      }

      setState(() {
        _loading = false;
        _loadingMore = false;
        _error =
            error.toString();
      });
    }
  }

  void _searchChanged(
    String value,
  ) {
    setState(() {});

    _debounce?.cancel();

    _debounce =
        Timer(
      const Duration(
        milliseconds: 420,
      ),
      _loadProducts,
    );
  }

  void _selectCategory(
    String? category,
  ) {
    if (_category ==
        category) {
      return;
    }

    setState(() {
      _category =
          category;
    });

    _loadProducts();
  }

  void _changeSort(
    String value,
  ) {
    if (_sort == value) {
      return;
    }

    setState(() {
      _sort = value;
    });

    _loadProducts();
  }

  Future<void> _openProduct(
    BuyerProduct product,
  ) async {
    try {
      final Map<String, dynamic>
          response =
          await SariLiveData
              .instance
              .productDetails(
        product.id,
      );

      final dynamic raw =
          response['data'];

      if (raw is! Map) {
        throw const FormatException(
          'Invalid product details.',
        );
      }

      final BuyerProduct fresh =
          _parseProduct(
        raw,
      );

      if (!mounted) {
        return;
      }

      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) =>
              BuyerProductDetails(
            product: fresh,
          ),
        ),
      );
    } catch (error) {
      _message(
        'Unable to load product: $error',
      );
    }
  }

  Future<void> _quickAdd(
    BuyerProduct product,
  ) async {
    if (product.stock <= 0) {
      _message(
        'This product is out of stock.',
      );

      return;
    }

    try {
      final Map<String, dynamic>
          response =
          await SariLiveData
              .instance
              .buyerAddCart(
        productId:
            product.id,
        quantity: 1,
      );

      _message(
        _text(
          response['message'],
          'Added to cart.',
        ),
      );
    } catch (error) {
      _message(
        error.toString(),
      );
    }
  }

  void _message(
    String message,
  ) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content:
              Text(message),
          behavior:
              SnackBarBehavior.floating,
        ),
      );
  }

  Widget _pageHeading() {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        13,
        15,
        13,
        0,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'BUYER CATALOG',
            style:
                TextStyle(
              color:
                  BuyerTheme.goldDark,
              fontSize: 8,
              fontWeight:
                  FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),

          const SizedBox(
            height: 3,
          ),

          RichText(
            text:
                const TextSpan(
              style:
                  TextStyle(
                color:
                    _ink,
                fontSize: 24,
                fontWeight:
                    FontWeight.w900,
                letterSpacing: -.8,
              ),
              children:
                  <InlineSpan>[
                TextSpan(
                  text: 'Shop ',
                ),
                TextSpan(
                  text: 'Products',
                  style:
                      TextStyle(
                    color:
                        _gold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 5,
          ),

          const Text(
            'Browse trusted products across the SARI marketplace.',
            style:
                TextStyle(
              color:
                  _muted,
              fontSize: 9.5,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchAndSort() {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        13,
        14,
        13,
        0,
      ),
      child: Column(
        children: <Widget>[
          TextField(
            controller:
                _searchController,
            textInputAction:
                TextInputAction.search,
            onChanged:
                _searchChanged,
            onSubmitted: (_) {
              _loadProducts();
            },
            style:
                const TextStyle(
              fontSize: 10.5,
            ),
            decoration:
                InputDecoration(
              hintText:
                  'Search products or brands...',
              prefixIcon:
                  const Icon(
                Icons.search_rounded,
                size: 18,
              ),
              suffixIcon:
                  _searchController
                          .text
                          .isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            _searchController
                                .clear();

                            setState(
                              () {},
                            );

                            _loadProducts();
                          },
                          icon:
                              const Icon(
                            Icons
                                .close_rounded,
                            size: 17,
                          ),
                        ),
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(
                vertical: 12,
              ),
            ),
          ),

          const SizedBox(
            height: 9,
          ),

          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  _loading
                      ? 'Loading...'
                      : '$_total product${_total == 1 ? '' : 's'}',
                  style:
                      const TextStyle(
                    color:
                        _muted,
                    fontSize: 8.5,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ),

              PopupMenuButton<String>(
                initialValue:
                    _sort,
                onSelected:
                    _changeSort,
                itemBuilder:
                    (
                      BuildContext context,
                    ) =>
                        const <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value:
                        'newest',
                    child:
                        Text(
                      'Newest',
                    ),
                  ),
                  PopupMenuItem<String>(
                    value:
                        'price_low',
                    child:
                        Text(
                      'Price: Low to High',
                    ),
                  ),
                  PopupMenuItem<String>(
                    value:
                        'price_high',
                    child:
                        Text(
                      'Price: High to Low',
                    ),
                  ),
                ],
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration:
                      BoxDecoration(
                    color:
                        Colors.white,
                    borderRadius:
                        BorderRadius.circular(
                      10,
                    ),
                    border:
                        Border.all(
                      color:
                          BuyerTheme.border,
                    ),
                  ),
                  child: Row(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: <Widget>[
                      const Icon(
                        Icons.sort_rounded,
                        size: 15,
                        color:
                            BuyerTheme.goldDark,
                      ),

                      const SizedBox(
                        width: 4,
                      ),

                      Text(
                        switch (_sort) {
                          'price_low' =>
                            'Low Price',
                          'price_high' =>
                            'High Price',
                          _ =>
                            'Newest',
                        },
                        style:
                            const TextStyle(
                          color: _ink,
                          fontSize: 8.5,
                          fontWeight:
                              FontWeight.w700,
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
    );
  }

  Widget _categoryRail() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: <Widget>[
        const Padding(
          padding:
              EdgeInsets.fromLTRB(
            13,
            20,
            13,
            9,
          ),
          child: Text(
            'Shop by Category',
            style:
                TextStyle(
              color: _ink,
              fontSize: 15,
              fontWeight:
                  FontWeight.w900,
            ),
          ),
        ),

        SizedBox(
          height: 96,
          child:
              ListView.separated(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 13,
            ),
            scrollDirection:
                Axis.horizontal,
            itemCount:
                _categories.length +
                    1,
            separatorBuilder:
                (
                  BuildContext context,
                  int index,
                ) =>
                    const SizedBox(
              width: 10,
            ),
            itemBuilder:
                (
                  BuildContext context,
                  int index,
                ) {
              if (index == 0) {
                final bool selected =
                    _category == null;

                return _allCategory(
                  selected,
                );
              }

              final _ShopCategory category =
                  _categories[
                      index - 1];

              final bool selected =
                  _category ==
                      category.value;

              return _imageCategory(
                category,
                selected,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _allCategory(
    bool selected,
  ) {
    return InkWell(
      onTap: () {
        _selectCategory(
          null,
        );
      },
      borderRadius:
          BorderRadius.circular(
        15,
      ),
      child: SizedBox(
        width: 68,
        child: Column(
          children: <Widget>[
            AnimatedContainer(
              duration:
                  const Duration(
                milliseconds: 180,
              ),
              width: 57,
              height: 57,
              alignment:
                  Alignment.center,
              decoration:
                  BoxDecoration(
                color: selected
                    ? const Color(
                        0xFF252525,
                      )
                    : Colors.white,
                shape:
                    BoxShape.circle,
                border:
                    Border.all(
                  color: selected
                      ? const Color(
                          0xFF252525,
                        )
                      : BuyerTheme.border,
                ),
              ),
              child: Icon(
                Icons.grid_view_rounded,
                size: 20,
                color: selected
                    ? Colors.white
                    : BuyerTheme.ink,
              ),
            ),

            const SizedBox(
              height: 6,
            ),

            Text(
              'All',
              style:
                  TextStyle(
                color: selected
                    ? BuyerTheme.goldDark
                    : _ink,
                fontSize: 8,
                fontWeight:
                    selected
                        ? FontWeight.w900
                        : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageCategory(
    _ShopCategory category,
    bool selected,
  ) {
    return InkWell(
      onTap: () {
        _selectCategory(
          category.value,
        );
      },
      borderRadius:
          BorderRadius.circular(
        15,
      ),
      child: SizedBox(
        width: 72,
        child: Column(
          children: <Widget>[
            AnimatedContainer(
              duration:
                  const Duration(
                milliseconds: 180,
              ),
              width: 57,
              height: 57,
              padding:
                  EdgeInsets.all(
                selected ? 2 : 0,
              ),
              decoration:
                  BoxDecoration(
                shape:
                    BoxShape.circle,
                border:
                    Border.all(
                  color: selected
                      ? _gold
                      : const Color(
                          0xFFE2DDD7,
                        ),
                  width:
                      selected
                          ? 2
                          : 1,
                ),
              ),
              child: ClipOval(
                child: Image.network(
                  _asset(
                    category.image,
                  ),
                  fit:
                      BoxFit.cover,
                  errorBuilder:
                      (
                        _,
                        __,
                        ___,
                      ) =>
                          const ColoredBox(
                    color:
                        Color(
                      0xFFF5F3F0,
                    ),
                    child:
                        Icon(
                      Icons.category_outlined,
                      size: 19,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 6,
            ),

            Text(
              category.name,
              maxLines: 2,
              textAlign:
                  TextAlign.center,
              overflow:
                  TextOverflow.ellipsis,
              style:
                  TextStyle(
                color: selected
                    ? BuyerTheme.goldDark
                    : _ink,
                fontSize: 7.7,
                height: 1.05,
                fontWeight:
                    selected
                        ? FontWeight.w800
                        : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _grid() {
    if (_loading) {
      return const Padding(
        padding:
            EdgeInsets.symmetric(
          vertical: 70,
        ),
        child: Center(
          child:
              CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null &&
        _products.isEmpty) {
      return _status(
        icon:
            Icons.cloud_off_outlined,
        title:
            'Unable to load products',
        message:
            _error!,
      );
    }

    if (_products.isEmpty) {
      return _status(
        icon:
            Icons.search_off_rounded,
        title:
            'No products found',
        message:
            'Try another category or search.',
      );
    }

    return LayoutBuilder(
      builder:
          (
            BuildContext context,
            BoxConstraints constraints,
          ) {
        final bool compact =
            constraints.maxWidth <
                350;

        return Column(
          children: <Widget>[
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(
                12,
                13,
                12,
                0,
              ),
              child:
                  GridView.builder(
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(),
                itemCount:
                    _products.length,
                gridDelegate:
                    SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 9,
                  mainAxisSpacing: 9,
                  mainAxisExtent:
                      compact
                          ? 290
                          : 306,
                ),
                itemBuilder:
                    (
                      BuildContext context,
                      int index,
                    ) {
                  final BuyerProduct product =
                      _products[index];

                  return BuyerProductCard(
                    product:
                        product,
                    showPromotions:
                        true,
                    showStock:
                        true,
                    showQuickAdd:
                        true,
                    onTap: () {
                      _openProduct(
                        product,
                      );
                    },
                    onAddToCart: () {
                      _quickAdd(
                        product,
                      );
                    },
                    onBuyNow: () async {
                      await _quickAdd(
                        product,
                      );

                      if (mounted) {
                        widget
                            .onTabChanged
                            ?.call(2);
                      }
                    },
                  );
                },
              ),
            ),

            if (_page <
                _lastPage)
              Padding(
                padding:
                    const EdgeInsets.fromLTRB(
                  13,
                  16,
                  13,
                  0,
                ),
                child: SizedBox(
                  width:
                      double.infinity,
                  height: 41,
                  child:
                      OutlinedButton.icon(
                    onPressed:
                        _loadingMore
                            ? null
                            : () {
                                _loadProducts(
                                  loadMore:
                                      true,
                                );
                              },
                    icon:
                        _loadingMore
                            ? const SizedBox(
                                width:
                                    15,
                                height:
                                    15,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth:
                                      2,
                                ),
                              )
                            : const Icon(
                                Icons
                                    .expand_more_rounded,
                                size:
                                    17,
                              ),
                    label:
                        Text(
                      _loadingMore
                          ? 'Loading...'
                          : 'Load More',
                      style:
                          const TextStyle(
                        fontSize:
                            9,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _status({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Container(
      margin:
          const EdgeInsets.fromLTRB(
        13,
        15,
        13,
        0,
      ),
      padding:
          const EdgeInsets.all(
        26,
      ),
      decoration:
          BuyerTheme.card(),
      child: Column(
        children: <Widget>[
          Icon(
            icon,
            size: 40,
            color:
                BuyerTheme.muted,
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            title,
            style:
                const TextStyle(
              fontSize: 14,
              fontWeight:
                  FontWeight.w800,
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            message,
            textAlign:
                TextAlign.center,
            style:
                const TextStyle(
              color:
                  BuyerTheme.muted,
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
    return Scaffold(
      backgroundColor:
          BuyerTheme.canvas,
      body: Column(
        children: <Widget>[
          BuyerHeader(
            pageTitle:
                'Shop Products',
            cartCount: 0,
            notificationCount: 0,
            onSearchTap: () {},
            onCartTap: () {
              widget.onTabChanged
                  ?.call(2);
            },
            onNotificationTap: () {
              widget.onTabChanged
                  ?.call(5);
            },
            onProfileTap: () {
              widget.onTabChanged
                  ?.call(4);
            },
          ),

          Expanded(
            child:
                RefreshIndicator(
              color:
                  BuyerTheme.gold,
              onRefresh: () {
                return _loadProducts();
              },
              child:
                  ListView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                padding:
                    const EdgeInsets.only(
                  bottom: 28,
                ),
                children: <Widget>[
                  _pageHeading(),
                  _searchAndSort(),
                  _categoryRail(),
                  _grid(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShopCategory {
  final String name;
  final String value;
  final String image;

  const _ShopCategory({
    required this.name,
    required this.value,
    required this.image,
  });
}