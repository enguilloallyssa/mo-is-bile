import 'package:flutter/material.dart';

import 'models/rider_delivery_model.dart';
import 'widgets/rider_map.dart';

class RiderHome extends StatelessWidget {
  final RiderDelivery? currentDelivery;
  final List<RiderDelivery> assignments;
  final ValueChanged<int>? onTabChanged;
  final ValueChanged<RiderDelivery> onAdvanceDelivery;
  final VoidCallback onOpenMessages;

  const RiderHome({
    super.key,
    required this.currentDelivery,
    required this.assignments,
    required this.onAdvanceDelivery,
    required this.onOpenMessages,
    this.onTabChanged,
  });

  static const Color _gold = Color(0xFFD99600);
  static const Color _blue = Color(0xFF3C6E91);
  static const Color _green = Color(0xFF4F7D63);
  static const Color _purple = Color(0xFF715A86);
  static const Color _pageBg = Color(0xFFFBF8F1);
  static const Color _border = Color(0xFFEADFC9);

  int get _waitingCount =>
      assignments.where((order) => order.status == 'courier_accepted').length;

  int get _activeCount {
    final current = currentDelivery;
    if (current == null || current.status == 'delivered') return 0;
    return 1;
  }

  int get _completedToday =>
      currentDelivery?.status == 'delivered' ? 1 : 0;

