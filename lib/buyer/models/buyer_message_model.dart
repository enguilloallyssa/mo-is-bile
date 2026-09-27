class BuyerConversation {
  final int sellerId;
  final String storeName;
  final String sellerEmail;
  final List<BuyerMessage> messages;

  const BuyerConversation({
    required this.sellerId,
    required this.storeName,
    required this.sellerEmail,
    this.messages = const [],
  });

  BuyerConversation copyWith({
    List<BuyerMessage>? messages,
  }) {
    return BuyerConversation(
      sellerId: sellerId,
      storeName: storeName,
      sellerEmail: sellerEmail,
      messages: messages ?? this.messages,
    );
  }
}

class BuyerMessage {
  final int id;
  final int sellerId;
  final String senderRole;
  final String body;
  final String createdAt;

  const BuyerMessage({
    required this.id,
    required this.sellerId,
    required this.senderRole,
    required this.body,
    required this.createdAt,
  });

  bool get isBuyer => senderRole.toLowerCase() == 'buyer';
}
