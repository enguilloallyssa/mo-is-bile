import 'package:flutter/material.dart';

import '../services/sari_live_data.dart';
import 'widgets/rider_ui.dart';

/// Server-backed Rider notifications.
/// No local/demo events or guessed counts.
class RiderNotifications
    extends StatefulWidget {
  const RiderNotifications({
    super.key,
    this.onOpenMessages,
  });

  final VoidCallback?
      onOpenMessages;

  @override
  State<RiderNotifications>
      createState() =>
          _RiderNotificationsState();
}

class _RiderNotificationsState
    extends State<RiderNotifications> {
  final List<Map<String, dynamic>>
      _items = [];

  bool _loading = true;
  bool _working = false;
  bool _unreadOnly = false;

  int _unreadCount = 0;

  String? _error;

  @override
  void initState() {
    super.initState();

    _refresh();
  }

  Map<String, dynamic> _map(
    dynamic value,
  ) {
    return value is Map
        ? Map<String, dynamic>.from(
            value,
          )
        : <String, dynamic>{};
  }

  int _integer(
    dynamic value,
  ) {
    return value is num
        ? value.toInt()
        : int.tryParse(
              '$value',
            ) ??
            0;
  }

  String _text(
    dynamic value,
  ) {
    return value
            ?.toString()
            .trim() ??
        '';
  }

  Future<void> _refresh()
      async {
    if (_working) {
      return;
    }

    setState(() {
      _loading =
          _items.isEmpty;

      _error = null;
    });

    try {
      final response =
          await SariLiveData
              .instance
              .riderNotifications()
              .timeout(
                const Duration(
                  seconds: 10,
                ),
              );

      final data =
          _map(
        response['data'],
      );

      final raw =
          data['items'];

      if (raw is! List) {
        throw const FormatException(
          'Invalid notification feed.',
        );
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _items
          ..clear()
          ..addAll(
            raw.map(
              _map,
            ),
          );

        _unreadCount =
            _integer(
          data['unread_count'],
        );

        _loading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _error =
            error.toString();

        _loading = false;
      });
    }
  }

  Future<void> _markRead(
    Map<String, dynamic> item,
  ) async {
    if (_working ||
        item['unread'] != true) {
      return;
    }

    final id =
        _integer(
      item['id'],
    );

    if (id <= 0) {
      return;
    }

    setState(() {
      _working = true;
    });

    try {
      await SariLiveData
          .instance
          .riderReadNotification(
        id,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        item['unread'] = false;

        if (_unreadCount > 0) {
          _unreadCount--;
        }
      });
    } catch (error) {
      _show(
        error.toString(),
      );
    } finally {
      if (mounted) {
        setState(() {
          _working = false;
        });
      }
    }
  }

  Future<void> _markAllRead()
      async {
    if (_working ||
        _unreadCount == 0) {
      return;
    }

    setState(() {
      _working = true;
    });

    try {
      await SariLiveData
          .instance
          .riderReadAllNotifications();

      if (!mounted) {
        return;
      }

      setState(() {
        for (final item
            in _items) {
          item['unread'] = false;
        }

        _unreadCount = 0;
      });

      _show(
        'All notifications marked as read.',
      );
    } catch (error) {
      _show(
        error.toString(),
      );
    } finally {
      if (mounted) {
        setState(() {
          _working = false;
        });
      }
    }
  }

  void _show(
    String text,
  ) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            text,
          ),
          behavior:
              SnackBarBehavior.floating,
        ),
      );
  }

  IconData _iconFor(
    String category,
  ) {
    switch (category) {
      case 'message':
        return Icons
            .chat_bubble_outline_rounded;

      case 'last_mile':
        return Icons.route_rounded;

      case 'delivery':
        return Icons
            .local_shipping_outlined;

      case 'remittance':
        return Icons
            .payments_outlined;

      case 'earnings':
        return Icons
            .account_balance_wallet_outlined;

      default:
        return Icons
            .notifications_none_rounded;
    }
  }

  Color _colorFor(
    String category,
  ) {
    switch (category) {
      case 'message':
        return RiderColors.blue;

      case 'last_mile':
        return RiderColors.goldDark;

      case 'delivery':
        return RiderColors.green;

      case 'remittance':
        return RiderColors.goldDark;

      default:
        return RiderColors.text;
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final visible =
        _items
            .where(
              (item) =>
                  !_unreadOnly ||
                  item['unread'] ==
                      true,
            )
            .toList();

    return Scaffold(
      backgroundColor:
          RiderColors.bg,
      appBar: AppBar(
        elevation: 0,
        surfaceTintColor:
            Colors.transparent,
        backgroundColor:
            RiderColors.surface,
        foregroundColor:
            RiderColors.text,
        title:
            const RiderHeaderTitle(
          title: 'Notifications',
          subtitle:
              'Updates from SARI Logistics',
        ),
        actions: [
          RiderTopActionButton(
            tooltip: 'Refresh notifications',
            onPressed: _working ? null : _refresh,
            icon: Icons.refresh_rounded,
            accent: RiderColors.goldDark,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(14, 12, 14, 5),
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            decoration: BoxDecoration(
              color: RiderColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: RiderColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .025),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 4,
              children: [
                ChoiceChip(
                  showCheckmark: false,
                  backgroundColor: RiderColors.surfaceSoft,
                  selectedColor: RiderColors.goldSoft,
                  side: BorderSide(color: RiderColors.gold.withValues(alpha: .20)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  labelStyle: TextStyle(
                    color: RiderColors.text,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                  label: Text(
                    'All (${_items.length})',
                  ),
                  selected:
                      !_unreadOnly,
                  onSelected:
                      (_) {
                    setState(() {
                      _unreadOnly =
                          false;
                    });
                  },
                ),



                ChoiceChip(
                  showCheckmark: false,
                  backgroundColor: RiderColors.surfaceSoft,
                  selectedColor: RiderColors.goldSoft,
                  side: BorderSide(color: RiderColors.gold.withValues(alpha: .20)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  labelStyle: TextStyle(
                    color: RiderColors.text,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                  label: Text(
                    'Unread ($_unreadCount)',
                  ),
                  selected:
                      _unreadOnly,
                  onSelected:
                      (_) {
                    setState(() {
                      _unreadOnly =
                          true;
                    });
                  },
                ),

                const SizedBox(width: 2),

                if (_unreadCount > 0)
                  TextButton(
                    onPressed:
                        _working
                            ? null
                            : _markAllRead,
                    child:
                        const Text(
                      'Read all',
                    ),
                  ),
              ],
            ),
          ),

          if (_error != null &&
              _items.isNotEmpty)
            MaterialBanner(
              content: Text(
                'Refresh failed: $_error',
              ),
              actions: [
                TextButton(
                  onPressed:
                      _refresh,
                  child:
                      const Text(
                    'Retry',
                  ),
                ),
              ],
            ),

          Expanded(
            child: _loading
                ? Center(
                    child:
                        CircularProgressIndicator(
                      color:
                          RiderColors.gold,
                    ),
                  )
                : _error != null &&
                        _items.isEmpty
                    ? Center(
                        child: Padding(
                          padding:
                              const EdgeInsets.all(
                            24,
                          ),
                          child:
                              Column(
                            mainAxisSize:
                                MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons
                                    .wifi_off_rounded,
                                size:
                                    44,
                              ),

                              const SizedBox(
                                height:
                                    12,
                              ),

                              Text(
                                'Unable to load notifications',
                                style:
                                    TextStyle(
                                  color:
                                      RiderColors.text,
                                  fontWeight:
                                      FontWeight.w800,
                                ),
                              ),

                              const SizedBox(
                                height:
                                    8,
                              ),

                              Text(
                                _error!,
                                textAlign:
                                    TextAlign.center,
                                style:
                                    TextStyle(
                                  color:
                                      RiderColors.muted,
                                  fontSize:
                                      12,
                                ),
                              ),

                              const SizedBox(
                                height:
                                    16,
                              ),

                              OutlinedButton.icon(
                                onPressed:
                                    _refresh,
                                icon:
                                    const Icon(
                                  Icons.refresh,
                                ),
                                label:
                                    const Text(
                                  'Retry',
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh:
                            _refresh,
                        color:
                            RiderColors.gold,
                        child:
                            visible.isEmpty
                                ? ListView(
                                    children: [
                                      const SizedBox(
                                        height:
                                            115,
                                      ),

                                      Icon(
                                        Icons
                                            .notifications_none_rounded,
                                        size:
                                            52,
                                        color:
                                            RiderColors.muted,
                                      ),

                                      const SizedBox(
                                        height:
                                            14,
                                      ),

                                      Text(
                                        _unreadOnly
                                            ? 'No unread notifications'
                                            : 'No notifications yet',
                                        textAlign:
                                            TextAlign.center,
                                        style:
                                            TextStyle(
                                          color:
                                              RiderColors.text,
                                          fontSize:
                                              16,
                                          fontWeight:
                                              FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  )
                                : ListView.separated(
                                    padding:
                                        const EdgeInsets.all(
                                      16,
                                    ),
                                    itemCount:
                                        visible.length,
                                    separatorBuilder:
                                        (
                                      context,
                                      index,
                                    ) =>
                                            const SizedBox(
                                      height:
                                          10,
                                    ),
                                    itemBuilder:
                                        (
                                      context,
                                      index,
                                    ) =>
                                            _tile(
                                      visible[
                                          index],
                                    ),
                                  ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _tile(
    Map<String, dynamic> item,
  ) {
    final category =
        _text(
      item['category'],
    );

    final unread =
        item['unread'] ==
            true;

    final color =
        _colorFor(
      category,
    );

    final message =
        _text(
      item['message'],
    );

    final time =
        _text(
      item['time'],
    );

    return RiderSurface(
      elevated: unread,
      padding: const EdgeInsets.all(15),
      child: InkWell(
        borderRadius:
            BorderRadius.circular(
          14,
        ),
        onTap:
            _working
                ? null
                : () async {
                    await _markRead(
                      item,
                    );
                  },
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            RiderIconBadge(
              icon: _iconFor(category),
              color: color,
              size: 42,
              iconSize: 22,
              radius: 13,
            ),

            const SizedBox(
              width: 12,
            ),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _text(
                            item['title'],
                          ),
                          style:
                              TextStyle(
                            color:
                                RiderColors.text,
                            fontSize:
                                13,
                            fontWeight:
                                unread
                                    ? FontWeight.w900
                                    : FontWeight.w600,
                          ),
                        ),
                      ),

                      if (unread)
                        Container(
                          width:
                              8,
                          height:
                              8,
                          decoration:
                              BoxDecoration(
                            color:
                                RiderColors.gold,
                            shape:
                                BoxShape.circle,
                          ),
                        ),
                    ],
                  ),

                  if (message.isNotEmpty) ...[
                    const SizedBox(
                      height:
                          5,
                    ),

                    Text(
                      message,
                      style:
                          TextStyle(
                        color:
                            RiderColors.muted,
                        fontSize:
                            11,
                        height:
                            1.45,
                      ),
                    ),
                  ],

                  const SizedBox(
                    height: 7,
                  ),

                  Row(
                    children: [
                      Text(
                        time,
                        style:
                            TextStyle(
                          color:
                              RiderColors.muted,
                          fontSize:
                              10,
                        ),
                      ),

                      const Spacer(),

                      if (category ==
                              'message' &&
                          widget
                                  .onOpenMessages !=
                              null)
                        TextButton(
                          onPressed:
                              _working
                                  ? null
                                  : () async {
                                      await _markRead(
                                        item,
                                      );

                                      if (mounted) {
                                        widget
                                            .onOpenMessages
                                            ?.call();
                                      }
                                    },
                          child:
                              const Text(
                            'Open chat',
                          ),
                        ),

                      if (unread &&
                          category !=
                              'message')
                        Text(
                          'Tap to mark read',
                          style:
                              TextStyle(
                            color:
                                RiderColors.goldDark,
                            fontSize:
                                9,
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
    );
  }
}