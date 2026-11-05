import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/registration_api.dart';
import '../widgets/sari_address_picker.dart';
import 'registration_pending_screen.dart';
import 'rider_logistics_screen.dart';

class RiderRegisterScreen
    extends StatefulWidget {
  const RiderRegisterScreen({
    super.key,
    required this.provider,
  });

  final LogisticsProvider provider;

  @override
  State<RiderRegisterScreen>
      createState() =>
          _RiderRegisterScreenState();
}

class _RiderRegisterScreenState
    extends State<RiderRegisterScreen> {
  static const Color _background =
      Color(0xFF0B0B0D);

  static const Color _surface =
      Color(0xFF18181C);

  static const Color _field =
      Color(0xFF222226);

  static const Color _border =
      Color(0xFF37373D);

  static const Color _gold =
      Color(0xFFD4A62A);

  static const Color _muted =
      Color(0xFFA7A7AF);

  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  final TextEditingController
      _lastName =
      TextEditingController();

  final TextEditingController
      _firstName =
      TextEditingController();

  final TextEditingController
      _middleInitial =
      TextEditingController();

  final TextEditingController _email =
      TextEditingController();

  final TextEditingController _contact =
      TextEditingController();

  final TextEditingController _birthday =
      TextEditingController();

  final TextEditingController _province =
      TextEditingController();

  final TextEditingController _provinceCode =
      TextEditingController();

  final TextEditingController _municipality =
      TextEditingController();

  final TextEditingController
      _municipalityCode =
      TextEditingController();

  final TextEditingController _barangay =
      TextEditingController();

  final TextEditingController _barangayCode =
      TextEditingController();

  final TextEditingController _street =
      TextEditingController();

  final TextEditingController
      _licenseNumber =
      TextEditingController();

  final TextEditingController
      _licenseExpiry =
      TextEditingController();

  final TextEditingController
      _plateNumber =
      TextEditingController();

  final TextEditingController _password =
      TextEditingController();

  final TextEditingController
      _passwordConfirmation =
      TextEditingController();

  String? _sex;
  String? _vehicleType;

  PlatformFile? _profileImage;
  PlatformFile? _idDocument;
  PlatformFile? _orcrDocument;

  bool _terms = false;
  bool _hidePassword = true;
  bool _hideConfirmation = true;
  bool _busy = false;

  @override
  void dispose() {
    final List<TextEditingController>
        controllers =
        <TextEditingController>[
      _lastName,
      _firstName,
      _middleInitial,
      _email,
      _contact,
      _birthday,
      _province,
      _provinceCode,
      _municipality,
      _municipalityCode,
      _barangay,
      _barangayCode,
      _street,
      _licenseNumber,
      _licenseExpiry,
      _plateNumber,
      _password,
      _passwordConfirmation,
    ];

    for (final TextEditingController controller
        in controllers) {
      controller.dispose();
    }

    super.dispose();
  }

  // ============================================================
  // DATE PICKERS
  // ============================================================

  Future<void> _pickBirthday() async {
    final DateTime today =
        DateTime.now();

    final DateTime latest =
        DateTime(
      today.year - 18,
      today.month,
      today.day,
    );

    final DateTime? date =
        await showDatePicker(
      context: context,
      initialDate:
          DateTime(
        latest.year - 3,
        latest.month,
        latest.day,
      ),
      firstDate:
          DateTime(1900),
      lastDate: latest,
    );

    if (date == null) {
      return;
    }

    _birthday.text =
        _formatDate(date);

    setState(() {});
  }

  Future<void> _pickExpiry()
      async {
    final DateTime today =
        DateTime.now();

    final DateTime? date =
        await showDatePicker(
      context: context,
      initialDate:
          today.add(
        const Duration(
          days: 365,
        ),
      ),
      firstDate:
          DateTime(
        today.year,
        today.month,
        today.day,
      ),
      lastDate:
          DateTime(
        today.year + 15,
        12,
        31,
      ),
    );

    if (date == null) {
      return;
    }

    _licenseExpiry.text =
        _formatDate(date);

    setState(() {});
  }

  String _formatDate(
    DateTime value,
  ) {
    return '${value.year.toString().padLeft(4, '0')}-'
        '${value.month.toString().padLeft(2, '0')}-'
        '${value.day.toString().padLeft(2, '0')}';
  }

  // ============================================================
  // FILES
  // ============================================================

Future<PlatformFile?> _pickFile({
  required List<String> extensions,
}) async {
  final FilePickerResult? result =
      await FilePicker.pickFiles(
    type: FileType.custom,
    allowedExtensions: extensions,
    allowMultiple: false,
  );

  if (result == null ||
      result.files.isEmpty) {
    return null;
  }

  final PlatformFile file =
      result.files.single;

  if (file.path == null) {
    _message(
      'The selected file cannot be read.',
    );

    return null;
  }

  return file;
}

  Future<void> _pickProfile()
      async {
    final PlatformFile? file =
        await _pickFile(
      extensions:
          const <String>[
        'jpg',
        'jpeg',
        'png',
        'webp',
      ],
    );

    if (file != null) {
      setState(() {
        _profileImage = file;
      });
    }
  }

  Future<void> _pickId()
      async {
    final PlatformFile? file =
        await _pickFile(
      extensions:
          const <String>[
        'jpg',
        'jpeg',
        'png',
        'pdf',
      ],
    );

    if (file != null) {
      setState(() {
        _idDocument = file;
      });
    }
  }

  Future<void> _pickOrcr()
      async {
    final PlatformFile? file =
        await _pickFile(
      extensions:
          const <String>[
        'jpg',
        'jpeg',
        'png',
        'pdf',
      ],
    );

    if (file != null) {
      setState(() {
        _orcrDocument = file;
      });
    }
  }

  // ============================================================
  // VALIDATION
  // ============================================================

  bool _validBeforeOtp() {
    FocusScope.of(context)
        .unfocus();

    if (!(_formKey.currentState
            ?.validate() ??
        false)) {
      return false;
    }

    if (_sex == null) {
      _message(
        'Please select your sex.',
      );
      return false;
    }

    if (_vehicleType == null) {
      _message(
        'Please select your vehicle type.',
      );
      return false;
    }

    if (_provinceCode
            .text
            .trim()
            .isEmpty ||
        _municipalityCode
            .text
            .trim()
            .isEmpty ||
        _barangayCode
            .text
            .trim()
            .isEmpty) {
      _message(
        'Please select your complete address.',
      );
      return false;
    }

    if (_profileImage == null) {
      _message(
        'Please upload your profile photo.',
      );
      return false;
    }

    if (_idDocument == null) {
      _message(
        'Please upload your valid ID or driver\'s license.',
      );
      return false;
    }

    if (_orcrDocument == null) {
      _message(
        'Please upload your OR/CR.',
      );
      return false;
    }

    if (!_terms) {
      _message(
        'Please accept the Terms and Privacy Policy.',
      );
      return false;
    }

    return true;
  }

  // ============================================================
  // OTP
  // ============================================================

  Future<void> _beginRegistration()
      async {
    if (_busy ||
        !_validBeforeOtp()) {
      return;
    }

    setState(() {
      _busy = true;
    });

    try {
      final String message =
          await RegistrationApi
              .instance
              .sendRiderOtp(
        logisticsId:
            widget.provider.id,
        email:
            _email.text
                .trim()
                .toLowerCase(),
      );

      if (!mounted) {
        return;
      }

      _message(message);

      final String? otp =
          await _showOtpDialog();

      if (otp == null ||
          otp.length != 6 ||
          !mounted) {
        return;
      }

      await RegistrationApi
          .instance
          .verifyRiderOtp(
        logisticsId:
            widget.provider.id,
        email:
            _email.text
                .trim()
                .toLowerCase(),
        otp: otp,
      );

      if (!mounted) {
        return;
      }

      await _submit();
    } on RegistrationApiException
        catch (error) {
      _message(error.message);
    } catch (error) {
      _message(
        'Registration failed: $error',
      );
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  Future<String?>
      _showOtpDialog() async {
    final TextEditingController otp =
        TextEditingController();

    final String? result =
        await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (
        BuildContext dialogContext,
      ) {
        return AlertDialog(
          title: const Text(
            'Verify your email',
          ),
          content: Column(
            mainAxisSize:
                MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Enter the 6-digit code sent to ${_email.text.trim()}.',
              ),
              const SizedBox(
                height: 16,
              ),
              TextField(
                controller: otp,
                autofocus: true,
                maxLength: 6,
                keyboardType:
                    TextInputType.number,
                inputFormatters:
                    <TextInputFormatter>[
                  FilteringTextInputFormatter
                      .digitsOnly,
                ],
                textAlign:
                    TextAlign.center,
                style:
                    const TextStyle(
                  fontSize: 24,
                  letterSpacing: 8,
                  fontWeight:
                      FontWeight.w800,
                ),
                decoration:
                    const InputDecoration(
                  counterText: '',
                  hintText: '000000',
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );
              },
              child:
                  const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final String code =
                    otp.text.trim();

                if (code.length == 6) {
                  Navigator.pop(
                    dialogContext,
                    code,
                  );
                }
              },
              child:
                  const Text('Verify'),
            ),
          ],
        );
      },
    );

    otp.dispose();

    return result;
  }

  // ============================================================
  // SUBMIT
  // ============================================================

  Future<void> _submit()
      async {
    final Map<String, String> fields =
        <String, String>{
      'last_name':
          _lastName.text.trim(),
      'first_name':
          _firstName.text.trim(),
      'middle_initial':
          _middleInitial.text
              .trim()
              .toUpperCase(),
      'sex': _sex!,
      'email':
          _email.text
              .trim()
              .toLowerCase(),
      'contact_no':
          _contact.text.trim(),
      'birthday':
          _birthday.text.trim(),

      'province_code':
          _provinceCode.text.trim(),
      'province_name':
          _province.text.trim(),

      'municipality_code':
          _municipalityCode
              .text
              .trim(),
      'municipality_name':
          _municipality.text.trim(),

      'barangay_code':
          _barangayCode.text.trim(),
      'barangay_name':
          _barangay.text.trim(),

      'street_address':
          _street.text.trim(),

      'license_number':
          _licenseNumber.text
              .trim()
              .toUpperCase(),

      'license_expiry_date':
          _licenseExpiry.text.trim(),

      'vehicle_type':
          _vehicleType!,

      'plate_number':
          _plateNumber.text
              .trim()
              .toUpperCase(),

      'password':
          _password.text,

      'password_confirmation':
          _passwordConfirmation.text,

      'terms': '1',
    };

    await RegistrationApi
        .instance
        .registerRider(
      logisticsId:
          widget.provider.id,
      fields: fields,
      profileImage:
          _profileImage!,
      idDocument:
          _idDocument!,
      orcrDocument:
          _orcrDocument!,
    );

    if (!mounted) {
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (
          BuildContext context,
        ) {
          return RegistrationPendingScreen(
            role: 'rider',
            email:
                _email.text
                    .trim()
                    .toLowerCase(),
            reviewerName:
                widget.provider.name,
          );
        },
      ),
    );
  }

  // ============================================================
  // UI HELPERS
  // ============================================================

  void _message(String message) {
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

  InputDecoration _decoration(
    String label, {
    String? hint,
    IconData? icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle:
          const TextStyle(
        color: _muted,
        fontSize: 12,
      ),
      hintStyle:
          const TextStyle(
        color:
            Color(0xFF6E6E76),
        fontSize: 11,
      ),
      prefixIcon: icon == null
          ? null
          : Icon(
              icon,
              color: _muted,
              size: 19,
            ),
      suffixIcon: suffix,
      filled: true,
      fillColor: _field,
      enabledBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),
        borderSide:
            const BorderSide(
          color: _border,
        ),
      ),
      focusedBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),
        borderSide:
            const BorderSide(
          color: _gold,
          width: 1.4,
        ),
      ),
      errorBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),
        borderSide:
            const BorderSide(
          color: Colors.redAccent,
        ),
      ),
      focusedErrorBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),
        borderSide:
            const BorderSide(
          color: Colors.redAccent,
        ),
      ),
    );
  }

  Widget _section({
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return Container(
      padding:
          const EdgeInsets.all(17),
      decoration:
          BoxDecoration(
        color: _surface,
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color: _border,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style:
                const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight:
                  FontWeight.w800,
            ),
          ),
          const SizedBox(
            height: 4,
          ),
          Text(
            subtitle,
            style:
                const TextStyle(
              color: _muted,
              fontSize: 9,
              height: 1.4,
            ),
          ),
          const SizedBox(
            height: 17,
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _gap() {
    return const SizedBox(
      height: 13,
    );
  }

  Widget _fileTile({
    required String title,
    required String subtitle,
    required PlatformFile? file,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(14),
      child: Container(
        padding:
            const EdgeInsets.all(13),
        decoration:
            BoxDecoration(
          color: _field,
          borderRadius:
              BorderRadius.circular(14),
          border: Border.all(
            color: file == null
                ? _border
                : _gold,
          ),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 42,
              height: 42,
              alignment:
                  Alignment.center,
              decoration:
                  BoxDecoration(
                color: file == null
                    ? const Color(
                        0xFF2A2A2F,
                      )
                    : const Color(
                        0xFF3B311A,
                      ),
                borderRadius:
                    BorderRadius.circular(
                  12,
                ),
              ),
              child: Icon(
                file == null
                    ? Icons
                        .upload_file_outlined
                    : Icons
                        .check_circle_outline_rounded,
                color: file == null
                    ? _muted
                    : _gold,
              ),
            ),
            const SizedBox(
              width: 11,
            ),
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
                          Colors.white,
                      fontSize: 11,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                  const SizedBox(
                    height: 3,
                  ),
                  Text(
                    file?.name ??
                        subtitle,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style:
                        const TextStyle(
                      color: _muted,
                      fontSize: 8,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons
                  .chevron_right_rounded,
              color: _muted,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor:
            Colors.white,
        surfaceTintColor:
            Colors.transparent,
        title: const Text(
          'Rider Application',
          style: TextStyle(
            fontSize: 17,
            fontWeight:
                FontWeight.w800,
          ),
        ),
      ),
      body:
          SingleChildScrollView(
        padding:
            const EdgeInsets.fromLTRB(
          16,
          8,
          16,
          32,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .stretch,
            children: <Widget>[
              Container(
                padding:
                    const EdgeInsets.all(
                  17,
                ),
                decoration:
                    BoxDecoration(
                  gradient:
                      const LinearGradient(
                    colors: <Color>[
                      Color(
                        0xFF28292F,
                      ),
                      Color(
                        0xFF18181C,
                      ),
                      Color(
                        0xFF362E1A,
                      ),
                    ],
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 48,
                      height: 48,
                      alignment:
                          Alignment.center,
                      decoration:
                          BoxDecoration(
                        color: Colors.white
                            .withOpacity(
                          .09,
                        ),
                        borderRadius:
                            BorderRadius
                                .circular(
                          14,
                        ),
                      ),
                      child:
                          const Icon(
                        Icons
                            .local_shipping_outlined,
                        color: _gold,
                      ),
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: <Widget>[
                          const Text(
                            'Applying to',
                            style:
                                TextStyle(
                              color: _muted,
                              fontSize: 9,
                            ),
                          ),
                          const SizedBox(
                            height: 3,
                          ),
                          Text(
                            widget
                                .provider
                                .name,
                            style:
                                const TextStyle(
                              color: Colors
                                  .white,
                              fontSize: 14,
                              fontWeight:
                                  FontWeight
                                      .w800,
                            ),
                          ),
                          const SizedBox(
                            height: 3,
                          ),
                          Text(
                            widget
                                .provider
                                .location,
                            style:
                                const TextStyle(
                              color: _muted,
                              fontSize: 8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 16,
              ),

              _section(
                title:
                    'Personal Information',
                subtitle:
                    'Use the same information shown on your valid government documents.',
                children: <Widget>[
                  TextFormField(
                    controller:
                        _firstName,
                    textCapitalization:
                        TextCapitalization
                            .words,
                    style:
                        const TextStyle(
                      color: Colors.white,
                    ),
                    decoration:
                        _decoration(
                      'First Name',
                      icon: Icons
                          .person_outline,
                    ),
                    validator:
                        _requiredText,
                  ),
                  _gap(),
                  TextFormField(
                    controller:
                        _lastName,
                    textCapitalization:
                        TextCapitalization
                            .words,
                    style:
                        const TextStyle(
                      color: Colors.white,
                    ),
                    decoration:
                        _decoration(
                      'Last Name',
                      icon: Icons
                          .person_outline,
                    ),
                    validator:
                        _requiredText,
                  ),
                  _gap(),
                  TextFormField(
                    controller:
                        _middleInitial,
                    maxLength: 1,
                    textCapitalization:
                        TextCapitalization
                            .characters,
                    style:
                        const TextStyle(
                      color: Colors.white,
                    ),
                    decoration:
                        _decoration(
                      'Middle Initial',
                      hint: 'Optional',
                    ).copyWith(
                      counterText: '',
                    ),
                  ),
                  _gap(),
                  DropdownButtonFormField<
                      String>(
                    value: _sex,
                    dropdownColor:
                        _surface,
                    style:
                        const TextStyle(
                      color: Colors.white,
                    ),
                    decoration:
                        _decoration(
                      'Sex',
                      icon:
                          Icons.wc_outlined,
                    ),
                    items:
                        const <DropdownMenuItem<
                            String>>[
                      DropdownMenuItem(
                        value: 'Male',
                        child:
                            Text('Male'),
                      ),
                      DropdownMenuItem(
                        value: 'Female',
                        child:
                            Text('Female'),
                      ),
                    ],
                    onChanged:
                        (String? value) {
                      setState(() {
                        _sex = value;
                      });
                    },
                  ),
                  _gap(),
                  TextFormField(
                    controller:
                        _birthday,
                    readOnly: true,
                    onTap:
                        _pickBirthday,
                    style:
                        const TextStyle(
                      color: Colors.white,
                    ),
                    decoration:
                        _decoration(
                      'Birthday',
                      icon: Icons
                          .calendar_month_outlined,
                    ),
                    validator:
                        _requiredText,
                  ),
                ],
              ),

              const SizedBox(
                height: 14,
              ),

              _section(
                title:
                    'Contact & Address',
                subtitle:
                    'Your service area is based on the official address data from SARI.',
                children: <Widget>[
                  TextFormField(
                    controller: _email,
                    keyboardType:
                        TextInputType
                            .emailAddress,
                    style:
                        const TextStyle(
                      color: Colors.white,
                    ),
                    decoration:
                        _decoration(
                      'Email Address',
                      icon: Icons
                          .mail_outline,
                    ),
                    validator:
                        _emailValidator,
                  ),
                  _gap(),
                  TextFormField(
                    controller:
                        _contact,
                    keyboardType:
                        TextInputType.phone,
                    maxLength: 11,
                    inputFormatters:
                        <TextInputFormatter>[
                      FilteringTextInputFormatter
                          .digitsOnly,
                    ],
                    style:
                        const TextStyle(
                      color: Colors.white,
                    ),
                    decoration:
                        _decoration(
                      'Mobile Number',
                      hint:
                          '09XXXXXXXXX',
                      icon: Icons
                          .phone_outlined,
                    ).copyWith(
                      counterText: '',
                    ),
                    validator:
                        _phoneValidator,
                  ),
                  _gap(),

                  SariAddressPicker(
                    province:
                        _province,
                    provinceCode:
                        _provinceCode,
                    municipality:
                        _municipality,
                    municipalityCode:
                        _municipalityCode,
                    barangay:
                        _barangay,
                    barangayCode:
                        _barangayCode,
                    accent: _gold,
                  ),

                  _gap(),

                  TextFormField(
                    controller:
                        _street,
                    minLines: 2,
                    maxLines: 3,
                    textCapitalization:
                        TextCapitalization
                            .words,
                    style:
                        const TextStyle(
                      color: Colors.white,
                    ),
                    decoration:
                        _decoration(
                      'Street Address',
                      icon: Icons
                          .home_outlined,
                    ),
                    validator:
                        _requiredText,
                  ),
                ],
              ),

              const SizedBox(
                height: 14,
              ),

              _section(
                title:
                    'Rider & Vehicle',
                subtitle:
                    'These details are checked by your selected Logistics provider.',
                children: <Widget>[
                  TextFormField(
                    controller:
                        _licenseNumber,
                    textCapitalization:
                        TextCapitalization
                            .characters,
                    inputFormatters:
                        <TextInputFormatter>[
                      FilteringTextInputFormatter
                          .allow(
                        RegExp(
                          r'[A-Za-z0-9-]',
                        ),
                      ),
                    ],
                    style:
                        const TextStyle(
                      color: Colors.white,
                    ),
                    decoration:
                        _decoration(
                      'Driver\'s License Number',
                      hint:
                          'A12-34-567890',
                      icon: Icons
                          .badge_outlined,
                    ),
                    validator:
                        _licenseValidator,
                  ),
                  _gap(),
                  TextFormField(
                    controller:
                        _licenseExpiry,
                    readOnly: true,
                    onTap:
                        _pickExpiry,
                    style:
                        const TextStyle(
                      color: Colors.white,
                    ),
                    decoration:
                        _decoration(
                      'License Expiry',
                      icon: Icons
                          .event_available_outlined,
                    ),
                    validator:
                        _requiredText,
                  ),
                  _gap(),
                  DropdownButtonFormField<
                      String>(
                    value:
                        _vehicleType,
                    dropdownColor:
                        _surface,
                    style:
                        const TextStyle(
                      color: Colors.white,
                    ),
                    decoration:
                        _decoration(
                      'Vehicle Type',
                      icon: Icons
                          .two_wheeler_outlined,
                    ),
                    items:
                        const <DropdownMenuItem<
                            String>>[
                      DropdownMenuItem(
                        value:
                            'Motorcycle',
                        child: Text(
                          'Motorcycle',
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'Car',
                        child:
                            Text('Car'),
                      ),
                      DropdownMenuItem(
                        value: 'Van',
                        child:
                            Text('Van'),
                      ),
                    ],
                    onChanged:
                        (String? value) {
                      setState(() {
                        _vehicleType =
                            value;
                      });
                    },
                  ),
                  _gap(),
                  TextFormField(
                    controller:
                        _plateNumber,
                    textCapitalization:
                        TextCapitalization
                            .characters,
                    style:
                        const TextStyle(
                      color: Colors.white,
                    ),
                    decoration:
                        _decoration(
                      'Plate Number',
                      icon: Icons
                          .directions_car_outlined,
                    ),
                    validator:
                        _requiredText,
                  ),
                ],
              ),

              const SizedBox(
                height: 14,
              ),

              _section(
                title:
                    'Documents',
                subtitle:
                    'Maximum upload size supported by Laravel is 5 MB per file.',
                children: <Widget>[
                  _fileTile(
                    title:
                        'Profile Photo',
                    subtitle:
                        'JPG, PNG or WEBP',
                    file:
                        _profileImage,
                    onTap:
                        _pickProfile,
                  ),
                  _gap(),
                  _fileTile(
                    title:
                        'Driver\'s License / Valid ID',
                    subtitle:
                        'JPG, PNG or PDF',
                    file:
                        _idDocument,
                    onTap: _pickId,
                  ),
                  _gap(),
                  _fileTile(
                    title:
                        'Vehicle OR/CR',
                    subtitle:
                        'JPG, PNG or PDF',
                    file:
                        _orcrDocument,
                    onTap: _pickOrcr,
                  ),
                ],
              ),

              const SizedBox(
                height: 14,
              ),

              _section(
                title:
                    'Secure your account',
                subtitle:
                    'Password must contain uppercase, lowercase, number and symbol.',
                children: <Widget>[
                  TextFormField(
                    controller:
                        _password,
                    obscureText:
                        _hidePassword,
                    style:
                        const TextStyle(
                      color: Colors.white,
                    ),
                    decoration:
                        _decoration(
                      'Password',
                      icon:
                          Icons.lock_outline,
                      suffix: IconButton(
                        onPressed: () {
                          setState(() {
                            _hidePassword =
                                !_hidePassword;
                          });
                        },
                        icon: Icon(
                          _hidePassword
                              ? Icons
                                  .visibility_outlined
                              : Icons
                                  .visibility_off_outlined,
                          color: _muted,
                        ),
                      ),
                    ),
                    validator:
                        _passwordValidator,
                  ),
                  _gap(),
                  TextFormField(
                    controller:
                        _passwordConfirmation,
                    obscureText:
                        _hideConfirmation,
                    style:
                        const TextStyle(
                      color: Colors.white,
                    ),
                    decoration:
                        _decoration(
                      'Confirm Password',
                      icon:
                          Icons.lock_outline,
                      suffix: IconButton(
                        onPressed: () {
                          setState(() {
                            _hideConfirmation =
                                !_hideConfirmation;
                          });
                        },
                        icon: Icon(
                          _hideConfirmation
                              ? Icons
                                  .visibility_outlined
                              : Icons
                                  .visibility_off_outlined,
                          color: _muted,
                        ),
                      ),
                    ),
                    validator:
                        (
                      String? value,
                    ) {
                      if (value !=
                          _password.text) {
                        return 'Passwords do not match.';
                      }

                      return null;
                    },
                  ),
                ],
              ),

              const SizedBox(
                height: 15,
              ),

              CheckboxListTile(
                value: _terms,
                activeColor: _gold,
                checkColor:
                    Colors.black,
                contentPadding:
                    EdgeInsets.zero,
                onChanged:
                    (bool? value) {
                  setState(() {
                    _terms =
                        value ?? false;
                  });
                },
                title:
                    const Text(
                  'I agree to the Terms and Privacy Policy.',
                  style: TextStyle(
                    color:
                        Colors.white,
                    fontSize: 11,
                  ),
                ),
                subtitle:
                    const Text(
                  'Your Rider application will be reviewed by the selected Logistics provider.',
                  style: TextStyle(
                    color: _muted,
                    fontSize: 8,
                  ),
                ),
              ),

              const SizedBox(
                height: 15,
              ),

              SizedBox(
                height: 54,
                child:
                    ElevatedButton(
                  onPressed: _busy
                      ? null
                      : _beginRegistration,
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        _gold,
                    foregroundColor:
                        Colors.black,
                    disabledBackgroundColor:
                        const Color(
                      0xFF66552D,
                    ),
                    elevation: 0,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                        15,
                      ),
                    ),
                  ),
                  child: _busy
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child:
                              CircularProgressIndicator(
                            strokeWidth:
                                2.2,
                            color:
                                Colors.white,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .center,
                          children: <Widget>[
                            Icon(
                              Icons
                                  .verified_user_outlined,
                              size: 19,
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Text(
                              'Verify Email & Submit',
                              style:
                                  TextStyle(
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
        ),
      ),
    );
  }

  // ============================================================
  // VALIDATORS
  // ============================================================

  String? _requiredText(
    String? value,
  ) {
    if ((value ?? '')
        .trim()
        .isEmpty) {
      return 'Required.';
    }

    return null;
  }

  String? _emailValidator(
    String? value,
  ) {
    final String email =
        (value ?? '').trim();

    if (email.isEmpty) {
      return 'Email is required.';
    }

    if (!RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    ).hasMatch(email)) {
      return 'Enter a valid email.';
    }

    return null;
  }

  String? _phoneValidator(
    String? value,
  ) {
    final String phone =
        (value ?? '').trim();

    if (!RegExp(
      r'^09\d{9}$',
    ).hasMatch(phone)) {
      return 'Use 09XXXXXXXXX format.';
    }

    return null;
  }

  String? _licenseValidator(
    String? value,
  ) {
    final String license =
        (value ?? '')
            .trim()
            .toUpperCase();

    if (!RegExp(
      r'^[A-Z]\d{2}-\d{2}-\d{6}$',
    ).hasMatch(license)) {
      return 'Format: A12-34-567890';
    }

    return null;
  }

  String? _passwordValidator(
    String? value,
  ) {
    final String password =
        value ?? '';

    if (password.length < 8) {
      return 'At least 8 characters.';
    }

    if (!RegExp(
      r'[A-Z]',
    ).hasMatch(password)) {
      return 'Add an uppercase letter.';
    }

    if (!RegExp(
      r'[a-z]',
    ).hasMatch(password)) {
      return 'Add a lowercase letter.';
    }

    if (!RegExp(
      r'\d',
    ).hasMatch(password)) {
      return 'Add a number.';
    }

    if (!RegExp(
      r'[!@#$%^&*(),.?":{}|<>_\-+=]',
    ).hasMatch(password)) {
      return 'Add a symbol.';
    }

    return null;
  }
}