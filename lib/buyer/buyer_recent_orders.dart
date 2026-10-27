import 'package:flutter/material.dart';

import 'buyer_order_details.dart';
import 'models/buyer_order_model.dart';
import 'widgets/buyer_empty_state.dart';

class BuyerRecentOrders extends StatelessWidget {
  final List<BuyerOrder> orders;
  final VoidCallback? onBrowseProducts;
  final VoidCallback? onViewAllOrders;

  const BuyerRecentOrders({
    super.key,
    this.orders = _demoOrders,
    this.onBrowseProducts,
    this.onViewAllOrders,
  });

  static const List<BuyerOrder> _demoOrders = [
    BuyerOrder(
      id: 15,
      orderNumber: 'SARI-2026-0015',
      status: 'in_transit',
      paymentMethod: 'COD',
      totalAmount: 979,
      subtotal: 899,
      deliveryFee: 80,
      createdAt: 'Oct 27, 2026 · 8:12 AM',
      expectedDelivery: 'Oct 29, 2026',
      latestUpdateTime: 'Oct 27, 2026 · 10:35 AM',
      latestUpdateMessage: 'Your parcel is on the way.',
      courierName: 'Juan Dela Cruz',
      courierRating: 4.9,
      courierDeliveries: 120,
      deliveryAddress: 'San Isidro, Santa Cruz, Laguna',
      sellerName: 'SARI Tech Corner',
      sellerAccountId: 101,
      productNames: ['Everyday Wireless Earbuds'],
      items: [
        BuyerOrderItem(
          name: 'Everyday Wireless Earbuds',
          variantLabel: 'Black',
          quantity: 1,
          lineTotal: 899,
        ),
      ],
    ),
    BuyerOrder(
      id: 11,
      orderNumber: 'SARI-2026-0011',
      status: 'delivered',
      paymentMethod: 'COD',
      paymentStatus: 'paid',
      totalAmount: 429,
      subtotal: 349,
      deliveryFee: 80,
      createdAt: 'Oct 23, 2026 · 1:20 PM',
      expectedDelivery: 'Oct 25, 2026',
      latestUpdateTime: 'Oct 25, 2026 · 4:46 PM',
      latestUpdateMessage: 'Order delivered successfully.',
      courierName: 'Maria Santos',
      courierRating: 4.8,
      courierDeliveries: 86,
      deliveryAddress: 'San Isidro, Santa Cruz, Laguna',
      sellerName: 'Daily Finds',
      sellerAccountId: 202,
      productNames: ['Minimal Everyday Tote'],
      items: [
        BuyerOrderItem(
          name: 'Minimal Everyday Tote',
          variantLabel: 'Natural',
          quantity: 1,
          lineTotal: 349,
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final active = orders.where((order) {
      return order.status != 'delivered' && order.status != 'cancelled';
    }).length;
    final delivered = orders.where((order) => order.status == 'delivered').length;
    final cancelled = orders.where((order) => order.status == 'cancelled').length;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F1),
      appBar: AppBar(
        title: const Text('Recent Orders'),
        actions: [
          TextButton(
            onPressed: onViewAllOrders ?? () => Navigator.pop(context),
            child: const Text('View all'),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 28),
        children: [
          _header(),
          const SizedBox(height: 12),
          if (orders.isEmpty)
            BuyerEmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'No recent orders yet',
              message: 'Your latest purchases will appear here after checkout.',
              actionLabel: 'Browse Products',
              onAction: onBrowseProducts ?? () => Navigator.pop(context),
            )
          else ...[
            _stats(active, delivered, cancelled),
            const SizedBox(height: 12),
            ...orders.map((order) => _orderCard(context, order)),
          ],
        ],
      ),
    );
  }

  Widget _header() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF9EC), Color(0xFFFFEDC8)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE8CE9A)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SARI MARKETPLACE',
            style: TextStyle(
              color: Color(0xFFA76C0A),
              fontSize: 8,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Recent Orders',
            style: TextStyle(
              color: Color(0xFF211D17),
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Review your latest purchases and quickly open their delivery details.',
            style: TextStyle(
              color: Color(0xFF81786E),
              fontSize: 9.5,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _stats(int active, int delivered, int cancelled) {
    return Row(
      children: [
        Expanded(child: _stat('Recent', orders.length, const Color(0xFFB87910))),
        const SizedBox(width: 7),
        Expanded(child: _stat('Active', active, const Color(0xFF3C6E91))),
        const SizedBox(width: 7),
        Expanded(child: _stat('Delivered', delivered, const Color(0xFF2E8B57))),
        const SizedBox(width: 7),
        Expanded(child: _stat('Cancelled', cancelled, const Color(0xFFC54C4C))),
      ],
    );
  }

  Widget _stat(String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8E1D8)),
      ),
      child: Column(
        children: [
          Text(
            '$value',
            style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            style: const TextStyle(color: Color(0xFF81786E), fontSize: 7.2),
          ),
        ],
      ),
    );
  }

  Widget _orderCard(BuildContext context, BuyerOrder order) {
    final item = order.items.isEmpty ? null : order.items.first;
    final moreItems = order.items.length > 1 ? order.items.length - 1 : 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8E1D8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                        color: Color(0xFF312B25),
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${order.sellerName} · ${order.createdAt}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Color(0xFF8A8177), fontSize: 8),
                    ),
                  ],
                ),
              ),
              _status(order.statusLabel, _statusColor(order.status)),
            ],
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F1EA),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: item?.image == null
                    ? const Icon(Icons.inventory_2_outlined, color: Color(0xFFB58A45))
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(13),
                        child: Image.asset(item!.image!, fit: BoxFit.cover),
                      ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item?.name ?? 'Ordered product',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Qty ${item?.quantity ?? 1} · ${item?.variantLabel ?? 'Standard'}${moreItems > 0 ? ' · +$moreItems more' : ''}',
                      style: const TextStyle(color: Color(0xFF81786E), fontSize: 8.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              Expanded(
                child: Text(
                  '₱${(order.totalAmount ?? order.subtotal + order.deliveryFee).toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Color(0xFF9B650B),
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              OutlinedButton(
                onPressed: () => Navigator.push<void>(
                  context,
                  MaterialPageRoute(builder: (_) => BuyerOrderDetails(order: order)),
                ),
                child: const Text('View Order'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _status(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 7.5, fontWeight: FontWeight.w800),
      ),
    );
  }

  Color _statusColor(String status) {
    if (status == 'delivered') return const Color(0xFF2E8B57);
    if (status == 'cancelled') return const Color(0xFFC54C4C);
    if (status == 'new' || status == 'preparing' || status == 'ready_for_pickup') {
      return const Color(0xFFB87910);
    }
    return const Color(0xFF3C6E91);
  }
}
