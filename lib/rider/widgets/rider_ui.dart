import 'package:flutter/material.dart';

/// Shared entry point for the Rider shell's navigation drawer.
///
/// The callback is still supported for compatibility, but RiderMenuButton
/// also searches for the nearest ancestor Scaffold that owns an endDrawer.
/// This makes the right-side hamburger work even when the page itself
/// contains a nested Scaffold.
class RiderMenuController {
  static VoidCallback? open;
}

class RiderMenuButton extends StatelessWidget {
  const RiderMenuButton({
    super.key,
  });

  void _openMenu(
    BuildContext context,
  ) {
    ScaffoldState? targetScaffold;

    // Rider pages use their own nested Scaffold.
    // Scaffold.of(context) would normally find that inner Scaffold,
    // which does not own the Rider drawer.
    //
    // Instead, walk upward until we find the outer Rider Shell Scaffold
    // that actually contains an endDrawer.
    context.visitAncestorElements(
      (Element element) {
        final Widget widget =
            element.widget;

        if (widget is Scaffold &&
            widget.endDrawer != null &&
            element is StatefulElement &&
            element.state
                is ScaffoldState) {
          targetScaffold =
              element.state
                  as ScaffoldState;

          return false;
        }

        return true;
      },
    );

    if (targetScaffold != null) {
      targetScaffold!
          .openEndDrawer();

      return;
    }

    // Fallback for older Rider Shell implementation.
    final VoidCallback? callback =
        RiderMenuController.open;

    if (callback != null) {
      callback();

      return;
    }

    // Final fallback so the button does not silently do nothing.
    ScaffoldMessenger.maybeOf(
      context,
    )?.showSnackBar(
      const SnackBar(
        content: Text(
          'Rider menu is not connected to the current page.',
        ),
        behavior:
            SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return IconButton(
      tooltip:
          'Open Rider menu',

      onPressed: () {
        _openMenu(
          context,
        );
      },

      icon:
          const Icon(
        Icons.menu_rounded,
      ),
    );
  }
}

/// Rider-only UI navigation callbacks set by RiderShell.
class RiderHeaderController {
  static VoidCallback? messages;
  static VoidCallback? notifications;
}

class RiderHeaderActions extends StatelessWidget {
  const RiderHeaderActions({super.key});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      IconButton(
        tooltip: 'Messages',
        onPressed: RiderHeaderController.messages,
        icon: const Icon(Icons.chat_bubble_outline_rounded),
      ),
      IconButton(
        tooltip: 'Notifications',
        onPressed: RiderHeaderController.notifications,
        icon: const Icon(Icons.notifications_none_rounded),
      ),
    ],
  );
}

class RiderSearchField extends StatelessWidget {
  const RiderSearchField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onChanged,
    this.onSubmitted,
  });
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    onChanged: onChanged,
    onSubmitted: onSubmitted,
    textInputAction: onSubmitted == null ? TextInputAction.done : TextInputAction.search,
    style: TextStyle(color: RiderColors.text, fontSize: 14),
    decoration: InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: RiderColors.muted, fontSize: 13),
      prefixIcon: Icon(Icons.search_rounded, color: RiderColors.muted, size: 21),
      suffixIcon: controller.text.isEmpty ? null : IconButton(
        tooltip: 'Clear search',
        icon: const Icon(Icons.close_rounded, size: 19),
        onPressed: () { controller.clear(); onChanged(''); },
      ),
      filled: true,
      fillColor: RiderColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: RiderColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: RiderColors.gold, width: 1.6),
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );
}

class RiderThemeController {
  static bool isDark = false;

  static void setDark(
    bool value,
  ) {
    isDark = value;
  }
}

class RiderColors {
  static bool get isDark =>
      RiderThemeController.isDark;

  static Color get bg =>
      isDark
          ? const Color(
              0xFF171715,
            )
          : const Color(
              0xFFF7F5F1,
            );

  static Color get surface =>
      isDark
          ? const Color(
              0xFF24231F,
            )
          : const Color(
              0xFFFFFFFF,
            );

  static Color get surfaceElevated =>
      isDark
          ? const Color(
              0xFF2C2A25,
            )
          : const Color(
              0xFFFFFFFF,
            );

  static Color get surfaceSoft =>
      isDark
          ? const Color(
              0xFF35312A,
            )
          : const Color(
              0xFFF4F0E9,
            );

  static Color get text =>
      isDark
          ? const Color(
              0xFFF4F7F8,
            )
          : const Color(
              0xFF24231F,
            );

  static Color get muted =>
      isDark
          ? const Color(
              0xFFAEBBC3,
            )
          : const Color(
              0xFF77716A,
            );

  static Color get border =>
      isDark
          ? const Color(
              0xFF464039,
            )
          : const Color(
              0xFFEAE5DC,
            );

