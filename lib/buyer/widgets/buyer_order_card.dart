import 'package:flutter/material.dart';

import '../models/buyer_order_model.dart';

class BuyerOrderCard extends StatelessWidget {
  final BuyerOrder order;

  final VoidCallback onCopy;
  final VoidCallback onMessageSeller;
  final VoidCallback onViewDetails;
  final VoidCallback onTrackOrder;

  final VoidCallback? onReturnRequest;

  const BuyerOrderCard({
    super.key,
    required this.order,
    required this.onCopy,
    required this.onMessageSeller,
    required this.onViewDetails,
    required this.onTrackOrder,
    this.onReturnRequest,
  });

  static const Color _brand =
      Color(0xFFD98D08);
  static const Color _blue =
      Color(0xFF3C6E91);
  static const Color _green =
      Color(0xFF4F7D63);
  static const Color _text =
      Color(0xFF211D17);
  static const Color _muted =
      Color(0xFF81786E);
  static const Color _border =
      Color(0xFFE8E0D5);

  bool get _isLiveDelivery {
    return const {
      'courier_accepted',
      'heading_pickup',
      'arrived_pickup',
      'in_transit',
      'arrived_buyer',
    }.contains(
      order.status,
    );
  }

  String get _deliveryHeadline {
    switch (order.status) {
      case 'new':
        return 'Order placed';

      case 'preparing':
        return 'Seller is preparing your order';

      case 'ready_for_pickup':
        return 'Ready for courier pickup';

      case 'courier_accepted':
        return 'Courier assigned';

      case 'heading_pickup':
        return 'Courier heading to seller';

      case 'arrived_pickup':
        return 'Courier arrived at seller';

      case 'in_transit':
        return 'Package is on the way';

      case 'arrived_buyer':
        return 'Courier arrived at destination';

      case 'delivered':
        return 'Order delivered';

      case 'cancelled':
        return 'Order cancelled';

      default:
        return order.statusLabel;
    }
  }

  String get _updateMessage {
    if (order.latestUpdateMessage
        .trim()
        .isNotEmpty) {
      return order.latestUpdateMessage;
    }

    return order.statusLabel;
  }

