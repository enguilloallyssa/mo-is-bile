import 'package:flutter/material.dart';

import '../config/api_config.dart';
import '../services/sari_live_data.dart';
import 'buyer_product_details.dart';
import 'buyer_theme.dart';
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
  final List<BuyerProduct> _products =
      <BuyerProduct>[];

  bool _loading = true;
  String? _error;

  static const Color _ink =
      Color(0xFF17191D);

  static const Color _gold =
      Color(0xFFC88912);

  static const Color _muted =
      Color(0xFF77736E);

  static const List<_HomeCategory>
      _categories =
      <_HomeCategory>[
    _HomeCategory(
      name: 'Fashion',
      image:
          '/images/cat-fashion.jpg',
    ),
    _HomeCategory(
      name: 'Electronics',
      image:
          '/images/cat-electronics.jpg',
    ),
    _HomeCategory(
      name: 'Home & Living',
      image:
          '/images/cat-home.jpg',
    ),
    _HomeCategory(
      name: 'Beauty',
      image:
          '/images/cat-beauty.jpg',
    ),
    _HomeCategory(
      name: 'Accessories',
      image:
          '/images/cat-accessories.jpg',
    ),
    _HomeCategory(
      name: 'Food & Essentials',
      image:
          '/images/cat-food.jpg',
    ),
    _HomeCategory(
      name: 'Sports',
      image:
          '/images/cat-sports.jpg',
    ),
    _HomeCategory(
      name: 'Lifestyle',
      image:
          '/images/cat-lifestyle.jpg',
    ),
  ];

  static const List<_PromoItem>
      _promos =
      <_PromoItem>[
    _PromoItem(
      image: '/images/hero.jpg',
      kicker: 'FEATURED COLLECTION',
      title:
          'Modern picks for everyday living.',
    ),
    _PromoItem(
      image:
          '/images/beauty-bestsellers.png',
      kicker: 'BEAUTY EDIT',
      title:
          'Everyday beauty, elevated.',
    ),
    _PromoItem(
      image:
          '/images/home-essentials.png',
      kicker: 'HOME REFRESH',
      title:
          'Comfort for every corner.',
    ),
    _PromoItem(
      image:
          '/images/sari-ticket-08-product-camera.jpg',
      kicker: 'FLASH SALE',
      title:
          'Tech and lifestyle finds.',
    ),
  ];

  @override
  void initState() {
    super.initState();

    _loadProducts();
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
        : int.tryParse('$value') ?? 0;
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
                  (discount / 100));
    }

    final String image =
        _text(
      data['image_url'] ??
          data['image'],
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
        'SARI Seller',
      ),
      sellerAccountId:
          _integer(
        data['seller_id'],
      ),
    );
  }

  Future<void> _loadProducts() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final Map<String, dynamic>
          response =
          await SariLiveData
              .instance
              .products(
        page: 1,
        perPage: 8,
      );

      final dynamic raw =
          response['data'];

      if (raw is! List) {
        throw const FormatException(
          'Invalid product response.',
        );
      }

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

      if (!mounted) {
        return;
      }

      setState(() {
        _products
          ..clear()
          ..addAll(
            loaded,
          );

        _loading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;
        _error =
            error.toString();
      });
    }
  }

  void _openShop() {
    widget.onTabChanged
        ?.call(1);
  }

  void _openCart() {
    widget.onTabChanged
        ?.call(2);
  }

  void _openNotifications() {
    widget.onTabChanged
        ?.call(5);
  }

  void _openAccount() {
    widget.onTabChanged
        ?.call(4);
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
          'Unable to load product.',
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

  Widget _hero() {
    return LayoutBuilder(
      builder:
          (
            BuildContext context,
            BoxConstraints constraints,
          ) {
        final bool narrow =
            constraints.maxWidth < 360;

        final double titleSize =
            narrow ? 27 : 31;

        return Container(
          margin:
              const EdgeInsets.fromLTRB(
            12,
            12,
            12,
            0,
          ),
          height:
              narrow ? 280 : 300,
          clipBehavior:
              Clip.antiAlias,
          decoration:
              BoxDecoration(
            color:
                const Color(
              0xFFF0EAE1,
            ),
            borderRadius:
                BorderRadius.circular(
              22,
            ),
            boxShadow:
                const <BoxShadow>[
              BoxShadow(
                color:
                    Color(
                  0x1B000000,
                ),
                blurRadius: 22,
                offset:
                    Offset(
                  0,
                  9,
                ),
              ),
            ],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Image.network(
                _asset(
                  '/images/sari-hero-bg.webp',
                ),
                fit: BoxFit.cover,
                alignment:
                    Alignment.centerRight,
                errorBuilder:
                    (
                      _,
                      __,
                      ___,
                    ) =>
                        const ColoredBox(
                  color:
                      Color(
                    0xFFF0EAE1,
                  ),
                ),
              ),

              const DecoratedBox(
                decoration:
                    BoxDecoration(
                  gradient:
                      LinearGradient(
                    begin:
                        Alignment.centerLeft,
                    end:
                        Alignment.centerRight,
                    stops:
                        <double>[
                      0,
                      .48,
                      .77,
                      1,
                    ],
                    colors:
                        <Color>[
                      Color(
                        0xFFF4EFE8,
                      ),
                      Color(
                        0xF4F4EFE8,
                      ),
                      Color(
                        0xA6F4EFE8,
                      ),
                      Color(
                        0x18F4EFE8,
                      ),
                    ],
                  ),
                ),
              ),

              const DecoratedBox(
                decoration:
                    BoxDecoration(
                  gradient:
                      LinearGradient(
                    begin:
                        Alignment.topCenter,
                    end:
                        Alignment.bottomCenter,
                    colors:
                        <Color>[
                      Colors.transparent,
                      Color(
                        0x16000000,
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding:
                    EdgeInsets.fromLTRB(
                  narrow ? 18 : 21,
                  19,
                  narrow ? 14 : 18,
                  18,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: <Widget>[
                    SizedBox(
                      height: 28,
                      child:
                          Image.network(
                        _asset(
                          '/images/sari-main-logo.png',
                        ),
                        fit:
                            BoxFit.contain,
                        alignment:
                            Alignment.centerLeft,
                        errorBuilder:
                            (
                              _,
                              __,
                              ___,
                            ) =>
                                const Text(
                          'SARI',
                          style:
                              TextStyle(
                            color:
                                _ink,
                            fontSize: 19,
                            fontWeight:
                                FontWeight.w900,
                            letterSpacing: 3,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 21,
                    ),

                    Text(
                      'Variety You Need,',
                      style:
                          TextStyle(
                        color: _ink,
                        fontSize:
                            titleSize,
                        height: .98,
                        fontWeight:
                            FontWeight.w900,
                        letterSpacing:
                            -1.2,
                      ),
                    ),

                    const SizedBox(
                      height: 3,
                    ),

                    Text(
                      'Convenience\nYou Deserve.',
                      style:
                          TextStyle(
                        color:
                            _gold,
                        fontSize:
                            titleSize,
                        height: 1,
                        fontWeight:
                            FontWeight.w900,
                        letterSpacing:
                            -1.2,
                      ),
                    ),

                    const SizedBox(
                      height: 11,
                    ),

                    ConstrainedBox(
                      constraints:
                          BoxConstraints(
                        maxWidth:
                            narrow
                                ? 220
                                : 245,
                      ),
                      child:
                          const Text(
                        'Curated finds, everyday essentials, and effortless shopping.',
                        style:
                            TextStyle(
                          color:
                              Color(
                            0xFF4D4943,
                          ),
                          fontSize: 9.6,
                          height: 1.45,
                          fontWeight:
                              FontWeight.w500,
                        ),
                      ),
                    ),

                    const Spacer(),

                    Wrap(
                      spacing: 8,
                      runSpacing: 7,
                      children: <Widget>[
                        SizedBox(
                          height: 39,
                          child:
                              FilledButton(
                            onPressed:
                                _openShop,
                            style:
                                FilledButton
                                    .styleFrom(
                              backgroundColor:
                                  _gold,
                              foregroundColor:
                                  Colors.white,
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal:
                                    17,
                              ),
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                  10,
                                ),
                              ),
                            ),
                            child:
                                const Row(
                              mainAxisSize:
                                  MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                  'Shop Now',
                                  style:
                                      TextStyle(
                                    fontSize:
                                        9.5,
                                    fontWeight:
                                        FontWeight.w800,
                                  ),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Icon(
                                  Icons
                                      .arrow_forward_rounded,
                                  size: 15,
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(
                          height: 39,
                          child:
                              OutlinedButton(
                            onPressed:
                                _openShop,
                            style:
                                OutlinedButton
                                    .styleFrom(
                              foregroundColor:
                                  _ink,
                              backgroundColor:
                                  Colors.white
                                      .withValues(
                                alpha: .83,
                              ),
                              side:
                                  const BorderSide(
                                color:
                                    Color(
                                  0xFFD8D0C6,
                                ),
                              ),
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal:
                                    14,
                              ),
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                  10,
                                ),
                              ),
                            ),
                            child:
                                const Text(
                              'Explore Categories',
                              style:
                                  TextStyle(
                                fontSize:
                                    9,
                                fontWeight:
                                    FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _benefits() {
    const List<_Benefit>
        items =
        <_Benefit>[
      _Benefit(
        icon:
            Icons.local_shipping_outlined,
        title:
            'Free Shipping',
        subtitle:
            'On eligible orders',
      ),
      _Benefit(
        icon:
            Icons.card_giftcard_rounded,
        title:
            'Earn Rewards',
        subtitle:
            'Shop and earn points',
      ),
      _Benefit(
        icon:
            Icons
                .verified_user_outlined,
        title:
            'Secure Payments',
        subtitle:
            'Safe and protected',
      ),
      _Benefit(
        icon:
            Icons.storefront_outlined,
        title:
            'Verified Sellers',
        subtitle:
            'Quality and trusted',
      ),
    ];

    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        12,
        12,
        12,
        0,
      ),
      child: LayoutBuilder(
        builder:
            (
              BuildContext context,
              BoxConstraints constraints,
            ) {
          return GridView.builder(
            shrinkWrap: true,
            physics:
                const NeverScrollableScrollPhysics(),
            itemCount:
                items.length,
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              mainAxisExtent: 69,
            ),
            itemBuilder:
                (
                  BuildContext context,
                  int index,
                ) {
              final _Benefit item =
                  items[index];

              return Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 9,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      Colors.white,
                  borderRadius:
                      BorderRadius.circular(
                    13,
                  ),
                  border:
                      Border.all(
                    color:
                        BuyerTheme.border,
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 35,
                      height: 35,
                      alignment:
                          Alignment.center,
                      decoration:
                          BoxDecoration(
                        color:
                            BuyerTheme.goldPale,
                        borderRadius:
                            BorderRadius.circular(
                          10,
                        ),
                      ),
                      child: Icon(
                        item.icon,
                        size: 17,
                        color:
                            BuyerTheme.goldDark,
                      ),
                    ),

                    const SizedBox(
                      width: 8,
                    ),

                    Expanded(
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            item.title,
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis,
                            style:
                                const TextStyle(
                              color:
                                  _ink,
                              fontSize: 9.3,
                              fontWeight:
                                  FontWeight.w800,
                            ),
                          ),
                          const SizedBox(
                            height: 2,
                          ),
                          Text(
                            item.subtitle,
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis,
                            style:
                                const TextStyle(
                              color:
                                  _muted,
                              fontSize: 7.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _promosSection() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: <Widget>[
        const Padding(
          padding:
              EdgeInsets.fromLTRB(
            12,
            23,
            12,
            10,
          ),
          child: Text(
            'Featured Today',
            style:
                TextStyle(
              color: _ink,
              fontSize: 17,
              fontWeight:
                  FontWeight.w900,
              letterSpacing: -.4,
            ),
          ),
        ),

        SizedBox(
          height: 132,
          child:
              ListView.separated(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 12,
            ),
            scrollDirection:
                Axis.horizontal,
            itemCount:
                _promos.length,
            separatorBuilder:
                (
                  BuildContext context,
                  int index,
                ) =>
                    const SizedBox(
              width: 9,
            ),
            itemBuilder:
                (
                  BuildContext context,
                  int index,
                ) {
              final _PromoItem promo =
                  _promos[index];

              return InkWell(
                onTap:
                    _openShop,
                borderRadius:
                    BorderRadius.circular(
                  16,
                ),
                child: Container(
                  width: 235,
                  clipBehavior:
                      Clip.antiAlias,
                  decoration:
                      BoxDecoration(
                    color:
                        Colors.black,
                    borderRadius:
                        BorderRadius.circular(
                      16,
                    ),
                  ),
                  child: Stack(
                    fit:
                        StackFit.expand,
                    children: <Widget>[
                      Image.network(
                        _asset(
                          promo.image,
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
                            0xFF282828,
                          ),
                        ),
                      ),

                      const DecoratedBox(
                        decoration:
                            BoxDecoration(
                          gradient:
                              LinearGradient(
                            begin:
                                Alignment.topCenter,
                            end:
                                Alignment.bottomCenter,
                            colors:
                                <Color>[
                              Colors.transparent,
                              Color(
                                0xC9000000,
                              ),
                            ],
                          ),
                        ),
                      ),

                      Positioned(
                        left: 13,
                        right: 13,
                        bottom: 12,
                        child:
                            Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              promo.kicker,
                              style:
                                  const TextStyle(
                                color:
                                    Color(
                                  0xFFFFC94F,
                                ),
                                fontSize: 7.5,
                                fontWeight:
                                    FontWeight.w900,
                                letterSpacing: .8,
                              ),
                            ),
                            const SizedBox(
                              height: 3,
                            ),
                            Text(
                              promo.title,
                              maxLines: 2,
                              overflow:
                                  TextOverflow.ellipsis,
                              style:
                                  const TextStyle(
                                color:
                                    Colors.white,
                                fontSize: 12,
                                height: 1.1,
                                fontWeight:
                                    FontWeight.w800,
                              ),
                            ),
                          ],
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

  Widget _categoriesSection() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding:
              const EdgeInsets.fromLTRB(
            12,
            23,
            12,
            10,
          ),
          child: Row(
            children: <Widget>[
              const Expanded(
                child: Text(
                  'Shop by Category',
                  style:
                      TextStyle(
                    color: _ink,
                    fontSize: 17,
                    fontWeight:
                        FontWeight.w900,
                    letterSpacing: -.4,
                  ),
                ),
              ),

              TextButton(
                onPressed:
                    _openShop,
                child:
                    const Text(
                  'View all',
                  style:
                      TextStyle(
                    fontSize: 9,
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(
          height: 106,
          child:
              ListView.separated(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 12,
            ),
            scrollDirection:
                Axis.horizontal,
            itemCount:
                _categories.length,
            separatorBuilder:
                (
                  BuildContext context,
                  int index,
                ) =>
                    const SizedBox(
              width: 12,
            ),
            itemBuilder:
                (
                  BuildContext context,
                  int index,
                ) {
              final _HomeCategory category =
                  _categories[index];

              return InkWell(
                onTap:
                    _openShop,
                borderRadius:
                    BorderRadius.circular(
                  40,
                ),
                child: SizedBox(
                  width: 72,
                  child: Column(
                    children: <Widget>[
                      Container(
                        width: 64,
                        height: 64,
                        clipBehavior:
                            Clip.antiAlias,
                        decoration:
                            BoxDecoration(
                          shape:
                              BoxShape.circle,
                          color:
                              Colors.white,
                          border:
                              Border.all(
                            color:
                                const Color(
                              0xFFE4DED6,
                            ),
                          ),
                          boxShadow:
                              const <BoxShadow>[
                            BoxShadow(
                              color:
                                  Color(
                                0x11000000,
                              ),
                              blurRadius: 9,
                              offset:
                                  Offset(
                                0,
                                4,
                              ),
                            ),
                          ],
                        ),
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
                                  const Icon(
                            Icons
                                .category_outlined,
                            color:
                                BuyerTheme.muted,
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 7,
                      ),

                      Text(
                        category.name,
                        maxLines: 2,
                        textAlign:
                            TextAlign.center,
                        overflow:
                            TextOverflow.ellipsis,
                        style:
                            const TextStyle(
                          color:
                              _ink,
                          fontSize: 8.2,
                          height: 1.1,
                          fontWeight:
                              FontWeight.w700,
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
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding:
              const EdgeInsets.fromLTRB(
            12,
            23,
            12,
            10,
          ),
          child: Row(
            children: <Widget>[
              const Expanded(
                child: Text(
                  'Recommended for You',
                  style:
                      TextStyle(
                    color: _ink,
                    fontSize: 17,
                    fontWeight:
                        FontWeight.w900,
                    letterSpacing: -.4,
                  ),
                ),
              ),

              TextButton(
                onPressed:
                    _openShop,
                child:
                    const Text(
                  'View All',
                  style:
                      TextStyle(
                    fontSize: 9,
                  ),
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
                  CircularProgressIndicator(),
            ),
          )
        else if (_error != null)
          _stateCard(
            icon:
                Icons.wifi_off_rounded,
            title:
                'Products unavailable',
            message:
                _error!,
          )
        else if (_products.isEmpty)
          _stateCard(
            icon:
                Icons
                    .inventory_2_outlined,
            title:
                'No products yet',
            message:
                'Products will appear here.',
          )
        else
          LayoutBuilder(
            builder:
                (
                  BuildContext context,
                  BoxConstraints constraints,
                ) {
              final bool narrow =
                  constraints.maxWidth <
                      350;

              return Padding(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 12,
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
                    mainAxisSpacing: 9,
                    crossAxisSpacing: 9,
                    mainAxisExtent:
                        narrow
                            ? 290
                            : 305,
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
                          _openCart();
                        }
                      },
                    );
                  },
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _stateCard({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Container(
      margin:
          const EdgeInsets.symmetric(
        horizontal: 12,
      ),
      padding:
          const EdgeInsets.all(
        25,
      ),
      decoration:
          BuyerTheme.card(),
      child: Column(
        children: <Widget>[
          Icon(
            icon,
            color:
                BuyerTheme.muted,
            size: 38,
          ),

          const SizedBox(
            height: 10,
          ),

          Text(
            title,
            style:
                const TextStyle(
              color: _ink,
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
            pageTitle: 'Home',
            cartCount: 0,
            notificationCount: 0,
            onSearchTap:
                _openShop,
            onCartTap:
                _openCart,
            onNotificationTap:
                _openNotifications,
            onProfileTap:
                _openAccount,
          ),

          Expanded(
            child:
                RefreshIndicator(
              color:
                  BuyerTheme.gold,
              onRefresh:
                  _loadProducts,
              child:
                  ListView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                padding:
                    const EdgeInsets.only(
                  bottom: 28,
                ),
                children: <Widget>[
                  _hero(),
                  _benefits(),
                  _promosSection(),
                  _categoriesSection(),
                  _recommended(),

                  const SizedBox(
                    height: 18,
                  ),

                  const Center(
                    child: Text(
                      'SARI • ELEVATED EVERYDAY',
                      style:
                          TextStyle(
                        color:
                            BuyerTheme.muted,
                        fontSize: 7.5,
                        letterSpacing: 1,
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

class _HomeCategory {
  final String name;
  final String image;

  const _HomeCategory({
    required this.name,
    required this.image,
  });
}

class _PromoItem {
  final String image;
  final String kicker;
  final String title;

  const _PromoItem({
    required this.image,
    required this.kicker,
    required this.title,
  });
}

class _Benefit {
  final IconData icon;
  final String title;
  final String subtitle;

  const _Benefit({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}