  static Color get nav =>
      isDark
          ? const Color(
              0xFF211F1C,
            )
          : const Color(
              0xFFFFFFFF,
            );

  static Color get field =>
      isDark
          ? const Color(
              0xFF292620,
            )
          : const Color(
              0xFFF8F5F0,
            );

  static Color get overlay =>
      isDark
          ? const Color(
              0x66101A20,
            )
          : const Color(
              0x44FFFFFF,
            );

  static Color get gold =>
      isDark
          ? const Color(
              0xFFF0B84A,
            )
          : const Color(
              0xFFB88A2C,
            );

  static Color get goldDark =>
      isDark
          ? const Color(
              0xFFFFCA68,
            )
          : const Color(
              0xFF9B701E,
            );

  static Color get goldSoft =>
      isDark
          ? const Color(
              0xFF4A3E2B,
            )
          : const Color(
              0xFFF7EBD5,
            );

  static Color get blue =>
      isDark
          ? const Color(
              0xFF7AA8C7,
            )
          : const Color(
              0xFF3C6E91,
            );

  static Color get blueSoft =>
      isDark
          ? const Color(
              0xFF294352,
            )
          : const Color(
              0xFFEAF2F7,
            );

  static Color get green =>
      isDark
          ? const Color(
              0xFF72B98C,
            )
          : const Color(
              0xFF4F7D63,
            );

  static Color get greenSoft =>
      isDark
          ? const Color(
              0xFF294638,
            )
          : const Color(
              0xFFEAF3ED,
            );

  static Color get red =>
      isDark
          ? const Color(
              0xFFE18484,
            )
          : const Color(
              0xFFB95555,
            );

  static Color get redSoft =>
      isDark
          ? const Color(
              0xFF4B3034,
            )
          : const Color(
              0xFFFCEDED,
            );

  static Color get purple =>
      isDark
          ? const Color(
              0xFFB096C6,
            )
          : const Color(
              0xFF715A86,
            );

  static Color get purpleSoft =>
      isDark
          ? const Color(
              0xFF40364A,
            )
          : const Color(
              0xFFF1EDF5,
            );

  static List<Color>
      get heroGradient =>
          isDark
              ? const <Color>[
                  Color(
                    0xFF201E1B,
                  ),
                  Color(
                    0xFF302A21,
                  ),
                  Color(
                    0xFF4B3D28,
                  ),
                ]
              : const <Color>[
                  Color(
                    0xFF262521,
                  ),
                  Color(
                    0xFF4E4535,
                  ),
                  Color(
                    0xFFB88A2C,
                  ),
                ];

  static List<Color>
      get earningsGradient =>
          isDark
              ? const <Color>[
                  Color(
                    0xFF28251F,
                  ),
                  Color(
                    0xFF393024,
                  ),
                ]
              : const <Color>[
                  Color(
                    0xFFFFFFFF,
                  ),
                  Color(
                    0xFFF8F4ED,
                  ),
                ];
}

