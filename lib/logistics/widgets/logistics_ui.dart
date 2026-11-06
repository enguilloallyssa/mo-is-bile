import 'package:flutter/material.dart';

class LogisticsPalette {
  const LogisticsPalette._();

  static const canvas =
      Color(
    0xFFF6F7F9,
  );

  static const surface =
      Colors.white;

  static const ink =
      Color(
    0xFF192333,
  );

  static const body =
      Color(
    0xFF526173,
  );

  static const muted =
      Color(
    0xFF8994A4,
  );

  static const border =
      Color(
    0xFFE7EBF0,
  );

  static const soft =
      Color(
    0xFFF1F4F7,
  );

  static const gold =
      Color(
    0xFFD59A0B,
  );

  static const goldDark =
      Color(
    0xFF9C6900,
  );

  static const goldPale =
      Color(
    0xFFFFF4D9,
  );

  static const navy =
      Color(
    0xFF1A2638,
  );

  static const blue =
      Color(
    0xFF3B7199,
  );

  static const bluePale =
      Color(
    0xFFEDF5FA,
  );

  static const green =
      Color(
    0xFF24835E,
  );

  static const greenPale =
      Color(
    0xFFE8F6ED,
  );

  static const danger =
      Color(
    0xFFB34D4D,
  );
}

class LogisticsSurface
    extends StatelessWidget {
  const LogisticsSurface({
    super.key,
    required this.child,
    this.padding =
        const EdgeInsets.all(
      16,
    ),
    this.color =
        LogisticsPalette.surface,
    this.radius = 18,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final double radius;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      padding:
          padding,
      decoration:
          BoxDecoration(
        color:
            color,
        borderRadius:
            BorderRadius.circular(
          radius,
        ),
        border:
            Border.all(
          color:
              LogisticsPalette
                  .border,
        ),
        boxShadow:
            const [
          BoxShadow(
            color:
                Color(
              0x070E1B2E,
            ),
            blurRadius:
                16,
            offset:
                Offset(
              0,
              5,
            ),
          ),
        ],
      ),
      child:
          child,
    );
  }
}

class LogisticsSectionTitle
    extends StatelessWidget {
  const LogisticsSectionTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Row(
      children: [
        Expanded(
          child:
              Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,
            children: [
              Text(
                title,
                style:
                    const TextStyle(
                  fontSize: 17,
                  fontWeight:
                      FontWeight.w900,
                  letterSpacing:
                      -.35,
                  color:
                      LogisticsPalette
                          .ink,
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
                      const TextStyle(
                    fontSize: 11,
                    color:
                        LogisticsPalette
                            .muted,
                    height: 1.4,
                  ),
                ),
              ],
            ],
          ),
        ),

        if (trailing !=
            null)
          trailing!,
      ],
    );
  }
}

class LogisticsTag
    extends StatelessWidget {
  const LogisticsTag({
    super.key,
    required this.label,
    this.icon,
    this.color =
        LogisticsPalette.goldDark,
    this.background =
        LogisticsPalette.goldPale,
  });

  final String label;
  final IconData? icon;
  final Color color;
  final Color background;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration:
          BoxDecoration(
        color:
            background,
        borderRadius:
            BorderRadius.circular(
          100,
        ),
      ),
      child:
          Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          if (icon !=
              null) ...[
            Icon(
              icon,
              size: 12,
              color:
                  color,
            ),
            const SizedBox(
              width: 5,
            ),
          ],
          Text(
            label,
            style:
                TextStyle(
              fontSize: 9,
              fontWeight:
                  FontWeight.w800,
              color:
                  color,
            ),
          ),
        ],
      ),
    );
  }
}

