import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../config/api_config.dart';
import '../services/sari_live_data.dart';
import 'buyer_theme.dart';
import 'widgets/buyer_address_picker.dart';
import 'widgets/buyer_header.dart';

class BuyerAccount extends StatefulWidget {
  final ValueChanged<int>? onTabChanged;

  const BuyerAccount({
    super.key,
    this.onTabChanged,
  });

  @override
  State<BuyerAccount> createState() =>
      _BuyerAccountState();
}

class _BuyerAccountState
    extends State<BuyerAccount> {
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  final TextEditingController _firstName =
      TextEditingController();

  final TextEditingController _middleInitial =
      TextEditingController();

  final TextEditingController _lastName =
      TextEditingController();

  final TextEditingController _birthday =
      TextEditingController();

  final TextEditingController _contact =
      TextEditingController();

  final TextEditingController _street =
      TextEditingController();

  Map<String, dynamic> _profile =
      <String, dynamic>{};

  final List<Map<String, dynamic>> _addresses =
      <Map<String, dynamic>>[];

  String _sex = '';

  String? _newPhoto;

  bool _loading = true;
  bool _saving = false;

  String? _error;

  @override
  void initState() {
    super.initState();

    _load();
  }

  @override
  void dispose() {
    _firstName.dispose();
    _middleInitial.dispose();
    _lastName.dispose();
    _birthday.dispose();
    _contact.dispose();
    _street.dispose();

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
    final String result =
        value?.toString().trim() ??
            '';

    return result.isEmpty
        ? fallback
        : result;
  }

  int _integer(
    dynamic value,
  ) {
    return value is num
        ? value.toInt()
        : int.tryParse('$value') ??
            0;
  }

  String _absoluteUrl(
    dynamic raw,
  ) {
    final String value =
        _text(raw);

    if (value.isEmpty) {
      return '';
    }

    if (value.startsWith(
          'http://',
        ) ||
        value.startsWith(
          'https://',
        )) {
      return value;
    }

    final String base =
        ApiConfig.baseUrl.replaceFirst(
      RegExp(r'/+$'),
      '',
    );

    return value.startsWith('/')
        ? '$base$value'
        : '$base/$value';
  }

  int? get _age {
    final DateTime? value =
        DateTime.tryParse(
      _birthday.text,
    );

    if (value == null) {
      return null;
    }

    final DateTime now =
        DateTime.now();

    int age =
        now.year - value.year;

    if (now.month < value.month ||
        (now.month == value.month &&
            now.day < value.day)) {
      age--;
    }

    return age;
  }

  String get _fullName {
    return <String>[
      _firstName.text.trim(),
      if (_middleInitial.text
          .trim()
          .isNotEmpty)
        _middleInitial.text
            .trim()
            .toUpperCase(),
      _lastName.text.trim(),
    ].join(' ');
  }

  String get _area {
    return <String>[
      _text(
        _profile['barangay_name'],
      ),
      _text(
        _profile[
            'municipality_name'],
      ),
      _text(
        _profile['province_name'],
      ),
    ]
        .where(
          (
            String value,
          ) =>
              value.isNotEmpty,
        )
        .join(', ');
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final Map<String, dynamic>
          response =
          await SariLiveData
              .instance
              .buyerProfile();

      final Map<String, dynamic> data =
          _map(
        response['data'],
      );

      final Map<String, dynamic> profile =
          _map(
        data['profile'],
      );

      final List<Map<String, dynamic>>
          addresses =
          data['addresses'] is List
              ? (data['addresses']
                      as List)
                  .map(_map)
                  .toList()
              : <Map<String, dynamic>>[];

      _firstName.text =
          _text(
        profile['first_name'],
      );

      _middleInitial.text =
          _text(
        profile['middle_initial'],
      );

      _lastName.text =
          _text(
        profile['last_name'],
      );

      _birthday.text =
          _text(
        profile['birthday'],
      );

      _contact.text =
          _text(
        profile['contact_no'],
      );

      _street.text =
          _text(
        profile['street_address'],
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _profile =
            profile;

        _addresses
          ..clear()
          ..addAll(
            addresses,
          );

        _sex =
            _text(
          profile['sex'],
        );

        _newPhoto = null;

        _loading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;
        _error =
            error.toString();
      });
    }
  }

  Future<void> _pickPhoto() async {
    final FilePickerResult? result =
        await FilePicker.pickFiles(
      type:
          FileType.custom,
      allowedExtensions:
          const <String>[
        'jpg',
        'jpeg',
        'png',
        'webp',
      ],
    );

    if (result == null ||
        result.files.isEmpty) {
      return;
    }

    final PlatformFile file =
        result.files.single;

    if (file.path == null) {
      return;
    }

    if (file.size >
        5 * 1024 * 1024) {
      _message(
        'Profile photo must be 5 MB or smaller.',
      );

      return;
    }

    setState(() {
      _newPhoto =
          file.path;
    });
  }

  Future<void> _pickBirthday() async {
    final DateTime now =
        DateTime.now();

    final DateTime maximum =
        DateTime(
      now.year - 18,
      now.month,
      now.day,
    );

    DateTime initial =
        DateTime.tryParse(
              _birthday.text,
            ) ??
            DateTime(
              2000,
              1,
              1,
            );

    if (initial.isAfter(maximum)) {
      initial = maximum;
    }

    final DateTime? selected =
        await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate:
          DateTime(1900),
      lastDate:
          maximum,
    );

    if (selected == null) {
      return;
    }

    setState(() {
      _birthday.text =
          '${selected.year.toString().padLeft(4, '0')}-'
          '${selected.month.toString().padLeft(2, '0')}-'
          '${selected.day.toString().padLeft(2, '0')}';
    });
  }

  Future<void> _save() async {
    FocusScope.of(context)
        .unfocus();

    if (!(_formKey.currentState
            ?.validate() ??
        false)) {
      return;
    }

    if ((_age ?? 0) < 18) {
      _message(
        'Buyer must be at least 18 years old.',
      );

      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      final Map<String, String> fields =
          <String, String>{
        'first_name':
            _firstName.text.trim(),

        'middle_initial':
            _middleInitial.text
                .trim()
                .toUpperCase(),

        'last_name':
            _lastName.text.trim(),

        if (_sex.isNotEmpty)
          'sex':
              _sex,

        'birthday':
            _birthday.text.trim(),

        'contact_no':
            _contact.text.trim(),

        'street_address':
            _street.text.trim(),
      };

      final Map<String, dynamic>
          response =
          await SariLiveData
              .instance
              .buyerUpdateProfileForm(
        fields: fields,
        profileImage:
            _newPhoto == null
                ? null
                : File(
                    _newPhoto!,
                  ),
      );

      _message(
        _text(
          response['message'],
          'Buyer account updated.',
        ),
      );

      await _load();
    } catch (error) {
      _message(
        error.toString(),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  Future<void> _addAddress() async {
    final GlobalKey<FormState> formKey =
        GlobalKey<FormState>();

    final TextEditingController label =
        TextEditingController(
      text: 'Home',
    );

    final TextEditingController recipient =
        TextEditingController(
      text: _fullName,
    );

    final TextEditingController contact =
        TextEditingController(
      text: _contact.text,
    );

    final TextEditingController street =
        TextEditingController();

    final TextEditingController province =
        TextEditingController();

    final TextEditingController municipality =
        TextEditingController();

    final TextEditingController barangay =
        TextEditingController();

    final TextEditingController postal =
        TextEditingController();

    bool makeDefault =
        _addresses.isEmpty;

    final bool? save =
        await showDialog<bool>(
      context: context,
      builder:
          (
            BuildContext dialogContext,
          ) {
        return StatefulBuilder(
          builder:
              (
                BuildContext context,
                void Function(
                  void Function(),
                ) setDialogState,
              ) {
            return AlertDialog(
              title:
                  const Text(
                'Add Address',
              ),
              content:
                  SizedBox(
                width: 430,
                child:
                    SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: <Widget>[
                        TextFormField(
                          controller:
                              label,
                          decoration:
                              const InputDecoration(
                            labelText:
                                'Label',
                          ),
                          validator:
                              _required,
                        ),

                        const SizedBox(
                          height: 9,
                        ),

                        TextFormField(
                          controller:
                              recipient,
                          decoration:
                              const InputDecoration(
                            labelText:
                                'Recipient',
                          ),
                          validator:
                              _required,
                        ),

                        const SizedBox(
                          height: 9,
                        ),

                        TextFormField(
                          controller:
                              contact,
                          keyboardType:
                              TextInputType.phone,
                          decoration:
                              const InputDecoration(
                            labelText:
                                'Contact Number',
                          ),
                          validator:
                              _phoneValidator,
                        ),

                        const SizedBox(
                          height: 9,
                        ),

                        BuyerAddressPicker(
                          province:
                              province,
                          municipality:
                              municipality,
                          barangay:
                              barangay,
                        ),

                        const SizedBox(
                          height: 9,
                        ),

                        TextFormField(
                          controller:
                              street,
                          minLines: 2,
                          maxLines: 3,
                          decoration:
                              const InputDecoration(
                            labelText:
                                'Street / Unit Address',
                          ),
                          validator:
                              _required,
                        ),

                        const SizedBox(
                          height: 9,
                        ),

                        TextFormField(
                          controller:
                              postal,
                          keyboardType:
                              TextInputType.number,
                          maxLength: 4,
                          decoration:
                              const InputDecoration(
                            labelText:
                                'Postal Code',
                            counterText:
                                '',
                          ),
                        ),

                        CheckboxListTile(
                          contentPadding:
                              EdgeInsets.zero,
                          value:
                              makeDefault,
                          title:
                              const Text(
                            'Set as default address',
                            style:
                                TextStyle(
                              fontSize: 11,
                            ),
                          ),
                          onChanged:
                              (
                                bool? value,
                              ) {
                            setDialogState(
                              () {
                                makeDefault =
                                    value ??
                                        false;
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                      false,
                    );
                  },
                  child:
                      const Text(
                    'Cancel',
                  ),
                ),
                FilledButton(
                  onPressed: () {
                    if (!(formKey
                            .currentState
                            ?.validate() ??
                        false)) {
                      return;
                    }

                    Navigator.pop(
                      dialogContext,
                      true,
                    );
                  },
                  child:
                      const Text(
                    'Add Address',
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (save == true) {
      try {
        await SariLiveData.instance
            .buyerStoreAddress(
          <String, dynamic>{
            'label':
                label.text.trim(),

            'recipient_name':
                recipient.text
                    .trim(),

            'contact_no':
                contact.text.trim(),

            'street_address':
                street.text.trim(),

            'barangay_name':
                barangay.text.trim(),

            'municipality_name':
                municipality.text
                    .trim(),

            'province_name':
                province.text.trim(),

            'postal_code':
                postal.text.trim(),

            'is_default':
                makeDefault,
          },
        );

        await _load();
      } catch (error) {
        _message(
          error.toString(),
        );
      }
    }

    label.dispose();
    recipient.dispose();
    contact.dispose();
    street.dispose();
    province.dispose();
    municipality.dispose();
    barangay.dispose();
    postal.dispose();
  }

  Future<void> _setDefault(
    int id,
  ) async {
    try {
      await SariLiveData.instance
          .buyerSetDefaultAddress(
        id,
      );

      await _load();
    } catch (error) {
      _message(
        error.toString(),
      );
    }
  }

  Future<void> _deleteAddress(
    int id,
  ) async {
    final bool? confirmed =
        await showDialog<bool>(
      context: context,
      builder:
          (
            BuildContext context,
          ) =>
              AlertDialog(
        title:
            const Text(
          'Remove Address?',
        ),
        content:
            const Text(
          'This saved delivery address will be removed.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(
                context,
                false,
              );
            },
            child:
                const Text(
              'Cancel',
            ),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(
                context,
                true,
              );
            },
            child:
                const Text(
              'Remove',
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    try {
      await SariLiveData.instance
          .buyerDeleteAddress(
        id,
      );

      await _load();
    } catch (error) {
      _message(
        error.toString(),
      );
    }
  }

  String? _required(
    String? value,
  ) {
    return (value ?? '')
            .trim()
            .isEmpty
        ? 'Required.'
        : null;
  }

  String? _nameValidator(
    String? value,
  ) {
    final String name =
        (value ?? '').trim();

    if (name.length < 2) {
      return 'Enter at least 2 characters.';
    }

    return null;
  }

  String? _phoneValidator(
    String? value,
  ) {
    final String phone =
        (value ?? '').trim();

    if (!RegExp(
      r'^(?:09\d{9}|\+639\d{9})$',
    ).hasMatch(phone)) {
      return 'Use 09XXXXXXXXX or +639XXXXXXXXX.';
    }

    return null;
  }

  ImageProvider? _profileImage() {
    if (_newPhoto != null) {
      return FileImage(
        File(
          _newPhoto!,
        ),
      );
    }

    final String url =
        _absoluteUrl(
      _profile[
          'profile_image_url'],
    );

    return url.isEmpty
        ? null
        : NetworkImage(url);
  }

  Widget _profileHero() {
    final ImageProvider? image =
        _profileImage();

    return Container(
      margin:
          const EdgeInsets.fromLTRB(
        11,
        8,
        11,
        0,
      ),
      padding:
          const EdgeInsets.all(
        14,
      ),
      decoration:
          BoxDecoration(
        gradient:
            const LinearGradient(
          begin:
              Alignment.topLeft,
          end:
              Alignment.bottomRight,
          colors: <Color>[
            Color(
              0xFF172334,
            ),
            Color(
              0xFF303D4B,
            ),
            Color(
              0xFF7B632B,
            ),
          ],
        ),
        borderRadius:
            BorderRadius.circular(
          18,
        ),
      ),
      child: Row(
        children: <Widget>[
          Stack(
            clipBehavior:
                Clip.none,
            children: <Widget>[
              Container(
                width: 69,
                height: 69,
                decoration:
                    BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(
                    18,
                  ),
                  color:
                      Colors.white12,
                  border:
                      Border.all(
                    color:
                        Colors.white24,
                  ),
                  image: image == null
                      ? null
                      : DecorationImage(
                          image: image,
                          fit:
                              BoxFit.cover,
                        ),
                ),
                child: image == null
                    ? const Icon(
                        Icons
                            .person_rounded,
                        color:
                            Colors.white,
                        size: 34,
                      )
                    : null,
              ),

              Positioned(
                right: -5,
                bottom: -5,
                child: InkWell(
                  onTap:
                      _pickPhoto,
                  borderRadius:
                      BorderRadius.circular(
                    9,
                  ),
                  child: Container(
                    width: 28,
                    height: 28,
                    alignment:
                        Alignment.center,
                    decoration:
                        BoxDecoration(
                      color:
                          BuyerTheme.gold,
                      borderRadius:
                          BorderRadius.circular(
                        9,
                      ),
                      border:
                          Border.all(
                        color:
                            Colors.white,
                        width: 2,
                      ),
                    ),
                    child:
                        const Icon(
                      Icons.edit_rounded,
                      color:
                          Colors.white,
                      size: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            width: 13,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'BUYER ACCOUNT',
                  style:
                      TextStyle(
                    color:
                        Color(
                      0xFFFFD98A,
                    ),
                    fontSize: 7,
                    letterSpacing:
                        1,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),

                const SizedBox(
                  height: 4,
                ),

                Text(
                  _fullName.isEmpty
                      ? 'SARI Buyer'
                      : _fullName,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      const TextStyle(
                    color:
                        Colors.white,
                    fontSize: 16,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),

                const SizedBox(
                  height: 3,
                ),

                Text(
                  _text(
                    _profile['email'],
                  ),
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      const TextStyle(
                    color:
                        Colors.white70,
                    fontSize: 8.5,
                  ),
                ),

                if (_area.isNotEmpty) ...[
                  const SizedBox(
                    height: 4,
                  ),
                  Row(
                    children: <Widget>[
                      const Icon(
                        Icons
                            .location_on_outlined,
                        color:
                            Colors.white54,
                        size: 12,
                      ),
                      const SizedBox(
                        width: 3,
                      ),
                      Expanded(
                        child: Text(
                          _area,
                          maxLines: 1,
                          overflow:
                              TextOverflow
                                  .ellipsis,
                          style:
                              const TextStyle(
                            color:
                                Colors.white60,
                            fontSize: 7.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _personalInformation() {
    return _card(
      title:
          'Personal Information',
      subtitle:
          'Changes are synced directly to your SARI Buyer account.',
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            _field(
              label:
                  'First Name',
              controller:
                  _firstName,
              icon:
                  Icons.person_outline,
              validator:
                  _nameValidator,
            ),

            _field(
              label:
                  'Middle Initial',
              controller:
                  _middleInitial,
            ),

            _field(
              label:
                  'Last Name',
              controller:
                  _lastName,
              icon:
                  Icons.person_outline,
              validator:
                  _nameValidator,
            ),

            Padding(
              padding:
                  const EdgeInsets.only(
                bottom: 9,
              ),
              child:
                  InputDecorator(
                decoration:
                    const InputDecoration(
                  labelText:
                      'Sex',
                  prefixIcon:
                      Icon(
                    Icons.wc_outlined,
                  ),
                ),
                child:
                    DropdownButtonHideUnderline(
                  child:
                      DropdownButton<String>(
                    isExpanded:
                        true,
                    value:
                        _sex.isEmpty
                            ? ''
                            : _sex,
                    items:
                        const <DropdownMenuItem<String>>[
                      DropdownMenuItem(
                        value: '',
                        child:
                            Text(
                          'Not set',
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'Male',
                        child:
                            Text(
                          'Male',
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'Female',
                        child:
                            Text(
                          'Female',
                        ),
                      ),
                    ],
                    onChanged:
                        (
                          String? value,
                        ) {
                      setState(() {
                        _sex =
                            value ??
                                '';
                      });
                    },
                  ),
                ),
              ),
            ),

            Padding(
              padding:
                  const EdgeInsets.only(
                bottom: 9,
              ),
              child:
                  TextFormField(
                controller:
                    _birthday,
                readOnly:
                    true,
                onTap:
                    _pickBirthday,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Birthday',
                  prefixIcon:
                      Icon(
                    Icons
                        .calendar_month_outlined,
                  ),
                ),
                validator:
                    _required,
              ),
            ),

            Row(
              children: <Widget>[
                Expanded(
                  child:
                      _miniInfo(
                    'Age',
                    '${_age ?? '—'}',
                  ),
                ),

                const SizedBox(
                  width: 8,
                ),

                Expanded(
                  child:
                      _miniInfo(
                    'Account',
                    'Buyer',
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 9,
            ),

            _miniInfo(
              'Email',
              _text(
                _profile['email'],
              ),
              fullWidth:
                  true,
            ),

            const SizedBox(
              height: 9,
            ),

            _field(
              label:
                  'Contact Number',
              controller:
                  _contact,
              icon:
                  Icons.phone_outlined,
              keyboardType:
                  TextInputType.phone,
              validator:
                  _phoneValidator,
            ),

            _field(
              label:
                  'Registered Street Address',
              controller:
                  _street,
              icon:
                  Icons.home_outlined,
              validator:
                  _required,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _addressesCard() {
    return _card(
      title:
          'Delivery Addresses',
      subtitle:
          'Manage addresses used during checkout.',
      trailing:
          _addresses.length < 5
              ? TextButton.icon(
                  onPressed:
                      _addAddress,
                  icon:
                      const Icon(
                    Icons.add_rounded,
                    size: 16,
                  ),
                  label:
                      const Text(
                    'Add',
                  ),
                )
              : null,
      child:
          _addresses.isEmpty
              ? const Padding(
                  padding:
                      EdgeInsets.symmetric(
                    vertical: 18,
                  ),
                  child: Center(
                    child: Text(
                      'No saved delivery addresses.',
                      style:
                          TextStyle(
                        color:
                            BuyerTheme.muted,
                        fontSize: 9,
                      ),
                    ),
                  ),
                )
              : Column(
                  children:
                      _addresses.map(
                    _addressTile,
                  ).toList(),
                ),
    );
  }

  Widget _addressTile(
    Map<String, dynamic> address,
  ) {
    final bool active =
        address['is_default'] ==
                true ||
            address['is_default'] ==
                1;

    final String full =
        <String>[
      _text(
        address['street_address'],
      ),
      _text(
        address['barangay_name'],
      ),
      _text(
        address[
            'municipality_name'],
      ),
      _text(
        address['province_name'],
      ),
    ]
            .where(
              (
                String value,
              ) =>
                  value.isNotEmpty,
            )
            .join(', ');

    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 8,
      ),
      padding:
          const EdgeInsets.all(
        11,
      ),
      decoration:
          BoxDecoration(
        color: active
            ? BuyerTheme.goldPale
            : BuyerTheme.canvas,
        borderRadius:
            BorderRadius.circular(
          13,
        ),
        border:
            Border.all(
          color: active
              ? const Color(
                  0xFFE3BE67,
                )
              : BuyerTheme.border,
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(
            Icons
                .location_on_outlined,
            color:
                BuyerTheme.goldDark,
            size: 18,
          ),

          const SizedBox(
            width: 8,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        _text(
                          address['label'],
                          'Address',
                        ),
                        style:
                            const TextStyle(
                          fontSize: 10,
                          fontWeight:
                              FontWeight.w800,
                        ),
                      ),
                    ),

                    if (active)
                      const Text(
                        'DEFAULT',
                        style:
                            TextStyle(
                          color:
                              BuyerTheme.goldDark,
                          fontSize: 6.5,
                          fontWeight:
                              FontWeight.w900,
                        ),
                      ),
                  ],
                ),

                const SizedBox(
                  height: 4,
                ),

                Text(
                  full,
                  style:
                      const TextStyle(
                    color:
                        BuyerTheme.muted,
                    fontSize: 8,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),

          PopupMenuButton<String>(
            onSelected:
                (
                  String value,
                ) {
              if (value ==
                  'default') {
                _setDefault(
                  _integer(
                    address['id'],
                  ),
                );
              } else if (value ==
                  'delete') {
                _deleteAddress(
                  _integer(
                    address['id'],
                  ),
                );
              }
            },
            itemBuilder:
                (
                  BuildContext context,
                ) =>
                    <PopupMenuEntry<String>>[
              if (!active)
                const PopupMenuItem(
                  value:
                      'default',
                  child:
                      Text(
                    'Set as Default',
                  ),
                ),
              const PopupMenuItem(
                value:
                    'delete',
                child:
                    Text(
                  'Remove',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _field({
    required String label,
    required TextEditingController
        controller,
    IconData? icon,
    String? Function(String?)?
        validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 9,
      ),
      child:
          TextFormField(
        controller:
            controller,
        keyboardType:
            keyboardType,
        validator:
            validator,
        maxLines:
            maxLines,
        style:
            const TextStyle(
          fontSize: 10,
        ),
        decoration:
            InputDecoration(
          isDense: true,
          labelText:
              label,
          prefixIcon:
              icon == null
                  ? null
                  : Icon(
                      icon,
                      size: 17,
                    ),
          contentPadding:
              const EdgeInsets.symmetric(
            horizontal: 11,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _miniInfo(
    String label,
    String value, {
    bool fullWidth = false,
  }) {
    return Container(
      width: fullWidth
          ? double.infinity
          : null,
      padding:
          const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 9,
      ),
      decoration:
          BoxDecoration(
        color:
            const Color(
          0xFFF7F8FA,
        ),
        borderRadius:
            BorderRadius.circular(
          11,
        ),
        border:
            Border.all(
          color:
              BuyerTheme.border,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style:
                const TextStyle(
              color:
                  BuyerTheme.muted,
              fontSize: 7,
            ),
          ),
          const SizedBox(
            height: 2,
          ),
          Text(
            value,
            maxLines: 1,
            overflow:
                TextOverflow.ellipsis,
            style:
                const TextStyle(
              color:
                  BuyerTheme.ink,
              fontSize: 9.5,
              fontWeight:
                  FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({
    required String title,
    required String subtitle,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      margin:
          const EdgeInsets.fromLTRB(
        11,
        10,
        11,
        0,
      ),
      padding:
          const EdgeInsets.all(
        13,
      ),
      decoration:
          BuyerTheme.card(
        radius: 16,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style:
                          const TextStyle(
                        color:
                            BuyerTheme.ink,
                        fontSize: 12,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    Text(
                      subtitle,
                      style:
                          const TextStyle(
                        color:
                            BuyerTheme.muted,
                        fontSize: 7.5,
                      ),
                    ),
                  ],
                ),
              ),

              if (trailing != null)
                trailing,
            ],
          ),

          const SizedBox(
            height: 13,
          ),

          child,
        ],
      ),
    );
  }

  Widget _bottomSave() {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        11,
        14,
        11,
        28,
      ),
      child: Column(
        children: <Widget>[
          const Text(
            'Profile changes will sync with your SARI web account.',
            textAlign:
                TextAlign.center,
            style:
                TextStyle(
              color:
                  BuyerTheme.muted,
              fontSize: 7.5,
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          SizedBox(
            width:
                double.infinity,
            height: 45,
            child:
                FilledButton.icon(
              onPressed:
                  _saving
                      ? null
                      : _save,
              icon:
                  _saving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                            color:
                                Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons
                              .save_outlined,
                          size: 17,
                        ),
              label:
                  Text(
                _saving
                    ? 'Saving...'
                    : 'Save Account Changes',
                style:
                    const TextStyle(
                  fontSize: 10,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _message(
    String message,
  ) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content:
              Text(message),
          behavior:
              SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          BuyerTheme.canvas,
      body: Column(
        children: <Widget>[
          BuyerHeader(
            pageTitle:
                'Account',
            cartCount: 0,
            notificationCount: 0,
            onSearchTap: () {
              widget.onTabChanged
                  ?.call(1);
            },
            onCartTap: () {
              widget.onTabChanged
                  ?.call(2);
            },
            onNotificationTap: () {
              widget.onTabChanged
                  ?.call(5);
            },
            onProfileTap: () {},
          ),

          Expanded(
            child: _loading
                ? const Center(
                    child:
                        CircularProgressIndicator(),
                  )
                : _error != null
                    ? RefreshIndicator(
                        onRefresh:
                            _load,
                        child:
                            ListView(
                          physics:
                              const AlwaysScrollableScrollPhysics(),
                          children: <Widget>[
                            const SizedBox(
                              height: 80,
                            ),
                            Text(
                              _error!,
                              textAlign:
                                  TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh:
                            _load,
                        child:
                            ListView(
                          physics:
                              const AlwaysScrollableScrollPhysics(),
                          padding:
                              EdgeInsets.zero,
                          children: <Widget>[
                            _profileHero(),
                            _personalInformation(),
                            _addressesCard(),
                            _bottomSave(),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}