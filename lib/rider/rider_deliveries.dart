import 'package:flutter/material.dart';

import 'models/rider_delivery_model.dart';
import 'widgets/rider_map.dart';

class RiderDeliveries extends StatelessWidget {
  final List<RiderDelivery> orders;
  final ValueChanged<RiderDelivery> onAdvanceDelivery;
  final VoidCallback onOpenWorkflow;
  final VoidCallback onOpenHistory;

  const RiderDeliveries({
    super.key,
    required this.orders,
    required this.onAdvanceDelivery,
    required this.onOpenWorkflow,
    required this.onOpenHistory,
  });

  static const Color _blue = Color(0xFF3C6E91);
  static const Color _green = Color(0xFF4F7D63);
  static const Color _border = Color(0xFFEADFC9);

  @override
  Widget build(BuildContext context) {
    final active = orders.where((order) => order.isActiveDelivery).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFBF8F1),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFFFFDF8),
        surfaceTintColor: Colors.transparent,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Active Deliveries',
              style: TextStyle(
                color: Color(0xFF211D17),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Map & Delivery Workflow',
              style: TextStyle(
                color: Color(0xFF918677),
                fontSize: 8,
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: onOpenHistory,
            icon: const Icon(Icons.history, size: 16),
            label: const Text(
              'History',
              style: TextStyle(fontSize: 8),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFDF8),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _border),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Delivery Route',
                  style: TextStyle(
                    color: Color(0xFF211D17),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'After confirming Seller pickup, the active delivery and Buyer map appear here.',
                  style: TextStyle(
                    color: Color(0xFF817769),
                    fontSize: 8,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (active.isEmpty)
            _empty()
          else ...[
            RiderMap(
              delivery: active.first,
              height: 300,
            ),
            const SizedBox(height: 12),
            ...active.map(
              (order) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _card(order),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _card(RiderDelivery order) {
    final accent =
        order.status == 'arrived_buyer' ? _green : _blue;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F9FB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD2DFE9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.orderNumber,
                      style: const TextStyle(
                        color: Color(0xFF211D17),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      order.buyerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF514A42),
                        fontSize: 8.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      order.buyerAddress,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF72808C),
                        fontSize: 7,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  order.statusLabel.toUpperCase(),
                  style: TextStyle(
                    color: accent,
                    fontSize: 6,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          Text(
            order.actionMessage,
            style: TextStyle(
              color: accent,
              fontSize: 7.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 9),
          ElevatedButton(
            onPressed: order.nextStatus == null
                ? null
                : () => onAdvanceDelivery(order),
            style: ElevatedButton.styleFrom(
              backgroundColor: accent,
              foregroundColor: Colors.white,
              elevation: 0,
              minimumSize: const Size.fromHeight(42),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(11),
              ),
            ),
            child: Text(
              order.actionLabel,
              style: const TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 6),
          TextButton(
            onPressed: onOpenWorkflow,
            child: const Text(
              'Open full workflow',
              style: TextStyle(fontSize: 7.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _empty() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 32,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDDD2C1)),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.route_outlined,
            color: Color(0xFF9B9185),
            size: 30,
          ),
          SizedBox(height: 9),
          Text(
            'No package is in transit yet.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF51483D),
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Go to Home or Pickups and confirm the Seller handoff first.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF918677),
              fontSize: 7.5,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
