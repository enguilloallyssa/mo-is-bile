import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Keep these names: other Rider widgets may already import them.
const kGold = Color(0xFFC9A24B);
const kGoldLight = Color(0xFFF3DFA2);
const kPageBg = Color(0xFFEEF0EE);

/// Rider dashboard hero (UI only). No server calls, navigation bars, or maps.
/// The rider photo appears in the header, and the actual rider name appears
/// below the greeting using SARI-inspired bold black and gold typography.
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

  // Retained for compatibility with existing RiderHero callers.
  final String name;
  // The existing RiderHome passes this from RiderProfile firstName/lastName.
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

  static const _ink = Color(0xFF16191A);
  static const _muted = Color(0xFF687078);
  static const _accent = Color(0xFFD3940C);

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
    if (parts.isEmpty || parts.first.isEmpty) return 'R';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  Widget _avatar(double size) {
    final url = profileImageUrl?.trim() ?? '';
    final hasRemotePhoto = url.startsWith('https://') || url.startsWith('http://');
    final fallback = Center(
      child: Text(
        _initials,
        style: TextStyle(
          fontSize: size * .36,
          fontWeight: FontWeight.w900,
          color: const Color(0xFF80520B),
          letterSpacing: -.5,
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
          colors: [Color(0xFFFFF0C9), Color(0xFFE8C98A)],
        ),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9A7844).withValues(alpha: .20),
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
    return SizedBox(
      width: 38,
      height: 38,
      child: IconButton(
        tooltip: tooltip,
        onPressed: onTap,
        padding: EdgeInsets.zero,
        icon: Icon(icon, size: 19),
        style: IconButton.styleFrom(
          foregroundColor: _ink,
          backgroundColor: const Color(0xFFEBE7E3).withValues(alpha: .96),
        ),
      ),
    );
  }

  Widget _status() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: isOnline ? const Color(0xFFD6F9DF) : const Color(0xFFE9E7E3),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isOnline ? const Color(0xFF08C95F) : _muted,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isOnline ? 'ONLINE' : 'OFFLINE',
            style: const TextStyle(
              color: _ink,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: .3,
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
        padding: EdgeInsets.symmetric(horizontal: compact ? 3 : 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: _accent, size: compact ? 17 : 19),
            SizedBox(width: compact ? 3 : 6),
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
                      fontSize: compact ? 13 : 15,
                      fontWeight: FontWeight.w900,
                      height: 1.08,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _muted,
                      fontSize: compact ? 9 : 10,
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
      // Keep the layout compact for short names, but give long full names
      // room so they do not collide with the heading, date, or stats row.
      final displayName = riderName.trim().isEmpty ||
              riderName.trim().toLowerCase() == 'sari rider'
          ? 'Rider'
          : riderName.trim();
      final likelyTwoLines = displayName.length > (compact ? 13 : 16);
      final storyHeight = largeText
          ? (likelyTwoLines ? 303.0 : 275.0)
          : (likelyTwoLines ? 252.0 : 223.0);
      final leftStoryWidth = compact ? 200.0 : 226.0;
      final headlineSize = compact ? 23.0 : 26.0;

      return Container(
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0, .45, .78, 1],
            colors: [
              Color(0xFFFCF8F5),
              Color(0xFFF9F5F0),
              Color(0xFFF6F0E9),
              kPageBg,
            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(side, 12, side, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // One rider photo at upper-left, NOT another dashboard title.
              Row(
                children: [
                  InkWell(
                    onTap: onProfile,
                    customBorder: const CircleBorder(),
                    child: _avatar(49),
                  ),
                  const Spacer(),
                  _action(Icons.chat_bubble_outline_rounded, 'Messages', onMessages),
                  const SizedBox(width: 7),
                  _action(Icons.notifications_none_rounded, 'Notifications', onNotifications),
                  const SizedBox(width: 7),
                  _action(Icons.menu_rounded, 'Menu', onMenu),
                ],
              ),
              const SizedBox(height: 9),
              SizedBox(
                width: double.infinity,
                height: storyHeight,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // SARI helmet / delivery bag: faded in and softly blended.
                    Positioned(
                      right: compact ? -22 : -24,
                      top: 36,
                      child: Opacity(
                        opacity: .52,
                        child: Image.asset(
                          'assets/images/rider_hero_gear.png',
                          width: compact ? 235 : 275,
                          height: 187,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        ),
                      ),
                    ),
                    Positioned(right: 0, top: 3, child: _status()),
                    // The actual rider name replaces the old SARI logo.
                    Positioned(
                      left: 0,
                      top: 7,
                      width: leftStoryWidth,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _greeting,
                            style: GoogleFonts.poppins(
                              color: _muted,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            displayName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              color: _ink,
                              fontSize: compact
                                  ? (likelyTwoLines ? 22 : 26)
                                  : (likelyTwoLines ? 25 : 29),
                              fontWeight: FontWeight.w800,
                              height: 1.08,
                              letterSpacing: -1.1,
                            ),
                          ),
                          SizedBox(height: likelyTwoLines ? 14 : 17),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Ready for\n',
                                  style: GoogleFonts.poppins(
                                    color: _ink,
                                    fontSize: headlineSize,
                                    fontWeight: FontWeight.w800,
                                    height: 1.06,
                                    letterSpacing: -.9,
                                  ),
                                ),
                                TextSpan(
                                  text: "today's route?",
                                  style: GoogleFonts.poppins(
                                    color: _accent,
                                    fontSize: headlineSize,
                                    fontWeight: FontWeight.w800,
                                    height: 1.06,
                                    letterSpacing: -.9,
                                  ),
                                ),
                              ],
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_outlined,
                                size: 15,
                                color: _muted,
                              ),
                              const SizedBox(width: 7),
                              Flexible(
                                child: Text(
                                  _date,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    color: _muted,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Container(
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .88),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFF4EAE0)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF9F886E).withValues(alpha: .14),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
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
                    Container(width: 1, height: 34, color: const Color(0xFFE8D7C1)),
                    _stat(
                      icon: Icons.check_circle_outline_rounded,
                      value: '$completedCount',
                      label: 'Completed',
                      compact: compact,
                    ),
                    Container(width: 1, height: 34, color: const Color(0xFFE8D7C1)),
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
