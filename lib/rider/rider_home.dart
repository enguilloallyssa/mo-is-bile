
import 'package:flutter/material.dart';

import 'models/rider_delivery_model.dart';
import 'models/rider_profile_model.dart';
import 'widgets/rider_ui.dart';

class RiderHome extends StatelessWidget {
  final RiderDelivery? currentDelivery;
  final List<RiderDelivery> assignments;
  final RiderProfile profile;
  final bool isDarkMode;
  final ValueChanged<bool> onDarkModeChanged;
  final ValueChanged<int>? onTabChanged;
  final ValueChanged<RiderDelivery> onAdvanceDelivery;
  final VoidCallback onOpenMessages;
  final VoidCallback onOpenHistory;
  final VoidCallback onOpenPickups;

  const RiderHome({
    super.key,
    required this.currentDelivery,
    required this.assignments,
    required this.profile,
    required this.isDarkMode,
    required this.onDarkModeChanged,
    required this.onAdvanceDelivery,
    required this.onOpenMessages,
    required this.onOpenHistory,
    required this.onOpenPickups,
    this.onTabChanged,
  });

  bool _isComplete(RiderDelivery order) {
    return order.status == 'completed' ||
        order.status == 'delivered';
  }

  bool _isPending(RiderDelivery order) {
    return order.status == 'pickup_assigned' ||
        order.status == 'delivery_assigned';
  }

