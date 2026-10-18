import 'package:flutter/material.dart';

import '../models/buyer_product_model.dart';

class BuyerProductCard extends StatelessWidget {
  final BuyerProduct product;
  final bool featured;
  final bool showPromotions;
  final bool showStock;
  final bool showQuickAdd;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  final VoidCallback? onBuyNow;

  const BuyerProductCard({
    super.key,
    required this.product,
    this.featured = false,
    this.showPromotions = true,
    this.showStock = true,
    this.showQuickAdd = true,
    this.onTap,
    this.onAddToCart,
    this.onBuyNow,
  });

  static const Color _brand = Color(0xFFD98D08);
  static const Color _text = Color(0xFF211D17);
  static const Color _muted = Color(0xFF887E72);
  static const Color _border = Color(0xFFE9E1D6);

  @override
  Widget build(BuildContext context) {
    return featured ? _featuredCard(context) : _compactCard(context);
  }

  Widget _compactCard(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 190;
        final imageHeight = compact ? 126.0 : 142.0;

        return Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _border),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0C4A3517),
                    blurRadius: 16,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      _productImage(height: imageHeight),
                      Positioned(
                        left: 8,
                        top: 8,
                        child: _miniBadge(
                          product.brand.trim().isEmpty
                              ? 'SARI PICK'
                              : product.brand,
                          background: Colors.white.withValues(alpha: .94),
                          foreground: const Color(0xFF6F5A36),
                          border: const Color(0xFFE6D9C1),
                        ),
                      ),
                      if (product.discountPercent > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE59714),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x22000000),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Text(
                              '-${product.discountPercent}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        )
                      else if (product.isNew)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: _miniBadge(
                            'NEW',
                            background: const Color(0xFF4F7D63),
                            foreground: Colors.white,
                          ),
                        ),
                      if (product.stock <= 0)
                        Positioned.fill(
                          child: Container(
                            color: Colors.white.withValues(alpha: .72),
                            alignment: Alignment.center,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2D2924),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'SOLD OUT',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        compact ? 9 : 11,
                        9,
                        compact ? 9 : 11,
                        9,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.category.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFFA06C16),
                              fontSize: 7,
                              fontWeight: FontWeight.w800,
                              letterSpacing: .65,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            product.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: _text,
                              fontSize: compact ? 10.5 : 11.5,
                              height: 1.18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 7),
                          _priceLine(compact: compact),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              if (product.rating > 0) ...[
                                const Icon(
                                  Icons.star_rounded,
                                  color: Color(0xFFF2A10A),
                                  size: 13,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  product.rating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    color: Color(0xFF665D53),
                                    fontSize: 7.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                              if (product.rating > 0 && product.sold > 0)
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 5),
                                  child: Text(
                                    '•',
                                    style: TextStyle(
                                      color: Color(0xFFC3BBB1),
                                      fontSize: 8,
                                    ),
                                  ),
                                ),
                              if (product.sold > 0)
                                Expanded(
                                  child: Text(
                                    '${product.sold} sold',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: _muted,
                                      fontSize: 7.5,
                                    ),
                                  ),
                                )
                              else
                                const Spacer(),
                            ],
                          ),
                          const SizedBox(height: 6),
                          _promoRow(compact: compact),
                          const Spacer(),
                          if (showQuickAdd) _quickActions(compact: compact),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _featuredCard(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _border),
            boxShadow: const [
              BoxShadow(
                color: Color(0x104A3517),
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            height: 190,
            child: LayoutBuilder(
              builder: (context, constraints) {
              final narrow = constraints.maxWidth < 360;
              final imageWidth = narrow ? 132.0 : 155.0;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: imageWidth,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        _productImage(height: 188),
                        if (product.discountPercent > 0)
                          Positioned(
                            top: 10,
                            left: 10,
                            child: _miniBadge(
                              '${product.discountPercent}% OFF',
                              background: const Color(0xFFE59714),
                              foreground: Colors.white,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _miniBadge(
                            'FEATURED PICK',
                            background: const Color(0xFFFFF1D5),
                            foreground: const Color(0xFFAA6A05),
                            border: const Color(0xFFEBCB8E),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            product.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _text,
                              fontSize: 15,
                              height: 1.15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          _priceLine(),
                          const SizedBox(height: 7),
                          Text(
                            '${product.rating > 0 ? '★ ${product.rating.toStringAsFixed(1)}  •  ' : ''}${product.sold} sold',
                            style: const TextStyle(
                              color: _muted,
                              fontSize: 8,
                            ),
                          ),
                          const SizedBox(height: 9),
                          _promoRow(),
                          if (showQuickAdd) ...[
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                SizedBox(
                                  width: 42,
                                  height: 38,
                                  child: OutlinedButton(
                                    onPressed: product.stock > 0
                                        ? onAddToCart
                                        : null,
                                    style: OutlinedButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                    ),
                                    child: const Icon(
                                      Icons.add_shopping_cart_outlined,
                                      size: 17,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 7),
                                Expanded(
                                  child: SizedBox(
                                    height: 38,
                                    child: ElevatedButton(
                                      onPressed: product.stock > 0
                                          ? onBuyNow
                                          : null,
                                      child: const Text('Buy Now'),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _quickActions({required bool compact}) {
    return Row(
      children: [
        SizedBox(
          width: compact ? 34 : 38,
          height: 32,
          child: OutlinedButton(
            onPressed: product.stock > 0 ? onAddToCart : null,
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              side: const BorderSide(color: Color(0xFFE4C47C)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Icon(
              Icons.add_shopping_cart_outlined,
              size: 15,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: SizedBox(
            height: 32,
            child: ElevatedButton(
              onPressed: product.stock > 0 ? onBuyNow : null,
              style: ElevatedButton.styleFrom(
                minimumSize: Size.zero,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                product.stock > 0 ? 'Buy' : 'Sold out',
                style: const TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _priceLine({bool compact = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Flexible(
          child: Text(
            '₱${product.price.toStringAsFixed(2)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: const Color(0xFFD77F00),
              fontSize: compact ? 14 : 17,
              height: 1,
              fontWeight: FontWeight.w900,
              fontFamilyFallback: const <String>[
                'Roboto',
                'Noto Sans',
              ],
            ),
          ),
        ),
        if ((product.oldPrice ?? 0) > product.price) ...[
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              '₱${product.oldPrice!.toStringAsFixed(0)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFFAAA198),
                fontSize: 7,
                decoration: TextDecoration.lineThrough,
                fontFamilyFallback: <String>[
                  'Roboto',
                  'Noto Sans',
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _promoRow({bool compact = false}) {
    final widgets = <Widget>[];

    if (showPromotions && product.freeShipping) {
      widgets.add(
        _miniBadge(
          'FREE SHIPPING',
          background: const Color(0xFFEAF7EF),
          foreground: const Color(0xFF397354),
          border: const Color(0xFFBFE0CA),
        ),
      );
    }

    if (showStock) {
      final stockColor = product.stock <= 0
          ? const Color(0xFFC75353)
          : product.stock <= 5
              ? const Color(0xFFA97120)
              : const Color(0xFF5E7667);
      widgets.add(
        Text(
          product.stock <= 0 ? 'Sold out' : '${product.stock} left',
          style: TextStyle(
            color: stockColor,
            fontSize: compact ? 6.5 : 7.2,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return Wrap(
      spacing: 5,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: widgets,
    );
  }

  Widget _productImage({required double height}) {
    final path = product.image?.trim() ?? '';

    if (path.isEmpty) return _imagePlaceholder(height);

    final isNetwork = path.startsWith('http://') ||
        path.startsWith('https://') ||
        path.startsWith('//');

    return SizedBox(
      width: double.infinity,
      height: height,
      child: isNetwork
          ? Image.network(
              path.startsWith('//') ? 'https:$path' : path,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _imagePlaceholder(height),
            )
          : Image.asset(
              path,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _imagePlaceholder(height),
            ),
    );
  }

  Widget _imagePlaceholder(double height) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF8F3EA),
            Color(0xFFF1EBE1),
          ],
        ),
      ),
      alignment: Alignment.center,
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.image_outlined,
            color: Color(0xFFB2A89A),
            size: 30,
          ),
          SizedBox(height: 4),
          Text(
            'Image unavailable',
            style: TextStyle(
              color: Color(0xFF9B9184),
              fontSize: 7,
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniBadge(
    String text, {
    required Color background,
    required Color foreground,
    Color? border,
  }) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 105),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
        border: border == null ? null : Border.all(color: border),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: foreground,
          fontSize: 6.2,
          fontWeight: FontWeight.w800,
          letterSpacing: .15,
        ),
      ),
    );
  }
}
