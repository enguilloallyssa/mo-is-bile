class RiderMessage {
  final int id;
  final String senderRole;
  final String body;
  final String createdAt;

  const RiderMessage({
    required this.id,
    required this.senderRole,
    required this.body,
    required this.createdAt,
  });

  bool get isRider => senderRole == 'rider';
}
