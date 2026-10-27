import 'package:flutter/material.dart';

import 'buyer_messages.dart';
import 'buyer_notifications.dart';
import 'buyer_recent_activity.dart';
import 'buyer_recent_orders.dart';
import 'buyer_rewards.dart';
import 'buyer_shipping.dart';
import 'models/buyer_address_model.dart';
import 'models/buyer_profile_model.dart';
import 'widgets/buyer_header.dart';

class BuyerAccount extends StatefulWidget {
  final ValueChanged<int>? onTabChanged;
  final BuyerProfileData profile;

  const BuyerAccount({
    super.key,
    this.onTabChanged,
    this.profile = const BuyerProfileData(),
  });

  @override
  State<BuyerAccount> createState() => _BuyerAccountState();
}

class _BuyerAccountState extends State<BuyerAccount> {
  static const Color _brand = Color(0xFFD98D08);
  static const Color _text = Color(0xFF211D17);
  static const Color _muted = Color(0xFF81786E);
  static const Color _border = Color(0xFFE8E0D5);

  final _formKey = GlobalKey<FormState>();
  final _complaintKey = GlobalKey<FormState>();

  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _contact;
  late final TextEditingController _address;
  final TextEditingController _complaint = TextEditingController();

  late List<BuyerAddress> _addresses;

