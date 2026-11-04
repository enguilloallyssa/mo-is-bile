import 'package:flutter/material.dart';

import '../models/rider_profile_model.dart';
import 'rider_ui.dart';

/// Mobile-first navigation for all Rider workflows. This is a navigation
/// surface only: every workflow uses existing shell callbacks and Laravel APIs.
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
  final int activeIndex;
  final VoidCallback onDashboard;
  final VoidCallback onAssignments;
  final VoidCallback onPickups;
  final VoidCallback onDeliveries;
  final VoidCallback onLastMile;
  final VoidCallback onScanner;
  final VoidCallback onEarnings;
  final VoidCallback onCod;
  final VoidCallback onHistory;
  final VoidCallback onMessages;
  final VoidCallback onNotifications;
  final VoidCallback onProfile;
  final VoidCallback onLogout;

  Widget _heading(String label) => Padding(
        padding: const EdgeInsets.fromLTRB(22, 20, 16, 8),
        child: Text(label.toUpperCase(), style: TextStyle(
          color: RiderColors.muted,
          letterSpacing: 1.35,
          fontWeight: FontWeight.w800,
          fontSize: 10,
        )),
      );

  Widget _item({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool active = false,
    bool danger = false,
  }) {
    final foreground = danger
        ? RiderColors.red
        : active ? RiderColors.goldDark : RiderColors.text;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: active ? RiderColors.goldSoft : Colors.transparent,
        borderRadius: BorderRadius.circular(13),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(13),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(children: [
              Icon(icon, size: 21, color: foreground),
              const SizedBox(width: 14),
              Expanded(child: Text(title, style: TextStyle(
                fontSize: 13.5,
                fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                color: foreground,
              ))),
              if (active) Icon(Icons.chevron_right_rounded, size: 17, color: foreground),
            ]),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = profile.fullName.trim().isEmpty ? 'SARI Rider' : profile.fullName;
    final online = profile.availabilityStatus.toLowerCase() == 'online';
    return Drawer(
      width: MediaQuery.sizeOf(context).width * .82,
      backgroundColor: RiderColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.horizontal(right: Radius.circular(22))),
      child: SafeArea(
        child: Column(children: [
          Expanded(child: ListView(children: [
            Container(
              margin: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(colors: RiderColors.heroGradient),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(
                    height: 54, width: 54,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .16),
                      border: Border.all(color: Colors.white38),
                      borderRadius: BorderRadius.circular(17),
                    ),
                    child: const Icon(Icons.delivery_dining_rounded, color: Colors.white, size: 30),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Close menu',
                    color: Colors.white,
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ]),
                const SizedBox(height: 14),
                Text(name, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(profile.email, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10.5, color: Colors.white70)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: .14), borderRadius: BorderRadius.circular(22)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.circle, size: 8, color: online ? const Color(0xFF83E5A3) : Colors.white70),
                    const SizedBox(width: 7),
                    Text(online ? 'Online' : 'Offline', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                  ]),
                ),
              ]),
            ),
            _heading('Workspace'),
            _item(icon: Icons.grid_view_rounded, title: 'Dashboard', active: activeIndex == 0, onTap: onDashboard),
            _item(icon: Icons.assignment_outlined, title: 'Pickup Assignments', active: activeIndex == 1, onTap: onAssignments),
            _item(icon: Icons.inventory_2_outlined, title: 'Seller Pickups', onTap: onPickups),
            _item(icon: Icons.local_shipping_outlined, title: 'Active Deliveries', active: activeIndex == 2, onTap: onDeliveries),
            _item(icon: Icons.route_rounded, title: 'Last-Mile Deliveries', onTap: onLastMile),
            _item(icon: Icons.qr_code_scanner_rounded, title: 'Parcel Scanner', onTap: onScanner),
            _heading('Finance & Records'),
            _item(icon: Icons.account_balance_wallet_outlined, title: 'Earnings', active: activeIndex == 3, onTap: onEarnings),
            _item(icon: Icons.payments_outlined, title: 'COD Remittance', onTap: onCod),
            _item(icon: Icons.history_rounded, title: 'Delivery History', onTap: onHistory),
            _heading('Communication & Account'),
            _item(icon: Icons.chat_bubble_outline_rounded, title: 'Messages', onTap: onMessages),
            _item(icon: Icons.notifications_none_rounded, title: 'Notifications', onTap: onNotifications),
            _item(icon: Icons.person_outline_rounded, title: 'Rider Profile', active: activeIndex == 4, onTap: onProfile),
            const SizedBox(height: 12),
          ])),
          Divider(color: RiderColors.border, height: 1),
          _item(icon: Icons.logout_rounded, title: 'Log Out', danger: true, onTap: onLogout),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }
}
