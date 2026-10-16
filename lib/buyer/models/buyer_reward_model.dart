class BuyerRewardActivity {
  final String orderNumber;
  final double orderTotal;
  final int earnedPoints;
  final String deliveredDate;

  const BuyerRewardActivity({
    required this.orderNumber,
    required this.orderTotal,
    required this.earnedPoints,
    required this.deliveredDate,
  });
}
