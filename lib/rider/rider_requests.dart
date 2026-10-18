import 'package:flutter/material.dart';

import 'models/rider_delivery_model.dart';

class RiderRequests extends StatelessWidget {
  final RiderDelivery? activeOrder;
  final List<RiderDelivery> orders;
  final VoidCallback onOpenWorkflow;
  final VoidCallback onOpenPickups;

  const RiderRequests({
    super.key,
    required this.activeOrder,
    required this.orders,
    required this.onOpenWorkflow,
    required this.onOpenPickups,
  });

  static const Color _gold = Color(0xFFD99600);
  static const Color _blue = Color(0xFF3C6E91);
  static const Color _border = Color(0xFFEADFC9);

  @override
  Widget build(BuildContext context) {
    final visibleOrders =
        orders.where((order) => order.status != 'delivered').toList();
    final visibleActive =
        activeOrder != null && activeOrder!.status != 'delivered'
            ? activeOrder
            : null;

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
              'My Assignments',
              style: TextStyle(
                color: Color(0xFF211D17),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Dispatched by SARI Logistics',
              style: TextStyle(
                color: Color(0xFF918677),
                fontSize: 8,
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: onOpenPickups,
            icon: const Icon(Icons.inventory_2_outlined, size: 16),
            label: const Text(
              'Pickups',
              style: TextStyle(fontSize: 8),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        color: _gold,
        onRefresh: () async {
          await Future<void>.delayed(const Duration(milliseconds: 350));
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12, 14, 12, 24),
          children: [
            _intro(),
            if (visibleActive != null) ...[
              const SizedBox(height: 12),
              _activeAssignment(visibleActive),
            ],
            const SizedBox(height: 14),
            if (visibleOrders.isEmpty)
              _emptyState()
            else
              ...visibleOrders.map(
                (order) => Padding(
                  padding: const EdgeInsets.only(bottom: 11),
                  child: _assignmentCard(order),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _intro() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _border),
            ),
            child: const Text(
              'LOGISTICS DISPATCH',
              style: TextStyle(
                color: Color(0xFF8A7F70),
                fontSize: 7,
                fontWeight: FontWeight.w800,
                letterSpacing: .8,
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Assigned delivery jobs',
            style: TextStyle(
              color: Color(0xFF211D17),
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Riders no longer self-accept public delivery requests. SARI Logistics assigns one active job at a time.',
            style: TextStyle(
              color: Color(0xFF817769),
              fontSize: 8.5,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _activeAssignment(RiderDelivery order) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F8FB),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFD2DFE9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current assignment: ${order.orderNumber}',
            style: const TextStyle(
              color: _blue,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            order.statusLabel,
            style: const TextStyle(
              color: Color(0xFF6F8190),
              fontSize: 7.5,
            ),
          ),
          const SizedBox(height: 9),
          ElevatedButton(
            onPressed: onOpenWorkflow,
            style: ElevatedButton.styleFrom(
              backgroundColor: _blue,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text(
              'Open Delivery Workflow',
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

  Widget _assignmentCard(RiderDelivery order) {
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
                        color: Color(0xFF29241E),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      order.sellerName,
                      style: const TextStyle(
                        color: Color(0xFF918677),
                        fontSize: 7.5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF6E1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _border),
                ),
                child: const Text(
                  'ASSIGNED',
                  style: TextStyle(
                    color: Color(0xFFA56B00),
                    fontSize: 6.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _locationCard(
                  'PICKUP',
                  order.pickupName,
                  order.pickupAddress,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _locationCard(
                  'BUYER',
                  order.buyerName,
                  order.buyerAddress,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFEEE5D6)),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                _peso(order.deliveryFee),
                style: const TextStyle(
                  color: Color(0xFF29241E),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: onOpenWorkflow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _gold,
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
                child: const Text(
                  'Start Workflow',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _locationCard(String label, String name, String address) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: const Color(0xFFEEE5D6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFA09484),
              fontSize: 6.5,
              fontWeight: FontWeight.w700,
              letterSpacing: .7,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: const TextStyle(
              color: Color(0xFF2A251F),
              fontSize: 8.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            address.isEmpty ? 'Address unavailable' : address,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF8A8073),
              fontSize: 6.5,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      padding: const EdgeInsets.all(34),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDCD2C3)),
      ),
      child: const Column(
        children: [
          Text(
            'No Logistics assignment yet.',
            style: TextStyle(
              color: Color(0xFF51483D),
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'When Logistics assigns an order to you, it will appear here automatically.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF918677),
              fontSize: 8,
            ),
          ),
        ],
      ),
    );
  }

  String _peso(double value) => '₱${value.toStringAsFixed(2)}';
}
