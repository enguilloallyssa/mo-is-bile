
import 'package:flutter/material.dart';

import '../services/sari_live_data.dart';
import 'models/buyer_product_model.dart';

class BuyerProductDetails extends StatefulWidget {
  final BuyerProduct product;
  final List<BuyerProduct> relatedProducts;
  final int initialCartCount;
  final ValueChanged<int>? onCartCountChanged;
  final VoidCallback? onViewCart;
  final VoidCallback? onVisitShop;
  final VoidCallback? onMessageSeller;
  final bool buyNowMode;

  const BuyerProductDetails({
    super.key,
    required this.product,
    this.relatedProducts = const [],
    this.initialCartCount = 0,
    this.onCartCountChanged,
    this.onViewCart,
    this.onVisitShop,
    this.onMessageSeller,
    this.buyNowMode = false,
  });

  @override
  State<BuyerProductDetails> createState() =>
      _BuyerProductDetailsState();
}

class _BuyerProductDetailsState
    extends State<BuyerProductDetails> {
  static const Color gold = Color(0xFFC98B13);
  static const Color dark = Color(0xFF292929);
  static const Color canvas = Color(0xFFF4F5F7);
  static const Color border = Color(0xFFE6E8EC);
  static const Color muted = Color(0xFF808792);

  late BuyerProduct _product;

  bool _loading = true;
  String? _error;

  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    _loadProduct();
  }


