import '../models/buyer_message_model.dart';

class BuyerMessageService {
  int _nextMessageId = 100;

  List<BuyerConversation> loadDemoConversations() {
    return const [
      BuyerConversation(
        sellerId: 101,
        storeName: 'SARI Tech Corner',
        sellerEmail: 'techcorner@example.com',
        messages: [
          BuyerMessage(
            id: 1,
            sellerId: 101,
            senderRole: 'seller',
            body: 'Hello! Thanks for checking our products. How can we help you?',
            createdAt: 'Sep 27, 02:05 PM',
          ),
          BuyerMessage(
            id: 2,
            sellerId: 101,
            senderRole: 'buyer',
            body: 'Hi, I would like to ask if the black variant is still available.',
            createdAt: 'Sep 27, 02:08 PM',
          ),
          BuyerMessage(
            id: 3,
            sellerId: 101,
            senderRole: 'seller',
            body: 'Yes, the black variant is currently available.',
            createdAt: 'Sep 27, 02:10 PM',
          ),
        ],
      ),
      BuyerConversation(
        sellerId: 202,
        storeName: 'Daily Finds',
        sellerEmail: 'dailyfinds@example.com',
        messages: [
          BuyerMessage(
            id: 4,
            sellerId: 202,
            senderRole: 'seller',
            body: 'Welcome to Daily Finds. Feel free to ask about your order or any product.',
            createdAt: 'Sep 26, 11:20 AM',
          ),
        ],
      ),
      BuyerConversation(
        sellerId: 303,
        storeName: 'Local Essentials',
        sellerEmail: 'localessentials@example.com',
      ),
    ];
  }

  BuyerMessage createBuyerMessage({
    required int sellerId,
    required String body,
  }) {
    _nextMessageId++;

    return BuyerMessage(
      id: _nextMessageId,
      sellerId: sellerId,
      senderRole: 'buyer',
      body: body.trim(),
      createdAt: 'Just now',
    );
  }
}
