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
    required this.onProfileSection,
    required this.isDarkMode,
    required this.onDarkModeChanged,
  });

  final RiderProfile profile;

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
  final ValueChanged<String> onProfileSection;
  final bool isDarkMode;
  final ValueChanged<bool> onDarkModeChanged;

  String get _name {
    final String value = profile.fullName.trim();
    return value.isEmpty ? 'SARI Rider' : value;
  }

  bool get _online {
    final String value = profile.availabilityStatus.trim().toLowerCase();
    return value == 'online' || value == 'available' || value == 'active';
  }

  Widget _heading(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 18, 6),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: RiderColors.muted,
          letterSpacing: 1.3,
          fontWeight: FontWeight.w800,
          fontSize: 10.5,
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
    final Color accent = danger ? RiderColors.red : riderIconAccent(icon);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: <Widget>[
                RiderIconBadge(
                  icon: icon,
                  color: accent,
                  background: danger ? RiderColors.redSoft : accent.withValues(alpha: .11),
                  size: 39,
                  iconSize: 20,
                  radius: 12,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
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
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
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
    final String vehicleMeta = <String>[
      if (profile.vehicleType.trim().isNotEmpty) profile.vehicleType.trim(),
      if (profile.plateNumber.trim().isNotEmpty) profile.plateNumber.trim(),
    ].join(' • ');

    return Drawer(
      width: width > 420 ? 335 : width * .82,
      backgroundColor: RiderColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(
          left: Radius.circular(26),
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
                    margin: const EdgeInsets.fromLTRB(12, 10, 12, 6),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: RiderColors.heroGradient,
                      ),
                      border: Border.all(
                        color: const Color(0xFF3E3524),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: .14),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
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
                                color: Colors.white.withValues(alpha: .12),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: .14),
                                ),
                              ),
                              child: const Icon(
                                Icons.delivery_dining_rounded,
                                color: Color(0xFFF3C663),
                                size: 25,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: .12),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: .14),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _online
                                          ? const Color(0xFF34D399)
                                          : Colors.white54,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _online ? 'ONLINE' : 'OFFLINE',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: .4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              tooltip: 'Close',
                              visualDensity: VisualDensity.compact,
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(
                                Icons.close_rounded,
                                color: Colors.white70,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          _name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -.3,
                          ),
                        ),
                        if (profile.email.trim().isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            profile.email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                        if (vehicleMeta.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: .28),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              vehicleMeta,
                              style: const TextStyle(
                                color: Color(0xFFF3C663),
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  _heading('Rider operations'),
                  _item(
                    icon: Icons.inventory_2_outlined,
                    title: 'Seller Pickups',
                    subtitle: 'Assigned seller collections',
                    onTap: onPickups,
                  ),
                  _item(
                    icon: Icons.route_outlined,
                    title: 'Last-Mile Deliveries',
                    subtitle: 'Destination hub to buyer',
                    onTap: onLastMile,
                  ),
                  _item(
                    icon: Icons.qr_code_scanner_rounded,
                    title: 'Scan QR Code',
                    subtitle: 'Verify an assigned parcel',
                    onTap: onScanner,
                  ),
                  _heading('Management'),
                  _item(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'COD Remittance',
                    subtitle: 'Prepare collected COD cash',
                    onTap: onCod,
                  ),
                  _item(
                    icon: Icons.history_rounded,
                    title: 'Delivery History',
                    subtitle: 'Completed rider trips',
                    onTap: onHistory,
                  ),
                  _item(
                    icon: Icons.chat_bubble_outline_rounded,
                    title: 'Chat & Messaging',
                    onTap: onMessages,
                  ),
                  _item(
                    icon: Icons.notifications_none_rounded,
                    title: 'Notifications',
                    onTap: onNotifications,
                  ),
                  _heading('Account Information'),
                  _item(
                    icon: Icons.person_outline_rounded,
                    title: 'Personal Information',
                    onTap: () => onProfileSection('personal'),
                  ),
                  _item(
                    icon: Icons.two_wheeler_rounded,
                    title: 'Vehicle Information',
                    onTap: () => onProfileSection('vehicle'),
                  ),
                  _heading('Preferences & Security'),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    child: Container(
                      decoration: BoxDecoration(
                        color: RiderColors.surfaceSoft.withValues(alpha: .55),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: SwitchListTile.adaptive(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 12),
                        secondary: Container(
                          width: 38,
                          height: 38,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: RiderColors.surface,
                            borderRadius: BorderRadius.circular(11),
                            border: Border.all(color: RiderColors.border),
                          ),
                          child: Icon(
                            Icons.brightness_6_outlined,
                            size: 18,
                            color: RiderColors.text,
                          ),
                        ),
                        title: Text(
                          'Appearance',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: RiderColors.text,
                          ),
                        ),
                        subtitle: Text(
                          isDarkMode ? 'Dark Mode' : 'Light Mode',
                          style: TextStyle(
                            fontSize: 11,
                            color: RiderColors.muted,
                          ),
                        ),
                        value: isDarkMode,
                        activeTrackColor: RiderColors.gold,
                        onChanged: onDarkModeChanged,
                      ),
                    ),
                  ),
                  _item(
                    icon: Icons.shield_outlined,
                    title: 'Security',
                    onTap: () => onProfileSection('security'),
                  ),
                  const SizedBox(height: 14),
                ],
              ),
            ),
            Divider(
              color: RiderColors.border,
              height: 1,
            ),
            const SizedBox(height: 4),
            _item(
              icon: Icons.logout_rounded,
              title: 'Log Out',
              danger: true,
              onTap: onLogout,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}