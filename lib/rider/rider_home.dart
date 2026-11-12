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

  final ValueChanged<RiderDelivery>
      onAdvanceDelivery;

  final VoidCallback onOpenMessages;
  final VoidCallback onOpenHistory;
  final VoidCallback onOpenPickups;

  final Future<void> Function()? onRefresh;

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
    final dynamic value =
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
    final dynamic value =
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

  String get _name {
    final String value =
        profile.fullName.trim();

    return value.isEmpty
        ? 'SARI Rider'
        : value;
  }

  String get _firstName {
    final String value =
        profile.firstName.trim();

    return value.isEmpty
        ? 'Rider'
        : value;
  }

  bool get _online {
    final String value =
        profile.availabilityStatus
            .trim()
            .toLowerCase();

    return value == 'online' ||
        value == 'available' ||
        value == 'active';
  }

  String _greeting() {
    final int hour =
        DateTime.now().hour;

    if (hour < 12) {
      return 'Good morning';
    }

    if (hour < 18) {
      return 'Good afternoon';
    }

    return 'Good evening';
  }

  String _date() {
    final DateTime now =
        DateTime.now();

    const List<String> days =
        <String>[
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ];

    const List<String> months =
        <String>[
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

    return '${days[now.weekday - 1]}, '
        '${months[now.month - 1]} '
        '${now.day}';
  }

  Color _statusColor(
    RiderDelivery delivery,
  ) {
    if (delivery.isComplete) {
      return RiderColors.green;
    }

    if (delivery.isFailed) {
      return RiderColors.red;
    }

    if (delivery.isDeliveryFlow) {
      return RiderColors.blue;
    }

    return RiderColors.goldDark;
  }

  Color _statusSoft(
    RiderDelivery delivery,
  ) {
    if (delivery.isComplete) {
      return RiderColors.greenSoft;
    }

    if (delivery.isFailed) {
      return RiderColors.redSoft;
    }

    if (delivery.isDeliveryFlow) {
      return RiderColors.blueSoft;
    }

    return RiderColors.goldSoft;
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final int pickupActive =
        _serverInt(
      'pickup_active',
    );

    final int deliveryActive =
        _serverInt(
      'direct_delivery_active',
    );

    final int lastMileActive =
        _serverInt(
      'last_mile_active',
    );

    final int completedToday =
        _serverInt(
      'completed_today',
    );

    final double earningsToday =
        _serverDouble(
      'earnings_today',
    );

    final int unreadMessages =
        _serverInt(
      'unread_messages',
    );

    final int activeWork =
        pickupActive +
            deliveryActive +
            lastMileActive;

    final RiderDelivery? current =
        currentDelivery ??
            (assignments.isEmpty
                ? null
                : assignments.first);

    return Scaffold(
      backgroundColor:
          RiderColors.bg,

      // ========================================================
      // HEADER
      // ========================================================

      appBar: AppBar(
        automaticallyImplyLeading:
            false,
        backgroundColor:
            RiderColors.surface,
        surfaceTintColor:
            Colors.transparent,
        elevation: 0,
        titleSpacing: 13,

        title: Row(
          children: <Widget>[
            Container(
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
                  12,
                ),
              ),
              child: Icon(
                Icons
                    .delivery_dining_rounded,
                color:
                    RiderColors.gold,
                size: 20,
              ),
            ),

            const SizedBox(
              width: 9,
            ),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: <Widget>[
                  Text(
                    'Rider Dashboard',
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style:
                        TextStyle(
                      color:
                          RiderColors.text,
                      fontSize: 16,
                      fontWeight:
                          FontWeight.w900,
                      letterSpacing:
                          -.25,
                    ),
                  ),

                  Text(
                    _online
                        ? 'Online • Ready for assignments'
                        : 'Offline • New jobs paused',
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style:
                        TextStyle(
                      color:
                          RiderColors.muted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        actions: <Widget>[
          const RiderHeaderActions(),
        ],
      ),

      // ========================================================
      // BODY
      // ========================================================

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
            12,
            12,
            12,
            30,
          ),
          children: <Widget>[
            _hero(
              activeWork:
                  activeWork,
              completedToday:
                  completedToday,
              earningsToday:
                  earningsToday,
            ),

            const SizedBox(
              height: 11,
            ),

            _metrics(
              pickupActive:
                  pickupActive,
              deliveryActive:
                  deliveryActive,
              lastMileActive:
                  lastMileActive,
              completedToday:
                  completedToday,
            ),

            const SizedBox(
              height: 21,
            ),

            _sectionHeader(
              title:
                  'My Assignments',
              subtitle:
                  'Your current pickup and delivery work.',
              action:
                  'View all',
              onAction: () {
                onTabChanged?.call(
                  1,
                );
              },
            ),

            const SizedBox(
              height: 10,
            ),

            current == null
                ? _emptyAssignment()
                : _assignmentCard(
                    current,
                  ),

            const SizedBox(
              height: 21,
            ),

            Center(
              child: Text(
                'SARI RIDER • ELEVATED EVERYDAY',
                style:
                    TextStyle(
                  color:
                      RiderColors.muted,
                  fontSize: 10,
                  letterSpacing:
                      .9,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HERO
  // ============================================================

  Widget _hero({
    required int activeWork,
    required int completedToday,
    required double earningsToday,
  }) {
    return LayoutBuilder(
      builder:
          (
            BuildContext context,
            BoxConstraints constraints,
          ) {
        final bool compact =
            constraints.maxWidth <
                350;

        return Container(
          padding:
              EdgeInsets.fromLTRB(
            compact ? 16 : 18,
            16,
            compact ? 16 : 18,
            16,
          ),
          decoration:
              BoxDecoration(
            image: const DecorationImage(
              image: AssetImage('assets/images/sari_rider_dashboard_bg.png'),
              fit: BoxFit.cover,
              alignment: Alignment.centerRight,
              colorFilter: ColorFilter.mode(Color(0x990D1014), BlendMode.darken),
            ),
            gradient: LinearGradient(
              colors: [Color(0xFF292A2C), Color(0xFF9A792F)],
            ),
            borderRadius:
                BorderRadius.circular(
              20,
            ),
            boxShadow:
                <BoxShadow>[
              BoxShadow(
                color:
                    Colors.black.withValues(
                  alpha:
                      RiderColors.isDark
                          ? .20
                          : .11,
                ),
                blurRadius: 20,
                offset:
                    const Offset(
                  0,
                  8,
                ),
              ),
            ],
          ),
          child: Stack(
            children: <Widget>[
              Positioned(
                right: -35,
                top: -45,
                child: Container(
                  width: 145,
                  height: 145,
                  decoration:
                      BoxDecoration(
                    shape:
                        BoxShape.circle,
                    color:
                        Colors.white
                            .withValues(
                      alpha: .055,
                    ),
                  ),
                ),
              ),

              Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: <Widget>[
                            Text(
                              _greeting(),
                              style:
                                  const TextStyle(
                                color:
                                    Colors.white60,
                                fontSize: 10,
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),

                            const SizedBox(
                              height: 2,
                            ),

                            Text(
                              _firstName,
                              maxLines: 1,
                              overflow:
                                  TextOverflow
                                      .ellipsis,
                              style:
                                  TextStyle(
                                color:
                                    Colors.white,
                                fontSize:
                                    compact
                                        ? 20
                                        : 22,
                                fontWeight:
                                    FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration:
                            BoxDecoration(
                          color:
                              Colors.white
                                  .withValues(
                            alpha: .10,
                          ),
                          borderRadius:
                              BorderRadius.circular(
                            20,
                          ),
                        ),
                        child: Row(
                          children: <Widget>[
                            Container(
                              width: 6,
                              height: 6,
                              decoration:
                                  BoxDecoration(
                                color:
                                    _online
                                        ? const Color(
                                            0xFF7DDEA0,
                                          )
                                        : Colors.white54,
                                shape:
                                    BoxShape.circle,
                              ),
                            ),

                            const SizedBox(
                              width: 5,
                            ),

                            Text(
                              _online
                                  ? 'ONLINE'
                                  : 'OFFLINE',
                              style:
                                  const TextStyle(
                                color:
                                    Colors.white,
                                fontSize: 10,
                                fontWeight:
                                    FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  Text(
                    'Ready for today\'s\nroute?',
                    style:
                        TextStyle(
                      color:
                          Colors.white,
                      fontSize:
                          compact
                              ? 23
                              : 26,
                      height: 1.02,
                      fontWeight:
                          FontWeight.w900,
                      letterSpacing:
                          -.7,
                    ),
                  ),

                  const SizedBox(
                    height: 7,
                  ),

                  Row(
                    children: <Widget>[
                      const Icon(
                        Icons
                            .calendar_today_outlined,
                        color:
                            Colors.white60,
                        size: 12,
                      ),

                      const SizedBox(
                        width: 5,
                      ),

                      Text(
                        _date(),
                        style:
                            const TextStyle(
                          color:
                              Colors.white60,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  Row(
                    children: <Widget>[
                      Expanded(
                        child:
                            _heroStat(
                          '$activeWork',
                          'Active',
                        ),
                      ),

                      const SizedBox(
                        width: 7,
                      ),

                      Expanded(
                        child:
                            _heroStat(
                          '$completedToday',
                          'Completed',
                        ),
                      ),

                      const SizedBox(
                        width: 7,
                      ),

                      Expanded(
                        child:
                            _heroStat(
                          _money(
                            earningsToday,
                          ),
                          'Today',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _heroStat(
    String value,
    String label,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        vertical: 9,
        horizontal: 5,
      ),
      decoration:
          BoxDecoration(
        color:
            Colors.white.withValues(
          alpha: .09,
        ),
        borderRadius:
            BorderRadius.circular(
          11,
        ),
      ),
      child: Column(
        children: <Widget>[
          Text(
            value,
            maxLines: 1,
            overflow:
                TextOverflow.ellipsis,
            style:
                const TextStyle(
              color: Colors.white,
              fontSize: 10.5,
              fontWeight:
                  FontWeight.w900,
            ),
          ),

          const SizedBox(
            height: 2,
          ),

          Text(
            label,
            maxLines: 1,
            style:
                const TextStyle(
              color:
                  Colors.white54,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // METRICS
  // ============================================================

  Widget _metrics({
    required int pickupActive,
    required int deliveryActive,
    required int lastMileActive,
    required int completedToday,
  }) {
    final List<
        ({
          String value,
          String label,
          String note,
          IconData icon,
          Color color,
          Color soft,
        })> items = [
      (
        value:
            '$pickupActive',
        label:
            'Pickups',
        note:
            'Seller pickup',
        icon:
            Icons.inventory_2_outlined,
        color:
            RiderColors.goldDark,
        soft:
            RiderColors.goldSoft,
      ),
      (
        value:
            '$deliveryActive',
        label:
            'Deliveries',
        note:
            'Active routes',
        icon:
            Icons.local_shipping_outlined,
        color:
            RiderColors.blue,
        soft:
            RiderColors.blueSoft,
      ),
      (
        value:
            '$lastMileActive',
        label:
            'Last Mile',
        note:
            'Assigned batches',
        icon:
            Icons.route_outlined,
        color:
            RiderColors.purple,
        soft:
            RiderColors.purpleSoft,
      ),
      (
        value:
            '$completedToday',
        label:
            'Completed',
        note:
            'Today',
        icon:
            Icons.verified_outlined,
        color:
            RiderColors.green,
        soft:
            RiderColors.greenSoft,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics:
          const NeverScrollableScrollPhysics(),
      itemCount:
          items.length,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        mainAxisExtent: 91,
      ),
      itemBuilder:
          (
            BuildContext context,
            int index,
          ) {
        final item =
            items[index];

        return Container(
          padding:
              const EdgeInsets.all(
            11,
          ),
          decoration:
              BoxDecoration(
            color:
                RiderColors.surface,
            borderRadius:
                BorderRadius.circular(
              15,
            ),
            border:
                Border.all(
              color:
                  RiderColors.border,
            ),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 38,
                height: 38,
                alignment:
                    Alignment.center,
                decoration:
                    BoxDecoration(
                  color:
                      item.soft,
                  borderRadius:
                      BorderRadius.circular(
                    11,
                  ),
                ),
                child: Icon(
                  item.icon,
                  color:
                      item.color,
                  size: 18,
                ),
              ),

              const SizedBox(
                width: 8,
              ),

              Expanded(
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .center,
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: <Widget>[
                    Text(
                      item.value,
                      maxLines: 1,
                      overflow:
                          TextOverflow
                              .ellipsis,
                      style:
                          TextStyle(
                        color:
                            RiderColors.text,
                        fontSize: 17,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),

                    Text(
                      item.label,
                      maxLines: 1,
                      overflow:
                          TextOverflow
                              .ellipsis,
                      style:
                          TextStyle(
                        color:
                            RiderColors.text,
                        fontSize: 10,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),

                    Text(
                      item.note,
                      maxLines: 1,
                      overflow:
                          TextOverflow
                              .ellipsis,
                      style:
                          TextStyle(
                        color:
                            RiderColors.muted,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // SECTION
  // ============================================================

  Widget _sectionHeader({
    required String title,
    required String subtitle,
    String? action,
    VoidCallback? onAction,
  }) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.end,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,
            children: <Widget>[
              Text(
                title,
                style:
                    TextStyle(
                  color:
                      RiderColors.text,
                  fontSize: 14,
                  fontWeight:
                      FontWeight.w900,
                ),
              ),

              const SizedBox(
                height: 2,
              ),

              Text(
                subtitle,
                style:
                    TextStyle(
                  color:
                      RiderColors.muted,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),

        if (action != null)
          TextButton(
            onPressed:
                onAction,
            child:
                Text(
              action,
              style:
                  const TextStyle(
                fontSize: 10,
              ),
            ),
          ),
      ],
    );
  }

  // ============================================================
  // ASSIGNMENT
  // ============================================================

  Widget _assignmentCard(
    RiderDelivery delivery,
  ) {
    final Color status =
        _statusColor(
      delivery,
    );

    return Container(
      padding:
          const EdgeInsets.all(
        13,
      ),
      decoration:
          BoxDecoration(
        color:
            RiderColors.surface,
        borderRadius:
            BorderRadius.circular(
          17,
        ),
        border:
            Border.all(
          color:
              RiderColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 40,
                height: 40,
                alignment:
                    Alignment.center,
                decoration:
                    BoxDecoration(
                  color:
                      _statusSoft(
                    delivery,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),
                child: Icon(
                  delivery
                          .isLogisticsPickup
                      ? Icons
                          .inventory_2_outlined
                      : Icons
                          .local_shipping_outlined,
                  color:
                      status,
                  size: 19,
                ),
              ),

              const SizedBox(
                width: 9,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: <Widget>[
                    Text(
                      delivery
                              .orderNumber
                              .trim()
                              .isEmpty
                          ? 'Rider Assignment'
                          : delivery
                              .orderNumber,
                      maxLines: 1,
                      overflow:
                          TextOverflow
                              .ellipsis,
                      style:
                          TextStyle(
                        color:
                            RiderColors.text,
                        fontSize: 11,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),

                    const SizedBox(
                      height: 2,
                    ),

                    Text(
                      delivery
                          .sellerName,
                      maxLines: 1,
                      overflow:
                          TextOverflow
                              .ellipsis,
                      style:
                          TextStyle(
                        color:
                            RiderColors.muted,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 7,
                  vertical: 4,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      _statusSoft(
                    delivery,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),
                ),
                child: Text(
                  delivery.statusLabel,
                  style:
                      TextStyle(
                    color:
                        status,
                    fontSize: 10,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 12,
          ),

          Container(
            width:
                double.infinity,
            padding:
                const EdgeInsets.all(
              10,
            ),
            decoration:
                BoxDecoration(
              color:
                  RiderColors.surfaceSoft,
              borderRadius:
                  BorderRadius.circular(
                12,
              ),
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(
                      Icons
                          .location_on_outlined,
                      color:
                          RiderColors.gold,
                      size: 14,
                    ),

                    const SizedBox(
                      width: 6,
                    ),

                    Expanded(
                      child: Text(
                        delivery
                                .destinationAddress
                                .trim()
                                .isEmpty
                            ? delivery
                                .destinationName
                            : delivery
                                .destinationAddress,
                        maxLines: 2,
                        overflow:
                            TextOverflow
                                .ellipsis,
                        style:
                            TextStyle(
                          color:
                              RiderColors.text,
                          fontSize: 10,
                          height: 1.3,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 8,
                ),

                Row(
                  children: <Widget>[
                    Icon(
                      Icons.route_outlined,
                      color:
                          RiderColors.blue,
                      size: 14,
                    ),

                    const SizedBox(
                      width: 6,
                    ),

                    Expanded(
                      child: Text(
                        delivery
                            .actionMessage,
                        maxLines: 2,
                        overflow:
                            TextOverflow
                                .ellipsis,
                        style:
                            TextStyle(
                          color:
                              RiderColors.muted,
                          fontSize: 10,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 11,
          ),

          SizedBox(
            width:
                double.infinity,
            height: 39,
            child:
                FilledButton.icon(
              onPressed: () {
                onAdvanceDelivery(
                  delivery,
                );
              },
              icon:
                  const Icon(
                Icons
                    .arrow_forward_rounded,
                size: 15,
              ),
              label:
                  Text(
                delivery.actionLabel,
                maxLines: 1,
                overflow:
                    TextOverflow
                        .ellipsis,
                style:
                    const TextStyle(
                  fontSize: 10,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyAssignment() {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        vertical: 25,
        horizontal: 18,
      ),
      decoration:
          BoxDecoration(
        color:
            RiderColors.surface,
        borderRadius:
            BorderRadius.circular(
          17,
        ),
        border:
            Border.all(
          color:
              RiderColors.border,
        ),
      ),
      child: Column(
        children: <Widget>[
          Container(
            width: 48,
            height: 48,
            alignment:
                Alignment.center,
            decoration:
                BoxDecoration(
              color:
                  RiderColors.goldSoft,
              shape:
                  BoxShape.circle,
            ),
            child: Icon(
              Icons
                  .inventory_2_outlined,
              color:
                  RiderColors.gold,
            ),
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
              fontSize: 11,
              fontWeight:
                  FontWeight.w800,
            ),
          ),

          const SizedBox(
            height: 4,
          ),

          Text(
            'New jobs will appear here once assigned.',
            textAlign:
                TextAlign.center,
            style:
                TextStyle(
              color:
                  RiderColors.muted,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // QUICK ACTIONS
  // ============================================================

  Widget _quickActions() {
    final actions = [
      (
        icon:
            Icons.inventory_2_outlined,
        label:
            'Pickups',
        color:
            RiderColors.gold,
        soft:
            RiderColors.goldSoft,
        tap:
            onOpenPickups,
      ),
      (
        icon:
            Icons.assignment_outlined,
        label:
            'Jobs',
        color:
            RiderColors.green,
        soft:
            RiderColors.greenSoft,
        tap: () {
          onTabChanged?.call(
            1,
          );
        },
      ),
      (
        icon:
            Icons.local_shipping_outlined,
        label:
            'Deliveries',
        color:
            RiderColors.blue,
        soft:
            RiderColors.blueSoft,
        tap: () {
          onTabChanged?.call(
            2,
          );
        },
      ),
      (
        icon:
            Icons.history_rounded,
        label:
            'History',
        color:
            RiderColors.purple,
        soft:
            RiderColors.purpleSoft,
        tap:
            onOpenHistory,
      ),
    ];

    return Row(
      children:
          List<Widget>.generate(
        actions.length,
        (
          int index,
        ) {
          final item =
              actions[index];

          return Expanded(
            child: Padding(
              padding:
                  EdgeInsets.only(
                right:
                    index ==
                            actions.length -
                                1
                        ? 0
                        : 7,
              ),
              child: InkWell(
                onTap:
                    item.tap,
                borderRadius:
                    BorderRadius.circular(
                  14,
                ),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 4,
                  ),
                  decoration:
                      BoxDecoration(
                    color:
                        RiderColors.surface,
                    borderRadius:
                        BorderRadius.circular(
                      14,
                    ),
                    border:
                        Border.all(
                      color:
                          RiderColors.border,
                    ),
                  ),
                  child: Column(
                    children: <Widget>[
                      Container(
                        width: 34,
                        height: 34,
                        alignment:
                            Alignment.center,
                        decoration:
                            BoxDecoration(
                          color:
                              item.soft,
                          borderRadius:
                              BorderRadius.circular(
                            10,
                          ),
                        ),
                        child: Icon(
                          item.icon,
                          color:
                              item.color,
                          size: 17,
                        ),
                      ),

                      const SizedBox(
                        height: 6,
                      ),

                      Text(
                        item.label,
                        maxLines: 1,
                        overflow:
                            TextOverflow
                                .ellipsis,
                        style:
                            TextStyle(
                          color:
                              RiderColors.text,
                          fontSize: 10,
                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // STATUS
  // ============================================================

  Widget _statusCard() {
    return Container(
      padding:
          const EdgeInsets.all(
        13,
      ),
      decoration:
          BoxDecoration(
        color:
            RiderColors.surface,
        borderRadius:
            BorderRadius.circular(
          16,
        ),
        border:
            Border.all(
          color:
              RiderColors.border,
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 42,
            height: 42,
            alignment:
                Alignment.center,
            decoration:
                BoxDecoration(
              color:
                  _online
                      ? RiderColors
                          .greenSoft
                      : RiderColors
                          .surfaceSoft,
              borderRadius:
                  BorderRadius.circular(
                12,
              ),
            ),
            child: Icon(
              Icons
                  .person_outline_rounded,
              color:
                  _online
                      ? RiderColors.green
                      : RiderColors.muted,
              size: 20,
            ),
          ),

          const SizedBox(
            width: 10,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  _name,
                  maxLines: 1,
                  overflow:
                      TextOverflow
                          .ellipsis,
                  style:
                      TextStyle(
                    color:
                        RiderColors.text,
                    fontSize: 10.5,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),

                const SizedBox(
                  height: 2,
                ),

                Text(
                  _online
                      ? 'Available for Rider assignments'
                      : 'Currently offline',
                  style:
                      TextStyle(
                    color:
                        RiderColors.muted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),

          Container(
            width: 8,
            height: 8,
            decoration:
                BoxDecoration(
              color:
                  _online
                      ? RiderColors.green
                      : RiderColors.muted,
              shape:
                  BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}