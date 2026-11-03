import 'package:flutter/material.dart';

import '../services/sari_live_data.dart';
import 'models/buyer_cart_model.dart';

class BuyerCheckout extends StatefulWidget {
  final List<BuyerCartItem> items;

  const BuyerCheckout({
    super.key,
    required this.items,
  });

  @override
  State<BuyerCheckout> createState() =>
      _BuyerCheckoutState();
}

class _BuyerCheckoutState
    extends State<BuyerCheckout> {
  static const Color gold =
      Color(0xFFCC8A0B);

  static const Color goldDark =
      Color(0xFFA96D07);

  static const Color dark =
      Color(0xFF24201C);

  static const Color muted =
      Color(0xFF7F776E);

  static const Color canvas =
      Color(0xFFFBFAF8);

  static const Color border =
      Color(0xFFE9E3DB);

  final GlobalKey<FormState>
      _formKey =
      GlobalKey<FormState>();

  final TextEditingController
      _nameController =
      TextEditingController();

  final TextEditingController
      _emailController =
      TextEditingController();

  final TextEditingController
      _phoneController =
      TextEditingController();

  final TextEditingController
      _addressController =
      TextEditingController();

  final TextEditingController
      _voucherController =
      TextEditingController();

  bool _loading = true;
  bool _placingOrder = false;

  String? _error;

  Map<String, dynamic>
      _profile = {};

  List<Map<String, dynamic>>
      _addresses = [];

  List<Map<String, dynamic>>
      _previewItems = [];

  String? _addressChoice;

  double _subtotal = 0;

  double _originalDeliveryFee = 0;

  double _shippingDiscount = 0;

  double _deliveryFee = 0;

  double _grandTotal = 0;

  @override
  void initState() {
    super.initState();

    _loadCheckout();
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

  Map<String, dynamic> _map(
    dynamic value,
  ) {
    if (value is Map) {
      return Map<String, dynamic>.from(
        value,
      );
    }

    return {};
  }

  String _text(
    dynamic value, [
    String fallback = '',
  ]) {
    final text =
        value?.toString().trim() ?? '';

    return text.isEmpty
        ? fallback
        : text;
  }

  int _integer(dynamic value) {
    if (value is num) {
      return value.toInt();
    }

    return int.tryParse('$value') ?? 0;
  }

  double _decimal(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse('$value') ?? 0;
  }

  String _registeredAddress() {
    return [
      _text(
        _profile['street_address'],
      ),
      _text(
        _profile['barangay_name'],
      ),
      _text(
        _profile['municipality_name'],
      ),
      _text(
        _profile['province_name'],
      ),
    ]
        .where(
          (part) => part.isNotEmpty,
        )
        .join(', ');
  }

  Future<void> _loadCheckout()
      async {
    if (widget.items.isEmpty) {
      setState(() {
        _loading = false;
        _error =
            'No products were selected for checkout.';
      });

      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final itemIds = widget.items
          .map(
            (item) => item.id,
          )
          .toList();

      final results =
          await Future.wait([
        SariLiveData.instance
            .buyerCheckoutPreview(
          itemIds,
        ),
        SariLiveData.instance
            .buyerProfile(),
      ]);

      final preview =
          _map(
        results[0]['data'],
      );

      final profileResponse =
          _map(
        results[1]['data'],
      );

      final profile =
          _map(
        profileResponse['profile'],
      );

      final rawAddresses =
          preview['addresses'] is List
              ? preview['addresses']
                  as List
              : const [];

      final addresses = rawAddresses
          .map(_map)
          .where(
            (address) =>
                _integer(
                  address['id'],
                ) >
                0,
          )
          .toList();

      final previewItems =
          preview['items'] is List
              ? (preview['items']
                      as List)
                  .map(_map)
                  .toList()
              : <Map<String, dynamic>>[];

      final shipping =
          _map(
        preview['shipping'],
      );

      if (!mounted) return;

      setState(() {
        _profile = profile;

        _addresses = addresses;

        _previewItems =
            previewItems;

        _subtotal =
            _decimal(
          preview['subtotal'],
        );

        _originalDeliveryFee =
            _decimal(
          shipping[
              'original_delivery_fee'],
        );

        _shippingDiscount =
            _decimal(
          shipping[
              'shipping_discount'],
        );

        _deliveryFee =
            _decimal(
          shipping[
              'delivery_fee'],
        );

        _grandTotal =
            _decimal(
          preview['grand_total'],
        );

        _nameController.text =
            _text(
          profile['full_name'],
        );

        _emailController.text =
            _text(
          profile['email'],
        );

        _phoneController.text =
            _text(
          profile['contact_no'],
        );

        final registeredAddress =
            _registeredAddress();

        if (registeredAddress
            .isNotEmpty) {
          _addressChoice =
              'registered';

          _addressController.text =
              registeredAddress;
        } else if (_addresses
            .isNotEmpty) {
          final address =
              _addresses.first;

          _addressChoice =
              'saved:${address['id']}';

          _applySavedAddress(
            address,
          );
        }

        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error =
            error.toString();
      });
    }
  }

  void _applyAddressChoice(
    String? choice,
  ) {
    if (choice == null) {
      return;
    }

    setState(() {
      _addressChoice = choice;
    });

    if (choice == 'registered') {
      _nameController.text =
          _text(
        _profile['full_name'],
      );

      _phoneController.text =
          _text(
        _profile['contact_no'],
      );

      _addressController.text =
          _registeredAddress();

      return;
    }

    if (choice.startsWith(
      'saved:',
    )) {
      final id = int.tryParse(
        choice.substring(
          'saved:'.length,
        ),
      );

      if (id == null) return;

      for (final address
          in _addresses) {
        if (_integer(
              address['id'],
            ) ==
            id) {
          _applySavedAddress(
            address,
          );

          return;
        }
      }
    }
  }

  void _applySavedAddress(
    Map<String, dynamic> address,
  ) {
    _nameController.text =
        _text(
      address['recipient_name'],
    );

    _phoneController.text =
        _text(
      address['contact_no'],
    );

    _addressController.text =
        _text(
      address['full_address'],
    );
  }

  Map<String, List<Map<String, dynamic>>>
      get _itemsByStore {
    final groups = <String,
        List<Map<String, dynamic>>>{};

    for (final item
        in _previewItems) {
      final store = _text(
        item['store_name'],
        'SARI Seller Store',
      );

      groups
          .putIfAbsent(
            store,
            () =>
                <Map<String, dynamic>>[],
          )
          .add(item);
    }

    return groups;
  }

  Future<void> _placeOrder()
      async {
    FocusScope.of(context)
        .unfocus();

    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    setState(() {
      _placingOrder = true;
    });

    try {
      final response =
          await SariLiveData.instance
              .buyerCheckout(
        name:
            _nameController.text
                .trim(),
        email:
            _emailController.text
                .trim(),
        phone:
            _phoneController.text
                .trim(),
        address:
            _addressController.text
                .trim(),
        itemIds: widget.items
            .map(
              (item) => item.id,
            )
            .toList(),
        voucherCode:
            _voucherController.text
                .trim(),
      );

      final data =
          _map(
        response['data'],
      );

      final orders =
          data['orders'] is List
              ? (data['orders']
                      as List)
                  .map(_map)
                  .toList()
              : <Map<String, dynamic>>[];

      if (!mounted) return;

      await showDialog<void>(
        context: context,
        barrierDismissible:
            false,
        builder: (dialogContext) {
          return AlertDialog(
            icon: const Icon(
              Icons
                  .check_circle_outline_rounded,
              color: Color(
                0xFF4F8065,
              ),
              size: 42,
            ),
            title: const Text(
              'Order placed',
            ),
            content:
                SingleChildScrollView(
              child: Column(
                mainAxisSize:
                    MainAxisSize.min,
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Text(
                    response['message']
                            ?.toString() ??
                        'Order placed successfully.',
                  ),
                  if (orders
                      .isNotEmpty) ...[
                    const SizedBox(
                      height: 14,
                    ),
                    ...orders.map(
                      (order) =>
                          Padding(
                        padding:
                            const EdgeInsets
                                .only(
                          bottom: 8,
                        ),
                        child:
                            Container(
                          width:
                              double.infinity,
                          padding:
                              const EdgeInsets
                                  .all(
                            10,
                          ),
                          decoration:
                              BoxDecoration(
                            color:
                                const Color(
                              0xFFF8F8F8,
                            ),
                            borderRadius:
                                BorderRadius
                                    .circular(
                              9,
                            ),
                          ),
                          child:
                              Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              Text(
                                _text(
                                  order[
                                      'order_number'],
                                ),
                                style:
                                    const TextStyle(
                                  fontWeight:
                                      FontWeight
                                          .w800,
                                ),
                              ),
                              const SizedBox(
                                height: 3,
                              ),
                              Text(
                                'Total: ${_money(_decimal(order['total']))}',
                                style:
                                    const TextStyle(
                                  fontSize:
                                      11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              FilledButton(
                onPressed: () =>
                    Navigator.of(
                      dialogContext,
                    ).pop(),
                child:
                    const Text(
                  'Continue',
                ),
              ),
            ],
          );
        },
      );

      if (!mounted) return;

      Navigator.of(context).pop(
        true,
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              error.toString(),
            ),
            behavior:
                SnackBarBehavior.floating,
          ),
        );
    } finally {
      if (mounted) {
        setState(() {
          _placingOrder = false;
        });
      }
    }
  }

  String _money(
    double amount,
  ) {
    return '₱${amount.toStringAsFixed(2)}';
  }

  Widget _shippingAddressSection() {
    final registered =
        _registeredAddress();

    final hasAddressOptions =
        registered.isNotEmpty ||
            _addresses.isNotEmpty;

    return _sectionCard(
      icon:
          Icons.location_on_outlined,
      title:
          'Shipping address',
      subtitle:
          'Confirm the recipient and delivery details.',
      child: Column(
        children: [
          TextFormField(
            controller:
                _nameController,
            textInputAction:
                TextInputAction.next,
            decoration:
                const InputDecoration(
              labelText:
                  'Full Name',
            ),
            validator: (value) {
              if ((value ?? '')
                  .trim()
                  .isEmpty) {
                return 'Enter your full name.';
              }

              return null;
            },
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller:
                _emailController,
            keyboardType:
                TextInputType
                    .emailAddress,
            textInputAction:
                TextInputAction.next,
            decoration:
                const InputDecoration(
              labelText: 'Email',
            ),
            validator: (value) {
              final email =
                  (value ?? '')
                      .trim();

              if (email.isEmpty) {
                return 'Enter your email.';
              }

              if (!email.contains(
                    '@',
                  ) ||
                  !email.contains(
                    '.',
                  )) {
                return 'Enter a valid email.';
              }

              return null;
            },
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller:
                _phoneController,
            keyboardType:
                TextInputType.phone,
            textInputAction:
                TextInputAction.next,
            decoration:
                const InputDecoration(
              labelText:
                  'Contact Number',
              hintText:
                  '09xxxxxxxxx',
            ),
            validator: (value) {
              if ((value ?? '')
                  .trim()
                  .isEmpty) {
                return 'Enter your contact number.';
              }

              return null;
            },
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller:
                _addressController,
            minLines: 3,
            maxLines: 4,
            decoration:
                const InputDecoration(
              labelText:
                  'Complete Delivery Address',
              hintText:
                  'House/Unit, Street, Barangay, City/Municipality, Province',
            ),
            validator: (value) {
              if ((value ?? '')
                  .trim()
                  .isEmpty) {
                return 'Enter your complete delivery address.';
              }

              return null;
            },
          ),
          const SizedBox(height: 7),
          const Align(
            alignment:
                Alignment.centerLeft,
            child: Text(
              'Include house/unit, street, barangay, city or municipality, and province.',
              style: TextStyle(
                color: muted,
                fontSize: 8,
                height: 1.4,
              ),
            ),
          ),
          if (hasAddressOptions) ...[
            const SizedBox(height: 14),
            DropdownButtonFormField<
                String>(
              value:
                  _addressChoice,
              decoration:
                  const InputDecoration(
                labelText:
                    'Saved address',
              ),
              items: [
                if (registered
                    .isNotEmpty)
                  const DropdownMenuItem<
                      String>(
                    value:
                        'registered',
                    child: Text(
                      'Registered address',
                    ),
                  ),
                ..._addresses.map(
                  (address) =>
                      DropdownMenuItem<
                          String>(
                    value:
                        'saved:${address['id']}',
                    child: Text(
                      '${_text(address['label'], 'Address')}${address['is_default'] == true ? ' · Default' : ''}',
                    ),
                  ),
                ),
              ],
              onChanged:
                  _applyAddressChoice,
            ),
          ],
        ],
      ),
    );
  }

  Widget _paymentSection() {
    return _sectionCard(
      icon:
          Icons.payments_outlined,
      title:
          'Payment method',
      child: Container(
        padding:
            const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: const Color(
            0xFFFFFAF2,
          ),
          borderRadius:
              BorderRadius.circular(
            12,
          ),
          border: Border.all(
            color: const Color(
              0xFFEADFC9,
            ),
          ),
        ),
        child: const Row(
          children: [
            CircleAvatar(
              backgroundColor:
                  Color(
                0xFFFFE9BE,
              ),
              child: Icon(
                Icons
                    .payments_outlined,
                color: goldDark,
              ),
            ),
            SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Text(
                    'Cash on Delivery',
                    style: TextStyle(
                      color: dark,
                      fontSize: 11,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Pay the courier when your package arrives.',
                    style: TextStyle(
                      color: muted,
                      fontSize: 8,
                    ),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: 'COD',
              groupValue: 'COD',
              onChanged: null,
              activeColor: gold,
            ),
          ],
        ),
      ),
    );
  }

  Widget _orderItemsSection() {
    return _sectionCard(
      icon:
          Icons.shopping_bag_outlined,
      title:
          'Order items',
      child: Column(
        children:
            _itemsByStore.entries.map(
          (entry) {
            return Container(
              width: double.infinity,
              margin:
                  const EdgeInsets.only(
                bottom: 10,
              ),
              padding:
                  const EdgeInsets.all(
                12,
              ),
              decoration:
                  BoxDecoration(
                color:
                    const Color(
                  0xFFFCFBF8,
                ),
                borderRadius:
                    BorderRadius
                        .circular(
                  12,
                ),
                border:
                    Border.all(
                  color:
                      border,
                ),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons
                            .storefront_outlined,
                        color:
                            goldDark,
                        size: 17,
                      ),
                      const SizedBox(
                        width: 7,
                      ),
                      Expanded(
                        child: Text(
                          entry.key,
                          style:
                              const TextStyle(
                            color:
                                dark,
                            fontSize:
                                11,
                            fontWeight:
                                FontWeight
                                    .w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ...entry.value.map(
                    (item) =>
                        Padding(
                      padding:
                          const EdgeInsets
                              .only(
                        bottom: 9,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child:
                                Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [
                                Text(
                                  _text(
                                    item[
                                        'name'],
                                    'Product',
                                  ),
                                  style:
                                      const TextStyle(
                                    color:
                                        dark,
                                    fontSize:
                                        10,
                                    fontWeight:
                                        FontWeight
                                            .w700,
                                  ),
                                ),
                                const SizedBox(
                                  height: 2,
                                ),
                                Text(
                                  '${_text(item['variant_label'], 'Standard')} · Qty: ${_integer(item['quantity'])}',
                                  style:
                                      const TextStyle(
                                    color:
                                        muted,
                                    fontSize:
                                        8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            _money(
                              _decimal(
                                item[
                                    'line_total'],
                              ),
                            ),
                            style:
                                const TextStyle(
                              color:
                                  goldDark,
                              fontSize:
                                  11,
                              fontWeight:
                                  FontWeight
                                      .w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ).toList(),
      ),
    );
  }

  Widget _summarySection() {
    return Container(
      padding:
          const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(15),
        border: Border.all(
          color: border,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'Order summary',
            style: TextStyle(
              color: dark,
              fontSize: 16,
              fontWeight:
                  FontWeight.w800,
            ),
          ),
          const SizedBox(height: 15),

          const Text(
            'Voucher',
            style: TextStyle(
              color: dark,
              fontSize: 10,
              fontWeight:
                  FontWeight.w700,
            ),
          ),

          const SizedBox(height: 7),

          TextField(
            controller:
                _voucherController,
            textCapitalization:
                TextCapitalization
                    .characters,
            decoration:
                const InputDecoration(
              hintText:
                  'Enter voucher code',
            ),
            onChanged: (value) {
              final upper =
                  value.toUpperCase();

              if (upper != value) {
                _voucherController
                    .value =
                    _voucherController
                        .value
                        .copyWith(
                  text: upper,
                  selection:
                      TextSelection
                          .collapsed(
                    offset:
                        upper.length,
                  ),
                );
              }
            },
          ),

          const SizedBox(height: 6),

          const Text(
            'Voucher eligibility is validated securely when you place the order.',
            style: TextStyle(
              color: muted,
              fontSize: 8,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 18),

          _summaryRow(
            'Merchandise subtotal',
            _subtotal,
          ),

          const SizedBox(height: 10),

          _summaryRow(
            'Shipping fee',
            _originalDeliveryFee,
          ),

          if (_shippingDiscount >
              0) ...[
            const SizedBox(height: 10),
            _summaryRow(
              'Shipping discount',
              -_shippingDiscount,
              discount: true,
            ),
          ],

          const SizedBox(height: 10),

          _summaryRow(
            'Shipping payable',
            _deliveryFee,
          ),

          const SizedBox(height: 14),

          const Divider(
            color: border,
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              const Expanded(
                child: Text(
                  'Total',
                  style:
                      TextStyle(
                    color:
                        dark,
                    fontSize:
                        11,
                    fontWeight:
                        FontWeight
                            .w700,
                  ),
                ),
              ),
              Text(
                _money(
                  _grandTotal,
                ),
                style:
                    const TextStyle(
                  color:
                      goldDark,
                  fontSize:
                      22,
                  fontWeight:
                      FontWeight
                          .w900,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child:
                ElevatedButton(
              onPressed:
                  _placingOrder
                      ? null
                      : _placeOrder,
              style:
                  ElevatedButton
                      .styleFrom(
                backgroundColor:
                    gold,
                foregroundColor:
                    Colors.white,
                padding:
                    const EdgeInsets
                        .symmetric(
                  vertical:
                      15,
                ),
              ),
              child:
                  _placingOrder
                      ? const SizedBox(
                          width:
                              18,
                          height:
                              18,
                          child:
                              CircularProgressIndicator(
                            strokeWidth:
                                2,
                            color:
                                Colors.white,
                          ),
                        )
                      : const Text(
                          'Place Order',
                        ),
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            'By placing the order, stock, vouchers, shipping discounts and totals are revalidated securely on the server.',
            style: TextStyle(
              color: muted,
              fontSize: 8,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required IconData icon,
    required String title,
    String? subtitle,
    required Widget child,
  }) {
    return Container(
      padding:
          const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(15),
        border: Border.all(
          color: border,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: goldDark,
                size: 20,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      title,
                      style:
                          const TextStyle(
                        color:
                            dark,
                        fontSize:
                            15,
                        fontWeight:
                            FontWeight
                                .w800,
                      ),
                    ),
                    if (subtitle !=
                        null) ...[
                      const SizedBox(
                        height: 3,
                      ),
                      Text(
                        subtitle,
                        style:
                            const TextStyle(
                          color:
                              muted,
                          fontSize:
                              9,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          child,
        ],
      ),
    );
  }

  Widget _summaryRow(
    String label,
    double amount, {
    bool discount = false,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: discount
                  ? const Color(
                      0xFF4F8065,
                    )
                  : muted,
              fontSize: 9,
            ),
          ),
        ),
        Text(
          amount < 0
              ? '-${_money(amount.abs())}'
              : _money(amount),
          style: TextStyle(
            color: discount
                ? const Color(
                    0xFF4F8065,
                  )
                : dark,
            fontSize: 9,
            fontWeight:
                FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _errorState() {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(24),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: muted,
              size: 48,
            ),
            const SizedBox(height: 12),
            const Text(
              'Unable to prepare checkout',
              style: TextStyle(
                color: dark,
                fontSize: 16,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ??
                  'Please try again.',
              textAlign:
                  TextAlign.center,
              style: const TextStyle(
                color: muted,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 15),
            OutlinedButton.icon(
              onPressed:
                  _loadCheckout,
              icon: const Icon(
                Icons.refresh_rounded,
              ),
              label: const Text(
                'Try Again',
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: canvas,
      appBar: AppBar(
        backgroundColor:
            Colors.white,
        foregroundColor: dark,
        surfaceTintColor:
            Colors.white,
        title: const Text(
          'Checkout',
          style: TextStyle(
            fontSize: 16,
            fontWeight:
                FontWeight.w800,
          ),
        ),
        actions: const [
          Padding(
            padding:
                EdgeInsets.only(
              right: 14,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lock_outline,
                  color: goldDark,
                  size: 16,
                ),
                SizedBox(width: 5),
                Text(
                  'Secure checkout',
                  style: TextStyle(
                    color: goldDark,
                    fontSize: 9,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child:
                  CircularProgressIndicator(
                color: gold,
              ),
            )
          : _error != null
              ? _errorState()
              : Form(
                  key: _formKey,
                  child:
                      SingleChildScrollView(
                    padding:
                        const EdgeInsets
                            .fromLTRB(
                      14,
                      16,
                      14,
                      30,
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .stretch,
                      children: [
                        _shippingAddressSection(),
                        const SizedBox(
                          height: 12,
                        ),
                        _paymentSection(),
                        const SizedBox(
                          height: 12,
                        ),
                        _orderItemsSection(),
                        const SizedBox(
                          height: 12,
                        ),
                        _summarySection(),
                      ],
                    ),
                  ),
                ),
    );
  }
}