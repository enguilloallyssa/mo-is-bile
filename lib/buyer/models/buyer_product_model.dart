class BuyerProductVariant {
  final int id;
  final String label;
  final double price;
  final double? oldPrice;
  final int stock;
  final String? image;
  final bool available;

  const BuyerProductVariant({
    required this.id,
    required this.label,
    required this.price,
    this.oldPrice,
    required this.stock,
    this.image,
    this.available = true,
  });
}

class BuyerProductReview {
  final int rating;
  final String comment;
  final String createdAt;

  const BuyerProductReview({
    required this.rating,
    this.comment = '',
    this.createdAt = '',
  });
}

class BuyerPackageInfo {
  final double? weightKg;
  final double? lengthCm;
  final double? widthCm;
  final double? heightCm;

  const BuyerPackageInfo({
    this.weightKg,
    this.lengthCm,
    this.widthCm,
    this.heightCm,
  });

  String get formatted {
    final parts = <String>[];

    if (weightKg != null) {
      parts.add('${_compact(weightKg!)} kg');
    }

    if (lengthCm != null && widthCm != null && heightCm != null) {
      parts.add(
        '${_compact(lengthCm!)} × ${_compact(widthCm!)} × ${_compact(heightCm!)} cm',
      );
    }

    return parts.join(' · ');
  }

  String _compact(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(1);
  }
}

class BuyerProduct {
  final int id;
  final String name;
  final String category;
  final String brand;
  final String sku;
  final String? image;
  final List<String> images;
  final double rating;
  final int ratingCount;
  final int sold;
  final int stock;
  final double price;
  final double? oldPrice;
  final bool freeShipping;
  final String? description;
  final List<String> variations;
  final List<BuyerProductVariant> variants;
  final List<BuyerProductReview> reviews;
  final Map<String, List<String>> optionGroups;
  final String shopName;
  final String shopSlug;
  final int sellerAccountId;
  final String condition;
  final int? preparationDays;
  final BuyerPackageInfo? packageInfo;

  const BuyerProduct({
    required this.id,
    required this.name,
    required this.category,
    this.brand = '',
    this.sku = '',
    this.image,
    this.images = const [],
    this.rating = 0,
    this.ratingCount = 0,
    this.sold = 0,
    this.stock = 0,
    required this.price,
    this.oldPrice,
    this.freeShipping = false,
    this.description,
    this.variations = const [],
    this.variants = const [],
    this.reviews = const [],
    this.optionGroups = const {},
    this.shopName = 'SARI Seller Store',
    this.shopSlug = '',
    this.sellerAccountId = 0,
    this.condition = '',
    this.preparationDays,
    this.packageInfo,
  });

  int get discountPercent {
    final original = oldPrice ?? 0;
    if (original <= price || original <= 0) return 0;
    return (((original - price) / original) * 100).round();
  }

  bool get isNew => rating <= 0 && sold <= 0 && stock > 0;

  bool get hasVariants => variants.isNotEmpty;

  List<String> get gallery {
    final result = <String>[];

    void addImage(String? value) {
      final cleaned = value?.trim() ?? '';
      if (cleaned.isNotEmpty && !result.contains(cleaned)) {
        result.add(cleaned);
      }
    }

    addImage(image);
    for (final item in images) {
      addImage(item);
    }

    return result;
  }
}
