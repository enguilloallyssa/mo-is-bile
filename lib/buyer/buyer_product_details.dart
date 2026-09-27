// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'models/buyer_product_model.dart';
import 'models/buyer_cart_model.dart';
import 'buyer_checkout.dart';

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
  State<BuyerProductDetails> createState() => _BuyerProductDetailsState();
}

class _BuyerProductDetailsState extends State<BuyerProductDetails> {
  static const Color _gold = Color(0xFFC98B13);
  static const Color _goldDark = Color(0xFFB77D10);
  static const Color _background = Color(0xFFFBFAF7);
  static const Color _border = Color(0xFFE8DFD3);
  static const Color _text = Color(0xFF2F2923);
  static const Color _muted = Color(0xFF847A70);

  BuyerProductVariant? _selectedVariant;
  int _selectedImageIndex = 0;
  int _quantity = 1;
  late int _cartCount;

  BuyerProduct get product => widget.product;

  double get _activePrice => _selectedVariant?.price ?? product.price;

  double? get _activeOldPrice =>
      _selectedVariant?.oldPrice ?? product.oldPrice;

  int get _activeStock => _selectedVariant?.stock ?? product.stock;

  bool get _needsVariant => product.variants.isNotEmpty;

  List<String> get _gallery {
    final values = <String>[...product.gallery];

    final variantImage = _selectedVariant?.image?.trim() ?? '';
    if (variantImage.isNotEmpty && !values.contains(variantImage)) {
      values.insert(0, variantImage);
    }

    return values;
  }

  List<BuyerProduct> get _related {
    final candidates = widget.relatedProducts
        .where((item) => item.id != product.id)
        .toList();

    candidates.sort((a, b) {
      final aSame =
          a.category.toLowerCase() == product.category.toLowerCase();
      final bSame =
          b.category.toLowerCase() == product.category.toLowerCase();

      if (aSame == bSame) return 0;
      return aSame ? -1 : 1;
    });

    return candidates.take(4).toList();
  }

