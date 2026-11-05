import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/registration_api.dart';
import '../widgets/sari_address_picker.dart';
import 'registration_pending_screen.dart';

class AccountRegistrationScreen extends StatefulWidget {
  final String role;

  const AccountRegistrationScreen({
    super.key,
    required this.role,
  });

  @override
  State<AccountRegistrationScreen> createState() =>
      _AccountRegistrationScreenState();
}

class _AccountRegistrationScreenState
    extends State<AccountRegistrationScreen> {
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

  static const Color _goldDark =
      Color(0xFFA96F06);

  static const Color _muted =
      Color(0xFFA7A7AF);

  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  final TextEditingController _firstName =
      TextEditingController();

  final TextEditingController _lastName =
      TextEditingController();

  final TextEditingController _middleInitial =
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

  final TextEditingController _municipalityCode =
      TextEditingController();

  final TextEditingController _barangay =
      TextEditingController();

  final TextEditingController _barangayCode =
      TextEditingController();

  final TextEditingController _street =
      TextEditingController();

  final TextEditingController _password =
      TextEditingController();

  final TextEditingController _confirmPassword =
      TextEditingController();

  final TextEditingController _otp =
      TextEditingController();

  String? _sex;

  PlatformFile? _profileImage;

  int _step = 0;

  bool _acceptTerms = false;
  bool _hidePassword = true;
  bool _hideConfirmation = true;

  bool _busy = false;

  bool get _isBuyer =>
      widget.role.toLowerCase() == 'buyer';

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _middleInitial.dispose();
    _email.dispose();
    _contact.dispose();
    _birthday.dispose();

    _province.dispose();
    _provinceCode.dispose();

    _municipality.dispose();
    _municipalityCode.dispose();

    _barangay.dispose();
    _barangayCode.dispose();

    _street.dispose();

    _password.dispose();
    _confirmPassword.dispose();
    _otp.dispose();

    super.dispose();
  }

  // ============================================================
  // DATE
  // ============================================================

  Future<void> _pickBirthday() async {
    final DateTime today =
        DateTime.now();

    final DateTime maximum =
        DateTime(
      today.year - 18,
      today.month,
      today.day,
    );

    final DateTime? result =
        await showDatePicker(
      context: context,
      initialDate: DateTime(
        maximum.year - 3,
        maximum.month,
        maximum.day,
      ),
      firstDate:
          DateTime(1900),
      lastDate: maximum,
    );

    if (result == null) {
      return;
    }

    setState(() {
      _birthday.text =
          '${result.year.toString().padLeft(4, '0')}-'
          '${result.month.toString().padLeft(2, '0')}-'
          '${result.day.toString().padLeft(2, '0')}';
    });
  }

  int? _calculateAge() {
    final DateTime? birthday =
        DateTime.tryParse(
      _birthday.text,
    );

    if (birthday == null) {
      return null;
    }

    final DateTime now =
        DateTime.now();

    int age =
        now.year - birthday.year;

    if (now.month < birthday.month ||
        (now.month ==
                birthday.month &&
            now.day <
                birthday.day)) {
      age--;
    }

    return age;
  }

  // ============================================================
  // PROFILE IMAGE
  // ============================================================

  Future<void> _pickProfileImage() async {
    final FilePickerResult? result =
        await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions:
          const <String>[
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

    final PlatformFile file =
        result.files.single;

    if (file.path == null) {
      _message(
        'The selected photo cannot be read.',
      );

      return;
    }

    if (file.size >
        5 * 1024 * 1024) {
      _message(
        'Profile image must not exceed 5 MB.',
      );

      return;
    }

    setState(() {
      _profileImage = file;
    });
  }

  // ============================================================
  // STEP VALIDATION
  // ============================================================

  bool _validatePersonal() {
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

    if ((_calculateAge() ?? 0) <
        18) {
      _message(
        'You must be at least 18 years old.',
      );

      return false;
    }

    if (_provinceCode.text
            .trim()
            .isEmpty ||
        _municipalityCode.text
            .trim()
            .isEmpty ||
        _barangayCode.text
            .trim()
            .isEmpty) {
      _message(
        'Please select your complete address.',
      );

      return false;
    }

    return true;
  }

  bool _validateSecurity() {
    if (_profileImage == null) {
      _message(
        'Please select a profile photo.',
      );

      return false;
    }

    final String password =
        _password.text;

    if (password.length < 8) {
      _message(
        'Password must contain at least 8 characters.',
      );

      return false;
    }

    if (!RegExp(
      r'[A-Z]',
    ).hasMatch(password)) {
      _message(
        'Password must contain an uppercase letter.',
      );

      return false;
    }

    if (!RegExp(
      r'[a-z]',
    ).hasMatch(password)) {
      _message(
        'Password must contain a lowercase letter.',
      );

      return false;
    }

    if (!RegExp(
      r'\d',
    ).hasMatch(password)) {
      _message(
        'Password must contain a number.',
      );

      return false;
    }

    if (!RegExp(
      r'[^A-Za-z0-9]',
    ).hasMatch(password)) {
      _message(
        'Password must contain a symbol.',
      );

      return false;
    }

    if (_password.text !=
        _confirmPassword.text) {
      _message(
        'Passwords do not match.',
      );

      return false;
    }

    if (!_acceptTerms) {
      _message(
        'Please accept the Terms and Privacy Policy.',
      );

      return false;
    }

    return true;
  }

  // ============================================================
  // REGISTRATION
  // ============================================================

  Map<String, String> _fields() {
    return <String, String>{
      'last_name':
          _lastName.text.trim(),

      'first_name':
          _firstName.text.trim(),

      'middle_initial':
          _middleInitial.text
              .trim()
              .toUpperCase(),

      'sex':
          _sex ?? '',

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

      'password':
          _password.text,

      'password_confirmation':
          _confirmPassword.text,

      'terms': '1',
    };
  }

  Future<void> _continue() async {
    if (_busy) {
      return;
    }

    if (_step == 0) {
      if (!_validatePersonal()) {
        return;
      }

      setState(() {
        _step = 1;
      });

      return;
    }

    if (_step == 1) {
      if (!_validateSecurity()) {
        return;
      }

      await _submitRegistration();

      return;
    }

    if (_step == 2) {
      await _verifyOtp();
    }
  }

  Future<void>
      _submitRegistration() async {
    if (!_isBuyer) {
      _message(
        'This account type is not connected to the mobile registration API yet.',
      );

      return;
    }

    setState(() {
      _busy = true;
    });

    try {
      await RegistrationApi
          .instance
          .registerBuyer(
        fields: _fields(),
        profileImage:
            _profileImage!,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _step = 2;
      });

      _message(
        'Registration saved. Check your email for the verification code.',
      );
    } on RegistrationApiException
        catch (error) {
      _message(
        error.message,
      );
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

  Future<void> _resendOtp() async {
    if (_busy) {
      return;
    }

    setState(() {
      _busy = true;
    });

    try {
      final String response =
          await RegistrationApi
              .instance
              .sendOtp(
        email:
            _email.text
                .trim()
                .toLowerCase(),
        role: 'buyer',
      );

      _message(response);
    } on RegistrationApiException
        catch (error) {
      _message(
        error.message,
      );
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  Future<void> _verifyOtp() async {
    FocusScope.of(context)
        .unfocus();

    final String code =
        _otp.text.trim();

    if (!RegExp(
      r'^\d{6}$',
    ).hasMatch(code)) {
      _message(
        'Enter the complete 6-digit verification code.',
      );

      return;
    }

    setState(() {
      _busy = true;
    });

    try {
      final Map<String, dynamic> response =
          await RegistrationApi
              .instance
              .verifyOtp(
        email:
            _email.text
                .trim()
                .toLowerCase(),
        role: 'buyer',
        otp: code,
      );

      if (!mounted) {
        return;
      }

      _message(
        response['message']
                ?.toString() ??
            'Email verified successfully.',
      );

      Navigator.of(context)
          .pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (_) =>
              RegistrationPendingScreen(
            role: 'buyer',
            email:
                _email.text
                    .trim()
                    .toLowerCase(),
            reviewerName: 'SARI',
          ),
        ),
        (
          Route<dynamic> route,
        ) =>
            false,
      );
    } on RegistrationApiException
        catch (error) {
      _message(
        error.message,
      );
    } catch (error) {
      _message(
        'Unable to verify code: $error',
      );
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  void _back() {
    if (_busy) {
      return;
    }

    if (_step == 0) {
      Navigator.pop(context);

      return;
    }

    setState(() {
      _step--;
    });
  }

  // ============================================================
  // VALIDATORS
  // ============================================================

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

  String? _nameValidator(
    String? value,
  ) {
    final String text =
        (value ?? '').trim();

    if (text.length < 2) {
      return 'Use at least 2 characters.';
    }

    if (!RegExp(
      r"^[A-Za-zÀ-ÖØ-öø-ÿÑñ\s.'-]+$",
    ).hasMatch(text)) {
      return 'Enter a valid name.';
    }

    return null;
  }

  String? _emailValidator(
    String? value,
  ) {
    final String email =
        (value ?? '').trim();

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

  // ============================================================
  // UI HELPERS
  // ============================================================

  InputDecoration _decoration({
    required String label,
    IconData? icon,
    String? hint,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon == null
          ? null
          : Icon(
              icon,
              size: 19,
              color: _muted,
            ),
      suffixIcon: suffix,
      labelStyle:
          const TextStyle(
        color: _muted,
      ),
      hintStyle:
          const TextStyle(
        color: Color(
          0xFF72727A,
        ),
      ),
      filled: true,
      fillColor: _field,
      enabledBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(
          14,
        ),
        borderSide:
            const BorderSide(
          color: _border,
        ),
      ),
      focusedBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(
          14,
        ),
        borderSide:
            const BorderSide(
          color: _gold,
          width: 1.4,
        ),
      ),
      errorBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(
          14,
        ),
        borderSide:
            const BorderSide(
          color:
              Colors.redAccent,
        ),
      ),
      focusedErrorBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(
          14,
        ),
        borderSide:
            const BorderSide(
          color:
              Colors.redAccent,
        ),
      ),
    );
  }

  Widget _stepIndicator() {
    return Row(
      children:
          List<Widget>.generate(
        3,
        (int index) {
          final bool completed =
              index < _step;

          final bool current =
              index == _step;

          return Expanded(
            child: Row(
              children: <Widget>[
                Container(
                  width: 29,
                  height: 29,
                  alignment:
                      Alignment.center,
                  decoration:
                      BoxDecoration(
                    color: completed
                        ? const Color(
                            0xFF276C4B,
                          )
                        : current
                            ? _gold
                            : _field,
                    shape:
                        BoxShape.circle,
                    border:
                        Border.all(
                      color: current ||
                              completed
                          ? Colors
                              .transparent
                          : _border,
                    ),
                  ),
                  child: completed
                      ? const Icon(
                          Icons
                              .check_rounded,
                          color:
                              Colors.white,
                          size: 16,
                        )
                      : Text(
                          '${index + 1}',
                          style:
                              TextStyle(
                            color: current
                                ? Colors
                                    .black
                                : _muted,
                            fontSize: 10,
                            fontWeight:
                                FontWeight
                                    .w800,
                          ),
                        ),
                ),

                if (index < 2)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 7,
                      ),
                      color: completed
                          ? const Color(
                              0xFF276C4B,
                            )
                          : _border,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _personalStep() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: <Widget>[
        _title(
          'Tell us about yourself',
          'Your details will be used for your Buyer account and deliveries.',
        ),

        const SizedBox(
          height: 18,
        ),

        TextFormField(
          controller:
              _firstName,
          textCapitalization:
              TextCapitalization.words,
          style:
              const TextStyle(
            color: Colors.white,
          ),
          decoration:
              _decoration(
            label: 'First Name',
            icon:
                Icons.person_outline,
          ),
          validator:
              _nameValidator,
        ),

        _gap(),

        TextFormField(
          controller:
              _lastName,
          textCapitalization:
              TextCapitalization.words,
          style:
              const TextStyle(
            color: Colors.white,
          ),
          decoration:
              _decoration(
            label: 'Last Name',
            icon:
                Icons.person_outline,
          ),
          validator:
              _nameValidator,
        ),

        _gap(),

        TextFormField(
          controller:
              _middleInitial,
          maxLength: 1,
          inputFormatters:
              <TextInputFormatter>[
            FilteringTextInputFormatter
                .allow(
              RegExp(
                r'[A-Za-z]',
              ),
            ),
          ],
          textCapitalization:
              TextCapitalization
                  .characters,
          style:
              const TextStyle(
            color: Colors.white,
          ),
          decoration:
              _decoration(
            label:
                'Middle Initial',
            hint: 'Optional',
          ).copyWith(
            counterText: '',
          ),
        ),

        _gap(),

        DropdownButtonFormField<String>(
          value: _sex,
          dropdownColor:
              _surface,
          style:
              const TextStyle(
            color: Colors.white,
          ),
          decoration:
              _decoration(
            label: 'Sex',
            icon:
                Icons.wc_outlined,
          ),
          items:
              const <DropdownMenuItem<
                  String>>[
            DropdownMenuItem<String>(
              value: 'Male',
              child:
                  Text('Male'),
            ),
            DropdownMenuItem<String>(
              value: 'Female',
              child:
                  Text('Female'),
            ),
          ],
          onChanged:
              (
            String? value,
          ) {
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
            label: 'Birthday',
            icon: Icons
                .calendar_month_outlined,
          ),
          validator:
              _required,
        ),

        _gap(),

        TextFormField(
          controller:
              _email,
          keyboardType:
              TextInputType
                  .emailAddress,
          style:
              const TextStyle(
            color: Colors.white,
          ),
          decoration:
              _decoration(
            label: 'Email Address',
            icon:
                Icons.mail_outline,
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
            label: 'Mobile Number',
            hint:
                '09XXXXXXXXX',
            icon:
                Icons.phone_outlined,
          ).copyWith(
            counterText: '',
          ),
          validator:
              _phoneValidator,
        ),

        const SizedBox(
          height: 17,
        ),

        const Text(
          'Delivery Address',
          style: TextStyle(
            color:
                Colors.white,
            fontSize: 14,
            fontWeight:
                FontWeight.w800,
          ),
        ),

        const SizedBox(
          height: 12,
        ),

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

        TextFormField(
          controller:
              _street,
          textCapitalization:
              TextCapitalization.words,
          minLines: 2,
          maxLines: 3,
          style:
              const TextStyle(
            color: Colors.white,
          ),
          decoration:
              _decoration(
            label: 'Street Address',
            icon:
                Icons.home_outlined,
          ),
          validator:
              _required,
        ),
      ],
    );
  }

  Widget _securityStep() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: <Widget>[
        _title(
          'Secure your Buyer account',
          'Add your profile photo and create a secure password.',
        ),

        const SizedBox(
          height: 20,
        ),

        Center(
          child: InkWell(
            onTap:
                _pickProfileImage,
            borderRadius:
                BorderRadius.circular(
              22,
            ),
            child: Container(
              width: 125,
              height: 125,
              alignment:
                  Alignment.center,
              decoration:
                  BoxDecoration(
                color: _field,
                borderRadius:
                    BorderRadius.circular(
                  22,
                ),
                border:
                    Border.all(
                  color:
                      _profileImage ==
                              null
                          ? _border
                          : _gold,
                  width:
                      _profileImage ==
                              null
                          ? 1
                          : 1.5,
                ),
              ),
              child:
                  _profileImage ==
                          null
                      ? const Column(
                          mainAxisSize:
                              MainAxisSize
                                  .min,
                          children: <Widget>[
                            Icon(
                              Icons
                                  .camera_alt_outlined,
                              color:
                                  _gold,
                              size: 30,
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Text(
                              'Add Photo',
                              style:
                                  TextStyle(
                                color:
                                    _muted,
                                fontSize:
                                    9,
                              ),
                            ),
                          ],
                        )
                      : const Icon(
                          Icons
                              .check_circle_rounded,
                          color:
                              Color(
                            0xFF69BF8A,
                          ),
                          size: 44,
                        ),
            ),
          ),
        ),

        if (_profileImage != null) ...[
          const SizedBox(
            height: 8,
          ),

          Center(
            child: Text(
              _profileImage!.name,
              maxLines: 1,
              overflow:
                  TextOverflow.ellipsis,
              style:
                  const TextStyle(
                color: _muted,
                fontSize: 9,
              ),
            ),
          ),
        ],

        const SizedBox(
          height: 22,
        ),

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
            label: 'Password',
            icon:
                Icons.lock_outline,
            suffix:
                IconButton(
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
        ),

        _gap(),

        TextFormField(
          controller:
              _confirmPassword,
          obscureText:
              _hideConfirmation,
          style:
              const TextStyle(
            color: Colors.white,
          ),
          decoration:
              _decoration(
            label:
                'Confirm Password',
            icon:
                Icons.lock_outline,
            suffix:
                IconButton(
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
        ),

        const SizedBox(
          height: 10,
        ),

        _passwordRules(),

        const SizedBox(
          height: 14,
        ),

        CheckboxListTile(
          contentPadding:
              EdgeInsets.zero,
          value:
              _acceptTerms,
          activeColor: _gold,
          checkColor:
              Colors.black,
          onChanged:
              (
            bool? value,
          ) {
            setState(() {
              _acceptTerms =
                  value ?? false;
            });
          },
          title:
              const Text(
            'I agree to the Terms of Service and Privacy Policy.',
            style:
                TextStyle(
              color:
                  Colors.white,
              fontSize: 10,
            ),
          ),
        ),
      ],
    );
  }

  Widget _otpStep() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: <Widget>[
        _title(
          'Verify your email',
          'We sent a verification code to ${_email.text.trim()}.',
        ),

        const SizedBox(
          height: 24,
        ),

        TextFormField(
          controller:
              _otp,
          keyboardType:
              TextInputType.number,
          textAlign:
              TextAlign.center,
          maxLength: 6,
          inputFormatters:
              <TextInputFormatter>[
            FilteringTextInputFormatter
                .digitsOnly,
          ],
          style:
              const TextStyle(
            color: Colors.white,
            fontSize: 27,
            letterSpacing: 11,
            fontWeight:
                FontWeight.w900,
          ),
          decoration:
              _decoration(
            label:
                '6-digit verification code',
            icon:
                Icons.verified_outlined,
          ).copyWith(
            counterText: '',
          ),
        ),

        const SizedBox(
          height: 14,
        ),

        Container(
          padding:
              const EdgeInsets.all(
            13,
          ),
          decoration:
              BoxDecoration(
            color: const Color(
              0xFF1D2922,
            ),
            borderRadius:
                BorderRadius.circular(
              14,
            ),
            border: Border.all(
              color: const Color(
                0xFF355542,
              ),
            ),
          ),
          child: const Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: <Widget>[
              Icon(
                Icons
                    .security_rounded,
                color:
                    Color(
                  0xFF79C58E,
                ),
                size: 18,
              ),
              SizedBox(
                width: 9,
              ),
              Expanded(
                child: Text(
                  'The verification is handled through the Laravel mobile API. No browser session or CSRF token is required.',
                  style:
                      TextStyle(
                    color:
                        Color(
                      0xFFB8D8C1,
                    ),
                    fontSize: 9,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(
          height: 14,
        ),

        Center(
          child: TextButton(
            onPressed:
                _busy
                    ? null
                    : _resendOtp,
            child: const Text(
              'Resend verification code',
            ),
          ),
        ),
      ],
    );
  }

  Widget _passwordRules() {
    final String value =
        _password.text;

    final List<
        ({
          String label,
          bool valid,
        })> rules = [
      (
        label:
            'At least 8 characters',
        valid:
            value.length >= 8,
      ),
      (
        label:
            'Uppercase letter',
        valid:
            RegExp(
          r'[A-Z]',
        ).hasMatch(value),
      ),
      (
        label:
            'Lowercase letter',
        valid:
            RegExp(
          r'[a-z]',
        ).hasMatch(value),
      ),
      (
        label: 'Number',
        valid:
            RegExp(
          r'\d',
        ).hasMatch(value),
      ),
      (
        label: 'Symbol',
        valid:
            RegExp(
          r'[^A-Za-z0-9]',
        ).hasMatch(value),
      ),
    ];

    return Wrap(
      spacing: 7,
      runSpacing: 7,
      children:
          rules.map(
        (rule) {
          return Container(
            padding:
                const EdgeInsets
                    .symmetric(
              horizontal: 9,
              vertical: 6,
            ),
            decoration:
                BoxDecoration(
              color: rule.valid
                  ? const Color(
                      0xFF1D2922,
                    )
                  : _field,
              borderRadius:
                  BorderRadius.circular(
                20,
              ),
              border:
                  Border.all(
                color: rule.valid
                    ? const Color(
                        0xFF355542,
                      )
                    : _border,
              ),
            ),
            child: Row(
              mainAxisSize:
                  MainAxisSize.min,
              children: <Widget>[
                Icon(
                  rule.valid
                      ? Icons
                          .check_rounded
                      : Icons
                          .circle_outlined,
                  size: 12,
                  color: rule.valid
                      ? const Color(
                          0xFF79C58E,
                        )
                      : _muted,
                ),
                const SizedBox(
                  width: 5,
                ),
                Text(
                  rule.label,
                  style:
                      TextStyle(
                    color: rule.valid
                        ? const Color(
                            0xFFB8D8C1,
                          )
                        : _muted,
                    fontSize: 8,
                  ),
                ),
              ],
            ),
          );
        },
      ).toList(),
    );
  }

  Widget _title(
    String title,
    String subtitle,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style:
              const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight:
                FontWeight.w900,
          ),
        ),

        const SizedBox(
          height: 6,
        ),

        Text(
          subtitle,
          style:
              const TextStyle(
            color: _muted,
            fontSize: 10,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _gap() {
    return const SizedBox(
      height: 13,
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

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    if (!_isBuyer) {
      return Scaffold(
        backgroundColor:
            _background,
        appBar: AppBar(
          backgroundColor:
              _background,
          foregroundColor:
              Colors.white,
          title:
              const Text(
            'Registration',
          ),
        ),
        body:
            const Center(
          child: Padding(
            padding:
                EdgeInsets.all(
              28,
            ),
            child: Text(
              'This registration type is not connected to the mobile Laravel API yet.',
              textAlign:
                  TextAlign.center,
              style:
                  TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor:
          _background,
      appBar: AppBar(
        backgroundColor:
            _background,
        foregroundColor:
            Colors.white,
        surfaceTintColor:
            Colors.transparent,
        leading: IconButton(
          onPressed:
              _back,
          icon:
              const Icon(
            Icons
                .arrow_back_rounded,
          ),
        ),
        title:
            const Text(
          'Create Buyer Account',
          style: TextStyle(
            fontSize: 16,
            fontWeight:
                FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child:
            SingleChildScrollView(
          padding:
              const EdgeInsets.fromLTRB(
            16,
            10,
            16,
            30,
          ),
          child: Center(
            child:
                ConstrainedBox(
              constraints:
                  const BoxConstraints(
                maxWidth: 600,
              ),
              child: Form(
                key:
                    _formKey,
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .stretch,
                  children: <Widget>[
                    _stepIndicator(),

                    const SizedBox(
                      height: 22,
                    ),

                    Container(
                      padding:
                          const EdgeInsets.all(
                        18,
                      ),
                      decoration:
                          BoxDecoration(
                        color:
                            _surface,
                        borderRadius:
                            BorderRadius.circular(
                          22,
                        ),
                        border:
                            Border.all(
                          color:
                              _border,
                        ),
                      ),
                      child: AnimatedSwitcher(
                        duration:
                            const Duration(
                          milliseconds:
                              220,
                        ),
                        child: KeyedSubtree(
                          key:
                              ValueKey<int>(
                            _step,
                          ),
                          child: switch (_step) {
                            0 =>
                              _personalStep(),
                            1 =>
                              _securityStep(),
                            _ =>
                              _otpStep(),
                          },
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    SizedBox(
                      height: 53,
                      child:
                          FilledButton(
                        onPressed:
                            _busy
                                ? null
                                : _continue,
                        style:
                            FilledButton
                                .styleFrom(
                          backgroundColor:
                              _gold,
                          foregroundColor:
                              Colors.black,
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                              15,
                            ),
                          ),
                        ),
                        child: _busy
                            ? const SizedBox(
                                width:
                                    21,
                                height:
                                    21,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth:
                                      2,
                                  color:
                                      Colors.white,
                                ),
                              )
                            : Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    _step ==
                                            0
                                        ? 'Continue'
                                        : _step ==
                                                1
                                            ? 'Submit & Send OTP'
                                            : 'Verify Account',
                                    style:
                                        const TextStyle(
                                      fontWeight:
                                          FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 7,
                                  ),
                                  Icon(
                                    _step ==
                                            2
                                        ? Icons
                                            .verified_rounded
                                        : Icons
                                            .arrow_forward_rounded,
                                  ),
                                ],
                              ),
                      ),
                    ),

                    const SizedBox(
                      height: 13,
                    ),

                    Center(
                      child: Text(
                        'SARI • Secure mobile registration',
                        style:
                            TextStyle(
                          color:
                              _muted.withOpacity(
                            .65,
                          ),
                          fontSize: 8,
                          letterSpacing:
                              .6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}