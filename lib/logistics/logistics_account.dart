import 'package:flutter/material.dart';
import 'services/logistics_session.dart';
import 'widgets/logistics_ui.dart';

class LogisticsAccount extends StatelessWidget {
  const LogisticsAccount({
    super.key,
    required this.session,
    required this.profileError,
    required this.refreshing,
    required this.signingOut,
    required this.onRefresh,
    required this.onLogout,
  });

  final LogisticsSession session;
  final String? profileError;
  final bool refreshing;
  final bool signingOut;
  final Future<void> Function() onRefresh;
  final VoidCallback onLogout;

  Widget _row(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        children: [
          Icon(icon, color: LogisticsPalette.muted, size: 18),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: LogisticsPalette.muted,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value.isEmpty
                      ? 'Not provided by account API'
                      : value,
                  style: const TextStyle(
                    color: LogisticsPalette.ink,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: LogisticsPalette.gold,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(15, 16, 15, 32),
        children: [
          LogisticsSurface(
            child: Column(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: LogisticsPalette.goldPale,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warehouse_outlined,
                    size: 33,
                    color: LogisticsPalette.goldDark,
                  ),
                ),
                const SizedBox(height: 11),
                Text(
                  session.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 19,
                    color: LogisticsPalette.ink,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  session.email.isEmpty
                      ? 'Authenticated Logistics workspace'
                      : session.email,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: LogisticsPalette.muted,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 12),
                LogisticsTag(
                  label: session.role.toUpperCase(),
                  icon: Icons.verified_user_outlined,
                ),
              ],
            ),
          ),
          if (profileError != null) ...[
            const SizedBox(height: 12),
            LogisticsInfoBanner(message: profileError!),
          ],
          const SizedBox(height: 23),
          const LogisticsSectionTitle(
            title: 'Account & operating branch',
            subtitle:
                'Information available from the shared authenticated account API.',
          ),
          const SizedBox(height: 11),
          LogisticsSurface(
            child: Column(
              children: [
                _row(
                  'Business / provider',
                  session.business,
                  Icons.business_outlined,
                ),
                const Divider(
                  height: 1,
                  color: LogisticsPalette.border,
                ),
                _row(
                  'Operating branch',
                  session.branch,
                  Icons.location_city_outlined,
                ),
                const Divider(
                  height: 1,
                  color: LogisticsPalette.border,
                ),
                _row(
                  'Account role',
                  session.role,
                  Icons.badge_outlined,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const LogisticsInfoBanner(
            message:
                'Operating hubs are loaded from Laravel and selected per operation. '
                'Facility administration and provider account editing remain desktop-first.',
          ),
          const SizedBox(height: 21),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: refreshing ? null : onRefresh,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(
                refreshing
                    ? 'Refreshing account…'
                    : 'Refresh account',
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: signingOut ? null : onLogout,
              style: OutlinedButton.styleFrom(
                foregroundColor: LogisticsPalette.danger,
                side: const BorderSide(
                  color: Color(0xFFE8BDBD),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 13,
                ),
              ),
              icon: const Icon(Icons.logout_rounded),
              label: Text(
                signingOut
                    ? 'Signing out…'
                    : 'Log Out',
              ),
            ),
          ),
        ],
      ),
    );
  }
}