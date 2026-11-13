import 'package:flutter/material.dart';

/// SARI Rider Design System Tokens & Reusable UI Components
/// Drop this into your Flutter project and use across all Rider screens.
class SariRiderColors {
  static const Color background = Color(0xFFF7F5F0); // Warm Alabaster
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF1EDE4);
  static const Color border = Color(0xFFE6E1D6);

  static const Color obsidian = Color(0xFF161513);
  static const Color obsidianLight = Color(0xFF28241E);
  static const Color amberGold = Color(0xFFD99B26);
  static const Color amberSoft = Color(0xFFFFF4DC);

  static const Color textPrimary = Color(0xFF141413);
  static const Color textSecondary = Color(0xFF6E6A63);
  static const Color textMuted = Color(0xFF9C968C);

  static const Color onlineGreen = Color(0xFF10B981);
  static const Color onlineBg = Color(0xFFD1FAE5);
  static const Color infoBlue = Color(0xFF0EA5E9);
  static const Color infoBg = Color(0xFFE0F2FE);
  static const Color batchPurple = Color(0xFF8B5CF6);
  static const Color batchBg = Color(0xFFEDE9FE);
  static const Color dangerRed = Color(0xFFEF4444);
  static const Color dangerBg = Color(0xFFFEE2E2);

  static const LinearGradient heroBannerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF181715),
      Color(0xFF2B2418),
      Color(0xFF6B4E1B),
    ],
    stops: [0.0, 0.55, 1.0],
  );
}

/// 1. Unified Top App Bar for Rider Tabs
class SariRiderAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final String? avatarInitials;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onChatTap;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onMenuTap;
  final int unreadNotifications;
  final int unreadChats;

  const SariRiderAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.avatarInitials,
    this.onAvatarTap,
    this.onChatTap,
    this.onNotificationTap,
    this.onMenuTap,
    this.unreadNotifications = 0,
    this.unreadChats = 0,
  });

  @override
  Size get preferredSize => const Size.fromHeight(68);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        height: 68,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: const BoxDecoration(
          color: SariRiderColors.background,
        ),
        child: Row(
          children: [
            if (avatarInitials != null) ...[
              GestureDetector(
                onTap: onAvatarTap,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEAD39C), Color(0xFFD99B26)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    avatarInitials!,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: SariRiderColors.obsidian,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: SariRiderColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: SariRiderColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            _AppBarActionCircle(
              icon: Icons.chat_bubble_outline_rounded,
              badgeCount: unreadChats,
              onTap: onChatTap,
            ),
            const SizedBox(width: 8),
            _AppBarActionCircle(
              icon: Icons.notifications_none_rounded,
              badgeCount: unreadNotifications,
              onTap: onNotificationTap,
            ),
            const SizedBox(width: 8),
            _AppBarActionCircle(
              icon: Icons.menu_rounded,
              onTap: onMenuTap,
            ),
          ],
        ),
      ),
    );
  }
}

class _AppBarActionCircle extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final int badgeCount;

  const _AppBarActionCircle({
    required this.icon,
    this.onTap,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: SariRiderColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: SariRiderColors.border, width: 1),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: SizedBox(
              width: 42,
              height: 42,
              child: Icon(icon, size: 20, color: SariRiderColors.textPrimary),
            ),
          ),
        ),
        if (badgeCount > 0)
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: SariRiderColors.dangerRed,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: Text(
                badgeCount > 9 ? '9+' : '$badgeCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// 2. Polished Dark Obsidian & Gold Workspace Banner
class SariWorkspaceBanner extends StatelessWidget {
  final IconData tagIcon;
  final String tagLabel;
  final String title;
  final String description;
  final Widget? bottomChild;
  final Widget? trailingBadge;

  const SariWorkspaceBanner({
    super.key,
    required this.tagIcon,
    required this.tagLabel,
    required this.title,
    required this.description,
    this.bottomChild,
    this.trailingBadge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: SariRiderColors.heroBannerGradient,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF3E3423), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF181715).withOpacity(0.14),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.12)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(tagIcon, size: 13, color: const Color(0xFFF3C663)),
                    const SizedBox(width: 6),
                    Text(
                      tagLabel.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                        color: Color(0xFFF3C663),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (trailingBadge != null) trailingBadge!,
            ],
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: Colors.white.withOpacity(0.78),
            ),
          ),
          if (bottomChild != null) ...[
            const SizedBox(height: 18),
            bottomChild!,
          ],
        ],
      ),
    );
  }
}

/// 3. Compact 3-Column KPI Strip (Replaces oversized 3-cards row)
class SariCompactKpiRow extends StatelessWidget {
  final List<SariKpiItem> items;

