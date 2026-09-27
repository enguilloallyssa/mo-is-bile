import 'package:flutter/material.dart';

import 'models/buyer_message_model.dart';
import 'services/buyer_message_service.dart';
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
  State<BuyerMessages> createState() => _BuyerMessagesState();
}

class _BuyerMessagesState extends State<BuyerMessages> {
  static const Color _gold = Color(0xFFC99128);
  static const Color _pageBg = Color(0xFFFBFAF7);
  static const Color _border = Color(0xFFEBE4DA);

  final BuyerMessageService _service = BuyerMessageService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _messageScrollController = ScrollController();

  late List<BuyerConversation> _conversations;
  int? _selectedSellerId;

  @override
  void initState() {
    super.initState();
    _conversations = _service.loadDemoConversations();
    _selectedSellerId = _resolveInitialSeller();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _messageScrollController.dispose();
    super.dispose();
  }

  int? _resolveInitialSeller() {
    final requested = widget.initialSellerId;

    if (requested != null &&
        _conversations.any((item) => item.sellerId == requested)) {
      return requested;
    }

    if (requested != null) {
      _conversations = [
        ..._conversations,
        BuyerConversation(
          sellerId: requested,
          storeName: 'SARI Seller Store',
          sellerEmail: '',
        ),
      ];
      return requested;
    }

    if (_conversations.isEmpty) return null;
    return _conversations.first.sellerId;
  }

