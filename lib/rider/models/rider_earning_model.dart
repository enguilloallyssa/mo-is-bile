class RiderDailyEarning {
  final String day;
  final double amount;

  const RiderDailyEarning({
    required this.day,
    required this.amount,
  });
}

class RiderEarningTransaction {
  final String order;
  final String date;
  final String type;
  final double amount;
  final String status;

  const RiderEarningTransaction({
    required this.order,
    required this.date,
    required this.type,
    required this.amount,
    required this.status,
  });
}

class RiderPayoutRequest {
  final double amount;
  final String status;

  const RiderPayoutRequest({
    required this.amount,
    required this.status,
  });
}
