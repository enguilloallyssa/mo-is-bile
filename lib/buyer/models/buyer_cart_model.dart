class BuyerCartItem {
  final int id;
  final int productId;

  // Kept for compatibility with older local cart code.
  // The current mobile cart API does not expose seller_id.
  final int sellerId;

  final int? variantId;

  final String storeName;
  final String productName;
  final String variantLabel;
  final String? image;

  final double unitPrice;
  final double? serverLineTotal;

  final int maxStock;

  // Kept for compatibility only.
  // Free-shipping calculations must come from Laravel,
  // not from this local flag.
  final bool freeShipping;

  final bool selectable;
  final String availabilityReason;

  int quantity;

  BuyerCartItem({
    required this.id,
    required this.productId,
    this.sellerId = 0,
    this.variantId,
    required this.storeName,
    required this.productName,
    this.variantLabel = '',
    this.image,
    required this.unitPrice,
    required this.quantity,
    required this.maxStock,
    this.serverLineTotal,
    this.freeShipping = false,
    this.selectable = true,
    this.availabilityReason = '',
  });

  double get lineTotal =>
      serverLineTotal ?? unitPrice * quantity;

  bool get quantityEditable =>
      maxStock > 0;

  BuyerCartItem copyWith({
    int? id,
    int? productId,
    int? sellerId,
    int? variantId,
    String? storeName,
    String? productName,
    String? variantLabel,
    String? image,
    double? unitPrice,
    double? serverLineTotal,
    int? quantity,
    int? maxStock,
    bool? freeShipping,
    bool? selectable,
    String? availabilityReason,
  }) {
    return BuyerCartItem(
      id: id ?? this.id,
      productId:
          productId ?? this.productId,
      sellerId:
          sellerId ?? this.sellerId,
      variantId:
          variantId ?? this.variantId,
      storeName:
          storeName ?? this.storeName,
      productName:
          productName ?? this.productName,
      variantLabel:
          variantLabel ?? this.variantLabel,
      image:
          image ?? this.image,
      unitPrice:
          unitPrice ?? this.unitPrice,
      serverLineTotal:
          serverLineTotal ??
              this.serverLineTotal,
      quantity:
          quantity ?? this.quantity,
      maxStock:
          maxStock ?? this.maxStock,
      freeShipping:
          freeShipping ??
              this.freeShipping,
      selectable:
          selectable ??
              this.selectable,
      availabilityReason:
          availabilityReason ??
              this.availabilityReason,
    );
  }
}