  BuyerConversation? get _selectedConversation {
    final sellerId = _selectedSellerId;
    if (sellerId == null) return null;

    for (final conversation in _conversations) {
      if (conversation.sellerId == sellerId) {
        return conversation;
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selectedConversation;

    return Scaffold(
      backgroundColor: _pageBg,
      body: Column(
        children: [
          BuyerHeader(
            pageTitle: 'Seller Messages',
            cartCount: 0,
            onSearchTap: () => widget.onTabChanged?.call(1),
            onCartTap: () => widget.onTabChanged?.call(2),
            onProfileTap: () => widget.onTabChanged?.call(4),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: _border),
                ),
                clipBehavior: Clip.antiAlias,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth >= 760;

                    if (wide) {
                      return Row(
                        children: [
                          SizedBox(
                            width: 280,
                            child: _conversationList(),
                          ),
                          const VerticalDivider(
                            width: 1,
                            color: Color(0xFFEEE8DF),
                          ),
                          Expanded(
                            child: _chatPanel(selected),
                          ),
                        ],
                      );
                    }

                    if (selected == null) {
                      return _conversationList(mobileOnly: true);
                    }

                    return _mobileChat(selected);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _conversationList({bool mobileOnly = false}) {
    return Container(
      color: const Color(0xFFFCFBF8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Text(
              'SELLER CONVERSATIONS',
              style: TextStyle(
                color: Color(0xFFA8731F),
                fontSize: 7.5,
                fontWeight: FontWeight.w700,
                letterSpacing: .8,
              ),
            ),
          ),
          Expanded(
            child: _conversations.isEmpty
                ? _noConversationListState()
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
                    itemCount: _conversations.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 7),
                    itemBuilder: (context, index) {
                      final conversation = _conversations[index];
                      final selected =
                          conversation.sellerId == _selectedSellerId;

                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedSellerId = conversation.sellerId;
                          });

                          WidgetsBinding.instance.addPostFrameCallback(
                            (_) => _scrollToBottom(),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: selected
                                ? const Color(0xFFFFF8EB)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selected
                                  ? const Color(0xFFD7B978)
                                  : const Color(0xFFEBE4DA),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 39,
                                height: 39,
                                decoration: BoxDecoration(
                                  color: selected
                                      ? const Color(0xFFFFF0CD)
                                      : const Color(0xFFF5F2ED),
                                  borderRadius: BorderRadius.circular(11),
                                ),
                                child: Icon(
                                  Icons.storefront_outlined,
                                  size: 19,
                                  color: selected
                                      ? const Color(0xFFB67813)
                                      : const Color(0xFF8E867D),
                                ),
                              ),
                              const SizedBox(width: 9),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      conversation.storeName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Color(0xFF514A42),
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      conversation.sellerEmail.trim().isEmpty
                                          ? 'Approved SARI seller'
                                          : conversation.sellerEmail,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Color(0xFF91887D),
                                        fontSize: 6.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.chevron_right,
                                size: 17,
                                color: Color(0xFFB8B0A7),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _mobileChat(BuyerConversation selected) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(8, 7, 12, 7),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0xFFEEE8DF)),
            ),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _selectedSellerId = null;
                  });
                },
                icon: const Icon(Icons.arrow_back, size: 19),
              ),
              const SizedBox(width: 3),
              Expanded(
                child: _chatHeaderContent(selected),
              ),
            ],
          ),
        ),
        Expanded(child: _messageList(selected)),
        _messageComposer(selected),
      ],
    );
  }

  Widget _chatPanel(BuyerConversation? selected) {
    if (selected == null) {
      return _chooseSellerState();
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 14,
          ),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0xFFEEE8DF)),
            ),
          ),
          child: _chatHeaderContent(selected),
        ),
        Expanded(child: _messageList(selected)),
        _messageComposer(selected),
      ],
    );
  }

  Widget _chatHeaderContent(BuyerConversation selected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          selected.storeName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF302A24),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        const Text(
          'Direct Buyer ↔ Seller conversation',
          style: TextStyle(
            color: Color(0xFF91887D),
            fontSize: 7.5,
          ),
        ),
      ],
    );
  }

  Widget _messageList(BuyerConversation selected) {
    final messages = selected.messages;

    if (messages.isEmpty) {
      return _startConversationState();
    }

    return ListView.builder(
      controller: _messageScrollController,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 18),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];

        return Align(
          alignment: message.isBuyer
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 310),
            margin: const EdgeInsets.only(bottom: 9),
            padding: const EdgeInsets.fromLTRB(13, 10, 13, 9),
            decoration: BoxDecoration(
              color: message.isBuyer
                  ? _gold
                  : const Color(0xFFFCFBF8),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(17),
                topRight: const Radius.circular(17),
                bottomLeft: Radius.circular(
                  message.isBuyer ? 17 : 5,
                ),
                bottomRight: Radius.circular(
                  message.isBuyer ? 5 : 17,
                ),
              ),
              border: message.isBuyer
                  ? null
                  : Border.all(
                      color: const Color(0xFFE7DFD4),
                    ),
            ),
            child: Column(
              crossAxisAlignment: message.isBuyer
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  message.body,
                  style: TextStyle(
                    color: message.isBuyer
                        ? Colors.white
                        : const Color(0xFF514A42),
                    fontSize: 9,
                    height: 1.55,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  message.createdAt,
                  style: TextStyle(
                    color: message.isBuyer
                        ? Colors.white.withOpacity(.72)
                        : const Color(0xFF9B9289),
                    fontSize: 6.5,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _messageComposer(BuyerConversation selected) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFEEE8DF)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              minLines: 2,
              maxLines: 4,
              maxLength: 3000,
              style: const TextStyle(
                color: Color(0xFF514A42),
                fontSize: 9,
              ),
              decoration: InputDecoration(
                hintText: 'Message the seller...',
                hintStyle: const TextStyle(
                  color: Color(0xFFAAA198),
                  fontSize: 9,
                ),
                counterText: '',
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 11,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFE4DDD3),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFE4DDD3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _gold),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 88,
            height: 52,
            child: ElevatedButton(
              onPressed: () => _sendMessage(selected),
              style: ElevatedButton.styleFrom(
                backgroundColor: _gold,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.send_outlined, size: 15),
                  SizedBox(width: 5),
                  Text(
                    'Send',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chooseSellerState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.forum_outlined,
              color: Color(0xFFC99128),
              size: 43,
            ),
            SizedBox(height: 12),
            Text(
              'Choose a seller',
              style: TextStyle(
                color: Color(0xFF403A33),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Approved shops appear here automatically.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF91887D),
                fontSize: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _noConversationListState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFDED5C9),
          ),
        ),
        child: const Text(
          'No seller conversation is available yet.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF91887D),
            fontSize: 8,
            height: 1.45,
          ),
        ),
      ),
    );
  }

  Widget _startConversationState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              color: Color(0xFFC99128),
              size: 39,
            ),
            SizedBox(height: 11),
            Text(
              'Start the conversation',
              style: TextStyle(
                color: Color(0xFF514A42),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Ask about a product or your order.',
              style: TextStyle(
                color: Color(0xFF91887D),
                fontSize: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage(BuyerConversation selected) {
    final body = _messageController.text.trim();

    if (body.isEmpty) {
      _toast('Type a message first.');
      return;
    }

    final newMessage = _service.createBuyerMessage(
      sellerId: selected.sellerId,
      body: body,
    );

    final index = _conversations.indexWhere(
      (item) => item.sellerId == selected.sellerId,
    );

    if (index < 0) return;

    setState(() {
      _conversations[index] = selected.copyWith(
        messages: [
          ...selected.messages,
          newMessage,
        ],
      );

      _messageController.clear();
    });

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scrollToBottom(),
    );
  }

  void _scrollToBottom() {
    if (!_messageScrollController.hasClients) return;

    _messageScrollController.animateTo(
      _messageScrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOut,
    );
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
