class BuyerCartItem {
  final int id;
  final int productId;
  final int sellerId;
  final String storeName;
  final String productName;
  final String variantLabel;
  final String? image;
  final double unitPrice;
  final int maxStock;
  final bool freeShipping;
  int quantity;

  BuyerCartItem({
    required this.id,
    required this.productId,
    required this.sellerId,
    required this.storeName,
    required this.productName,
    this.variantLabel = '',
    this.image,
    required this.unitPrice,
    required this.quantity,
    required this.maxStock,
    this.freeShipping = false,
  });

  double get lineTotal => unitPrice * quantity;

  BuyerCartItem copyWith({
    int? quantity,
  }) {
    return BuyerCartItem(
      id: id,
      productId: productId,
      sellerId: sellerId,
      storeName: storeName,
      productName: productName,
      variantLabel: variantLabel,
      image: image,
      unitPrice: unitPrice,
      quantity: quantity ?? this.quantity,
      maxStock: maxStock,
      freeShipping: freeShipping,
    );
  }
}
