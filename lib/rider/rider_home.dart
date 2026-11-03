import 'package:flutter/material.dart';

import 'models/rider_delivery_model.dart';
import 'models/rider_profile_model.dart';
import 'widgets/rider_ui.dart';

class RiderHome extends StatelessWidget {
  final RiderDelivery? currentDelivery;

  final List<RiderDelivery> assignments;

  final RiderProfile profile;

  final bool isDarkMode;

  final ValueChanged<bool>
      onDarkModeChanged;

  final ValueChanged<int>?
      onTabChanged;

  final ValueChanged<RiderDelivery>
      onAdvanceDelivery;

  final VoidCallback onOpenMessages;

  final VoidCallback onOpenHistory;

  final VoidCallback onOpenPickups;

  final Future<void> Function()?
      onRefresh;

  final Map<String, dynamic>
      dashboardSummary;

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
    this.onRefresh,
    this.dashboardSummary =
        const <String, dynamic>{},
    this.onTabChanged,
  });

  int _serverInt(
    String key,
  ) {
    final value =
        dashboardSummary[key];

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
          '$value',
        ) ??
        0;
  }

  double _serverDouble(
    String key,
  ) {
    final value =
        dashboardSummary[key];

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          '$value',
        ) ??
        0;
  }

  String _money(
    double value,
  ) {
    return '₱${value.toStringAsFixed(2)}';
  }

  String get _riderName {
    final name = [
      profile.firstName,
      profile.lastName,
    ]
        .where(
          (value) =>
              value.trim().isNotEmpty,
        )
        .join(' ');

    return name.isEmpty
        ? 'SARI Rider'
        : name;
  }

  String _todayLabel() {
    final now =
        DateTime.now();

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[now.month - 1]} '
        '${now.day}, ${now.year}';
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final pickupActive =
        _serverInt(
      'pickup_active',
    );

    final directActive =
        _serverInt(
      'direct_delivery_active',
    );

    final lastMileActive =
        _serverInt(
      'last_mile_active',
    );

    final completedToday =
        _serverInt(
      'completed_today',
    );

    final earningsToday =
        _serverDouble(
      'earnings_today',
    );

    final unreadMessages =
        _serverInt(
      'unread_messages',
    );

    final activeWork =
        pickupActive +
            directActive +
            lastMileActive;

    final current =
        currentDelivery ??
            (assignments.isEmpty
                ? null
                : assignments.first);

    return Scaffold(
      backgroundColor:
          RiderColors.bg,
      appBar: AppBar(
        automaticallyImplyLeading:
            false,
        backgroundColor:
            RiderColors.surface,
        surfaceTintColor:
            Colors.transparent,
        elevation: 0,
        titleSpacing: 15,
        title: Row(
          children: [
            Container(
              width: 39,
              height: 39,
              alignment:
                  Alignment.center,
              decoration:
                  BoxDecoration(
                color:
                    RiderColors.goldSoft,
                borderRadius:
                    BorderRadius.circular(
                  12,
                ),
              ),
              child: Icon(
                Icons
                    .delivery_dining_rounded,
                color:
                    RiderColors.gold,
                size: 21,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Text(
                    'Rider Dashboard',
                    style:
                        TextStyle(
                      color:
                          RiderColors.text,
                      fontSize: 17,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                  const SizedBox(
                    height: 1,
                  ),
                  Text(
                    profile.availabilityStatus ==
                            'online'
                        ? 'Online • Ready for assignments'
                        : 'Offline • Not accepting new assignments',
                    maxLines: 1,
                    overflow:
                        TextOverflow
                            .ellipsis,
                    style:
                        TextStyle(
                      color:
                          RiderColors.muted,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Stack(
            clipBehavior:
                Clip.none,
            children: [
              IconButton(
                tooltip:
                    'Chat / Messaging',
                onPressed:
                    onOpenMessages,
                icon: Icon(
                  Icons
                      .chat_bubble_outline_rounded,
                  color:
                      RiderColors.text,
                ),
              ),
              if (unreadMessages > 0)
                Positioned(
                  right: 5,
                  top: 5,
                  child: Container(
                    constraints:
                        const BoxConstraints(
                      minWidth: 17,
                    ),
                    height: 17,
                    alignment:
                        Alignment.center,
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 4,
                    ),
                    decoration:
                        BoxDecoration(
                      color:
                          RiderColors.gold,
                      borderRadius:
                          BorderRadius.circular(
                        20,
                      ),
                    ),
                    child: Text(
                      unreadMessages > 99
                          ? '99+'
                          : '$unreadMessages',
                      style:
                          const TextStyle(
                        color:
                            Colors.white,
                        fontSize: 7,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        color:
            RiderColors.gold,
        onRefresh:
            onRefresh ??
                () async {},
        child: ListView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          padding:
              const EdgeInsets.fromLTRB(
            14,
            18,
            14,
            32,
          ),
          children: [
            _welcomeCard(),

            const SizedBox(
              height: 18,
            ),

            _metrics(
              pickupActive:
                  pickupActive,
              activeWork:
                  activeWork,
              lastMileActive:
                  lastMileActive,
              earningsToday:
                  earningsToday,
              completedToday:
                  completedToday,
            ),

            const SizedBox(
              height: 22,
            ),

            _sectionHeader(
              title:
                  'My Assignments',
              subtitle:
                  'Your current pickup and delivery work',
              trailing:
                  TextButton(
                onPressed: () =>
                    onTabChanged
                        ?.call(1),
                child:
                    const Text(
                  'View All',
                ),
              ),
            ),

            const SizedBox(
              height: 11,
            ),

            current == null
                ? _emptyAssignment()
                : _assignmentCard(
                    current,
                  ),

            const SizedBox(
              height: 22,
            ),

            _sectionHeader(
              title:
                  'Rider Operations',
              subtitle:
                  'Quick access to active workflows',
            ),

            const SizedBox(
              height: 11,
            ),

            _operations(),

            const SizedBox(
              height: 22,
            ),

            _sectionHeader(
              title:
                  'Today at a Glance',
              subtitle:
                  'Your latest operational totals',
              trailing:
                  TextButton(
                onPressed: () =>
                    onTabChanged
                        ?.call(3),
                child:
                    const Text(
                  'Earnings',
                ),
              ),
            ),

            const SizedBox(
              height: 11,
            ),

            _todayGrid(
              completedToday:
                  completedToday,
              pickupActive:
                  pickupActive,
              lastMileActive:
                  lastMileActive,
              earningsToday:
                  earningsToday,
            ),

            const SizedBox(
              height: 22,
            ),

            _riderStatus(),

            const SizedBox(
              height: 20,
            ),

            Center(
              child: Text(
                'SARI Rider • Elevated Everyday',
                style:
                    TextStyle(
                  color:
                      RiderColors.muted,
                  fontSize: 9,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _welcomeCard() {
    final online =
        profile.availabilityStatus ==
            'online';

    return RiderSurface(
      elevated: true,
      radius: 17,
      padding:
          const EdgeInsets.all(
        18,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  'RIDER OPERATIONS',
                  style:
                      TextStyle(
                    color:
                        RiderColors.gold,
                    fontSize: 9,
                    fontWeight:
                        FontWeight.w800,
                    letterSpacing:
                        1.2,
                  ),
                ),
                const SizedBox(
                  height: 6,
                ),
                Text(
                  'Welcome back,\n$_riderName',
                  style:
                      TextStyle(
                    color:
                        RiderColors.text,
                    fontSize: 23,
                    height: 1.15,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
                const SizedBox(
                  height: 9,
                ),
                Text(
                  'Manage your assigned pickups and deliveries from one place.',
                  style:
                      TextStyle(
                    color:
                        RiderColors.muted,
                    fontSize: 10,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            width: 12,
          ),
          Column(
            crossAxisAlignment:
                CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 6,
                ),
                decoration:
                    BoxDecoration(
                  color: online
                      ? RiderColors
                          .greenSoft
                      : RiderColors
                          .surfaceSoft,
                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),
                ),
                child: Row(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration:
                          BoxDecoration(
                        color: online
                            ? RiderColors
                                .green
                            : RiderColors
                                .muted,
                        shape:
                            BoxShape.circle,
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      online
                          ? 'Online'
                          : 'Offline',
                      style:
                          TextStyle(
                        color: online
                            ? RiderColors
                                .green
                            : RiderColors
                                .muted,
                        fontSize: 8,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Icon(
                    Icons
                        .calendar_today_outlined,
                    size: 13,
                    color:
                        RiderColors.gold,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    _todayLabel(),
                    style:
                        TextStyle(
                      color:
                          RiderColors.muted,
                      fontSize: 8,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metrics({
    required int pickupActive,
    required int activeWork,
    required int lastMileActive,
    required double earningsToday,
    required int completedToday,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child:
                  _metricCard(
                label:
                    'Pickup Active',
                value:
                    '$pickupActive',
                note:
                    'Seller pickup jobs',
                icon: Icons
                    .inventory_2_outlined,
                accent:
                    RiderColors.gold,
                background:
                    RiderColors.goldSoft,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child:
                  _metricCard(
                label:
                    'Active Work',
                value:
                    '$activeWork',
                note:
                    'Pickups & deliveries',
                icon: Icons
                    .route_outlined,
                accent:
                    RiderColors.green,
                background:
                    RiderColors.greenSoft,
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          children: [
            Expanded(
              child:
                  _metricCard(
                label:
                    'Last-Mile Batches',
                value:
                    '$lastMileActive',
                note:
                    'Assigned batches',
                icon: Icons
                    .local_shipping_outlined,
                accent:
                    RiderColors.blue,
                background:
                    RiderColors.blueSoft,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child:
                  _metricCard(
                label:
                    'Today\'s Earnings',
                value:
                    _money(
                  earningsToday,
                ),
                note:
                    '$completedToday completed today',
                icon: Icons
                    .payments_outlined,
                accent:
                    RiderColors.gold,
                background:
                    RiderColors.goldSoft,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _metricCard({
    required String label,
    required String value,
    required String note,
    required IconData icon,
    required Color accent,
    required Color background,
  }) {
    return RiderSurface(
      elevated: true,
      radius: 16,
      padding:
          const EdgeInsets.all(
        13,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            alignment:
                Alignment.center,
            decoration:
                BoxDecoration(
              color: background,
              borderRadius:
                  BorderRadius.circular(
                10,
              ),
            ),
            child: Icon(
              icon,
              color: accent,
              size: 19,
            ),
          ),
          const SizedBox(
            height: 11,
          ),
          Text(
            label,
            maxLines: 1,
            overflow:
                TextOverflow.ellipsis,
            style:
                TextStyle(
              color:
                  RiderColors.muted,
              fontSize: 9,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
          const SizedBox(
            height: 3,
          ),
          Text(
            value,
            maxLines: 1,
            overflow:
                TextOverflow.ellipsis,
            style:
                TextStyle(
              color:
                  RiderColors.text,
              fontSize: 20,
              fontWeight:
                  FontWeight.w800,
            ),
          ),
          const SizedBox(
            height: 3,
          ),
          Text(
            note,
            maxLines: 1,
            overflow:
                TextOverflow.ellipsis,
            style:
                TextStyle(
              color:
                  RiderColors.muted,
              fontSize: 7.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader({
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,
            children: [
              Text(
                title,
                style:
                    TextStyle(
                  color:
                      RiderColors.text,
                  fontSize: 16,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
              const SizedBox(
                height: 3,
              ),
              Text(
                subtitle,
                style:
                    TextStyle(
                  color:
                      RiderColors.muted,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null)
          trailing,
      ],
    );
  }

  Widget _emptyAssignment() {
    return RiderSurface(
      radius: 15,
      padding:
          const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 28,
      ),
      child: Column(
        children: [
          Icon(
            Icons
                .assignment_turned_in_outlined,
            size: 43,
            color:
                RiderColors.muted,
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            'No active assignment',
            style:
                TextStyle(
              color:
                  RiderColors.text,
              fontSize: 13,
              fontWeight:
                  FontWeight.w800,
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            'Your current pickup or delivery assignment will appear here.',
            textAlign:
                TextAlign.center,
            style:
                TextStyle(
              color:
                  RiderColors.muted,
              fontSize: 9,
              height: 1.45,
            ),
          ),
          const SizedBox(
            height: 13,
          ),
          OutlinedButton(
            onPressed: () =>
                onTabChanged
                    ?.call(1),
            child:
                const Text(
              'View Assignments',
            ),
          ),
        ],
      ),
    );
  }

  Widget _assignmentCard(
    RiderDelivery order,
  ) {
    final hasAction =
        order.actionLabel
            .trim()
            .isNotEmpty;

    return RiderSurface(
      elevated: true,
      radius: 16,
      padding:
          const EdgeInsets.all(
        15,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      order.orderNumber,
                      style:
                          TextStyle(
                        color:
                            RiderColors.text,
                        fontSize: 14,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                    const SizedBox(
                      height: 3,
                    ),
                    Text(
                      order.sellerName,
                      maxLines: 1,
                      overflow:
                          TextOverflow
                              .ellipsis,
                      style:
                          TextStyle(
                        color:
                            RiderColors.muted,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      RiderColors.goldSoft,
                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),
                ),
                child: Text(
                  order.statusLabel,
                  style:
                      TextStyle(
                    color:
                        RiderColors.goldDark,
                    fontSize: 8,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 13,
          ),

          const Divider(),

          const SizedBox(
            height: 10,
          ),

          _assignmentDetail(
            icon:
                Icons.storefront_outlined,
            label:
                'Pickup',
            value:
                order.pickupAddress
                        .trim()
                        .isNotEmpty
                    ? order
                        .pickupAddress
                    : order
                        .pickupName,
          ),

          const SizedBox(
            height: 10,
          ),

          if (!order
              .isLogisticsPickup)
            _assignmentDetail(
              icon:
                  Icons.location_on_outlined,
              label:
                  'Buyer',
              value:
                  order.buyerAddress
                          .trim()
                          .isNotEmpty
                      ? order
                          .buyerAddress
                      : order
                          .buyerName,
            )
          else
            _assignmentDetail(
              icon:
                  Icons.hub_outlined,
              label:
                  'Workflow',
              value:
                  'Seller pickup and origin-hub handoff',
            ),

          const SizedBox(
            height: 12,
          ),

          Text(
            order.actionMessage,
            style:
                TextStyle(
              color:
                  RiderColors.muted,
              fontSize: 9,
              height: 1.45,
            ),
          ),

          const SizedBox(
            height: 14,
          ),

          Row(
            children: [
              Expanded(
                child:
                    OutlinedButton.icon(
                  onPressed: () =>
                      onTabChanged
                          ?.call(1),
                  icon:
                      const Icon(
                    Icons
                        .visibility_outlined,
                    size: 16,
                  ),
                  label:
                      const Text(
                    'Details',
                  ),
                ),
              ),
              if (hasAction) ...[
                const SizedBox(
                  width: 8,
                ),
                Expanded(
                  child:
                      ElevatedButton(
                    onPressed: () =>
                        onAdvanceDelivery(
                      order,
                    ),
                    style:
                        ElevatedButton
                            .styleFrom(
                      backgroundColor:
                          RiderColors.gold,
                      foregroundColor:
                          Colors.white,
                    ),
                    child: Text(
                      order.actionLabel,
                      maxLines: 1,
                      overflow:
                          TextOverflow
                              .ellipsis,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _assignmentDetail({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color:
              RiderColors.gold,
          size: 18,
        ),
        const SizedBox(
          width: 8,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,
            children: [
              Text(
                label,
                style:
                    TextStyle(
                  color:
                      RiderColors.muted,
                  fontSize: 8,
                ),
              ),
              const SizedBox(
                height: 2,
              ),
              Text(
                value.isEmpty
                    ? 'Not available'
                    : value,
                style:
                    TextStyle(
                  color:
                      RiderColors.text,
                  fontSize: 9.5,
                  height: 1.4,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _operations() {
    return RiderSurface(
      radius: 16,
      padding:
          const EdgeInsets.all(
        10,
      ),
      child: Column(
        children: [
          _operationRow(
            icon: Icons
                .assignment_outlined,
            title:
                'Pickup Assignments',
            subtitle:
                'Review your current assigned work',
            onTap: () =>
                onTabChanged
                    ?.call(1),
          ),
          _divider(),
          _operationRow(
            icon:
                Icons.storefront_outlined,
            title:
                'Seller Pickups',
            subtitle:
                'Seller collection and hub handoff',
            onTap:
                onOpenPickups,
          ),
          _divider(),
          _operationRow(
            icon: Icons
                .local_shipping_outlined,
            title:
                'Active Deliveries',
            subtitle:
                'Direct deliveries to buyers',
            onTap: () =>
                onTabChanged
                    ?.call(2),
          ),
          _divider(),
          _operationRow(
            icon:
                Icons.history_rounded,
            title:
                'Delivery History',
            subtitle:
                'Completed rider transactions',
            onTap:
                onOpenHistory,
          ),
          _divider(),
          _operationRow(
            icon: Icons
                .chat_bubble_outline_rounded,
            title:
                'Chat / Messaging',
            subtitle:
                'Messages from Logistics',
            onTap:
                onOpenMessages,
          ),
        ],
      ),
    );
  }

  Widget _operationRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 5,
        vertical: 2,
      ),
      leading: Container(
        width: 38,
        height: 38,
        alignment:
            Alignment.center,
        decoration:
            BoxDecoration(
          color:
              RiderColors.goldSoft,
          borderRadius:
              BorderRadius.circular(
            10,
          ),
        ),
        child: Icon(
          icon,
          color:
              RiderColors.goldDark,
          size: 19,
        ),
      ),
      title: Text(
        title,
        style:
            TextStyle(
          color:
              RiderColors.text,
          fontSize: 10.5,
          fontWeight:
              FontWeight.w700,
        ),
      ),
      subtitle: Text(
        subtitle,
        style:
            TextStyle(
          color:
              RiderColors.muted,
          fontSize: 8,
        ),
      ),
      trailing: Icon(
        Icons
            .chevron_right_rounded,
        color:
            RiderColors.muted,
      ),
      onTap: onTap,
    );
  }

  Widget _divider() {
    return Divider(
      height: 1,
      color:
          RiderColors.border,
    );
  }

  Widget _todayGrid({
    required int completedToday,
    required int pickupActive,
    required int lastMileActive,
    required double earningsToday,
  }) {
    return RiderSurface(
      radius: 16,
      padding:
          EdgeInsets.zero,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child:
                    _todayCell(
                  icon: Icons
                      .check_circle_outline,
                  label:
                      'Completed Jobs',
                  value:
                      '$completedToday',
                ),
              ),
              _verticalDivider(),
              Expanded(
                child:
                    _todayCell(
                  icon: Icons
                      .inventory_2_outlined,
                  label:
                      'Pickup Active',
                  value:
                      '$pickupActive',
                ),
              ),
            ],
          ),
          Divider(
            height: 1,
            color:
                RiderColors.border,
          ),
          Row(
            children: [
              Expanded(
                child:
                    _todayCell(
                  icon: Icons
                      .local_shipping_outlined,
                  label:
                      'Last-Mile Active',
                  value:
                      '$lastMileActive',
                ),
              ),
              _verticalDivider(),
              Expanded(
                child:
                    _todayCell(
                  icon: Icons
                      .payments_outlined,
                  label:
                      'Earned Today',
                  value:
                      _money(
                    earningsToday,
                  ),
                  highlight:
                      true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _verticalDivider() {
    return Container(
      width: 1,
      height: 102,
      color:
          RiderColors.border,
    );
  }

  Widget _todayCell({
    required IconData icon,
    required String label,
    required String value,
    bool highlight = false,
  }) {
    return Padding(
      padding:
          const EdgeInsets.all(
        15,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color:
                    RiderColors.gold,
                size: 18,
              ),
              const SizedBox(
                width: 6,
              ),
              Expanded(
                child: Text(
                  label,
                  style:
                      TextStyle(
                    color:
                        RiderColors.muted,
                    fontSize: 8.5,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 11,
          ),
          Text(
            value,
            maxLines: 1,
            overflow:
                TextOverflow.ellipsis,
            style:
                TextStyle(
              color: highlight
                  ? RiderColors
                      .goldDark
                  : RiderColors
                      .text,
              fontSize: 19,
              fontWeight:
                  FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _riderStatus() {
    final online =
        profile.availabilityStatus ==
            'online';

    return RiderSurface(
      radius: 16,
      padding:
          const EdgeInsets.all(
        15,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor:
                RiderColors.blueSoft,
            child: Icon(
              Icons.person_rounded,
              color:
                  RiderColors.blue,
            ),
          ),
          const SizedBox(
            width: 11,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  _riderName,
                  style:
                      TextStyle(
                    color:
                        RiderColors.text,
                    fontSize: 12,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
                const SizedBox(
                  height: 3,
                ),
                Text(
                  'Rider • '
                  '${online ? 'Online' : 'Offline'}',
                  style:
                      TextStyle(
                    color:
                        RiderColors.muted,
                    fontSize: 8.5,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  children: [
                    Icon(
                      Icons
                          .star_rounded,
                      size: 14,
                      color:
                          RiderColors.gold,
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    Text(
                      profile.rating
                          .toStringAsFixed(
                        1,
                      ),
                      style:
                          TextStyle(
                        color:
                            RiderColors.text,
                        fontSize: 8.5,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () =>
                onTabChanged
                    ?.call(4),
            child:
                const Text(
              'Manage',
            ),
          ),
        ],
      ),
    );
  }
}