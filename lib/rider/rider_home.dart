import 'package:flutter/material.dart';

import 'models/rider_delivery_model.dart';
import 'models/rider_profile_model.dart';
import 'widgets/rider_map.dart';
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

  RiderHome({
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

  int get _waitingCount => assignments
      .where((order) =>
          order.status == 'pickup_assigned' ||
          order.status == 'delivery_assigned')
      .length;

  int get _activeCount =>
      currentDelivery == null || currentDelivery!.isComplete ? 0 : 1;

  int get _completedToday => currentDelivery?.status == 'completed' ? 3 : 2;

  double get _earningsToday =>
      180.0 +
      (currentDelivery?.status == 'completed'
          ? currentDelivery!.deliveryFee
          : 0);

  @override
  Widget build(BuildContext context) {
    final delivery = currentDelivery;

    return Scaffold(
      backgroundColor: RiderColors.bg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 78,
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: RiderColors.surfaceSoft,
                shape: BoxShape.circle,
                border: Border.all(color: RiderColors.border),
              ),
              child: Icon(
                Icons.person_rounded,
                color: RiderColors.text,
                size: 24,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: RiderHeaderTitle(
                title: 'Hi, ${profile.firstName}',
                subtitle: profile.availabilityStatus == 'online'
                    ? 'Rider • Online and ready'
                    : 'Rider • Offline',
              ),
            ),
          ],
        ),
        actions: [
          _iconButton(
            icon: isDarkMode
                ? Icons.light_mode_outlined
                : Icons.dark_mode_outlined,
            onTap: () => onDarkModeChanged(!isDarkMode),
            tooltip: isDarkMode ? 'Light mode' : 'Dark mode',
          ),
          SizedBox(width: 6),
          _iconButton(
            icon: Icons.notifications_none_rounded,
            onTap: onOpenMessages,
            badge: true,
            tooltip: 'Dispatch messages',
          ),
          SizedBox(width: 12),
        ],
      ),
      body: RefreshIndicator(
        color: RiderColors.gold,
        onRefresh: () async =>
            Future<void>.delayed(Duration(milliseconds: 350)),
        child: ListView(
          padding: EdgeInsets.fromLTRB(14, 8, 14, 26),
          children: [
            _availabilityHero(),
            SizedBox(height: 12),
            _earningsOverview(),
            SizedBox(height: 12),
            _stats(),
            SizedBox(height: 22),
            RiderSectionHeader(
              title: 'Current mission',
              subtitle: delivery == null
                  ? 'No active rider assignment'
                  : '${delivery.legLabel} • ${delivery.orderNumber}',
              trailing: delivery == null
                  ? null
                  : RiderStatusPill(
                      label: delivery.statusLabel,
                      color: riderStatusColor(delivery.status),
                      background: riderStatusSoftColor(delivery.status),
                    ),
            ),
            SizedBox(height: 10),
            if (delivery == null)
              RiderEmptyState(
                icon: Icons.route_outlined,
                title: 'No active mission',
                message:
                    'Assigned pickup and delivery jobs will appear here.',
              )
            else ...[
              _missionCard(delivery),
              if (delivery.showDeliveryMap) ...[
                SizedBox(height: 12),
                RiderMap(delivery: delivery),
              ],
            ],
            SizedBox(height: 22),
            RiderSectionHeader(
              title: 'Quick tools',
              subtitle: 'Everything a rider needs in one tap',
            ),
            SizedBox(height: 10),
            _quickTools(),
            SizedBox(height: 22),
            RiderSectionHeader(
              title: 'Workflow overview',
              subtitle: 'Seller → Sorting Center → Customer',
              trailing: TextButton(
                onPressed: onOpenPickups,
                child: Text('View pickups'),
              ),
            ),
            SizedBox(height: 10),
            _workflowOverview(),
          ],
        ),
      ),
    );
  }

  Widget _iconButton({
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
    bool badge = false,
  }) {
    return Tooltip(
      message: tooltip,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Material(
            color: RiderColors.surfaceSoft,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                width: 42,
                height: 42,
                child: Icon(
                  icon,
                  color: RiderColors.text,
                  size: 21,
                ),
              ),
            ),
          ),
          if (badge)
            Positioned(
              right: 4,
              top: 4,
              child: CircleAvatar(
                radius: 4,
                backgroundColor: RiderColors.gold,
              ),
            ),
        ],
      ),
    );
  }

  Widget _availabilityHero() {
    final online = profile.availabilityStatus == 'online';

    return Container(
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: RiderColors.heroGradient,
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: RiderColors.isDark ? .08 : .14),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: RiderColors.isDark ? .24 : .10),
            blurRadius: 28,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -28,
            top: -36,
            child: Container(
              width: 145,
              height: 145,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: .055),
              ),
            ),
          ),
          Positioned(
            right: 12,
            bottom: -34,
            child: Icon(
              Icons.delivery_dining_rounded,
              size: 122,
              color: Colors.white.withValues(alpha: .07),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  RiderStatusPill(
                    label: online ? 'ONLINE • READY' : 'OFFLINE',
                    color: online ? Color(0xFFBFF1CC) : RiderColors.red,
                    background: online
                        ? Color(0x2638C469)
                        : RiderColors.redSoft,
                    icon: online
                        ? Icons.bolt_rounded
                        : Icons.pause_circle_outline,
                  ),
                  Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .09),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: .10),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.shield_outlined,
                          color: Colors.white,
                          size: 14,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Safe ride',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 18),
              Text(
                'Ride smart. Deliver safe.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -.8,
                ),
              ),
              SizedBox(height: 6),
              Text(
                currentDelivery == null
                    ? 'You are ready to receive logistics assignments.'
                    : currentDelivery!.actionMessage,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: .82),
                  fontSize: 12,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _earningsOverview() {
    const values = <double>[52, 68, 86, 74, 61, 48, 55];
    const labels = <String>['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    const maxValue = 86.0;

    return Container(
      padding: EdgeInsets.fromLTRB(16, 15, 16, 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: RiderColors.earningsGradient,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: RiderColors.border),
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
                      "Today's earnings",
                      style: TextStyle(
                        color: RiderColors.muted,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      '₱${_earningsToday.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: RiderColors.text,
                        fontSize: 27,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -.7,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: RiderColors.greenSoft,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.trending_up_rounded,
                      color: RiderColors.green,
                      size: 14,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '+12%',
                      style: TextStyle(
                        color: RiderColors.green,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14),
          SizedBox(
            height: 74,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(values.length, (index) {
                final selected = index == 2;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: FractionallySizedBox(
                              heightFactor: (values[index] / maxValue).clamp(.18, 1).toDouble(),
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(7),
                                  color: selected
                                      ? RiderColors.gold
                                      : RiderColors.blue.withValues(
                                          alpha: RiderColors.isDark ? .28 : .18,
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          labels[index],
                          style: TextStyle(
                            color: selected ? RiderColors.goldDark : RiderColors.muted,
                            fontSize: 8.5,
                            fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stats() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - 10) / 2;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            SizedBox(
              width: width,
              child: RiderMetricTile(
                value: '$_waitingCount',
                label: 'Waiting jobs',
                icon: Icons.assignment_late_outlined,
                accent: RiderColors.goldDark,
                softColor: RiderColors.goldSoft,
              ),
            ),
            SizedBox(
              width: width,
              child: RiderMetricTile(
                value: '$_activeCount',
                label: 'Active route',
                icon: Icons.route_rounded,
                accent: RiderColors.blue,
                softColor: RiderColors.blueSoft,
              ),
            ),
            SizedBox(
              width: width,
              child: RiderMetricTile(
                value: '$_completedToday',
                label: 'Done today',
                icon: Icons.check_circle_outline_rounded,
                accent: RiderColors.green,
                softColor: RiderColors.greenSoft,
              ),
            ),
            SizedBox(
              width: width,
              child: RiderMetricTile(
                value: '4.9',
                label: 'Rider rating',
                icon: Icons.star_outline_rounded,
                accent: RiderColors.purple,
                softColor: RiderColors.purpleSoft,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _missionCard(RiderDelivery order) {
    return RiderSurface(
      padding: EdgeInsets.zero,
      shadow: true,
      elevated: true,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: riderStatusSoftColor(order.status),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    order.isDeliveryFlow
                        ? Icons.local_shipping_outlined
                        : Icons.inventory_2_outlined,
                    color: riderStatusColor(order.status),
                    size: 24,
                  ),
                ),
                SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.orderNumber,
                        style: TextStyle(
                          color: RiderColors.text,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Parcel ${order.packageCode}',
                        style: TextStyle(
                          color: RiderColors.muted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '₱${order.deliveryFee.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: RiderColors.green,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: order.workflowProgress,
                minHeight: 7,
                backgroundColor: RiderColors.border,
                valueColor: AlwaysStoppedAnimation<Color>(
                  riderStatusColor(order.status),
                ),
              ),
            ),
          ),
          SizedBox(height: 14),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: _routeLine(order),
          ),
          SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(16, 13, 16, 15),
            decoration: BoxDecoration(
              color: RiderColors.surfaceSoft,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
              border: Border(
                top: BorderSide(color: RiderColors.border),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  order.actionMessage,
                  style: TextStyle(
                    color: RiderColors.muted,
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
                if (order.status == 'arrived_buyer') ...[
                  SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () => onTabChanged?.call(2),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: RiderColors.blue,
                      foregroundColor: Colors.white,
                      minimumSize: Size.fromHeight(46),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: Icon(Icons.fact_check_outlined, size: 19),
                    label: Text(
                      'Record Delivery Result',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ] else if (order.nextStatus != null) ...[
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => onAdvanceDelivery(order),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: riderStatusColor(order.status),
                      foregroundColor: RiderColors.isDark
                          ? Color(0xFF172129)
                          : Colors.white,
                      minimumSize: Size.fromHeight(46),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      order.actionLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _routeLine(RiderDelivery order) {
    return Row(
      children: [
        _routeNode(
          icon: Icons.storefront_outlined,
          label: 'Seller',
          active: !order.isDeliveryFlow && !order.isHeadingToSortingCenter,
          done: order.isHeadingToSortingCenter || order.isDeliveryFlow,
          color: RiderColors.gold,
        ),
        _connector(),
        _routeNode(
          icon: Icons.warehouse_outlined,
          label: 'Sorting',
          active: order.isHeadingToSortingCenter ||
              const [
                'sorting_received',
                'delivery_assigned',
                'delivery_accepted',
                'parcel_released',
              ].contains(order.status),
          done: const [
            'out_for_delivery',
            'arrived_buyer',
            'delivered',
            'completed',
          ].contains(order.status),
          color: RiderColors.blue,
        ),
        _connector(),
        _routeNode(
          icon: Icons.home_outlined,
          label: 'Customer',
          active: order.isHeadingToBuyer || order.status == 'delivered',
          done: order.status == 'completed',
          color: RiderColors.green,
        ),
      ],
    );
  }

  Widget _connector() {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5),
        child: Divider(
          color: RiderColors.border,
          thickness: 2,
        ),
      ),
    );
  }

  Widget _routeNode({
    required IconData icon,
    required String label,
    required bool active,
    required bool done,
    required Color color,
  }) {
    final fg = done || active ? color : RiderColors.muted;
    final bg = done || active
        ? color.withValues(alpha: .14)
        : RiderColors.surfaceSoft;

    return Column(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
            border: active ? Border.all(color: color, width: 2) : null,
          ),
          child: Icon(
            done ? Icons.check_rounded : icon,
            color: fg,
            size: 19,
          ),
        ),
        SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            color: fg,
            fontSize: 9,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _quickTools() {
    return Row(
      children: [
        Expanded(
          child: _tool(
            icon: Icons.assignment_outlined,
            label: 'Jobs',
            color: RiderColors.goldDark,
            onTap: () => onTabChanged?.call(1),
          ),
        ),
        SizedBox(width: 9),
        Expanded(
          child: _tool(
            icon: Icons.inventory_2_outlined,
            label: 'Pickups',
            color: RiderColors.blue,
            onTap: onOpenPickups,
          ),
        ),
        SizedBox(width: 9),
        Expanded(
          child: _tool(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Wallet',
            color: RiderColors.green,
            onTap: () => onTabChanged?.call(3),
          ),
        ),
        SizedBox(width: 9),
        Expanded(
          child: _tool(
            icon: Icons.history_rounded,
            label: 'History',
            color: RiderColors.purple,
            onTap: onOpenHistory,
          ),
        ),
      ],
    );
  }

  Widget _tool({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: RiderColors.surfaceElevated,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 14, horizontal: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: RiderColors.border),
          ),
          child: Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .13),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              SizedBox(height: 7),
              Text(
                label,
                style: TextStyle(
                  color: RiderColors.text,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _workflowOverview() {
    const items = [
      ('1', 'Seller pickup', 'Accept → Go to seller → Pick up → Scan'),
      ('2', 'Sorting handoff', 'Bring parcel to the sorting center'),
      ('3', 'Last-mile assignment', 'Pick up from sorting → Out for delivery'),
      ('4', 'Customer handoff', 'Deliver → Result → Buyer confirmation'),
    ];

    return RiderSurface(
      padding: EdgeInsets.all(15),
      elevated: true,
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 31,
                  height: 31,
                  decoration: BoxDecoration(
                    color: i == 0
                        ? RiderColors.goldSoft
                        : RiderColors.surfaceSoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    items[i].$1,
                    style: TextStyle(
                      color: i == 0
                          ? RiderColors.goldDark
                          : RiderColors.muted,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        items[i].$2,
                        style: TextStyle(
                          color: RiderColors.text,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        items[i].$3,
                        style: TextStyle(
                          color: RiderColors.muted,
                          fontSize: 10,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (i != items.length - 1)
              Padding(
                padding: EdgeInsets.only(left: 15),
                child: SizedBox(
                  height: 18,
                  child: VerticalDivider(
                    color: RiderColors.border,
                    thickness: 1.5,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
