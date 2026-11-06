import 'package:flutter/material.dart';
import '../services/sari_live_data.dart';
import 'widgets/logistics_ui.dart';

class LogisticsMessages extends StatefulWidget {
  const LogisticsMessages({super.key});

  @override
  State<LogisticsMessages> createState() =>
      _LogisticsMessagesState();
}

class _LogisticsMessagesState extends State<LogisticsMessages> {
  final _message = TextEditingController();

  int? _riderId;

  List<Map<String, dynamic>> _riders = [];
  List<Map<String, dynamic>> _messages = [];

  bool _busy = false;

  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRiders();
  }

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  Future<void> _loadRiders() async {
    setState(() => _busy = true);

    try {
      final response =
          await SariLiveData.instance.logisticsRiders();

      final data = response['data'];

      final raw =
          data is Map
              ? data['items']
              : null;

      final rows =
          raw is List
              ? raw
                  .whereType<Map>()
                  .map(
                    (e) =>
                        Map<String, dynamic>.from(e),
                  )
                  .toList()
              : <Map<String, dynamic>>[];

      if (!mounted) {
        return;
      }

      setState(() {
        _riders = rows;

        _riderId =
            rows.isEmpty
                ? null
                : (rows.first['id'] as num).toInt();
      });

      await _loadMessages();
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _loadMessages() async {
    if (_riderId == null) {
      return;
    }

    try {
      final response =
          await SariLiveData.instance.logisticsMessages(
        _riderId!,
      );

      final data = response['data'];

      final raw =
          data is Map
              ? data['items']
              : null;

      if (mounted) {
        setState(
          () =>
              _messages =
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
        setState(() => _error = e.toString());
      }
    }
  }

  Future<void> _send() async {
    final text = _message.text.trim();

    if (_riderId == null ||
        text.isEmpty ||
        _busy) {
      return;
    }

    setState(() => _busy = true);

    try {
      await SariLiveData.instance.logisticsSendMessage(
        _riderId!,
        text,
      );

      _message.clear();

      await _loadMessages();
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) =>
      Scaffold(
        backgroundColor:
            LogisticsPalette.canvas,

        appBar: AppBar(
          title:
              const Text(
            'Messages',
          ),

          actions: [
            IconButton(
              onPressed:
                  _loadRiders,

              icon:
                  const Icon(
                Icons.refresh,
              ),
            ),
          ],
        ),

        body: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.all(
                12,
              ),

              child:
                  DropdownButtonFormField<int>(
                value:
                    _riderId,

                isExpanded:
                    true,

                decoration:
                    const InputDecoration(
                  labelText:
                      'Rider',

                  border:
                      OutlineInputBorder(),
                ),

                items:
                    _riders
                        .map(
                          (r) =>
                              DropdownMenuItem<int>(
                            value:
                                (r['id'] as num).toInt(),

                            child:
                                Text(
                              '${r['first_name'] ?? ''} ${r['last_name'] ?? ''}',

                              overflow:
                                  TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),

                onChanged: (
                  value,
                ) {
                  setState(() {
                    _riderId = value;
                    _messages = [];
                  });

                  _loadMessages();
                },
              ),
            ),

            if (_error != null)
              Text(
                _error!,

                style:
                    const TextStyle(
                  color:
                      Colors.red,
                ),
              ),

            if (_busy)
              const LinearProgressIndicator(),

            Expanded(
              child:
                  ListView(
                padding:
                    const EdgeInsets.all(
                  12,
                ),

                children: [
                  if (_messages.isEmpty)
                    const Text(
                      'No messages in this thread.',
                    ),

                  ..._messages.map(
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
                              '${m['sender_role'] ?? ''}'
                                  .toUpperCase(),

                              style:
                                  const TextStyle(
                                fontSize: 10,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            Text(
                              '${m['body'] ?? ''}',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding:
                  EdgeInsets.fromLTRB(
                12,
                8,
                12,
                MediaQuery.viewInsetsOf(context).bottom > 0
                    ? 12
                    : 24,
              ),

              child:
                  Row(
                children: [
                  Expanded(
                    child:
                        TextField(
                      controller:
                          _message,

                      maxLength:
                          2000,

                      maxLines:
                          1,

                      decoration:
                          const InputDecoration(
                        hintText:
                            'Message Rider...',

                        border:
                            OutlineInputBorder(),
                      ),
                    ),
                  ),

                  IconButton(
                    onPressed:
                        _riderId == null || _busy
                            ? null
                            : _send,

                    icon:
                        const Icon(
                      Icons.send_rounded,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}