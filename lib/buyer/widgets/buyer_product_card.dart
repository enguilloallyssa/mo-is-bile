import 'package:flutter/material.dart';

import '../models/buyer_product_model.dart';

class BuyerProductCard
    extends StatelessWidget {
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

  static const Color gold =
      Color(0xFFCC8A0B);
  static const Color goldDark =
      Color(0xFFA96D07);
  static const Color dark =
      Color(0xFF24201C);
  static const Color muted =
      Color(0xFF7F776E);
  static const Color border =
      Color(0xFFE9E3DB);

  @override
  Widget build(
    BuildContext context,
  ) {
    return Material(
      color: Colors.white,
      borderRadius:
          BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(
              14,
            ),
            border:
                Border.all(
              color: border,
            ),
          ),
          clipBehavior:
              Clip.antiAlias,
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              _image(),
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.all(
                    11,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Text(
                        product.category
                            .toUpperCase(),
                        maxLines: 1,
                        overflow:
                            TextOverflow
                                .ellipsis,
                        style:
                            const TextStyle(
                          color: goldDark,
                          fontSize: 8,
                          fontWeight:
                              FontWeight
                                  .w800,
                          letterSpacing:
                              .6,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow:
                            TextOverflow
                                .ellipsis,
                        style:
                            const TextStyle(
                          color: dark,
                          fontSize: 11.5,
                          height: 1.2,
                          fontWeight:
                              FontWeight
                                  .w700,
                        ),
                      ),
                      if (product.brand
                          .trim()
                          .isNotEmpty) ...[
                        const SizedBox(
                          height: 4,
                        ),
                        Text(
                          product.brand,
                          maxLines: 1,
                          overflow:
                              TextOverflow
                                  .ellipsis,
                          style:
                              const TextStyle(
                            color: muted,
                            fontSize:
                                8.5,
                          ),
                        ),
                      ],
                      const Spacer(),
                      Row(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .end,
                        children: [
                          Expanded(
                            child: Text(
                              _peso(
                                product
                                    .price,
                              ),
                              style:
                                  const TextStyle(
                                color:
                                    goldDark,
                                fontSize:
                                    16,
                                fontWeight:
                                    FontWeight
                                        .w900,
                              ),
                            ),
                          ),
                          if (showStock)
                            Text(
                              product.stock >
                                      0
                                  ? '${product.stock} left'
                                  : 'Out',
                              style:
                                  TextStyle(
                                color: product
                                            .stock >
                                        0
                                    ? muted
                                    : Colors
                                        .redAccent,
                                fontSize:
                                    8,
                                fontWeight:
                                    FontWeight
                                        .w600,
                              ),
                            ),
                        ],
                      ),
                      if (showQuickAdd &&
                          product.stock >
                              0 &&
                          (onAddToCart !=
                                  null ||
                              onBuyNow !=
                                  null)) ...[
                        const SizedBox(
                          height: 9,
                        ),
                        Row(
                          children: [
                            if (onAddToCart !=
                                null)
                              Expanded(
                                child:
                                    OutlinedButton(
                                  onPressed:
                                      onAddToCart,
                                  style:
                                      OutlinedButton
                                          .styleFrom(
                                    padding:
                                        const EdgeInsets.symmetric(
                                      vertical:
                                          8,
                                    ),
                                  ),
                                  child:
                                      const Icon(
                                    Icons
                                        .add_shopping_cart_outlined,
                                    size:
                                        16,
                                  ),
                                ),
                              ),
                            if (onAddToCart !=
                                    null &&
                                onBuyNow !=
                                    null)
                              const SizedBox(
                                width: 6,
                              ),
                            if (onBuyNow !=
                                null)
                              Expanded(
                                child:
                                    ElevatedButton(
                                  onPressed:
                                      onBuyNow,
                                  style:
                                      ElevatedButton
                                          .styleFrom(
                                    backgroundColor:
                                        gold,
                                    foregroundColor:
                                        Colors.white,
                                    padding:
                                        const EdgeInsets.symmetric(
                                      vertical:
                                          8,
                                    ),
                                  ),
                                  child:
                                      const Text(
                                    'Buy',
                                    style:
                                        TextStyle(
                                      fontSize:
                                          9,
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _image() {
    final image =
        product.image?.trim() ?? '';

    final height =
        featured ? 180.0 : 150.0;

    if (image.isEmpty) {
      return SizedBox(
        width: double.infinity,
        height: height,
        child:
            const ColoredBox(
          color:
              Color(0xFFF4F4F4),
          child: Center(
            child: Icon(
              Icons
                  .inventory_2_outlined,
              color:
                  Color(0xFFAAAEB5),
              size: 42,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: height,
      child: Image.network(
        image,
        fit: BoxFit.cover,
        loadingBuilder:
            (
          context,
          child,
          progress,
        ) {
          if (progress == null) {
            return child;
          }

          return const Center(
            child:
                CircularProgressIndicator(
              color: gold,
              strokeWidth: 2,
            ),
          );
        },
        errorBuilder:
            (
          context,
          error,
          stackTrace,
        ) {
          return const ColoredBox(
            color:
                Color(0xFFF4F4F4),
            child: Center(
              child: Icon(
                Icons
                    .inventory_2_outlined,
                color:
                    Color(0xFFAAAEB5),
                size: 42,
              ),
            ),
          );
        },
      ),
    );
  }

  String _peso(
    double value,
  ) {
    return '₱${value.toStringAsFixed(2)}';
  }
}