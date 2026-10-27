import '../models/buyer_order_model.dart';

class BuyerOrderSummary {
  final int total;
  final int active;
  final int delivered;
  final int cancelled;

  const BuyerOrderSummary({
    required this.total,
    required this.active,
    required this.delivered,
    required this.cancelled,
  });
}

class BuyerOrderService {
  List<BuyerOrder> filter(
    Iterable<BuyerOrder> orders, {
    String status = 'all',
    String query = '',
  }) {
    final normalizedQuery = query.trim().toLowerCase();

    return orders.where((order) {
      final matchesStatus = status == 'all' || order.filterGroup == status;
      if (!matchesStatus) return false;
      if (normalizedQuery.isEmpty) return true;

      final searchable = <String>[
        order.orderNumber,
        order.sellerName,
        order.statusLabel,
        ...order.productNames,
        ...order.items.map((item) => item.name),
      ].join(' ').toLowerCase();

      return searchable.contains(normalizedQuery);
    }).toList();
  }

  BuyerOrderSummary summarize(Iterable<BuyerOrder> orders) {
    final list = orders.toList();
    return BuyerOrderSummary(
      total: list.length,
      active: list.where((order) => !order.isDelivered && !order.isCancelled).length,
      delivered: list.where((order) => order.isDelivered).length,
      cancelled: list.where((order) => order.isCancelled).length,
    );
  }

  bool canCancel(BuyerOrder order) {
    return const {'new', 'preparing'}.contains(order.status);
  }

  bool canRequestReturn(BuyerOrder order) {
    return order.isDelivered && order.returnRequestStatus == null;
  }
}