Future<void> _loadProduct() async {
  setState(() {
    _loading = true;
    _error = null;
  });

  try {
    final response =
        await SariLiveData.instance.productDetails(
      widget.product.id,
    );

    if (!mounted) return;

    final raw = response['data'];

    if (raw is! Map) {
      throw const FormatException(
        'Invalid product data received from Laravel.',
      );
    }

    final data = Map<String, dynamic>.from(raw);

    double toDouble(dynamic value) {
      return double.tryParse(value?.toString() ?? '') ?? 0;
    }

    int toInt(dynamic value) {
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    String toText(dynamic value, [String fallback = '']) {
      return value?.toString() ?? fallback;
    }

    final price = toDouble(data['price']);
    final discount = toDouble(data['discount']);

    final product = BuyerProduct(
      id: toInt(data['id']),
      name: toText(data['name'], 'Unnamed product'),
      category: toText(data['category'], 'Other'),
      brand: toText(data['brand']),
      description: toText(data['description']),
      image: toText(data['image_url']).isEmpty
          ? null
          : toText(data['image_url']),
      price: price,
      oldPrice: discount > 0 && discount < 100
          ? price / (1 - discount / 100)
          : null,
      stock: toInt(data['stock']),
      shopName: toText(data['store_name'], 'SARI Store'),
      sellerAccountId: toInt(data['seller_id']),
    );

    if (product.id <= 0) {
      throw const FormatException(
        'Invalid product ID received from Laravel.',
      );
    }

    setState(() {
      _product = product;
      _loading = false;

      if (_quantity > product.stock && product.stock > 0) {
        _quantity = product.stock;
      }
    });
  } catch (error) {
    if (!mounted) return;

    setState(() {
      _error = error.toString();
      _loading = false;
    });
  }
}


  String _peso(double amount) {
    return '₱${amount.toStringAsFixed(2)}';
  }

  bool get _inStock => _product.stock > 0;

  void _changeQuantity(int change) {
    if (!_inStock) return;

    final next = _quantity + change;

    if (next < 1 || next > _product.stock) {
      return;
    }

    setState(() {
      _quantity = next;
    });
  }

  void _showUnavailable(String feature) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            '$feature is not yet connected to the '
            'Laravel mobile API.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
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

  Widget _statusBadge() {
    final available = _inStock;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: available
            ? const Color(0xFFEAF7EF)
            : const Color(0xFFFDECEC),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        available ? 'In Stock' : 'Out of Stock',
        style: TextStyle(
          color: available
              ? const Color(0xFF248450)
              : const Color(0xFFBD3434),
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _productImage() {
    final image = _product.image?.trim() ?? '';

    return _panel(
      padding: const EdgeInsets.all(12),
      child: AspectRatio(
        aspectRatio: 1,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: image.isEmpty
              ? _imagePlaceholder()
              : Image.network(
                  image,
                  fit: BoxFit.contain,
                  loadingBuilder: (
                    context,
                    child,
                    progress,
                  ) {
                    if (progress == null) return child;

                    return const Center(
                      child: CircularProgressIndicator(
                        color: gold,
                        strokeWidth: 2,
                      ),
                    );
                  },
                  errorBuilder: (
                    context,
                    error,
                    stackTrace,
                  ) {
                    return _imagePlaceholder();
                  },
                ),
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: const Color(0xFFF7F7F7),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 65,
            color: Color(0xFFB8BEC7),
          ),
          SizedBox(height: 12),
          Text(
            'No product image',
            style: TextStyle(
              fontSize: 12,
              color: muted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _productInformation() {
    final discount = _product.discountPercent;

    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _product.category.isNotEmpty
                      ? _product.category.toUpperCase()
                      : 'PRODUCT',
                  style: const TextStyle(
                    color: gold,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              _statusBadge(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _product.name,
            style: const TextStyle(
              color: dark,
              fontSize: 23,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          if (_product.brand.isNotEmpty) ...[
            const SizedBox(height: 7),
            Text(
              'Brand: ${_product.brand}',
              style: const TextStyle(
                color: muted,
                fontSize: 12,
              ),
            ),
          ],
          const SizedBox(height: 16),
          const Divider(color: border),
          const SizedBox(height: 12),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 10,
            runSpacing: 8,
            children: [
              Text(
                _peso(_product.price),
                style: const TextStyle(
                  color: gold,
                  fontSize: 27,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (_product.oldPrice != null &&
                  _product.oldPrice! > _product.price)
                Text(
                  _peso(_product.oldPrice!),
                  style: const TextStyle(
                    color: muted,
                    fontSize: 14,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              if (discount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0D7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '$discount% OFF',
                    style: const TextStyle(
                      color: Color(0xFFB4770C),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            _inStock
                ? '${_product.stock} items available'
                : 'Currently unavailable',
            style: const TextStyle(
              color: muted,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'QUANTITY',
            style: TextStyle(
              color: dark,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _quantityButton(
                Icons.remove,
                () => _changeQuantity(-1),
                enabled: _inStock && _quantity > 1,
              ),
              Container(
                width: 52,
                height: 40,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: border),
                    bottom: BorderSide(color: border),
                  ),
                ),
                child: Text(
                  '$_quantity',
                  style: const TextStyle(
                    color: dark,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _quantityButton(
                Icons.add,
                () => _changeQuantity(1),
                enabled:
                    _inStock && _quantity < _product.stock,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: null,
                  icon: const Icon(
                    Icons.add_shopping_cart_outlined,
                    size: 17,
                  ),
                  label: const Text('Add to Cart'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                    ),
                    side: const BorderSide(color: gold),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: null,
                  icon: const Icon(
                    Icons.shopping_bag_outlined,
                    size: 17,
                  ),
                  label: const Text('Buy Now'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: gold,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        const Color(0xFFE4E5E7),
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Cart and checkout are not yet available '
            'through the mobile API.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: muted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _quantityButton(
    IconData icon,
    VoidCallback onPressed, {
    required bool enabled,
  }) {
    return SizedBox(
      width: 42,
      height: 40,
      child: OutlinedButton(
        onPressed: enabled ? onPressed : null,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          side: const BorderSide(color: border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        child: Icon(
          icon,
          color: enabled ? dark : muted,
          size: 17,
        ),
      ),
    );
  }

  Widget _descriptionSection() {
    final description = _product.description?.trim() ?? '';

    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Product Description',
            style: TextStyle(
              color: dark,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: border),
          const SizedBox(height: 12),
          Text(
            description.isNotEmpty
                ? description
                : 'No description provided by the seller.',
            style: const TextStyle(
              color: Color(0xFF667085),
              fontSize: 12,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }

  Widget _specifications() {
    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Product Information',
            style: TextStyle(
              color: dark,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: border),
          _infoRow('Product ID', '${_product.id}'),
          _infoRow('Category', _product.category),
          if (_product.brand.isNotEmpty)
            _infoRow('Brand', _product.brand),
          _infoRow(
            'Availability',
            _inStock ? 'In Stock' : 'Out of Stock',
          ),
          _infoRow(
            'Available Quantity',
            '${_product.stock}',
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 135,
            child: Text(
              label,
              style: const TextStyle(
                color: muted,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: dark,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sellerSection() {
    return _panel(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF2DC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.storefront_outlined,
              color: gold,
              size: 26,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SOLD BY',
                  style: TextStyle(
                    color: muted,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _product.shopName,
                  style: const TextStyle(
                    color: dark,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.verified_outlined,
            color: gold,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _errorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: _panel(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.wifi_off_rounded,
                color: muted,
                size: 44,
              ),
              const SizedBox(height: 12),
              const Text(
                'Unable to load product',
                style: TextStyle(
                  color: dark,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _error ?? 'Unknown error',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: muted,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: _loadProduct,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: gold,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _breadcrumb() {
    return Row(
      children: [
        const Text(
          'Products',
          style: TextStyle(
            color: muted,
            fontSize: 11,
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 7),
          child: Icon(
            Icons.chevron_right_rounded,
            size: 15,
            color: muted,
          ),
        ),
        Expanded(
          child: Text(
            _product.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: dark,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: canvas,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: dark,
        surfaceTintColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Product Details',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Cart',
            onPressed: widget.onViewCart ??
                () => _showUnavailable('Cart'),
            icon: const Icon(
              Icons.shopping_cart_outlined,
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                color: gold,
              ),
            )
          : _error != null
              ? _errorState()
              : RefreshIndicator(
                  color: gold,
                  onRefresh: _loadProduct,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      14,
                      18,
                      14,
                      30,
                    ),
                    children: [
                      _breadcrumb(),
                      const SizedBox(height: 15),
                      _productImage(),
                      const SizedBox(height: 14),
                      _productInformation(),
                      const SizedBox(height: 14),
                      _descriptionSection(),
                      const SizedBox(height: 14),
                      _specifications(),
                      const SizedBox(height: 14),
                      _sellerSection(),
                    ],
                  ),
                ),
    );
  }
}
