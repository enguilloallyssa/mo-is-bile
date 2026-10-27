import '../models/buyer_cart_model.dart';

class BuyerCartService {
  static const double deliveryFeePerSeller = 80;

  final List<BuyerCartItem> _items;

  BuyerCartService({List<BuyerCartItem> initialItems = const []})
      : _items = initialItems.map((item) => item.copyWith()).toList();

  List<BuyerCartItem> get items => List.unmodifiable(_items);

  void add(BuyerCartItem item) {
    final index = _items.indexWhere((existing) {
      return existing.productId == item.productId &&
          existing.sellerId == item.sellerId &&
          existing.variantLabel == item.variantLabel;
    });

    if (index < 0) {
      _items.add(item.copyWith());
      return;
    }

    final current = _items[index];
    final nextQuantity = (current.quantity + item.quantity)
        .clamp(1, current.maxStock)
        .toInt();
    _items[index] = current.copyWith(quantity: nextQuantity);
  }

  bool updateQuantity(int itemId, int quantity) {
    final index = _items.indexWhere((item) => item.id == itemId);
    if (index < 0) return false;

    final item = _items[index];
    if (quantity < 1 || quantity > item.maxStock) return false;

    _items[index] = item.copyWith(quantity: quantity);
    return true;
  }

  bool remove(int itemId) {
    final before = _items.length;
    _items.removeWhere((item) => item.id == itemId);
    return _items.length != before;
  }

  List<BuyerCartItem> selectedItems(Set<int> selectedIds) {
    return _items.where((item) => selectedIds.contains(item.id)).toList();
  }

  double subtotal(Iterable<BuyerCartItem> selected) {
    return selected.fold(0, (sum, item) => sum + item.lineTotal);
  }

  double deliveryFee(Iterable<BuyerCartItem> selected) {
    final groups = <int, List<BuyerCartItem>>{};
    for (final item in selected) {
      groups.putIfAbsent(item.sellerId, () => []).add(item);
    }

    double total = 0;
    for (final group in groups.values) {
      final groupSubtotal = subtotal(group);
      final hasPromo = group.any((item) => item.freeShipping);
      if (!(hasPromo && groupSubtotal >= 500)) {
        total += deliveryFeePerSeller;
      }
    }
    return total;
  }

  double grandTotal(Iterable<BuyerCartItem> selected) {
    final selectedList = selected.toList();
    return subtotal(selectedList) + deliveryFee(selectedList);
  }
}
