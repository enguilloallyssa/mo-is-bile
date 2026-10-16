class RiderHistoryRecord {
  final String order;
  final String customer;
  final String route;
  final String date;
  final String time;
  final double fee;
  final String status;
  final bool isToday;

  const RiderHistoryRecord({
    required this.order,
    required this.customer,
    required this.route,
    required this.date,
    required this.time,
    required this.fee,
    required this.status,
    required this.isToday,
  });

  String get searchable =>
      '$order $customer $route'.toLowerCase();
}
