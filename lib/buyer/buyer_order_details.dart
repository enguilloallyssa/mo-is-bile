import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'models/buyer_order_model.dart';
import 'buyer_messages.dart';

class BuyerOrderDetails extends StatelessWidget {
  final BuyerOrder order;
  final VoidCallback? onContactSupport;
  final VoidCallback? onMessageSeller;

  const BuyerOrderDetails({
    super.key,
    required this.order,
    this.onContactSupport,
    this.onMessageSeller,
  });

  static const Color _gold = Color(0xFFC98B1C);
  static const Color _goldDark = Color(0xFFB67813);
  static const Color _pageBg = Color(0xFFFBFAF7);
  static const Color _border = Color(0xFFEBE4DA);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBg,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFDFA),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 0,
        title: const Text(
          'Order Tracking',
          style: TextStyle(
            color: Color(0xFF302A24),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _topHeading(context),
            const SizedBox(height: 12),
            _breadcrumb(context),
            const SizedBox(height: 14),
            if (order.isCancelled)
              _cancelledPanel()
            else ...[
              _orderHeaderCard(),
              const SizedBox(height: 14),
              _deliveryJourney(),
              const SizedBox(height: 14),
              _orderSummaryCard(),
              const SizedBox(height: 14),
              _courierCard(context),
            ],
            const SizedBox(height: 14),
            _itemsCard(),
            const SizedBox(height: 14),
            _deliveryReminder(),
          ],
        ),
      ),
    );
  }

  Widget _topHeading(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton.icon(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            foregroundColor: const Color(0xFF7C746C),
          ),
          icon: const Icon(
            Icons.arrow_back,
            size: 16,
          ),
          label: const Text(
            'Back to My Orders',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'ORDER TRACKING',
          style: TextStyle(
            color: Color(0xFFB47B1E),
            fontSize: 8,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 3),
        const Text(
          'Track your delivery',
          style: TextStyle(
            color: Color(0xFF201D19),
            fontSize: 29,
            height: 1.05,
            fontWeight: FontWeight.w700,
            letterSpacing: -1.1,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Follow your order status and delivery progress from checkout to doorstep.',
          style: TextStyle(
            color: Color(0xFF857B70),
            fontSize: 9,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Text(
              'Need help?',
              style: TextStyle(
                color: Color(0xFF9A9187),
                fontSize: 8,
              ),
            ),
            const SizedBox(width: 7),
            OutlinedButton.icon(
              onPressed: onContactSupport ??
                  () => _toast(
                        context,
                        'Support will be connected later.',
                      ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF9D6D18),
                backgroundColor: const Color(0xFFFFFAF0),
                side: const BorderSide(
                  color: Color(0xFFE8D7B6),
                ),
                minimumSize: const Size(0, 38),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
              icon: const Icon(
                Icons.headset_mic_outlined,
                size: 15,
              ),
              label: const Text(
                'Contact Support',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _breadcrumb(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const Text(
          'Home',
          style: TextStyle(
            color: Color(0xFF9B9289),
            fontSize: 8,
          ),
        ),
        const Icon(
          Icons.chevron_right,
          size: 14,
          color: Color(0xFFB8AFA5),
        ),
        InkWell(
          onTap: () => Navigator.pop(context),
          child: const Text(
            'Orders',
            style: TextStyle(
              color: Color(0xFF9B9289),
              fontSize: 8,
            ),
          ),
        ),
        const Icon(
          Icons.chevron_right,
          size: 14,
          color: Color(0xFFB8AFA5),
        ),
        Text(
          order.orderNumber,
          style: const TextStyle(
            color: _goldDark,
            fontSize: 8,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _cancelledPanel() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFEFCECE),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFFBE4E4),
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: Color(0xFFA65353),
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Order cancelled',
                  style: TextStyle(
                    color: Color(0xFF913F3F),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  (order.cancellationReason ?? '').trim().isEmpty
                      ? 'This order was cancelled.'
                      : order.cancellationReason!,
                  style: const TextStyle(
                    color: Color(0xFF926E6E),
                    fontSize: 9,
                    height: 1.45,
                  ),
                ),
                if ((order.cancelledAt ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 7),
                  Text(
                    order.cancelledAt!,
                    style: const TextStyle(
                      color: Color(0xFFAD8B8B),
                      fontSize: 8,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _orderHeaderCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: _border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x112C2721),
            blurRadius: 36,
            offset: Offset(0, 16),
          ),
          BoxShadow(
            color: Color(0x092C2721),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 49,
                      height: 49,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF5DF),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.inventory_2_outlined,
                        color: Color(0xFFB77914),
                        size: 23,
                      ),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 7,
                            runSpacing: 6,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                order.orderNumber,
                                style: const TextStyle(
                                  color: Color(0xFF26211D),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 9,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF2D6),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  order.statusLabel.toUpperCase(),
                                  style: const TextStyle(
                                    color: Color(0xFFA66F0F),
                                    fontSize: 6.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: .6,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Placed ${order.createdAt} • ${order.sellerName}',
                            style: const TextStyle(
                              color: Color(0xFF968C82),
                              fontSize: 8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _topMetric(
                        'FULFILLMENT',
                        '${order.progress}%',
                        const Color(0xFFB67813),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 38,
                      color: const Color(0xFFEEE6DC),
                    ),
                    Expanded(
                      child: _topMetric(
                        'PAYMENT',
                        '${order.paymentMethod} · ${_titleCase(order.paymentStatus)}',
                        const Color(0xFF4E4740),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(
            height: 1,
            color: Color(0xFFEFE8DF),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _summaryProgress(),
                const SizedBox(height: 16),
                _deliveryStatusCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _topMetric(
    String label,
    String value,
    Color valueColor,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF9B9289),
            fontSize: 7,
            fontWeight: FontWeight.w700,
            letterSpacing: .7,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: valueColor,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _summaryProgress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CURRENT STAGE',
                    style: TextStyle(
                      color: Color(0xFF9C9186),
                      fontSize: 7,
                      fontWeight: FontWeight.w700,
                      letterSpacing: .7,
                    ),
                  ),
                  SizedBox(height: 3),
                ],
              ),
            ),
            Text(
              '${order.progress}%',
              style: const TextStyle(
                color: _goldDark,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        Text(
          order.statusLabel,
          style: const TextStyle(
            color: Color(0xFF342E28),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 9),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: order.progress / 100,
            minHeight: 8,
            backgroundColor: const Color(0xFFEDE7DF),
            color: const Color(0xFFE2A328),
          ),
        ),
        const SizedBox(height: 13),
        _fiveStepSummary(),
      ],
    );
  }

  Widget _fiveStepSummary() {
    const labels = [
      'Order Placed',
      'Processing',
      'In Transit',
      'Out for Delivery',
      'Delivered',
    ];

    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: labels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 7),
        itemBuilder: (context, index) {
          final number = index + 1;
          final complete = order.activeSummaryStep >= number;
          final current =
              order.activeSummaryStep == number && !order.isDelivered;

          return SizedBox(
            width: 72,
            child: Column(
              children: [
                Container(
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(
                      color: complete
                          ? const Color(0xFFECB033)
                          : const Color(0xFFDED8CF),
                      width: 2,
                    ),
                    boxShadow: current
                        ? const [
                            BoxShadow(
                              color: Color(0x30FFF1D7),
                              blurRadius: 0,
                              spreadRadius: 7,
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    _summaryIcon(index),
                    size: 16,
                    color: complete
                        ? _goldDark
                        : const Color(0xFFAAA198),
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  labels[index],
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: TextStyle(
                    color: complete
                        ? const Color(0xFF332D28)
                        : const Color(0xFF9F968D),
                    fontSize: 7,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  IconData _summaryIcon(int index) {
    switch (index) {
      case 0:
        return Icons.check;
      case 1:
        return Icons.inventory_2_outlined;
      case 2:
        return Icons.local_shipping_outlined;
      case 3:
        return Icons.delivery_dining_outlined;
      default:
        return Icons.check_circle_outline;
    }
  }

  Widget _deliveryStatusCard() {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFEEE5D8),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3D7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.local_shipping_outlined,
              color: _goldDark,
              size: 20,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.deliveryHeadline,
                  style: const TextStyle(
                    color: Color(0xFF332D28),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  order.deliverySubtext,
                  style: const TextStyle(
                    color: Color(0xFF8A8076),
                    fontSize: 8,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _deliveryJourney() {
    final steps = _timelineSteps();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x102C2721),
            blurRadius: 30,
            offset: Offset(0, 13),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SHIPMENT PROGRESS',
                        style: TextStyle(
                          color: Color(0xFFA8751C),
                          fontSize: 7,
                          fontWeight: FontWeight.w700,
                          letterSpacing: .8,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Delivery journey',
                        style: TextStyle(
                          color: Color(0xFF312B26),
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFCFAF6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFEADFCF),
                    ),
                  ),
                  child: const Text(
                    'Status-based preview',
                    style: TextStyle(
                      color: Color(0xFF80766C),
                      fontSize: 6.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            height: 1,
            color: Color(0xFFEEE7DE),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ...List.generate(steps.length, (index) {
                  final stepNumber = index + 1;
                  final complete =
                      order.trackingStatusIndex >= stepNumber;
                  final current =
                      order.trackingStatusIndex == stepNumber &&
                          !order.isDelivered;

                  return _timelineRow(
                    number: stepNumber,
                    label: steps[index].label,
                    description: steps[index].description,
                    time: steps[index].time,
                    complete: complete,
                    current: current,
                    isLast: index == steps.length - 1,
                  );
                }),
                const SizedBox(height: 14),
                _routeMap(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _timelineRow({
    required int number,
    required String label,
    required String description,
    required String time,
    required bool complete,
    required bool current,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 32,
          child: Column(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: complete
                      ? const Color(0xFFFFF6E5)
                      : Colors.white,
                  border: Border.all(
                    color: complete
                        ? const Color(0xFFD9A13C)
                        : const Color(0xFFE2DBD2),
                  ),
                  boxShadow: current
                      ? const [
                          BoxShadow(
                            color: Color(0x33FFF1D3),
                            blurRadius: 0,
                            spreadRadius: 4,
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: complete && !current
                      ? const Icon(
                          Icons.check,
                          color: _goldDark,
                          size: 16,
                        )
                      : Text(
                          '$number',
                          style: TextStyle(
                            color: complete
                                ? _goldDark
                                : const Color(0xFFB4AAA0),
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
              if (!isLast)
                Container(
                  width: 1,
                  height: 49,
                  color: complete &&
                          order.trackingStatusIndex > number
                      ? const Color(0xFFDCA137)
                      : const Color(0xFFE6DFD6),
                ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 7,
                  runSpacing: 5,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: complete
                            ? const Color(0xFF3B342E)
                            : const Color(0xFFA29A91),
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (current)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF1D3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'CURRENT',
                          style: TextStyle(
                            color: Color(0xFFA66F0F),
                            fontSize: 6,
                            fontWeight: FontWeight.w800,
                            letterSpacing: .6,
                          ),
                        ),
                      ),
                  ],
                ),
                if (time.trim().isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    time,
                    style: const TextStyle(
                      color: Color(0xFF9B9187),
                      fontSize: 7,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: complete
                        ? const Color(0xFF8B8177)
                        : const Color(0xFFAAA198),
                    fontSize: 7.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _routeMap() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F5F1),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE7E0D7),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          SizedBox(
            height: 250,
            width: double.infinity,
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _DeliveryRoutePainter(
                      progress: order.routeProgress / 100,
                    ),
                  ),
                ),
                Positioned(
                  left: 12,
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.94),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white,
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.local_shipping_outlined,
                          color: Color(0xFFB77914),
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Delivery route',
                                style: TextStyle(
                                  color: Color(0xFF3E3832),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'Progress preview based on your current order status',
                                style: TextStyle(
                                  color: Color(0xFF91877D),
                                  fontSize: 6.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.95),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${order.routeProgress}% route progress',
                      style: const TextStyle(
                        color: _goldDark,
                        fontSize: 7,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(13),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 7,
                  runSpacing: 5,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      order.courierName.trim().isEmpty
                          ? 'Courier not yet assigned'
                          : order.courierName,
                      style: const TextStyle(
                        color: Color(0xFF3B352F),
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3D8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        order.statusLabel.toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFF9D6C17),
                          fontSize: 6,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                const Text(
                  "The route fills to the parcel's current stage and then stops. This is a status preview, not live GPS tracking.",
                  style: TextStyle(
                    color: Color(0xFF8C8278),
                    fontSize: 7,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _orderSummaryCard() {
    return _sideCard(
      title: 'Order summary',
      trailing: '${order.resolvedItems.length} '
          '${order.resolvedItems.length == 1 ? 'item' : 'items'}',
      child: Column(
        children: [
          _summaryRow('Order ID', order.orderNumber),
          const SizedBox(height: 11),
          _summaryRow(
            'Payment method',
            order.paymentMethod,
          ),
          const SizedBox(height: 13),
          const Divider(
            height: 1,
            color: Color(0xFFEEE7DE),
          ),
          const SizedBox(height: 13),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Shipping address',
              style: _mutedLabelStyle,
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              order.buyerName,
              style: const TextStyle(
                color: Color(0xFF49423B),
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 3),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              order.deliveryAddress,
              style: const TextStyle(
                color: Color(0xFF847A70),
                fontSize: 8,
                height: 1.4,
              ),
            ),
          ),
          if (order.buyerPhone.trim().isNotEmpty) ...[
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                order.buyerPhone,
                style: const TextStyle(
                  color: Color(0xFF9C9186),
                  fontSize: 7.5,
                ),
              ),
            ),
          ],
          const SizedBox(height: 13),
          const Divider(
            height: 1,
            color: Color(0xFFEEE7DE),
          ),
          const SizedBox(height: 13),
          _summaryRow(
            'Subtotal',
            _peso(order.resolvedSubtotal),
          ),
          const SizedBox(height: 9),
          _summaryRow(
            'Delivery fee',
            _peso(order.deliveryFee),
          ),
          const SizedBox(height: 13),
          const Divider(
            height: 1,
            color: Color(0xFFEEE7DE),
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Total amount',
                  style: TextStyle(
                    color: Color(0xFF39332D),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                _peso(order.resolvedTotal),
                style: const TextStyle(
                  color: _goldDark,
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _courierCard(BuildContext context) {
    return _sideCard(
      title: 'Courier details',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4DD),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.local_shipping_outlined,
                  color: _goldDark,
                  size: 19,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  order.courierName.trim().isEmpty
                      ? 'Waiting for assignment'
                      : order.courierName,
                  style: const TextStyle(
                    color: Color(0xFF3D3630),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (order.courierEmail.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF8F4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'COURIER CONTACT',
                    style: TextStyle(
                      color: Color(0xFF9A9086),
                      fontSize: 6.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: .7,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    order.courierEmail,
                    style: const TextStyle(
                      color: Color(0xFF59514A),
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFAF1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFEFE3CD),
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Map preview only',
                  style: TextStyle(
                    color: Color(0xFF8D631C),
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Courier movement on the map is an interface animation, not live location data.',
                  style: TextStyle(
                    color: Color(0xFF9B8664),
                    fontSize: 7,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: onMessageSeller ??
                () => Navigator.push<void>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BuyerMessages(
                          initialSellerId: order.sellerAccountId,
                        ),
                      ),
                    ),
            icon: const Icon(
              Icons.chat_bubble_outline,
              size: 15,
            ),
            label: const Text(
              'Message Seller',
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sideCard({
    required String title,
    String? trailing,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D2C2721),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF322C27),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if ((trailing ?? '').isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBF7EF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    trailing!,
                    style: const TextStyle(
                      color: Color(0xFF8B8177),
                      fontSize: 7,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(
            height: 1,
            color: Color(0xFFEEE7DE),
          ),
          const SizedBox(height: 13),
          child,
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: _mutedLabelStyle,
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Color(0xFF403932),
              fontSize: 8.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  TextStyle get _mutedLabelStyle => const TextStyle(
        color: Color(0xFF968C82),
        fontSize: 8,
      );

  Widget _itemsCard() {
    final items = order.resolvedItems;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F2C2721),
            blurRadius: 30,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ITEMS IN THIS ORDER',
                      style: TextStyle(
                        color: Color(0xFF978D82),
                        fontSize: 7,
                        fontWeight: FontWeight.w700,
                        letterSpacing: .7,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${items.length} ${items.length == 1 ? 'item' : 'items'}',
                      style: const TextStyle(
                        color: Color(0xFF342E28),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${order.paymentMethod} · ${_titleCase(order.paymentStatus)}',
                style: const TextStyle(
                  color: Color(0xFF91867B),
                  fontSize: 7.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(
            height: 1,
            color: Color(0xFFEEE7DD),
          ),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 26),
              child: Text(
                'No order items found.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF958B80),
                  fontSize: 8,
                ),
              ),
            )
          else
            ...items.map(_itemRow),
        ],
      ),
    );
  }

  Widget _itemRow(BuyerOrderItem item) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFEEE7DD),
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFFAF8F4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFEEE7DE),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: _itemImage(item.image),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF4B443D),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.variantLabel} • Qty ${item.quantity}',
                  style: const TextStyle(
                    color: Color(0xFF92887C),
                    fontSize: 7.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            _peso(item.lineTotal),
            style: const TextStyle(
              color: Color(0xFF342E28),
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemImage(String? source) {
    final value = source?.trim() ?? '';

    if (value.isEmpty) {
      return const Icon(
        Icons.inventory_2_outlined,
        color: Color(0xFFAA9F93),
        size: 21,
      );
    }

    final network = value.startsWith('http://') ||
        value.startsWith('https://') ||
        value.startsWith('//');

    if (network) {
      return Image.network(
        value.startsWith('//') ? 'https:$value' : value,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(
          Icons.inventory_2_outlined,
          color: Color(0xFFAA9F93),
          size: 21,
        ),
      );
    }

    return Image.asset(
      value,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const Icon(
        Icons.inventory_2_outlined,
        color: Color(0xFFAA9F93),
        size: 21,
      ),
    );
  }

  Widget _deliveryReminder() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFAF1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFEFE2CA),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.verified_user_outlined,
            color: _goldDark,
            size: 24,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Delivery reminder',
                  style: TextStyle(
                    color: Color(0xFF5A4B32),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Please inspect your order upon delivery. If there are any issues, contact the seller through Messages.',
                  style: TextStyle(
                    color: Color(0xFF8C795A),
                    fontSize: 7.5,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<_TimelineStep> _timelineSteps() {
    return [
      _TimelineStep(
        label: 'Order placed',
        description:
            'Your order was successfully submitted to the seller.',
        time: order.createdAt,
      ),
      _TimelineStep(
        label: 'Seller preparing order',
        description:
            'The seller is packing and preparing your items.',
        time: order.trackingStatusIndex >= 2
            ? order.latestUpdateTime
            : '',
      ),
      _TimelineStep(
        label: 'Ready for pickup',
        description:
            'Your parcel is packed and waiting for courier pickup.',
        time: order.readyAt,
      ),
      _TimelineStep(
        label: 'Courier assigned',
        description: order.courierName.trim().isNotEmpty &&
                order.courierName != 'Pending assignment'
            ? '${order.courierName} accepted your delivery.'
            : 'Waiting for a courier to accept the delivery request.',
        time: order.acceptedAt,
      ),
      _TimelineStep(
        label: 'Parcel in transit',
        description:
            'The courier has picked up your parcel and is heading to you.',
        time: order.pickedUpAt,
      ),
      _TimelineStep(
        label: 'Courier arrived',
        description:
            'The courier reached your delivery location.',
        time: order.arrivedBuyerAt,
      ),
      _TimelineStep(
        label: 'Delivered',
        description:
            'Your order has been delivered successfully.',
        time: order.deliveredAt,
      ),
    ];
  }

  String _peso(double value) {
    return '₱${value.toStringAsFixed(2)}';
  }

  String _titleCase(String value) {
    return value
        .replaceAll('_', ' ')
        .split(' ')
        .where((word) => word.isNotEmpty)
        .map(
          (word) =>
              '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  void _toast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _TimelineStep {
  final String label;
  final String description;
  final String time;

  const _TimelineStep({
    required this.label,
    required this.description,
    required this.time,
  });
}

class _DeliveryRoutePainter extends CustomPainter {
  final double progress;

  const _DeliveryRoutePainter({
    required this.progress,
  });

  static const Color road = Color(0xFFDEDAD3);
  static const Color roadCenter = Color(0xFFF8F6F2);
  static const Color gold = Color(0xFFD79A2B);

  @override
  void paint(Canvas canvas, Size size) {
    final background = Paint()
      ..color = const Color(0xFFF4F2ED);

    canvas.drawRect(
      Offset.zero & size,
      background,
    );

    final green = Paint()
      ..color = const Color(0xFFE7ECDf);

    canvas.drawOval(
      Rect.fromLTWH(
        size.width * .05,
        size.height * .15,
        size.width * .25,
        size.height * .22,
      ),
      green,
    );

    canvas.drawOval(
      Rect.fromLTWH(
        size.width * .66,
        size.height * .13,
        size.width * .25,
        size.height * .2,
      ),
      green,
    );

    final roadPaint = Paint()
      ..color = road
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final roadCenterPaint = Paint()
      ..color = roadCenter
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final road1 = Path()
      ..moveTo(-20, size.height * .25)
      ..cubicTo(
        size.width * .25,
        size.height * .1,
        size.width * .55,
        size.height * .4,
        size.width + 20,
        size.height * .16,
      );

    final road2 = Path()
      ..moveTo(-20, size.height * .82)
      ..cubicTo(
        size.width * .25,
        size.height * .65,
        size.width * .6,
        size.height * .95,
        size.width + 20,
        size.height * .63,
      );

    final road3 = Path()
      ..moveTo(size.width * .28, -20)
      ..cubicTo(
        size.width * .3,
        size.height * .25,
        size.width * .42,
        size.height * .55,
        size.width * .44,
        size.height + 20,
      );

    final road4 = Path()
      ..moveTo(size.width * .72, -20)
      ..cubicTo(
        size.width * .62,
        size.height * .35,
        size.width * .66,
        size.height * .62,
        size.width * .76,
        size.height + 20,
      );

    for (final path in [road1, road2, road3, road4]) {
      canvas.drawPath(path, roadPaint);
      canvas.drawPath(path, roadCenterPaint);
    }

    final route = Path()
      ..moveTo(size.width * .18, size.height * .79)
      ..cubicTo(
        size.width * .32,
        size.height * .68,
        size.width * .36,
        size.height * .52,
        size.width * .48,
        size.height * .45,
      )
      ..cubicTo(
        size.width * .62,
        size.height * .37,
        size.width * .67,
        size.height * .25,
        size.width * .79,
        size.height * .2,
      );

    final routeBase = Paint()
      ..color = const Color(0xFFEADFCA)
      ..strokeWidth = 11
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawPath(route, routeBase);

    final metrics = route.computeMetrics().toList();

    if (metrics.isNotEmpty) {
      final metric = metrics.first;
      final double clamped = progress.clamp(0.0, 1.0).toDouble();
      final length = metric.length * clamped;

      if (length > 0) {
        final partial = metric.extractPath(0, length);
        final routeProgressPaint = Paint()
          ..color = gold
          ..strokeWidth = 6
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;

        canvas.drawPath(
          partial,
          routeProgressPaint,
        );
      }

      final double courierDistance = metric.length * clamped;
      final double safeCourierDistance = courierDistance
          .clamp(
            0.0,
            math.max(0.0, metric.length - .01),
          )
          .toDouble();
      final tangent = metric.getTangentForOffset(
        safeCourierDistance,
      );

      if (tangent != null) {
        final position = tangent.position;

        canvas.drawCircle(
          position,
          15,
          Paint()..color = Colors.white,
        );

        canvas.drawCircle(
          position,
          11,
          Paint()..color = gold,
        );

        final iconPainter = TextPainter(
          text: const TextSpan(
            text: '🚚',
            style: TextStyle(fontSize: 13),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        iconPainter.paint(
          canvas,
          position -
              Offset(
                iconPainter.width / 2,
                iconPainter.height / 2,
              ),
        );
      }
    }

    final start = Offset(
      size.width * .18,
      size.height * .79,
    );

    canvas.drawCircle(
      start,
      18,
      Paint()..color = Colors.white,
    );

    canvas.drawCircle(
      start,
      13,
      Paint()..color = const Color(0xFF2F2B27),
    );

    final destination = Offset(
      size.width * .79,
      size.height * .2,
    );

    canvas.drawCircle(
      destination,
      18,
      Paint()..color = Colors.white,
    );

    canvas.drawCircle(
      destination,
      13,
      Paint()..color = const Color(0xFFFFF4D9),
    );

    canvas.drawCircle(
      destination,
      5,
      Paint()..color = const Color(0xFFC98B1C),
    );

    _label(
      canvas,
      'Sorting Center',
      start + const Offset(-30, 23),
    );

    _label(
      canvas,
      'Delivery Area',
      destination + const Offset(16, 3),
    );
  }

  void _label(Canvas canvas, String text, Offset offset) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Color(0xFF6F675F),
          fontSize: 8,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(
    covariant _DeliveryRoutePainter oldDelegate,
  ) {
    return oldDelegate.progress != progress;
  }
}