  @override
  void initState() {
    super.initState();
    _cartCount = widget.initialCartCount;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFDFA),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 0,
        title: const Text(
          'Product Details',
          style: TextStyle(
            color: _text,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                tooltip: 'View Cart',
                onPressed: _openCart,
                icon: const Icon(Icons.shopping_cart_outlined),
              ),
              if (_cartCount > 0)
                Positioned(
                  right: 3,
                  top: 3,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 18),
                    height: 18,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _gold,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFFFFDFA),
                        width: 2,
                      ),
                    ),
                    child: Text(
                      _cartCount > 99 ? '99+' : '$_cartCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 7,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 26),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _breadcrumb(),
            const SizedBox(height: 12),
            _gallerySection(),
            const SizedBox(height: 16),
            _buyingPanel(),
            const SizedBox(height: 16),
            _descriptionCard(),
            const SizedBox(height: 12),
            _detailsCard(),
            const SizedBox(height: 12),
            _reviewsCard(),
            if (_related.isNotEmpty) ...[
              const SizedBox(height: 20),
              _relatedSection(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _breadcrumb() {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        InkWell(
          onTap: () => Navigator.popUntil(context, (route) => route.isFirst),
          child: const Text(
            'Home',
            style: TextStyle(
              color: Color(0xFF91887E),
              fontSize: 9,
            ),
          ),
        ),
        const Text(
          '/',
          style: TextStyle(
            color: Color(0xFFC6BEB5),
            fontSize: 9,
          ),
        ),
        InkWell(
          onTap: () => Navigator.pop(context),
          child: const Text(
            'Products',
            style: TextStyle(
              color: Color(0xFF91887E),
              fontSize: 9,
            ),
          ),
        ),
        const Text(
          '/',
          style: TextStyle(
            color: Color(0xFFC6BEB5),
            fontSize: 9,
          ),
        ),
        Text(
          product.name,
          style: const TextStyle(
            color: Color(0xFF5C544C),
            fontSize: 9,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _gallerySection() {
    final gallery = _gallery;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: gallery.isEmpty ? null : _openImagePreview,
          child: Container(
            height: 320,
            decoration: BoxDecoration(
              color: const Color(0xFFFCFBF8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: gallery.isEmpty
                    ? const Color(0xFFDDD4C8)
                    : const Color(0xFFE8E0D5),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: gallery.isEmpty
                ? const _ImagePlaceholder(
                    text: 'No product image',
                    large: true,
                  )
                : _buildImage(
                    gallery[
                        _selectedImageIndex.clamp(0, gallery.length - 1).toInt()],
                    fit: BoxFit.contain,
                  ),
          ),
        ),
        if (gallery.length > 1) ...[
          const SizedBox(height: 10),
          SizedBox(
            height: 68,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: gallery.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final selected = index == _selectedImageIndex;

                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedImageIndex = index;
                    });
                  },
                  borderRadius: BorderRadius.circular(11),
                  child: Container(
                    width: 68,
                    height: 68,
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(
                        color: selected
                            ? _gold
                            : const Color(0xFFE4DDD3),
                        width: selected ? 2 : 1,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _buildImage(
                      gallery[index],
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  if (product.freeShipping)
                    _pill(
                      icon: Icons.local_shipping_outlined,
                      text: 'Free Shipping',
                      background: const Color(0xFFEFF9F2),
                      foreground: const Color(0xFF347451),
                      border: const Color(0xFFBEDEC8),
                    ),
                  if (product.discountPercent > 0)
                    _pill(
                      text: '-${product.discountPercent}%',
                      background: const Color(0xFFFFF4D7),
                      foreground: const Color(0xFF9B6208),
                      border: const Color(0xFFEAD09A),
                    ),
                ],
              ),
            ),
            if (gallery.length > 1)
              _pill(
                text:
                    '${_selectedImageIndex + 1} / ${gallery.length}',
                background: Colors.white,
                foreground: const Color(0xFF6F665D),
                border: const Color(0xFFE2DBD1),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buyingPanel() {
    final oldPrice = _activeOldPrice;
    final stock = _activeStock;

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D493825),
            blurRadius: 20,
            offset: Offset(8, 8),
          ),
          BoxShadow(
            color: Color(0xE6FFFFFF),
            blurRadius: 16,
            offset: Offset(-6, -6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              _badge(product.category, gold: true),
              if (product.condition.trim().isNotEmpty)
                _badge(
                  _titleCase(product.condition.replaceAll('_', ' ')),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            product.name,
            style: const TextStyle(
              color: Color(0xFF231F1B),
              fontSize: 25,
              height: 1.08,
              fontWeight: FontWeight.w700,
              letterSpacing: -1,
            ),
          ),
          if (product.brand.isNotEmpty || product.sku.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                if (product.brand.isNotEmpty)
                  Text.rich(
                    TextSpan(
                      text: 'Brand: ',
                      children: [
                        TextSpan(
                          text: product.brand,
                          style: const TextStyle(
                            color: Color(0xFF5C544C),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    style: const TextStyle(
                      color: Color(0xFF8D857C),
                      fontSize: 8.5,
                    ),
                  ),
                if (product.sku.isNotEmpty)
                  Text.rich(
                    TextSpan(
                      text: 'SKU: ',
                      children: [
                        TextSpan(
                          text: product.sku,
                          style: const TextStyle(
                            color: Color(0xFF5C544C),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    style: const TextStyle(
                      color: Color(0xFF8D857C),
                      fontSize: 8.5,
                    ),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: const BoxDecoration(
              border: Border.symmetric(
                horizontal: BorderSide(
                  color: Color(0xFFEEE8DF),
                ),
              ),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 5,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  product.ratingCount > 0
                      ? '★ ${product.rating.toStringAsFixed(1)}'
                      : '★ No rating',
                  style: const TextStyle(
                    color: Color(0xFFD89B11),
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Text(
                  '|',
                  style: TextStyle(
                    color: Color(0xFFCDC6BD),
                    fontSize: 9,
                  ),
                ),
                Text(
                  '${product.ratingCount} review${product.ratingCount == 1 ? '' : 's'}',
                  style: const TextStyle(
                    color: Color(0xFF81786F),
                    fontSize: 9,
                  ),
                ),
                const Text(
                  '|',
                  style: TextStyle(
                    color: Color(0xFFCDC6BD),
                    fontSize: 9,
                  ),
                ),
                Text(
                  '${product.sold} sold',
                  style: const TextStyle(
                    color: Color(0xFF81786F),
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFAF0),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: const Color(0xFFEFE2C4),
              ),
            ),
            child: Wrap(
              spacing: 9,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.end,
              children: [
                Text(
                  _peso(_activePrice),
                  style: const TextStyle(
                    color: Color(0xFFC7840C),
                    fontSize: 29,
                    height: 1,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -1.2,
                  ),
                ),
                if (oldPrice != null && oldPrice > _activePrice)
                  Text(
                    _peso(oldPrice),
                    style: const TextStyle(
                      color: Color(0xFFAAA198),
                      fontSize: 10,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                if (product.discountPercent > 0)
                  _pill(
                    text: 'Save ${product.discountPercent}%',
                    background: const Color(0xFFFFF4D7),
                    foreground: const Color(0xFF9D650B),
                    border: const Color(0xFFEAD09A),
                  ),
              ],
            ),
          ),
          if ((product.description ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 13),
            Text(
              _shortDescription(product.description!),
              style: const TextStyle(
                color: Color(0xFF756D64),
                fontSize: 9,
                height: 1.55,
              ),
            ),
          ],
          if (product.variants.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(color: Color(0xFFEEE8DF)),
            const SizedBox(height: 11),
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Choose an option',
                        style: TextStyle(
                          color: Color(0xFF49413A),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Select your preferred variant.',
                        style: TextStyle(
                          color: Color(0xFF91887D),
                          fontSize: 8,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  _selectedVariant?.label ?? 'Not selected',
                  style: const TextStyle(
                    color: Color(0xFF9A6817),
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: product.variants.map((variant) {
                final selected = _selectedVariant?.id == variant.id;
                final enabled = variant.available && variant.stock > 0;

                return ChoiceChip(
                  selected: selected,
                  onSelected: enabled
                      ? (_) => _selectVariant(variant)
                      : null,
                  selectedColor: const Color(0xFFFFF8E9),
                  backgroundColor: Colors.white,
                  disabledColor: const Color(0xFFF7F5F2),
                  side: BorderSide(
                    color: selected
                        ? _gold
                        : const Color(0xFFDDD6CC),
                  ),
                  label: Text(
                    enabled
                        ? variant.label
                        : '${variant.label} · Out',
                  ),
                  labelStyle: TextStyle(
                    color: enabled
                        ? selected
                            ? const Color(0xFF8E5F11)
                            : const Color(0xFF655D54)
                        : const Color(0xFFAA7A7A),
                    fontSize: 8.5,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }).toList(),
            ),
          ] else if (product.optionGroups.isNotEmpty) ...[
            const SizedBox(height: 15),
            const Divider(color: Color(0xFFEEE8DF)),
            const SizedBox(height: 9),
            ...product.optionGroups.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 11),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key,
                      style: const TextStyle(
                        color: Color(0xFF5E554C),
                        fontSize: 8.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: entry.value
                          .map((value) => _badge(value))
                          .toList(),
                    ),
                  ],
                ),
              );
            }),
          ] else if (product.variations.isNotEmpty) ...[
            const SizedBox(height: 15),
            const Divider(color: Color(0xFFEEE8DF)),
            const SizedBox(height: 9),
            const Text(
              'Available options',
              style: TextStyle(
                color: Color(0xFF5E554C),
                fontSize: 8.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 7),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children:
                  product.variations.map((value) => _badge(value)).toList(),
            ),
          ],
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: const Color(0xFFFCFBF8),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFE5DCCF),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Availability',
                        style: TextStyle(
                          color: Color(0xFF776E64),
                          fontSize: 8.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        stock > 0 ? '$stock in stock' : 'Out of stock',
                        style: TextStyle(
                          color: stock > 0
                              ? const Color(0xFF4F8065)
                              : const Color(0xFFB65E5E),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quantity',
                      style: TextStyle(
                        color: Color(0xFF6A6259),
                        fontSize: 8.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    _quantityControl(),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: stock > 0 ? _addToCart : null,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(46),
                    foregroundColor: const Color(0xFFA46B0C),
                    side: const BorderSide(color: _gold),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                  icon: const Icon(
                    Icons.add_shopping_cart_outlined,
                    size: 17,
                  ),
                  label: Text(
                    stock > 0 ? 'Add to Cart' : 'Out of Stock',
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: stock > 0 ? _buyNow : null,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(46),
                    backgroundColor: _gold,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                  icon: const Icon(Icons.bolt, size: 16),
                  label: const Text(
                    'Buy Now',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: _openCart,
              child: const Text(
                'View Cart',
                style: TextStyle(
                  color: Color(0xFF8C7F70),
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: _trustItem(
                  Icons.verified_user_outlined,
                  'Secure Checkout',
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _trustItem(
                  Icons.local_shipping_outlined,
                  product.freeShipping
                      ? 'Free Shipping'
                      : 'Standard Shipping',
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _trustItem(
                  Icons.storefront_outlined,
                  'Approved Seller',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _sellerCard(),
        ],
      ),
    );
  }

  Widget _sellerCard() {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE7DED2),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0B493825),
            blurRadius: 12,
            offset: Offset(5, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFEAD9B8),
                  ),
                ),
                child: const Icon(
                  Icons.storefront_outlined,
                  color: Color(0xFFB97913),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SOLD BY',
                      style: TextStyle(
                        color: Color(0xFFAA781D),
                        fontSize: 7,
                        fontWeight: FontWeight.w700,
                        letterSpacing: .7,
                      ),
                    ),
                    Text(
                      product.shopName,
                      style: const TextStyle(
                        color: Color(0xFF403930),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Text(
                      'Approved SARI marketplace seller',
                      style: TextStyle(
                        color: Color(0xFF91887D),
                        fontSize: 7.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (product.shopSlug.isNotEmpty ||
              product.sellerAccountId > 0) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                if (product.shopSlug.isNotEmpty)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: widget.onVisitShop ??
                          () => _toast(
                                'Shop page will be connected later.',
                              ),
                      child: const Text(
                        'Visit Shop',
                        style: TextStyle(fontSize: 8),
                      ),
                    ),
                  ),
                if (product.shopSlug.isNotEmpty &&
                    product.sellerAccountId > 0)
                  const SizedBox(width: 7),
                if (product.sellerAccountId > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: widget.onMessageSeller ??
                          () => _toast(
                                'Messages page will be connected later.',
                              ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFFAF1),
                        foregroundColor: const Color(0xFF956415),
                        side: const BorderSide(
                          color: Color(0xFFD7B876),
                        ),
                      ),
                      child: const Text(
                        'Message Seller',
                        style: TextStyle(fontSize: 8),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _descriptionCard() {
    final description = (product.description ?? '').trim();

    return _sectionCard(
      kicker: 'Product information',
      heading: 'Description',
      child: Text(
        description.isEmpty
            ? 'The seller did not provide a description for this product.'
            : description,
        style: TextStyle(
          color: description.isEmpty
              ? const Color(0xFF9A9187)
              : const Color(0xFF6F665D),
          fontSize: 9,
          height: 1.7,
        ),
      ),
    );
  }

  Widget _detailsCard() {
    final rows = <Widget>[
      _detailRow('Category', product.category),
      if (product.brand.isNotEmpty)
        _detailRow('Brand', product.brand),
      if (product.condition.isNotEmpty)
        _detailRow(
          'Condition',
          _titleCase(product.condition.replaceAll('_', ' ')),
        ),
      if (product.preparationDays != null)
        _detailRow(
          'Preparation',
          '${product.preparationDays} day${product.preparationDays == 1 ? '' : 's'}',
        ),
      if ((product.packageInfo?.formatted ?? '').isNotEmpty)
        _detailRow(
          'Package',
          product.packageInfo!.formatted,
        ),
      _detailRow(
        'Shipping',
        product.freeShipping
            ? 'Free Shipping'
            : 'Standard Shipping',
        valueColor:
            product.freeShipping ? const Color(0xFF4F8065) : null,
      ),
    ];

    return _sectionCard(
      kicker: 'Listing details',
      heading: 'Product details',
      child: Column(children: rows),
    );
  }

  Widget _reviewsCard() {
    return _sectionCard(
      kicker: 'Buyer feedback',
      heading: 'Ratings & reviews',
      trailing: Text(
        product.ratingCount > 0
            ? '★ ${product.rating.toStringAsFixed(1)} · ${product.ratingCount} review${product.ratingCount == 1 ? '' : 's'}'
            : '★ — · 0 reviews',
        style: const TextStyle(
          color: Color(0xFF81786F),
          fontSize: 8,
        ),
      ),
      child: product.reviews.isEmpty
          ? Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 25,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFCFBF8),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFDDD6CD),
                  style: BorderStyle.solid,
                ),
              ),
              child: const Column(
                children: [
                  Text(
                    'No reviews yet',
                    style: TextStyle(
                      color: Color(0xFF655D54),
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Buyer reviews will appear here after completed orders.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF9A9187),
                      fontSize: 8,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: product.reviews.map((review) {
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFEBE5DD),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: List.generate(
                                5,
                                (index) => Text(
                                  '★',
                                  style: TextStyle(
                                    color: index < review.rating
                                        ? const Color(0xFFE0A00E)
                                        : const Color(0xFFE0A00E)
                                            .withOpacity(.25),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Text(
                            review.createdAt,
                            style: const TextStyle(
                              color: Color(0xFFAAA198),
                              fontSize: 7,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        review.comment.trim().isEmpty
                            ? 'Rating submitted without a written comment.'
                            : review.comment,
                        style: const TextStyle(
                          color: Color(0xFF6F665D),
                          fontSize: 9,
                          height: 1.55,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }

  Widget _relatedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'DISCOVER MORE',
          style: TextStyle(
            color: Color(0xFFAE7A20),
            fontSize: 7,
            fontWeight: FontWeight.w700,
            letterSpacing: .8,
          ),
        ),
        const SizedBox(height: 3),
        Row(
          children: [
            const Expanded(
              child: Text(
                'You may also like',
                style: TextStyle(
                  color: Color(0xFF302A24),
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'View all products',
                style: TextStyle(
                  color: Color(0xFF966719),
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ..._related.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: InkWell(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BuyerProductDetails(
                      product: item,
                      relatedProducts: widget.relatedProducts,
                      initialCartCount: _cartCount,
                      onCartCountChanged: widget.onCartCountChanged,
                      onViewCart: widget.onViewCart,
                      onVisitShop: widget.onVisitShop,
                      onMessageSeller: widget.onMessageSeller,
                    ),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                height: 104,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFE7DED2),
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: Row(
                  children: [
                    SizedBox(
                      width: 104,
                      height: 104,
                      child: item.image == null ||
                              item.image!.trim().isEmpty
                          ? const _ImagePlaceholder(
                              text: '',
                              large: false,
                            )
                          : _buildImage(
                              item.image!,
                              fit: BoxFit.cover,
                            ),
                    ),
                    const VerticalDivider(
                      width: 1,
                      color: Color(0xFFEEE8DF),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF332E29),
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              item.category,
                              style: const TextStyle(
                                color: Color(0xFF968D83),
                                fontSize: 7.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              crossAxisAlignment:
                                  WrapCrossAlignment.end,
                              children: [
                                Text(
                                  _peso(item.price),
                                  style: const TextStyle(
                                    color: Color(0xFFCF8B10),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                if ((item.oldPrice ?? 0) > item.price)
                                  Text(
                                    _peso(item.oldPrice!),
                                    style: const TextStyle(
                                      color: Color(0xFFAAA198),
                                      fontSize: 7,
                                      decoration:
                                          TextDecoration.lineThrough,
                                    ),
                                  ),
                              ],
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
        }),
      ],
    );
  }

  Widget _sectionCard({
    required String kicker,
    required String heading,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE7DED2),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D493825),
            blurRadius: 17,
            offset: Offset(7, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      kicker.toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFFAE7A20),
                        fontSize: 7.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: .7,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      heading,
                      style: const TextStyle(
                        color: Color(0xFF302A24),
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 12),
          const Divider(
            height: 1,
            color: Color(0xFFF0EBE5),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _detailRow(
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFF0EBE5),
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF91887D),
                fontSize: 8,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: valueColor ?? const Color(0xFF51483F),
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _trustItem(IconData icon, String text) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFCFBF8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFEBE3D9),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 15,
            color: const Color(0xFFB9780B),
          ),
          const SizedBox(height: 4),
          Text(
            text,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF746B61),
              fontSize: 6.8,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _quantityControl() {
    final stock = _activeStock;

    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFDED4C7),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _qtyButton(
            Icons.remove,
            _quantity > 1
                ? () {
                    setState(() {
                      _quantity--;
                    });
                  }
                : null,
          ),
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              border: Border.symmetric(
                vertical: BorderSide(
                  color: Color(0xFFE6E0D9),
                ),
              ),
            ),
            child: Text(
              '$_quantity',
              style: const TextStyle(
                color: Color(0xFF403930),
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          _qtyButton(
            Icons.add,
            stock > 0 && _quantity < stock
                ? () {
                    setState(() {
                      _quantity++;
                    });
                  }
                : null,
          ),
        ],
      ),
    );
  }

  Widget _qtyButton(IconData icon, VoidCallback? onPressed) {
    return SizedBox(
      width: 36,
      height: 38,
      child: IconButton(
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        icon: Icon(icon, size: 14),
        color: const Color(0xFF766D63),
      ),
    );
  }

  Widget _badge(String text, {bool gold = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color:
            gold ? const Color(0xFFFFF8E9) : const Color(0xFFFAF8F5),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color:
              gold ? const Color(0xFFE7D3AA) : const Color(0xFFE2DDD6),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color:
              gold ? const Color(0xFF956313) : const Color(0xFF716960),
          fontSize: 8,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _pill({
    IconData? icon,
    required String text,
    required Color background,
    required Color foreground,
    required Color border,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: foreground,
              size: 13,
            ),
            const SizedBox(width: 5),
          ],
          Text(
            text,
            style: TextStyle(
              color: foreground,
              fontSize: 8,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(
    String source, {
    required BoxFit fit,
  }) {
    final isNetwork = source.startsWith('http://') ||
        source.startsWith('https://') ||
        source.startsWith('//');

    if (isNetwork) {
      return Image.network(
        source.startsWith('//') ? 'https:$source' : source,
        fit: fit,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) => const _ImagePlaceholder(
          text: 'Image unavailable',
          large: false,
        ),
      );
    }

    return Image.asset(
      source,
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, __, ___) => const _ImagePlaceholder(
        text: 'Image unavailable',
        large: false,
      ),
    );
  }

  void _selectVariant(BuyerProductVariant variant) {
    setState(() {
      _selectedVariant = variant;
      _quantity = 1;

      final image = variant.image?.trim() ?? '';
      if (image.isNotEmpty) {
        _selectedImageIndex = 0;
      }
    });
  }

  void _addToCart() {
    if (!_canContinue()) return;

    setState(() {
      _cartCount += _quantity;
    });

    widget.onCartCountChanged?.call(_cartCount);

    _toast(
      '$_quantity × ${product.name} added to cart'
      '${_selectedVariant == null ? '' : ' • ${_selectedVariant!.label}'}',
    );
  }

  void _buyNow() {
    if (!_canContinue()) return;

    final item = BuyerCartItem(
      id: product.id,
      productId: product.id,
      sellerId: product.sellerAccountId,
      storeName: product.shopName,
      productName: product.name,
      variantLabel: _selectedVariant?.label ?? '',
      image: _selectedVariant?.image ?? product.image,
      unitPrice: _activePrice,
      quantity: _quantity,
      maxStock: _activeStock,
      freeShipping: product.freeShipping,
    );

    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => BuyerCheckout(
          items: [item],
        ),
      ),
    );
  }

  bool _canContinue() {
    if (_needsVariant && _selectedVariant == null) {
      _notice(
        'Choose a product variant before continuing.',
        danger: true,
      );
      return false;
    }

    if (_activeStock <= 0) {
      _notice(
        'This product option is currently out of stock.',
        danger: true,
      );
      return false;
    }

    return true;
  }

  void _openCart() {
    if (widget.onViewCart != null) {
      widget.onViewCart!();
      return;
    }

    _toast('Cart page will be connected next.');
  }

  void _notice(String message, {bool danger = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: danger
            ? const Color(0xFFA55B5B)
            : const Color(0xFF4F7D61),
        content: Text(message),
      ),
    );
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _openImagePreview() async {
    final gallery = _gallery;
    if (gallery.isEmpty) return;

    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withOpacity(.78),
      builder: (dialogContext) {
        return Dialog.fullscreen(
          backgroundColor: Colors.black.withOpacity(.86),
          child: SafeArea(
            child: Stack(
              children: [
                Center(
                  child: InteractiveViewer(
                    minScale: .8,
                    maxScale: 4,
                    child: _buildImage(
                      gallery[
                          _selectedImageIndex.clamp(0, gallery.length - 1).toInt()],
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: IconButton.filled(
                    onPressed: () => Navigator.pop(dialogContext),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black54,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.close),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _peso(double value) {
    return '₱${value.toStringAsFixed(2)}';
  }

  String _shortDescription(String value) {
    final cleaned = value.trim();
    if (cleaned.length <= 150) return cleaned;
    return '${cleaned.substring(0, 147)}...';
  }

  String _titleCase(String value) {
    return value
        .split(' ')
        .where((word) => word.isNotEmpty)
        .map(
          (word) =>
              '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
        )
        .join(' ');
  }
}

class _ImagePlaceholder extends StatelessWidget {
  final String text;
  final bool large;

  const _ImagePlaceholder({
    required this.text,
    required this.large,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF7F4EF),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.image_outlined,
            color: const Color(0xFFAAA198),
            size: large ? 42 : 26,
          ),
          if (text.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              text,
              style: const TextStyle(
                color: Color(0xFFAAA198),
                fontSize: 9,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
