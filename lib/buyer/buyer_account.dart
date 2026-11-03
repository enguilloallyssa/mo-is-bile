import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../config/api_config.dart';
import '../services/sari_live_data.dart';
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
      _profileFormKey =
      GlobalKey<FormState>();

  final TextEditingController
      _firstNameController =
      TextEditingController();

  final TextEditingController
      _middleInitialController =
      TextEditingController();

  final TextEditingController
      _lastNameController =
      TextEditingController();

  final TextEditingController
      _birthdayController =
      TextEditingController();

  final TextEditingController
      _contactController =
      TextEditingController();

  final TextEditingController
      _streetController =
      TextEditingController();

  Map<String, dynamic>
      _profile = {};

  List<Map<String, dynamic>>
      _addresses = [];

  String _sex = '';

  String? _pickedProfileImagePath;

  bool _loading = true;
  bool _savingProfile = false;

  String? _error;

  @override
  void initState() {
    super.initState();

    _load();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleInitialController.dispose();
    _lastNameController.dispose();
    _birthdayController.dispose();
    _contactController.dispose();
    _streetController.dispose();

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

  int _integer(
    dynamic value,
  ) {
    if (value is num) {
      return value.toInt();
    }

    return int.tryParse('$value') ?? 0;
  }

  String _absoluteUrl(
    String value,
  ) {
    final path = value.trim();

    if (path.isEmpty) {
      return '';
    }

    if (path.startsWith(
          'http://',
        ) ||
        path.startsWith(
          'https://',
        )) {
      return path;
    }

    final base = ApiConfig.baseUrl
        .replaceFirst(
          RegExp(r'/+$'),
          '',
        );

    if (path.startsWith('/')) {
      return '$base$path';
    }

    return '$base/$path';
  }

  Map<String, dynamic>?
      get _activeAddress {
    for (final address
        in _addresses) {
      if (address['is_default'] ==
          true) {
        return address;
      }
    }

    return null;
  }

  int? get _age {
    final birthday =
        DateTime.tryParse(
      _birthdayController.text,
    );

    if (birthday == null) {
      return null;
    }

    final now = DateTime.now();

    var age =
        now.year - birthday.year;

    final birthdayPassed =
        now.month > birthday.month ||
            (now.month ==
                    birthday.month &&
                now.day >=
                    birthday.day);

    if (!birthdayPassed) {
      age--;
    }

    return age;
  }

  String get _profileArea {
    return [
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

  Future<void> _load()
      async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response =
          await SariLiveData.instance
              .buyerProfile();

      final data =
          _map(
        response['data'],
      );

      final profile =
          _map(
        data['profile'],
      );

      final addresses =
          data['addresses'] is List
              ? (data['addresses']
                      as List)
                  .map(_map)
                  .toList()
              : <Map<String, dynamic>>[];

      if (!mounted) return;

      _firstNameController.text =
          _text(
        profile['first_name'],
      );

      _middleInitialController.text =
          _text(
        profile['middle_initial'],
      );

      _lastNameController.text =
          _text(
        profile['last_name'],
      );

      _birthdayController.text =
          _text(
        profile['birthday'],
      );

      _contactController.text =
          _text(
        profile['contact_no'],
      );

      _streetController.text =
          _text(
        profile['street_address'],
      );

      setState(() {
        _profile = profile;

        _addresses = addresses;

        _sex =
            _text(
          profile['sex'],
        );

        _pickedProfileImagePath =
            null;

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

  Future<void>
      _pickProfilePhoto() async {
final result =
    await FilePicker.pickFiles(
  type: FileType.custom,
  allowedExtensions: const [
    'jpg',
    'jpeg',
    'png',
    'webp',
  ],
  allowMultiple: false,
);

    if (result == null ||
        result.files.isEmpty) {
      return;
    }

    final path =
        result.files.single.path;

    if (path == null ||
        path.trim().isEmpty) {
      _message(
        'The selected photo cannot be read.',
      );

      return;
    }

    final file =
        File(path);

    final size =
        await file.length();

    if (size >
        5 * 1024 * 1024) {
      _message(
        'Profile photo must be 5 MB or smaller.',
      );

      return;
    }

    if (!mounted) return;

    setState(() {
      _pickedProfileImagePath =
          path;
    });
  }

  Future<void> _selectBirthday()
      async {
    final now = DateTime.now();

    final maximumDate = DateTime(
      now.year - 18,
      now.month,
      now.day,
    );

    DateTime initialDate =
        DateTime.tryParse(
              _birthdayController
                  .text,
            ) ??
            DateTime(
              2000,
              1,
              1,
            );

    if (initialDate
        .isAfter(maximumDate)) {
      initialDate =
          maximumDate;
    }

    final selected =
        await showDatePicker(
      context: context,
      initialDate:
          initialDate,
      firstDate: DateTime(
        1900,
        1,
        1,
      ),
      lastDate:
          maximumDate,
    );

    if (selected == null ||
        !mounted) {
      return;
    }

    setState(() {
      _birthdayController.text =
          '${selected.year.toString().padLeft(4, '0')}-'
          '${selected.month.toString().padLeft(2, '0')}-'
          '${selected.day.toString().padLeft(2, '0')}';
    });
  }

  Future<void> _saveProfile()
      async {
    FocusScope.of(context)
        .unfocus();

    if (!_profileFormKey
        .currentState!
        .validate()) {
      return;
    }

    final birthday =
        DateTime.tryParse(
      _birthdayController.text,
    );

    if (birthday == null) {
      _message(
        'Select a valid birthday.',
      );

      return;
    }

    final age = _age;

    if (age == null ||
        age < 18) {
      _message(
        'Buyer must be at least 18 years old.',
      );

      return;
    }

    setState(() {
      _savingProfile = true;
    });

    try {
      final fields =
          <String, String>{
        'first_name':
            _firstNameController.text
                .trim(),
        'middle_initial':
            _middleInitialController
                .text
                .trim()
                .toUpperCase(),
        'last_name':
            _lastNameController.text
                .trim(),
        if (_sex.isNotEmpty)
          'sex': _sex,
        'birthday':
            _birthdayController.text
                .trim(),
        'contact_no':
            _contactController.text
                .trim(),
        'street_address':
            _streetController.text
                .trim(),
      };

      final image =
          _pickedProfileImagePath ==
                  null
              ? null
              : File(
                  _pickedProfileImagePath!,
                );

      final response =
          await SariLiveData.instance
              .buyerUpdateProfileForm(
        fields: fields,
        profileImage: image,
      );

      _message(
        response['message']
                ?.toString() ??
            'Buyer account updated.',
      );

      await _load();
    } catch (error) {
      _message(
        error.toString(),
      );
    } finally {
      if (mounted) {
        setState(() {
          _savingProfile = false;
        });
      }
    }
  }

  Future<void> _openAddressForm({
    Map<String, dynamic>?
        address,
  }) async {
    final editing =
        address != null;

    final formKey =
        GlobalKey<FormState>();

    final label =
        TextEditingController(
      text: editing
          ? _text(
              address['label'],
            )
          : 'Home',
    );

    final recipient =
        TextEditingController(
      text: editing
          ? _text(
              address['recipient_name'],
            )
          : _text(
              _profile[
                  'full_name'],
            ),
    );

    final contact =
        TextEditingController(
      text: editing
          ? _text(
              address['contact_no'],
            )
          : _text(
              _profile[
                  'contact_no'],
            ),
    );

    final street =
        TextEditingController(
      text: editing
          ? _text(
              address[
                  'street_address'],
            )
          : '',
    );

    final province =
        TextEditingController(
      text: editing
          ? _text(
              address[
                  'province_name'],
            )
          : _text(
              _profile[
                  'province_name'],
            ),
    );

    final municipality =
        TextEditingController(
      text: editing
          ? _text(
              address[
                  'municipality_name'],
            )
          : _text(
              _profile[
                  'municipality_name'],
            ),
    );

    final barangay =
        TextEditingController(
      text: editing
          ? _text(
              address[
                  'barangay_name'],
            )
          : _text(
              _profile[
                  'barangay_name'],
            ),
    );

    final postal =
        TextEditingController(
      text: editing
          ? _text(
              address[
                  'postal_code'],
            )
          : '',
    );

    var makeDefault =
        editing
            ? address[
                    'is_default'] ==
                true
            : _addresses.isEmpty;

    final saved =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder:
              (
            context,
            setDialogState,
          ) {
            return AlertDialog(
              title: Text(
                editing
                    ? 'Edit Address'
                    : 'Add Address',
              ),
              content:
                  SizedBox(
                width: 450,
                child:
                    Form(
                  key: formKey,
                  child:
                      SingleChildScrollView(
                    child:
                        Column(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller:
                              label,
                          maxLength:
                              50,
                          decoration:
                              const InputDecoration(
                            labelText:
                                'Label',
                            hintText:
                                'Home, Office, etc.',
                          ),
                          validator:
                              _requiredValidator,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          controller:
                              recipient,
                          maxLength:
                              150,
                          decoration:
                              const InputDecoration(
                            labelText:
                                'Recipient',
                          ),
                          validator:
                              _requiredValidator,
                        ),
                        const SizedBox(
                          height: 10,
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
                            hintText:
                                '09XXXXXXXXX',
                          ),
                          validator:
                              _phoneValidator,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          controller:
                              street,
                          maxLength:
                              500,
                          minLines:
                              2,
                          maxLines:
                              3,
                          decoration:
                              const InputDecoration(
                            labelText:
                                'Street / Unit Address',
                            hintText:
                                'House, unit, building, subdivision, or street',
                          ),
                          validator:
                              _requiredValidator,
                        ),
                        const SizedBox(
                          height: 10,
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
                          height: 10,
                        ),
                        TextFormField(
                          controller:
                              postal,
                          keyboardType:
                              TextInputType.number,
                          maxLength:
                              4,
                          decoration:
                              const InputDecoration(
                            labelText:
                                'Postal Code',
                            hintText:
                                'Optional',
                          ),
                          validator:
                              (value) {
                            final text =
                                (value ?? '')
                                    .trim();

                            if (text.isEmpty) {
                              return null;
                            }

                            if (!RegExp(
                              r'^\d{4}$',
                            ).hasMatch(
                              text,
                            )) {
                              return 'Postal code must be 4 digits.';
                            }

                            return null;
                          },
                        ),
                        CheckboxListTile(
                          value:
                              makeDefault,
                          contentPadding:
                              EdgeInsets.zero,
                          activeColor:
                              gold,
                          title:
                              const Text(
                            'Set as active address',
                          ),
                          subtitle:
                              const Text(
                            'This address will be treated as your default saved delivery address.',
                            style:
                                TextStyle(
                              fontSize:
                                  9,
                            ),
                          ),
                          onChanged:
                              (value) {
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
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.of(
                        dialogContext,
                      ).pop(
                        false,
                      ),
                  child:
                      const Text(
                    'Cancel',
                  ),
                ),
                FilledButton(
                  onPressed: () {
                    if (!formKey
                        .currentState!
                        .validate()) {
                      return;
                    }

                    Navigator.of(
                      dialogContext,
                    ).pop(
                      true,
                    );
                  },
                  child: Text(
                    editing
                        ? 'Save Address'
                        : 'Add Address',
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (saved != true) {
      label.dispose();
      recipient.dispose();
      contact.dispose();
      street.dispose();
      province.dispose();
      municipality.dispose();
      barangay.dispose();
      postal.dispose();

      return;
    }

    try {
      final body =
          <String, dynamic>{
        'label':
            label.text.trim(),
        'recipient_name':
            recipient.text.trim(),
        'contact_no':
            contact.text.trim(),
        'street_address':
            street.text.trim(),
        'barangay_name':
            barangay.text.trim(),
        'municipality_name':
            municipality.text.trim(),
        'province_name':
            province.text.trim(),
        'postal_code':
            postal.text.trim(),
        'is_default':
            makeDefault,
      };

      final response = editing
          ? await SariLiveData.instance
              .buyerUpdateAddress(
              _integer(
                address['id'],
              ),
              body,
            )
          : await SariLiveData.instance
              .buyerStoreAddress(
              body,
            );

      _message(
        response['message']
                ?.toString() ??
            (editing
                ? 'Delivery address updated.'
                : 'Delivery address added.'),
      );

      await _load();
    } catch (error) {
      _message(
        error.toString(),
      );
    } finally {
      label.dispose();
      recipient.dispose();
      contact.dispose();
      street.dispose();
      province.dispose();
      municipality.dispose();
      barangay.dispose();
      postal.dispose();
    }
  }

  Future<void> _setDefaultAddress(
    int id,
  ) async {
    try {
      final response =
          await SariLiveData.instance
              .buyerSetDefaultAddress(
        id,
      );

      _message(
        response['message']
                ?.toString() ??
            'Default delivery address updated.',
      );

      await _load();
    } catch (error) {
      _message(
        error.toString(),
      );
    }
  }

  Future<void> _deleteAddress(
    Map<String, dynamic> address,
  ) async {
    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Remove Address',
          ),
          content: Text(
            'Remove "${_text(address['label'], 'this address')}" from your saved delivery addresses?',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.of(
                    dialogContext,
                  ).pop(
                    false,
                  ),
              child:
                  const Text(
                'Cancel',
              ),
            ),
            FilledButton(
              style:
                  FilledButton.styleFrom(
                backgroundColor:
                    Colors.redAccent,
              ),
              onPressed: () =>
                  Navigator.of(
                    dialogContext,
                  ).pop(
                    true,
                  ),
              child:
                  const Text(
                'Remove',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      final response =
          await SariLiveData.instance
              .buyerDeleteAddress(
        _integer(
          address['id'],
        ),
      );

      _message(
        response['message']
                ?.toString() ??
            'Delivery address removed.',
      );

      await _load();
    } catch (error) {
      _message(
        error.toString(),
      );
    }
  }

  String? _requiredValidator(
    String? value,
  ) {
    if ((value ?? '')
        .trim()
        .isEmpty) {
      return 'This field is required.';
    }

    return null;
  }

  String? _phoneValidator(
    String? value,
  ) {
    final phone =
        (value ?? '').trim();

    if (phone.isEmpty) {
      return 'Contact number is required.';
    }

    if (!RegExp(
      r'^(?:09\d{9}|\+639\d{9})$',
    ).hasMatch(
      phone,
    )) {
      return 'Use 09XXXXXXXXX or +639XXXXXXXXX.';
    }

    return null;
  }

  String? _nameValidator(
    String? value,
  ) {
    final name =
        (value ?? '').trim();

    if (name.length < 2) {
      return 'Enter at least 2 characters.';
    }

    if (!RegExp(
      r"^[A-Za-zÀ-ÖØ-öø-ÿÑñ\s.'-]+$",
    ).hasMatch(
      name,
    )) {
      return 'Enter a valid name.';
    }

    return null;
  }

  void _message(
    String message,
  ) {
    if (!mounted) return;

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

  ImageProvider? _profileImage() {
    if (_pickedProfileImagePath !=
        null) {
      return FileImage(
        File(
          _pickedProfileImagePath!,
        ),
      );
    }

    final url =
        _absoluteUrl(
      _text(
        _profile[
            'profile_image_url'],
      ),
    );

    if (url.isNotEmpty) {
      return NetworkImage(url);
    }

    return null;
  }

  String get _initials {
    final first =
        _firstNameController.text
            .trim();

    final last =
        _lastNameController.text
            .trim();

    final buffer =
        StringBuffer();

    if (first.isNotEmpty) {
      buffer.write(
        first[0],
      );
    }

    if (last.isNotEmpty) {
      buffer.write(
        last[0],
      );
    }

    final value =
        buffer.toString()
            .toUpperCase();

    return value.isEmpty
        ? 'B'
        : value;
  }

  Widget _pageHeading() {
    return const Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          'ACCOUNT MANAGEMENT',
          style: TextStyle(
            color: goldDark,
            fontSize: 8,
            fontWeight:
                FontWeight.w800,
            letterSpacing: 1.1,
          ),
        ),
        SizedBox(height: 5),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Buyer ',
              ),
              TextSpan(
                text: 'Profile',
                style: TextStyle(
                  color: gold,
                ),
              ),
            ],
          ),
          style: TextStyle(
            color: dark,
            fontSize: 27,
            fontWeight:
                FontWeight.w800,
            letterSpacing: -1,
          ),
        ),
      ],
    );
  }

  Widget _profileCard() {
    final image =
        _profileImage();

    return _card(
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Profile',
                  style:
                      TextStyle(
                    color:
                        dark,
                    fontSize:
                        14,
                    fontWeight:
                        FontWeight
                            .w800,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      const Color(
                    0xFFF5F6F7,
                  ),
                  borderRadius:
                      BorderRadius
                          .circular(
                    20,
                  ),
                ),
                child:
                    const Text(
                  'BUYER ACCOUNT',
                  style:
                      TextStyle(
                    color:
                        muted,
                    fontSize:
                        7,
                    fontWeight:
                        FontWeight
                            .w800,
                  ),
                ),
              ),
            ],
          ),
          const Divider(
            height: 24,
            color: border,
          ),
          Stack(
            clipBehavior:
                Clip.none,
            children: [
              Container(
                width: 118,
                height: 118,
                alignment:
                    Alignment.center,
                decoration:
                    BoxDecoration(
                  color:
                      const Color(
                    0xFFF4F6F8,
                  ),
                  borderRadius:
                      BorderRadius
                          .circular(
                    20,
                  ),
                  border:
                      Border.all(
                    color:
                        border,
                  ),
                  image: image ==
                          null
                      ? null
                      : DecorationImage(
                          image:
                              image,
                          fit: BoxFit
                              .cover,
                        ),
                ),
                child: image ==
                        null
                    ? Text(
                        _initials,
                        style:
                            const TextStyle(
                          color:
                              muted,
                          fontSize:
                              30,
                          fontWeight:
                              FontWeight
                                  .w700,
                        ),
                      )
                    : null,
              ),
              Positioned(
                right: -7,
                bottom: -7,
                child:
                    IconButton.filled(
                  tooltip:
                      'Change profile photo',
                  onPressed:
                      _pickProfilePhoto,
                  style:
                      IconButton.styleFrom(
                    backgroundColor:
                        gold,
                    foregroundColor:
                        Colors.white,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        11,
                      ),
                    ),
                  ),
                  icon:
                      const Icon(
                    Icons
                        .edit_outlined,
                    size: 17,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 22,
          ),
          Text(
            _text(
              _profile[
                  'full_name'],
              'SARI Buyer',
            ),
            textAlign:
                TextAlign.center,
            style:
                const TextStyle(
              color: dark,
              fontSize: 15,
              fontWeight:
                  FontWeight.w800,
            ),
          ),
          const SizedBox(
            height: 4,
          ),
          Text(
            _text(
              _profile['email'],
            ),
            textAlign:
                TextAlign.center,
            style:
                const TextStyle(
              color: muted,
              fontSize: 9,
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Container(
            padding:
                const EdgeInsets
                    .symmetric(
              horizontal: 10,
              vertical: 4,
            ),
            decoration:
                BoxDecoration(
              color:
                  const Color(
                0xFFF8F9FB,
              ),
              borderRadius:
                  BorderRadius.circular(
                20,
              ),
              border:
                  Border.all(
                color:
                    border,
              ),
            ),
            child:
                const Text(
              'Buyer',
              style:
                  TextStyle(
                color: muted,
                fontSize: 8,
                fontWeight:
                    FontWeight.w700,
              ),
            ),
          ),
          if (_pickedProfileImagePath !=
              null) ...[
            const SizedBox(
              height: 12,
            ),
            const Text(
              'New profile photo selected. Save Account Changes to upload it.',
              textAlign:
                  TextAlign.center,
              style:
                  TextStyle(
                color:
                    goldDark,
                fontSize: 8,
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(
            height: 16,
          ),
          const Divider(
            color: border,
          ),
          const SizedBox(
            height: 12,
          ),
          _profileMeta(
            'Contact',
            _text(
              _profile[
                  'contact_no'],
              'Not set',
            ),
          ),
          const SizedBox(
            height: 9,
          ),
          _profileMeta(
            'Area',
            _activeAddress !=
                    null
                ? _text(
                    _activeAddress![
                        'municipality_name'],
                    _text(
                      _activeAddress![
                          'province_name'],
                      'Not set',
                    ),
                  )
                : _profileArea
                        .isEmpty
                    ? 'Not set'
                    : _profileArea,
          ),
        ],
      ),
    );
  }

  Widget _profileMeta(
    String label,
    String value,
  ) {
    return Row(
      children: [
        Text(
          label,
          style:
              const TextStyle(
            color: muted,
            fontSize: 8.5,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign:
                TextAlign.right,
            overflow:
                TextOverflow.ellipsis,
            style:
                const TextStyle(
              color: dark,
              fontSize: 9,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _basicInformation() {
    return _card(
      child: Form(
        key:
            _profileFormKey,
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              'Basic information',
              style: TextStyle(
                color: dark,
                fontSize: 15,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            TextFormField(
              controller:
                  _firstNameController,
              maxLength: 50,
              decoration:
                  const InputDecoration(
                labelText:
                    'First Name *',
              ),
              validator:
                  _nameValidator,
            ),
            const SizedBox(
              height: 10,
            ),
            TextFormField(
              controller:
                  _lastNameController,
              maxLength: 50,
              decoration:
                  const InputDecoration(
                labelText:
                    'Last Name *',
              ),
              validator:
                  _nameValidator,
            ),
            const SizedBox(
              height: 10,
            ),
            TextFormField(
              controller:
                  _middleInitialController,
              maxLength: 2,
              textCapitalization:
                  TextCapitalization
                      .characters,
              decoration:
                  const InputDecoration(
                labelText:
                    'Middle Initial',
                helperText:
                    'Optional · up to 2 letters.',
              ),
              validator: (value) {
                final text =
                    (value ?? '')
                        .trim();

                if (text.isEmpty) {
                  return null;
                }

                if (!RegExp(
                  r'^[A-Za-z]{1,2}$',
                ).hasMatch(
                  text,
                )) {
                  return 'Use 1–2 letters only.';
                }

                return null;
              },
            ),
            const SizedBox(
              height: 10,
            ),
            InputDecorator(
              decoration:
                  const InputDecoration(
                labelText: 'Sex',
              ),
              child:
                  DropdownButtonHideUnderline(
                child:
                    DropdownButton<String>(
                  value:
                      _sex.isEmpty
                          ? ''
                          : _sex,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(
                      value: '',
                      child: Text(
                        'Not set',
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Male',
                      child: Text(
                        'Male',
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Female',
                      child: Text(
                        'Female',
                      ),
                    ),
                  ],
                  onChanged:
                      (value) {
                    setState(() {
                      _sex =
                          value ??
                              '';
                    });
                  },
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            TextFormField(
              controller:
                  _birthdayController,
              readOnly: true,
              onTap:
                  _selectBirthday,
              decoration:
                  const InputDecoration(
                labelText:
                    'Birthday *',
                suffixIcon: Icon(
                  Icons
                      .calendar_today_outlined,
                ),
              ),
              validator:
                  _requiredValidator,
            ),
            const SizedBox(
              height: 10,
            ),
            _readonlyField(
              label: 'Age',
              value:
                  _age?.toString() ??
                      '—',
              badge: 'Auto',
            ),
            const SizedBox(
              height: 10,
            ),
            _readonlyField(
              label: 'Email',
              value: _text(
                _profile['email'],
                'Not available',
              ),
              badge: 'Locked',
            ),
            const SizedBox(
              height: 10,
            ),
            TextFormField(
              controller:
                  _contactController,
              keyboardType:
                  TextInputType.phone,
              decoration:
                  const InputDecoration(
                labelText:
                    'Contact Number *',
                hintText:
                    '09XXXXXXXXX or +639XXXXXXXXX',
                helperText:
                    'Use 09XXXXXXXXX or +639XXXXXXXXX.',
              ),
              validator:
                  _phoneValidator,
            ),
          ],
        ),
      ),
    );
  }

  Widget _addressDetails() {
    final active =
        _activeAddress;

    return _card(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'Address details',
            style: TextStyle(
              color: dark,
              fontSize: 15,
              fontWeight:
                  FontWeight.w800,
            ),
          ),
          const SizedBox(
            height: 14,
          ),
          Row(
            children: [
              const Text(
                'Active address',
                style:
                    TextStyle(
                  color: dark,
                  fontSize: 9,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              Container(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      const Color(
                    0xFFFFF3DA,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),
                ),
                child: Text(
                  active != null
                      ? _text(
                          active[
                              'label'],
                          'Saved address',
                        )
                      : 'Registered address',
                  style:
                      const TextStyle(
                    color:
                        goldDark,
                    fontSize: 8,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 14,
          ),
          if (active != null) ...[
            _readonlyField(
              label:
                  'Street / Unit Address',
              value: _text(
                active[
                    'street_address'],
                'Not set',
              ),
              badge: 'Active',
            ),
            const SizedBox(
              height: 10,
            ),
            _readonlyField(
              label: 'Barangay',
              value: _text(
                active[
                    'barangay_name'],
                'Not set',
              ),
              badge: 'Active',
            ),
            const SizedBox(
              height: 10,
            ),
            _readonlyField(
              label:
                  'City / Municipality',
              value: _text(
                active[
                    'municipality_name'],
                'Not set',
              ),
              badge: 'Active',
            ),
            const SizedBox(
              height: 10,
            ),
            _readonlyField(
              label:
                  'Province / Area',
              value: _text(
                active[
                    'province_name'],
                'Not set',
              ),
              badge: 'Active',
            ),
          ] else ...[
            TextFormField(
              controller:
                  _streetController,
              minLines: 2,
              maxLines: 3,
              maxLength: 500,
              decoration:
                  const InputDecoration(
                labelText:
                    'Street / Unit Address *',
                hintText:
                    'House, unit, building, subdivision, or street',
              ),
              validator:
                  _requiredValidator,
            ),
            const SizedBox(
              height: 10,
            ),
            _readonlyField(
              label: 'Barangay',
              value: _text(
                _profile[
                    'barangay_name'],
                'Not set',
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            _readonlyField(
              label:
                  'City / Municipality',
              value: _text(
                _profile[
                    'municipality_name'],
                'Not set',
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            _readonlyField(
              label:
                  'Province / Area',
              value: _text(
                _profile[
                    'province_name'],
                'Not set',
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _addressBook() {
    return _card(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Address',
                  style:
                      TextStyle(
                    color:
                        dark,
                    fontSize:
                        15,
                    fontWeight:
                        FontWeight
                            .w800,
                  ),
                ),
              ),
              if (_addresses.length <
                  5)
                OutlinedButton.icon(
                  onPressed: () =>
                      _openAddressForm(),
                  icon:
                      const Icon(
                    Icons
                        .add_rounded,
                    size: 17,
                  ),
                  label:
                      const Text(
                    'Add Address',
                  ),
                )
              else
                const Text(
                  'Address Limit Reached',
                  style:
                      TextStyle(
                    color:
                        muted,
                    fontSize:
                        8,
                    fontWeight:
                        FontWeight
                            .w700,
                  ),
                ),
            ],
          ),
          const Divider(
            height: 24,
            color: border,
          ),
          if (_addresses.isEmpty)
            const Padding(
              padding:
                  EdgeInsets.symmetric(
                vertical: 18,
              ),
              child: Column(
                children: [
                  Icon(
                    Icons
                        .location_on_outlined,
                    color: muted,
                    size: 40,
                  ),
                  SizedBox(
                    height: 9,
                  ),
                  Text(
                    'No saved delivery addresses',
                    style:
                        TextStyle(
                      color:
                          dark,
                      fontSize:
                          12,
                      fontWeight:
                          FontWeight
                              .w700,
                    ),
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Text(
                    'Add another address for Home, Office, or any preferred delivery location.',
                    textAlign:
                        TextAlign.center,
                    style:
                        TextStyle(
                      color:
                          muted,
                      fontSize:
                          8,
                      height:
                          1.4,
                    ),
                  ),
                ],
              ),
            )
          else
            ..._addresses.map(
              _addressCard,
            ),
        ],
      ),
    );
  }

  Widget _addressCard(
    Map<String, dynamic> address,
  ) {
    final active =
        address['is_default'] ==
            true;

    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 10,
      ),
      padding:
          const EdgeInsets.all(
        13,
      ),
      decoration:
          BoxDecoration(
        color: const Color(
          0xFFFCFBF8,
        ),
        borderRadius:
            BorderRadius.circular(
          12,
        ),
        border:
            Border.all(
          color: active
              ? const Color(
                  0xFFE4C17B,
                )
              : border,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _text(
                    address['label'],
                    'Address',
                  ),
                  style:
                      const TextStyle(
                    color: dark,
                    fontSize: 11,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
              ),
              if (active)
                Container(
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration:
                      BoxDecoration(
                    color:
                        const Color(
                      0xFFFFF3DA,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      20,
                    ),
                  ),
                  child:
                      const Text(
                    'Active',
                    style:
                        TextStyle(
                      color:
                          goldDark,
                      fontSize:
                          7,
                      fontWeight:
                          FontWeight
                              .w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            _text(
              address[
                  'recipient_name'],
            ),
            style:
                const TextStyle(
              color: dark,
              fontSize: 9,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
          const SizedBox(
            height: 3,
          ),
          Text(
            _text(
              address[
                  'street_address'],
            ),
            style:
                const TextStyle(
              color: muted,
              fontSize: 8.5,
            ),
          ),
          const SizedBox(
            height: 3,
          ),
          Text(
            [
              _text(
                address[
                    'barangay_name'],
              ),
              _text(
                address[
                    'municipality_name'],
              ),
              _text(
                address[
                    'province_name'],
              ),
              if (_text(
                address[
                    'postal_code'],
              ).isNotEmpty)
                _text(
                  address[
                      'postal_code'],
                ),
              'Philippines',
            ]
                .where(
                  (value) =>
                      value.isNotEmpty,
                )
                .join(', '),
            style:
                const TextStyle(
              color: muted,
              fontSize: 8.5,
              height: 1.4,
            ),
          ),
          const SizedBox(
            height: 3,
          ),
          Text(
            _text(
              address[
                  'contact_no'],
            ),
            style:
                const TextStyle(
              color: muted,
              fontSize: 8.5,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              if (active)
                const Icon(
                  Icons
                      .check_circle_rounded,
                  color:
                      goldDark,
                  size: 20,
                )
              else
                IconButton(
                  tooltip:
                      'Use this address',
                  onPressed: () =>
                      _setDefaultAddress(
                    _integer(
                      address['id'],
                    ),
                  ),
                  icon:
                      const Icon(
                    Icons
                        .check_circle_outline_rounded,
                    color:
                        goldDark,
                  ),
                ),
              const Spacer(),
              IconButton(
                tooltip:
                    'Edit address',
                onPressed: () =>
                    _openAddressForm(
                  address:
                      address,
                ),
                icon:
                    const Icon(
                  Icons
                      .edit_outlined,
                  color:
                      goldDark,
                ),
              ),
              IconButton(
                tooltip:
                    'Delete address',
                onPressed: () =>
                    _deleteAddress(
                  address,
                ),
                icon:
                    const Icon(
                  Icons
                      .delete_outline_rounded,
                  color: Colors
                      .redAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _readonlyField({
    required String label,
    required String value,
    String? badge,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style:
              const TextStyle(
            color: dark,
            fontSize: 9.5,
            fontWeight:
                FontWeight.w700,
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        Container(
  width: double.infinity,
  constraints: const BoxConstraints(
    minHeight: 45,
  ),
  padding: const EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 11,
  ),
          decoration:
              BoxDecoration(
            color:
                const Color(
              0xFFF7F9FB,
            ),
            borderRadius:
                BorderRadius.circular(
              10,
            ),
            border:
                Border.all(
              color: border,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style:
                      const TextStyle(
                    color:
                        dark,
                    fontSize:
                        10,
                    fontWeight:
                        FontWeight
                            .w600,
                  ),
                ),
              ),
              if (badge !=
                  null)
                Container(
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration:
                      BoxDecoration(
                    color:
                        Colors.white,
                    borderRadius:
                        BorderRadius.circular(
                      20,
                    ),
                    border:
                        Border.all(
                      color:
                          border,
                    ),
                  ),
                  child:
                      Text(
                    badge,
                    style:
                        const TextStyle(
                      color:
                          muted,
                      fontSize:
                          7,
                      fontWeight:
                          FontWeight
                              .w700,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _saveButton() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Profile changes are saved securely to your Buyer account.',
          textAlign:
              TextAlign.center,
          style: TextStyle(
            color: muted,
            fontSize: 8,
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        ElevatedButton.icon(
          onPressed:
              _savingProfile
                  ? null
                  : _saveProfile,
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
              vertical: 14,
            ),
          ),
          icon:
              _savingProfile
                  ? const SizedBox(
                      width: 17,
                      height: 17,
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
                          .save_outlined,
                    ),
          label:
              Text(
            _savingProfile
                ? 'Saving...'
                : 'Save Account Changes',
          ),
        ),
      ],
    );
  }

  Widget _card({
    required Widget child,
  }) {
    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.all(
        16,
      ),
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
          16,
        ),
        border:
            Border.all(
          color: border,
        ),
      ),
      child: child,
    );
  }

  Widget _errorState() {
    return ListView(
      padding:
          const EdgeInsets.all(
        24,
      ),
      children: [
        const SizedBox(
          height: 70,
        ),
        const Icon(
          Icons
              .error_outline_rounded,
          color: muted,
          size: 48,
        ),
        const SizedBox(
          height: 12,
        ),
        Text(
          _error ??
              'Unable to load account.',
          textAlign:
              TextAlign.center,
          style:
              const TextStyle(
            color: muted,
            fontSize: 10,
          ),
        ),
        const SizedBox(
          height: 14,
        ),
        FilledButton(
          onPressed: _load,
          child:
              const Text(
            'Try Again',
          ),
        ),
      ],
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: canvas,
      body: Column(
        children: [
          BuyerHeader(
            pageTitle:
                'Account',
            cartCount: 0,
            notificationCount: 0,
            onSearchTap: () =>
                widget.onTabChanged
                    ?.call(1),
            onCartTap: () =>
                widget.onTabChanged
                    ?.call(2),
            onNotificationTap: () =>
                widget.onTabChanged
                    ?.call(5),
            onProfileTap: () {},
          ),
          Expanded(
            child:
                RefreshIndicator(
              color: gold,
              onRefresh: _load,
              child: _loading
                  ? ListView(
                      children:
                          const [
                        SizedBox(
                          height:
                              180,
                        ),
                        Center(
                          child:
                              CircularProgressIndicator(
                            color:
                                gold,
                          ),
                        ),
                      ],
                    )
                  : _error != null
                      ? _errorState()
                      : ListView(
                          physics:
                              const AlwaysScrollableScrollPhysics(),
                          padding:
                              const EdgeInsets.fromLTRB(
                            14,
                            18,
                            14,
                            30,
                          ),
                          children: [
                            _pageHeading(),
                            const SizedBox(
                              height:
                                  16,
                            ),
                            _profileCard(),
                            const SizedBox(
                              height:
                                  12,
                            ),
                            _basicInformation(),
                            const SizedBox(
                              height:
                                  12,
                            ),
                            _addressDetails(),
                            const SizedBox(
                              height:
                                  12,
                            ),
                            _addressBook(),
                            const SizedBox(
                              height:
                                  16,
                            ),
                            _saveButton(),
                          ],
                        ),
            ),
          ),
        ],
      ),
    );
  }
}