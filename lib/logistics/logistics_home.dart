import 'package:flutter/material.dart';

import 'services/logistics_session.dart';
import '../services/sari_live_data.dart';
import 'widgets/logistics_ui.dart';

class LogisticsHome extends StatelessWidget {
  const LogisticsHome({
    super.key,
    required this.session,
    required this.onRefresh,
    required this.onOperations,
    required this.onScan,
    required this.onTransfers,
    required this.onIncoming,
    required this.onSorting,
  });

  final LogisticsSession session;

  final Future<void> Function()
      onRefresh;

  final VoidCallback onOperations;
  final VoidCallback onScan;
  final VoidCallback onTransfers;
  final VoidCallback onIncoming;
  final VoidCallback onSorting;

  String _greeting() {
    final hour =
        DateTime.now().hour;

    return hour < 12
        ? 'Good morning'
        : hour < 18
            ? 'Good afternoon'
            : 'Good evening';
  }

  String _date() {
    const days =
        [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ];

    const months =
        [
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

    final now =
        DateTime.now();

    return '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }

  Widget _metric(
    String title,
    String count,
    IconData icon,
    Color accent,
    Color soft,
  ) {
    return LogisticsSurface(
      padding:
          const EdgeInsets.all(
        13,
      ),

      child:
          Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,

                decoration:
                    BoxDecoration(
                  color:
                      soft,

                  borderRadius:
                      BorderRadius.circular(
                    11,
                  ),
                ),

                child:
                    Icon(
                  icon,
                  color:
                      accent,
                  size: 18,
                ),
              ),

              const Spacer(),

              Text(
                count,

                style:
                    const TextStyle(
                  fontSize: 25,
                  fontWeight:
                      FontWeight.w900,
                  color:
                      LogisticsPalette.ink,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 10,
          ),

          Text(
            title,

            maxLines: 1,

            overflow:
                TextOverflow.ellipsis,

            style:
                const TextStyle(
              fontSize: 11,
              fontWeight:
                  FontWeight.w800,
              color:
                  LogisticsPalette.ink,
            ),
          ),

          const SizedBox(
            height: 3,
          ),

          const Text(
            'Live Laravel',

            style:
                TextStyle(
              fontSize: 9,
              color:
                  LogisticsPalette.muted,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final firstName =
        session.name
            .split(' ')
            .first;

    return RefreshIndicator(
      onRefresh:
          onRefresh,

      color:
          LogisticsPalette.gold,

      child:
          ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),

        padding:
            const EdgeInsets.fromLTRB(
          15,
          14,
          15,
          28,
        ),

        children: [
          Container(
            padding:
                const EdgeInsets.all(
              20,
            ),

            decoration:
                BoxDecoration(
              gradient:
                  const LinearGradient(
                begin:
                    Alignment.topLeft,

                end:
                    Alignment.bottomRight,

                colors: [
                  LogisticsPalette.navy,
                  Color(
                    0xFF39424B,
                  ),
                  Color(
                    0xFF997019,
                  ),
                ],
              ),

              borderRadius:
                  BorderRadius.circular(
                22,
              ),

              boxShadow:
                  const [
                BoxShadow(
                  color:
                      Color(
                    0x211A2638,
                  ),

                  blurRadius:
                      20,

                  offset:
                      Offset(
                    0,
                    8,
                  ),
                ),
              ],
            ),

            child:
                Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.warehouse_outlined,

                      color:
                          Color(
                        0xFFFFD88C,
                      ),

                      size:
                          20,
                    ),

                    const SizedBox(
                      width: 8,
                    ),

                    const Expanded(
                      child:
                          Text(
                        'LOGISTICS OPERATIONS',

                        style:
                            TextStyle(
                          color:
                              Color(
                            0xFFFFD88C,
                          ),

                          fontSize:
                              9,

                          letterSpacing:
                              1.1,

                          fontWeight:
                              FontWeight.w900,
                        ),
                      ),
                    ),

                    Container(
                      width: 6,
                      height: 6,

                      decoration:
                          const BoxDecoration(
                        color:
                            Color(
                          0xFF8FDAB2,
                        ),

                        shape:
                            BoxShape.circle,
                      ),
                    ),

                    const SizedBox(
                      width: 6,
                    ),

                    const Text(
                      'WORKSPACE',

                      style:
                          TextStyle(
                        color:
                            Colors.white70,

                        fontSize:
                            8,

                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 18,
                ),

                Text(
                  '${_greeting()},',

                  style:
                      const TextStyle(
                    color:
                        Colors.white70,

                    fontSize:
                        11,
                  ),
                ),

                const SizedBox(
                  height: 3,
                ),

                Text(
                  firstName,

                  maxLines: 1,

                  overflow:
                      TextOverflow.ellipsis,

                  style:
                      const TextStyle(
                    color:
                        Colors.white,

                    fontSize:
                        28,

                    fontWeight:
                        FontWeight.w900,

                    letterSpacing:
                        -.8,
                  ),
                ),

                const SizedBox(
                  height: 5,
                ),

                Text(
                  _date(),

                  style:
                      const TextStyle(
                    color:
                        Colors.white60,

                    fontSize:
                        10,
                  ),
                ),

                const SizedBox(
                  height: 19,
                ),

                const Text(
                  'Ready for your next parcel handoff?',

                  style:
                      TextStyle(
                    color:
                        Colors.white,

                    fontSize:
                        12.5,

                    fontWeight:
                        FontWeight.w700,
                  ),
                ),

                const SizedBox(
                  height: 12,
                ),

                SizedBox(
                  width:
                      double.infinity,

                  child:
                      FilledButton.icon(
                    onPressed:
                        onScan,

                    style:
                        FilledButton.styleFrom(
                      backgroundColor:
                          LogisticsPalette.gold,

                      foregroundColor:
                          Colors.white,

                      padding:
                          const EdgeInsets.symmetric(
                        vertical: 12,
                      ),
                    ),

                    icon:
                        const Icon(
                      Icons.qr_code_scanner_rounded,
                    ),

                    label:
                        const Text(
                      'Open Parcel Scanner',
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 22,
          ),

          const LogisticsSectionTitle(
            title:
                'Operations snapshot',

            subtitle:
                'Live counts from your Logistics provider account.',
          ),

          const SizedBox(
            height: 11,
          ),

          FutureBuilder<Map<String, dynamic>>(
            future:
                SariLiveData.instance.logisticsDashboard(),

            builder: (
              context,
              snapshot,
            ) {
              final raw =
                  snapshot.data?['data'];

              final counts =
                  raw is Map
                      ? Map<String, dynamic>.from(
                          raw,
                        )
                      : <String, dynamic>{};

              String n(
                String key,
              ) =>
                  snapshot.hasError
                      ? '!'
                      : snapshot.connectionState ==
                              ConnectionState.waiting
                          ? '…'
                          : counts.containsKey(key)
                              ? '${counts[key]}'
                              : '—';

              return Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  if (snapshot.hasError)
                    Padding(
                      padding:
                          const EdgeInsets.only(
                        bottom: 8,
                      ),

                      child:
                          Text(
                        'Dashboard API: ${snapshot.error}',

                        style:
                            const TextStyle(
                          color:
                              Colors.red,

                          fontSize:
                              11,
                        ),
                      ),
                    ),

                  GridView.count(
                    crossAxisCount:
                        2,

                    shrinkWrap:
                        true,

                    physics:
                        const NeverScrollableScrollPhysics(),

                    crossAxisSpacing:
                        9,

                    mainAxisSpacing:
                        9,

                    childAspectRatio:
                        1.55,

                    children: [
                      _metric(
                        'Incoming',
                        n(
                          'incoming',
                        ),
                        Icons.move_to_inbox_outlined,
                        LogisticsPalette.blue,
                        LogisticsPalette.bluePale,
                      ),

                      _metric(
                        'For Sorting',
                        n(
                          'sorting',
                        ),
                        Icons.account_tree_outlined,
                        LogisticsPalette.goldDark,
                        LogisticsPalette.goldPale,
                      ),

                      _metric(
                        'Transfers',
                        n(
                          'transfers',
                        ),
                        Icons.swap_horiz_rounded,
                        LogisticsPalette.blue,
                        LogisticsPalette.bluePale,
                      ),

                      _metric(
                        'Last Mile',
                        n(
                          'lastMile',
                        ),
                        Icons.local_shipping_outlined,
                        LogisticsPalette.green,
                        LogisticsPalette.greenPale,
                      ),
                    ],
                  ),
                ],
              );
            },
          ),

          const SizedBox(
            height: 22,
          ),

          LogisticsSectionTitle(
            title:
                'Parcel workflow',

            subtitle:
                'Go directly to the hub task you need.',

            trailing:
                TextButton(
              onPressed:
                  onOperations,

              child:
                  const Text(
                'View all',
              ),
            ),
          ),

          const SizedBox(
            height: 11,
          ),

          LogisticsActionTile(
            icon:
                Icons.move_to_inbox_outlined,

            title:
                'Incoming parcels',

            subtitle:
                'Receive parcels handed over by pickup Riders.',

            color:
                LogisticsPalette.blue,

            background:
                LogisticsPalette.bluePale,

            onTap:
                onIncoming,
          ),

          const SizedBox(
            height: 9,
          ),

          LogisticsActionTile(
            icon:
                Icons.account_tree_outlined,

            title:
                'Parcel sorting',

            subtitle:
                'Sort received parcels by destination and route.',

            onTap:
                onSorting,
          ),

          const SizedBox(
            height: 9,
          ),

          LogisticsActionTile(
            icon:
                Icons.swap_horiz_rounded,

            title:
                'Hub transfers',

            subtitle:
                'Outgoing manifests and incoming branch transfers.',

            color:
                LogisticsPalette.green,

            background:
                LogisticsPalette.greenPale,

            onTap:
                onTransfers,
          ),

          const SizedBox(
            height: 17,
          ),

          const LogisticsInfoBanner(
            message:
                'Live API workflows require the matching Laravel patch to be deployed first.',
          ),
        ],
      ),
    );
  }
}