import 'package:flutter/material.dart';

import '../services/sari_live_data.dart';
import 'buyer_theme.dart';

/// Mobile UI for the existing POST /api/v1/buyer/ai-assistant/message.
/// Answers are returned by Laravel; there are no hardcoded assistant replies.
class BuyerAiAssistant extends StatefulWidget {
  const BuyerAiAssistant({super.key});
  @override
  State<BuyerAiAssistant> createState() => _BuyerAiAssistantState();
}

class _BuyerAiAssistantState extends State<BuyerAiAssistant> {
  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final List<Map<String, String>> _messages = [];
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final message = _input.text.trim();
    if (message.isEmpty || message.length > 1200 || _sending) return;
    // Build history BEFORE adding the new user message.
    // Backend validates each history message as <=1200 characters.
    final recent = _messages.length <= 8
        ? _messages : _messages.sublist(_messages.length - 8);
    final history = recent.map((entry) {
      final text = entry['content'] ?? '';
      return <String, String>{
        'role': entry['role'] ?? 'user',
        'content': text.length > 1200 ? text.substring(0, 1200) : text,
      };
    }).toList();
    _input.clear();
    setState(() {
      _sending = true;
      _error = null;
      _messages.add({'role': 'user', 'content': message});
    });
    try {
      final response = await SariLiveData.instance.buyerAskAi(message,
        history: history, pagePath: '/buyer/account');
      final data = response['data'];
      final reply = data is Map ? data['reply']?.toString() ?? '' : '';
      if (!mounted) return;
      if (reply.trim().isEmpty) throw StateError('SARI AI sent an empty reply.');
      setState(() => _messages.add({'role': 'assistant', 'content': reply.trim()}));
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'The assistant is temporarily unavailable. You can retry your question.';
      });
    } finally {
      if (mounted) {
        setState(() => _sending = false);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scroll.hasClients) {
            _scroll.animateTo(_scroll.position.maxScrollExtent,
                duration: const Duration(milliseconds: 240), curve: Curves.easeOut);
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: BuyerTheme.canvas,
    appBar: AppBar(title: const Text('SARI Buyer Assistant')),
    body: SafeArea(
      child: Column(children: [
        Expanded(
          child: ListView(
            controller: _scroll,
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 20),
            children: [
              if (_messages.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BuyerTheme.card(radius: 20),
                  child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Icon(Icons.auto_awesome_rounded, color: BuyerTheme.goldDark, size: 28),
                    SizedBox(height: 10),
                    Text('How can SARI help?',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                    SizedBox(height: 6),
                    Text('Ask about orders, products, sizing, delivery, your cart, or your account. Answers come from the existing SARI Laravel assistant.',
                      style: TextStyle(color: BuyerTheme.muted, height: 1.4)),
                  ]),
                ),
              ..._messages.map((entry) {
                final user = entry['role'] == 'user';
                return Align(
                  alignment: user ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * .84),
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                    decoration: BoxDecoration(
                      color: user ? BuyerTheme.goldPale : Colors.white,
                      borderRadius: BorderRadius.circular(17),
                      border: Border.all(color: BuyerTheme.border),
                    ),
                    child: SelectableText(entry['content'] ?? '',
                      style: const TextStyle(fontSize: 13, height: 1.5)),
                  ),
                );
              }),
              if (_error != null)
                Padding(padding: const EdgeInsets.all(12),
                  child: Text(_error!, style: const TextStyle(color: Colors.red))),
              if (_sending)
                const Align(alignment: Alignment.centerLeft,
                  child: Padding(padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator())),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(12, 9, 12, 10),
          color: Colors.white,
          child: Row(children: [
            Expanded(child: TextField(
              controller: _input,
              enabled: !_sending,
              maxLines: 3,
              minLines: 1,
              maxLength: 1200,
              decoration: const InputDecoration(
                hintText: 'Ask SARI a question…',
                counterText: '', border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _send(),
            )),
            const SizedBox(width: 8),
            IconButton.filled(
              tooltip: 'Send', onPressed: _sending ? null : _send,
              icon: const Icon(Icons.send_rounded),
            ),
          ]),
        ),
      ]),
    ),
  );
}