  double get _earningsToday =>
      currentDelivery?.status == 'delivered'
          ? currentDelivery!.deliveryFee
          : 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFFFFDF8),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 16,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rider Dashboard',
              style: TextStyle(
                color: Color(0xFF211D17),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Logistics Assigned Deliveries',
              style: TextStyle(
                color: Color(0xFF918677),
                fontSize: 8,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Messages',
            onPressed: onOpenMessages,
            icon: const Icon(Icons.chat_bubble_outline),
          ),
          IconButton(
            tooltip: 'Profile',
            onPressed: () => onTabChanged?.call(4),
            icon: const Icon(Icons.person_outline),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _operationsHeader(),
            const SizedBox(height: 14),
            _statsGrid(),
            if (currentDelivery != null &&
                currentDelivery!.showDeliveryMap) ...[
              const SizedBox(height: 14),
              RiderMap(delivery: currentDelivery!),
            ],
            const SizedBox(height: 14),
            _currentDeliverySection(),
            const SizedBox(height: 14),
            _latestAssignments(),
          ],
        ),
      ),
    );
  }

  Widget _operationsHeader() {
    return Container(
      padding: const EdgeInsets.only(bottom: 15),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 7,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text(
                'Rider Operations',
                style: TextStyle(
                  color: Color(0xFF211D17),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _border),
                ),
                child: const Text(
                  'Logistics Dispatch',
                  style: TextStyle(
                    color: Color(0xFF8A7F70),
                    fontSize: 7,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          const Text(
            'Delivery jobs are assigned by SARI Logistics. Confirm every pickup and delivery step here.',
            style: TextStyle(
              color: Color(0xFF817769),
              fontSize: 8.5,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 11),
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton(
              onPressed: () => onTabChanged?.call(1),
              style: ElevatedButton.styleFrom(
                backgroundColor: _gold,
                foregroundColor: Colors.white,
                elevation: 0,
                minimumSize: const Size(0, 42),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
              child: const Text(
                'View My Assignments →',
                style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statsGrid() {
    final stats = [
      ('Waiting to Start', '$_waitingCount', Icons.schedule_outlined,
          const Color(0xFFFFF2D8), const Color(0xFFBB7B00)),
      ('Active Deliveries', '$_activeCount', Icons.local_shipping_outlined,
          const Color(0xFFEAF2F7), _blue),
      ('Completed Today', '$_completedToday', Icons.task_alt_outlined,
          const Color(0xFFEAF3ED), _green),
      ("Today's Earnings", _peso(_earningsToday),
          Icons.account_balance_wallet_outlined,
          const Color(0xFFF0ECF6), _purple),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: stats.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 9,
        mainAxisSpacing: 9,
        mainAxisExtent: 122,
      ),
      itemBuilder: (context, index) {
        final stat = stats[index];
        return Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFDF8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: stat.$4,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(stat.$3, color: stat.$5, size: 18),
              ),
              const Spacer(),
              Text(
                stat.$1,
                style: const TextStyle(
                  color: Color(0xFF817769),
                  fontSize: 7.5,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                stat.$2,
                style: const TextStyle(
                  color: Color(0xFF201C16),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _currentDeliverySection() {
    final current = currentDelivery;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Delivery',
                  style: TextStyle(
                    color: Color(0xFF211D17),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'The Buyer, Seller, Logistics, and Rider all use this same MarketplaceOrder record.',
                  style: TextStyle(
                    color: Color(0xFF918677),
                    fontSize: 7.5,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: _border),
          if (current == null)
            _noActiveAssignment()
          else
            _currentDeliveryBody(current),
        ],
      ),
    );
  }

  Widget _currentDeliveryBody(RiderDelivery current) {
    return Padding(
      padding: const EdgeInsets.all(15),
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
                      current.orderNumber,
                      style: const TextStyle(
                        color: Color(0xFF201C16),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${current.pickupName} → ${current.buyerName}',
                      style: const TextStyle(
                        color: Color(0xFF817769),
                        fontSize: 8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _statusPill(current.statusLabel),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(color: _border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Delivery Fee',
                      style: TextStyle(
                        color: Color(0xFF918677),
                        fontSize: 6.5,
                      ),
                    ),
                    Text(
                      _peso(current.deliveryFee),
                      style: const TextStyle(
                        color: Color(0xFF201C16),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _stage(1, 'Picked Up', current.pickupDone,
                  !current.pickupDone, _gold)),
              const SizedBox(width: 7),
              Expanded(child: _stage(2, 'In Transit', current.transitDone,
                  current.status == 'in_transit', _blue)),
              const SizedBox(width: 7),
              Expanded(child: _stage(3, 'Delivered', current.deliveredDone,
                  false, _green)),
            ],
          ),
          const SizedBox(height: 14),
          _actionPanel(current),
        ],
      ),
    );
  }

  Widget _statusPill(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F7FB),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFD2DFE9)),
        ),
        child: Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: _blue,
            fontSize: 6.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _stage(
    int number,
    String label,
    bool complete,
    bool active,
    Color activeColor,
  ) {
    final color = complete
        ? _green
        : active
            ? activeColor
            : const Color(0xFFE5DDD1);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: BoxDecoration(
        color: complete
            ? const Color(0xFFEAF8EF)
            : active
                ? const Color(0xFFFFFAF0)
                : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: complete
              ? const Color(0xFFBDE0C9)
              : const Color(0xFFE5DDD1),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: complete
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : Text(
                    '$number',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF2D2822),
              fontSize: 7.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionPanel(RiderDelivery current) {
    if (current.status == 'delivered') {
      return Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F8F4),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFFCFE4D7)),
        ),
        child: const Text(
          'Delivery completed successfully.',
          style: TextStyle(
            color: _green,
            fontSize: 8.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    final accent = current.status == 'arrived_buyer'
        ? _green
        : const ['arrived_pickup', 'in_transit'].contains(current.status)
            ? _blue
            : _gold;

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            current.actionMessage,
            style: TextStyle(
              color: accent,
              fontSize: 8,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => onAdvanceDelivery(current),
            style: ElevatedButton.styleFrom(
              backgroundColor: accent,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: Text(
              current.actionLabel,
              style: const TextStyle(
                fontSize: 8.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _noActiveAssignment() {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          const Text(
            'No active assignment.',
            style: TextStyle(
              color: Color(0xFF51483D),
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'SARI Logistics will dispatch an eligible delivery to your account.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF918677),
              fontSize: 8,
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => onTabChanged?.call(1),
            style: ElevatedButton.styleFrom(
              backgroundColor: _gold,
              foregroundColor: Colors.white,
            ),
            child: const Text('Check Assignments'),
          ),
        ],
      ),
    );
  }

  Widget _latestAssignments() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'My Latest Assignments',
            style: TextStyle(
              color: Color(0xFF211D17),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          if (assignments.isEmpty)
            const Text(
              'No assigned jobs.',
              textAlign: TextAlign.center,
            )
          else
            ...assignments.map(
              (order) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.orderNumber,
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '${order.pickupName} → ${order.buyerName}',
                            style: const TextStyle(
                              color: Color(0xFF84796C),
                              fontSize: 6.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      order.statusLabel.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: order.status == 'delivered'
                            ? _green
                            : const Color(0xFFAA6D00),
                        fontSize: 5.8,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _peso(double value) => '₱${value.toStringAsFixed(2)}';
}
