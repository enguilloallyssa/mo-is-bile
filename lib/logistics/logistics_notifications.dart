import 'package:flutter/material.dart';

import '../services/sari_live_data.dart';

import 'widgets/logistics_ui.dart';

class LogisticsNotifications extends StatefulWidget {
  const LogisticsNotifications({
    super.key,
  });

  @override
  State<LogisticsNotifications> createState() =>
      _LogisticsNotificationsState();
}

class _LogisticsNotificationsState
    extends State<LogisticsNotifications> {
  bool _busy =
      true;

  String? _error;

  List<Map<String, dynamic>>
      _items =
      [];

  @override
  void initState() {
    super.initState();

    _load();
  }

  Future<void> _load()
      async {
    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      final response =
          await SariLiveData.instance.logisticsNotifications();

      final data =
          response['data'];

      final raw =
          data is Map
              ? data['items']
              : null;

      if (mounted) {
        setState(
          () =>
              _items =
                  raw is List
                      ? raw
                          .whereType<Map>()
                          .map(
                            (e) =>
                                Map<String, dynamic>.from(e),
                          )
                          .toList()
                      : [],
        );
      }
    } catch (e) {
      if (mounted) {
        setState(
          () =>
              _error =
                  e.toString(),
        );
      }
    } finally {
      if (mounted) {
        setState(
          () =>
              _busy =
                  false,
        );
      }
    }
  }

  Future<void> _readAll() async {
    try {
      await SariLiveData.instance.logisticsReadAllNotifications();
      if (mounted) await _load();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to mark all read: $error')),
      );
    }
  }

  Future<void> _read(
    Map<String, dynamic> item,
  ) async {
    final id =
        (item['id'] as num?)
            ?.toInt();

    if (id == null) {
      return;
    }

    try {
      await SariLiveData.instance.logisticsReadNotification(
        id,
      );

      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content:
                Text(
              e.toString(),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) =>
      Scaffold(
        backgroundColor:
            LogisticsPalette.canvas,

        appBar:
            AppBar(
          title:
              const Text(
            'Notifications',
          ),

          actions: [
            IconButton(
              tooltip: 'Mark all read',
              onPressed: _busy ? null : _readAll,
              icon: const Icon(Icons.done_all_rounded),
            ),
            IconButton(
              onPressed:
                  _load,

              icon:
                  const Icon(
                Icons.refresh,
              ),
            ),
          ],
        ),

        body:
            RefreshIndicator(
          onRefresh:
              _load,

          child:
              ListView(
            padding:
                const EdgeInsets.all(
              15,
            ),

            children: [
              if (_busy)
                const LinearProgressIndicator(),

              if (_error !=
                  null)
                Text(
                  _error!,

                  style:
                      const TextStyle(
                    color:
                        Colors.red,
                  ),
                ),

              if (_items.isEmpty &&
                  !_busy &&
                  _error == null)
                const LogisticsEmptyCard(
                  icon:
                      Icons.notifications_none,

                  title:
                      'No notifications',

                  message:
                      'Updates from Laravel will appear here.',
                ),

              ..._items.map(
                (m) =>
                    Padding(
                  padding:
                      const EdgeInsets.only(
                    bottom: 8,
                  ),

                  child:
                      LogisticsSurface(
                    child:
                        Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [
                        Text(
                          '${m['title'] ?? 'Notification'}',

                          style:
                              const TextStyle(
                            fontWeight:
                                FontWeight.w800,
                          ),
                        ),

                        const SizedBox(
                          height: 5,
                        ),

                        Text(
                          '${m['message'] ?? ''}',
                        ),

                        if (m['read_at'] ==
                            null)
                          Align(
                            alignment:
                                Alignment.centerRight,

                            child:
                                TextButton(
                              onPressed: () =>
                                  _read(
                                m,
                              ),

                              child:
                                  const Text(
                                'Mark as read',
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}