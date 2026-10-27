import 'package:flutter/material.dart';

import 'buyer_notifications.dart';
import 'models/buyer_activity_model.dart';
import 'widgets/buyer_empty_state.dart';

class BuyerRecentActivity extends StatelessWidget {
  final List<BuyerActivity> activities;
  final VoidCallback? onBrowseProducts;

  const BuyerRecentActivity({
    super.key,
    this.activities = _demoActivities,
    this.onBrowseProducts,
  });

  static const List<BuyerActivity> _demoActivities = [
    BuyerActivity(
      id: 1,
      type: 'delivery',
      title: 'Parcel is on the way',
      message: 'Your courier has picked up the parcel and is heading to your area.',
      orderNumber: 'SARI-2026-0015',
      storeName: 'SARI Tech Corner',
      status: 'in_transit',
      createdAt: 'Oct 27, 2026 · 10:35 AM',
      orderId: 15,
    ),
    BuyerActivity(
      id: 2,
      type: 'order',
      title: 'Order is being prepared',
      message: 'The seller confirmed your order and started preparing the items.',
      orderNumber: 'SARI-2026-0016',
      storeName: 'Daily Finds',
      status: 'preparing',
      createdAt: 'Oct 27, 2026 · 8:12 AM',
      orderId: 16,
    ),
    BuyerActivity(
      id: 3,
      type: 'delivery',
      title: 'Order delivered',
      message: 'Your order was delivered successfully. Thank you for shopping with SARI.',
      orderNumber: 'SARI-2026-0011',
      storeName: 'Home & Local',
      status: 'delivered',
      createdAt: 'Oct 25, 2026 · 4:46 PM',
      orderId: 11,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F1),
      appBar: AppBar(
        title: const Text('Recent Activity'),
        actions: [
          TextButton(
            onPressed: () => Navigator.push<void>(
              context,
              MaterialPageRoute(builder: (_) => const BuyerNotifications()),
            ),
            child: const Text('Notifications'),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 28),
        children: [
          _pageHeader(),
          const SizedBox(height: 14),
          if (activities.isEmpty)
            BuyerEmptyState(
              icon: Icons.history_rounded,
              title: 'No recent activity yet',
              message:
                  'Order updates will appear here as your purchases move through fulfillment and delivery.',
              actionLabel: 'Browse Products',
              onAction: onBrowseProducts ?? () => Navigator.pop(context),
            )
          else
            _activityCard(context),
        ],
      ),
    );
  }

  Widget _pageHeader() {
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
            'Recent Activity',
            style: TextStyle(
              color: Color(0xFF211D17),
              fontSize: 25,
              height: 1.05,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Follow every important update from checkout to delivery.',
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

  Widget _activityCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE8E1D8)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Order Activity',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                  ),
                ),
                Text(
                  '${activities.length} updates',
                  style: const TextStyle(color: Color(0xFF8B8176), fontSize: 9),
                ),
              ],
            ),
          ),
          const Divider(),
          ...activities.asMap().entries.map((entry) {
            return Column(
              children: [
                _activityRow(context, entry.value),
                if (entry.key != activities.length - 1) const Divider(indent: 66),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _activityRow(BuildContext context, BuyerActivity activity) {
    final Color tone = activity.isDelivered
        ? const Color(0xFF2E8B57)
        : activity.isCancelled
            ? const Color(0xFFC54C4C)
            : activity.isShipping
                ? const Color(0xFF3C6E91)
                : const Color(0xFFB87910);

    final IconData icon = activity.isDelivered
        ? Icons.check_rounded
        : activity.isCancelled
            ? Icons.close_rounded
            : activity.isShipping
                ? Icons.local_shipping_outlined
                : Icons.shopping_bag_outlined;

    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: tone.withValues(alpha: .11),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: tone, size: 20),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: const TextStyle(
                    color: Color(0xFF312B25),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity.message,
                  style: const TextStyle(
                    color: Color(0xFF7C7369),
                    fontSize: 9,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 5,
                  children: [
                    _meta(activity.orderNumber),
                    _meta(activity.storeName),
                    _meta(activity.status.replaceAll('_', ' ')),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        activity.createdAt,
                        style: const TextStyle(
                          color: Color(0xFF9A9187),
                          fontSize: 8,
                        ),
                      ),
                    ),
                    if (activity.orderId != null)
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('View order ›'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _meta(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F4EF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        value,
        style: const TextStyle(
          color: Color(0xFF756B60),
          fontSize: 7.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
