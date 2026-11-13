import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Keep these names: other Rider widgets may already import them.
const kGold = Color(0xFFD4951A);
const kGoldLight = Color(0xFFF3DFA2);
const kPageBg = Color(0xFFF7F5F0);

/// Rider dashboard hero (UI only). No server calls, navigation bars, or maps.
class RiderHero extends StatelessWidget {
  const RiderHero({
    super.key,
    this.name = 'SARI',
    this.riderName = 'Rider',
    this.profileImageUrl,
    this.onProfile,
    this.isOnline = false,
    this.activeCount = 0,
    this.completedCount = 0,
    this.earningsToday = 0,
    this.onMessages,
    this.onNotifications,
    this.onMenu,
  });

  final String name;
  final String riderName;
  final String? profileImageUrl;
  final VoidCallback? onProfile;
  final bool isOnline;
  final int activeCount;
  final int completedCount;
  final double earningsToday;
  final VoidCallback? onMessages;
  final VoidCallback? onNotifications;
  final VoidCallback? onMenu;

  static const _ink = Color(0xFF161513);
  static const _muted = Color(0xFF6E6A63);
  static const _accent = Color(0xFFD4951A);

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }

  String get _date {
    final now = DateTime.now();
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }

  String get _initials {
    final parts = riderName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'SR';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  Widget _avatar(double size) {
    final url = profileImageUrl?.trim() ?? '';
    final hasRemotePhoto =
        url.startsWith('https://') || url.startsWith('http://');
    final fallback = Center(
      child: Text(
        _initials,
        style: TextStyle(
          fontSize: size * .34,
          fontWeight: FontWeight.w900,
          color: const Color(0xFF5E3D06),
          letterSpacing: -.3,
        ),
      ),
    );
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFDF0CE), Color(0xFFE5BE6B)],
        ),
        border: Border.all(color: Colors.white, width: 2.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8C641E).withValues(alpha: .18),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: hasRemotePhoto
          ? Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => fallback,
            )
          : fallback,
    );
  }

  Widget _action(IconData icon, String tooltip, VoidCallback? onTap) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xFFE6E1D6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onTap,
        padding: EdgeInsets.zero,
        icon: Icon(icon, size: 19, color: _ink),
      ),
    );
  }

  Widget _status() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: isOnline ? const Color(0xFFD9FBE5) : const Color(0xFFECE9E2),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
          color: isOnline
              ? const Color(0xFF10B981).withValues(alpha: .35)
              : const Color(0xFFD5CFC4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isOnline ? const Color(0xFF059669) : _muted,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isOnline ? 'ONLINE' : 'OFFLINE',
            style: TextStyle(
              color: isOnline ? const Color(0xFF065F46) : _ink,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: .5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat({
    required IconData icon,
    required String value,
    required String label,
    required bool compact,
  }) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: compact ? 4 : 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: compact ? 30 : 34,
              height: compact ? 30 : 34,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3D6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: _accent, size: compact ? 16 : 18),
            ),
            SizedBox(width: compact ? 6 : 8),
            Flexible(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      color: _ink,
                      fontSize: compact ? 13.5 : 15,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                      letterSpacing: -.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _muted,
                      fontSize: compact ? 9.5 : 10.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, box) {
      final compact = box.maxWidth < 355;
      final side = compact ? 16.0 : 20.0;
      final mediaTextScale = MediaQuery.textScalerOf(context);
      final largeText = mediaTextScale.scale(14) > 18;
      final displayName = riderName.trim().isEmpty ||
              riderName.trim().toLowerCase() == 'sari rider'
          ? 'SARI'
          : riderName.trim();
      final likelyTwoLines = displayName.length > (compact ? 13 : 16);
      final storyHeight = largeText
          ? (likelyTwoLines ? 290.0 : 265.0)
          : (likelyTwoLines ? 236.0 : 215.0);
      final leftStoryWidth = compact ? 195.0 : 220.0;
      final headlineSize = compact ? 22.0 : 25.0;

      return Container(
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0, .5, .85, 1],
            colors: [
              Color(0xFFFFFFFF),
              Color(0xFFFAF6EE),
              Color(0xFFF5EFE2),
              kPageBg,
            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(side, 12, side, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Navigation Bar
              Row(
                children: [
                  InkWell(
                    onTap: onProfile,
                    customBorder: const CircleBorder(),
                    child: _avatar(46),
                  ),
                  const Spacer(),
                  _action(
                    Icons.chat_bubble_outline_rounded,
                    'Messages',
                    onMessages,
                  ),
                  const SizedBox(width: 8),
                  _action(
                    Icons.notifications_none_rounded,
                    'Notifications',
                    onNotifications,
                  ),
                  const SizedBox(width: 8),
                  _action(Icons.menu_rounded, 'Menu', onMenu),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: storyHeight,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Crisp SARI Helmet & Delivery Bag Hero Asset
                    Positioned(
                      right: compact ? -18 : -14,
                      bottom: 0,
                      top: 28,
                      child: Image.asset(
                        'assets/images/rider_hero_gear.png',
                        width: compact ? 215 : 245,
                        height: 185,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    ),
                    Positioned(right: 0, top: 2, child: _status()),
                    Positioned(
                      left: 0,
                      top: 4,
                      width: leftStoryWidth,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _greeting,
                            style: GoogleFonts.poppins(
                              color: _muted,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _ink,
                              borderRadius: BorderRadius.circular(11),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: .12),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Text(
                              displayName.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: compact ? 13 : 14,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          SizedBox(height: likelyTwoLines ? 12 : 14),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Ready for\n',
                                  style: GoogleFonts.poppins(
                                    color: _ink,
                                    fontSize: headlineSize,
                                    fontWeight: FontWeight.w800,
                                    height: 1.08,
                                    letterSpacing: -.8,
                                  ),
                                ),
                                TextSpan(
                                  text: "today's route?",
                                  style: GoogleFonts.poppins(
                                    color: _ink,
                                    fontSize: headlineSize,
                                    fontWeight: FontWeight.w800,
                                    height: 1.08,
                                    letterSpacing: -.8,
                                  ),
                                ),
                              ],
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: .75),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFFE6E1D6),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.calendar_today_outlined,
                                  size: 13,
                                  color: _muted,
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    _date,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                      color: _ink,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Summary Strip (Active | Completed | Today)
              Container(
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFE8E2D5)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF594025).withValues(alpha: .07),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    _stat(
                      icon: Icons.inventory_2_outlined,
                      value: '$activeCount',
                      label: 'Active',
                      compact: compact,
                    ),
                    Container(
                      width: 1,
                      height: 32,
                      color: const Color(0xFFE8E2D5),
                    ),
                    _stat(
                      icon: Icons.check_circle_outline_rounded,
                      value: '$completedCount',
                      label: 'Completed',
                      compact: compact,
                    ),
                    Container(
                      width: 1,
                      height: 32,
                      color: const Color(0xFFE8E2D5),
                    ),
                    _stat(
                      icon: Icons.account_balance_wallet_outlined,
                      value: '₱${earningsToday.toStringAsFixed(2)}',
                      label: 'Today',
                      compact: compact,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}