import 'package:flutter/material.dart';

import '../models/rider_profile_model.dart';
import 'rider_ui.dart';

class RiderDrawer extends StatelessWidget {
  const RiderDrawer({
    super.key,
    required this.profile,
    required this.activeIndex,
    required this.onDashboard,
    required this.onAssignments,
    required this.onPickups,
    required this.onDeliveries,
    required this.onLastMile,
    required this.onScanner,
    required this.onEarnings,
    required this.onCod,
    required this.onHistory,
    required this.onMessages,
    required this.onNotifications,
    required this.onProfile,
    required this.onLogout,
  });

  final RiderProfile profile;

  // These are kept so RiderShell does not need backend or navigation changes.
  // Main pages are intentionally hidden from the drawer because they already
  // exist in the bottom navigation.
  final int activeIndex;
  final VoidCallback onDashboard;
  final VoidCallback onAssignments;
  final VoidCallback onPickups;
  final VoidCallback onDeliveries;
  final VoidCallback onLastMile;
  final VoidCallback onEarnings;
  final VoidCallback onProfile;

  final VoidCallback onScanner;
  final VoidCallback onCod;
  final VoidCallback onHistory;
  final VoidCallback onMessages;
  final VoidCallback onNotifications;
  final VoidCallback onLogout;

  String get _name {
    final String value = profile.fullName.trim();
    return value.isEmpty ? 'SARI Rider' : value;
  }

  bool get _online {
    final String value = profile.availabilityStatus.trim().toLowerCase();
    return value == 'online' ||
        value == 'available' ||
        value == 'active';
  }

  Widget _heading(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 18, 7),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: RiderColors.muted,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w800,
          fontSize: 8.5,
        ),
      ),
    );
  }

  Widget _item({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    String? subtitle,
    bool danger = false,
  }) {
    final Color foreground = danger ? RiderColors.red : RiderColors.text;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(13),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(13),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
            child: Row(
              children: <Widget>[
                Container(
                  width: 35,
                  height: 35,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: danger
                        ? RiderColors.redSoft
                        : RiderColors.surfaceSoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: foreground,
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: foreground,
                        ),
                      ),
                      if (subtitle != null) ...<Widget>[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: RiderColors.muted,
                            fontSize: 7.5,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_left_rounded,
                  size: 16,
                  color: danger ? RiderColors.red : RiderColors.muted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;

    return Drawer(
      width: width > 420 ? 330 : width * .80,
      backgroundColor: RiderColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(
          left: Radius.circular(23),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.fromLTRB(11, 9, 11, 4),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(19),
                      gradient: LinearGradient(
                        colors: RiderColors.heroGradient,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Container(
                              width: 46,
                              height: 46,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: .13),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.delivery_dining_rounded,
                                color: Colors.white,
                                size: 25,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: .11),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _online
                                          ? const Color(0xFF7CDEA0)
                                          : Colors.white54,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    _online ? 'ONLINE' : 'OFFLINE',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 6.5,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              tooltip: 'Close',
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(
                                Icons.close_rounded,
                                color: Colors.white70,
                                size: 19,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          profile.email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 8.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          <String>[
                            if (profile.vehicleType.trim().isNotEmpty)
                              profile.vehicleType,
                            if (profile.plateNumber.trim().isNotEmpty)
                              profile.plateNumber,
                          ].join(' • '),
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 7,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _heading('Rider Tools'),
                  _item(
                    icon: Icons.qr_code_scanner_rounded,
                    title: 'Parcel Scanner',
                    subtitle: 'Scan and verify parcel QR codes',
                    onTap: onScanner,
                  ),
                  _item(
                    icon: Icons.payments_outlined,
                    title: 'COD Remittance',
                    subtitle: 'Manage collected COD cash',
                    onTap: onCod,
                  ),
                  _item(
                    icon: Icons.history_rounded,
                    title: 'Delivery History',
                    subtitle: 'Review completed Rider trips',
                    onTap: onHistory,
                  ),
                  _heading('Communication'),
                  _item(
                    icon: Icons.chat_bubble_outline_rounded,
                    title: 'Messages',
                    subtitle: 'Logistics communication',
                    onTap: onMessages,
                  ),
                  _item(
                    icon: Icons.notifications_none_rounded,
                    title: 'Notifications',
                    subtitle: 'Assignment and delivery updates',
                    onTap: onNotifications,
                  ),
                  const SizedBox(height: 14),
                ],
              ),
            ),
            Divider(
              color: RiderColors.border,
              height: 1,
            ),
            _item(
              icon: Icons.logout_rounded,
              title: 'Log Out',
              danger: true,
              onTap: onLogout,
            ),
            const SizedBox(height: 7),
          ],
        ),
      ),
    );
  }
}