class RiderHeaderTitle
    extends StatelessWidget {
  final String title;
  final String subtitle;

  const RiderHeaderTitle({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      mainAxisSize:
          MainAxisSize.min,
      children: <Widget>[
        Text(
          title,
          maxLines: 1,
          overflow:
              TextOverflow.ellipsis,
          style:
              TextStyle(
            color:
                RiderColors.text,
            fontSize: 19,
            fontWeight:
                FontWeight.w800,
            letterSpacing: -.35,
          ),
        ),

        const SizedBox(
          height: 2,
        ),

        Text(
          subtitle,
          maxLines: 1,
          overflow:
              TextOverflow.ellipsis,
          style:
              TextStyle(
            color:
                RiderColors.muted,
            fontSize: 12,
            fontWeight:
                FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class RiderSurface
    extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final double radius;
  final bool shadow;
  final bool elevated;

  const RiderSurface({
    super.key,
    required this.child,
    this.padding =
        const EdgeInsets.all(
      16,
    ),
    this.color,
    this.radius = 20,
    this.shadow = false,
    this.elevated = false,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final Color background =
        color ??
            (elevated
                ? RiderColors
                    .surfaceElevated
                : RiderColors
                    .surface);

    return Container(
      padding: padding,
      decoration:
          BoxDecoration(
        color: background,
        borderRadius:
            BorderRadius.circular(
          radius,
        ),
        border:
            Border.all(
          color:
              RiderColors.border,
        ),
        boxShadow:
            shadow
                ? <BoxShadow>[
                    BoxShadow(
                      color:
                          Colors.black
                              .withValues(
                        alpha:
                            RiderColors
                                    .isDark
                                ? .22
                                : .08,
                      ),
                      blurRadius:
                          RiderColors
                                  .isDark
                              ? 24
                              : 18,
                      offset:
                          const Offset(
                        0,
                        8,
                      ),
                    ),
                  ]
                : null,
      ),
      child: child,
    );
  }
}

class RiderStatusPill
    extends StatelessWidget {
  final String label;
  final Color color;
  final Color background;
  final IconData? icon;

  const RiderStatusPill({
    super.key,
    required this.label,
    required this.color,
    required this.background,
    this.icon,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration:
          BoxDecoration(
        color: background,
        borderRadius:
            BorderRadius.circular(
          999,
        ),
        border:
            Border.all(
          color:
              color.withValues(
            alpha: .22,
          ),
        ),
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...[
            Icon(
              icon,
              size: 13,
              color: color,
            ),

            const SizedBox(
              width: 5,
            ),
          ],

          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow:
                  TextOverflow
                      .ellipsis,
              style:
                  TextStyle(
                color: color,
                fontSize: 10,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RiderSectionHeader
    extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const RiderSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.end,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,
            children: <Widget>[
              Text(
                title,
                style:
                    TextStyle(
                  color:
                      RiderColors.text,
                  fontSize: 17,
                  fontWeight:
                      FontWeight.w900,
                  letterSpacing: -.2,
                ),
              ),

              if (subtitle !=
                  null) ...[
                const SizedBox(
                  height: 3,
                ),

                Text(
                  subtitle!,
                  style:
                      TextStyle(
                    color:
                        RiderColors.muted,
                    fontSize: 11,
                    height: 1.35,
                  ),
                ),
              ],
            ],
          ),
        ),

        if (trailing != null) ...[
          const SizedBox(
            width: 10,
          ),
          trailing!,
        ],
      ],
    );
  }
}

class RiderMetricTile
    extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color accent;
  final Color softColor;

  const RiderMetricTile({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    required this.accent,
    required this.softColor,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final Color iconBackground =
        RiderColors.isDark
            ? accent.withValues(
                alpha: .16,
              )
            : softColor;

    return RiderSurface(
      padding:
          const EdgeInsets.all(
        13,
      ),
      radius: 17,
      elevated: true,
      child: Row(
        children: <Widget>[
          Container(
            width: 38,
            height: 38,
            decoration:
                BoxDecoration(
              color:
                  iconBackground,
              borderRadius:
                  BorderRadius.circular(
                12,
              ),
            ),
            child: Icon(
              icon,
              color: accent,
              size: 20,
            ),
          ),

          const SizedBox(
            width: 10,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: <Widget>[
                Text(
                  value,
                  maxLines: 1,
                  overflow:
                      TextOverflow
                          .ellipsis,
                  style:
                      TextStyle(
                    color:
                        RiderColors.text,
                    fontSize: 18,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),

                Text(
                  label,
                  maxLines: 1,
                  overflow:
                      TextOverflow
                          .ellipsis,
                  style:
                      TextStyle(
                    color:
                        RiderColors.muted,
                    fontSize: 10,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RiderEmptyState
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const RiderEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return RiderSurface(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 34,
      ),
      elevated: true,
      child: Column(
        children: <Widget>[
          Container(
            width: 58,
            height: 58,
            decoration:
                BoxDecoration(
              color:
                  RiderColors.goldSoft,
              borderRadius:
                  BorderRadius.circular(
                18,
              ),
            ),
            child: Icon(
              icon,
              color:
                  RiderColors.goldDark,
              size: 29,
            ),
          ),

          const SizedBox(
            height: 14,
          ),

          Text(
            title,
            textAlign:
                TextAlign.center,
            style:
                TextStyle(
              color:
                  RiderColors.text,
              fontSize: 15,
              fontWeight:
                  FontWeight.w900,
            ),
          ),

          const SizedBox(
            height: 5,
          ),

          Text(
            message,
            textAlign:
                TextAlign.center,
            style:
                TextStyle(
              color:
                  RiderColors.muted,
              fontSize: 11,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

Color riderStatusColor(
  String status,
) {
  if (status == 'completed' ||
      status == 'delivered') {
    return RiderColors.green;
  }

  if (status ==
      'delivery_failed') {
    return RiderColors.red;
  }

  if (status.contains(
        'sorting',
      ) ||
      status.contains(
        'delivery_',
      )) {
    return RiderColors.blue;
  }

  return RiderColors.goldDark;
}

Color riderStatusSoftColor(
  String status,
) {
  if (status == 'completed' ||
      status == 'delivered') {
    return RiderColors.greenSoft;
  }

  if (status ==
      'delivery_failed') {
    return RiderColors.redSoft;
  }

  if (status.contains(
        'sorting',
      ) ||
      status.contains(
        'delivery_',
      )) {
    return RiderColors.blueSoft;
  }

  return RiderColors.goldSoft;
}