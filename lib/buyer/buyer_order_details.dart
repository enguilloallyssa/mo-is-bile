import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/sari_live_data.dart';
import 'buyer_theme.dart';
import 'models/buyer_order_model.dart';

class BuyerOrderDetails extends StatefulWidget {
  final BuyerOrder order;

  const BuyerOrderDetails({
    super.key,
    required this.order,
  });

  @override
  State<BuyerOrderDetails> createState() =>
      _BuyerOrderDetailsState();
}

class _BuyerOrderDetailsState
    extends State<BuyerOrderDetails> {
  BuyerOrder? _order;

  final List<Map<String, dynamic>>
      _trackingEvents =
      <Map<String, dynamic>>[];

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

  // ============================================================
  // HELPERS
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
        : int.tryParse(
              '$value',
            ) ??
            0;
  }

  double _decimal(
    dynamic value,
  ) {
    return value is num
        ? value.toDouble()
        : double.tryParse(
              '$value',
            ) ??
            0;
  }

  String _money(
    double value,
  ) {
    return '₱${value.toStringAsFixed(2)}';
  }

  String _dateTime(
    String raw,
  ) {
    if (raw.trim().isEmpty) {
      return '—';
    }

    final DateTime? date =
        DateTime.tryParse(
      raw,
    )?.toLocal();

    if (date == null) {
      return raw;
    }

    const List<String> months =
        <String>[
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

    final int hour =
        date.hour == 0
            ? 12
            : date.hour > 12
                ? date.hour - 12
                : date.hour;

    final String minute =
        date.minute
            .toString()
            .padLeft(
              2,
              '0',
            );

    final String period =
        date.hour >= 12
            ? 'PM'
            : 'AM';

    return '${months[date.month - 1]} '
        '${date.day}, ${date.year} • '
        '$hour:$minute $period';
  }

  // ============================================================
  // PARSER
  // ============================================================

  BuyerOrderItem _parseItem(
    dynamic raw,
  ) {
    final Map<String, dynamic> item =
        _map(raw);

    final String image =
        _text(
      item['image_url'] ??
          item['image'],
    );

    return BuyerOrderItem(
      productId:
          _integer(
        item['product_id'],
      ),
      variantId:
          item['variant_id'] == null
              ? null
              : _integer(
                  item['variant_id'],
                ),
      name:
          _text(
        item['name'],
        'Product',
      ),
      variantLabel:
          _text(
        item['variant_label'],
        'Standard',
      ),
      quantity:
          _integer(
        item['qty'] ??
            item['quantity'],
      ),
      lineTotal:
          _decimal(
        item['line_total'],
      ),
      image:
          image.isEmpty
              ? null
              : image,
    );
  }

  BuyerOrder _parseOrder(
    dynamic raw,
  ) {
    final Map<String, dynamic> data =
        _map(raw);

    final List<BuyerOrderItem> items =
        data['items'] is List
            ? (data['items'] as List)
                .map(_parseItem)
                .toList()
            : <BuyerOrderItem>[];

    return BuyerOrder(
      id:
          _integer(
        data['id'],
      ),
      orderNumber:
          _text(
        data['order_number'],
        'SARI Order',
      ),
      status:
          _text(
        data['status'],
      ),
      apiStatusLabel:
          _text(
        data['status_label'],
      ),
      paymentMethod:
          _text(
        data['payment_method'],
        'Cash on Delivery',
      ),
      paymentStatus:
          _text(
        data['payment_status'],
        'pending',
      ),
      subtotal:
          _decimal(
        data['subtotal'],
      ),
      deliveryFee:
          _decimal(
        data['delivery_fee'],
      ),
      totalAmount:
          _decimal(
        data['total'],
      ),
      createdAt:
          _text(
        data['created_at'],
      ),
      deliveredAt:
          _text(
        data['delivered_at'],
      ),
      deliveryAddress:
          _text(
        data['buyer_address'],
      ),
      buyerName:
          _text(
        data['buyer_name'],
        'SARI Buyer',
      ),
      buyerPhone:
          _text(
        data['buyer_phone'],
      ),
      sellerName:
          _text(
        data['store_name'],
        'SARI Seller',
      ),
      sellerAccountId:
          _integer(
        data['seller_id'],
      ),
      items: items,
      productNames:
          items
              .map(
                (
                  BuyerOrderItem item,
                ) =>
                    item.name,
              )
              .toList(),
      latestUpdateTime:
          _text(
        data['updated_at'],
      ),
      latestUpdateMessage:
          _text(
        data['status_label'],
      ),
      cancelledAt:
          _text(
                  data['cancelled_at'],
                )
                .isEmpty
              ? null
              : _text(
                  data['cancelled_at'],
                ),
      cancellationReason:
          _text(
                  data[
                      'cancellation_reason'],
                )
                .isEmpty
              ? null
              : _text(
                  data[
                      'cancellation_reason'],
                ),
    );
  }

  // ============================================================
  // LOAD FRESH SERVER STATE
  // ============================================================

  Future<void> _load() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final Map<String, dynamic> response =
          await SariLiveData.instance
              .buyerOrderDetails(
        widget.order.id,
      );

      final dynamic raw =
          response['data'];

      if (raw is! Map) {
        throw const FormatException(
          'Invalid order details from SARI.',
        );
      }

      final BuyerOrder order =
          _parseOrder(raw);

      if (order.id !=
          widget.order.id) {
        throw const FormatException(
          'Invalid order ID returned by SARI.',
        );
      }

      List<Map<String, dynamic>>
          events =
          <Map<String, dynamic>>[];

      String courier = '';

      try {
        final Map<String, dynamic> tracking =
            await SariLiveData.instance
                .buyerTracking(
          order.id,
        );

        final Map<String, dynamic>
            trackingData =
            _map(
          tracking['data'],
        );

        courier =
            _text(
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
        // Order details remain usable
        // even if tracking temporarily fails.
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _order = order;

        _trackingEvents
          ..clear()
          ..addAll(events);

        _courierName =
            courier;

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
  // COPY
  // ============================================================

  Future<void> _copyOrderNumber()
      async {
    final BuyerOrder? order =
        _order;

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

  // ============================================================
  // CANCEL
  // ============================================================

  Future<void> _cancelOrder() async {
    final BuyerOrder? order =
        _order;

    if (order == null ||
        !order.canCancel ||
        _actionLoading) {
      return;
    }

    final TextEditingController reasonController =
        TextEditingController();

    final String? reason =
        await showDialog<String>(
      context: context,
      builder:
          (
            BuildContext dialogContext,
          ) {
        return AlertDialog(
          title:
              const Text(
            'Cancel Order',
          ),
          content:
              Column(
            mainAxisSize:
                MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Tell us why you want to cancel this order.',
              ),

              const SizedBox(
                height: 14,
              ),

              TextField(
                controller:
                    reasonController,
                minLines: 3,
                maxLines: 5,
                maxLength: 500,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Cancellation Reason',
                  hintText:
                      'Enter your reason...',
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );
              },
              child:
                  const Text(
                'Keep Order',
              ),
            ),

            FilledButton(
              style:
                  FilledButton
                      .styleFrom(
                backgroundColor:
                    BuyerTheme.danger,
              ),
              onPressed: () {
                final String reason =
                    reasonController
                        .text
                        .trim();

                if (reason.length < 3) {
                  return;
                }

                Navigator.pop(
                  dialogContext,
                  reason,
                );
              },
              child:
                  const Text(
                'Cancel Order',
              ),
            ),
          ],
        );
      },
    );

    reasonController.dispose();

    if (reason == null ||
        reason.trim().isEmpty ||
        !mounted) {
      return;
    }

    final bool? confirmed =
        await showDialog<bool>(
      context: context,
      builder:
          (
            BuildContext dialogContext,
          ) {
        return AlertDialog(
          title:
              const Text(
            'Confirm Cancellation',
          ),
          content: Text(
            'Cancel ${order.orderNumber}?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child:
                  const Text(
                'No',
              ),
            ),
            FilledButton(
              style:
                  FilledButton.styleFrom(
                backgroundColor:
                    BuyerTheme.danger,
              ),
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child:
                  const Text(
                'Yes, Cancel',
              ),
            ),
          ],
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
      final Map<String, dynamic> response =
          await SariLiveData.instance
              .buyerCancelOrder(
        order.id,
        reason,
      );

      _message(
        _text(
          response['message'],
          'Order cancelled.',
        ),
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

  // ============================================================
  // REVIEW
  // ============================================================

  Future<void> _reviewOrder() async {
    final BuyerOrder? order =
        _order;

    if (order == null ||
        !order.canReview ||
        order.items.isEmpty ||
        _actionLoading) {
      return;
    }

    final List<BuyerOrderItem>
        reviewableItems =
        order.items
            .where(
              (
                BuyerOrderItem item,
              ) =>
                  item.productId > 0,
            )
            .toList();

    if (reviewableItems.isEmpty) {
      _message(
        'No reviewable product was found in this order.',
      );

      return;
    }

    int productId =
        reviewableItems.first.productId;

    int rating = 5;

    final TextEditingController
        commentController =
        TextEditingController();

    final bool? submitted =
        await showDialog<bool>(
      context: context,
      builder:
          (
            BuildContext dialogContext,
          ) {
        return StatefulBuilder(
          builder:
              (
                BuildContext context,
                void Function(
                  void Function(),
                ) setDialogState,
              ) {
            return AlertDialog(
              title:
                  const Text(
                'Review Product',
              ),
              content:
                  SingleChildScrollView(
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: <Widget>[
                    if (reviewableItems.length >
                        1)
                      DropdownButtonFormField<int>(
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
                                  (
                                    BuyerOrderItem item,
                                  ) =>
                                      DropdownMenuItem<int>(
                                    value:
                                        item.productId,
                                    child:
                                        Text(
                                      item.name,
                                      overflow:
                                          TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
                                .toList(),
                        onChanged:
                            (
                              int? value,
                            ) {
                          if (value ==
                              null) {
                            return;
                          }

                          setDialogState(
                            () {
                              productId =
                                  value;
                            },
                          );
                        },
                      )
                    else
                      Text(
                        reviewableItems
                            .first.name,
                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight.w800,
                        ),
                      ),

                    const SizedBox(
                      height: 18,
                    ),

                    const Text(
                      'Your Rating',
                      style:
                          TextStyle(
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children:
                          List<Widget>.generate(
                        5,
                        (
                          int index,
                        ) {
                          final int value =
                              index + 1;

                          return IconButton(
                            onPressed: () {
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
                                  const Color(
                                0xFFF1B43B,
                              ),
                              size: 31,
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
                      maxLength: 1000,
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Comment',
                        hintText:
                            'Share your experience...',
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                      false,
                    );
                  },
                  child:
                      const Text(
                    'Cancel',
                  ),
                ),

                FilledButton(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                      true,
                    );
                  },
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
      final Map<String, dynamic> response =
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
        _text(
          response['message'],
          'Product review saved.',
        ),
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

  // ============================================================
  // STATUS
  // ============================================================

  Color _statusColor(
    BuyerOrder order,
  ) {
    if (order.isDelivered) {
      return BuyerTheme.success;
    }

    if (order.isCancelled) {
      return BuyerTheme.danger;
    }

    if (order.filterGroup ==
        'in-transit') {
      return BuyerTheme.blue;
    }

    return BuyerTheme.goldDark;
  }

  Color _statusBackground(
    BuyerOrder order,
  ) {
    if (order.isDelivered) {
      return BuyerTheme.successSoft;
    }

    if (order.isCancelled) {
      return const Color(
        0xFFFFECEB,
      );
    }

    if (order.filterGroup ==
        'in-transit') {
      return BuyerTheme.blueSoft;
    }

    return BuyerTheme.goldPale;
  }

  IconData _statusIcon(
    BuyerOrder order,
  ) {
    if (order.isDelivered) {
      return Icons
          .check_circle_outline_rounded;
    }

    if (order.isCancelled) {
      return Icons
          .cancel_outlined;
    }

    if (order.filterGroup ==
        'in-transit') {
      return Icons
          .local_shipping_outlined;
    }

    return Icons
        .inventory_2_outlined;
  }

  List<
      ({
        String title,
        String subtitle,
        IconData icon,
      })> _statusSteps() {
    return const [
      (
        title: 'Order Placed',
        subtitle:
            'Your order was created.',
        icon:
            Icons.receipt_long_outlined,
      ),
      (
        title: 'Preparing',
        subtitle:
            'Seller is preparing your parcel.',
        icon:
            Icons.inventory_2_outlined,
      ),
      (
        title: 'Picked Up',
        subtitle:
            'Parcel was released for delivery.',
        icon:
            Icons.delivery_dining_outlined,
      ),
      (
        title: 'In Transit',
        subtitle:
            'Your parcel is on the way.',
        icon:
            Icons.local_shipping_outlined,
      ),
      (
        title: 'Delivered',
        subtitle:
            'Parcel reached the Buyer.',
        icon:
            Icons.check_circle_outline_rounded,
      ),
    ];
  }

  // ============================================================
  // UI HELPERS
  // ============================================================

  Widget _section({
    required String title,
    IconData? icon,
    required Widget child,
  }) {
    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 13,
      ),
      padding:
          const EdgeInsets.all(
        17,
      ),
      decoration:
          BuyerTheme.card(),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              if (icon != null) ...[
                Container(
                  width: 38,
                  height: 38,
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
                  child: Icon(
                    icon,
                    color:
                        BuyerTheme.goldDark,
                    size: 19,
                  ),
                ),

                const SizedBox(
                  width: 10,
                ),
              ],

              Expanded(
                child: Text(
                  title,
                  style:
                      const TextStyle(
                    color:
                        BuyerTheme.ink,
                    fontSize: 15,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 15,
          ),

          child,
        ],
      ),
    );
  }

  Widget _infoRow(
    String label,
    String value, {
    bool strong = false,
  }) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 6,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 115,
            child: Text(
              label,
              style:
                  const TextStyle(
                color:
                    BuyerTheme.muted,
                fontSize: 9.5,
              ),
            ),
          ),

          Expanded(
            child: Text(
              value.isEmpty
                  ? '—'
                  : value,
              textAlign:
                  TextAlign.right,
              style:
                  TextStyle(
                color: strong
                    ? BuyerTheme.goldDark
                    : BuyerTheme.ink,
                fontSize:
                    strong ? 13 : 9.5,
                fontWeight: strong
                    ? FontWeight.w900
                    : FontWeight.w700,
                fontFamilyFallback:
                    const <String>[
                  'Roboto',
                  'Arial',
                  'sans-serif',
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _hero(
    BuyerOrder order,
  ) {
    final Color color =
        _statusColor(order);

    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 13,
      ),
      padding:
          const EdgeInsets.all(
        20,
      ),
      decoration:
          BoxDecoration(
        gradient:
            const LinearGradient(
          colors:
              BuyerTheme.heroGradient,
          begin:
              Alignment.topLeft,
          end:
              Alignment.bottomRight,
        ),
        borderRadius:
            BorderRadius.circular(
          23,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'ORDER DETAILS',
                      style:
                          TextStyle(
                        color:
                            Color(
                          0xFFFFD98A,
                        ),
                        fontSize: 9,
                        fontWeight:
                            FontWeight.w900,
                        letterSpacing:
                            1.2,
                      ),
                    ),

                    const SizedBox(
                      height: 7,
                    ),

                    Text(
                      order.orderNumber,
                      style:
                          const TextStyle(
                        color:
                            Colors.white,
                        fontSize: 21,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),

                    const SizedBox(
                      height: 6,
                    ),

                    Text(
                      _dateTime(
                        order.createdAt,
                      ),
                      style:
                          const TextStyle(
                        color:
                            Colors.white70,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),

              IconButton(
                tooltip:
                    'Copy order number',
                onPressed:
                    _copyOrderNumber,
                icon:
                    const Icon(
                  Icons
                      .content_copy_outlined,
                  color:
                      Colors.white,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 17,
          ),

          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 11,
              vertical: 8,
            ),
            decoration:
                BoxDecoration(
              color:
                  Colors.white
                      .withOpacity(.10),
              borderRadius:
                  BorderRadius.circular(
                20,
              ),
            ),
            child: Row(
              mainAxisSize:
                  MainAxisSize.min,
              children: <Widget>[
                Icon(
                  _statusIcon(order),
                  color:
                      Colors.white,
                  size: 16,
                ),

                const SizedBox(
                  width: 6,
                ),

                Text(
                  order.statusLabel,
                  style:
                      const TextStyle(
                    color:
                        Colors.white,
                    fontSize: 10,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 14,
          ),

          ClipRRect(
            borderRadius:
                BorderRadius.circular(
              10,
            ),
            child:
                LinearProgressIndicator(
              value:
                  order.isCancelled
                      ? 0
                      : (order.statusStep +
                              1) /
                          5,
              minHeight: 6,
              backgroundColor:
                  Colors.white
                      .withOpacity(.15),
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _timeline(
    BuyerOrder order,
  ) {
    if (order.isCancelled) {
      return _section(
        title:
            'Order Status',
        icon:
            Icons.cancel_outlined,
        child: Container(
          width:
              double.infinity,
          padding:
              const EdgeInsets.all(
            14,
          ),
          decoration:
              BoxDecoration(
            color:
                const Color(
              0xFFFFECEB,
            ),
            borderRadius:
                BorderRadius.circular(
              14,
            ),
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Cancelled',
                style:
                    TextStyle(
                  color:
                      BuyerTheme.danger,
                  fontSize: 13,
                  fontWeight:
                      FontWeight.w900,
                ),
              ),

              if ((order
                          .cancellationReason ??
                      '')
                  .isNotEmpty) ...[
                const SizedBox(
                  height: 6,
                ),
                Text(
                  order
                      .cancellationReason!,
                  style:
                      const TextStyle(
                    color:
                        BuyerTheme.muted,
                    fontSize: 10,
                  ),
                ),
              ],

              if ((order.cancelledAt ??
                      '')
                  .isNotEmpty) ...[
                const SizedBox(
                  height: 6,
                ),
                Text(
                  _dateTime(
                    order.cancelledAt!,
                  ),
                  style:
                      const TextStyle(
                    color:
                        BuyerTheme.muted,
                    fontSize: 9,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    final steps =
        _statusSteps();

    return _section(
      title:
          'Order Progress',
      icon:
          Icons.route_outlined,
      child: Column(
        children:
            List<Widget>.generate(
          steps.length,
          (
            int index,
          ) {
            final step =
                steps[index];

            final bool complete =
                index <=
                    order.statusStep;

            final bool current =
                index ==
                    order.statusStep;

            final bool last =
                index ==
                    steps.length - 1;

            return Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Container(
                      width: 34,
                      height: 34,
                      alignment:
                          Alignment.center,
                      decoration:
                          BoxDecoration(
                        color: complete
                            ? BuyerTheme
                                .successSoft
                            : BuyerTheme
                                .canvas,
                        shape:
                            BoxShape.circle,
                      ),
                      child: Icon(
                        complete
                            ? Icons
                                .check_rounded
                            : step.icon,
                        color: complete
                            ? BuyerTheme
                                .success
                            : BuyerTheme
                                .muted,
                        size: 17,
                      ),
                    ),

                    if (!last)
                      Container(
                        width: 2,
                        height: 42,
                        color: complete
                            ? BuyerTheme
                                .successSoft
                            : BuyerTheme
                                .border,
                      ),
                  ],
                ),

                const SizedBox(
                  width: 12,
                ),

                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.only(
                      top: 2,
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          step.title,
                          style:
                              TextStyle(
                            color: complete
                                ? BuyerTheme
                                    .ink
                                : BuyerTheme
                                    .muted,
                            fontSize: 11,
                            fontWeight: current
                                ? FontWeight
                                    .w900
                                : FontWeight
                                    .w700,
                          ),
                        ),

                        const SizedBox(
                          height: 3,
                        ),

                        Text(
                          step.subtitle,
                          style:
                              const TextStyle(
                            color:
                                BuyerTheme.muted,
                            fontSize: 8.5,
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
      ),
    );
  }

  Widget _items(
    BuyerOrder order,
  ) {
    return _section(
      title: 'Items',
      icon:
          Icons.shopping_bag_outlined,
      child: Column(
        children:
            order.items.map(
          (
            BuyerOrderItem item,
          ) {
            return Container(
              margin:
                  const EdgeInsets.only(
                bottom: 9,
              ),
              padding:
                  const EdgeInsets.all(
                12,
              ),
              decoration:
                  BoxDecoration(
                color:
                    BuyerTheme.canvas,
                borderRadius:
                    BorderRadius.circular(
                  14,
                ),
              ),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 55,
                    height: 55,
                    clipBehavior:
                        Clip.antiAlias,
                    decoration:
                        BoxDecoration(
                      color:
                          BuyerTheme.surface,
                      borderRadius:
                          BorderRadius.circular(
                        12,
                      ),
                    ),
                    child:
                        item.image == null ||
                                item.image!
                                    .trim()
                                    .isEmpty
                            ? const Icon(
                                Icons
                                    .inventory_2_outlined,
                                color:
                                    BuyerTheme.muted,
                              )
                            : Image.network(
                                item.image!,
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
                                      .inventory_2_outlined,
                                  color:
                                      BuyerTheme.muted,
                                ),
                              ),
                  ),

                  const SizedBox(
                    width: 11,
                  ),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          item.name,
                          maxLines: 2,
                          overflow:
                              TextOverflow.ellipsis,
                          style:
                              const TextStyle(
                            color:
                                BuyerTheme.ink,
                            fontSize: 11,
                            fontWeight:
                                FontWeight.w800,
                          ),
                        ),

                        if (item.variantLabel
                            .isNotEmpty) ...[
                          const SizedBox(
                            height: 3,
                          ),
                          Text(
                            item.variantLabel,
                            style:
                                const TextStyle(
                              color:
                                  BuyerTheme.muted,
                              fontSize: 8.5,
                            ),
                          ),
                        ],

                        const SizedBox(
                          height: 4,
                        ),

                        Text(
                          'Qty: ${item.quantity}',
                          style:
                              const TextStyle(
                            color:
                                BuyerTheme.muted,
                            fontSize: 8.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    width: 8,
                  ),

                  Text(
                    _money(
                      item.lineTotal,
                    ),
                    style:
                        const TextStyle(
                      color:
                          BuyerTheme.goldDark,
                      fontSize: 11,
                      fontWeight:
                          FontWeight.w900,
                      fontFamilyFallback:
                          <String>[
                        'Roboto',
                        'Arial',
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ).toList(),
      ),
    );
  }

  Widget _delivery(
    BuyerOrder order,
  ) {
    return _section(
      title:
          'Delivery Information',
      icon:
          Icons.location_on_outlined,
      child: Column(
        children: <Widget>[
          _infoRow(
            'Recipient',
            order.buyerName,
          ),

          _infoRow(
            'Contact',
            order.buyerPhone,
          ),

          _infoRow(
            'Address',
            order.deliveryAddress,
          ),

          if (_courierName
              .trim()
              .isNotEmpty)
            _infoRow(
              'Rider',
              _courierName,
            ),
        ],
      ),
    );
  }

  Widget _payment(
    BuyerOrder order,
  ) {
    return _section(
      title:
          'Payment Summary',
      icon:
          Icons.receipt_long_outlined,
      child: Column(
        children: <Widget>[
          _infoRow(
            'Payment',
            order.paymentMethod,
          ),

          _infoRow(
            'Payment Status',
            order.paymentStatus
                .replaceAll(
                  '_',
                  ' ',
                )
                .toUpperCase(),
          ),

          const Divider(),

          _infoRow(
            'Subtotal',
            _money(
              order
                  .resolvedSubtotal,
            ),
          ),

          _infoRow(
            'Delivery Fee',
            _money(
              order.deliveryFee,
            ),
          ),

          const Divider(),

          _infoRow(
            'Total',
            _money(
              order.resolvedTotal,
            ),
            strong: true,
          ),
        ],
      ),
    );
  }

  Widget _tracking() {
    if (_trackingEvents.isEmpty) {
      return const SizedBox.shrink();
    }

    return _section(
      title:
          'Tracking Updates',
      icon:
          Icons.local_shipping_outlined,
      child: Column(
        children:
            List<Widget>.generate(
          _trackingEvents.length,
          (
            int index,
          ) {
            final Map<String, dynamic>
                event =
                _trackingEvents[index];

            final bool last =
                index ==
                    _trackingEvents.length -
                        1;

            return Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Container(
                      width: 30,
                      height: 30,
                      alignment:
                          Alignment.center,
                      decoration:
                          const BoxDecoration(
                        color:
                            BuyerTheme.successSoft,
                        shape:
                            BoxShape.circle,
                      ),
                      child:
                          const Icon(
                        Icons
                            .check_rounded,
                        color:
                            BuyerTheme.success,
                        size: 16,
                      ),
                    ),

                    if (!last)
                      Container(
                        width: 2,
                        height: 48,
                        color:
                            BuyerTheme.border,
                      ),
                  ],
                ),

                const SizedBox(
                  width: 11,
                ),

                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.only(
                      top: 2,
                      bottom: 16,
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          _text(
                            event['title'],
                            _text(
                              event['status'],
                              'Order Update',
                            ),
                          ),
                          style:
                              const TextStyle(
                            color:
                                BuyerTheme.ink,
                            fontSize: 10.5,
                            fontWeight:
                                FontWeight.w800,
                          ),
                        ),

                        if (_text(
                          event['message'],
                        ).isNotEmpty) ...[
                          const SizedBox(
                            height: 3,
                          ),
                          Text(
                            _text(
                              event['message'],
                            ),
                            style:
                                const TextStyle(
                              color:
                                  BuyerTheme.muted,
                              fontSize: 8.5,
                              height: 1.4,
                            ),
                          ),
                        ],

                        if (_text(
                          event['created_at'],
                        ).isNotEmpty) ...[
                          const SizedBox(
                            height: 4,
                          ),
                          Text(
                            _dateTime(
                              _text(
                                event['created_at'],
                              ),
                            ),
                            style:
                                const TextStyle(
                              color:
                                  BuyerTheme.muted,
                              fontSize: 8,
                            ),
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
    );
  }

  Widget _actions(
    BuyerOrder order,
  ) {
    if (!order.canCancel &&
        !order.canReview) {
      return const SizedBox.shrink();
    }

    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 15,
      ),
      child: Row(
        children: <Widget>[
          if (order.canCancel)
            Expanded(
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
                      BuyerTheme.danger,
                  side:
                      const BorderSide(
                    color:
                        BuyerTheme.danger,
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

          if (order.canCancel &&
              order.canReview)
            const SizedBox(
              width: 9,
            ),

          if (order.canReview)
            Expanded(
              child:
                  FilledButton.icon(
                onPressed:
                    _actionLoading
                        ? null
                        : _reviewOrder,
                icon:
                    const Icon(
                  Icons.star_outline_rounded,
                ),
                label:
                    const Text(
                  'Write Review',
                ),
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
          26,
        ),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.cloud_off_outlined,
              size: 49,
              color:
                  BuyerTheme.muted,
            ),

            const SizedBox(
              height: 13,
            ),

            const Text(
              'Unable to load order',
              style:
                  TextStyle(
                color:
                    BuyerTheme.ink,
                fontSize: 17,
                fontWeight:
                    FontWeight.w900,
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
                color:
                    BuyerTheme.muted,
              ),
            ),

            const SizedBox(
              height: 16,
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
    final BuyerOrder? order =
        _order;

    return Scaffold(
      backgroundColor:
          BuyerTheme.canvas,
      appBar: AppBar(
        title:
            const Text(
          'Order Details',
          style:
              TextStyle(
            fontWeight:
                FontWeight.w900,
          ),
        ),
        actions: <Widget>[
          IconButton(
            tooltip:
                'Refresh',
            onPressed:
                _loading
                    ? null
                    : _load,
            icon:
                const Icon(
              Icons.refresh_rounded,
            ),
          ),
        ],
      ),
      body: _loading &&
              order == null
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : _error != null &&
                  order == null
              ? _errorState()
              : order == null
                  ? _errorState()
                  : Stack(
                      children: <Widget>[
                        RefreshIndicator(
                          color:
                              BuyerTheme.gold,
                          onRefresh:
                              _load,
                          child: ListView(
                            physics:
                                const AlwaysScrollableScrollPhysics(),
                            padding:
                                const EdgeInsets.fromLTRB(
                              14,
                              14,
                              14,
                              30,
                            ),
                            children: <Widget>[
                              _hero(
                                order,
                              ),

                              _timeline(
                                order,
                              ),

                              if (order
                                  .items
                                  .isNotEmpty)
                                _items(
                                  order,
                                ),

                              _delivery(
                                order,
                              ),

                              _payment(
                                order,
                              ),

                              _tracking(),

                              _actions(
                                order,
                              ),
                            ],
                          ),
                        ),

                        if (_actionLoading)
                          Positioned.fill(
                            child:
                                ColoredBox(
                              color:
                                  const Color(
                                0x33FFFFFF,
                              ),
                              child:
                                  const Center(
                                child:
                                    CircularProgressIndicator(),
                              ),
                            ),
                          ),
                      ],
                    ),
    );
  }
}