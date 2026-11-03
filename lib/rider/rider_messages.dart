import 'package:flutter/material.dart';

import '../services/sari_api.dart';
import '../services/sari_live_data.dart';
import 'models/rider_message_model.dart';
import 'widgets/rider_ui.dart';

class RiderMessages extends StatefulWidget {
  const RiderMessages({
    super.key,
    this.initialMessages = const [],
  });

  final List<RiderMessage> initialMessages;

  @override
  State<RiderMessages> createState() =>
      _RiderMessagesState();
}

class _RiderMessagesState
    extends State<RiderMessages> {
  final TextEditingController _messageController =
      TextEditingController();

  final ScrollController _scrollController =
      ScrollController();

  final List<RiderMessage> _messages = [];

  bool _loading = true;
  bool _sending = false;
  bool _usingFallback = false;

  String? _error;

  @override
  void initState() {
    super.initState();

    _messages.addAll(
      widget.initialMessages,
    );

    _load();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();

    super.dispose();
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

  int _int(
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

  String _text(
    dynamic value, [
    String fallback = '',
  ]) {
    final result =
        value?.toString().trim() ?? '';

    return result.isEmpty
        ? fallback
        : result;
  }

  RiderMessage _parseMessage(
    dynamic raw,
  ) {
    final data = _map(
      raw,
    );

    return RiderMessage(
      id: _int(
        data['id'],
      ),
      senderRole: _text(
        data['sender_role'],
        'logistics',
      ),
      body: _text(
        data['body'],
      ),
      createdAt: _text(
        data['created_at'],
      ),
    );
  }

  Future<void> _load() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final response =
          await SariLiveData.instance
              .riderMessages();

      final data = _map(
        response['data'],
      );

      final rawMessages =
          data['messages'];

      if (rawMessages is! List) {
        throw const FormatException(
          'Invalid Rider messages response.',
        );
      }

      final loaded = rawMessages
          .map(
            _parseMessage,
          )
          .where(
            (message) =>
                message.body
                    .trim()
                    .isNotEmpty,
          )
          .toList();

      if (!mounted) {
        return;
      }

      setState(() {
        _messages
          ..clear()
          ..addAll(
            loaded,
          );

        _loading = false;
        _usingFallback = false;
        _error = null;
      });

      _scheduleScrollToBottom();
    } on SariApiException catch (
      error
    ) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;
        _error = error.message;

        if (_messages.isNotEmpty) {
          _usingFallback = true;
        }
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;
        _error = error.toString();

        if (_messages.isNotEmpty) {
          _usingFallback = true;
        }
      });
    }
  }

  Future<void> _send() async {
    final body =
        _messageController.text
            .trim();

    if (body.isEmpty ||
        _sending) {
      return;
    }

    if (body.length > 3000) {
      _message(
        'Message cannot exceed 3000 characters.',
      );

      return;
    }

    setState(() {
      _sending = true;
    });

    try {
      final response =
          await SariLiveData.instance
              .riderSendMessage(
        body,
      );

      _messageController.clear();

      final sentData = _map(
        response['data'],
      );

      if (sentData.isNotEmpty &&
          mounted) {
        final sent =
            _parseMessage(
          sentData,
        );

        setState(() {
          final alreadyExists =
              _messages.any(
            (message) =>
                message.id ==
                sent.id,
          );

          if (!alreadyExists) {
            _messages.add(
              sent,
            );
          }

          _usingFallback = false;
        });

        _scheduleScrollToBottom();
      }

      await _load();
    } on SariApiException catch (
      error
    ) {
      _message(
        error.message,
      );
    } catch (error) {
      _message(
        'Unable to send message: $error',
      );
    } finally {
      if (mounted) {
        setState(() {
          _sending = false;
        });
      }
    }
  }

  void _scheduleScrollToBottom() {
    WidgetsBinding.instance
        .addPostFrameCallback(
      (_) {
        _scrollToBottom();
      },
    );
  }

  void _scrollToBottom() {
    if (!_scrollController
        .hasClients) {
      return;
    }

    _scrollController.animateTo(
      _scrollController
          .position.maxScrollExtent,
      duration:
          const Duration(
        milliseconds: 280,
      ),
      curve:
          Curves.easeOut,
    );
  }

  void _message(
    String message,
  ) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content:
              Text(message),
          behavior:
              SnackBarBehavior.floating,
        ),
      );
  }

  String _formatTime(
    String raw,
  ) {
    final date =
        DateTime.tryParse(
          raw,
        )?.toLocal();

    if (date == null) {
      return raw;
    }

    final hour =
        date.hour == 0
            ? 12
            : date.hour > 12
                ? date.hour - 12
                : date.hour;

    final minute =
        date.minute
            .toString()
            .padLeft(
              2,
              '0',
            );

    final period =
        date.hour >= 12
            ? 'PM'
            : 'AM';

    return '$hour:$minute $period';
  }

  String _formatDate(
    String raw,
  ) {
    final date =
        DateTime.tryParse(
          raw,
        )?.toLocal();

    if (date == null) {
      return '';
    }

    final now =
        DateTime.now();

    final today =
        DateTime(
      now.year,
      now.month,
      now.day,
    );

    final messageDay =
        DateTime(
      date.year,
      date.month,
      date.day,
    );

    final difference =
        today
            .difference(
              messageDay,
            )
            .inDays;

    if (difference == 0) {
      return 'Today';
    }

    if (difference == 1) {
      return 'Yesterday';
    }

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    if (date.year ==
        now.year) {
      return '${months[date.month - 1]} '
          '${date.day}';
    }

    return '${months[date.month - 1]} '
        '${date.day}, ${date.year}';
  }

  bool _showDateDivider(
    int index,
  ) {
    if (index == 0) {
      return true;
    }

    final current =
        _formatDate(
      _messages[index]
          .createdAt,
    );

    final previous =
        _formatDate(
      _messages[index - 1]
          .createdAt,
    );

    return current !=
        previous;
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          RiderColors.bg,
      appBar: AppBar(
        backgroundColor:
            RiderColors.surface,
        foregroundColor:
            RiderColors.text,
        surfaceTintColor:
            Colors.transparent,
        elevation: 0,
        titleSpacing: 16,
        title:
            const RiderHeaderTitle(
          title: 'Messages',
          subtitle:
              'Logistics Communication',
        ),
        actions: [
          IconButton(
            tooltip:
                'Refresh messages',
            onPressed:
                _loading
                    ? null
                    : _load,
            icon:
                const Icon(
              Icons.refresh_rounded,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _conversationHeader(),

          if (_usingFallback)
            _fallbackNotice(),

          Expanded(
            child:
                _messageBody(),
          ),

          _composer(),
        ],
      ),
    );
  }

  Widget _conversationHeader() {
    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.fromLTRB(
        16,
        12,
        16,
        14,
      ),
      decoration:
          BoxDecoration(
        color:
            RiderColors.surface,
        border: Border(
          bottom:
              BorderSide(
            color:
                RiderColors.border,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            alignment:
                Alignment.center,
            decoration:
                BoxDecoration(
              color:
                  RiderColors.blueSoft,
              borderRadius:
                  BorderRadius.circular(
                14,
              ),
            ),
            child: Icon(
              Icons
                  .local_shipping_outlined,
              color:
                  RiderColors.blue,
              size: 24,
            ),
          ),

          const SizedBox(
            width: 11,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'SARI Logistics',
                  style:
                      TextStyle(
                    color:
                        RiderColors.text,
                    fontSize: 14,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),

                const SizedBox(
                  height: 3,
                ),

                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration:
                          BoxDecoration(
                        color:
                            RiderColors.green,
                        shape:
                            BoxShape.circle,
                      ),
                    ),

                    const SizedBox(
                      width: 5,
                    ),

                    Expanded(
                      child: Text(
                        'Operations & rider support',
                        style:
                            TextStyle(
                          color:
                              RiderColors.muted,
                          fontSize: 9.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 6,
            ),
            decoration:
                BoxDecoration(
              color:
                  RiderColors.greenSoft,
              borderRadius:
                  BorderRadius.circular(
                20,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons
                      .verified_outlined,
                  color:
                      RiderColors.green,
                  size: 13,
                ),

                const SizedBox(
                  width: 4,
                ),

                Text(
                  'Official',
                  style:
                      TextStyle(
                    color:
                        RiderColors.green,
                    fontSize: 8,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _messageBody() {
    if (_loading &&
        _messages.isEmpty) {
      return Center(
        child:
            CircularProgressIndicator(
          color:
              RiderColors.gold,
        ),
      );
    }

    if (_error != null &&
        _messages.isEmpty) {
      return _errorState();
    }

    if (_messages.isEmpty) {
      return RefreshIndicator(
        color:
            RiderColors.gold,
        onRefresh:
            _load,
        child: ListView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          padding:
              const EdgeInsets.all(
            24,
          ),
          children: [
            const SizedBox(
              height: 70,
            ),

            Icon(
              Icons
                  .forum_outlined,
              size: 52,
              color:
                  RiderColors.muted,
            ),

            const SizedBox(
              height: 13,
            ),

            Text(
              'No messages yet',
              textAlign:
                  TextAlign.center,
              style:
                  TextStyle(
                color:
                    RiderColors.text,
                fontSize: 16,
                fontWeight:
                    FontWeight.w900,
              ),
            ),

            const SizedBox(
              height: 6,
            ),

            Text(
              'Use this conversation to communicate with your assigned SARI Logistics provider.',
              textAlign:
                  TextAlign.center,
              style:
                  TextStyle(
                color:
                    RiderColors.muted,
                fontSize: 10.5,
                height: 1.5,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color:
          RiderColors.gold,
      onRefresh:
          _load,
      child: ListView.builder(
        controller:
            _scrollController,
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding:
            const EdgeInsets.fromLTRB(
          15,
          18,
          15,
          20,
        ),
        itemCount:
            _messages.length,
        itemBuilder: (
          context,
          index,
        ) {
          final message =
              _messages[index];

          return Column(
            children: [
              if (_showDateDivider(
                index,
              ))
                _dateDivider(
                  _formatDate(
                    message
                        .createdAt,
                  ),
                ),

              _messageBubble(
                message,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _dateDivider(
    String label,
  ) {
    if (label.isEmpty) {
      return const SizedBox(
        height: 5,
      );
    }

    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 13,
      ),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color:
                  RiderColors.border,
            ),
          ),

          Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 10,
            ),
            child: Text(
              label,
              style:
                  TextStyle(
                color:
                    RiderColors.muted,
                fontSize: 8,
                fontWeight:
                    FontWeight.w700,
              ),
            ),
          ),

          Expanded(
            child: Divider(
              color:
                  RiderColors.border,
            ),
          ),
        ],
      ),
    );
  }

  Widget _messageBubble(
    RiderMessage message,
  ) {
    final rider =
        message.isRider;

    return Align(
      alignment:
          rider
              ? Alignment.centerRight
              : Alignment.centerLeft,
      child: Container(
        constraints:
            BoxConstraints(
          maxWidth:
              MediaQuery.sizeOf(
                    context,
                  ).width *
                  .78,
        ),
        margin:
            const EdgeInsets.only(
          bottom: 9,
        ),
        padding:
            const EdgeInsets.fromLTRB(
          13,
          11,
          13,
          9,
        ),
        decoration:
            BoxDecoration(
          color: rider
              ? RiderColors.blue
              : RiderColors.surface,
          borderRadius:
              BorderRadius.only(
            topLeft:
                const Radius.circular(
              16,
            ),
            topRight:
                const Radius.circular(
              16,
            ),
            bottomLeft:
                Radius.circular(
              rider ? 16 : 4,
            ),
            bottomRight:
                Radius.circular(
              rider ? 4 : 16,
            ),
          ),
          border: rider
              ? null
              : Border.all(
                  color:
                      RiderColors.border,
                ),
        ),
        child: Column(
          crossAxisAlignment:
              rider
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
          children: [
            if (!rider) ...[
              Row(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  Icon(
                    Icons
                        .support_agent_rounded,
                    color:
                        RiderColors.blue,
                    size: 14,
                  ),

                  const SizedBox(
                    width: 5,
                  ),

                  Text(
                    'SARI Logistics',
                    style:
                        TextStyle(
                      color:
                          RiderColors.blue,
                      fontSize: 8,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 6,
              ),
            ],

            Text(
              message.body,
              style:
                  TextStyle(
                color: rider
                    ? Colors.white
                    : RiderColors.text,
                fontSize: 11,
                height: 1.45,
              ),
            ),

            const SizedBox(
              height: 6,
            ),

            Row(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                Text(
                  _formatTime(
                    message
                        .createdAt,
                  ),
                  style:
                      TextStyle(
                    color: rider
                        ? Colors.white70
                        : RiderColors.muted,
                    fontSize: 7.5,
                  ),
                ),

                if (rider) ...[
                  const SizedBox(
                    width: 4,
                  ),
                  const Icon(
                    Icons
                        .done_all_rounded,
                    color:
                        Colors.white70,
                    size: 12,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _composer() {
    return SafeArea(
      top: false,
      child: Container(
        padding:
            const EdgeInsets.fromLTRB(
          12,
          10,
          12,
          11,
        ),
        decoration:
            BoxDecoration(
          color:
              RiderColors.surface,
          border: Border(
            top:
                BorderSide(
              color:
                  RiderColors.border,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller:
                    _messageController,
                minLines: 1,
                maxLines: 5,
                maxLength: 3000,
                enabled:
                    !_sending,
                textCapitalization:
                    TextCapitalization.sentences,
                keyboardType:
                    TextInputType.multiline,
                onSubmitted:
                    (_) {
                  if (!_sending) {
                    _send();
                  }
                },
                decoration:
                    InputDecoration(
                  hintText:
                      'Message Logistics...',
                  counterText: '',
                  filled: true,
                  fillColor:
                      RiderColors.field,
                  prefixIcon:
                      Icon(
                    Icons
                        .chat_bubble_outline_rounded,
                    color:
                        RiderColors.muted,
                    size: 19,
                  ),
                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                      16,
                    ),
                    borderSide:
                        BorderSide(
                      color:
                          RiderColors.border,
                    ),
                  ),
                  enabledBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                      16,
                    ),
                    borderSide:
                        BorderSide(
                      color:
                          RiderColors.border,
                    ),
                  ),
                  focusedBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                      16,
                    ),
                    borderSide:
                        BorderSide(
                      color:
                          RiderColors.blue,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(
              width: 8,
            ),

            SizedBox(
              width: 48,
              height: 48,
              child:
                  FilledButton(
                onPressed:
                    _sending
                        ? null
                        : _send,
                style:
                    FilledButton.styleFrom(
                  backgroundColor:
                      RiderColors.blue,
                  foregroundColor:
                      Colors.white,
                  padding:
                      EdgeInsets.zero,
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      15,
                    ),
                  ),
                ),
                child:
                    _sending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                              color:
                                  Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons
                                .send_rounded,
                            size: 20,
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallbackNotice() {
    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 9,
      ),
      color:
          RiderColors.goldSoft,
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            Icons
                .cloud_off_outlined,
            color:
                RiderColors.goldDark,
            size: 16,
          ),

          const SizedBox(
            width: 7,
          ),

          Expanded(
            child: Text(
              'Unable to refresh the conversation. Showing the messages already loaded on this device.',
              style:
                  TextStyle(
                color:
                    RiderColors.text,
                fontSize: 8.5,
                height: 1.4,
              ),
            ),
          ),

          InkWell(
            onTap: _load,
            child: Padding(
              padding:
                  const EdgeInsets.only(
                left: 8,
              ),
              child: Text(
                'Retry',
                style:
                    TextStyle(
                  color:
                      RiderColors.goldDark,
                  fontSize: 8.5,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorState() {
    return Center(
      child:
          SingleChildScrollView(
        padding:
            const EdgeInsets.all(
          27,
        ),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Container(
              width: 62,
              height: 62,
              alignment:
                  Alignment.center,
              decoration:
                  BoxDecoration(
                color:
                    RiderColors.redSoft,
                borderRadius:
                    BorderRadius.circular(
                  18,
                ),
              ),
              child: Icon(
                Icons
                    .cloud_off_outlined,
                color:
                    RiderColors.red,
                size: 31,
              ),
            ),

            const SizedBox(
              height: 15,
            ),

            Text(
              'Unable to load messages',
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
              height: 7,
            ),

            Text(
              _error ??
                  'Please check your connection.',
              textAlign:
                  TextAlign.center,
              style:
                  TextStyle(
                color:
                    RiderColors.muted,
                fontSize: 10,
                height: 1.45,
              ),
            ),

            const SizedBox(
              height: 15,
            ),

            FilledButton.icon(
              onPressed:
                  _load,
              icon:
                  const Icon(
                Icons.refresh_rounded,
              ),
              label:
                  const Text(
                'Try Again',
              ),
            ),
          ],
        ),
      ),
    );
  }
}