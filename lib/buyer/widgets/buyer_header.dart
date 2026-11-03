import 'package:flutter/material.dart';

import '../../services/sari_live_data.dart';

class BuyerHeader extends StatefulWidget {
  final String pageTitle;

  /// Immediate/fallback values supplied by the current page.
  /// The header refreshes these from Laravel for logged-in buyers.
  final int cartCount;
  final int notificationCount;

  final VoidCallback onSearchTap;
  final VoidCallback onCartTap;
  final VoidCallback onProfileTap;
  final VoidCallback? onNotificationTap;

  const BuyerHeader({
    super.key,
    this.pageTitle = 'Home',
    this.cartCount = 0,
    this.notificationCount = 0,
    required this.onSearchTap,
    required this.onCartTap,
    required this.onProfileTap,
    this.onNotificationTap,
  });

  @override
  State<BuyerHeader> createState() =>
      _BuyerHeaderState();
}

class _BuyerHeaderState
    extends State<BuyerHeader> {
  static const Color gold =
      Color(0xFFD9950B);

  static const Color dark =
      Color(0xFF292929);

  static const Color muted =
      Color(0xFF9198A2);

  static const Color border =
      Color(0xFFE5E8EC);

  int _cartCount = 0;
  int _notificationCount = 0;

  @override
  void initState() {
    super.initState();

    _cartCount = widget.cartCount;
    _notificationCount =
        widget.notificationCount;

    _loadLiveCounts();
  }

  @override
  void didUpdateWidget(
    covariant BuyerHeader oldWidget,
  ) {
    super.didUpdateWidget(
      oldWidget,
    );

    // Cart page can immediately provide its current
    // local item count after add/remove/update.
    if (oldWidget.cartCount !=
            widget.cartCount &&
        widget.cartCount > 0) {
      _cartCount =
          widget.cartCount;
    }

    if (oldWidget.notificationCount !=
            widget.notificationCount &&
        widget.notificationCount > 0) {
      _notificationCount =
          widget.notificationCount;
    }
  }

  Map<String, dynamic> _map(
    dynamic value,
  ) {
    if (value is Map) {
      return Map<String, dynamic>.from(
        value,
      );
    }

    return {};
  }

  int _integer(
    dynamic value,
  ) {
    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
          '$value',
        ) ??
        0;
  }

  Future<void> _loadLiveCounts()
      async {
    try {
      final hasToken =
          await SariLiveData.instance
              .hasAccessToken();

      if (!hasToken ||
          !mounted) {
        return;
      }

      int? cartCount;
      int? notificationCount;

      // -----------------------------------
      // REAL CART COUNT
      // -----------------------------------

      try {
        final response =
            await SariLiveData.instance
                .buyerCart();

        final data =
            _map(
          response['data'],
        );

        if (data.containsKey(
          'cart_count',
        )) {
          cartCount =
              _integer(
            data['cart_count'],
          );
        } else if (data.containsKey(
          'count',
        )) {
          cartCount =
              _integer(
            data['count'],
          );
        } else if (data['items']
            is List) {
          cartCount =
              (data['items'] as List)
                  .length;
        } else if (response.containsKey(
          'cart_count',
        )) {
          cartCount =
              _integer(
            response['cart_count'],
          );
        }
      } catch (_) {
        // Header remains usable even if cart
        // count cannot be refreshed.
      }

      // -----------------------------------
      // REAL UNREAD NOTIFICATION COUNT
      // -----------------------------------

      try {
        final response =
            await SariLiveData.instance
                .buyerNotificationSummary();

        final data =
            _map(
          response['data'],
        );

        if (data.containsKey(
          'unread_count',
        )) {
          notificationCount =
              _integer(
            data['unread_count'],
          );
        } else if (data.containsKey(
          'unread',
        )) {
          notificationCount =
              _integer(
            data['unread'],
          );
        } else if (data.containsKey(
          'count',
        )) {
          notificationCount =
              _integer(
            data['count'],
          );
        } else if (response.containsKey(
          'unread_count',
        )) {
          notificationCount =
              _integer(
            response[
                'unread_count'],
          );
        }
      } catch (_) {
        // Header remains usable even when
        // notification summary is unavailable.
      }

      if (!mounted) {
        return;
      }

      setState(() {
        if (cartCount != null) {
          _cartCount =
              cartCount!;
        }

        if (notificationCount !=
            null) {
          _notificationCount =
              notificationCount!;
        }
      });
    } catch (_) {
      // Guests and expired sessions simply keep
      // the fallback counts without breaking UI.
    }
  } 

  @override
  Widget build(
    BuildContext context,
  ) {
    return Material(
      color: Colors.white,
      elevation: 0,
      child: SafeArea(
        bottom: false,
        child: Container(
          padding:
              const EdgeInsets.fromLTRB(
            12,
            9,
            12,
            10,
          ),
          decoration:
              const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(
                color: Color(
                  0xFFE6E8EC,
                ),
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap:
                      widget.onSearchTap,
                  borderRadius:
                      BorderRadius.circular(
                    13,
                  ),
                  child: Container(
                    height: 44,
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 12,
                    ),
                    decoration:
                        BoxDecoration(
                      color:
                          const Color(
                        0xFFF8F9FA,
                      ),
                      borderRadius:
                          BorderRadius.circular(
                        13,
                      ),
                      border:
                          Border.all(
                        color:
                            border,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons
                              .search_rounded,
                          size: 18,
                          color:
                              Color(
                            0xFF69717D,
                          ),
                        ),
                        const SizedBox(
                          width: 9,
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .center,
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              Text(
                                widget.pageTitle ==
                                        'Home'
                                    ? 'Search on SARI'
                                    : widget
                                        .pageTitle,
                                maxLines: 1,
                                overflow:
                                    TextOverflow
                                        .ellipsis,
                                style:
                                    const TextStyle(
                                  color:
                                      dark,
                                  fontSize:
                                      10.5,
                                  fontWeight:
                                      FontWeight
                                          .w700,
                                ),
                              ),
                              const SizedBox(
                                height: 1,
                              ),
                              const Text(
                                'Products, shops, brands...',
                                maxLines: 1,
                                overflow:
                                    TextOverflow
                                        .ellipsis,
                                style:
                                    TextStyle(
                                  color:
                                      muted,
                                  fontSize:
                                      8,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(
                width: 7,
              ),

              _HeaderButton(
                icon: Icons
                    .notifications_none_rounded,
                tooltip:
                    'Notifications',
                badge:
                    _notificationCount,
                onTap: widget
                        .onNotificationTap ??
                    () {},
              ),

              const SizedBox(
                width: 6,
              ),

              _HeaderButton(
                icon: Icons
                    .shopping_cart_outlined,
                tooltip:
                    'Shopping Cart',
                badge:
                    _cartCount,
                onTap:
                    widget.onCartTap,
              ),

              const SizedBox(
                width: 6,
              ),

              _HeaderButton(
                icon: Icons
                    .person_outline_rounded,
                tooltip:
                    'Account',
                onTap:
                    widget.onProfileTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderButton
    extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final int badge;

  final VoidCallback onTap;

  const _HeaderButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.badge = 0,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(
          12,
        ),
        child: Container(
          width: 40,
          height: 40,
          decoration:
              BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(
              12,
            ),
            border:
                Border.all(
              color:
                  const Color(
                0xFFE5E8EC,
              ),
            ),
          ),
          child: Stack(
            alignment:
                Alignment.center,
            clipBehavior:
                Clip.none,
            children: [
              Icon(
                icon,
                size: 20,
                color:
                    const Color(
                  0xFF4B535E,
                ),
              ),

              if (badge > 0)
                Positioned(
                  right: -5,
                  top: -5,
                  child: Container(
                    constraints:
                        const BoxConstraints(
                      minWidth: 18,
                    ),
                    height: 18,
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 4,
                    ),
                    alignment:
                        Alignment.center,
                    decoration:
                        BoxDecoration(
                      color:
                          const Color(
                        0xFFD9950B,
                      ),
                      borderRadius:
                          BorderRadius.circular(
                        20,
                      ),
                      border:
                          Border.all(
                        color:
                            Colors.white,
                        width: 2,
                      ),
                    ),
                    child: Text(
                      badge > 99
                          ? '99+'
                          : '$badge',
                      style:
                          const TextStyle(
                        color:
                            Colors.white,
                        fontSize: 7,
                        fontWeight:
                            FontWeight
                                .w800,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}