  @override
  void initState() {
    super.initState();
    _firstName = TextEditingController(text: widget.profile.firstName);
    _lastName = TextEditingController(text: widget.profile.lastName);
    _contact = TextEditingController(text: widget.profile.contactNo);
    _address = TextEditingController(text: widget.profile.streetAddress);
    _addresses = <BuyerAddress>[
      BuyerAddress(
        id: 1,
        label: 'Home',
        recipientName: widget.profile.fullName,
        contactNo: widget.profile.contactNo,
        streetAddress: widget.profile.streetAddress,
        barangayName: widget.profile.barangayName,
        municipalityName: widget.profile.municipalityName,
        provinceName: widget.profile.provinceName,
        isDefault: true,
      ),
    ];
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _contact.dispose();
    _address.dispose();
    _complaint.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F1),
      body: Column(
        children: [
          BuyerHeader(
            pageTitle: 'My Account',
            cartCount: 0,
            onSearchTap: () => widget.onTabChanged?.call(1),
            onCartTap: () => widget.onTabChanged?.call(2),
            onProfileTap: () => widget.onTabChanged?.call(4),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 14, 12, 26),
              children: [
                _profileHero(),
                const SizedBox(height: 12),
                _buyerCenter(),
                const SizedBox(height: 12),
                _profileForm(),
                const SizedBox(height: 12),
                _addressBook(),
                const SizedBox(height: 12),
                _supportCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileHero() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF8E8), Color(0xFFFFEBC5)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE8CD98)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12472F0B),
            blurRadius: 22,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE0B868), width: 1.5),
            ),
            child: ClipOval(
              child: widget.profile.photo == null
                  ? Container(
                      color: const Color(0xFFFFF4DE),
                      child: const Icon(
                        Icons.person_rounded,
                        color: Color(0xFFB7760B),
                        size: 35,
                      ),
                    )
                  : Image.asset(
                      widget.profile.photo!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFFFFF4DE),
                        child: const Icon(
                          Icons.person_rounded,
                          color: Color(0xFFB7760B),
                          size: 35,
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.profile.fullName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _text,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .72),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'BUYER',
                        style: TextStyle(
                          color: Color(0xFF9B640A),
                          fontSize: 6.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  widget.profile.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 9,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _profileChip(Icons.location_on_outlined, widget.profile.municipalityName),
                    _profileChip(Icons.verified_user_outlined, 'Verified profile'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .72),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE7D5B2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: const Color(0xFFA66B0A)),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFF725D3A),
              fontSize: 7,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buyerCenter() {
    final items = <(IconData, String, String, Color, VoidCallback)>[
      (Icons.receipt_long_outlined, 'Recent Orders', 'Latest purchases', const Color(0xFFFFEED7), () => _push(const BuyerRecentOrders())),
      (Icons.history_rounded, 'Activity', 'Order updates', const Color(0xFFE8EEF7), () => _push(const BuyerRecentActivity())),
      (Icons.local_shipping_outlined, 'Shipping', 'Track parcels', const Color(0xFFE7F0F7), () => _push(const BuyerShipping())),
      (Icons.notifications_none_rounded, 'Updates', 'Order alerts', const Color(0xFFFFEED7), () => _push(const BuyerNotifications())),
      (Icons.card_giftcard_outlined, 'Rewards', 'Points & perks', const Color(0xFFF0EAF7), () => _push(const BuyerRewards())),
      (Icons.forum_outlined, 'Messages', 'Talk to sellers', const Color(0xFFE7F3EB), () => _push(const BuyerMessages())),
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Expanded(
                child: Text(
                  'Buyer Center',
                  style: TextStyle(
                    color: _text,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                'Quick access',
                style: TextStyle(
                  color: _muted,
                  fontSize: 8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              mainAxisExtent: 84,
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              return InkWell(
                onTap: item.$5,
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFCFAF7),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: const Color(0xFFEEE7DC)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: item.$4,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(item.$1, color: const Color(0xFF9E670D), size: 19),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.$2,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF433C34),
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.$3,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: _muted,
                                fontSize: 7,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _profileForm() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: _cardDecoration(),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Personal Information',
              style: TextStyle(
                color: _text,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Used as your default checkout and delivery information.',
              style: TextStyle(
                color: _muted,
                fontSize: 8.5,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: _field(_firstName, 'First Name')),
                const SizedBox(width: 9),
                Expanded(child: _field(_lastName, 'Last Name')),
              ],
            ),
            const SizedBox(height: 10),
            _readOnlyField(widget.profile.email, 'Email'),
            const SizedBox(height: 10),
            _field(_contact, 'Contact Number', keyboardType: TextInputType.phone),
            const SizedBox(height: 10),
            TextFormField(
              controller: _address,
              minLines: 2,
              maxLines: 3,
              style: const TextStyle(fontSize: 11),
              decoration: const InputDecoration(
                labelText: 'Street / Unit Address',
                prefixIcon: Icon(Icons.home_outlined, size: 19),
              ),
              validator: _required,
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F5EF),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: const Color(0xFFEAE2D7)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on_outlined, color: Color(0xFFA36A0A), size: 17),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      widget.profile.savedArea,
                      style: const TextStyle(
                        color: Color(0xFF685F55),
                        fontSize: 8.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saveProfile,
                icon: const Icon(Icons.save_outlined, size: 17),
                label: const Text('Save Profile Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _addressBook() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Delivery Addresses',
                      style: TextStyle(
                        color: _text,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Choose the address used during checkout.',
                      style: TextStyle(color: _muted, fontSize: 8.5),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: _addresses.length >= 5 ? null : () => _openAddressEditor(),
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (_addresses.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF8F4),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: _border),
              ),
              child: const Column(
                children: [
                  Icon(Icons.location_off_outlined, color: Color(0xFFB58A45)),
                  SizedBox(height: 7),
                  Text(
                    'No saved delivery addresses',
                    style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Add Home, Office, or another preferred location.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: _muted, fontSize: 8),
                  ),
                ],
              ),
            )
          else
            ..._addresses.map(_addressCard),
          if (_addresses.length >= 5) ...[
            const SizedBox(height: 7),
            const Text(
              'You have reached the maximum of 5 saved addresses.',
              style: TextStyle(color: _muted, fontSize: 8),
            ),
          ],
        ],
      ),
    );
  }

  Widget _addressCard(BuyerAddress address) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: address.isDefault
            ? const Color(0xFFFFFAF0)
            : const Color(0xFFFCFAF7),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: address.isDefault
              ? const Color(0xFFDCB665)
              : const Color(0xFFEEE7DC),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  address.label,
                  style: const TextStyle(
                    color: _text,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (address.isDefault)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEDC8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'ACTIVE',
                    style: TextStyle(
                      color: Color(0xFF94600A),
                      fontSize: 6.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            address.recipientName,
            style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 3),
          Text(
            '${address.streetAddress}\n${address.area}, Philippines\n${address.contactNo}',
            style: const TextStyle(
              color: _muted,
              fontSize: 8.5,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              if (!address.isDefault)
                TextButton.icon(
                  onPressed: () => _setDefaultAddress(address.id),
                  icon: const Icon(Icons.check_circle_outline, size: 14),
                  label: const Text('Use'),
                ),
              const Spacer(),
              IconButton(
                tooltip: 'Edit address',
                visualDensity: VisualDensity.compact,
                onPressed: () => _openAddressEditor(address),
                icon: const Icon(Icons.edit_outlined, size: 17),
              ),
              IconButton(
                tooltip: 'Delete address',
                visualDensity: VisualDensity.compact,
                onPressed: () => _removeAddress(address),
                icon: const Icon(Icons.delete_outline, size: 17, color: Color(0xFFB85353)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openAddressEditor([BuyerAddress? existing]) async {
    final formKey = GlobalKey<FormState>();
    final label = TextEditingController(text: existing?.label ?? 'Home');
    final recipient = TextEditingController(
      text: existing?.recipientName ?? widget.profile.fullName,
    );
    final phone = TextEditingController(
      text: existing?.contactNo ?? widget.profile.contactNo,
    );
    final street = TextEditingController(text: existing?.streetAddress ?? '');
    final barangay = TextEditingController(text: existing?.barangayName ?? '');
    final municipality = TextEditingController(text: existing?.municipalityName ?? '');
    final province = TextEditingController(text: existing?.provinceName ?? '');
    final postalCode = TextEditingController(text: existing?.postalCode ?? '');

    final result = await showModalBottomSheet<BuyerAddress>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            4,
            16,
            MediaQuery.viewInsetsOf(sheetContext).bottom + 20,
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    existing == null ? 'Add Delivery Address' : 'Edit Delivery Address',
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 14),
                  _addressField(label, 'Label', maxLength: 30),
                  const SizedBox(height: 9),
                  _addressField(recipient, 'Recipient Name', maxLength: 100),
                  const SizedBox(height: 9),
                  _addressField(
                    phone,
                    'Contact Number',
                    keyboardType: TextInputType.phone,
                    validator: _phoneValidator,
                  ),
                  const SizedBox(height: 9),
                  _addressField(street, 'House, unit, building, or street', maxLength: 500),
                  const SizedBox(height: 9),
                  _addressField(barangay, 'Barangay', maxLength: 100),
                  const SizedBox(height: 9),
                  _addressField(municipality, 'City / Municipality', maxLength: 100),
                  const SizedBox(height: 9),
                  _addressField(province, 'Province', maxLength: 100),
                  const SizedBox(height: 9),
                  _addressField(
                    postalCode,
                    'Postal Code (optional)',
                    required: false,
                    keyboardType: TextInputType.number,
                    maxLength: 10,
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton(
                    onPressed: () {
                      if (!(formKey.currentState?.validate() ?? false)) return;
                      Navigator.pop(
                        sheetContext,
                        BuyerAddress(
                          id: existing?.id ?? DateTime.now().millisecondsSinceEpoch,
                          label: label.text.trim(),
                          recipientName: recipient.text.trim(),
                          contactNo: phone.text.trim(),
                          streetAddress: street.text.trim(),
                          barangayName: barangay.text.trim(),
                          municipalityName: municipality.text.trim(),
                          provinceName: province.text.trim(),
                          postalCode: postalCode.text.trim(),
                          isDefault: existing?.isDefault ?? _addresses.isEmpty,
                        ),
                      );
                    },
                    child: Text(existing == null ? 'Save Address' : 'Update Address'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    label.dispose();
    recipient.dispose();
    phone.dispose();
    street.dispose();
    barangay.dispose();
    municipality.dispose();
    province.dispose();
    postalCode.dispose();

    if (result == null || !mounted) return;
    setState(() {
      final index = _addresses.indexWhere((item) => item.id == result.id);
      if (index < 0) {
        _addresses.add(result);
      } else {
        _addresses[index] = result;
      }
    });
    _toast(existing == null ? 'Address added.' : 'Address updated.');
  }

  Widget _addressField(
    TextEditingController controller,
    String label, {
    bool required = true,
    TextInputType? keyboardType,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      style: const TextStyle(fontSize: 11),
      decoration: InputDecoration(labelText: label, counterText: ''),
      validator: validator ?? (required ? _required : null),
    );
  }

  String? _phoneValidator(String? value) {
    final phone = (value ?? '').trim();
    if (phone.isEmpty) return 'This field is required.';
    if (!RegExp(r'^(09\d{9}|\+639\d{9})$').hasMatch(phone)) {
      return 'Use 09XXXXXXXXX or +639XXXXXXXXX.';
    }
    return null;
  }

  void _setDefaultAddress(int id) {
    setState(() {
      _addresses = _addresses
          .map((address) => address.copyWith(isDefault: address.id == id))
          .toList();
    });
    _toast('Active delivery address updated.');
  }

  Future<void> _removeAddress(BuyerAddress address) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete address?'),
        content: Text('Remove ${address.label} from your saved delivery addresses?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    setState(() {
      _addresses.removeWhere((item) => item.id == address.id);
      if (address.isDefault && _addresses.isNotEmpty) {
        _addresses[0] = _addresses[0].copyWith(isDefault: true);
      }
    });
    _toast('Address removed.');
  }

  Widget _supportCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: _cardDecoration(),
      child: Form(
        key: _complaintKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.support_agent_rounded, color: Color(0xFF3C6E91), size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Need help?',
                    style: TextStyle(
                      color: _text,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Send a concern and keep your support request in one place.',
              style: TextStyle(color: _muted, fontSize: 8.5, height: 1.4),
            ),
            const SizedBox(height: 11),
            TextFormField(
              controller: _complaint,
              minLines: 3,
              maxLines: 5,
              maxLength: 2000,
              style: const TextStyle(fontSize: 11),
              decoration: const InputDecoration(
                hintText: 'Describe your concern...',
                counterText: '',
              ),
              validator: _required,
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _sendComplaint,
                icon: const Icon(Icons.send_outlined, size: 16),
                label: const Text('Submit Concern'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 11),
      decoration: InputDecoration(labelText: label),
      validator: _required,
    );
  }

  Widget _readOnlyField(String value, String label) {
    return TextFormField(
      initialValue: value,
      readOnly: true,
      style: const TextStyle(color: Color(0xFF81786E), fontSize: 11),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.mail_outline_rounded, size: 19),
        fillColor: const Color(0xFFF6F3EE),
      ),
    );
  }

  BoxDecoration _cardDecoration() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A3C2A12),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      );

  String? _required(String? value) =>
      (value ?? '').trim().isEmpty ? 'This field is required.' : null;

  void _saveProfile() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    _toast('Profile changes saved locally for now.');
  }

  void _sendComplaint() {
    if (!(_complaintKey.currentState?.validate() ?? false)) return;
    _complaint.clear();
    _toast('Concern submitted locally. API connection will send it later.');
  }

  void _push(Widget page) {
    Navigator.push<void>(context, MaterialPageRoute(builder: (_) => page));
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }
}
