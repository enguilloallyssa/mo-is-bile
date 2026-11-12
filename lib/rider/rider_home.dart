import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'models/rider_delivery_model.dart';
import 'models/rider_profile_model.dart';
import 'widgets/rider_hero.dart';
import 'widgets/rider_map.dart';
import 'widgets/rider_ui.dart';
import 'widgets/rider_figma_components.dart';

/// Drop-in dashboard. Retains the public constructor used by the previous
/// RiderHome and only reads values supplied by the existing Flutter app.
/// No demo counts, requests, local database writes, or server changes.
class RiderHome extends StatefulWidget {
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
    this.dashboardSummary = const <String, dynamic>{},
    this.onTabChanged,
    this.onOpenNotifications,
    this.profilePhotoUrl,
  });

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
  final Future<void> Function()? onRefresh;
  final Map<String, dynamic> dashboardSummary;

  /// Optional: connect your current notification page/modal handler here.
  final VoidCallback? onOpenNotifications;

  /// Optional URL supplied by RiderShell from its existing riderProfile API.
  final String? profilePhotoUrl;

  @override
  State<RiderHome> createState() => _RiderHomeState();
}

class _RiderHomeState extends State<RiderHome> {
  int _localTab = 0;

  String get _riderName {
    final first = widget.profile.firstName.trim();
    final last = widget.profile.lastName.trim();
    final name = [first, last].where((part) => part.isNotEmpty).join(' ');
    return name.isEmpty ? 'SARI Rider' : name;
  }

  bool get _online {
    final status = widget.profile.availabilityStatus.trim().toLowerCase();
    return status == 'online' || status == 'active' || status == 'available';
  }

  /// Existing Laravel APIs may serialize the dashboard keys differently.
  /// Accept common aliases without creating or inventing KPI values.
  dynamic _lookupValue(List<String> aliases) {
    final sources = <Map<String, dynamic>>[widget.dashboardSummary];
    for (final key in const ['summary', 'stats', 'counts', 'metrics', 'dashboard']) {
      final item = widget.dashboardSummary[key];
      if (item is Map<String, dynamic>) sources.add(item);
    }
    for (final source in sources) {
      for (final key in aliases) {
        if (source.containsKey(key) && source[key] != null) {
          return source[key];
        }
      }
    }
    return null;
  }

  int _summaryInt(List<String> aliases) {
    final value = _lookupValue(aliases);
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? 0;
  }

  double _summaryDouble(List<String> aliases) {
    final value = _lookupValue(aliases);
    if (value is num) return value.toDouble();
    return double.tryParse('$value') ?? 0;
  }

  String _peso(double number) => '₱${number.toStringAsFixed(2)}';

  int get _pickups => _summaryInt(const [
        'active_pickups',
        'pickup_active',
        'pickups_active',
        'active_pickup_count',
        'pickup_count',
      ]);

  int get _deliveries => _summaryInt(const [
        'active_deliveries',
        'direct_active',
        'active_direct_deliveries',
        'delivery_active',
        'direct_delivery_count',
      ]);

  int get _lastMile => _summaryInt(const [
        'last_mile_batches',
        'last_mile_active',
        'active_last_mile',
        'active_last_mile_batches',
        'last_mile_count',
      ]);

  int get _completed => _summaryInt(const [
        'completed_today',
        'deliveries_completed_today',
        'completed_deliveries_today',
        'completed_count',
      ]);

  double get _earnings => _summaryDouble(const [
        'earnings_today',
        'today_earnings',
        'total_earnings_today',
        'today_total',
      ]);

  /// Fallback for APIs that already include the avatar URL in dashboard data.
  String? get _photoUrl {
    final explicit = widget.profilePhotoUrl?.trim();
    if (explicit != null && explicit.isNotEmpty) return explicit;
    final maps = <Map<String, dynamic>>[widget.dashboardSummary];
    for (final key in const ['profile', 'rider', 'user', 'account']) {
      final nested = widget.dashboardSummary[key];
      if (nested is Map) maps.add(Map<String, dynamic>.from(nested));
    }
    for (final map in maps) {
      for (final key in const [
        'profile_photo_url', 'profile_picture_url', 'profile_image_url',
        'photo_url', 'avatar_url', 'image_url',
      ]) {
        final value = map[key];
        if (value is String && value.trim().isNotEmpty) return value.trim();
      }
    }
    return null;
  }

  bool get _summaryAvailable => widget.dashboardSummary.isNotEmpty;

  void _changeTab(int index) {
    // The app's existing router owns all other pages if this was provided.
    if (widget.onTabChanged != null) {
      widget.onTabChanged!(index);
      return;
    }
    // Only use built-in lightweight pages when no existing tab router exists.
    setState(() => _localTab = index);
  }

