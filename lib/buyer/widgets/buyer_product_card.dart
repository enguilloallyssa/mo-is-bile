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

  static const Color gold =
      Color(0xFFD89108);

  static const Color goldDark =
      Color(0xFFB87300);

  static const Color dark =
      Color(0xFF17191D);

  static const Color muted =
      Color(0xFF88827B);

  static const Color border =
      Color(0xFFE5E2DE);

  String _peso(
    double value,
  ) {
    return '₱${value.toStringAsFixed(2)}';
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return LayoutBuilder(
      builder:
          (
            BuildContext context,
            BoxConstraints constraints,
          ) {
        final bool narrow =
            constraints.maxWidth <
                155;

        return Material(
          color:
              Colors.white,
          borderRadius:
              BorderRadius.circular(
            14,
          ),
          clipBehavior:
              Clip.antiAlias,
          child: InkWell(
            onTap:
                onTap,
            child: Container(
              decoration:
                  BoxDecoration(
                color:
                    Colors.white,
                borderRadius:
                    BorderRadius.circular(
                  14,
                ),
                border:
                    Border.all(
                  color:
                      border,
                ),
                boxShadow:
                    const <BoxShadow>[
                  BoxShadow(
                    color:
                        Color(
                      0x0E000000,
                    ),
                    blurRadius: 13,
                    offset:
                        Offset(
                      0,
                      5,
                    ),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: <Widget>[
                  _imageSection(
                    narrow,
                  ),

                  Expanded(
                    child: Padding(
                      padding:
                          EdgeInsets.fromLTRB(
                        narrow
                            ? 8
                            : 10,
                        9,
                        narrow
                            ? 8
                            : 10,
                        9,
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            product.name,
                            maxLines: 2,
                            overflow:
                                TextOverflow.ellipsis,
                            style:
                                TextStyle(
                              color:
                                  dark,
                              fontSize:
                                  narrow
                                      ? 9.2
                                      : 10.2,
                              height:
                                  1.15,
                              fontWeight:
                                  FontWeight.w800,
                            ),
                          ),

                          const SizedBox(
                            height: 5,
                          ),

                          Text(
                            <String>[
                              product.category,
                              if (product.brand
                                  .trim()
                                  .isNotEmpty)
                                product.brand,
                            ].join(
                              ' · ',
                            ),
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis,
                            style:
                                TextStyle(
                              color:
                                  muted,
                              fontSize:
                                  narrow
                                      ? 7
                                      : 7.5,
                            ),
                          ),

                          const SizedBox(
                            height: 7,
                          ),

                          _price(
                            narrow,
                          ),

                          const Spacer(),

                          if (showStock)
                            _stock(),

                          if (showQuickAdd &&
                              product.stock >
                                  0 &&
                              (onAddToCart !=
                                      null ||
                                  onBuyNow !=
                                      null)) ...[
                            const SizedBox(
                              height: 7,
                            ),

                            _actions(
                              narrow,
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
      },
    );
  }

  Widget _imageSection(
    bool narrow,
  ) {
    final String image =
        product.image?.trim() ??
            '';

    final double height =
        featured
            ? 165
            : narrow
                ? 130
                : 143;

    return SizedBox(
      width:
          double.infinity,
      height:
          height,
      child: Stack(
        fit:
            StackFit.expand,
        children: <Widget>[
          ColoredBox(
            color:
                const Color(
              0xFFF4F3F1,
            ),
            child:
                image.isEmpty
                    ? const Center(
                        child: Icon(
                          Icons
                              .inventory_2_outlined,
                          color:
                              Color(
                            0xFFA9A49E,
                          ),
                          size: 34,
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
                                Color(
                              0xFFA9A49E,
                            ),
                            size: 34,
                          ),
                        ),
                      ),
          ),

          if (showPromotions)
            Positioned(
              left: 7,
              top: 7,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 7,
                  vertical: 4,
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
                  boxShadow:
                      const <BoxShadow>[
                    BoxShadow(
                      color:
                          Color(
                        0x22000000,
                      ),
                      blurRadius: 5,
                    ),
                  ],
                ),
                child:
                    const Text(
                  'SARI',
                  style:
                      TextStyle(
                    color:
                        Color(
                      0xFFFFC53B,
                    ),
                    fontSize: 6.5,
                    fontWeight:
                        FontWeight.w900,
                    letterSpacing: .5,
                  ),
                ),
              ),
            ),

          if (showPromotions &&
              product.discountPercent >
                  0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 6,
                ),
                decoration:
                    const BoxDecoration(
                  color:
                      Color(
                    0xFFE2A100,
                  ),
                  borderRadius:
                      BorderRadius.only(
                    bottomLeft:
                        Radius.circular(
                      12,
                    ),
                  ),
                ),
                child: Text(
                  '-${product.discountPercent}%',
                  style:
                      const TextStyle(
                    color:
                        Colors.white,
                    fontSize: 7,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
              ),
            ),

          if (showPromotions)
            Positioned(
              left: 0,
              bottom: 0,
              child: Container(
                constraints:
                    BoxConstraints(
                  maxWidth:
                      narrow
                          ? 91
                          : 108,
                ),
                padding:
                    const EdgeInsets.fromLTRB(
                  8,
                  4,
                  14,
                  4,
                ),
                decoration:
                    const BoxDecoration(
                  color:
                      Color(
                    0xFFF2B91B,
                  ),
                  borderRadius:
                      BorderRadius.only(
                    topRight:
                        Radius.circular(
                      10,
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
                        fontSize: 6,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),
                    Text(
                      'Cash on Delivery',
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style:
                          TextStyle(
                        color:
                            Color(
                          0xFF332600,
                        ),
                        fontSize: 5.8,
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
    );
  }

  Widget _price(
    bool narrow,
  ) {
    return Wrap(
      crossAxisAlignment:
          WrapCrossAlignment.center,
      spacing: 5,
      runSpacing: 2,
      children: <Widget>[
        Text(
          _peso(
            product.price,
          ),
          maxLines: 1,
          style:
              TextStyle(
            color:
                goldDark,
            fontSize:
                narrow
                    ? 12
                    : 13.5,
            fontWeight:
                FontWeight.w900,
            fontFamilyFallback:
                const <String>[
              'Roboto',
              'Arial',
              'sans-serif',
            ],
          ),
        ),

        if (product.oldPrice !=
                null &&
            product.oldPrice! >
                product.price)
          Text(
            _peso(
              product.oldPrice!,
            ),
            style:
                TextStyle(
              color:
                  muted,
              fontSize:
                  narrow
                      ? 6.5
                      : 7,
              decoration:
                  TextDecoration
                      .lineThrough,
              fontFamilyFallback:
                  const <String>[
                'Roboto',
                'Arial',
              ],
            ),
          ),
      ],
    );
  }

  Widget _stock() {
    final bool available =
        product.stock > 0;

    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            available
                ? '${product.stock} in stock'
                : 'Out of stock',
            maxLines: 1,
            overflow:
                TextOverflow.ellipsis,
            style:
                TextStyle(
              color:
                  available
                      ? const Color(
                          0xFF288255,
                        )
                      : Colors.redAccent,
              fontSize: 7.3,
              fontWeight:
                  FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _actions(
    bool narrow,
  ) {
    return SizedBox(
      height: 34,
      child: Row(
        children: <Widget>[
          if (onAddToCart != null)
            SizedBox(
              width:
                  narrow ? 34 : 37,
              height: 34,
              child:
                  OutlinedButton(
                onPressed:
                    onAddToCart,
                style:
                    OutlinedButton
                        .styleFrom(
                  padding:
                      EdgeInsets.zero,
                  foregroundColor:
                      goldDark,
                  side:
                      const BorderSide(
                    color:
                        Color(
                      0xFFE4DDD4,
                    ),
                  ),
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      9,
                    ),
                  ),
                ),
                child:
                    const Icon(
                  Icons
                      .shopping_cart_outlined,
                  size: 15,
                ),
              ),
            ),

          if (onAddToCart != null &&
              onBuyNow != null)
            const SizedBox(
              width: 6,
            ),

          if (onBuyNow != null)
            Expanded(
              child:
                  FilledButton(
                onPressed:
                    onBuyNow,
                style:
                    FilledButton
                        .styleFrom(
                  backgroundColor:
                      gold,
                  foregroundColor:
                      Colors.white,
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 5,
                  ),
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      9,
                    ),
                  ),
                ),
                child:
                    Text(
                  narrow
                      ? 'Buy'
                      : 'Buy Now',
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      const TextStyle(
                    fontSize: 7.5,
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
}