import 'package:flutter/material.dart';

import '../services/sari_live_data.dart';
import 'buyer_cart.dart';
import 'models/buyer_product_model.dart';

class BuyerProductDetails
    extends StatefulWidget {
  final BuyerProduct product;

  final VoidCallback? onViewCart;

  const BuyerProductDetails({
    super.key,
    required this.product,
    this.onViewCart,
  });

  @override
  State<BuyerProductDetails>
      createState() =>
          _BuyerProductDetailsState();
}

class _BuyerProductDetailsState
    extends State<BuyerProductDetails> {
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

  late BuyerProduct _product;

  bool _loading = true;
  bool _addingToCart = false;

  String? _error;

  int _quantity = 1;

  @override
  void initState() {
    super.initState();

    _product = widget.product;

    _loadProduct();
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
      brand:
          _text(data['brand']),
      description:
          _text(data['description']),
      image:
          _text(
            data['image_url'],
          ).isEmpty
              ? null
              : _text(
                  data['image_url'],
                ),
      price:
          _decimal(data['price']),

      // Do not fabricate the web old-price
      // or platform campaign price.
      oldPrice: null,

      stock:
          _integer(data['stock']),
      shopName: _text(
        data['store_name'],
        'SARI Store',
      ),
      sellerAccountId:
          _integer(
        data['seller_id'],
      ),
    );
  }

  Future<void> _loadProduct()
      async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response =
          await SariLiveData.instance
              .productDetails(
        widget.product.id,
      );

      final raw =
          response['data'];

      if (raw is! Map) {
        throw const FormatException(
          'Invalid product details from SARI.',
        );
      }

      final product =
          _parseProduct(raw);

      if (product.id <= 0) {
        throw const FormatException(
          'Invalid product ID.',
        );
      }

      if (!mounted) return;

      setState(() {
        _product = product;

        if (_product.stock <= 0) {
          _quantity = 1;
        } else if (_quantity >
            _product.stock) {
          _quantity =
              _product.stock;
        }

        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error =
            error.toString();
      });
    }
  }

  bool get _inStock =>
      _product.stock > 0;

  String _money(
    double amount,
  ) {
    return '₱${amount.toStringAsFixed(2)}';
  }

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
        _quantity >= _product.stock) {
      return;
    }

    setState(() {
      _quantity++;
    });
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

  Future<bool> _addToCart()
      async {
    if (!_inStock ||
        _addingToCart) {
      return false;
    }

    setState(() {
      _addingToCart = true;
    });

    try {
      final response =
          await SariLiveData.instance
              .buyerAddCart(
        productId:
            _product.id,
        quantity:
            _quantity,
      );

      if (!mounted) {
        return false;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              response['message']
                      ?.toString() ??
                  'Item added to cart.',
            ),
            behavior:
                SnackBarBehavior.floating,
          ),
        );

      return true;
    } catch (error) {
      if (!mounted) {
        return false;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              error.toString(),
            ),
            behavior:
                SnackBarBehavior.floating,
          ),
        );

      return false;
    } finally {
      if (mounted) {
        setState(() {
          _addingToCart = false;
        });
      }
    }
  }

  Future<void> _buyNow()
      async {
    final added =
        await _addToCart();

    if (!added || !mounted) {
      return;
    }

    _openCart();
  }

  Widget _imageSection() {
    final image =
        _product.image?.trim() ?? '';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(15),
        border: Border.all(
          color: border,
        ),
      ),
      clipBehavior:
          Clip.antiAlias,
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: image.isEmpty
                ? _imagePlaceholder()
                : Image.network(
                    image,
                    fit: BoxFit.contain,
                    errorBuilder:
                        (_, __, ___) =>
                            _imagePlaceholder(),
                  ),
          ),
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.all(11),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: border,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _product.category,
                    style:
                        const TextStyle(
                      color: muted,
                      fontSize: 10,
                    ),
                  ),
                ),
                _stockBadge(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return const ColoredBox(
      color: Color(0xFFF4F4F4),
      child: Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              color: Color(
                0xFFAAAEB5,
              ),
              size: 58,
            ),
            SizedBox(height: 9),
            Text(
              'No product image',
              style: TextStyle(
                color: muted,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stockBadge() {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: _inStock
            ? const Color(
                0xFFEAF7EF,
              )
            : const Color(
                0xFFFDECEC,
              ),
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Text(
        _inStock
            ? 'In Stock'
            : 'Out of Stock',
        style: TextStyle(
          color: _inStock
              ? const Color(
                  0xFF248450,
                )
              : const Color(
                  0xFFBD3434,
                ),
          fontSize: 9,
          fontWeight:
              FontWeight.w700,
        ),
      ),
    );
  }

  Widget _productSummary() {
    return _card(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            _product.category
                .toUpperCase(),
            style: const TextStyle(
              color: goldDark,
              fontSize: 9,
              fontWeight:
                  FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _product.name,
            style: const TextStyle(
              color: dark,
              fontSize: 24,
              height: 1.15,
              fontWeight:
                  FontWeight.w800,
              letterSpacing: -.6,
            ),
          ),
          if (_product.brand
              .trim()
              .isNotEmpty) ...[
            const SizedBox(height: 7),
            Text(
              'Brand: ${_product.brand}',
              style: const TextStyle(
                color: muted,
                fontSize: 11,
              ),
            ),
          ],
          const SizedBox(height: 18),
          const Divider(
            color: border,
          ),
          const SizedBox(height: 15),
          Text(
            _money(
              _product.price,
            ),
            style: const TextStyle(
              color: goldDark,
              fontSize: 31,
              fontWeight:
                  FontWeight.w800,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            _inStock
                ? '${_product.stock} in stock'
                : 'This product is currently out of stock.',
            style: TextStyle(
              color: _inStock
                  ? muted
                  : Colors.redAccent,
              fontSize: 11,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Quantity',
            style: TextStyle(
              color: dark,
              fontSize: 11,
              fontWeight:
                  FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _quantityButton(
                icon: Icons.remove,
                enabled:
                    _inStock &&
                        _quantity > 1,
                onTap:
                    _decreaseQuantity,
              ),
              Container(
                width: 54,
                height: 42,
                alignment:
                    Alignment.center,
                decoration:
                    const BoxDecoration(
                  color:
                      Colors.white,
                  border: Border(
                    top: BorderSide(
                      color: border,
                    ),
                    bottom: BorderSide(
                      color: border,
                    ),
                  ),
                ),
                child: Text(
                  '$_quantity',
                  style:
                      const TextStyle(
                    color: dark,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
              ),
              _quantityButton(
                icon: Icons.add,
                enabled:
                    _inStock &&
                        _quantity <
                            _product
                                .stock,
                onTap:
                    _increaseQuantity,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child:
                    OutlinedButton.icon(
                  onPressed:
                      _inStock &&
                              !_addingToCart
                          ? _addToCart
                          : null,
                  icon:
                      const Icon(
                    Icons
                        .shopping_cart_outlined,
                    size: 18,
                  ),
                  label: Text(
                    _addingToCart
                        ? 'Adding...'
                        : _inStock
                            ? 'Add to Cart'
                            : 'Out of Stock',
                  ),
                  style:
                      OutlinedButton
                          .styleFrom(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      vertical: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child:
                    ElevatedButton.icon(
                  onPressed:
                      _inStock &&
                              !_addingToCart
                          ? _buyNow
                          : null,
                  icon:
                      const Icon(
                    Icons
                        .bolt_rounded,
                    size: 18,
                  ),
                  label:
                      const Text(
                    'Buy Now',
                  ),
                  style:
                      ElevatedButton
                          .styleFrom(
                    backgroundColor:
                        gold,
                    foregroundColor:
                        Colors.white,
                    padding:
                        const EdgeInsets
                            .symmetric(
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Align(
            alignment:
                Alignment.centerLeft,
            child: TextButton(
              onPressed:
                  _openCart,
              child:
                  const Text(
                'View Cart',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _productInformation() {
    final description =
        _product.description
                ?.trim() ??
            '';

    return _card(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'Product information',
            style: TextStyle(
              color: goldDark,
              fontSize: 9,
              fontWeight:
                  FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Product details',
            style: TextStyle(
              color: dark,
              fontSize: 18,
              fontWeight:
                  FontWeight.w800,
            ),
          ),
          const SizedBox(height: 15),
          const Divider(
            color: border,
          ),
          const SizedBox(height: 15),
          const Text(
            'Description',
            style: TextStyle(
              color: dark,
              fontSize: 11,
              fontWeight:
                  FontWeight.w700,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            description.isEmpty
                ? 'The seller did not provide a description for this product.'
                : description,
            style: const TextStyle(
              color: muted,
              fontSize: 11,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 20),
          _detailRow(
            'Category',
            _product.category,
          ),
          if (_product.brand
              .trim()
              .isNotEmpty)
            _detailRow(
              'Brand',
              _product.brand,
            ),
          _detailRow(
            'Availability',
            _inStock
                ? '${_product.stock} in stock'
                : 'Out of Stock',
          ),
        ],
      ),
    );
  }

  Widget _sellerSection() {
    return _card(
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            alignment:
                Alignment.center,
            decoration: BoxDecoration(
              color: const Color(
                0xFFFFF3DA,
              ),
              borderRadius:
                  BorderRadius.circular(
                12,
              ),
            ),
            child: const Icon(
              Icons.storefront_outlined,
              color: goldDark,
              size: 23,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sold by',
                  style: TextStyle(
                    color: muted,
                    fontSize: 9,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _product.shopName,
                  style: const TextStyle(
                    color: dark,
                    fontSize: 13,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Approved SARI marketplace seller',
                  style: TextStyle(
                    color: muted,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
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
      width: 44,
      height: 42,
      child: OutlinedButton(
        onPressed:
            enabled ? onTap : null,
        style:
            OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          side: const BorderSide(
            color: border,
          ),
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              7,
            ),
          ),
        ),
        child: Icon(
          icon,
          size: 18,
        ),
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
        vertical: 8,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
            child: Text(
              label,
              style:
                  const TextStyle(
                color: muted,
                fontSize: 10,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style:
                  const TextStyle(
                color: dark,
                fontSize: 10,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color: border,
        ),
      ),
      child: child,
    );
  }

  Widget _errorState() {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(24),
        child: _card(
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              const Icon(
                Icons.wifi_off_rounded,
                color: muted,
                size: 45,
              ),
              const SizedBox(height: 12),
              const Text(
                'Unable to load product',
                style: TextStyle(
                  color: dark,
                  fontSize: 16,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                _error ??
                    'Please try again.',
                textAlign:
                    TextAlign.center,
                style:
                    const TextStyle(
                  color: muted,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 15),
              OutlinedButton.icon(
                onPressed:
                    _loadProduct,
                icon:
                    const Icon(
                  Icons.refresh_rounded,
                ),
                label:
                    const Text(
                  'Try Again',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: canvas,
      appBar: AppBar(
        backgroundColor:
            Colors.white,
        foregroundColor: dark,
        surfaceTintColor:
            Colors.white,
        elevation: 0,
        title: const Text(
          'Product Details',
          style: TextStyle(
            fontSize: 16,
            fontWeight:
                FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'View Cart',
            onPressed:
                _openCart,
            icon: const Icon(
              Icons
                  .shopping_cart_outlined,
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child:
                  CircularProgressIndicator(
                color: gold,
              ),
            )
          : _error != null
              ? _errorState()
              : RefreshIndicator(
                  color: gold,
                  onRefresh:
                      _loadProduct,
                  child: ListView(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    padding:
                        const EdgeInsets.fromLTRB(
                      14,
                      15,
                      14,
                      30,
                    ),
                    children: [
                      Row(
                        children: [
                          TextButton(
                            onPressed: () =>
                                Navigator.of(
                                  context,
                                ).pop(),
                            child: const Text(
                              'Products',
                            ),
                          ),
                          const Icon(
                            Icons
                                .chevron_right_rounded,
                            size: 16,
                            color: muted,
                          ),
                          Expanded(
                            child: Text(
                              _product.name,
                              maxLines: 1,
                              overflow:
                                  TextOverflow
                                      .ellipsis,
                              style:
                                  const TextStyle(
                                color: dark,
                                fontSize: 10,
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _imageSection(),
                      const SizedBox(height: 12),
                      _productSummary(),
                      const SizedBox(height: 12),
                      _productInformation(),
                      const SizedBox(height: 12),
                      _sellerSection(),
                    ],
                  ),
                ),
    );
  }
}