  const SariCompactKpiRow({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(items.length, (index) {
        final item = items[index];
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(
              left: index == 0 ? 0 : 6,
              right: index == items.length - 1 ? 0 : 6,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: SariRiderColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: SariRiderColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: item.tintColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(item.icon, size: 17, color: item.tintColor),
                    ),
                    Text(
                      item.value,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: SariRiderColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: SariRiderColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class SariKpiItem {
  final IconData icon;
  final String value;
  final String label;
  final Color tintColor;

  const SariKpiItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.tintColor,
  });
}

/// 4. Bento Overview Card (Used on Home 2x2 Grid with clean bottom accent bar)
class SariBentoMetricCard extends StatelessWidget {
  final IconData icon;
  final Color accentColor;
  final Color iconBgColor;
  final String value;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const SariBentoMetricCard({
    super.key,
    required this.icon,
    required this.accentColor,
    required this.iconBgColor,
    required this.value,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SariRiderColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: SariRiderColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: iconBgColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(icon, color: accentColor, size: 20),
                        ),
                        Text(
                          value,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: SariRiderColors.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: SariRiderColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: SariRiderColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 4,
                width: double.infinity,
                color: accentColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 5. Clean Search & Filter Pill Bar
class SariSearchAndFilterBar extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String hintText;
  final List<String> filters;
  final int selectedFilterIndex;
  final ValueChanged<int> onFilterSelected;
  final VoidCallback? onTrailingActionTap;
  final IconData? trailingActionIcon;

  const SariSearchAndFilterBar({
    super.key,
    this.controller,
    this.onChanged,
    required this.hintText,
    required this.filters,
    required this.selectedFilterIndex,
    required this.onFilterSelected,
    this.onTrailingActionTap,
    this.trailingActionIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: SariRiderColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: SariRiderColors.border),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              const Icon(
                Icons.search_rounded,
                size: 20,
                color: SariRiderColors.textMuted,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  style: const TextStyle(
                    fontSize: 14,
                    color: SariRiderColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: const TextStyle(
                      fontSize: 13.5,
                      color: SariRiderColors.textMuted,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
              if (onTrailingActionTap != null)
                IconButton(
                  onPressed: onTrailingActionTap,
                  icon: Icon(
                    trailingActionIcon ?? Icons.qr_code_scanner_rounded,
                    size: 20,
                    color: SariRiderColors.amberGold,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(filters.length, (index) {
              final isSelected = index == selectedFilterIndex;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(filters[index]),
                  selected: isSelected,
                  onSelected: (_) => onFilterSelected(index),
                  showCheckmark: false,
                  labelStyle: TextStyle(
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : SariRiderColors.textSecondary,
                  ),
                  backgroundColor: SariRiderColors.surface,
                  selectedColor: SariRiderColors.obsidian,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected
                          ? SariRiderColors.obsidian
                          : SariRiderColors.border,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

/// 6. Polished Empty State Card
class SariEmptyStateCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onActionTap;

  const SariEmptyStateCard({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.actionIcon,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      decoration: BoxDecoration(
        color: SariRiderColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: SariRiderColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: SariRiderColors.surfaceMuted,
              shape: BoxShape.circle,
              border: Border.all(color: SariRiderColors.border),
            ),
            child: Icon(
              icon,
              size: 28,
              color: SariRiderColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: SariRiderColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              height: 1.45,
              color: SariRiderColors.textSecondary,
            ),
          ),
          if (actionLabel != null && onActionTap != null) ...[
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: onActionTap,
              icon: Icon(
                actionIcon ?? Icons.history_rounded,
                size: 18,
                color: SariRiderColors.textPrimary,
              ),
              label: Text(
                actionLabel!,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: SariRiderColors.textPrimary,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                side: const BorderSide(color: SariRiderColors.border, width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 7. Polished Bottom Navigation Bar
class SariRiderBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const SariRiderBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.home_outlined, Icons.home_rounded, 'Home'),
      (Icons.assignment_outlined, Icons.assignment_rounded, 'Jobs'),
      (Icons.local_shipping_outlined, Icons.local_shipping_rounded, 'Deliveries'),
      (Icons.account_balance_wallet_outlined, Icons.account_balance_wallet_rounded, 'Earnings'),
      (Icons.person_outline_rounded, Icons.person_rounded, 'Account'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: SariRiderColors.surface,
        border: const Border(
          top: BorderSide(color: SariRiderColors.border, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final isSelected = index == currentIndex;
              final item = items[index];
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(index),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? SariRiderColors.amberSoft
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          isSelected ? item.$2 : item.$1,
                          size: 22,
                          color: isSelected
                              ? SariRiderColors.amberGold
                              : SariRiderColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.$3,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight:
                              isSelected ? FontWeight.w800 : FontWeight.w500,
                          color: isSelected
                              ? SariRiderColors.textPrimary
                              : SariRiderColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}