import 'package:flutter/material.dart';

import '../services/sari_live_data.dart';
import 'buyer_theme.dart';
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
  final GlobalKey<FormState> _formKey =
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

  Map<String, dynamic> _profile =
      <String, dynamic>{};

  List<Map<String, dynamic>> _addresses =
      <Map<String, dynamic>>[];

  List<Map<String, dynamic>>
      _previewItems =
      <Map<String, dynamic>>[];

  String? _addressChoice;

  bool _loading = true;
  bool _placingOrder = false;

  String? _error;

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
    return value is Map
        ? Map<String, dynamic>.from(
            value,
          )
        : <String, dynamic>{};
  }

  String _text(
    dynamic value, [
    String fallback = '',
  ]) {
    final String text =
        value?.toString().trim() ?? '';

    return text.isEmpty
        ? fallback
        : text;
  }

  int _integer(dynamic value) {
    return value is num
        ? value.toInt()
        : int.tryParse('$value') ?? 0;
  }

  double _decimal(dynamic value) {
    return value is num
        ? value.toDouble()
        : double.tryParse('$value') ?? 0;
  }

  String _money(double value) {
    return '₱${value.toStringAsFixed(2)}';
  }

  String _registeredAddress() {
    return <String>[
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
          (String value) =>
              value.isNotEmpty,
        )
        .join(', ');
  }

  Future<void> _loadCheckout()
      async {
    if (widget.items.isEmpty) {
      setState(() {
        _loading = false;
        _error =
            'No products selected.';
      });

      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final List<int> itemIds =
          widget.items
              .map(
                (BuyerCartItem item) =>
                    item.id,
              )
              .toList();

      final List<Map<String, dynamic>>
          results =
          await Future.wait<
              Map<String, dynamic>>(
        <Future<
            Map<String, dynamic>>>[
          SariLiveData.instance
              .buyerCheckoutPreview(
            itemIds,
          ),
          SariLiveData.instance
              .buyerProfile(),
        ],
      );

      final Map<String, dynamic> preview =
          _map(
        results[0]['data'],
      );

      final Map<String, dynamic>
          profileData =
          _map(
        results[1]['data'],
      );

      final Map<String, dynamic> profile =
          _map(
        profileData['profile'],
      );

      final List<Map<String, dynamic>>
          addresses =
          preview['addresses'] is List
              ? (preview['addresses']
                      as List)
                  .map(_map)
                  .where(
                    (
                      Map<String, dynamic>
                          item,
                    ) =>
                        _integer(
                          item['id'],
                        ) >
                        0,
                  )
                  .toList()
              : <Map<String, dynamic>>[];

      final List<Map<String, dynamic>>
          previewItems =
          preview['items'] is List
              ? (preview['items']
                      as List)
                  .map(_map)
                  .toList()
              : <Map<String, dynamic>>[];

      final Map<String, dynamic> shipping =
          _map(
        preview['shipping'],
      );

      if (!mounted) {
        return;
      }

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
          shipping['delivery_fee'],
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

        final String registered =
            _registeredAddress();

        if (registered.isNotEmpty) {
          _addressChoice =
              'registered';

          _addressController.text =
              registered;
        } else if (_addresses
            .isNotEmpty) {
          final Map<String, dynamic>
              address =
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
      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  void _applySavedAddress(
    Map<String, dynamic> address,
  ) {
    _nameController.text =
        _text(
      address['recipient_name'],
      _nameController.text,
    );

    _phoneController.text =
        _text(
      address['contact_no'],
      _phoneController.text,
    );

    _addressController.text =
        _text(
      address['full_address'],
    );
  }

  void _changeAddress(
    String? value,
  ) {
    if (value == null) {
      return;
    }

    setState(() {
      _addressChoice = value;
    });

    if (value == 'registered') {
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

    if (!value.startsWith(
      'saved:',
    )) {
      return;
    }

    final int? id =
        int.tryParse(
      value.substring(
        'saved:'.length,
      ),
    );

    if (id == null) {
      return;
    }

    for (final Map<String, dynamic>
        address in _addresses) {
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

  Map<String,
          List<Map<String, dynamic>>>
      get _itemsByStore {
    final Map<String,
            List<Map<String, dynamic>>>
        groups =
        <String,
            List<Map<String, dynamic>>>{};

    for (final Map<String, dynamic>
        item in _previewItems) {
      final String store =
          _text(
        item['store_name'],
        'SARI Seller',
      );

      groups
          .putIfAbsent(
            store,
            () => <Map<String,
                dynamic>>[],
          )
          .add(item);
    }

    return groups;
  }

  Future<void> _placeOrder()
      async {
    FocusScope.of(context)
        .unfocus();

    if (_placingOrder ||
        !(_formKey.currentState
                ?.validate() ??
            false)) {
      return;
    }

    setState(() {
      _placingOrder = true;
    });

    try {
      final Map<String, dynamic> response =
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
        itemIds:
            widget.items
                .map(
                  (BuyerCartItem item) =>
                      item.id,
                )
                .toList(),
        voucherCode:
            _voucherController.text
                .trim(),
      );

      final Map<String, dynamic> data =
          _map(response['data']);

      final List<Map<String, dynamic>>
          orders =
          data['orders'] is List
              ? (data['orders'] as List)
                  .map(_map)
                  .toList()
              : <Map<String, dynamic>>[];

      if (!mounted) {
        return;
      }

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (
          BuildContext dialogContext,
        ) {
          return AlertDialog(
            icon:
                const Icon(
              Icons
                  .check_circle_rounded,
              color:
                  BuyerTheme.success,
              size: 45,
            ),
            title:
                const Text(
              'Order placed!',
              style: TextStyle(
                fontWeight:
                    FontWeight.w900,
              ),
            ),
            content:
                SingleChildScrollView(
              child: Column(
                mainAxisSize:
                    MainAxisSize.min,
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: <Widget>[
                  Text(
                    _text(
                      response['message'],
                      'Your SARI order has been placed successfully.',
                    ),
                  ),

                  if (orders
                      .isNotEmpty) ...[
                    const SizedBox(
                      height: 16,
                    ),

                    ...orders.map(
                      (
                        Map<String,
                                dynamic>
                            order,
                      ) {
                        return Container(
                          width:
                              double.infinity,
                          margin:
                              const EdgeInsets.only(
                            bottom: 8,
                          ),
                          padding:
                              const EdgeInsets.all(
                            12,
                          ),
                          decoration:
                              BoxDecoration(
                            color:
                                BuyerTheme
                                    .canvas,
                            borderRadius:
                                BorderRadius
                                    .circular(
                              13,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: <Widget>[
                              Text(
                                _text(
                                  order[
                                      'order_number'],
                                  'SARI Order',
                                ),
                                style:
                                    const TextStyle(
                                  fontWeight:
                                      FontWeight
                                          .w800,
                                ),
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              Text(
                                'Total: ${_money(_decimal(order['total']))}',
                                style:
                                    const TextStyle(
                                  fontFamilyFallback:
                                      <String>[
                                    'Roboto',
                                    'Arial',
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
            actions: <Widget>[
              FilledButton(
                onPressed: () {
                  Navigator.pop(
                    dialogContext,
                  );
                },
                child:
                    const Text(
                  'Continue',
                ),
              ),
            ],
          );
        },
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(
        true,
      );
    } catch (error) {
      _show(error.toString());
    } finally {
      if (mounted) {
        setState(() {
          _placingOrder = false;
        });
      }
    }
  }

  void _show(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior:
              SnackBarBehavior.floating,
        ),
      );
  }

  Widget _section({
    required IconData icon,
    required String title,
    String? subtitle,
    required Widget child,
  }) {
    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 14,
      ),
      padding:
          const EdgeInsets.all(17),
      decoration:
          BuyerTheme.card(),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 39,
                height: 39,
                alignment:
                    Alignment.center,
                decoration:
                    BoxDecoration(
                  color: BuyerTheme
                      .goldPale,
                  borderRadius:
                      BorderRadius
                          .circular(
                    12,
                  ),
                ),
                child: Icon(
                  icon,
                  color: BuyerTheme
                      .goldDark,
                  size: 20,
                ),
              ),

              const SizedBox(
                width: 11,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: <Widget>[
                    Text(
                      title,
                      style:
                          const TextStyle(
                        color:
                            BuyerTheme.ink,
                        fontSize: 14,
                        fontWeight:
                            FontWeight
                                .w900,
                      ),
                    ),
                    if (subtitle !=
                        null) ...[
                      const SizedBox(
                        height: 2,
                      ),
                      Text(
                        subtitle,
                        style:
                            const TextStyle(
                          color:
                              BuyerTheme
                                  .muted,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 17,
          ),

          child,
        ],
      ),
    );
  }

  Widget _addressSection() {
    final String registered =
        _registeredAddress();

    final bool hasChoices =
        registered.isNotEmpty ||
            _addresses.isNotEmpty;

    return _section(
      icon:
          Icons.location_on_outlined,
      title: 'Delivery Details',
      subtitle:
          'Confirm who will receive the parcel.',
      child: Column(
        children: <Widget>[
          if (hasChoices) ...[
            DropdownButtonFormField<
                String>(
              value:
                  _addressChoice,
              decoration:
                  const InputDecoration(
                labelText:
                    'Saved Address',
              ),
              items: <DropdownMenuItem<
                  String>>[
                if (registered
                    .isNotEmpty)
                  const DropdownMenuItem<
                      String>(
                    value:
                        'registered',
                    child: Text(
                      'Registered Address',
                    ),
                  ),
                ..._addresses.map(
                  (
                    Map<String,
                            dynamic>
                        address,
                  ) {
                    return DropdownMenuItem<
                        String>(
                      value:
                          'saved:${address['id']}',
                      child: Text(
                        _text(
                          address['label'],
                          'Saved Address',
                        ),
                      ),
                    );
                  },
                ),
              ],
              onChanged:
                  _changeAddress,
            ),

            const SizedBox(
              height: 12,
            ),
          ],

          TextFormField(
            controller:
                _nameController,
            textInputAction:
                TextInputAction.next,
            decoration:
                const InputDecoration(
              labelText:
                  'Recipient Name',
              prefixIcon:
                  Icon(
                Icons.person_outline,
              ),
            ),
            validator:
                _required,
          ),

          const SizedBox(
            height: 11,
          ),

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
              labelText:
                  'Email Address',
              prefixIcon:
                  Icon(
                Icons.mail_outline,
              ),
            ),
            validator: (String? value) {
              final String email =
                  (value ?? '')
                      .trim();

              if (email.isEmpty) {
                return 'Required.';
              }

              if (!email.contains('@') ||
                  !email.contains('.')) {
                return 'Enter a valid email.';
              }

              return null;
            },
          ),

          const SizedBox(
            height: 11,
          ),

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
              prefixIcon:
                  Icon(
                Icons.phone_outlined,
              ),
            ),
            validator:
                _required,
          ),

          const SizedBox(
            height: 11,
          ),

          TextFormField(
            controller:
                _addressController,
            minLines: 3,
            maxLines: 5,
            decoration:
                const InputDecoration(
              labelText:
                  'Complete Delivery Address',
              prefixIcon:
                  Icon(
                Icons.home_outlined,
              ),
              alignLabelWithHint:
                  true,
            ),
            validator:
                _required,
          ),
        ],
      ),
    );
  }

  Widget _payment() {
    return _section(
      icon: Icons.payments_outlined,
      title: 'Payment Method',
      child: Container(
        padding:
            const EdgeInsets.all(
          14,
        ),
        decoration: BoxDecoration(
          color:
              BuyerTheme.goldPale,
          borderRadius:
              BorderRadius.circular(
            15,
          ),
        ),
        child: const Row(
          children: <Widget>[
            CircleAvatar(
              backgroundColor:
                  Color(0xFFFFE4AC),
              child: Icon(
                Icons.payments_outlined,
                color:
                    BuyerTheme
                        .goldDark,
              ),
            ),
            SizedBox(
              width: 12,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: <Widget>[
                  Text(
                    'Cash on Delivery',
                    style: TextStyle(
                      color:
                          BuyerTheme.ink,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                  SizedBox(
                    height: 3,
                  ),
                  Text(
                    'Pay the Rider when your parcel arrives.',
                    style: TextStyle(
                      color:
                          BuyerTheme.muted,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons
                  .check_circle_rounded,
              color:
                  BuyerTheme.success,
            ),
          ],
        ),
      ),
    );
  }

  Widget _itemsSection() {
    return _section(
      icon:
          Icons.shopping_bag_outlined,
      title: 'Order Items',
      child: Column(
        children:
            _itemsByStore.entries
                .map(
          (
            MapEntry<
                    String,
                    List<
                        Map<String,
                            dynamic>>>
                group,
          ) {
            return Container(
              width:
                  double.infinity,
              margin:
                  const EdgeInsets.only(
                bottom: 10,
              ),
              padding:
                  const EdgeInsets.all(
                13,
              ),
              decoration: BoxDecoration(
                color:
                    BuyerTheme.canvas,
                borderRadius:
                    BorderRadius.circular(
                  14,
                ),
                border: Border.all(
                  color:
                      BuyerTheme.border,
                ),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      const Icon(
                        Icons
                            .storefront_outlined,
                        color:
                            BuyerTheme
                                .goldDark,
                        size: 17,
                      ),
                      const SizedBox(
                        width: 6,
                      ),
                      Expanded(
                        child: Text(
                          group.key,
                          style:
                              const TextStyle(
                            color:
                                BuyerTheme.ink,
                            fontSize: 11,
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

                  ...group.value.map(
                    (
                      Map<String, dynamic>
                          item,
                    ) {
                      final int quantity =
                          _integer(
                        item['quantity'],
                      );

                      final double price =
                          _decimal(
                        item['unit_price'] ??
                            item['price'],
                      );

                      final double total =
                          _decimal(
                        item['line_total'],
                      );

                      return Padding(
                        padding:
                            const EdgeInsets.only(
                          bottom: 10,
                        ),
                        child: Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    _text(
                                      item['name'],
                                      'Product',
                                    ),
                                    style:
                                        const TextStyle(
                                      color:
                                          BuyerTheme.ink,
                                      fontSize:
                                          10,
                                      fontWeight:
                                          FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 3,
                                  ),
                                  Text(
                                    '$quantity × ${_money(price)}',
                                    style:
                                        const TextStyle(
                                      color:
                                          BuyerTheme.muted,
                                      fontSize:
                                          9,
                                      fontFamilyFallback:
                                          <String>[
                                        'Roboto',
                                        'Arial',
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              _money(
                                total > 0
                                    ? total
                                    : price *
                                        quantity,
                              ),
                              style:
                                  const TextStyle(
                                color:
                                    BuyerTheme.goldDark,
                                fontSize: 11,
                                fontWeight:
                                    FontWeight.w800,
                                fontFamilyFallback:
                                    <String>[
                                  'Roboto',
                                  'Arial',
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ).toList(),
      ),
    );
  }

  Widget _voucher() {
    return _section(
      icon:
          Icons.sell_outlined,
      title: 'Voucher',
      subtitle:
          'Optional',
      child: TextFormField(
        controller:
            _voucherController,
        textCapitalization:
            TextCapitalization.characters,
        decoration:
            const InputDecoration(
          labelText:
              'Voucher Code',
          hintText:
              'Enter code if you have one',
          prefixIcon:
              Icon(
            Icons.confirmation_num_outlined,
          ),
        ),
      ),
    );
  }

  Widget _summary() {
    return _section(
      icon:
          Icons.receipt_long_outlined,
      title: 'Payment Summary',
      child: Column(
        children: <Widget>[
          _row(
            'Subtotal',
            _money(_subtotal),
          ),

          const SizedBox(
            height: 9,
          ),

          _row(
            'Original delivery fee',
            _money(
              _originalDeliveryFee,
            ),
          ),

          if (_shippingDiscount > 0) ...[
            const SizedBox(
              height: 9,
            ),
            _row(
              'Shipping discount',
              '-${_money(_shippingDiscount)}',
              positive: true,
            ),
          ],

          const SizedBox(
            height: 9,
          ),

          _row(
            'Delivery fee',
            _money(_deliveryFee),
          ),

          const Padding(
            padding:
                EdgeInsets.symmetric(
              vertical: 13,
            ),
            child:
                Divider(height: 1),
          ),

          _row(
            'Grand Total',
            _money(_grandTotal),
            strong: true,
          ),
        ],
      ),
    );
  }

  Widget _row(
    String label,
    String value, {
    bool strong = false,
    bool positive = false,
  }) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: strong
                  ? BuyerTheme.ink
                  : BuyerTheme.muted,
              fontSize:
                  strong ? 13 : 10,
              fontWeight: strong
                  ? FontWeight.w800
                  : FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: positive
                ? BuyerTheme.success
                : strong
                    ? BuyerTheme
                        .goldDark
                    : BuyerTheme.ink,
            fontSize:
                strong ? 18 : 11,
            fontWeight: strong
                ? FontWeight.w900
                : FontWeight.w700,
            fontFamilyFallback:
                const <String>[
              'Roboto',
              'Arial',
              'sans-serif',
            ],
          ),
        ),
      ],
    );
  }

  String? _required(
    String? value,
  ) {
    if ((value ?? '')
        .trim()
        .isEmpty) {
      return 'Required.';
    }

    return null;
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          BuyerTheme.canvas,
      appBar: AppBar(
        title:
            const Text(
          'Checkout',
          style: TextStyle(
            fontWeight:
                FontWeight.w900,
          ),
        ),
      ),
      body: _loading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : _error != null
              ? Center(
                  child: Padding(
                    padding:
                        const EdgeInsets.all(
                      26,
                    ),
                    child: Column(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: <Widget>[
                        const Icon(
                          Icons
                              .cloud_off_outlined,
                          color:
                              BuyerTheme
                                  .muted,
                          size: 48,
                        ),
                        const SizedBox(
                          height: 13,
                        ),
                        Text(
                          _error!,
                          textAlign:
                              TextAlign.center,
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        OutlinedButton.icon(
                          onPressed:
                              _loadCheckout,
                          icon:
                              const Icon(
                            Icons
                                .refresh_rounded,
                          ),
                          label:
                              const Text(
                            'Retry',
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Form(
                  key: _formKey,
                  child:
                      ListView(
                    padding:
                        const EdgeInsets
                            .fromLTRB(
                      14,
                      14,
                      14,
                      30,
                    ),
                    children: <Widget>[
                      Container(
                        padding:
                            const EdgeInsets.all(
                          19,
                        ),
                        margin:
                            const EdgeInsets.only(
                          bottom: 14,
                        ),
                        decoration:
                            BoxDecoration(
                          gradient:
                              const LinearGradient(
                            colors:
                                BuyerTheme
                                    .heroGradient,
                          ),
                          borderRadius:
                              BorderRadius
                                  .circular(
                            23,
                          ),
                        ),
                        child:
                            const Row(
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'ALMOST THERE',
                                    style:
                                        TextStyle(
                                      color:
                                          Color(0xFFFFD98A),
                                      fontSize:
                                          9,
                                      letterSpacing:
                                          1.2,
                                      fontWeight:
                                          FontWeight.w900,
                                    ),
                                  ),
                                  SizedBox(
                                    height:
                                        6,
                                  ),
                                  Text(
                                    'Review and\nplace your order.',
                                    style:
                                        TextStyle(
                                      color:
                                          Colors.white,
                                      fontSize:
                                          22,
                                      height:
                                          1.06,
                                      fontWeight:
                                          FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons
                                  .shopping_bag_rounded,
                              color:
                                  Colors.white,
                              size: 43,
                            ),
                          ],
                        ),
                      ),

                      _addressSection(),
                      _payment(),
                      _itemsSection(),
                      _voucher(),
                      _summary(),

                      SizedBox(
                        height: 54,
                        child:
                            FilledButton.icon(
                          onPressed:
                              _placingOrder
                                  ? null
                                  : _placeOrder,
                          icon: _placingOrder
                              ? const SizedBox(
                                  width:
                                      20,
                                  height:
                                      20,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth:
                                        2,
                                    color:
                                        Colors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons
                                      .lock_outline_rounded,
                                ),
                          label: Text(
                            _placingOrder
                                ? 'Placing Order...'
                                : 'Place Order • ${_money(_grandTotal)}',
                            style:
                                const TextStyle(
                              fontFamilyFallback:
                                  <String>[
                                'Roboto',
                                'Arial',
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}