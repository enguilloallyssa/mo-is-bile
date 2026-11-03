import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/sari_live_data.dart';
import 'models/buyer_order_model.dart';

class BuyerOrderDetails
    extends StatefulWidget {
  final BuyerOrder order;

  const BuyerOrderDetails({
    super.key,
    required this.order,
  });

  @override
  State<BuyerOrderDetails>
      createState() =>
          _BuyerOrderDetailsState();
}

class _BuyerOrderDetailsState
    extends State<BuyerOrderDetails> {
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

  static const List<String>
      _cancellationReasons = [
    'Need to change shipping address',
    'Need to change payment method',
    'Need item sooner',
    'Need to change color or size',
    'High delivery costs',
    'Better price available',
    'No longer needed',
    'Seller not responsive to inquiries',
    'Seller requesting order cancellation',
  ];

  BuyerOrder? _order;

  List<Map<String, dynamic>>
      _trackingEvents = [];

  String _courierName = '';

  bool _loading = true;
  bool _actionLoading = false;

  String? _error;

  @override
  void initState() {
    super.initState();

    _order = widget.order;

    _load();
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

  int _integer(
    dynamic value,
  ) {
    if (value is num) {
      return value.toInt();
    }

    return int.tryParse('$value') ?? 0;
  }

  double _decimal(
    dynamic value,
  ) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse('$value') ?? 0;
  }

  BuyerOrder _parseOrder(
    dynamic raw,
  ) {
    final data = _map(raw);

    final rawItems =
        data['items'] is List
            ? data['items'] as List
            : const [];

    final items = rawItems.map(
      (rawItem) {
        final item =
            _map(rawItem);

        return BuyerOrderItem(
          productId: _integer(
            item['product_id'],
          ),
          variantId:
              item['variant_id'] ==
                      null
                  ? null
                  : _integer(
                      item[
                          'variant_id'],
                    ),
          name: _text(
            item['name'],
            'Product',
          ),
          variantLabel: _text(
            item['variant_label'],
            'Standard',
          ),
          quantity: _integer(
            item['qty'] ??
                item['quantity'],
          ),
          lineTotal: _decimal(
            item['line_total'],
          ),
        );
      },
    ).toList();

    return BuyerOrder(
      id: _integer(
        data['id'],
      ),
      orderNumber: _text(
        data['order_number'],
      ),
      status: _text(
        data['status'],
      ),
      apiStatusLabel: _text(
        data['status_label'],
      ),
      paymentMethod: _text(
        data['payment_method'],
        'Not specified',
      ),
      paymentStatus: _text(
        data['payment_status'],
        'pending',
      ),
      subtotal: _decimal(
        data['subtotal'],
      ),
      deliveryFee: _decimal(
        data['delivery_fee'],
      ),
      totalAmount: _decimal(
        data['total'],
      ),
      createdAt: _text(
        data['created_at'],
      ),
      deliveredAt: _text(
        data['delivered_at'],
      ),
      buyerName: _text(
        data['buyer_name'],
        'SARI Buyer',
      ),
      buyerPhone: _text(
        data['buyer_phone'],
      ),
      deliveryAddress: _text(
        data['buyer_address'],
      ),
      sellerName: _text(
        data['store_name'],
        'SARI Seller',
      ),
      sellerAccountId:
          _integer(
        data['seller_id'],
      ),
      items: items,
      productNames: items
          .map(
            (item) => item.name,
          )
          .toList(),
    );
  }

  Future<void> _load()
      async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response =
          await SariLiveData.instance
              .buyerOrderDetails(
        widget.order.id,
      );

      final raw =
          response['data'];

      if (raw is! Map) {
        throw const FormatException(
          'Invalid order details from SARI.',
        );
      }

      final order =
          _parseOrder(raw);

      if (order.id !=
          widget.order.id) {
        throw const FormatException(
          'Invalid order ID returned by SARI.',
        );
      }

      List<Map<String, dynamic>>
          events = [];

      String courier = '';

      try {
        final tracking =
            await SariLiveData.instance
                .buyerTracking(
          order.id,
        );

        final trackingData =
            _map(
          tracking['data'],
        );

        courier = _text(
          trackingData[
              'courier_name'],
        );

        if (trackingData['events']
            is List) {
          events =
              (trackingData['events']
                      as List)
                  .map(_map)
                  .toList();
        }
      } catch (_) {
        // Order details remain usable even when
        // tracking information is not available.
      }

      if (!mounted) return;

      setState(() {
        _order = order;
        _trackingEvents = events;
        _courierName = courier;

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

  Future<void> _copyOrderNumber()
      async {
    final order = _order;

    if (order == null) {
      return;
    }

    await Clipboard.setData(
      ClipboardData(
        text:
            order.orderNumber,
      ),
    );

    _message(
      'Order number copied.',
    );
  }

  Future<void> _cancelOrder()
      async {
    final order = _order;

    if (order == null ||
        !order.canCancel ||
        _actionLoading) {
      return;
    }

    String reason =
        _cancellationReasons.first;

    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder:
              (
            context,
            setDialogState,
          ) {
            return AlertDialog(
              title: const Text(
                'Cancel Order',
              ),
              content: Column(
                mainAxisSize:
                    MainAxisSize.min,
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  const Text(
                    'Cancellation is only available before the seller starts fulfillment.',
                    style: TextStyle(
                      fontSize: 11,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(
                    height: 14,
                  ),
                  DropdownButtonFormField<
                      String>(
                    value: reason,
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Reason',
                    ),
                    items:
                        _cancellationReasons
                            .map(
                      (value) =>
                          DropdownMenuItem<
                              String>(
                        value:
                            value,
                        child:
                            Text(
                          value,
                        ),
                      ),
                    )
                            .toList(),
                    onChanged: (value) {
                      if (value !=
                          null) {
                        setDialogState(
                          () {
                            reason =
                                value;
                          },
                        );
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.of(
                        dialogContext,
                      ).pop(
                        false,
                      ),
                  child:
                      const Text(
                    'Keep Order',
                  ),
                ),
                FilledButton(
                  onPressed: () =>
                      Navigator.of(
                        dialogContext,
                      ).pop(
                        true,
                      ),
                  style:
                      FilledButton
                          .styleFrom(
                    backgroundColor:
                        Colors.redAccent,
                  ),
                  child:
                      const Text(
                    'Cancel Order',
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed != true ||
        !mounted) {
      return;
    }

    setState(() {
      _actionLoading = true;
    });

    try {
      final response =
          await SariLiveData.instance
              .buyerCancelOrder(
        order.id,
        reason,
      );

      _message(
        response['message']
                ?.toString() ??
            'Order cancelled.',
      );

      await _load();
    } catch (error) {
      _message(
        error.toString(),
      );
    } finally {
      if (mounted) {
        setState(() {
          _actionLoading = false;
        });
      }
    }
  }

  Future<void> _reviewOrder()
      async {
    final order = _order;

    if (order == null ||
        !order.canReview ||
        order.items.isEmpty ||
        _actionLoading) {
      return;
    }

    final reviewableItems =
        order.items
            .where(
              (item) =>
                  item.productId > 0,
            )
            .toList();

    if (reviewableItems.isEmpty) {
      _message(
        'No reviewable product was found in this order.',
      );

      return;
    }

    var productId =
        reviewableItems.first.productId;

    var rating = 5;

    final commentController =
        TextEditingController();

    final submitted =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder:
              (
            context,
            setDialogState,
          ) {
            return AlertDialog(
              title: const Text(
                'Write a Review',
              ),
              content:
                  SingleChildScrollView(
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    if (reviewableItems
                            .length >
                        1) ...[
                      DropdownButtonFormField<
                          int>(
                        value:
                            productId,
                        decoration:
                            const InputDecoration(
                          labelText:
                              'Product',
                        ),
                        items:
                            reviewableItems
                                .map(
                          (item) =>
                              DropdownMenuItem<
                                  int>(
                            value: item
                                .productId,
                            child: Text(
                              item.name,
                              overflow:
                                  TextOverflow
                                      .ellipsis,
                            ),
                          ),
                        )
                                .toList(),
                        onChanged:
                            (value) {
                          if (value !=
                              null) {
                            setDialogState(
                              () {
                                productId =
                                    value;
                              },
                            );
                          }
                        },
                      ),
                      const SizedBox(
                        height: 14,
                      ),
                    ],
                    const Text(
                      'Rating',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                    const SizedBox(
                      height: 7,
                    ),
                    Wrap(
                      spacing: 3,
                      children:
                          List.generate(
                        5,
                        (index) {
                          final value =
                              index + 1;

                          return IconButton(
                            onPressed:
                                () {
                              setDialogState(
                                () {
                                  rating =
                                      value;
                                },
                              );
                            },
                            icon:
                                Icon(
                              value <=
                                      rating
                                  ? Icons
                                      .star_rounded
                                  : Icons
                                      .star_border_rounded,
                              color:
                                  gold,
                              size:
                                  28,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    TextField(
                      controller:
                          commentController,
                      minLines: 3,
                      maxLines: 5,
                      maxLength: 1500,
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Comment (optional)',
                        hintText:
                            'Share your experience with this product.',
                      ),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    const Text(
                      'Review photos are not included in the current mobile baseline yet.',
                      style: TextStyle(
                        color: muted,
                        fontSize: 8,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.of(
                        dialogContext,
                      ).pop(
                        false,
                      ),
                  child:
                      const Text(
                    'Cancel',
                  ),
                ),
                FilledButton(
                  onPressed: () =>
                      Navigator.of(
                        dialogContext,
                      ).pop(
                        true,
                      ),
                  child:
                      const Text(
                    'Submit Review',
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (submitted != true ||
        !mounted) {
      commentController.dispose();
      return;
    }

    setState(() {
      _actionLoading = true;
    });

    try {
      final response =
          await SariLiveData.instance
              .buyerReviewOrder(
        order.id,
        productId:
            productId,
        rating: rating,
        comment:
            commentController.text
                .trim(),
      );

      _message(
        response['message']
                ?.toString() ??
            'Product review saved.',
      );
    } catch (error) {
      _message(
        error.toString(),
      );
    } finally {
      commentController.dispose();

      if (mounted) {
        setState(() {
          _actionLoading = false;
        });
      }
    }
  }

  void _message(
    String message,
  ) {
    if (!mounted) return;

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

  String _money(
    double amount,
  ) {
    return '₱${amount.toStringAsFixed(2)}';
  }

  String _date(
    String raw,
  ) {
    final value =
        DateTime.tryParse(raw)
            ?.toLocal();

    if (value == null) {
      return raw.isEmpty
          ? 'Not available'
          : raw;
    }

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[value.month - 1]} '
        '${value.day}, '
        '${value.year}';
  }

  String _dateTime(
    String raw,
  ) {
    final value =
        DateTime.tryParse(raw)
            ?.toLocal();

    if (value == null) {
      return raw.isEmpty
          ? ''
          : raw;
    }

    final hour =
        value.hour == 0
            ? 12
            : value.hour > 12
                ? value.hour - 12
                : value.hour;

    final minute =
        value.minute
            .toString()
            .padLeft(
              2,
              '0',
            );

    final meridiem =
        value.hour >= 12
            ? 'PM'
            : 'AM';

    return '${_date(raw)} · '
        '$hour:$minute '
        '$meridiem';
  }

  Color _statusColor(
    BuyerOrder order,
  ) {
    if (order.isDelivered) {
      return const Color(
        0xFF4F8065,
      );
    }

    if (order.isCancelled) {
      return const Color(
        0xFFCC4D4D,
      );
    }

    return goldDark;
  }

  Widget _orderOverview(
    BuyerOrder order,
  ) {
    final statusColor =
        _statusColor(order);

    return _card(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'ORDER DETAILS',
            style: TextStyle(
              color: goldDark,
              fontSize: 8,
              fontWeight:
                  FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  order.orderNumber,
                  style:
                      const TextStyle(
                    color: dark,
                    fontSize: 20,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
              ),
              IconButton(
                tooltip:
                    'Copy order number',
                onPressed:
                    _copyOrderNumber,
                icon:
                    const Icon(
                  Icons.copy_outlined,
                  color: muted,
                  size: 19,
                ),
              ),
            ],
          ),
          Text(
            'Placed on ${_date(order.createdAt)}',
            style:
                const TextStyle(
              color: muted,
              fontSize: 9,
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 11,
              vertical: 7,
            ),
            decoration:
                BoxDecoration(
              color: statusColor
                  .withOpacity(
                .10,
              ),
              borderRadius:
                  BorderRadius.circular(
                20,
              ),
            ),
            child: Text(
              order.statusLabel,
              style:
                  TextStyle(
                color:
                    statusColor,
                fontSize: 9,
                fontWeight:
                    FontWeight.w700,
              ),
            ),
          ),
          if (order.deliveredAt
              .isNotEmpty) ...[
            const SizedBox(
              height: 12,
            ),
            _infoRow(
              'Delivered On',
              _date(
                order.deliveredAt,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _progressSection(
    BuyerOrder order,
  ) {
    if (order.isCancelled) {
      return _card(
        child: const Row(
          children: [
            Icon(
              Icons
                  .cancel_outlined,
              color: Color(
                0xFFCC4D4D,
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: Text(
                'This order was cancelled.',
                style: TextStyle(
                  color: Color(
                    0xFFCC4D4D,
                  ),
                  fontSize: 11,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
    }

    const steps = [
      (
        'Order Placed',
        Icons
            .shopping_bag_outlined,
      ),
      (
        'Preparing',
        Icons.inventory_2_outlined,
      ),
      (
        'Courier Assigned',
        Icons
            .local_shipping_outlined,
      ),
      (
        'Out for Delivery',
        Icons
            .two_wheeler_outlined,
      ),
      (
        'Delivered',
        Icons.home_outlined,
      ),
    ];

    return _card(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Progress',
            style: TextStyle(
              color: dark,
              fontSize: 15,
              fontWeight:
                  FontWeight.w800,
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          ...List.generate(
            steps.length,
            (index) {
              final reached =
                  index <=
                      order.statusStep;

              final current =
                  index ==
                      order.statusStep;

              return Row(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 31,
                        height: 31,
                        alignment:
                            Alignment.center,
                        decoration:
                            BoxDecoration(
                          shape:
                              BoxShape.circle,
                          color: reached
                              ? gold
                              : const Color(
                                  0xFFF1EEE8,
                                ),
                        ),
                        child: Icon(
                          steps[index]
                              .$2,
                          color: reached
                              ? Colors
                                  .white
                              : muted,
                          size: 16,
                        ),
                      ),
                      if (index !=
                          steps.length -
                              1)
                        Container(
                          width: 1.5,
                          height: 27,
                          color: index <
                                  order
                                      .statusStep
                              ? gold
                              : border,
                        ),
                    ],
                  ),
                  const SizedBox(
                    width: 11,
                  ),
                  Expanded(
                    child: Padding(
                      padding:
                          const EdgeInsets
                              .only(
                        top: 5,
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Text(
                            steps[index]
                                .$1,
                            style:
                                TextStyle(
                              color: reached
                                  ? dark
                                  : muted,
                              fontSize:
                                  10,
                              fontWeight: current
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                            ),
                          ),
                          if (current)
                            const Padding(
                              padding:
                                  EdgeInsets
                                      .only(
                                top: 2,
                              ),
                              child:
                                  Text(
                                'Current status',
                                style:
                                    TextStyle(
                                  color:
                                      goldDark,
                                  fontSize:
                                      8,
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
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _itemsSection(
    BuyerOrder order,
  ) {
    return _card(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Items',
            style: TextStyle(
              color: dark,
              fontSize: 15,
              fontWeight:
                  FontWeight.w800,
            ),
          ),
          const SizedBox(
            height: 13,
          ),
          if (order.items.isEmpty)
            const Text(
              'No item details are available.',
              style: TextStyle(
                color: muted,
                fontSize: 9,
              ),
            )
          else
            ...order.items.map(
              (item) =>
                  Container(
                margin:
                    const EdgeInsets.only(
                  bottom: 9,
                ),
                padding:
                    const EdgeInsets.all(
                  11,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      const Color(
                    0xFFFCFBF8,
                  ),
                  borderRadius:
                      BorderRadius
                          .circular(
                    10,
                  ),
                  border:
                      Border.all(
                    color: border,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      alignment:
                          Alignment.center,
                      decoration:
                          BoxDecoration(
                        color:
                            const Color(
                          0xFFFFF3DA,
                        ),
                        borderRadius:
                            BorderRadius
                                .circular(
                          9,
                        ),
                      ),
                      child:
                          const Icon(
                        Icons
                            .inventory_2_outlined,
                        color:
                            goldDark,
                        size: 20,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child:
                          Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Text(
                            item.name,
                            style:
                                const TextStyle(
                              color:
                                  dark,
                              fontSize:
                                  10,
                              fontWeight:
                                  FontWeight
                                      .w700,
                            ),
                          ),
                          const SizedBox(
                            height: 3,
                          ),
                          Text(
                            '${item.variantLabel} · Qty: ${item.quantity}',
                            style:
                                const TextStyle(
                              color:
                                  muted,
                              fontSize:
                                  8,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      _money(
                        item.lineTotal,
                      ),
                      style:
                          const TextStyle(
                        color:
                            goldDark,
                        fontSize: 10,
                        fontWeight:
                            FontWeight
                                .w800,
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

  Widget _deliverySection(
    BuyerOrder order,
  ) {
    return _card(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'Delivery Information',
            style: TextStyle(
              color: dark,
              fontSize: 15,
              fontWeight:
                  FontWeight.w800,
            ),
          ),
          const SizedBox(
            height: 13,
          ),
          _infoRow(
            'Recipient',
            order.buyerName,
          ),
          _infoRow(
            'Contact',
            order.buyerPhone
                    .isEmpty
                ? 'Not available'
                : order
                    .buyerPhone,
          ),
          const SizedBox(
            height: 9,
          ),
          const Text(
            'Delivery Address',
            style: TextStyle(
              color: muted,
              fontSize: 9,
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            order.deliveryAddress
                    .isEmpty
                ? 'Not available'
                : order
                    .deliveryAddress,
            style:
                const TextStyle(
              color: dark,
              fontSize: 10,
              height: 1.5,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sellerSection(
    BuyerOrder order,
  ) {
    return _card(
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            alignment:
                Alignment.center,
            decoration:
                BoxDecoration(
              color:
                  const Color(
                0xFFFFF3DA,
              ),
              borderRadius:
                  BorderRadius
                      .circular(
                10,
              ),
            ),
            child: const Icon(
              Icons
                  .storefront_outlined,
              color: goldDark,
              size: 21,
            ),
          ),
          const SizedBox(
            width: 11,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                const Text(
                  'Seller',
                  style:
                      TextStyle(
                    color:
                        muted,
                    fontSize: 8,
                  ),
                ),
                const SizedBox(
                  height: 3,
                ),
                Text(
                  order.sellerName,
                  style:
                      const TextStyle(
                    color: dark,
                    fontSize: 11,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentSection(
    BuyerOrder order,
  ) {
    return _card(
      child: Column(
        children: [
          const Align(
            alignment:
                Alignment.centerLeft,
            child: Text(
              'Payment Summary',
              style: TextStyle(
                color: dark,
                fontSize: 15,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(
            height: 13,
          ),
          _infoRow(
            'Payment Method',
            order.paymentMethod,
          ),
          _infoRow(
            'Payment Status',
            order.paymentStatus,
          ),
          _infoRow(
            'Merchandise Subtotal',
            _money(
              order.resolvedSubtotal,
            ),
          ),
          _infoRow(
            'Delivery Fee',
            _money(
              order.deliveryFee,
            ),
          ),
          const Divider(
            color: border,
            height: 22,
          ),
          _infoRow(
            'Order Total',
            _money(
              order.resolvedTotal,
            ),
            emphasis: true,
          ),
        ],
      ),
    );
  }

  Widget _trackingSection() {
    return _card(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'Delivery Tracking',
            style: TextStyle(
              color: dark,
              fontSize: 15,
              fontWeight:
                  FontWeight.w800,
            ),
          ),
          if (_courierName
              .isNotEmpty) ...[
            const SizedBox(
              height: 5,
            ),
            Text(
              'Courier: $_courierName',
              style:
                  const TextStyle(
                color: muted,
                fontSize: 9,
              ),
            ),
          ],
          const SizedBox(
            height: 14,
          ),
          if (_trackingEvents
              .isEmpty)
            const Text(
              'No buyer-visible tracking events are available yet.',
              style: TextStyle(
                color: muted,
                fontSize: 9,
              ),
            )
          else
            ..._trackingEvents.map(
              (event) =>
                  Padding(
                padding:
                    const EdgeInsets.only(
                  bottom: 12,
                ),
                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Container(
                      width: 29,
                      height: 29,
                      alignment:
                          Alignment.center,
                      decoration:
                          const BoxDecoration(
                        color:
                            Color(
                          0xFFFFF3DA,
                        ),
                        shape:
                            BoxShape.circle,
                      ),
                      child:
                          const Icon(
                        Icons
                            .check_rounded,
                        color:
                            goldDark,
                        size: 15,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child:
                          Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Text(
                            _text(
                              event[
                                  'title'],
                              _text(
                                event[
                                    'status'],
                                'Order Update',
                              ),
                            ),
                            style:
                                const TextStyle(
                              color:
                                  dark,
                              fontSize:
                                  10,
                              fontWeight:
                                  FontWeight
                                      .w700,
                            ),
                          ),
                          if (_text(
                            event[
                                'message'],
                          ).isNotEmpty) ...[
                            const SizedBox(
                              height:
                                  3,
                            ),
                            Text(
                              _text(
                                event[
                                    'message'],
                              ),
                              style:
                                  const TextStyle(
                                color:
                                    muted,
                                fontSize:
                                    8.5,
                                height:
                                    1.45,
                              ),
                            ),
                          ],
                          if (_text(
                            event[
                                'created_at'],
                          ).isNotEmpty) ...[
                            const SizedBox(
                              height:
                                  3,
                            ),
                            Text(
                              _dateTime(
                                _text(
                                  event[
                                      'created_at'],
                                ),
                              ),
                              style:
                                  const TextStyle(
                                color:
                                    muted,
                                fontSize:
                                    7.5,
                              ),
                            ),
                          ],
                        ],
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

  Widget _actionsSection(
    BuyerOrder order,
  ) {
    if (!order.canCancel &&
        !order.canReview) {
      return const SizedBox
          .shrink();
    }

    return _card(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Actions',
            style: TextStyle(
              color: dark,
              fontSize: 15,
              fontWeight:
                  FontWeight.w800,
            ),
          ),
          const SizedBox(
            height: 13,
          ),
          if (order.canCancel)
            SizedBox(
              width:
                  double.infinity,
              child:
                  OutlinedButton.icon(
                onPressed:
                    _actionLoading
                        ? null
                        : _cancelOrder,
                style:
                    OutlinedButton
                        .styleFrom(
                  foregroundColor:
                      Colors.redAccent,
                  side:
                      const BorderSide(
                    color:
                        Colors.redAccent,
                  ),
                  padding:
                      const EdgeInsets
                          .symmetric(
                    vertical: 13,
                  ),
                ),
                icon:
                    const Icon(
                  Icons
                      .cancel_outlined,
                ),
                label:
                    const Text(
                  'Cancel Order',
                ),
              ),
            ),
          if (order.canReview)
            SizedBox(
              width:
                  double.infinity,
              child:
                  ElevatedButton.icon(
                onPressed:
                    _actionLoading
                        ? null
                        : _reviewOrder,
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
                    vertical: 13,
                  ),
                ),
                icon:
                    const Icon(
                  Icons
                      .star_outline_rounded,
                ),
                label:
                    const Text(
                  'Write a Review',
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _infoRow(
    String label,
    String value, {
    bool emphasis = false,
  }) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 7,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style:
                  const TextStyle(
                color: muted,
                fontSize: 9,
              ),
            ),
          ),
          const SizedBox(
            width: 12,
          ),
          Flexible(
            child: Text(
              value,
              textAlign:
                  TextAlign.right,
              style:
                  TextStyle(
                color: emphasis
                    ? goldDark
                    : dark,
                fontSize: emphasis
                    ? 14
                    : 9,
                fontWeight:
                    emphasis
                        ? FontWeight
                            .w900
                        : FontWeight
                            .w600,
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
      width:
          double.infinity,
      padding:
          const EdgeInsets.all(
        16,
      ),
      decoration:
          BoxDecoration(
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
      child: child,
    );
  }

  Widget _errorState() {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(
          24,
        ),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            const Icon(
              Icons
                  .error_outline_rounded,
              size: 46,
              color: muted,
            ),
            const SizedBox(
              height: 12,
            ),
            const Text(
              'Unable to load order',
              style:
                  TextStyle(
                color: dark,
                fontSize: 16,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
            const SizedBox(
              height: 7,
            ),
            Text(
              _error ??
                  'Please try again.',
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                color: muted,
                fontSize: 9,
              ),
            ),
            const SizedBox(
              height: 14,
            ),
            OutlinedButton.icon(
              onPressed:
                  _load,
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
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final order = _order;

    return Scaffold(
      backgroundColor: canvas,
      appBar: AppBar(
        backgroundColor:
            Colors.white,
        foregroundColor: dark,
        surfaceTintColor:
            Colors.white,
        title: const Text(
          'Order Details',
          style: TextStyle(
            fontSize: 16,
            fontWeight:
                FontWeight.w800,
          ),
        ),
      ),
      body: _loading
          ? const Center(
              child:
                  CircularProgressIndicator(
                color: gold,
              ),
            )
          : _error != null ||
                  order == null
              ? _errorState()
              : RefreshIndicator(
                  color: gold,
                  onRefresh: _load,
                  child: ListView(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    padding:
                        const EdgeInsets.fromLTRB(
                      14,
                      16,
                      14,
                      30,
                    ),
                    children: [
                      _orderOverview(
                        order,
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      _progressSection(
                        order,
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      _itemsSection(
                        order,
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      _deliverySection(
                        order,
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      _sellerSection(
                        order,
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      _paymentSection(
                        order,
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      _trackingSection(),
                      if (order.canCancel ||
                          order
                              .canReview) ...[
                        const SizedBox(
                          height: 12,
                        ),
                        _actionsSection(
                          order,
                        ),
                      ],
                    ],
                  ),
                ),
    );
  }
}