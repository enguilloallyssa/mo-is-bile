import 'package:flutter/material.dart';

import 'models/rider_delivery_model.dart';

class RiderDeliveries extends StatelessWidget {
  final List<RiderDelivery> orders;
  final VoidCallback onOpenWorkflow;
  final VoidCallback onOpenHistory;

  const RiderDeliveries({
    super.key,
    required this.orders,
    required this.onOpenWorkflow,
    required this.onOpenHistory,
  });

  static const Color _blue = Color(0xFF3C6E91);
  static const Color _border = Color(0xFFEADFC9);

  @override
  Widget build(BuildContext context) {
    final active =
        orders.where((order) => order.isActiveDelivery).toList();

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
              'In Transit',
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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFDF8),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _border),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Active Deliveries',
                  style: TextStyle(
                    color: Color(0xFF211D17),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Packages already picked up from Sellers.',
                  style: TextStyle(
                    color: Color(0xFF817769),
                    fontSize: 8.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (active.isEmpty)
            _empty()
          else
            ...active.map(
              (order) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _card(order),
              ),
            ),
        ],
      ),
    );
  }

  Widget _card(RiderDelivery order) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F9FB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD2DFE9)),
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
                    Text(
                      order.orderNumber,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${order.buyerName} · ${order.buyerAddress}',
                      style: const TextStyle(
                        color: Color(0xFF72808C),
                        fontSize: 7.5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  order.statusLabel.toUpperCase(),
                  style: const TextStyle(
                    color: _blue,
                    fontSize: 6.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton(
              onPressed: onOpenWorkflow,
              style: ElevatedButton.styleFrom(
                backgroundColor: _blue,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: const Text(
                'Open Active Delivery',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _empty() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDDD2C1)),
      ),
      child: const Text(
        'No active in-transit delivery.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color(0xFF918677),
          fontSize: 9,
        ),
      ),
    );
  }
}
