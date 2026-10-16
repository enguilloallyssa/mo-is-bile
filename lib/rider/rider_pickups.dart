import 'package:flutter/material.dart';

import 'models/rider_delivery_model.dart';

class RiderPickups extends StatelessWidget {
  final List<RiderDelivery> orders;
  final VoidCallback onOpenWorkflow;

  const RiderPickups({
    super.key,
    required this.orders,
    required this.onOpenWorkflow,
  });

  static const Color _gold = Color(0xFFD99600);
  static const Color _border = Color(0xFFEADFC9);

  @override
  Widget build(BuildContext context) {
    final pickupOrders =
        orders.where((order) => order.isPickupStage).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFBF8F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFDF8),
        surfaceTintColor: Colors.transparent,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pick Up Orders',
              style: TextStyle(
                color: Color(0xFF211D17),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Seller Pickup Queue',
              style: TextStyle(
                color: Color(0xFF918677),
                fontSize: 8,
              ),
            ),
          ],
        ),
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
                  'Pick Up Orders',
                  style: TextStyle(
                    color: Color(0xFF211D17),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Accepted orders that are still in the Seller pickup stage.',
                  style: TextStyle(
                    color: Color(0xFF817769),
                    fontSize: 8.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (pickupOrders.isEmpty)
            _empty()
          else
            ...pickupOrders.map(
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
        color: const Color(0xFFFFFDF8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
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
                      order.pickupName,
                      style: const TextStyle(
                        color: Color(0xFF918677),
                        fontSize: 7.5,
                      ),
                    ),
                  ],
                ),
              ),
              _status(order.statusLabel),
            ],
          ),
          const SizedBox(height: 11),
          Text(
            order.pickupAddress.isEmpty
                ? 'Pickup address unavailable'
                : order.pickupAddress,
            style: const TextStyle(
              color: Color(0xFF817769),
              fontSize: 8,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 11),
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton(
              onPressed: onOpenWorkflow,
              style: ElevatedButton.styleFrom(
                backgroundColor: _gold,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: const Text(
                'Open Delivery',
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

  Widget _status(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF2D8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        value.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFFA56B00),
          fontSize: 6.5,
          fontWeight: FontWeight.w800,
        ),
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
        'No pickup-stage orders.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color(0xFF918677),
          fontSize: 9,
        ),
      ),
    );
  }
}
