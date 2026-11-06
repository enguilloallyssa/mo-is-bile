import 'package:flutter/material.dart';

import 'widgets/logistics_ui.dart';

class LogisticsOperations extends StatelessWidget {
  const LogisticsOperations({
    super.key,
    required this.onScan,
    required this.onIncoming,
    required this.onSorting,
    required this.onPickups,
    required this.onLastMile,
    required this.onMonitoring,
    required this.onRemittances,
  });

  final VoidCallback onScan;
  final VoidCallback onIncoming;
  final VoidCallback onSorting;
  final VoidCallback onPickups;
  final VoidCallback onLastMile;
  final VoidCallback onMonitoring;
  final VoidCallback onRemittances;

  @override
  Widget build(
    BuildContext context,
  ) {
    return ListView(
      padding:
          const EdgeInsets.fromLTRB(
        15,
        17,
        15,
        30,
      ),

      children: [
        const LogisticsSectionTitle(
          title:
              'Hub floor operations',

          subtitle:
              'Quick access to everyday intake and movement tasks.',
        ),

        const SizedBox(
          height: 13,
        ),

        LogisticsSurface(
          color:
              LogisticsPalette.navy,

          child:
              Row(
            children: [
              const Icon(
                Icons.qr_code_scanner_rounded,

                color:
                    Color(
                  0xFFFFD88C,
                ),

                size:
                    32,
              ),

              const SizedBox(
                width: 12,
              ),

              const Expanded(
                child:
                    Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    Text(
                      'Parcel Scanner',

                      style:
                          TextStyle(
                        color:
                            Colors.white,

                        fontSize:
                            15,

                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),

                    SizedBox(
                      height: 4,
                    ),

                    Text(
                      'Scan a QR/barcode on the parcel label.',

                      style:
                          TextStyle(
                        color:
                            Colors.white70,

                        fontSize:
                            10,

                        height:
                            1.4,
                      ),
                    ),
                  ],
                ),
              ),

              IconButton.filled(
                onPressed:
                    onScan,

                style:
                    IconButton.styleFrom(
                  backgroundColor:
                      LogisticsPalette.gold,
                ),

                icon:
                    const Icon(
                  Icons.arrow_forward_rounded,
                ),

                tooltip:
                    'Open scanner',
              ),
            ],
          ),
        ),

        const SizedBox(
          height: 21,
        ),

        const LogisticsSectionTitle(
          title:
              'Parcel handling',

          subtitle:
              'Hub intake and sorting queues.',
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
              'Origin-hub Rider handoffs and parcel receiving.',

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
              'Sort by destination hub and local delivery area.',

          onTap:
              onSorting,
        ),

        const SizedBox(
          height: 21,
        ),

        const LogisticsSectionTitle(
          title:
              'Assignments',

          subtitle:
              'Quick queue access; bulk planning stays on the web.',
        ),

        const SizedBox(
          height: 11,
        ),

        LogisticsActionTile(
          icon:
              Icons.fact_check_outlined,

          title:
              'Pickup requests',

          subtitle:
              'Review pending seller pickup verification.',

          onTap:
              onPickups,
        ),

        const SizedBox(
          height: 9,
        ),

        LogisticsActionTile(
          icon:
              Icons.local_shipping_outlined,

          title:
              'Last-mile queue',

          subtitle:
              'Review deliveries ready for barangay Riders.',

          color:
              LogisticsPalette.green,

          background:
              LogisticsPalette.greenPale,

          onTap:
              onLastMile,
        ),

        const SizedBox(
          height: 21,
        ),

        const LogisticsSectionTitle(
          title:
              'Tracking',

          subtitle:
              'Read-only status lookup for deliveries.',
        ),

        const SizedBox(
          height: 11,
        ),

        LogisticsActionTile(
          icon:
              Icons.route_outlined,

          title:
              'Delivery monitoring',

          subtitle:
              'Search parcels and inspect delivery progress.',

          color:
              LogisticsPalette.blue,

          background:
              LogisticsPalette.bluePale,

          onTap:
              onMonitoring,
        ),

        const SizedBox(
          height: 9,
        ),

        LogisticsActionTile(
          icon:
              Icons.payments_outlined,

          title:
              'COD cash intake',

          subtitle:
              'Count and verify Rider physical COD remittance batches.',

          color:
              LogisticsPalette.green,

          background:
              LogisticsPalette.greenPale,

          onTap:
              onRemittances,
        ),

        const SizedBox(
          height: 17,
        ),
      ],
    );
  }
}