  List<String> get _itemNames {
    if (order.productNames.isNotEmpty) {
      return order.productNames;
    }

    return order.items
        .map(
          (item) => item.name,
        )
        .where(
          (name) => name.trim().isNotEmpty,
        )
        .toList();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final accent =
        _statusColor;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        border:
            Border.all(color: _border),
      ),
      clipBehavior:
          Clip.antiAlias,
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 4,
            color: accent,
          ),
          Padding(
            padding:
                const EdgeInsets.fromLTRB(
              14,
              13,
              14,
              12,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration:
                          BoxDecoration(
                        color: accent
                            .withValues(
                          alpha: .11,
                        ),
                        borderRadius:
                            BorderRadius.circular(
                          12,
                        ),
                      ),
                      child: Icon(
                        _statusIcon,
                        color: accent,
                        size: 21,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  order.orderNumber,
                                  maxLines: 1,
                                  overflow:
                                      TextOverflow
                                          .ellipsis,
                                  style:
                                      const TextStyle(
                                    color: _text,
                                    fontSize: 12.5,
                                    fontWeight:
                                        FontWeight
                                            .w900,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: onCopy,
                                tooltip:
                                    'Copy order number',
                                icon:
                                    const Icon(
                                  Icons
                                      .copy_rounded,
                                  size: 16,
                                  color: _muted,
                                ),
                              ),
                            ],
                          ),
                          Wrap(
                            spacing: 6,
                            runSpacing: 5,
                            children: [
                              _statusPill(
                                accent,
                              ),
                              if (order
                                  .createdAt
                                  .isNotEmpty)
                                Text(
                                  order.createdAt,
                                  style:
                                      const TextStyle(
                                    color:
                                        _muted,
                                    fontSize:
                                        7.5,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 7),
                    Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'TOTAL',
                          style: TextStyle(
                            color: _muted,
                            fontSize: 6.5,
                            fontWeight:
                                FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _peso(
                            order.resolvedTotal,
                          ),
                          style:
                              const TextStyle(
                            color: _text,
                            fontSize: 13,
                            fontWeight:
                                FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.all(
                    11,
                  ),
                  decoration:
                      BoxDecoration(
                    color: accent
                        .withValues(
                      alpha: .055,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      13,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.bolt_rounded,
                        color: accent,
                        size: 17,
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Text(
                              _deliveryHeadline,
                              style:
                                  const TextStyle(
                                color: _text,
                                fontSize: 9.5,
                                fontWeight:
                                    FontWeight.w800,
                              ),
                            ),
                            const SizedBox(
                              height: 2,
                            ),
                            Text(
                              _updateMessage,
                              maxLines: 2,
                              overflow:
                                  TextOverflow
                                      .ellipsis,
                              style:
                                  const TextStyle(
                                color: _muted,
                                fontSize: 7.5,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _progress(accent),
                const SizedBox(height: 12),
                _productsPreview(),
                const SizedBox(height: 11),
                _deliveryInfo(),
              ],
            ),
          ),
          const Divider(height: 1),
          _actions(accent),
          if (order.isDelivered &&
              onReturnRequest != null) ...[
            const Divider(height: 1),
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(
                12,
                8,
                12,
                11,
              ),
              child: OutlinedButton.icon(
                onPressed:
                    onReturnRequest,
                icon: const Icon(
                  Icons
                      .assignment_return_outlined,
                  size: 15,
                ),
                label: const Text(
                  'Request Return / Refund',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _progress(
    Color accent,
  ) {
    const labels = [
      'Placed',
      'Prepared',
      'On the way',
      'Delivered',
    ];

    final step =
        _visualStep;

    return Column(
      children: [
        Row(
          children: List.generate(
            labels.length,
            (index) {
              final reached =
                  step >= index + 1 ||
                      order.isDelivered;

              final color = reached
                  ? accent
                  : const Color(
                      0xFFDCD5CB,
                    );

              return Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      alignment:
                          Alignment.center,
                      decoration:
                          BoxDecoration(
                        color: reached
                            ? color
                            : Colors.white,
                        shape:
                            BoxShape.circle,
                        border:
                            Border.all(
                          color: color,
                          width: 1.5,
                        ),
                      ),
                      child: reached
                          ? const Icon(
                              Icons
                                  .check_rounded,
                              color:
                                  Colors.white,
                              size: 14,
                            )
                          : Text(
                              '${index + 1}',
                              style:
                                  TextStyle(
                                color:
                                    color,
                                fontSize:
                                    7,
                                fontWeight:
                                    FontWeight
                                        .w800,
                              ),
                            ),
                    ),
                    if (index <
                        labels.length - 1)
                      Expanded(
                        child: Container(
                          height: 2,
                          color: step >
                                  index + 1
                              ? accent
                              : const Color(
                                  0xFFE5DED4,
                                ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 5),
        Row(
          children: labels
              .map(
                (label) => Expanded(
                  child: Text(
                    label,
                    textAlign:
                        TextAlign.center,
                    style:
                        const TextStyle(
                      color: _muted,
                      fontSize: 6.5,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _productsPreview() {
    final names = _itemNames;

    final preview =
        names.take(2).toList();

    return Container(
      padding:
          const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color:
            const Color(0xFFFBF9F5),
        borderRadius:
            BorderRadius.circular(13),
        border:
            Border.all(
          color:
              const Color(0xFFEEE7DC),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment:
                Alignment.center,
            decoration:
                BoxDecoration(
              color:
                  const Color(
                0xFFFFF0D8,
              ),
              borderRadius:
                  BorderRadius.circular(
                11,
              ),
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              color: _brand,
              size: 19,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  preview.isEmpty
                      ? 'Order items'
                      : preview.join(' • '),
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      const TextStyle(
                    color: _text,
                    fontSize: 8.5,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${names.length} item${names.length == 1 ? '' : 's'} • '
                  '${order.paymentMethod.toUpperCase()}',
                  style:
                      const TextStyle(
                    color: _muted,
                    fontSize: 7,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _deliveryInfo() {
    final address =
        order.deliveryAddress.trim();

    final courier =
        order.courierName.trim();

    return Row(
      children: [
        const Icon(
          Icons.location_on_outlined,
          color: _muted,
          size: 15,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            address.isEmpty
                ? 'Delivery address not available'
                : address,
            maxLines: 1,
            overflow:
                TextOverflow.ellipsis,
            style:
                const TextStyle(
              color: _muted,
              fontSize: 7.5,
            ),
          ),
        ),
        if (courier.isNotEmpty) ...[
          const SizedBox(width: 8),
          const Icon(
            Icons.two_wheeler_outlined,
            color: _blue,
            size: 15,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              courier,
              maxLines: 1,
              overflow:
                  TextOverflow.ellipsis,
              style:
                  const TextStyle(
                color: _blue,
                fontSize: 7.2,
                fontWeight:
                    FontWeight.w700,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _actions(
    Color accent,
  ) {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        12,
        10,
        12,
        12,
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed:
                  onMessageSeller,
              icon: const Icon(
                Icons
                    .chat_bubble_outline_rounded,
                size: 15,
              ),
              label:
                  const Text('Message'),
            ),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: OutlinedButton.icon(
              onPressed:
                  onViewDetails,
              icon: const Icon(
                Icons
                    .receipt_long_outlined,
                size: 15,
              ),
              label:
                  const Text('Details'),
            ),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: ElevatedButton.icon(
              onPressed:
                  onTrackOrder,
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    accent,
                foregroundColor:
                    Colors.white,
              ),
              icon: Icon(
                order.isDelivered
                    ? Icons
                        .check_circle_outline
                    : Icons
                        .route_outlined,
                size: 15,
              ),
              label: Text(
                order.isDelivered
                    ? 'View'
                    : 'Track',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusPill(
    Color color,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: .10,
        ),
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Text(
        order.statusLabel
            .toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 6.5,
          fontWeight:
              FontWeight.w900,
        ),
      ),
    );
  }

  int get _visualStep {
    if (order.isCancelled) {
      return 0;
    }

    switch (order.status) {
      case 'new':
        return 1;

      case 'preparing':
      case 'ready_for_pickup':
        return 2;

      case 'courier_accepted':
      case 'heading_pickup':
      case 'arrived_pickup':
      case 'in_transit':
      case 'arrived_buyer':
        return 3;

      case 'delivered':
        return 4;

      default:
        return 1;
    }
  }

  Color get _statusColor {
    if (order.isDelivered) {
      return _green;
    }

    if (order.isCancelled) {
      return const Color(
        0xFFB25555,
      );
    }

    if (_isLiveDelivery) {
      return _blue;
    }

    return _brand;
  }

  IconData get _statusIcon {
    if (order.isDelivered) {
      return Icons.task_alt_rounded;
    }

    if (order.isCancelled) {
      return Icons.cancel_outlined;
    }

    if (_isLiveDelivery) {
      return Icons
          .local_shipping_outlined;
    }

    return Icons
        .inventory_2_outlined;
  }

  String _peso(
    double value,
  ) {
    return '₱${value.toStringAsFixed(2)}';
  }
}