  void _showNotifications() {
    if (widget.onOpenNotifications != null) {
      widget.onOpenNotifications!();
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: kPageBg,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const RiderEyebrow(label: 'Notifications'),
            const SizedBox(height: 12),
            const RiderSectionHeading(
              title: 'Rider alerts',
              subtitle: 'Your existing notification source is not wired here yet.',
            ),
            const SizedBox(height: 16),
            RiderActionCard(
              icon: Icons.chat_bubble_outline,
              title: 'Open messages',
              subtitle: 'View messages using your existing app flow',
              onTap: () {
                Navigator.pop(ctx);
                widget.onOpenMessages();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openRiderMenu() {
    // Open the REAL endDrawer in RiderShell, preserving the scanner,
    // last-mile, remittance and other existing Rider actions.
    final open = RiderMenuController.open;
    if (open != null) {
      open();
    } else {
      _showMenu();
    }
  }

  void _showMenu() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: kPageBg,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const RiderEyebrow(label: 'Rider menu'),
                const SizedBox(height: 10),
                RiderSectionHeading(
                  title: _riderName,
                  subtitle: _online ? 'Currently online' : 'Currently offline',
                ),
                const SizedBox(height: 18),
                RiderActionCard(
                  icon: Icons.inventory_2_outlined,
                  title: 'Pickup requests',
                  subtitle: 'Open your existing pickup workflow',
                  onTap: () {
                    Navigator.pop(ctx);
                    widget.onOpenPickups();
                  },
                ),
                const SizedBox(height: 10),
                RiderActionCard(
                  icon: Icons.chat_bubble_outline,
                  title: 'Messages',
                  subtitle: 'Conversations and updates',
                  onTap: () {
                    Navigator.pop(ctx);
                    widget.onOpenMessages();
                  },
                  iconBackground: const Color(0xFFE0F2FE),
                  iconColor: const Color(0xFF0284C7),
                ),
                const SizedBox(height: 10),
                RiderActionCard(
                  icon: Icons.history_rounded,
                  title: 'Delivery history',
                  subtitle: 'View completed work',
                  onTap: () {
                    Navigator.pop(ctx);
                    widget.onOpenHistory();
                  },
                  iconBackground: const Color(0xFFD1FAE5),
                  iconColor: const Color(0xFF059669),
                ),
                const SizedBox(height: 10),
                SwitchListTile.adaptive(
                  value: widget.isDarkMode,
                  onChanged: widget.onDarkModeChanged,
                  title: const Text('Dark mode'),
                  subtitle: const Text('Uses the app’s existing theme preference'),
                  activeThumbColor: RiderFigmaColors.green,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _refresh() async {
    if (widget.onRefresh != null) await widget.onRefresh!();
  }

  List<RiderStatData> get _stats => [
        RiderStatData(
          label: 'Active pickups',
          subtitle: 'Seller collections',
          icon: Icons.inventory_2_outlined,
          count: _pickups,
          iconBackground: const Color(0xFFFEF3C7),
          iconColor: const Color(0xFFD97706),
          barColors: const [Color(0xFFFCD34D), Color(0xFFF59E0B)],
        ),
        RiderStatData(
          label: 'Active deliveries',
          subtitle: 'Direct delivery',
          icon: Icons.local_shipping_outlined,
          count: _deliveries,
          iconBackground: const Color(0xFFE0F2FE),
          iconColor: const Color(0xFF0284C7),
          barColors: const [Color(0xFF7DD3FC), Color(0xFF0EA5E9)],
        ),
        RiderStatData(
          label: 'Last-mile batches',
          subtitle: 'Assigned to you',
          icon: Icons.route,
          count: _lastMile,
          iconBackground: const Color(0xFFEDE9FE),
          iconColor: const Color(0xFF7C3AED),
          barColors: const [Color(0xFFC4B5FD), Color(0xFF8B5CF6)],
        ),
        RiderStatData(
          label: 'Completed',
          subtitle: 'Finished today',
          icon: Icons.done_all,
          count: _completed,
          iconBackground: const Color(0xFFD1FAE5),
          iconColor: const Color(0xFF059669),
          barColors: const [Color(0xFF6EE7B7), Color(0xFF10B981)],
        ),
      ];

  Widget _home() {
    final stats = _stats;
    return RefreshIndicator(
      color: RiderFigmaColors.green,
      onRefresh: _refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          RiderHero(
            name: 'SARI',
            riderName: _riderName,
            profileImageUrl: _photoUrl,
            onProfile: () => _changeTab(4),
            isOnline: _online,
            activeCount: _pickups + _deliveries + _lastMile,
            completedCount: _completed,
            earningsToday: _earnings,
            onMessages: widget.onOpenMessages,
            onNotifications: _showNotifications,
            onMenu: _openRiderMenu,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const RiderEyebrow(label: 'Overview'),
                const SizedBox(height: 8),
                RiderSectionHeading(
                  title: 'Today at a glance',
                  subtitle: 'Live work, updated from SARI Logistics',
                  trailing: RiderLiveChip(isLive: _summaryAvailable),
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    // Two cards per row as in the supplied design.
                    // Fixed main-axis extent protects text from overflow.
                    final tileHeight = constraints.maxWidth < 320 ? 116.0 : 124.0;
                    return GridView.builder(
                      itemCount: stats.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        mainAxisExtent: tileHeight,
                      ),
                      itemBuilder: (context, i) => RiderStatCard(
                        data: stats[i],
                        onTap: [
                          widget.onOpenPickups,
                          () => _changeTab(2),
                          () => _changeTab(1),
                          widget.onOpenHistory,
                        ][i],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 25),
                const RiderEyebrow(label: 'Current route'),
                const SizedBox(height: 9),
                RiderSectionHeading(
                  title: 'Route & live map',
                  subtitle: widget.currentDelivery == null
                      ? 'Your assigned route will appear here'
                      : widget.currentDelivery!.orderNumber,
                ),
                const SizedBox(height: 12),
                if (widget.currentDelivery != null &&
                    widget.currentDelivery!.showDeliveryMap)
                  // RESTORED: existing RiderMap widget, API coordinates,
                  // navigation and its existing map behavior are untouched.
                  RiderMap(delivery: widget.currentDelivery!)
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 26),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: RiderFigmaColors.border),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.map_outlined,
                            size: 34, color: RiderFigmaColors.green),
                        SizedBox(height: 9),
                        Text('No active route to display',
                            style: TextStyle(
                              color: RiderFigmaColors.ink,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            )),
                        SizedBox(height: 4),
                        Text('Map and stops appear when a route is assigned.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 11, color: Colors.black54)),
                      ],
                    ),
                  ),
                const SizedBox(height: 26),
                const RiderEyebrow(label: 'Your next stop'),
                const SizedBox(height: 10),
                RiderActionCard(
                  icon: widget.currentDelivery == null
                      ? Icons.check_circle_outline_rounded
                      : Icons.delivery_dining_outlined,
                  title: widget.currentDelivery == null
                      ? 'No active delivery right now'
                      : 'Current delivery',
                  subtitle: widget.currentDelivery == null
                      ? 'Check your jobs for the next assignment'
                      : 'Continue your work in Deliveries',
                  onTap: () => _changeTab(
                    widget.currentDelivery == null ? 1 : 2,
                  ),
                  iconBackground: const Color(0xFFE0F2FE),
                  iconColor: const Color(0xFF0284C7),
                ),
                if (widget.currentDelivery != null &&
                    !widget.currentDelivery!.isComplete) ...[
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Update current delivery'),
                    onPressed: () async {
                      final delivery = widget.currentDelivery;
                      if (delivery == null) return;
                      final yes = await showDialog<bool>(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          title: const Text('Advance delivery status?'),
                          content: const Text(
                            'Only update after completing the current step.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(dialogContext, false),
                              child: const Text('Cancel'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(dialogContext, true),
                              child: const Text('Continue'),
                            ),
                          ],
                        ),
                      );
                      if (yes == true) widget.onAdvanceDelivery(delivery);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: RiderFigmaColors.green,
                      minimumSize: const Size(double.infinity, 44),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                RiderActionCard(
                  icon: Icons.inventory_2_outlined,
                  title: 'View pickup requests',
                  subtitle: 'Collect parcels from sellers',
                  onTap: widget.onOpenPickups,
                ),
                const SizedBox(height: 12),
                RiderActionCard(
                  icon: Icons.history_rounded,
                  title: 'Delivery history',
                  subtitle: 'Review previously finished deliveries',
                  onTap: widget.onOpenHistory,
                  iconBackground: const Color(0xFFD1FAE5),
                  iconColor: const Color(0xFF059669),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Fallback pages are only used when the parent has not supplied its router.
  /// When onTabChanged exists, your current API-backed pages remain untouched.
  Widget _fallbackTab() {
    final titles = <String>['Home', 'Jobs', 'Deliveries', 'Earnings', 'Account'];
    final descriptions = <String>[
      'Your operations at a glance',
      'Assignments and pickup requests',
      'Manage your current route',
      'Your delivery earnings',
      'Rider profile and settings',
    ];
    final icons = <IconData>[
      Icons.home_outlined,
      Icons.assignment_outlined,
      Icons.local_shipping_outlined,
      Icons.account_balance_wallet_outlined,
      Icons.person_outline,
    ];
    return Column(
      children: [
        RiderInnerHeader(
          title: titles[_localTab],
          subtitle: descriptions[_localTab],
          icon: icons[_localTab],
          onBack: () => _changeTab(0),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refresh,
            color: RiderFigmaColors.green,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 130),
              children: _fallbackContent(),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _fallbackContent() {
    if (_localTab == 1) {
      return [
        const RiderEyebrow(label: 'Assigned jobs'),
        const SizedBox(height: 10),
        RiderSectionHeading(
          title: '${widget.assignments.length} assignments',
          subtitle: 'Use your existing Jobs screen for full assignment details',
        ),
        const SizedBox(height: 16),
        RiderActionCard(
          icon: Icons.inventory_2_outlined,
          title: 'Seller pickups',
          subtitle: 'Open the existing pickup workflow',
          onTap: widget.onOpenPickups,
        ),
        const SizedBox(height: 12),
        RiderActionCard(
          icon: Icons.route,
          title: 'Last-mile batches',
          subtitle: 'Active batches: $_lastMile',
          onTap: () => _changeTab(2),
          iconBackground: const Color(0xFFEDE9FE),
          iconColor: const Color(0xFF7C3AED),
        ),
      ];
    }
    if (_localTab == 2) {
      return [
        const RiderEyebrow(label: 'Delivery overview'),
        const SizedBox(height: 10),
        RiderSectionHeading(
          title: 'Your deliveries',
          subtitle: 'Active: $_deliveries · Last-mile: $_lastMile',
        ),
        const SizedBox(height: 16),
        RiderActionCard(
          icon: Icons.local_shipping_outlined,
          title: widget.currentDelivery == null
              ? 'No current delivery'
              : 'Active delivery assigned',
          subtitle: widget.currentDelivery == null
              ? 'Your queue will update through your existing API'
              : 'Advance status only when the delivery step is complete',
          onTap: () async {
            final delivery = widget.currentDelivery;
            if (delivery == null) return;
            final proceed = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Advance delivery status?'),
                content: const Text(
                  'This invokes the existing delivery status action. '
                  'Only continue when the current step has been completed.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Continue'),
                  ),
                ],
              ),
            );
            if (proceed == true) widget.onAdvanceDelivery(delivery);
          },
          iconColor: const Color(0xFF0284C7),
          iconBackground: const Color(0xFFE0F2FE),
        ),
        const SizedBox(height: 12),
        RiderActionCard(
          icon: Icons.history_rounded,
          title: 'Completed deliveries',
          subtitle: 'See your proof and delivery history',
          onTap: widget.onOpenHistory,
          iconColor: const Color(0xFF059669),
          iconBackground: const Color(0xFFD1FAE5),
        ),
      ];
    }
    if (_localTab == 3) {
      return [
        const RiderEyebrow(label: 'Earnings'),
        const SizedBox(height: 10),
        const RiderSectionHeading(
          title: 'Your earnings',
          subtitle: 'Amounts shown only from the available dashboard summary',
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('EARNED TODAY',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: kGold,
                    fontSize: 10,
                    letterSpacing: 2,
                  )),
              const SizedBox(height: 10),
              Text(
                _summaryAvailable ? _peso(_earnings) : 'Not available',
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: RiderFigmaColors.ink,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        RiderActionCard(
          icon: Icons.history_rounded,
          title: 'Earnings & delivery history',
          subtitle: 'Open the existing history screen',
          onTap: widget.onOpenHistory,
          iconColor: const Color(0xFF059669),
          iconBackground: const Color(0xFFD1FAE5),
        ),
      ];
    }
    return [
      const RiderEyebrow(label: 'Rider account'),
      const SizedBox(height: 10),
      RiderSectionHeading(
        title: _riderName,
        subtitle: _online ? 'Online' : 'Offline',
      ),
      const SizedBox(height: 16),
      RiderActionCard(
        icon: Icons.chat_bubble_outline,
        title: 'Messages',
        subtitle: 'Open rider conversations',
        onTap: widget.onOpenMessages,
        iconColor: const Color(0xFF0284C7),
        iconBackground: const Color(0xFFE0F2FE),
      ),
      const SizedBox(height: 12),
      RiderActionCard(
        icon: Icons.settings_outlined,
        title: 'More options',
        subtitle: 'History, pickups, and theme settings',
        onTap: _showMenu,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // RiderShell owns the ONE Figma-style bottom nav. Never add another
    // bottomNavigationBar in a nested RiderHome Scaffold.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: kPageBg,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: kPageBg,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: kPageBg,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          top: true,
          bottom: false,
          child: ClipRect(
            child: _localTab == 0 ? _home() : _fallbackTab(),
          ),
        ),
      ),
    );
  }
}
