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

  static const Color gold = Color(0xFFCF8B0E);

  @override
  Widget build(BuildContext context) {
    if (featured) return _featuredCard(context);
    return _compactCard(context);
  }

  Widget _compactCard(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: const Color(0xFFE7E1DA)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  _productImage(height: 178),
                  Positioned(
                    left: 10,
                    top: 10,
                    child: _badge(
                      '★ SARI Mall',
                      background: gold,
                      foreground: Colors.white,
                    ),
                  ),
                  Positioned(
                    right: 10,
                    top: 10,
                    child: _statusBadge(),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.category.toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFF8F857A),
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        letterSpacing: .7,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF29231E),
                        fontSize: 12.5,
                        height: 1.25,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _priceRow(),
                    const SizedBox(height: 10),
                    const Divider(height: 1, color: Color(0xFFEEE8DF)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: _promotionAndStock()),
                        if (product.rating > 0 || product.sold > 0)
                          Text(
                            [
                              if (product.rating > 0)
                                '★ ${product.rating.toStringAsFixed(1)}',
                              if (product.sold > 0) '${product.sold} sold',
                            ].join('  |  '),
                            style: const TextStyle(
                              color: Color(0xFF817970),
                              fontSize: 7.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                    if (showQuickAdd) ...[
                      const SizedBox(height: 11),
                      Row(
                        children: [
                          SizedBox(
                            width: 42,
                            height: 40,
                            child: OutlinedButton(
                              onPressed: product.stock > 0
                                  ? onAddToCart
                                  : null,
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.zero,
                                foregroundColor: const Color(0xFFBC7808),
                                side: BorderSide(
                                  color: product.stock > 0
                                      ? const Color(0xFFDDA62F)
                                      : const Color(0xFFDDD9D3),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Icon(
                                product.stock > 0
                                    ? Icons.add_shopping_cart_outlined
                                    : Icons.remove_shopping_cart_outlined,
                                size: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: SizedBox(
                              height: 40,
                              child: ElevatedButton(
                                onPressed:
                                    product.stock > 0 ? onBuyNow : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFD68F08),
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor:
                                      const Color(0xFFD3D0CB),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  product.stock > 0
                                      ? 'Buy Now'
                                      : 'Out of Stock',
                                  style: const TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _featuredCard(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: const Color(0xFFE7E1DA)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              Stack(
                children: [
                  _productImage(height: 270),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withValues(alpha: .80),
                            Colors.black.withValues(alpha: .30),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 14,
                    top: 14,
                    child: _badge(
                      '★ SARI Mall',
                      background: gold,
                      foreground: Colors.white,
                    ),
                  ),
                  Positioned(
                    right: 14,
                    top: 14,
                    child: _statusBadge(),
                  ),
                  Positioned(
                    left: 18,
                    right: 90,
                    bottom: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.category.toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFFEFC36B),
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          product.name,
                          maxLines: 2,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            height: 1.05,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if ((product.description ?? '').isNotEmpty) ...[
                          const SizedBox(height: 7),
                          Text(
                            product.description!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 8,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    _priceRow(),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: _promotionAndStock()),
                        if (showQuickAdd) ...[
                          const SizedBox(width: 8),
                          SizedBox(
                            height: 40,
                            child: ElevatedButton(
                              onPressed:
                                  product.stock > 0 ? onBuyNow : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFD68F08),
                                foregroundColor: Colors.white,
                                elevation: 0,
                              ),
                              child: const Text(
                                'Buy Now',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _productImage({required double height}) {
    final path = product.image;

    if (path == null || path.isEmpty) {
      return _imagePlaceholder(height);
    }

    return SizedBox(
      width: double.infinity,
      height: height,
      child: Image.asset(
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
      color: const Color(0xFFF6F2EB),
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_outlined,
        color: Color(0xFFAAA197),
        size: 34,
      ),
    );
  }

  Widget _priceRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '₱${product.price.toStringAsFixed(2)}',
          style: const TextStyle(
            color: Color(0xFFC67F08),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        if ((product.oldPrice ?? 0) > product.price) ...[
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Text(
              '₱${product.oldPrice!.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Color(0xFFAAA198),
                fontSize: 8,
                decoration: TextDecoration.lineThrough,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _promotionAndStock() {
    return Wrap(
      spacing: 6,
      runSpacing: 5,
      children: [
        if (showPromotions && product.freeShipping)
          _badge(
            'Free Shipping',
            background: const Color(0xFFEFF9F2),
            foreground: const Color(0xFF347451),
            border: const Color(0xFFBFE0CA),
          ),
        if (showStock)
          Text(
            product.stock > 0
                ? 'Stock: ${product.stock}'
                : 'Out of Stock',
            style: TextStyle(
              color: product.stock <= 0
                  ? const Color(0xFFC75353)
                  : product.stock <= 5
                      ? const Color(0xFFA97120)
                      : const Color(0xFF3F7E5A),
              fontSize: 7,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }

  Widget _statusBadge() {
    if (product.stock <= 0) {
      return _badge(
        'Out of Stock',
        background: Colors.white.withValues(alpha: .95),
        foreground: const Color(0xFFC04747),
        border: const Color(0xFFEFB6B6),
      );
    }

    if (product.discountPercent > 0) {
      return _badge(
        '-${product.discountPercent}%',
        background: const Color(0xFFFFF2D2),
        foreground: const Color(0xFFAB6908),
        border: const Color(0xFFECD69F),
      );
    }

    if (product.isNew) {
      return _badge(
        'New',
        background: const Color(0xFF3F8B68),
        foreground: Colors.white,
      );
    }

    return const SizedBox.shrink();
  }

  Widget _badge(
    String text, {
    required Color background,
    required Color foreground,
    Color? border,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(30),
        border: border == null ? null : Border.all(color: border),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: foreground,
          fontSize: 7,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
