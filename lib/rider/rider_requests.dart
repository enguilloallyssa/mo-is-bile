
import 'package:flutter/material.dart';

import 'models/rider_delivery_model.dart';
import 'widgets/rider_ui.dart';

class RiderRequests extends StatefulWidget {
  const RiderRequests({
    super.key,
    required this.activeOrder,
    required this.orders,
    required this.onAdvanceDelivery,
    required this.onOpenWorkflow,
    required this.onOpenPickups,
    required this.onOpenDelivery,
  });

  final RiderDelivery? activeOrder;
  final List<RiderDelivery> orders;
  final ValueChanged<RiderDelivery> onAdvanceDelivery;
  final VoidCallback onOpenWorkflow;
  final VoidCallback onOpenPickups;
  final VoidCallback onOpenDelivery;

  @override
  State<RiderRequests> createState() => _RiderRequestsState();
}

class _RiderRequestsState extends State<RiderRequests> {
  final TextEditingController _searchController =
      TextEditingController();

  String _filter = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<RiderDelivery> get _pickupQueue {
    final query = _searchController.text.trim().toLowerCase();

    return widget.orders.where((order) {
      if (order.isComplete || !order.isPickupFlow) {
        return false;
      }

      if (_filter == 'Assigned' &&
          order.status != 'pickup_assigned') {
        return false;
      }

      if (_filter == 'In Progress' &&
          order.status == 'pickup_assigned') {
        return false;
      }

      if (query.isEmpty) return true;

      return [
        order.orderNumber,
        order.packageCode,
        order.sellerName,
        order.pickupName,
        order.pickupAddress,
        order.sortingCenterName,
        order.sortingCenterAddress,
        order.statusLabel,
      ].any((value) => value.toLowerCase().contains(query));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final allPickups = widget.orders
        .where((order) =>
            order.isPickupFlow && !order.isComplete)
        .toList();

    final assigned = allPickups
        .where((order) => order.status == 'pickup_assigned')
        .length;

    final inProgress = allPickups.length - assigned;

    return Scaffold(
      backgroundColor: RiderColors.bg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: RiderColors.surface,
        foregroundColor: RiderColors.text,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 16,
        title: const RiderHeaderTitle(
          title: 'Pickup Assignments',
          subtitle: 'Dispatched by SARI Logistics',
        ),
        actions: [
          IconButton(
            tooltip: 'Last-Mile Deliveries',
            onPressed: widget.onOpenDelivery,
            icon: const Icon(
              Icons.local_shipping_outlined,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
        children: [
          _hero(),
          const SizedBox(height: 20),

          _summary(
            allPickups.length,
            assigned,
            inProgress,
          ),

          const SizedBox(height: 22),

          if (widget.activeOrder != null &&
              !widget.activeOrder!.isComplete &&
              widget.activeOrder!.isPickupFlow) ...[
            _sectionHeading(
              'Current Assignment',
              'Continue your assigned pickup workflow.',
              Icons.bolt_rounded,
            ),
            const SizedBox(height: 12),
            _currentAssignment(widget.activeOrder!),
            const SizedBox(height: 24),
          ],

          _sectionHeading(
            'Assigned Pickup Queue',
            'Seller pickups assigned by SARI Logistics.',
            Icons.assignment_outlined,
          ),

          const SizedBox(height: 14),

          _searchBar(),

          const SizedBox(height: 12),

          _filterBar(
            allPickups.length,
            assigned,
            inProgress,
          ),

          const SizedBox(height: 16),

          if (_pickupQueue.isEmpty)
            _emptyState()
          else
            ..._pickupQueue.map(
              (order) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _assignmentCard(order),
              ),
            ),

          const SizedBox(height: 14),

          _footer(_pickupQueue.length),

          const SizedBox(height: 16),

          _previewNotice(),
        ],
      ),
    );
  }

  Widget _hero() {
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
          const Row(
            children: [
              Icon(
                Icons.local_shipping_outlined,
                color: Colors.white70,
                size: 16,
              ),
              SizedBox(width: 8),
              Text(
                'SELLER PICKUP DISPATCH',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Pickup Assignments',
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Collect assigned Seller orders and '
            'continue to the next handoff.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: widget.onOpenDelivery,
            icon: const Icon(
              Icons.route_outlined,
              size: 18,
            ),
            label: const Text('Last-Mile Deliveries'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(
                color: Colors.white38,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summary(
    int total,
    int assigned,
    int inProgress,
  ) {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            'Total',
            total,
            Icons.inventory_2_outlined,
            RiderColors.blue,
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: _statCard(
            'Assigned',
            assigned,
            Icons.pending_actions_outlined,
            RiderColors.gold,
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: _statCard(
            'Ongoing',
            inProgress,
            Icons.local_shipping_outlined,
            RiderColors.green,
          ),
        ),
      ],
    );
  }

  Widget _statCard(
    String label,
    int value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 17,
        horizontal: 8,
      ),
      decoration: BoxDecoration(
        color: RiderColors.surface,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: RiderColors.border,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 22,
          ),
          const SizedBox(height: 10),
          Text(
            '$value',
            style: TextStyle(
              color: RiderColors.text,
              fontSize: 23,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              color: RiderColors.muted,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeading(
    String title,
    String subtitle,
    IconData icon,
  ) {
    return Row(
      children: [
        Container(
          height: 43,
          width: 43,
          decoration: BoxDecoration(
            color: RiderColors.blueSoft,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: RiderColors.blue,
            size: 21,
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: RiderColors.text,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(
                  color: RiderColors.muted,
                  fontSize: 11,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _currentAssignment(RiderDelivery order) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: RiderColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: RiderColors.blue.withValues(alpha: .35),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .06),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  order.orderNumber,
                  style: TextStyle(
                    color: RiderColors.text,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              _badge(
                order.statusLabel,
                RiderColors.blueSoft,
                RiderColors.blue,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Seller pickup • Handoff at origin hub',
            style: TextStyle(
              color: RiderColors.muted,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          _badge(
            'Seller Pickup',
            RiderColors.goldSoft,
            RiderColors.goldDark,
          ),
          if (order.status == 'in_transit') ...[
            const SizedBox(height: 13),
            _infoBox(
              'Pickup completed. Bring the parcel to '
              'the assigned origin hub for physical '
              'intake by SARI Logistics.',
            ),
          ],
          const SizedBox(height: 17),
          Divider(color: RiderColors.border),
          const SizedBox(height: 10),
          Text(
            'Review the current stage before continuing.',
            style: TextStyle(
              color: RiderColors.muted,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: widget.onOpenWorkflow,
              icon: const Icon(
                Icons.arrow_forward_rounded,
                size: 18,
              ),
              label: const Text(
                'Continue Pickup Workflow',
              ),
              style: FilledButton.styleFrom(
                backgroundColor: RiderColors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
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

  Widget _searchBar() {
    return TextField(
      controller: _searchController,
      onChanged: (_) => setState(() {}),
      style: TextStyle(
        color: RiderColors.text,
        fontSize: 13,
      ),
      decoration: InputDecoration(
        hintText: 'Search order, seller, parcel code...',
        hintStyle: TextStyle(
          color: RiderColors.muted,
          fontSize: 12,
        ),
        prefixIcon: Icon(
          Icons.search_rounded,
          color: RiderColors.muted,
        ),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                onPressed: () {
                  _searchController.clear();
                  setState(() {});
                },
                icon: const Icon(Icons.close),
              )
            : null,
        filled: true,
        fillColor: RiderColors.field,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: RiderColors.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: RiderColors.blue,
          ),
        ),
      ),
    );
  }

  Widget _filterBar(
    int total,
    int assigned,
    int inProgress,
  ) {
    final filters = [
      ('All', total),
      ('Assigned', assigned),
      ('In Progress', inProgress),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final selected = _filter == filter.$1;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                '${filter.$1} (${filter.$2})',
              ),
              selected: selected,
              onSelected: (_) {
                setState(() {
                  _filter = filter.$1;
                });
              },
              selectedColor: RiderColors.blueSoft,
              backgroundColor: RiderColors.surface,
              side: BorderSide(
                color: selected
                    ? RiderColors.blue
                    : RiderColors.border,
              ),
              labelStyle: TextStyle(
                color: selected
                    ? RiderColors.blue
                    : RiderColors.muted,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _assignmentCard(RiderDelivery order) {
    final isAssigned = order.status == 'pickup_assigned';

    return Container(
      decoration: BoxDecoration(
        color: RiderColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: RiderColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        order.orderNumber,
                        style: TextStyle(
                          color: RiderColors.text,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.inventory_2_outlined,
                      color: RiderColors.blue,
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  order.sellerName.isNotEmpty
                      ? order.sellerName
                      : order.pickupName,
                  style: TextStyle(
                    color: RiderColors.muted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 13),
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: [
                    _badge(
                      order.statusLabel,
                      RiderColors.goldSoft,
                      RiderColors.goldDark,
                    ),
                    _badge(
                      'Seller Pickup',
                      RiderColors.blueSoft,
                      RiderColors.blue,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _location(
                  Icons.storefront_outlined,
                  'SELLER PICKUP',
                  order.pickupName,
                  order.pickupAddress,
                  RiderColors.blue,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Container(
                    height: 23,
                    width: 2,
                    color: RiderColors.border,
                  ),
                ),
                _location(
                  Icons.location_on_outlined,
                  'NEXT HANDOFF',
                  order.sortingCenterName.isNotEmpty
                      ? order.sortingCenterName
                      : 'Origin Sorting Hub',
                  order.sortingCenterAddress.isNotEmpty
                      ? order.sortingCenterAddress
                      : 'SARI Logistics intake',
                  RiderColors.green,
                ),
                const SizedBox(height: 16),
                _infoBox(
                  'Pickup-only assignment. '
                  'The Marketplace delivery fee belongs '
                  'to the final-mile Rider, not the '
                  'Seller pickup Rider.',
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: RiderColors.surfaceSoft,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: widget.onOpenWorkflow,
                    icon: Icon(
                      isAssigned
                          ? Icons.play_arrow_rounded
                          : Icons.arrow_forward_rounded,
                    ),
                    label: Text(
                      isAssigned
                          ? 'Start Pickup Workflow'
                          : 'Continue Pickup Workflow',
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: RiderColors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Parcel: ${order.packageCode}',
                  style: TextStyle(
                    color: RiderColors.muted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _location(
    IconData icon,
    String label,
    String name,
    String address,
    Color accent,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: accent, size: 26),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: accent,
                  fontSize: 10,
                  letterSpacing: .7,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                name.isEmpty ? 'Not available' : name,
                style: TextStyle(
                  color: RiderColors.text,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                address.isEmpty
                    ? 'Address unavailable'
                    : address,
                style: TextStyle(
                  color: RiderColors.muted,
                  fontSize: 11,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _badge(
    String text,
    Color background,
    Color foreground,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: foreground,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _infoBox(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: RiderColors.blueSoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: RiderColors.blue,
            size: 18,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              message,
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

  Widget _emptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 22,
        vertical: 38,
      ),
      decoration: BoxDecoration(
        color: RiderColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: RiderColors.border,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            color: RiderColors.muted,
            size: 45,
          ),
          const SizedBox(height: 14),
          Text(
            'No pickup assignments waiting',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: RiderColors.text,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'New Seller pickups will appear here '
            'when SARI Logistics assigns them to you.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: RiderColors.muted,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _footer(int count) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Showing $count assigned '
            '${count == 1 ? 'pickup' : 'pickups'}.',
            style: TextStyle(
              color: RiderColors.muted,
              fontSize: 11,
            ),
          ),
        ),
        TextButton(
          onPressed: widget.onOpenDelivery,
          child: Text(
            'Last-Mile',
            style: TextStyle(
              color: RiderColors.blue,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _previewNotice() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: RiderColors.goldSoft,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: RiderColors.goldDark,
            size: 19,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              'Preview mode: Assignments are supplied '
              'by the Flutter app until the authenticated '
              'Laravel Rider API is integrated. '
              'Opening a workflow does not confirm '
              'an update in Laravel.',
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
