import 'package:flutter/material.dart';

import '../config/api_config.dart';
import '../services/sari_live_data.dart';
import 'buyer_cart.dart';
import 'buyer_theme.dart';
import 'models/buyer_product_model.dart';

class BuyerProductDetails extends StatefulWidget {
  final BuyerProduct product;
  final VoidCallback? onViewCart;

  const BuyerProductDetails({
    super.key,
    required this.product,
    this.onViewCart,
  });

  @override
  State<BuyerProductDetails> createState() =>
      _BuyerProductDetailsState();
}

class _BuyerProductDetailsState
    extends State<BuyerProductDetails> {
  late BuyerProduct _product;

  final List<_VariantData> _variants =
      <_VariantData>[];

  final Map<String, List<String>> _optionGroups =
      <String, List<String>>{};

  final Map<String, String> _selectedOptions =
      <String, String>{};

  _VariantData? _selectedVariant;

  bool _loading = true;
  bool _addingToCart = false;

  bool _apiSaysHasVariants = false;
  bool _serverRequiresVariant = false;

  String? _error;

  int _quantity = 1;

  @override
  void initState() {
    super.initState();

    _product = widget.product;

    _loadProduct();
  }

  // ============================================================
  // BASIC HELPERS
  // ============================================================

  Map<String, dynamic> _map(
    dynamic value,
  ) {
    return value is Map
        ? Map<String, dynamic>.from(value)
        : <String, dynamic>{};
  }

  String _text(
    dynamic value, [
    String fallback = '',
  ]) {
    final String result =
        value?.toString().trim() ?? '';

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
        : double.tryParse('$value') ?? 0;
  }

  bool _boolean(
    dynamic value,
  ) {
    return value == true ||
        value == 1 ||
        value == '1' ||
        '$value'.toLowerCase() == 'true';
  }

  String _money(
    double value,
  ) {
    return '₱${value.toStringAsFixed(2)}';
  }

  String _normalize(
    String value,
  ) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(
          RegExp(r'\s+'),
          ' ',
        );
  }

  String _absoluteUrl(
    dynamic raw,
  ) {
    final String value =
        _text(raw);

    if (value.isEmpty) {
      return '';
    }

    if (value.startsWith('http://') ||
        value.startsWith('https://')) {
      return value;
    }

    final String base =
        ApiConfig.baseUrl.replaceFirst(
      RegExp(r'/+$'),
      '',
    );

    if (value.startsWith('/')) {
      return '$base$value';
    }

    return '$base/$value';
  }

  // ============================================================
  // PARSE PRODUCT
  // ============================================================

  _ParsedProduct _parseProduct(
    dynamic raw,
  ) {
    final Map<String, dynamic> data =
        _map(raw);

    final List<_VariantData> variants =
        <_VariantData>[];

    if (data['variants'] is List) {
      for (final dynamic rawVariant
          in data['variants'] as List) {
        final Map<String, dynamic> variant =
            _map(rawVariant);

        final Map<String, String> options =
            <String, String>{};

        final dynamic rawOptions =
            variant['options'];

        if (rawOptions is Map) {
          for (final MapEntry<dynamic, dynamic> entry
              in rawOptions.entries) {
            final String key =
                _text(entry.key);

            final String value =
                _text(entry.value);

            if (key.isNotEmpty &&
                value.isNotEmpty) {
              options[key] = value;
            }
          }
        }

        final int id =
            _integer(
          variant['id'],
        );

        if (id <= 0) {
          continue;
        }

        final String image =
            _absoluteUrl(
          variant['image_url'] ??
              variant['image'],
        );

        variants.add(
          _VariantData(
            id: id,
            label: _text(
              variant['label'],
              'Variant $id',
            ),
            options: options,
            price: _decimal(
              variant['price'],
            ),
            oldPrice:
                variant['old_price'] == null
                    ? null
                    : _decimal(
                        variant['old_price'],
                      ),
            stock: _integer(
              variant['stock'],
            ),
            available:
                variant['available'] == null
                    ? _integer(
                          variant['stock'],
                        ) >
                        0
                    : _boolean(
                        variant['available'],
                      ),
            image:
                image.isEmpty
                    ? null
                    : image,
          ),
        );
      }
    }

    final Map<String, List<String>> optionGroups =
        <String, List<String>>{};

    final dynamic rawGroups =
        data['option_groups'];

    if (rawGroups is Map) {
      for (final MapEntry<dynamic, dynamic> entry
          in rawGroups.entries) {
        final String key =
            _text(entry.key);

        if (key.isEmpty) {
          continue;
        }

        final List<String> values =
            <String>[];

        if (entry.value is List) {
          for (final dynamic rawValue
              in entry.value as List) {
            final String value =
                _text(rawValue);

            if (value.isNotEmpty &&
                !values.contains(value)) {
              values.add(value);
            }
          }
        }

        if (values.isNotEmpty) {
          optionGroups[key] =
              values;
        }
      }
    }

    // Derive groups from variants if option_groups
    // was not included separately.
    if (optionGroups.isEmpty &&
        variants.isNotEmpty) {
      for (final _VariantData variant
          in variants) {
        for (final MapEntry<String, String> entry
            in variant.options.entries) {
          optionGroups.putIfAbsent(
            entry.key,
            () => <String>[],
          );

          if (!optionGroups[entry.key]!
              .contains(entry.value)) {
            optionGroups[entry.key]!
                .add(entry.value);
          }
        }
      }
    }

    final List<String> images =
        <String>[];

    if (data['images'] is List) {
      for (final dynamic rawImage
          in data['images'] as List) {
        final String image =
            _absoluteUrl(rawImage);

        if (image.isNotEmpty &&
            !images.contains(image)) {
          images.add(image);
        }
      }
    }

    final String cover =
        _absoluteUrl(
      data['image_url'] ??
          data['image'],
    );

    if (cover.isNotEmpty &&
        !images.contains(cover)) {
      images.insert(
        0,
        cover,
      );
    }

    final List<BuyerProductVariant>
        buyerVariants =
        variants
            .map(
              (
                _VariantData variant,
              ) =>
                  BuyerProductVariant(
                id: variant.id,
                label: variant.label,
                price: variant.price,
                oldPrice:
                    variant.oldPrice,
                stock: variant.stock,
                image: variant.image,
                available:
                    variant.available,
              ),
            )
            .toList();

    final BuyerProduct product =
        BuyerProduct(
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
      sku:
          _text(
        data['sku'],
      ),
      description:
          _text(
        data['description'],
      ),
      image:
          cover.isEmpty
              ? null
              : cover,
      images:
          images,
      price:
          _decimal(
        data['price'],
      ),
      oldPrice:
          data['old_price'] == null
              ? null
              : _decimal(
                  data['old_price'],
                ),
      rating:
          _decimal(
        data['rating'],
      ),
      ratingCount:
          _integer(
        data['rating_count'],
      ),
      sold:
          _integer(
        data['sold'],
      ),
      stock:
          variants.isNotEmpty
              ? variants.fold<int>(
                  0,
                  (
                    int total,
                    _VariantData variant,
                  ) =>
                      total +
                      variant.stock,
                )
              : _integer(
                  data['stock'],
                ),
      shopName:
          _text(
        data['store_name'] ??
            data['shop_name'],
        'SARI Seller',
      ),
      sellerAccountId:
          _integer(
        data['seller_id'],
      ),
      variants:
          buyerVariants,
      optionGroups:
          optionGroups,
      condition:
          _text(
        data['condition'],
      ),
      preparationDays:
          data['preparation_days'] == null
              ? null
              : _integer(
                  data['preparation_days'],
                ),
    );

    final bool hasVariants =
        _boolean(
          data['has_variants'],
        ) ||
        variants.isNotEmpty ||
        optionGroups.isNotEmpty;

    return _ParsedProduct(
      product: product,
      variants: variants,
      optionGroups:
          optionGroups,
      hasVariants:
          hasVariants,
    );
  }

  // ============================================================
  // LOAD
  // ============================================================

  Future<void> _loadProduct() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final Map<String, dynamic> response =
          await SariLiveData.instance
              .productDetails(
        widget.product.id,
      );

      final dynamic raw =
          response['data'];

      if (raw is! Map) {
        throw const FormatException(
          'Invalid product details.',
        );
      }

      final _ParsedProduct parsed =
          _parseProduct(raw);

      if (parsed.product.id <= 0) {
        throw const FormatException(
          'Invalid product.',
        );
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _product =
            parsed.product;

        _variants
          ..clear()
          ..addAll(
            parsed.variants,
          );

        _optionGroups
          ..clear()
          ..addAll(
            parsed.optionGroups,
          );

        _apiSaysHasVariants =
            parsed.hasVariants;

        _selectedOptions.clear();
        _selectedVariant = null;

        // If there is literally one variant and
        // it has no selectable option groups,
        // select it automatically.
        if (_variants.length == 1 &&
            _optionGroups.isEmpty &&
            _variants.first.available &&
            _variants.first.stock > 0) {
          _selectedVariant =
              _variants.first;
        }

        _quantity = 1;
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

  // ============================================================
  // VARIANT LOGIC
  // ============================================================

  bool get _requiresVariant {
    return _apiSaysHasVariants ||
        _serverRequiresVariant ||
        _variants.isNotEmpty ||
        _optionGroups.isNotEmpty;
  }

  List<String> get _orderedGroups {
    final List<String> groups =
        _optionGroups.keys.toList();

    int priority(
      String name,
    ) {
      final String normalized =
          _normalize(name);

      if (normalized == 'size' ||
          normalized == 'shoe size') {
        return 10;
      }

      if (normalized == 'color' ||
          normalized == 'colour') {
        return 20;
      }

      return 100;
    }

    groups.sort(
      (
        String a,
        String b,
      ) {
        final int compare =
            priority(a).compareTo(
          priority(b),
        );

        if (compare != 0) {
          return compare;
        }

        return a.compareTo(b);
      },
    );

    return groups;
  }

  String? _variantOption(
    _VariantData variant,
    String group,
  ) {
    final String normalizedGroup =
        _normalize(group);

    for (final MapEntry<String, String> entry
        in variant.options.entries) {
      if (_normalize(entry.key) ==
          normalizedGroup) {
        return entry.value;
      }
    }

    return null;
  }

  bool _variantMatches(
    _VariantData variant,
    Map<String, String> selections,
  ) {
    for (final MapEntry<String, String> selection
        in selections.entries) {
      final String? value =
          _variantOption(
        variant,
        selection.key,
      );

      if (value == null ||
          _normalize(value) !=
              _normalize(
                selection.value,
              )) {
        return false;
      }
    }

    return true;
  }

  bool _canSelectValue(
    String group,
    String value,
  ) {
    if (_variants.isEmpty) {
      return false;
    }

    final List<String> groups =
        _orderedGroups;

    final int index =
        groups.indexOf(group);

    if (index < 0) {
      return false;
    }

    // Web-like flow:
    // Size first, then Color.
    for (int i = 0; i < index; i++) {
      if (!_selectedOptions
          .containsKey(groups[i])) {
        return false;
      }
    }

    final Map<String, String> test =
        <String, String>{};

    for (int i = 0; i < index; i++) {
      final String previous =
          groups[i];

      final String? selected =
          _selectedOptions[
              previous];

      if (selected != null) {
        test[previous] =
            selected;
      }
    }

    test[group] = value;

    return _variants.any(
      (
        _VariantData variant,
      ) =>
          variant.available &&
          variant.stock > 0 &&
          _variantMatches(
            variant,
            test,
          ),
    );
  }

  void _selectOption(
    String group,
    String value,
  ) {
    final List<String> groups =
        _orderedGroups;

    final int index =
        groups.indexOf(group);

    if (index < 0) {
      return;
    }

    setState(() {
      _selectedOptions[group] =
          value;

      // Clear options after the changed group.
      for (int i = index + 1;
          i < groups.length;
          i++) {
        _selectedOptions.remove(
          groups[i],
        );
      }

      _resolveSelectedVariant();

      _quantity = 1;
    });
  }

  void _selectDirectVariant(
    _VariantData variant,
  ) {
    if (!variant.available ||
        variant.stock <= 0) {
      return;
    }

    setState(() {
      _selectedVariant =
          variant;

      _quantity = 1;
    });
  }

  void _resolveSelectedVariant() {
    if (_variants.isEmpty) {
      _selectedVariant = null;

      return;
    }

    final List<String> groups =
        _orderedGroups;

    if (groups.isEmpty) {
      return;
    }

    final bool complete =
        groups.every(
      (
        String group,
      ) =>
          _selectedOptions
              .containsKey(group),
    );

    if (!complete) {
      _selectedVariant = null;

      return;
    }

    for (final _VariantData variant
        in _variants) {
      if (variant.available &&
          variant.stock > 0 &&
          _variantMatches(
            variant,
            _selectedOptions,
          )) {
        _selectedVariant =
            variant;

        return;
      }
    }

    _selectedVariant = null;
  }

  // ============================================================
  // CURRENT VALUES
  // ============================================================

  double get _currentPrice {
    final double? variantPrice =
        _selectedVariant?.price;

    if (variantPrice != null &&
        variantPrice > 0) {
      return variantPrice;
    }

    return _product.price;
  }

  double? get _currentOldPrice {
    return _selectedVariant?.oldPrice ??
        _product.oldPrice;
  }

  int get _currentStock {
    if (_selectedVariant != null) {
      return _selectedVariant!.stock;
    }

    if (_variants.isNotEmpty) {
      return _variants.fold<int>(
        0,
        (
          int total,
          _VariantData variant,
        ) =>
            total +
            variant.stock,
      );
    }

    return _product.stock;
  }

  String? get _currentImage {
    final String variantImage =
        _selectedVariant?.image
                ?.trim() ??
            '';

    if (variantImage.isNotEmpty) {
      return variantImage;
    }

    return _product.image;
  }

  bool get _inStock {
    return _currentStock > 0;
  }

  bool get _variantReady {
    if (!_requiresVariant) {
      return true;
    }

    return _selectedVariant != null;
  }

  // ============================================================
  // QUANTITY
  // ============================================================

  void _decreaseQuantity() {
    if (_quantity <= 1) {
      return;
    }

    setState(() {
      _quantity--;
    });
  }

  void _increaseQuantity() {
    if (!_inStock ||
        !_variantReady ||
        _quantity >= _currentStock) {
      return;
    }

    setState(() {
      _quantity++;
    });
  }

  // ============================================================
  // CART
  // ============================================================

  Future<bool> _addToCart() async {
    if (_addingToCart) {
      return false;
    }

    if (!_inStock) {
      _message(
        'This product is out of stock.',
      );

      return false;
    }

    if (_requiresVariant &&
        _selectedVariant == null) {
      if (_variants.isEmpty) {
        _message(
          'This product requires a variation, but its variation options are not available in the current mobile product response.',
        );
      } else {
        _message(
          _variantInstruction,
        );
      }

      return false;
    }

    setState(() {
      _addingToCart = true;
    });

    try {
      final Map<String, dynamic> response =
          await SariLiveData.instance
              .buyerAddCart(
        productId:
            _product.id,
        variantId:
            _selectedVariant?.id,
        quantity:
            _quantity,
      );

      _message(
        _text(
          response['message'],
          'Added to cart.',
        ),
      );

      return true;
    } catch (error) {
      final String message =
          error.toString();

      final String normalized =
          message.toLowerCase();

      // If the server says a variant is required but the
      // product endpoint didn't give us any variant data,
      // show a proper state instead of repeating a 422 toast.
      if (normalized.contains(
            'variation',
          ) ||
          normalized.contains(
            'variant',
          )) {
        if (mounted) {
          setState(() {
            _serverRequiresVariant =
                true;
          });
        }
      }

      _message(message);

      return false;
    } finally {
      if (mounted) {
        setState(() {
          _addingToCart = false;
        });
      }
    }
  }

  Future<void> _buyNow() async {
    final bool added =
        await _addToCart();

    if (!added ||
        !mounted) {
      return;
    }

    _openCart();
  }

  void _openCart() {
    if (widget.onViewCart != null) {
      widget.onViewCart!();

      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            const BuyerCart(),
      ),
    );
  }

  String get _variantInstruction {
    final List<String> groups =
        _orderedGroups;

    if (groups.isEmpty) {
      return 'Please select a product variation.';
    }

    if (groups.length == 1) {
      return 'Select ${groups.first} first.';
    }

    return 'Select ${groups.join(' → ')}.';
  }

  // ============================================================
  // COLOR HELPERS
  // ============================================================

  bool _isColorGroup(
    String group,
  ) {
    final String value =
        _normalize(group);

    return value == 'color' ||
        value == 'colour';
  }

  Color _colorValue(
    String value,
  ) {
    final String normalized =
        _normalize(value)
            .replaceAll(' ', '');

    if (normalized.startsWith('#')) {
      final String hex =
          normalized.substring(1);

      if (hex.length == 6) {
        return Color(
          int.parse(
            'FF$hex',
            radix: 16,
          ),
        );
      }
    }

    const Map<String, Color> colors =
        <String, Color>{
      'black':
          Color(0xFF202020),
      'white':
          Color(0xFFF2F2F2),
      'gray':
          Color(0xFFAAAAAA),
      'grey':
          Color(0xFFAAAAAA),
      'silver':
          Color(0xFFC4C4C4),
      'blue':
          Color(0xFF98AAD0),
      'navy':
          Color(0xFF243A64),
      'red':
          Color(0xFFCA5353),
      'green':
          Color(0xFF608C69),
      'yellow':
          Color(0xFFD7B845),
      'orange':
          Color(0xFFD58947),
      'brown':
          Color(0xFF80634E),
      'beige':
          Color(0xFFD7C7AB),
      'cream':
          Color(0xFFEDE4D2),
      'pink':
          Color(0xFFD8A4B2),
      'purple':
          Color(0xFF8272A3),
    };

    return colors[normalized] ??
        const Color(
          0xFFB8BEC8,
        );
  }

  // ============================================================
  // UI
  // ============================================================

  Widget _productImage() {
    final String image =
        _currentImage?.trim() ?? '';

    return Container(
      margin:
          const EdgeInsets.fromLTRB(
        12,
        12,
        12,
        0,
      ),
      clipBehavior:
          Clip.antiAlias,
      decoration:
          BuyerTheme.card(
        radius: 19,
      ),
      child: AspectRatio(
        aspectRatio: 1.05,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            ColoredBox(
              color:
                  const Color(
                0xFFF4F3F1,
              ),
              child: image.isEmpty
                  ? const Center(
                      child: Icon(
                        Icons
                            .inventory_2_outlined,
                        color:
                            BuyerTheme.muted,
                        size: 55,
                      ),
                    )
                  : Image.network(
                      image,
                      fit:
                          BoxFit.contain,
                      errorBuilder:
                          (
                            _,
                            __,
                            ___,
                          ) =>
                              const Center(
                        child: Icon(
                          Icons
                              .inventory_2_outlined,
                          color:
                              BuyerTheme.muted,
                          size: 55,
                        ),
                      ),
                    ),
            ),

            Positioned(
              top: 11,
              left: 11,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 5,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      const Color(
                    0xFF292722,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),
                ),
                child:
                    const Text(
                  'SARI',
                  style:
                      TextStyle(
                    color:
                        Color(
                      0xFFFFC847,
                    ),
                    fontSize: 7,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
              ),
            ),

            Positioned(
              left: 0,
              bottom: 0,
              child: Container(
                padding:
                    const EdgeInsets.fromLTRB(
                  11,
                  5,
                  17,
                  5,
                ),
                decoration:
                    const BoxDecoration(
                  color:
                      Color(
                    0xFFF0B71B,
                  ),
                  borderRadius:
                      BorderRadius.only(
                    topRight:
                        Radius.circular(
                      12,
                    ),
                  ),
                ),
                child:
                    const Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'COD',
                      style:
                          TextStyle(
                        color:
                            Color(
                          0xFF332600,
                        ),
                        fontSize: 7,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),
                    Text(
                      'Cash on Delivery',
                      style:
                          TextStyle(
                        color:
                            Color(
                          0xFF332600,
                        ),
                        fontSize: 6.5,
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
      ),
    );
  }

  Widget _summary() {
    return Container(
      margin:
          const EdgeInsets.fromLTRB(
        12,
        11,
        12,
        0,
      ),
      padding:
          const EdgeInsets.all(
        16,
      ),
      decoration:
          BuyerTheme.card(
        radius: 18,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            _product.category
                .toUpperCase(),
            style:
                const TextStyle(
              color:
                  BuyerTheme.goldDark,
              fontSize: 7.5,
              fontWeight:
                  FontWeight.w900,
              letterSpacing: 1,
            ),
          ),

          const SizedBox(
            height: 7,
          ),

          Text(
            _product.name,
            style:
                const TextStyle(
              color:
                  BuyerTheme.ink,
              fontSize: 20,
              height: 1.08,
              fontWeight:
                  FontWeight.w900,
              letterSpacing: -.5,
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: <Widget>[
              if (_product.brand
                  .isNotEmpty)
                Text(
                  'Brand: ${_product.brand}',
                  style:
                      const TextStyle(
                    color:
                        BuyerTheme.muted,
                    fontSize: 8.5,
                  ),
                ),

              if (_product.sku
                  .isNotEmpty)
                Text(
                  'SKU: ${_product.sku}',
                  style:
                      const TextStyle(
                    color:
                        BuyerTheme.muted,
                    fontSize: 8.5,
                  ),
                ),
            ],
          ),

          const SizedBox(
            height: 15,
          ),

          Row(
            crossAxisAlignment:
                CrossAxisAlignment.end,
            children: <Widget>[
              Flexible(
                child: Text(
                  _money(
                    _currentPrice,
                  ),
                  style:
                      const TextStyle(
                    color:
                        BuyerTheme.goldDark,
                    fontSize: 26,
                    fontWeight:
                        FontWeight.w900,
                    fontFamilyFallback:
                        <String>[
                      'Roboto',
                      'Arial',
                    ],
                  ),
                ),
              ),

              if (_currentOldPrice !=
                      null &&
                  _currentOldPrice! >
                      _currentPrice) ...[
                const SizedBox(
                  width: 8,
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(
                    bottom: 4,
                  ),
                  child: Text(
                    _money(
                      _currentOldPrice!,
                    ),
                    style:
                        const TextStyle(
                      color:
                          BuyerTheme.muted,
                      fontSize: 9,
                      decoration:
                          TextDecoration
                              .lineThrough,
                    ),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(
            height: 8,
          ),

          Text(
            _inStock
                ? '$_currentStock in stock'
                : 'Out of stock',
            style:
                TextStyle(
              color:
                  _inStock
                      ? BuyerTheme.success
                      : BuyerTheme.danger,
              fontSize: 8,
              fontWeight:
                  FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _variantSection() {
    if (!_requiresVariant) {
      return const SizedBox.shrink();
    }

    return Container(
      margin:
          const EdgeInsets.fromLTRB(
        12,
        11,
        12,
        0,
      ),
      padding:
          const EdgeInsets.all(
        16,
      ),
      decoration:
          BuyerTheme.card(
        radius: 18,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Choose your variant',
            style:
                TextStyle(
              color:
                  BuyerTheme.ink,
              fontSize: 13,
              fontWeight:
                  FontWeight.w900,
            ),
          ),

          const SizedBox(
            height: 4,
          ),

          Text(
            _orderedGroups.length >= 2
                ? 'Select ${_orderedGroups.first} first, then ${_orderedGroups[1]}.'
                : _variantInstruction,
            style:
                const TextStyle(
              color:
                  BuyerTheme.muted,
              fontSize: 8.5,
            ),
          ),

          const SizedBox(
            height: 15,
          ),

          if (_variants.isEmpty)
            _variantUnavailable()
          else if (_optionGroups.isNotEmpty)
            ..._orderedGroups.map(
              (
                String group,
              ) =>
                  _optionSelector(
                group,
              ),
            )
          else
            _directVariantSelector(),

          if (_selectedVariant != null) ...[
            const SizedBox(
              height: 10,
            ),

            Container(
              width:
                  double.infinity,
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 11,
                vertical: 9,
              ),
              decoration:
                  BoxDecoration(
                color:
                    BuyerTheme.successSoft,
                borderRadius:
                    BorderRadius.circular(
                  11,
                ),
              ),
              child: Row(
                children: <Widget>[
                  const Icon(
                    Icons
                        .check_circle_rounded,
                    color:
                        BuyerTheme.success,
                    size: 16,
                  ),

                  const SizedBox(
                    width: 7,
                  ),

                  Expanded(
                    child: Text(
                      '${_selectedVariant!.label} • ${_selectedVariant!.stock} available',
                      style:
                          const TextStyle(
                        color:
                            BuyerTheme.success,
                        fontSize: 8.5,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _optionSelector(
    String group,
  ) {
    final List<String> values =
        _optionGroups[group] ??
            <String>[];

    final bool colorGroup =
        _isColorGroup(group);

    final List<String> groups =
        _orderedGroups;

    final int groupIndex =
        groups.indexOf(group);

    bool previousSelected =
        true;

    for (int i = 0;
        i < groupIndex;
        i++) {
      if (!_selectedOptions
          .containsKey(groups[i])) {
        previousSelected =
            false;

        break;
      }
    }

    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 15,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            group,
            style:
                TextStyle(
              color:
                  previousSelected
                      ? BuyerTheme.ink
                      : BuyerTheme.muted,
              fontSize: 9.5,
              fontWeight:
                  FontWeight.w800,
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          if (colorGroup)
            Wrap(
              spacing: 9,
              runSpacing: 9,
              children:
                  values.map(
                (
                  String value,
                ) {
                  final bool enabled =
                      previousSelected &&
                      _canSelectValue(
                        group,
                        value,
                      );

                  final bool selected =
                      _selectedOptions[
                          group] ==
                      value;

                  final Color swatch =
                      _colorValue(
                    value,
                  );

                  return Tooltip(
                    message: value,
                    child: GestureDetector(
                      onTap: enabled
                          ? () {
                              _selectOption(
                                group,
                                value,
                              );
                            }
                          : null,
                      child: AnimatedContainer(
                        duration:
                            const Duration(
                          milliseconds: 160,
                        ),
                        width: 38,
                        height: 38,
                        padding:
                            const EdgeInsets.all(
                          3,
                        ),
                        decoration:
                            BoxDecoration(
                          shape:
                              BoxShape.circle,
                          border:
                              Border.all(
                            color: selected
                                ? BuyerTheme.gold
                                : enabled
                                    ? BuyerTheme.border
                                    : const Color(
                                        0xFFE5E5E5,
                                      ),
                            width: selected
                                ? 2.4
                                : 1,
                          ),
                        ),
                        child: Container(
                          decoration:
                              BoxDecoration(
                            color: enabled
                                ? swatch
                                : swatch
                                    .withValues(
                                      alpha: .25,
                                    ),
                            shape:
                                BoxShape.circle,
                            border:
                                Border.all(
                              color:
                                  Colors.black12,
                            ),
                          ),
                          child: selected
                              ? Icon(
                                  Icons
                                      .check_rounded,
                                  size: 15,
                                  color:
                                      swatch.computeLuminance() >
                                              .6
                                          ? Colors
                                              .black
                                          : Colors
                                              .white,
                                )
                              : null,
                        ),
                      ),
                    ),
                  );
                },
              ).toList(),
            )
          else
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children:
                  values.map(
                (
                  String value,
                ) {
                  final bool enabled =
                      previousSelected &&
                      _canSelectValue(
                        group,
                        value,
                      );

                  final bool selected =
                      _selectedOptions[
                          group] ==
                      value;

                  return ChoiceChip(
                    label:
                        Text(
                      value,
                    ),
                    selected:
                        selected,
                    onSelected: enabled
                        ? (_) {
                            _selectOption(
                              group,
                              value,
                            );
                          }
                        : null,
                    selectedColor:
                        BuyerTheme.goldPale,
                    side:
                        BorderSide(
                      color: selected
                          ? BuyerTheme.gold
                          : BuyerTheme.border,
                    ),
                    labelStyle:
                        TextStyle(
                      color: enabled
                          ? BuyerTheme.ink
                          : BuyerTheme.muted,
                      fontSize: 9,
                      fontWeight:
                          selected
                              ? FontWeight
                                  .w800
                              : FontWeight
                                  .w600,
                    ),
                  );
                },
              ).toList(),
            ),

          if (!previousSelected) ...[
            const SizedBox(
              height: 6,
            ),
            Text(
              'Select ${groups[groupIndex - 1]} first.',
              style:
                  const TextStyle(
                color:
                    BuyerTheme.muted,
                fontSize: 7.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _directVariantSelector() {
    return Wrap(
      spacing: 7,
      runSpacing: 7,
      children:
          _variants.map(
        (
          _VariantData variant,
        ) {
          final bool selected =
              _selectedVariant?.id ==
                  variant.id;

          final bool enabled =
              variant.available &&
                  variant.stock > 0;

          return ChoiceChip(
            label:
                Text(
              variant.label,
            ),
            selected:
                selected,
            onSelected: enabled
                ? (_) {
                    _selectDirectVariant(
                      variant,
                    );
                  }
                : null,
            selectedColor:
                BuyerTheme.goldPale,
            side:
                BorderSide(
              color: selected
                  ? BuyerTheme.gold
                  : BuyerTheme.border,
            ),
          );
        },
      ).toList(),
    );
  }

  Widget _variantUnavailable() {
    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.all(
        12,
      ),
      decoration:
          BoxDecoration(
        color:
            const Color(
          0xFFFFF4E7,
        ),
        borderRadius:
            BorderRadius.circular(
          12,
        ),
        border:
            Border.all(
          color:
              const Color(
            0xFFEBCB95,
          ),
        ),
      ),
      child:
          const Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            Icons.info_outline_rounded,
            color:
                BuyerTheme.goldDark,
            size: 17,
          ),

          SizedBox(
            width: 8,
          ),

          Expanded(
            child: Text(
              'This product requires a variation, but the current mobile product response did not include its variation options. Add to Cart is disabled so the app will not guess a Size or Color.',
              style:
                  TextStyle(
                color:
                    BuyerTheme.body,
                fontSize: 8.5,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quantitySection() {
    return Container(
      margin:
          const EdgeInsets.fromLTRB(
        12,
        11,
        12,
        0,
      ),
      padding:
          const EdgeInsets.all(
        15,
      ),
      decoration:
          BuyerTheme.card(
        radius: 17,
      ),
      child: Row(
        children: <Widget>[
          const Expanded(
            child: Text(
              'Quantity',
              style:
                  TextStyle(
                color:
                    BuyerTheme.ink,
                fontSize: 10,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
          ),

          _quantityButton(
            icon:
                Icons.remove_rounded,
            enabled:
                _quantity > 1,
            onTap:
                _decreaseQuantity,
          ),

          SizedBox(
            width: 38,
            child: Text(
              '$_quantity',
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                color:
                    BuyerTheme.ink,
                fontSize: 11,
                fontWeight:
                    FontWeight.w900,
              ),
            ),
          ),

          _quantityButton(
            icon:
                Icons.add_rounded,
            enabled:
                _variantReady &&
                _inStock &&
                _quantity <
                    _currentStock,
            onTap:
                _increaseQuantity,
          ),
        ],
      ),
    );
  }

  Widget _quantityButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 34,
      height: 34,
      child:
          OutlinedButton(
        onPressed:
            enabled
                ? onTap
                : null,
        style:
            OutlinedButton.styleFrom(
          padding:
              EdgeInsets.zero,
          shape:
              const CircleBorder(),
        ),
        child: Icon(
          icon,
          size: 15,
        ),
      ),
    );
  }

  Widget _actions() {
    final bool enabled =
        !_addingToCart &&
        _inStock &&
        _variantReady;

    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        12,
        11,
        12,
        0,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child:
                OutlinedButton.icon(
              onPressed:
                  enabled
                      ? () {
                          _addToCart();
                        }
                      : null,
              icon:
                  const Icon(
                Icons
                    .add_shopping_cart_outlined,
                size: 17,
              ),
              label:
                  const Text(
                'Add to Cart',
                style:
                    TextStyle(
                  fontSize: 9,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
            ),
          ),

          const SizedBox(
            width: 8,
          ),

          Expanded(
            child:
                FilledButton.icon(
              onPressed:
                  enabled
                      ? _buyNow
                      : null,
              icon:
                  _addingToCart
                      ? const SizedBox(
                          width: 15,
                          height: 15,
                          child:
                              CircularProgressIndicator(
                            strokeWidth:
                                2,
                            color:
                                Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons
                              .shopping_bag_outlined,
                          size: 17,
                        ),
              label:
                  Text(
                _addingToCart
                    ? 'Adding...'
                    : 'Buy Now',
                style:
                    const TextStyle(
                  fontSize: 9,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _description() {
    final String description =
        _product.description
                ?.trim() ??
            '';

    return Container(
      margin:
          const EdgeInsets.fromLTRB(
        12,
        11,
        12,
        0,
      ),
      padding:
          const EdgeInsets.all(
        15,
      ),
      decoration:
          BuyerTheme.card(
        radius: 17,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Product Details',
            style:
                TextStyle(
              color:
                  BuyerTheme.ink,
              fontSize: 12,
              fontWeight:
                  FontWeight.w900,
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          Text(
            description.isEmpty
                ? 'No product description provided.'
                : description,
            style:
                const TextStyle(
              color:
                  BuyerTheme.body,
              fontSize: 9,
              height: 1.5,
            ),
          ),

          const SizedBox(
            height: 13,
          ),

          _detailRow(
            'Category',
            _product.category,
          ),

          if (_product.brand
              .isNotEmpty)
            _detailRow(
              'Brand',
              _product.brand,
            ),

          if (_product.sku
              .isNotEmpty)
            _detailRow(
              'SKU',
              _product.sku,
            ),
        ],
      ),
    );
  }

  Widget _detailRow(
    String label,
    String value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 4,
      ),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 80,
            child: Text(
              label,
              style:
                  const TextStyle(
                color:
                    BuyerTheme.muted,
                fontSize: 8,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style:
                  const TextStyle(
                color:
                    BuyerTheme.ink,
                fontSize: 8.5,
                fontWeight:
                    FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _seller() {
    return Container(
      margin:
          const EdgeInsets.fromLTRB(
        12,
        11,
        12,
        25,
      ),
      padding:
          const EdgeInsets.all(
        14,
      ),
      decoration:
          BuyerTheme.card(
        radius: 17,
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 42,
            height: 42,
            alignment:
                Alignment.center,
            decoration:
                BoxDecoration(
              color:
                  BuyerTheme.goldPale,
              borderRadius:
                  BorderRadius.circular(
                12,
              ),
            ),
            child:
                const Icon(
              Icons
                  .storefront_outlined,
              color:
                  BuyerTheme.goldDark,
              size: 21,
            ),
          ),

          const SizedBox(
            width: 10,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'SOLD BY',
                  style:
                      TextStyle(
                    color:
                        BuyerTheme.muted,
                    fontSize: 6.5,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),

                const SizedBox(
                  height: 2,
                ),

                Text(
                  _product.shopName,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      const TextStyle(
                    color:
                        BuyerTheme.ink,
                    fontSize: 10.5,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorState() {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(
          25,
        ),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons
                  .cloud_off_outlined,
              color:
                  BuyerTheme.muted,
              size: 45,
            ),

            const SizedBox(
              height: 11,
            ),

            Text(
              _error ??
                  'Unable to load product.',
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                color:
                    BuyerTheme.muted,
              ),
            ),

            const SizedBox(
              height: 14,
            ),

            OutlinedButton.icon(
              onPressed:
                  _loadProduct,
              icon:
                  const Icon(
                Icons.refresh_rounded,
              ),
              label:
                  const Text(
                'Retry',
              ),
            ),
          ],
        ),
      ),
    );
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

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          BuyerTheme.canvas,
      appBar: AppBar(
        title:
            const Text(
          'Product Details',
          style:
              TextStyle(
            fontSize: 16,
            fontWeight:
                FontWeight.w900,
          ),
        ),
        actions: <Widget>[
          IconButton(
            tooltip:
                'Cart',
            onPressed:
                _openCart,
            icon:
                const Icon(
              Icons
                  .shopping_cart_outlined,
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : _error != null
              ? _errorState()
              : RefreshIndicator(
                  color:
                      BuyerTheme.gold,
                  onRefresh:
                      _loadProduct,
                  child: ListView(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    padding:
                        EdgeInsets.zero,
                    children: <Widget>[
                      _productImage(),
                      _summary(),
                      _variantSection(),
                      _quantitySection(),
                      _actions(),
                      _description(),
                      _seller(),
                    ],
                  ),
                ),
    );
  }
}

// ============================================================
// INTERNAL MODELS
// ============================================================

class _ParsedProduct {
  final BuyerProduct product;

  final List<_VariantData> variants;

  final Map<String, List<String>>
      optionGroups;

  final bool hasVariants;

  const _ParsedProduct({
    required this.product,
    required this.variants,
    required this.optionGroups,
    required this.hasVariants,
  });
}

class _VariantData {
  final int id;

  final String label;

  final Map<String, String> options;

  final double price;

  final double? oldPrice;

  final int stock;

  final bool available;

  final String? image;

  const _VariantData({
    required this.id,
    required this.label,
    required this.options,
    required this.price,
    required this.oldPrice,
    required this.stock,
    required this.available,
    required this.image,
  });
}