  @override
  Widget build(BuildContext context) {
    final pickupOrders = assignments
        .where((order) => order.isPickupFlow)
        .toList();

    final deliveryOrders = assignments
        .where((order) => order.isDeliveryFlow)
        .toList();

    final completedOrders =
        assignments.where(_isComplete).toList();

    final pendingOrders =
        assignments.where(_isPending).toList();

    final totalEarnings = completedOrders.fold<double>(
      0,
      (sum, order) => sum + order.deliveryFee,
    );

    final current = currentDelivery ??
        (assignments.isEmpty
            ? null
            : assignments.first);

    return Scaffold(
      backgroundColor: RiderColors.bg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: RiderColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 16,
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: RiderColors.blueSoft,
              child: Icon(
                Icons.delivery_dining_rounded,
                color: RiderColors.blue,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rider Dashboard',
                    style: TextStyle(
                      color: RiderColors.text,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    profile.availabilityStatus == 'online'
                        ? 'Online • Ready for assignments'
                        : 'Offline • Rider account',
                    style: TextStyle(
                      color: RiderColors.muted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Toggle theme',
            onPressed: () =>
                onDarkModeChanged(!isDarkMode),
            icon: Icon(
              isDarkMode
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
              color: RiderColors.text,
            ),
          ),
          IconButton(
            tooltip: 'Messages',
            onPressed: onOpenMessages,
            icon: Icon(
              Icons.notifications_none_rounded,
              color: RiderColors.text,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // RiderShell currently supplies local data.
          // Server refresh requires a Rider API endpoint.
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            16, 18, 16, 32,
          ),
          children: [
            _welcomeCard(),
            const SizedBox(height: 20),

            _sectionTitle(
              'Pickup Overview',
              subtitle:
                  'Seller collection and hub handoff',
              onViewAll: onOpenPickups,
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _statCard(
                    'Assigned',
                    '${pickupOrders.length}',
                    Icons.inventory_2_outlined,
                    RiderColors.blue,
                    RiderColors.blueSoft,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _statCard(
                    'Pending',
                    '${pickupOrders.where(_isPending).length}',
                    Icons.schedule_rounded,
                    RiderColors.gold,
                    RiderColors.goldSoft,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            _overviewCard(
              title: 'Seller Pickups',
              description:
                  'Review collection jobs and parcel handoffs.',
              icon: Icons.storefront_outlined,
              buttonLabel: 'View Pickups',
              onPressed: onOpenPickups,
              accent: RiderColors.blue,
            ),

            const SizedBox(height: 24),

            _sectionTitle(
              'Last-Mile Overview',
              subtitle:
                  'Deliver parcels to customers',
              onViewAll: () => onTabChanged?.call(2),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _statCard(
                    'Deliveries',
                    '${deliveryOrders.length}',
                    Icons.local_shipping_outlined,
                    RiderColors.purple,
                    RiderColors.purpleSoft,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _statCard(
                    'Completed',
                    '${completedOrders.length}',
                    Icons.check_circle_outline,
                    RiderColors.green,
                    RiderColors.greenSoft,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            _overviewCard(
              title: 'Active Deliveries',
              description:
                  'Track delivery progress, scan parcels, and capture proof of delivery.',
              icon: Icons.route_outlined,
              buttonLabel: 'View Deliveries',
              onPressed: () => onTabChanged?.call(2),
              accent: RiderColors.gold,
            ),

            const SizedBox(height: 24),

            _sectionTitle(
              'Current Job',
              subtitle: 'Your next task',
            ),
            const SizedBox(height: 12),

            current == null
                ? _emptyJobCard()
                : _currentJobCard(current),

            const SizedBox(height: 24),

            _sectionTitle(
              'Today at a Glance',
              subtitle: 'Rider activity summary',
            ),
            const SizedBox(height: 12),

            _todayCard(
              pending: pendingOrders.length,
              completed: completedOrders.length,
              earnings: totalEarnings,
            ),

            const SizedBox(height: 16),

            _demoNotice(),

            const SizedBox(height: 24),

            _sectionTitle('Quick Access'),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _quickAction(
                    Icons.assignment_outlined,
                    'Assignments',
                    () => onTabChanged?.call(1),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _quickAction(
                    Icons.history_rounded,
                    'History',
                    onOpenHistory,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _quickAction(
                    Icons.chat_bubble_outline,
                    'Messages',
                    onOpenMessages,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _welcomeCard() {
    final online =
        profile.availabilityStatus == 'online';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: RiderColors.heroGradient,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.waving_hand_outlined,
                color: RiderColors.gold,
                size: 20,
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 4,
                      backgroundColor: online
                          ? const Color(0xFF81D8A1)
                          : Colors.orangeAccent,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      online ? 'ONLINE' : 'OFFLINE',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Welcome back, ${profile.firstName}!',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Manage your pickups, deliveries, '
            'and daily rider activities in one place.',
            style: TextStyle(
              color: Color(0xFFE3EAF0),
              fontSize: 12,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(
                Icons.two_wheeler_rounded,
                color: Colors.white,
                size: 17,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${profile.vehicleType} • ${profile.plateNumber}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(
    String title, {
    String? subtitle,
    VoidCallback? onViewAll,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: RiderColors.text,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: RiderColors.muted,
                    fontSize: 11,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (onViewAll != null)
          TextButton(
            onPressed: onViewAll,
            child: Text(
              'View All',
              style: TextStyle(
                color: RiderColors.blue,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _statCard(
    String label,
    String value,
    IconData icon,
    Color accent,
    Color soft,
  ) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: RiderColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: RiderColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: soft,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              icon,
              color: accent,
              size: 20,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: TextStyle(
              color: RiderColors.text,
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              color: RiderColors.muted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _overviewCard({
    required String title,
    required String description,
    required IconData icon,
    required String buttonLabel,
    required VoidCallback onPressed,
    required Color accent,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RiderColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: RiderColors.border),
      ),
      child: Row(
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: .13),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: accent),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: RiderColors.text,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: RiderColors.muted,
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: buttonLabel,
            onPressed: onPressed,
            icon: Icon(
              Icons.arrow_forward_ios_rounded,
              color: accent,
              size: 17,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyJobCard() {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 32,
        horizontal: 20,
      ),
      decoration: BoxDecoration(
        color: RiderColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: RiderColors.border),
      ),
      child: Column(
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 42,
            color: RiderColors.muted,
          ),
          const SizedBox(height: 12),
          Text(
            'No Current Job',
            style: TextStyle(
              color: RiderColors.text,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Your assigned pickup or delivery will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: RiderColors.muted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _currentJobCard(RiderDelivery order) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: RiderColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: RiderColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Order #${order.orderNumber}',
                  style: TextStyle(
                    color: RiderColors.text,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: RiderColors.goldSoft,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  order.statusLabel,
                  style: TextStyle(
                    color: RiderColors.goldDark,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _detailRow(
            Icons.qr_code_rounded,
            'Parcel',
            order.packageCode,
          ),
          const SizedBox(height: 10),
          _detailRow(
            Icons.storefront_outlined,
            'Seller',
            order.sellerName,
          ),
          const SizedBox(height: 10),
          _detailRow(
            Icons.location_on_outlined,
            'Destination',
            order.destinationAddress.isEmpty
                ? order.destinationName
                : order.destinationAddress,
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: order.workflowProgress.clamp(0.0, 1.0),
              minHeight: 7,
              backgroundColor: RiderColors.surfaceSoft,
              valueColor: AlwaysStoppedAnimation<Color>(
                RiderColors.gold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            order.actionMessage,
            style: TextStyle(
              color: RiderColors.muted,
              fontSize: 11,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                if (order.isPickupFlow) {
                  onOpenPickups();
                } else {
                  onTabChanged?.call(2);
                }
              },
              icon: const Icon(
                Icons.arrow_forward_rounded,
                size: 18,
              ),
              label: const Text('Open Workflow'),
              style: FilledButton.styleFrom(
                backgroundColor: RiderColors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: RiderColors.muted,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                color: RiderColors.text,
                fontSize: 12,
                height: 1.5,
              ),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: TextStyle(
                    color: RiderColors.muted,
                  ),
                ),
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _todayCard({
    required int pending,
    required int completed,
    required double earnings,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: RiderColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: RiderColors.border),
      ),
      child: Column(
        children: [
          _summaryRow(
            Icons.pending_actions_outlined,
            'Pending Assignments',
            '$pending',
            RiderColors.gold,
          ),
          Divider(
            height: 26,
            color: RiderColors.border,
          ),
          _summaryRow(
            Icons.task_alt_rounded,
            'Completed in Loaded Data',
            '$completed',
            RiderColors.green,
          ),
          Divider(
            height: 26,
            color: RiderColors.border,
          ),
          _summaryRow(
            Icons.account_balance_wallet_outlined,
            'Earnings in Loaded Data',
            '₱${earnings.toStringAsFixed(2)}',
            RiderColors.blue,
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
    IconData icon,
    String label,
    String value,
    Color accent,
  ) {
    return Row(
      children: [
        Icon(icon, color: accent, size: 21),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: RiderColors.muted,
              fontSize: 12,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: RiderColors.text,
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _quickAction(
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 6,
        ),
        decoration: BoxDecoration(
          color: RiderColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: RiderColors.border),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: RiderColors.blue,
              size: 23,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: RiderColors.text,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _demoNotice() {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: RiderColors.goldSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: RiderColors.gold.withValues(alpha: .25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: RiderColors.goldDark,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Preview data: Rider assignments and earnings '
              'are currently supplied by the Flutter app. '
              'Live updates require the Laravel Rider API.',
              style: TextStyle(
                color: RiderColors.text,
                fontSize: 11,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
