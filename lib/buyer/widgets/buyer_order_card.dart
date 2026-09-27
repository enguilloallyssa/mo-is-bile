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

  static const Color gold = Color(0xFFD99A18);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFECE7DF)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F2C2721),
            blurRadius: 36,
            offset: Offset(0, 16),
          ),
          BoxShadow(
            color: Color(0x082C2721),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _orderTop(),
          _trackingSteps(),
          _orderInformation(),
          _actions(),
          if (order.isDelivered) _deliveredActions(),
        ],
      ),
    );
  }

  Widget _orderTop() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF5DC),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.shopping_bag_outlined,
                  color: Color(0xFFC7890B),
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
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
                            color: Color(0xFF202020),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        OutlinedButton(
                          onPressed: onCopy,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            foregroundColor: const Color(0xFF77736B),
                            side: const BorderSide(
                              color: Color(0xFFE7E0D5),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Copy',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Wrap(
                      spacing: 7,
                      runSpacing: 5,
                      children: [
                        _statusPill(),
                        Text(
                          'Placed ${order.createdAt}',
                          style: const TextStyle(
                            color: Color(0xFF929087),
                            fontSize: 8,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _statusMessage(),
            style: const TextStyle(
              color: Color(0xFF33312D),
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'Expected delivery: ${order.expectedDelivery}',
            style: const TextStyle(
              color: Color(0xFF77736B),
              fontSize: 8,
            ),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFEEE8DC)),
          const SizedBox(height: 13),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: _productPreview()),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.only(left: 14),
                decoration: const BoxDecoration(
                  border: Border(
                    left: BorderSide(color: Color(0xFFEEE8DC)),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'ORDER TOTAL',
                      style: TextStyle(
                        color: Color(0xFFAAA49A),
                        fontSize: 7,
                        fontWeight: FontWeight.w700,
                        letterSpacing: .7,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      order.totalAmount == null
                          ? 'See details'
                          : _peso(order.totalAmount!),
                      style: TextStyle(
                        color: order.totalAmount == null
                            ? const Color(0xFF77736B)
                            : const Color(0xFF26231F),
                        fontSize: order.totalAmount == null ? 9 : 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      order.paymentMethod.toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFF9A958C),
                        fontSize: 7,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _productPreview() {
    final names = order.productNames;
    final previewCount = names.length > 2 ? 2 : names.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ITEMS IN THIS ORDER',
          style: TextStyle(
            color: Color(0xFFAAA49A),
            fontSize: 7,
            fontWeight: FontWeight.w700,
            letterSpacing: .7,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            ...List.generate(
              previewCount,
              (index) => Container(
                width: 42,
                height: 42,
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  color: index == 0
                      ? const Color(0xFFFFFDF9)
                      : const Color(0xFFFAFAFA),
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(color: const Color(0xFFEEE8DC)),
                ),
                child: Icon(
                  index == 0
                      ? Icons.shopping_bag_outlined
                      : Icons.checkroom_outlined,
                  color: const Color(0xFF9B958B),
                  size: 20,
                ),
              ),
            ),
            if (names.length > 2)
              Container(
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFDF9),
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(color: const Color(0xFFD9D1C4)),
                ),
                child: Text(
                  '${names.length - 2}+',
                  style: const TextStyle(
                    color: Color(0xFF8A8479),
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                names.isEmpty
                    ? 'Your selected products'
                    : names.take(2).join(', '),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF4B4842),
                  fontSize: 8.5,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _trackingSteps() {
    const steps = [
      ('Order Placed', Icons.shopping_bag_outlined),
      ('Preparing', Icons.inventory_2_outlined),
      ('Courier Assigned', Icons.local_shipping_outlined),
      ('Out for Delivery', Icons.two_wheeler_outlined),
      ('Delivered', Icons.home_outlined),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 18, 10, 19),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFEEE8DC))),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: 470,
          child: Stack(
            children: [
              Positioned(
                top: 19,
                left: 42,
                right: 42,
                child: Container(
                  height: 2,
                  color: const Color(0xFFE9E2D6),
                ),
              ),
              Positioned(
                top: 19,
                left: 42,
                child: Container(
                  height: 2,
                  width: (order.statusStep / 4) * 386,
                  color: gold,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  steps.length,
                  (index) {
                    final complete = index <= order.statusStep;
                    final current = index == order.statusStep;

                    return SizedBox(
                      width: 82,
                      child: Column(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: complete ? gold : Colors.white,
                              border: Border.all(
                                color: complete
                                    ? gold
                                    : const Color(0xFFDDD6CA),
                                width: 2,
                              ),
                              boxShadow: current
                                  ? const [
                                      BoxShadow(
                                        color: Color(0x22D99A18),
                                        blurRadius: 0,
                                        spreadRadius: 6,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Icon(
                              complete ? Icons.check : steps[index].$2,
                              color: complete
                                  ? Colors.white
                                  : const Color(0xFFAAA49A),
                              size: 18,
                            ),
                          ),
                          const SizedBox(height: 9),
                          Text(
                            steps[index].$1,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: current
                                  ? const Color(0xFFC7890B)
                                  : const Color(0xFF69655D),
                              fontSize: 8,
                              height: 1.2,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _orderInformation() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFEEE8DC))),
      ),
      child: Column(
        children: [
          _infoBlock(
            title: 'LATEST UPDATE',
            icon: Icons.circle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.latestUpdateTime,
                  style: const TextStyle(
                    color: Color(0xFF34322F),
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  order.latestUpdateMessage,
                  style: const TextStyle(
                    color: Color(0xFF77736B),
                    fontSize: 8,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          _infoBlock(
            title: 'COURIER',
            icon: Icons.delivery_dining_outlined,
            child: Row(
              children: [
                Container(
                  width: 39,
                  height: 39,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFFF3D8),
                    border: Border.all(
                      color: const Color(0xFFFFFAF0),
                      width: 4,
                    ),
                  ),
                  child: Text(
                    _initials(order.courierName),
                    style: const TextStyle(
                      color: Color(0xFFC7890B),
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.courierName,
                        style: const TextStyle(
                          color: Color(0xFF282622),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '★ ${order.courierRating.toStringAsFixed(1)} • ${order.courierDeliveries} deliveries',
                        style: const TextStyle(
                          color: Color(0xFF817D75),
                          fontSize: 7.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _infoBlock(
            title: 'DELIVERY ADDRESS',
            icon: Icons.location_on_outlined,
            child: Text(
              order.deliveryAddress,
              style: const TextStyle(
                color: Color(0xFF625F58),
                fontSize: 8,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoBlock({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEEE8DC))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFA09B91),
              fontSize: 7,
              fontWeight: FontWeight.w700,
              letterSpacing: .8,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: const Color(0xFFC7890B), size: 17),
              const SizedBox(width: 8),
              Expanded(child: child),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actions() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: const Color(0xFFFFFEFA),
      child: Row(
        children: [
          Expanded(
            child: _actionButton(
              icon: Icons.chat_bubble_outline,
              label: 'Message',
              onTap: onMessageSeller,
              filled: false,
            ),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: _actionButton(
              icon: Icons.receipt_long_outlined,
              label: 'Details',
              onTap: onViewDetails,
              filled: false,
            ),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: _actionButton(
              icon: Icons.location_searching,
              label: 'Track',
              onTap: onTrackOrder,
              filled: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _deliveredActions() {
    final hasReturnRequest =
        (order.returnRequestStatus ?? '').trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      color: const Color(0xFFFFFEFA),
      child: hasReturnRequest
          ? Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFAF2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFEADFC9)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Return request: ${order.returnRequestStatus}',
                    style: const TextStyle(
                      color: Color(0xFF9A680B),
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    (order.returnSellerResponse ?? '').trim().isEmpty
                        ? 'Waiting for Seller review.'
                        : order.returnSellerResponse!,
                    style: const TextStyle(
                      color: Color(0xFF7D7468),
                      fontSize: 7,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            )
          : OutlinedButton.icon(
              onPressed: onReturnRequest,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFA96F06),
                side: const BorderSide(color: Color(0xFFE8DFD0)),
              ),
              icon: const Icon(Icons.assignment_return_outlined, size: 15),
              label: const Text(
                'Request Return / Refund',
                style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700),
              ),
            ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool filled,
  }) {
    return SizedBox(
      height: 40,
      child: filled
          ? ElevatedButton.icon(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFCF8E0D),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
              icon: Icon(icon, size: 15),
              label: Text(
                label,
                style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w700),
              ),
            )
          : OutlinedButton.icon(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFB87905),
                side: const BorderSide(color: Color(0xFFDCA62D)),
                padding: const EdgeInsets.symmetric(horizontal: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
              icon: Icon(icon, size: 15),
              label: Text(
                label,
                style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w700),
              ),
            ),
    );
  }

  Widget _statusPill() {
    final delivered = order.status == 'delivered';
    final cancelled = order.status == 'cancelled';

    final background = delivered
        ? const Color(0xFFF1F8EF)
        : cancelled
            ? const Color(0xFFFFF1F1)
            : const Color(0xFFFFF4D9);

    final foreground = delivered
        ? const Color(0xFF4C9361)
        : cancelled
            ? const Color(0xFFA65353)
            : const Color(0xFFAD7204);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(shape: BoxShape.circle, color: foreground),
          ),
          const SizedBox(width: 5),
          Text(
            order.statusLabel,
            style: TextStyle(
              color: foreground,
              fontSize: 7.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  String _statusMessage() {
    switch (order.status) {
      case 'new':
        return 'Your order has been placed.';
      case 'preparing':
      case 'ready_for_pickup':
        return 'Your order is being prepared.';
      case 'courier_accepted':
      case 'heading_pickup':
      case 'arrived_pickup':
        return 'A courier has been assigned to your order.';
      case 'in_transit':
      case 'arrived_buyer':
        return 'Your parcel is on the way.';
      case 'delivered':
        return 'Your order has been delivered.';
      case 'cancelled':
        return 'This order was cancelled.';
      default:
        return 'Your order is being processed.';
    }
  }

  String _peso(double value) => '₱${value.toStringAsFixed(2)}';

  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) return '—';
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
