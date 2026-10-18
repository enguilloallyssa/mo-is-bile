import 'package:flutter/material.dart';

import 'models/buyer_cart_model.dart';

class BuyerCheckout extends StatefulWidget {
  final List<BuyerCartItem> items;
  final String initialName;
  final String initialEmail;
  final String initialPhone;
  final String initialAddress;
  final VoidCallback? onOrderPlaced;

  const BuyerCheckout({
    super.key,
    required this.items,
    this.initialName = '',
    this.initialEmail = '',
    this.initialPhone = '',
    this.initialAddress = '',
    this.onOrderPlaced,
  });

  @override
  State<BuyerCheckout> createState() => _BuyerCheckoutState();
}

class _BuyerCheckoutState extends State<BuyerCheckout> {
  static const Color _gold = Color(0xFFC99128);
  static const Color _goldDark = Color(0xFFB47E1E);
  static const Color _pageBg = Color(0xFFFBFAF7);
  static const double _deliveryFeePerSeller = 80;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  final TextEditingController _voucherController = TextEditingController();

  bool _placingOrder = false;
  String _paymentMethod = 'COD';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _emailController = TextEditingController(text: widget.initialEmail);
    _phoneController = TextEditingController(text: widget.initialPhone);
    _addressController = TextEditingController(text: widget.initialAddress);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _voucherController.dispose();
    super.dispose();
  }

  Map<int, List<BuyerCartItem>> get _sellerGroups {
    final groups = <int, List<BuyerCartItem>>{};

    for (final item in widget.items) {
      groups.putIfAbsent(item.sellerId, () => <BuyerCartItem>[]);
      groups[item.sellerId]!.add(item);
    }

    return groups;
  }

  double get _subtotal {
    return widget.items.fold(
      0,
      (sum, item) => sum + item.lineTotal,
    );
  }

  double get _originalDeliveryFee =>
      _sellerGroups.length * _deliveryFeePerSeller;

  double _groupSubtotal(List<BuyerCartItem> items) {
    return items.fold(0, (sum, item) => sum + item.lineTotal);
  }

  bool _groupHasFreeShippingPromo(List<BuyerCartItem> items) {
    return items.any((item) => item.freeShipping);
  }

  bool _groupFreeShippingEligible(List<BuyerCartItem> items) {
    return _groupHasFreeShippingPromo(items) && _groupSubtotal(items) >= 500;
  }

  double get _shippingDiscount {
    double discount = 0;
    for (final group in _sellerGroups.values) {
      if (_groupFreeShippingEligible(group)) {
        discount += _deliveryFeePerSeller;
      }
    }
    return discount;
  }

  double get _deliveryFee => _originalDeliveryFee - _shippingDiscount;

  double get _grandTotal => _subtotal + _deliveryFee;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBg,
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F5F1),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 0,
        title: const Text(
          'Checkout',
          style: TextStyle(
            color: Color(0xFF302A24),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: widget.items.isEmpty
          ? _emptyCheckout()
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(12, 14, 12, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _deliverySection(),
                    const SizedBox(height: 12),
                    _paymentSection(),
                    const SizedBox(height: 12),
                    _productsSection(),
                    const SizedBox(height: 12),
                    _summarySection(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _deliverySection() {
    return _sectionCard(
      kicker: 'Delivery Information',
      title: 'Where should we deliver?',
      child: Column(
        children: [
          _field(
            controller: _nameController,
            label: 'Full Name',
            textInputAction: TextInputAction.next,
            validator: (value) {
              if ((value ?? '').trim().isEmpty) {
                return 'Enter your full name.';
              }
              return null;
            },
          ),
          const SizedBox(height: 11),
          _field(
            controller: _emailController,
            label: 'Email',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: (value) {
              final email = (value ?? '').trim();

              if (email.isEmpty) {
                return 'Enter your email.';
              }

              if (!email.contains('@') || !email.contains('.')) {
                return 'Enter a valid email.';
              }

              return null;
            },
          ),
          const SizedBox(height: 11),
          _field(
            controller: _phoneController,
            label: 'Contact Number',
            hint: '09xxxxxxxxx',
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            validator: (value) {
              final phone = (value ?? '').trim();

              if (phone.isEmpty) {
                return 'Enter your contact number.';
              }

              return null;
            },
          ),
          const SizedBox(height: 11),
          TextFormField(
            controller: _addressController,
            minLines: 4,
            maxLines: 4,
            textInputAction: TextInputAction.newline,
            style: const TextStyle(
              color: Color(0xFF514A42),
              fontSize: 9.5,
            ),
            decoration: _inputDecoration(
              label: 'Complete Delivery Address',
              hint:
                  'House/Unit, Street, Barangay, City/Municipality, Province',
            ),
            validator: (value) {
              if ((value ?? '').trim().isEmpty) {
                return 'Enter your complete delivery address.';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _paymentSection() {
    return _sectionCard(
      kicker: 'Payment',
      title: 'Payment Method',
      child: InkWell(
        onTap: () {
          setState(() {
            _paymentMethod = 'COD';
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFAF2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFEADFC9),
            ),
          ),
          child: Row(
            children: [
              Radio<String>(
                value: 'COD',
                groupValue: _paymentMethod,
                activeColor: _gold,
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _paymentMethod = value;
                  });
                },
              ),
              const SizedBox(width: 2),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cash on Delivery',
                      style: TextStyle(
                        color: Color(0xFF514A42),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Pay the courier after the package reaches you.',
                      style: TextStyle(
                        color: Color(0xFF91887D),
                        fontSize: 8,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _productsSection() {
    return _sectionCard(
      title: 'Products by Seller',
      child: Column(
        children: _sellerGroups.entries.map((entry) {
          final items = entry.value;
          final storeName =
              items.isEmpty ? 'SARI Seller' : items.first.storeName;

          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: const Color(0xFFFCFBF8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFEEE7DC),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  storeName,
                  style: const TextStyle(
                    color: Color(0xFFA8731F),
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (_groupHasFreeShippingPromo(items)) ...[
                  const SizedBox(height: 9),
                  _shippingPromotion(items),
                ],
                const SizedBox(height: 10),
                ...items.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 9),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${item.productName} × ${item.quantity}',
                                style: const TextStyle(
                                  color: Color(0xFF514A42),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (item.variantLabel.trim().isNotEmpty) ...[
                                const SizedBox(height: 3),
                                Text(
                                  item.variantLabel,
                                  style: const TextStyle(
                                    color: Color(0xFF91887D),
                                    fontSize: 7,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _peso(item.lineTotal),
                          style: const TextStyle(
                            color: Color(0xFF302A24),
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _shippingPromotion(List<BuyerCartItem> items) {
    const minimum = 500.0;
    final subtotal = _groupSubtotal(items);
    final eligible = _groupFreeShippingEligible(items);
    final remaining = (minimum - subtotal).clamp(0, minimum).toDouble();

    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: const Color(0xFFF4FAF6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD9E8DE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Free Shipping Promotion',
                      style: TextStyle(
                        color: Color(0xFF46775A),
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Minimum spend ₱500.00 · up to ₱80.00 shipping off',
                      style: TextStyle(
                        color: Color(0xFF708078),
                        fontSize: 6.5,
                        height: 1.4,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: eligible ? const Color(0xFFE5F5EB) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: eligible
                        ? const Color(0xFFCBE6D4)
                        : const Color(0xFFD5E3DA),
                  ),
                ),
                child: Text(
                  eligible
                      ? 'Applied · save ₱80.00'
                      : 'Add ${_peso(remaining)} more',
                  style: TextStyle(
                    color: eligible
                        ? const Color(0xFF397451)
                        : const Color(0xFF748178),
                    fontSize: 6.3,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Roboto',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summarySection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFEBE4DA),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D3D2F1F),
            blurRadius: 24,
            offset: Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Checkout Summary',
            style: TextStyle(
              color: Color(0xFF302A24),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: const Color(0xFFFCFBF8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFEEE7DC),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SELLER VOUCHER',
                  style: TextStyle(
                    color: Color(0xFF8D8479),
                    fontSize: 7.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .7,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _voucherController,
                  textCapitalization: TextCapitalization.characters,
                  style: const TextStyle(
                    color: Color(0xFF514A42),
                    fontSize: 9,
                  ),
                  decoration: _inputDecoration(
                    hint: 'Enter voucher code',
                  ),
                  onChanged: (value) {
                    final upper = value.toUpperCase();

                    if (value != upper) {
                      _voucherController.value =
                          _voucherController.value.copyWith(
                        text: upper,
                        selection: TextSelection.collapsed(
                          offset: upper.length,
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 7),
                const Text(
                  'A valid code is applied server-side to matching Seller items when you place the order.',
                  style: TextStyle(
                    color: Color(0xFF9B9287),
                    fontSize: 7,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _summaryRow(
            'Products',
            _peso(_subtotal),
          ),
          const SizedBox(height: 10),
          _summaryRow(
            'Courier delivery fee',
            _peso(_originalDeliveryFee),
          ),
          if (_shippingDiscount > 0) ...[
            const SizedBox(height: 10),
            _summaryRow(
              'Free Shipping discount',
              '-${_peso(_shippingDiscount)}',
              positive: true,
            ),
          ],
          const SizedBox(height: 10),
          _summaryRow(
            'Delivery payable',
            _peso(_deliveryFee),
          ),
          const SizedBox(height: 13),
          const Divider(
            height: 1,
            color: Color(0xFFEEE8DF),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Expanded(
                child: Text(
                  'Total',
                  style: TextStyle(
                    color: Color(0xFF514A42),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                _peso(_grandTotal),
                style: const TextStyle(
                  color: Color(0xFFB97805),
                  fontSize: 22,
                  height: 1,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -.8,
                  fontFamily: 'Roboto',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _placingOrder ? null : _placeOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: _gold,
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    const Color(0xFFD8D1C5),
                disabledForegroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _placingOrder
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Place Order',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 9),
          const Text(
            'Stock, vouchers, and Free Shipping eligibility are revalidated on the server when you place the order. Promotion schedules use Asia/Manila time.',
            style: TextStyle(
              color: Color(0xFF9B9287),
              fontSize: 7,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    String? kicker,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFEBE4DA),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if ((kicker ?? '').isNotEmpty) ...[
            Text(
              kicker!.toUpperCase(),
              style: const TextStyle(
                color: Color(0xFFA8731F),
                fontSize: 7.5,
                fontWeight: FontWeight.w700,
                letterSpacing: .9,
              ),
            ),
            const SizedBox(height: 5),
          ],
          Text(
            title,
            style: TextStyle(
              color: const Color(0xFF302A24),
              fontSize: kicker == null ? 16 : 19,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 15),
          child,
        ],
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      style: const TextStyle(
        color: Color(0xFF514A42),
        fontSize: 9.5,
      ),
      decoration: _inputDecoration(
        label: label,
        hint: hint,
      ),
      validator: validator,
    );
  }

  InputDecoration _inputDecoration({
    String? label,
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(
        color: Color(0xFF62594E),
        fontSize: 8.5,
        fontWeight: FontWeight.w600,
      ),
      hintStyle: const TextStyle(
        color: Color(0xFFA2998F),
        fontSize: 8.5,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 12,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFFE4DDD3),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFFE4DDD3),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: _gold,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFFA65353),
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFFA65353),
        ),
      ),
    );
  }

  Widget _summaryRow(
    String label,
    String value, {
    bool positive = false,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: positive
                  ? const Color(0xFF4F8065)
                  : const Color(0xFF8D8479),
              fontSize: 9,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          value,
          style: TextStyle(
            color: positive
                ? const Color(0xFF4F8065)
                : const Color(0xFF514A42),
            fontSize: 9,
            fontWeight: FontWeight.w700,
            fontFamily: 'Roboto',
          ),
        ),
      ],
    );
  }

  Widget _emptyCheckout() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.shopping_bag_outlined,
              size: 54,
              color: _gold,
            ),
            const SizedBox(height: 12),
            const Text(
              'No products to checkout',
              style: TextStyle(
                color: Color(0xFF403A33),
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Return to your cart and select at least one product.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF91887D),
                fontSize: 9,
              ),
            ),
            const SizedBox(height: 14),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back to Cart'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _placeOrder() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _placingOrder = true;
    });

    await Future<void>.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    setState(() {
      _placingOrder = false;
    });

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(
            Icons.check_circle_outline,
            color: Color(0xFF4F8065),
            size: 38,
          ),
          title: const Text(
            'Order preview complete',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'Total: ${_peso(_grandTotal)}\n'
            'Payment: Cash on Delivery\n\n'
            'Laravel API is not connected yet, so no real order was created.',
            style: const TextStyle(
              fontSize: 10,
              height: 1.5,
            ),
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(
                dialogContext,
                true,
              ),
              style: FilledButton.styleFrom(
                backgroundColor: _goldDark,
              ),
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );

    if (result != true || !mounted) return;

    widget.onOrderPlaced?.call();
  }

  String _peso(double value) {
    return '₱${value.toStringAsFixed(2)}';
  }
}
