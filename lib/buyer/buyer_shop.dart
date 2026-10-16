import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'models/buyer_shop_model.dart';
import 'models/buyer_product_model.dart';
import 'widgets/buyer_product_card.dart';
import 'buyer_messages.dart';
import 'buyer_product_details.dart';

class BuyerShop extends StatefulWidget {
  final BuyerShopData shop;

  const BuyerShop({
    super.key,
    required this.shop,
  });

  @override
  State<BuyerShop> createState() => _BuyerShopState();
}

class _BuyerShopState extends State<BuyerShop> {
  final TextEditingController _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<BuyerProduct> get _filteredProducts {
    final q = _search.text.trim().toLowerCase();
    if (q.isEmpty) return widget.shop.products;
    return widget.shop.products.where((product) {
      return product.name.toLowerCase().contains(q) ||
          product.category.toLowerCase().contains(q) ||
          product.brand.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final products = _filteredProducts;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Seller Shop',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _shopProfile(),
            const SizedBox(height: 12),
            _productsSection(products),
          ],
        ),
      ),
    );
  }

  Widget _shopProfile() {
    final shop = widget.shop;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE3E8ED)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08111727),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if ((shop.banner ?? '').isNotEmpty)
            SizedBox(
              height: 135,
              child: _image(shop.banner!, fit: BoxFit.cover),
            )
          else
            Container(
              height: 82,
              decoration: const BoxDecoration(
                color: Color(0xFFF1F3F5),
              ),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 22),
              child: const Icon(
                Icons.storefront_outlined,
                color: Color(0xFFD7C6A3),
                size: 42,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFDFE5EA)),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: (shop.logo ?? '').isEmpty
                          ? const Icon(
                              Icons.storefront_outlined,
                              color: Color(0xFFC88912),
                              size: 27,
                            )
                          : _image(shop.logo!, fit: BoxFit.cover),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'VERIFIED SARI SELLER',
                            style: TextStyle(
                              color: Color(0xFF9D680D),
                              fontSize: 7,
                              fontWeight: FontWeight.w800,
                              letterSpacing: .8,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            shop.storeName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF111827),
                              fontSize: 20,
                              height: 1.05,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '${shop.products.length} active products · ★ ${shop.rating.toStringAsFixed(1)} from ${shop.ratingCount} reviews',
                            style: const TextStyle(
                              color: Color(0xFF7A8594),
                              fontSize: 7.5,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 41,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.push<void>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BuyerMessages(
                          initialSellerId: shop.sellerAccountId,
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.forum_outlined, size: 16),
                    label: const Text('Message Seller'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC88912),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      textStyle: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
                if (shop.description.trim().isNotEmpty ||
                    shop.publicPhone.trim().isNotEmpty ||
                    shop.publicEmail.trim().isNotEmpty) ...[
                  const SizedBox(height: 15),
                  const Divider(height: 1, color: Color(0xFFE3E8ED)),
                  const SizedBox(height: 14),
                  const Text(
                    'ABOUT THIS SHOP',
                    style: TextStyle(
                      color: Color(0xFF697586),
                      fontSize: 7,
                      fontWeight: FontWeight.w800,
                      letterSpacing: .6,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (shop.description.trim().isNotEmpty)
                    Text(
                      shop.description,
                      style: const TextStyle(
                        color: Color(0xFF667085),
                        fontSize: 8,
                        height: 1.55,
                      ),
                    ),
                  if (shop.publicPhone.trim().isNotEmpty ||
                      shop.publicEmail.trim().isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _contactInfo(),
                  ],
                ],
                if (shop.vouchers.isNotEmpty) ...[
                  const SizedBox(height: 15),
                  const Divider(height: 1, color: Color(0xFFE3E8ED)),
                  const SizedBox(height: 14),
                  const Text(
                    'AVAILABLE SELLER VOUCHERS',
                    style: TextStyle(
                      color: Color(0xFF697586),
                      fontSize: 7,
                      fontWeight: FontWeight.w800,
                      letterSpacing: .6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children: shop.vouchers.map(_voucherCard).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _contactInfo() {
    final shop = widget.shop;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFAFBFC),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: const Color(0xFFE3E8ED)),
      ),
      child: Column(
        children: [
          if (shop.publicPhone.trim().isNotEmpty)
            _contactRow('Store phone', shop.publicPhone),
          if (shop.publicPhone.trim().isNotEmpty && shop.publicEmail.trim().isNotEmpty)
            const Divider(height: 1, color: Color(0xFFEDF0F3)),
          if (shop.publicEmail.trim().isNotEmpty)
            _contactRow('Public email', shop.publicEmail),
        ],
      ),
    );
  }

  Widget _contactRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0xFF8A94A1), fontSize: 7),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF344054),
                fontSize: 7.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _voucherCard(BuyerShopVoucher voucher) {
    return InkWell(
      onTap: () async {
        await Clipboard.setData(ClipboardData(text: voucher.code));
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${voucher.code} copied')),
        );
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        constraints: const BoxConstraints(minWidth: 150),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE5D5B3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${voucher.code} · ${voucher.value}',
              style: const TextStyle(
                color: Color(0xFF9D680D),
                fontSize: 7.5,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              voucher.minimum > 0
                  ? '${voucher.name} · Min. ${_peso(voucher.minimum)}'
                  : voucher.name,
              style: const TextStyle(
                color: Color(0xFF7E8793),
                fontSize: 6.5,
                height: 1.35,
                fontFamily: 'Roboto',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _productsSection(List<BuyerProduct> products) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE3E8ED)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Products',
            style: TextStyle(
              color: Color(0xFF111827),
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Only approved and active listings are visible here.',
            style: TextStyle(color: Color(0xFF7A8594), fontSize: 7.5),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _search,
            onChanged: (_) => setState(() {}),
            style: const TextStyle(fontSize: 8.5),
            decoration: InputDecoration(
              hintText: 'Search this shop...',
              prefixIcon: const Icon(Icons.search, size: 18),
              isDense: true,
              filled: true,
              fillColor: const Color(0xFFFAFBFC),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFDCE2E7)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFDCE2E7)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (products.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFFAFBFC),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: const Color(0xFFD9E0E6)),
              ),
              child: const Text(
                'No products match your search.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF7C8794), fontSize: 8),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: products.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: .45,
              ),
              itemBuilder: (context, index) {
                final product = products[index];
                return BuyerProductCard(
                  product: product,
                  showPromotions: true,
                  showStock: true,
                  showQuickAdd: true,
                  onTap: () => Navigator.push<void>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BuyerProductDetails(
                        product: product,
                        relatedProducts: widget.shop.products,
                        onMessageSeller: () => Navigator.push<void>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BuyerMessages(
                              initialSellerId: widget.shop.sellerAccountId,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  onAddToCart: () => _toast('${product.name} added to cart'),
                  onBuyNow: () => Navigator.push<void>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BuyerProductDetails(
                        product: product,
                        relatedProducts: widget.shop.products,
                        buyNowMode: true,
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _image(String source, {required BoxFit fit}) {
    final network = source.startsWith('http://') || source.startsWith('https://') || source.startsWith('//');
    if (network) {
      return Image.network(
        source.startsWith('//') ? 'https:$source' : source,
        fit: fit,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) => const Center(
          child: Icon(Icons.image_outlined, color: Color(0xFFAAB1B9)),
        ),
      );
    }
    return Image.asset(
      source,
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, __, ___) => const Center(
        child: Icon(Icons.image_outlined, color: Color(0xFFAAB1B9)),
      ),
    );
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
    );
  }

  String _peso(double value) => '₱${value.toStringAsFixed(2)}';
}
