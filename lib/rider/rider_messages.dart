
import 'package:flutter/material.dart';

import 'models/rider_message_model.dart';
import 'widgets/rider_ui.dart';

class RiderMessages extends StatefulWidget {
  const RiderMessages({
    super.key,
    required this.initialMessages,
  });

  final List<RiderMessage> initialMessages;

  @override
  State<RiderMessages> createState() => _RiderMessagesState();
}

class _RiderMessagesState extends State<RiderMessages> {
  final TextEditingController _searchController =
      TextEditingController();

  final TextEditingController _messageController =
      TextEditingController();

  final ScrollController _scrollController =
      ScrollController();

  bool _showSearch = false;

  List<RiderMessage> get _messages =>
      widget.initialMessages;

  List<RiderMessage> get _filteredMessages {
    final query = _searchController.text.trim().toLowerCase();

    if (query.isEmpty) return _messages;

    return _messages.where((message) {
      return message.body.toLowerCase().contains(query) ||
          message.senderRole.toLowerCase().contains(query) ||
          message.createdAt.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showNotice(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _toggleSearch() {
    setState(() {
      _showSearch = !_showSearch;

      if (!_showSearch) {
        _searchController.clear();
      }
    });
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;

    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  void _prepareQuickReply(String value) {
    _messageController.text = value;
    _messageController.selection = TextSelection.collapsed(
      offset: value.length,
    );

    setState(() {});
  }

  void _showSendUnavailable() {
    _showNotice(
      'Message sending is not yet connected to the '
      'Laravel Rider API. Your draft has not been sent.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RiderColors.bg,
      appBar: AppBar(
        backgroundColor: RiderColors.surface,
        foregroundColor: RiderColors.text,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 8,
        title: const RiderHeaderTitle(
          title: 'Chat / Messaging',
          subtitle: 'SARI Logistics',
        ),
        actions: [
          IconButton(
            tooltip: 'Search messages',
            onPressed: _toggleSearch,
            icon: Icon(
              _showSearch
                  ? Icons.search_off_rounded
                  : Icons.search_rounded,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_showSearch) _searchBar(),

          _conversationHeader(),

          _supportNotice(),

          Expanded(
            child: _filteredMessages.isEmpty
                ? _emptyMessages()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(
                      16, 18, 16, 20,
                    ),
                    itemCount: _filteredMessages.length,
                    itemBuilder: (context, index) {
                      final message = _filteredMessages[index];

                      return _messageBubble(message);
                    },
                  ),
          ),

          _composer(),
        ],
      ),
    );
  }

  Widget _searchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      color: RiderColors.surface,
      child: TextField(
        controller: _searchController,
        autofocus: true,
        onChanged: (_) => setState(() {}),
        style: TextStyle(
          color: RiderColors.text,
          fontSize: 13,
        ),
        decoration: InputDecoration(
          hintText: 'Search messages...',
          hintStyle: TextStyle(
            color: RiderColors.muted,
            fontSize: 12,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: RiderColors.muted,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  tooltip: 'Clear search',
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                  icon: const Icon(Icons.close_rounded),
                )
              : null,
          filled: true,
          fillColor: RiderColors.field,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: RiderColors.border,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: RiderColors.blue,
            ),
          ),
        ),
      ),
    );
  }

  Widget _conversationHeader() {
    final latest = _messages.isNotEmpty
        ? _messages.last
        : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: RiderColors.surface,
        border: Border(
          bottom: BorderSide(
            color: RiderColors.border,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: RiderColors.blueSoft,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: RiderColors.border,
              ),
            ),
            child: Icon(
              Icons.support_agent_rounded,
              color: RiderColors.blue,
              size: 27,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SARI Logistics',
                  style: TextStyle(
                    color: RiderColors.text,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Dispatch and delivery support',
                  style: TextStyle(
                    color: RiderColors.muted,
                    fontSize: 11,
                  ),
                ),
                if (latest != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    latest.isRider
                        ? 'You: ${latest.body}'
                        : latest.body,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: RiderColors.muted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            tooltip: 'Go to latest message',
            onPressed: _scrollToBottom,
            icon: Icon(
              Icons.vertical_align_bottom_rounded,
              color: RiderColors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _supportNotice() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(15, 13, 15, 0),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: RiderColors.blueSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: RiderColors.blue.withValues(alpha: .20),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: RiderColors.blue,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Your Logistics coordination channel. '
              'Use this for pickup instructions, '
              'parcel issues, and delivery support. '
              'Messages are currently displayed from '
              'locally loaded records.',
              style: TextStyle(
                color: RiderColors.text,
                fontSize: 11,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _messageBubble(RiderMessage message) {
    final isRider = message.isRider;

    return Align(
      alignment: isRider
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * .82,
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 13),
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
          decoration: BoxDecoration(
            color: isRider
                ? RiderColors.blue
                : RiderColors.surface,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(17),
              topRight: const Radius.circular(17),
              bottomLeft: Radius.circular(
                isRider ? 17 : 5,
              ),
              bottomRight: Radius.circular(
                isRider ? 5 : 17,
              ),
            ),
            border: isRider
                ? null
                : Border.all(color: RiderColors.border),
          ),
          child: Column(
            crossAxisAlignment: isRider
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              if (!isRider) ...[
                Text(
                  'SARI Logistics',
                  style: TextStyle(
                    color: RiderColors.blue,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
              ],

              Text(
                message.body,
                style: TextStyle(
                  color: isRider
                      ? Colors.white
                      : RiderColors.text,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 7),

              Text(
                message.createdAt,
                style: TextStyle(
                  color: isRider
                      ? Colors.white70
                      : RiderColors.muted,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyMessages() {
    final searching =
        _searchController.text.trim().isNotEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              searching
                  ? Icons.search_off_rounded
                  : Icons.chat_bubble_outline_rounded,
              size: 46,
              color: RiderColors.muted,
            ),
            const SizedBox(height: 15),
            Text(
              searching
                  ? 'No Matching Messages'
                  : 'No Messages Yet',
              style: TextStyle(
                color: RiderColors.text,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              searching
                  ? 'Try another keyword to find '
                      'a message in this conversation.'
                  : 'Messages from SARI Logistics '
                      'will appear here when loaded.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: RiderColors.muted,
                fontSize: 12,
                height: 1.5,
              ),
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
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 13),
        decoration: BoxDecoration(
          color: RiderColors.surface,
          border: Border(
            top: BorderSide(
              color: RiderColors.border,
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _quickReply('On my way'),
                  _quickReply('Arrived at location'),
                  _quickReply('Need dispatch support'),
                ],
              ),
            ),

            const SizedBox(height: 10),

            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    onChanged: (_) => setState(() {}),
                    minLines: 1,
                    maxLines: 4,
                    maxLength: 3000,
                    style: TextStyle(
                      color: RiderColors.text,
                      fontSize: 13,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Message Logistics...',
                      hintStyle: TextStyle(
                        color: RiderColors.muted,
                        fontSize: 12,
                      ),
                      counterText: '',
                      filled: true,
                      fillColor: RiderColors.field,
                      contentPadding:
                          const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 13,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(
                          color: RiderColors.border,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(
                          color: RiderColors.blue,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 9),
                SizedBox(
                  width: 48,
                  height: 48,
                  child: IconButton.filled(
                    tooltip: 'Messaging API not connected',
                    onPressed:
                        _messageController.text.trim().isEmpty
                            ? null
                            : _showSendUnavailable,
                    style: IconButton.styleFrom(
                      backgroundColor: RiderColors.blue,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          RiderColors.surfaceSoft,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    icon: const Icon(
                      Icons.send_rounded,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  size: 13,
                  color: RiderColors.muted,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    'Preview only. Messages cannot be sent '
                    'until the Laravel messaging API is connected.',
                    style: TextStyle(
                      color: RiderColors.muted,
                      fontSize: 10,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickReply(String text) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(
          text,
          style: TextStyle(
            color: RiderColors.text,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: RiderColors.surfaceSoft,
        side: BorderSide(
          color: RiderColors.border,
        ),
        onPressed: () => _prepareQuickReply(text),
      ),
    );
  }
}
