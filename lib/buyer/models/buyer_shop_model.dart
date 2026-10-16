import 'buyer_product_model.dart';

class BuyerShopVoucher {
  final String code;
  final String name;
  final String value;
  final double minimum;

  const BuyerShopVoucher({
    required this.code,
    required this.name,
    required this.value,
    this.minimum = 0,
  });
}

class BuyerShopData {
  final int sellerAccountId;
  final String storeName;
  final String description;
  final String publicPhone;
  final String publicEmail;
  final String? logo;
  final String? banner;
  final double rating;
  final int ratingCount;
  final List<BuyerShopVoucher> vouchers;
  final List<BuyerProduct> products;

  const BuyerShopData({
    required this.sellerAccountId,
    required this.storeName,
    this.description = '',
    this.publicPhone = '',
    this.publicEmail = '',
    this.logo,
    this.banner,
    this.rating = 0,
    this.ratingCount = 0,
    this.vouchers = const [],
    this.products = const [],
  });
}