class LogisticsActionTile
    extends StatelessWidget {
  const LogisticsActionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.color =
        LogisticsPalette.goldDark,
    this.background =
        LogisticsPalette.goldPale,
    this.trailingLabel,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color color;
  final Color background;
  final String? trailingLabel;

  @override
  Widget build(
    BuildContext context,
  ) {
    return LogisticsSurface(
      padding:
          EdgeInsets.zero,
      child:
          Material(
        color:
            Colors.transparent,
        borderRadius:
            BorderRadius.circular(
          18,
        ),
        child:
            InkWell(
          borderRadius:
              BorderRadius.circular(
            18,
          ),
          onTap:
              onTap,
          child:
              Padding(
            padding:
                const EdgeInsets
                    .symmetric(
              horizontal: 13,
              vertical: 13,
            ),
            child:
                Row(
              children: [
                Container(
                  width: 45,
                  height: 45,
                  decoration:
                      BoxDecoration(
                    color:
                        background,
                    borderRadius:
                        BorderRadius
                            .circular(
                      13,
                    ),
                  ),
                  child:
                      Icon(
                    icon,
                    size: 22,
                    color:
                        color,
                  ),
                ),

                const SizedBox(
                  width: 12,
                ),

                Expanded(
                  child:
                      Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow:
                            TextOverflow
                                .ellipsis,
                        style:
                            const TextStyle(
                          fontSize:
                              13.5,
                          fontWeight:
                              FontWeight
                                  .w800,
                          color:
                              LogisticsPalette
                                  .ink,
                        ),
                      ),

                      const SizedBox(
                        height: 4,
                      ),

                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow:
                            TextOverflow
                                .ellipsis,
                        style:
                            const TextStyle(
                          fontSize:
                              10,
                          height:
                              1.35,
                          color:
                              LogisticsPalette
                                  .muted,
                        ),
                      ),
                    ],
                  ),
                ),

                if (trailingLabel !=
                    null)
                  Text(
                    trailingLabel!,
                    style:
                        const TextStyle(
                      fontSize: 10,
                      color:
                          LogisticsPalette
                              .goldDark,
                      fontWeight:
                          FontWeight
                              .w800,
                    ),
                  ),

                const SizedBox(
                  width: 5,
                ),

                const Icon(
                  Icons
                      .chevron_right_rounded,
                  color:
                      LogisticsPalette
                          .muted,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LogisticsEmptyCard
    extends StatelessWidget {
  const LogisticsEmptyCard({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
    this.actionLabel,
  });

  final IconData icon;
  final String title;
  final String message;
  final VoidCallback? action;
  final String? actionLabel;

  @override
  Widget build(
    BuildContext context,
  ) {
    return LogisticsSurface(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 22,
        vertical: 29,
      ),
      child:
          Column(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration:
                const BoxDecoration(
              color:
                  LogisticsPalette
                      .soft,
              shape:
                  BoxShape.circle,
            ),
            child:
                Icon(
              icon,
              color:
                  LogisticsPalette
                      .muted,
              size: 29,
            ),
          ),

          const SizedBox(
            height: 13,
          ),

          Text(
            title,
            textAlign:
                TextAlign.center,
            style:
                const TextStyle(
              fontSize: 14,
              fontWeight:
                  FontWeight.w900,
              color:
                  LogisticsPalette
                      .ink,
            ),
          ),

          const SizedBox(
            height: 7,
          ),

          Text(
            message,
            textAlign:
                TextAlign.center,
            style:
                const TextStyle(
              fontSize: 11,
              color:
                  LogisticsPalette
                      .muted,
              height: 1.5,
            ),
          ),

          if (action !=
                  null &&
              actionLabel !=
                  null) ...[
            const SizedBox(
              height: 16,
            ),

            OutlinedButton.icon(
              onPressed:
                  action,
              icon:
                  const Icon(
                Icons
                    .qr_code_scanner_rounded,
                size: 18,
              ),
              label:
                  Text(
                actionLabel!,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class LogisticsInfoBanner
    extends StatelessWidget {
  const LogisticsInfoBanner({
    super.key,
    required this.message,
  });

  final String message;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      padding:
          const EdgeInsets.all(
        12,
      ),
      decoration:
          BoxDecoration(
        color:
            LogisticsPalette
                .bluePale,
        borderRadius:
            BorderRadius.circular(
          13,
        ),
        border:
            Border.all(
          color:
              const Color(
            0xFFD6EAF4,
          ),
        ),
      ),
      child:
          Row(
        crossAxisAlignment:
            CrossAxisAlignment
                .start,
        children: [
          const Icon(
            Icons
                .info_outline_rounded,
            color:
                LogisticsPalette.blue,
            size: 17,
          ),

          const SizedBox(
            width: 9,
          ),

          Expanded(
            child:
                Text(
              message,
              style:
                  const TextStyle(
                fontSize: 10.5,
                height: 1.45,
                color:
                    LogisticsPalette
                        .body,
              ),
            ),
          ),
        ],
      ),
    );
  }
}