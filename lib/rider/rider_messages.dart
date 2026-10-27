import 'package:flutter/material.dart';

import 'models/rider_message_model.dart';
import 'widgets/rider_ui.dart';

class RiderMessages extends StatefulWidget {
  final List<RiderMessage> initialMessages;

  RiderMessages({super.key, required this.initialMessages});

  @override
  State<RiderMessages> createState() => _RiderMessagesState();
}

class _RiderMessagesState extends State<RiderMessages> {
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
      backgroundColor: RiderColors.bg,
      appBar: AppBar(
        toolbarHeight: 70,
        title: RiderHeaderTitle(title: 'Dispatch Chat', subtitle: 'SARI Logistics • Online'),
        actions: [
          IconButton(
            tooltip: 'Call Logistics',
            onPressed: () => _toast('Call action will connect to the logistics contact later.'),
            icon: Icon(Icons.call_outlined),
          ),
        ],
      ),
      body: Column(children: [
        _notice(),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.fromLTRB(14, 14, 14, 10),
            itemCount: _messages.length,
            itemBuilder: (context, index) => _bubble(_messages[index]),
          ),
        ),
        _composer(),
      ]),
    );
  }

  Widget _notice() {
    return Container(
      margin: EdgeInsets.fromLTRB(14, 12, 14, 0),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(color: RiderColors.blueSoft, borderRadius: BorderRadius.circular(14), border: Border.all(color: RiderColors.blue.withValues(alpha: .30))),
      child: Row(children: [
        Icon(Icons.support_agent_rounded, color: RiderColors.blue),
        SizedBox(width: 9),
        Expanded(child: Text('Use this chat for dispatch updates, parcel issues and route support.', style: TextStyle(color: RiderColors.blue, fontSize: 10.5, height: 1.35, fontWeight: FontWeight.w700))),
      ]),
    );
  }

  Widget _bubble(RiderMessage message) {
    return Align(
      alignment: message.isRider ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: 310),
        margin: EdgeInsets.only(bottom: 9),
        padding: EdgeInsets.fromLTRB(13, 10, 13, 9),
        decoration: BoxDecoration(
          color: message.isRider ? RiderColors.blue : RiderColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(message.isRider ? 16 : 4),
            bottomRight: Radius.circular(message.isRider ? 4 : 16),
          ),
          border: message.isRider ? null : Border.all(color: RiderColors.border),
        ),
        child: Column(
          crossAxisAlignment: message.isRider ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(message.body, style: TextStyle(color: message.isRider ? Colors.white : RiderColors.text, fontSize: 11.5, height: 1.45)),
            SizedBox(height: 5),
            Text(message.createdAt, style: TextStyle(color: message.isRider ? Colors.white.withValues(alpha: .72) : RiderColors.muted, fontSize: 8.5)),
          ],
        ),
      ),
    );
  }

  Widget _composer() {
    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(12, 9, 12, 12),
        decoration: BoxDecoration(color: RiderColors.surface, border: Border(top: BorderSide(color: RiderColors.border))),
        child: Column(children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [_quickReply('On my way'), _quickReply('Arrived at location'), _quickReply('Need dispatch support')]),
          ),
          SizedBox(height: 8),
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Expanded(
              child: TextField(
                controller: _controller,
                minLines: 1,
                maxLines: 4,
                maxLength: 3000,
                decoration: InputDecoration(
                  hintText: 'Message Logistics...',
                  counterText: '',
                  filled: true,
                  fillColor: RiderColors.bg,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: RiderColors.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: RiderColors.border)),
                ),
              ),
            ),
            SizedBox(width: 8),
            SizedBox(
              width: 48,
              height: 48,
              child: FilledButton(
                onPressed: _send,
                style: FilledButton.styleFrom(padding: EdgeInsets.zero, backgroundColor: RiderColors.blue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                child: Icon(Icons.send_rounded),
              ),
            ),
          ]),
        ]),
      ),
    );
  }

  Widget _quickReply(String value) {
    return Padding(
      padding: EdgeInsets.only(right: 7),
      child: ActionChip(
        label: Text(value, style: TextStyle(fontSize: 10)),
        onPressed: () {
          _controller.text = value;
          _controller.selection = TextSelection.collapsed(offset: _controller.text.length);
        },
        backgroundColor: RiderColors.surfaceSoft,
        side: BorderSide(color: RiderColors.border),
      ),
    );
  }

  void _send() {
    final value = _controller.text.trim();
    if (value.isEmpty) return;
    setState(() {
      _messages.add(RiderMessage(id: _nextId++, senderRole: 'rider', body: value, createdAt: 'Now'));
      _controller.clear();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: Duration(milliseconds: 220), curve: Curves.easeOut);
    });
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
