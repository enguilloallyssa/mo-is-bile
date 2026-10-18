import 'package:flutter/material.dart';

import 'buyer_messages.dart';
import 'buyer_notifications.dart';
import 'buyer_rewards.dart';
import 'buyer_shipping.dart';
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

  @override
  void initState() {
    super.initState();
    _firstName = TextEditingController(text: widget.profile.firstName);
    _lastName = TextEditingController(text: widget.profile.lastName);
    _contact = TextEditingController(text: widget.profile.contactNo);
    _address = TextEditingController(text: widget.profile.streetAddress);
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
