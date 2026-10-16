import 'package:flutter/material.dart';

import 'models/buyer_order_model.dart';
import 'buyer_order_details.dart';

class BuyerShipping extends StatelessWidget {
  final List<BuyerOrder>? shipments;

  const BuyerShipping({
    super.key,
    this.shipments,
  });

  @override
  Widget build(BuildContext context) {
    final data = shipments ?? _demoShipments;

    return Scaffold(
      backgroundColor: const Color(0xFFFBFAF8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFDF9),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Shipping',
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
            const Text(
              'DELIVERY CENTER',
              style: TextStyle(
                color: Color(0xFFB47B1E),
                fontSize: 7.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Shipping',
              style: TextStyle(
                color: Color(0xFF201B17),
                fontSize: 27,
                height: 1.05,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Track parcels using the same order status used by Seller, Logistics, and Courier.',
              style: TextStyle(
                color: Color(0xFF8D8377),
                fontSize: 8.4,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 14),
            if (data.isEmpty)
              _emptyState(context)
            else
              ...data.map((order) => _shipmentCard(context, order)),
          ],
        ),
      ),
    );
  }

  Widget _shipmentCard(BuildContext context, BuyerOrder order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEBE3D8)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A342A1C),
            blurRadius: 26,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                            color: Color(0xFF2E2923),
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        _statusPill(order.statusLabel),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Text(
                      '${order.sellerName} · ${order.productNames.length} item${order.productNames.length == 1 ? '' : 's'} · ${_peso(order.totalAmount ?? 0)}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF81776C),
                        fontSize: 7.6,
                        height: 1.4,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.local_shipping_outlined,
                color: Color(0xFFB67813),
                size: 23,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Shipment progress',
                  style: TextStyle(
                    color: Color(0xFF91877C),
                    fontSize: 7.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '${order.progress}%',
                style: const TextStyle(
                  color: Color(0xFF91877C),
                  fontSize: 7.2,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: order.progress / 100,
              minHeight: 7,
              backgroundColor: const Color(0xFFEEE8DF),
              valueColor: const AlwaysStoppedAnimation(Color(0xFFD99A18)),
            ),
          ),
          const SizedBox(height: 13),
          LayoutBuilder(
            builder: (context, constraints) {
              final horizontal = constraints.maxWidth >= 480;
              final courier = _infoBox(
                label: 'Courier',
                value: order.courierName.trim().isEmpty
                    ? 'Waiting for assignment'
                    : order.courierName,
              );
              final address = _infoBox(
                label: 'Delivery address',
                value: order.deliveryAddress.trim().isEmpty
                    ? 'Delivery address unavailable'
                    : order.deliveryAddress,
              );

              if (!horizontal) {
                return Column(
                  children: [
                    courier,
                    const SizedBox(height: 8),
                    address,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: courier),
                  const SizedBox(width: 8),
                  Expanded(flex: 2, child: address),
                ],
              );
            },
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () => Navigator.push<void>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BuyerOrderDetails(order: order),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD9930A),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11),
                      ),
                    ),
                    child: const Text(
                      'Track order',
                      style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: OutlinedButton(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${order.sellerName} shop will open from the product/shop flow.')),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF665C50),
                      side: const BorderSide(color: Color(0xFFDFD4C5)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11),
                      ),
                    ),
                    child: const Text(
                      'View seller',
                      style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoBox({required String label, required String value}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF8F4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: Color(0xFFA1988C),
              fontSize: 6.5,
              fontWeight: FontWeight.w800,
              letterSpacing: .5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF5F574F),
              fontSize: 8,
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusPill(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF2D6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFFA66F0F),
          fontSize: 6.5,
          fontWeight: FontWeight.w800,
          letterSpacing: .4,
        ),
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 48),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDDD2C4)),
      ),
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4DC),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.local_shipping_outlined,
              color: Color(0xFFB67813),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'No shipments yet',
            style: TextStyle(
              color: Color(0xFF38312A),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Orders appear here once they reach the shipping workflow.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF8C8378), fontSize: 8),
          ),
          const SizedBox(height: 13),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD9930A),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text('Shop products', style: TextStyle(fontSize: 8)),
          ),
        ],
      ),
    );
  }

  String _peso(double value) => '₱${value.toStringAsFixed(2)}';

  static const List<BuyerOrder> _demoShipments = [
    BuyerOrder(
      id: 1,
      orderNumber: 'SARI-2026-0001',
      status: 'in_transit',
      paymentMethod: 'COD',
      totalAmount: 1308,
      subtotal: 1228,
      deliveryFee: 80,
      createdAt: 'Oct 15, 2026 • 10:30 AM',
      expectedDelivery: 'Oct 16, 2026',
      latestUpdateTime: 'Today • 11:20 AM',
      latestUpdateMessage: 'Your parcel is on the way.',
      courierName: 'Juan Dela Cruz',
      courierEmail: 'juan@sari.test',
      courierRating: 4.9,
      courierDeliveries: 120,
      deliveryAddress: '123 Rizal St., Brgy. San Isidro, Lucena City, Quezon',
      sellerName: 'SARI Tech Corner',
      sellerAccountId: 101,
      productNames: ['Everyday Wireless Earbuds', 'Compact Wireless Mouse'],
    ),
    BuyerOrder(
      id: 2,
      orderNumber: 'SARI-2026-0002',
      status: 'ready_for_pickup',
      paymentMethod: 'COD',
      totalAmount: 699,
      subtotal: 619,
      deliveryFee: 80,
      createdAt: 'Oct 15, 2026 • 09:15 AM',
      expectedDelivery: 'Oct 17, 2026',
      latestUpdateTime: 'Today • 10:05 AM',
      latestUpdateMessage: 'The seller packed your order.',
      courierName: 'Waiting for assignment',
      courierRating: 0,
      courierDeliveries: 0,
      deliveryAddress: '123 Rizal St., Brgy. San Isidro, Lucena City, Quezon',
      sellerName: 'Glow & Go',
      sellerAccountId: 202,
      productNames: ['Daily Skin Essentials Set'],
    ),
  ];
}
