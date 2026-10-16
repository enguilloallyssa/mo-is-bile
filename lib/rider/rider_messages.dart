import 'package:flutter/material.dart';

import 'models/rider_message_model.dart';

class RiderMessages extends StatefulWidget {
  final List<RiderMessage> initialMessages;

  const RiderMessages({
    super.key,
    required this.initialMessages,
  });

  @override
  State<RiderMessages> createState() => _RiderMessagesState();
}

class _RiderMessagesState extends State<RiderMessages> {
  static const Color _blue = Color(0xFF3C6E91);

  late List<RiderMessage> _messages;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int _nextId = 100;

  @override
  void initState() {
    super.initState();
    _messages = [...widget.initialMessages];
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF8F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFDF8),
        surfaceTintColor: Colors.transparent,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Messages',
              style: TextStyle(
                color: Color(0xFF211D17),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'SARI Logistics',
              style: TextStyle(
                color: Color(0xFF918677),
                fontSize: 8,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFEADFC9),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Color(0xFFEADFC9),
                    ),
                  ),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SARI Logistics',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Real dispatch/support conversation.',
                      style: TextStyle(
                        color: Color(0xFF918677),
                        fontSize: 7.5,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  color: const Color(0xFFFCFAF6),
                  child: _messages.isEmpty
                      ? const Center(
                          child: Text(
                            'No messages yet.',
                            style: TextStyle(
                              color: Color(0xFF918677),
                              fontSize: 9,
                            ),
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(14),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final message = _messages[index];

                            return Align(
                              alignment: message.isRider
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                constraints: const BoxConstraints(
                                  maxWidth: 300,
                                ),
                                margin: const EdgeInsets.only(bottom: 9),
                                padding: const EdgeInsets.fromLTRB(
                                  13,
                                  10,
                                  13,
                                  9,
                                ),
                                decoration: BoxDecoration(
                                  color: message.isRider
                                      ? _blue
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: message.isRider
                                      ? null
                                      : Border.all(
                                          color: const Color(0xFFE7DFD4),
                                        ),
                                ),
                                child: Column(
                                  crossAxisAlignment: message.isRider
                                      ? CrossAxisAlignment.end
                                      : CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      message.body,
                                      style: TextStyle(
                                        color: message.isRider
                                            ? Colors.white
                                            : const Color(0xFF51493F),
                                        fontSize: 9,
                                        height: 1.5,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      message.createdAt,
                                      style: TextStyle(
                                        color: message.isRider
                                            ? Colors.white70
                                            : const Color(0xFF9A9187),
                                        fontSize: 6.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Color(0xFFEADFC9),
                    ),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        minLines: 2,
                        maxLines: 4,
                        maxLength: 3000,
                        style: const TextStyle(fontSize: 8.5),
                        decoration: InputDecoration(
                          hintText: 'Message Logistics...',
                          counterText: '',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _send,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _blue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                        ),
                        child: const Text(
                          'Send',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _send() {
    final body = _controller.text.trim();

    if (body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Type a message first.'),
        ),
      );
      return;
    }

    _nextId++;

    setState(() {
      _messages.add(
        RiderMessage(
          id: _nextId,
          senderRole: 'rider',
          body: body,
          createdAt: 'Just now',
        ),
      );
      _controller.clear();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }
}
