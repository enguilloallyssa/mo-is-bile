import 'package:flutter/material.dart';

import '../services/sari_live_data.dart';
import 'buyer_theme.dart';
import 'models/buyer_message_model.dart';
import 'widgets/buyer_header.dart';

class BuyerMessages extends StatefulWidget {
  final int? initialSellerId;
  final String buyerEmail;
  final ValueChanged<int>? onTabChanged;

  const BuyerMessages({
    super.key,
    this.initialSellerId,
    this.buyerEmail = '',
    this.onTabChanged,
  });

  @override
  State<BuyerMessages> createState() =>
      _BuyerMessagesState();
}

class _BuyerMessagesState
    extends State<BuyerMessages> {
  final TextEditingController
      _messageController =
      TextEditingController();

  final ScrollController
      _messageScrollController =
      ScrollController();

  final List<BuyerConversation>
      _conversations =
      <BuyerConversation>[];

  int? _selectedSellerId;

  bool _loading = true;
  bool _loadingThread = false;
  bool _sending = false;

  String? _error;

  @override
  void initState() {
    super.initState();

    _loadConversations();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _messageScrollController.dispose();

    super.dispose();
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

  int _int(
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
    dynamic value, [
    String fallback = '',
  ]) {
    final String text =
        value?.toString().trim() ?? '';

    return text.isEmpty
        ? fallback
        : text;
  }

  String _time(
    dynamic value,
  ) {
    final String raw =
        _text(value);

    final DateTime? date =
        DateTime.tryParse(
      raw,
    )?.toLocal();

    if (date == null) {
      return raw;
    }

    final DateTime now =
        DateTime.now();

    final bool sameDay =
        date.year == now.year &&
            date.month == now.month &&
            date.day == now.day;

    final int hour =
        date.hour == 0
            ? 12
            : date.hour > 12
                ? date.hour - 12
                : date.hour;

    final String minute =
        date.minute
            .toString()
            .padLeft(
              2,
              '0',
            );

    final String suffix =
        date.hour >= 12
            ? 'PM'
            : 'AM';

    if (sameDay) {
      return 'Today, $hour:$minute $suffix';
    }

    return '${date.month}/${date.day}/${date.year}, '
        '$hour:$minute $suffix';
  }

  Future<void> _loadConversations()
      async {
    if (!mounted) {
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final Map<String, dynamic>
          response =
          await SariLiveData
              .instance
              .buyerMessages();

      final dynamic raw =
          response['data'];

      if (raw is! List) {
        throw const FormatException(
          'Invalid seller conversation response.',
        );
      }

      final List<BuyerConversation>
          items = raw
              .map(
                (
                  dynamic entry,
                ) {
                  final Map<String,
                          dynamic>
                      item =
                      _map(entry);

                  return BuyerConversation(
                    sellerId:
                        _int(
                      item[
                          'seller_id'],
                    ),
                    storeName:
                        _text(
                      item[
                          'store_name'],
                      'SARI Seller',
                    ),
                    sellerEmail:
                        '',
                  );
                },
              )
              .where(
                (
                  BuyerConversation
                      item,
                ) =>
                    item.sellerId >
                    0,
              )
              .toList();

      final int? requested =
          widget.initialSellerId;

      if (requested != null &&
          requested > 0 &&
          !items.any(
            (
              BuyerConversation
                  item,
            ) =>
                item.sellerId ==
                requested,
          )) {
        items.insert(
          0,
          BuyerConversation(
            sellerId:
                requested,
            storeName:
                'SARI Seller',
            sellerEmail: '',
          ),
        );
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _conversations
          ..clear()
          ..addAll(items);

        _selectedSellerId =
            requested ??
                (_conversations
                        .isEmpty
                    ? null
                    : _conversations
                        .first
                        .sellerId);

        _loading = false;
      });

      if (_selectedSellerId !=
          null) {
        await _loadThread(
          _selectedSellerId!,
        );
      }
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;
        _error =
            error.toString();
      });
    }
  }

  Future<void> _loadThread(
    int sellerId,
  ) async {
    if (!mounted) {
      return;
    }

    setState(() {
      _selectedSellerId =
          sellerId;

      _loadingThread =
          true;
    });

    try {
      final Map<String, dynamic>
          response =
          await SariLiveData
              .instance
              .buyerMessageThread(
        sellerId,
      );

      final Map<String, dynamic>
          data =
          _map(
        response['data'],
      );

      final Map<String, dynamic>
          seller =
          _map(
        data['seller'],
      );

      final dynamic rawMessages =
          data['messages'];

      if (rawMessages is! List) {
        throw const FormatException(
          'Invalid seller message thread.',
        );
      }

      final List<BuyerMessage>
          messages =
          rawMessages
              .map(
                (
                  dynamic entry,
                ) {
                  final Map<String,
                          dynamic>
                      item =
                      _map(entry);

                  return BuyerMessage(
                    id: _int(
                      item['id'],
                    ),
                    sellerId:
                        _int(
                                  item[
                                      'seller_id'],
                                ) ==
                                0
                            ? sellerId
                            : _int(
                                item[
                                    'seller_id'],
                              ),
                    senderRole:
                        _text(
                      item[
                          'sender_role'],
                      'seller',
                    ),
                    body:
                        _text(
                      item['body'],
                    ),
                    createdAt:
                        _time(
                      item[
                          'created_at'],
                    ),
                  );
                },
              )
              .where(
                (
                  BuyerMessage
                      message,
                ) =>
                    message.id >
                    0,
              )
              .toList();

      final int index =
          _conversations
              .indexWhere(
        (
          BuyerConversation item,
        ) =>
            item.sellerId ==
            sellerId,
      );

      final BuyerConversation
          updated =
          BuyerConversation(
        sellerId: sellerId,
        storeName:
            _text(
          seller[
              'store_name'],
          index >= 0
              ? _conversations[
                      index]
                  .storeName
              : 'SARI Seller',
        ),
        sellerEmail: '',
        messages: messages,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        if (index >= 0) {
          _conversations[index] =
              updated;
        } else {
          _conversations.insert(
            0,
            updated,
          );
        }

        _loadingThread =
            false;
      });

      WidgetsBinding.instance
          .addPostFrameCallback(
        (_) {
          _scrollToBottom();
        },
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loadingThread =
            false;
      });

      _toast(
        'Unable to load messages: $error',
      );
    }
  }

  BuyerConversation?
      get _selectedConversation {
    final int? id =
        _selectedSellerId;

    if (id == null) {
      return null;
    }

    for (final BuyerConversation item
        in _conversations) {
      if (item.sellerId == id) {
        return item;
      }
    }

    return null;
  }

  Future<void> _sendMessage(
    BuyerConversation selected,
  ) async {
    final String body =
        _messageController.text
            .trim();

    if (body.isEmpty ||
        _sending) {
      return;
    }

    setState(() {
      _sending = true;
    });

    try {
      final Map<String, dynamic>
          response =
          await SariLiveData
              .instance
              .buyerSendMessage(
        selected.sellerId,
        body: body,
      );

      final Map<String, dynamic>
          item =
          _map(
        response['data'],
      );

      final BuyerMessage message =
          BuyerMessage(
        id: _int(
          item['id'],
        ),
        sellerId:
            _int(
                      item[
                          'seller_id'],
                    ) ==
                    0
                ? selected
                    .sellerId
                : _int(
                    item[
                        'seller_id'],
                  ),
        senderRole:
            _text(
          item['sender_role'],
          'buyer',
        ),
        body:
            _text(
          item['body'],
          body,
        ),
        createdAt:
            _time(
                  item[
                      'created_at'],
                )
                    .isEmpty
                ? 'Just now'
                : _time(
                    item[
                        'created_at'],
                  ),
      );

      final int index =
          _conversations
              .indexWhere(
        (
          BuyerConversation entry,
        ) =>
            entry.sellerId ==
            selected.sellerId,
      );

      if (!mounted ||
          index < 0) {
        return;
      }

      setState(() {
        _conversations[index] =
            selected.copyWith(
          messages:
              <BuyerMessage>[
            ...selected
                .messages,
            message,
          ],
        );

        _messageController
            .clear();
      });

      WidgetsBinding.instance
          .addPostFrameCallback(
        (_) {
          _scrollToBottom();
        },
      );
    } catch (error) {
      _toast(
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

  @override
  Widget build(
    BuildContext context,
  ) {
    final BuyerConversation?
        selected =
        _selectedConversation;

    return Scaffold(
      backgroundColor:
          BuyerTheme.canvas,
      body: Column(
        children: <Widget>[
          BuyerHeader(
            pageTitle:
                'Seller Messages',
            cartCount: 0,
            onSearchTap: () {
              widget.onTabChanged
                  ?.call(1);
            },
            onCartTap: () {
              widget.onTabChanged
                  ?.call(2);
            },
            onProfileTap: () {
              widget.onTabChanged
                  ?.call(4);
            },
          ),

          Expanded(
            child:
                RefreshIndicator(
              onRefresh:
                  _loadConversations,
              color:
                  BuyerTheme.gold,
              child: _loading
                  ? ListView(
                      children:
                          const <Widget>[
                        SizedBox(
                          height: 220,
                        ),
                        Center(
                          child:
                              CircularProgressIndicator(),
                        ),
                      ],
                    )
                  : _error !=
                              null &&
                          _conversations
                              .isEmpty
                      ? _errorState()
                      : selected ==
                              null
                          ? _conversationList()
                          : _chat(
                              selected,
                            ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorState() {
    return ListView(
      padding:
          const EdgeInsets.all(
        24,
      ),
      children: <Widget>[
        const SizedBox(
          height: 100,
        ),

        const Icon(
          Icons.cloud_off_rounded,
          size: 50,
          color:
              BuyerTheme.muted,
        ),

        const SizedBox(
          height: 14,
        ),

        const Text(
          'Messages are unavailable',
          textAlign:
              TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight:
                FontWeight.w800,
          ),
        ),

        const SizedBox(
          height: 7,
        ),

        Text(
          _error ??
              'Please try again.',
          textAlign:
              TextAlign.center,
          style:
              const TextStyle(
            color:
                BuyerTheme.muted,
            height: 1.5,
          ),
        ),

        const SizedBox(
          height: 18,
        ),

        Center(
          child:
              FilledButton.icon(
            onPressed:
                _loadConversations,
            icon:
                const Icon(
              Icons.refresh_rounded,
            ),
            label:
                const Text(
              'Retry',
            ),
          ),
        ),
      ],
    );
  }

  Widget _conversationList() {
    return ListView(
      padding:
          const EdgeInsets
              .fromLTRB(
        16,
        16,
        16,
        28,
      ),
      children: <Widget>[
        _hero(),

        const SizedBox(
          height: 14,
        ),

        if (_conversations
            .isEmpty)
          _emptyConversations()
        else
          ..._conversations.map(
            (
              BuyerConversation
                  item,
            ) =>
                _conversationTile(
              item,
            ),
          ),
      ],
    );
  }

  Widget _hero() {
    return Container(
      padding:
          const EdgeInsets.all(
        20,
      ),
      decoration:
          BoxDecoration(
        gradient:
            const LinearGradient(
          begin:
              Alignment.topLeft,
          end:
              Alignment.bottomRight,
          colors:
              BuyerTheme
                  .heroGradient,
        ),
        borderRadius:
            BorderRadius.circular(
          24,
        ),
        boxShadow:
            const <BoxShadow>[
          BoxShadow(
            color:
                Color(0x22000000),
            blurRadius: 24,
            offset:
                Offset(
              0,
              10,
            ),
          ),
        ],
      ),
      child:
          const Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: <Widget>[
                Text(
                  'SARI CHAT',
                  style:
                      TextStyle(
                    color:
                        Color(
                      0xFFFFD889,
                    ),
                    fontSize: 10,
                    fontWeight:
                        FontWeight
                            .w800,
                    letterSpacing:
                        1.2,
                  ),
                ),
                SizedBox(
                  height: 7,
                ),
                Text(
                  'Talk directly to your sellers',
                  style:
                      TextStyle(
                    color:
                        Colors.white,
                    fontSize: 20,
                    fontWeight:
                        FontWeight
                            .w900,
                    height: 1.1,
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                Text(
                  'Your conversations are synced with the same SARI account used on the web.',
                  style:
                      TextStyle(
                    color:
                        Colors.white70,
                    fontSize: 11,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 14,
          ),
          Icon(
            Icons.forum_rounded,
            color:
                Colors.white,
            size: 42,
          ),
        ],
      ),
    );
  }

  Widget _conversationTile(
    BuyerConversation item,
  ) {
    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 10,
      ),
      decoration:
          BuyerTheme.card(
        radius: 18,
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets
                .symmetric(
          horizontal: 14,
          vertical: 6,
        ),
        onTap: () {
          _loadThread(
            item.sellerId,
          );
        },
        leading: Container(
          width: 44,
          height: 44,
          decoration:
              BoxDecoration(
            color:
                BuyerTheme
                    .goldPale,
            borderRadius:
                BorderRadius
                    .circular(
              14,
            ),
          ),
          child:
              const Icon(
            Icons
                .storefront_rounded,
            color:
                BuyerTheme
                    .goldDark,
          ),
        ),
        title: Text(
          item.storeName,
          maxLines: 1,
          overflow:
              TextOverflow
                  .ellipsis,
          style:
              const TextStyle(
            fontWeight:
                FontWeight.w800,
            fontSize: 13,
          ),
        ),
        subtitle:
            const Padding(
          padding:
              EdgeInsets.only(
            top: 3,
          ),
          child: Text(
            'Open synced conversation',
            style:
                TextStyle(
              color:
                  BuyerTheme
                      .muted,
              fontSize: 10,
            ),
          ),
        ),
        trailing:
            const Icon(
          Icons
              .chevron_right_rounded,
          color:
              BuyerTheme.muted,
        ),
      ),
    );
  }

  Widget _chat(
    BuyerConversation selected,
  ) {
    return Column(
      children: <Widget>[
        Container(
          color:
              BuyerTheme.surface,
          padding:
              const EdgeInsets
                  .fromLTRB(
            8,
            8,
            14,
            10,
          ),
          child: Row(
            children: <Widget>[
              IconButton(
                onPressed: () {
                  setState(() {
                    _selectedSellerId =
                        null;
                  });
                },
                icon:
                    const Icon(
                  Icons
                      .arrow_back_rounded,
                ),
              ),

              Container(
                width: 40,
                height: 40,
                decoration:
                    BoxDecoration(
                  color:
                      BuyerTheme
                          .goldPale,
                  borderRadius:
                      BorderRadius
                          .circular(
                    13,
                  ),
                ),
                child:
                    const Icon(
                  Icons
                      .storefront_rounded,
                  color:
                      BuyerTheme
                          .goldDark,
                  size: 21,
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
                      selected
                          .storeName,
                      maxLines: 1,
                      overflow:
                          TextOverflow
                              .ellipsis,
                      style:
                          const TextStyle(
                        fontSize: 13,
                        fontWeight:
                            FontWeight
                                .w800,
                      ),
                    ),
                    const Text(
                      'Synced Buyer ↔ Seller conversation',
                      style:
                          TextStyle(
                        color:
                            BuyerTheme
                                .muted,
                        fontSize: 9.5,
                      ),
                    ),
                  ],
                ),
              ),

              IconButton(
                onPressed: () {
                  _loadThread(
                    selected
                        .sellerId,
                  );
                },
                icon:
                    const Icon(
                  Icons
                      .refresh_rounded,
                ),
              ),
            ],
          ),
        ),

        const Divider(
          height: 1,
        ),

        Expanded(
          child: _loadingThread
              ? const Center(
                  child:
                      CircularProgressIndicator(),
                )
              : selected
                      .messages
                      .isEmpty
                  ? _emptyThread()
                  : ListView.builder(
                      controller:
                          _messageScrollController,
                      padding:
                          const EdgeInsets
                              .fromLTRB(
                        16,
                        18,
                        16,
                        18,
                      ),
                      itemCount:
                          selected
                              .messages
                              .length,
                      itemBuilder:
                          (
                        BuildContext
                            context,
                        int index,
                      ) {
                        return _bubble(
                          selected
                              .messages[
                                  index],
                        );
                      },
                    ),
        ),

        _composer(
          selected,
        ),
      ],
    );
  }

  Widget _bubble(
    BuyerMessage message,
  ) {
    final bool mine =
        message.isBuyer;

    return Align(
      alignment: mine
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        constraints:
            const BoxConstraints(
          maxWidth: 315,
        ),
        margin:
            const EdgeInsets.only(
          bottom: 10,
        ),
        padding:
            const EdgeInsets
                .fromLTRB(
          14,
          11,
          14,
          9,
        ),
        decoration:
            BoxDecoration(
          color: mine
              ? BuyerTheme.goldDark
              : BuyerTheme.surface,
          borderRadius:
              BorderRadius.only(
            topLeft:
                const Radius.circular(
              18,
            ),
            topRight:
                const Radius.circular(
              18,
            ),
            bottomLeft:
                Radius.circular(
              mine ? 18 : 5,
            ),
            bottomRight:
                Radius.circular(
              mine ? 5 : 18,
            ),
          ),
          border: mine
              ? null
              : Border.all(
                  color:
                      BuyerTheme
                          .border,
                ),
          boxShadow:
              const <BoxShadow>[
            BoxShadow(
              color:
                  Color(0x08000000),
              blurRadius: 12,
              offset:
                  Offset(
                0,
                4,
              ),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: mine
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              message.body,
              style: TextStyle(
                color: mine
                    ? Colors.white
                    : BuyerTheme.ink,
                fontSize: 12,
                height: 1.45,
              ),
            ),

            const SizedBox(
              height: 5,
            ),

            Text(
              message.createdAt,
              style: TextStyle(
                color: mine
                    ? Colors.white70
                    : BuyerTheme
                        .muted,
                fontSize: 8.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _composer(
    BuyerConversation selected,
  ) {
    return SafeArea(
      top: false,
      child: Container(
        padding:
            const EdgeInsets
                .fromLTRB(
          12,
          10,
          12,
          10,
        ),
        decoration:
            const BoxDecoration(
          color:
              BuyerTheme.surface,
          border: Border(
            top: BorderSide(
              color:
                  BuyerTheme.border,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.end,
          children: <Widget>[
            Expanded(
              child: TextField(
                controller:
                    _messageController,
                minLines: 1,
                maxLines: 4,
                maxLength: 3000,
                decoration:
                    const InputDecoration(
                  hintText:
                      'Message the seller…',
                  counterText: '',
                ),
              ),
            ),

            const SizedBox(
              width: 8,
            ),

            SizedBox(
              width: 50,
              height: 50,
              child: FilledButton(
                onPressed: _sending
                    ? null
                    : () {
                        _sendMessage(
                          selected,
                        );
                      },
                style:
                    FilledButton
                        .styleFrom(
                  padding:
                      EdgeInsets.zero,
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius
                            .circular(
                      15,
                    ),
                  ),
                ),
                child: _sending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child:
                            CircularProgressIndicator(
                          strokeWidth:
                              2,
                          color:
                              Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons
                            .send_rounded,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyConversations() {
    return Container(
      padding:
          const EdgeInsets.all(
        28,
      ),
      decoration:
          BuyerTheme.card(
        radius: 20,
      ),
      child:
          const Column(
        children: <Widget>[
          Icon(
            Icons
                .chat_bubble_outline_rounded,
            size: 42,
            color:
                BuyerTheme
                    .goldDark,
          ),
          SizedBox(
            height: 12,
          ),
          Text(
            'No seller conversations yet',
            style: TextStyle(
              fontSize: 15,
              fontWeight:
                  FontWeight.w800,
            ),
          ),
          SizedBox(
            height: 6,
          ),
          Text(
            'Start from a product or order and your real conversation will appear here.',
            textAlign:
                TextAlign.center,
            style:
                TextStyle(
              color:
                  BuyerTheme.muted,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyThread() {
    return const Center(
      child: Padding(
        padding:
            EdgeInsets.all(
          28,
        ),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons
                  .waving_hand_outlined,
              size: 40,
              color:
                  BuyerTheme
                      .goldDark,
            ),
            SizedBox(
              height: 12,
            ),
            Text(
              'Start the conversation',
              style: TextStyle(
                fontSize: 15,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              'Ask the seller about a product or your order.',
              textAlign:
                  TextAlign.center,
              style:
                  TextStyle(
                color:
                    BuyerTheme.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _scrollToBottom() {
    if (!_messageScrollController
        .hasClients) {
      return;
    }

    _messageScrollController
        .animateTo(
      _messageScrollController
          .position
          .maxScrollExtent,
      duration:
          const Duration(
        milliseconds: 240,
      ),
      curve:
          Curves.easeOut,
    );
  }

  void _toast(
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
              SnackBarBehavior
                  .floating,
        ),
      );
  }
}