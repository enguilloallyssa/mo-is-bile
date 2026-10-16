import 'package:flutter/material.dart';

import 'models/buyer_profile_model.dart';
import 'buyer_messages.dart';
import 'buyer_notifications.dart';
import 'buyer_rewards.dart';
import 'buyer_shipping.dart';
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
  static const Color _gold = Color(0xFFC99128);
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
      backgroundColor: const Color(0xFFFBFAF8),
      body: Column(
        children: [
          BuyerHeader(
            pageTitle: 'Account',
            cartCount: 0,
            onSearchTap: () => widget.onTabChanged?.call(1),
            onCartTap: () => widget.onTabChanged?.call(2),
            onProfileTap: () {},
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(12, 14, 12, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _profileCard(),
                  const SizedBox(height: 12),
                  _quickLinks(),
                  const SizedBox(height: 12),
                  _supportCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileCard() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: _cardDecoration(),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ACCOUNT MANAGEMENT',
              style: TextStyle(
                color: Color(0xFFA8731F),
                fontSize: 7.5,
                fontWeight: FontWeight.w800,
                letterSpacing: .9,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Buyer Profile',
              style: TextStyle(
                color: Color(0xFF302A24),
                fontSize: 22,
                height: 1.05,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Your registered profile is reused as the default checkout information.',
              style: TextStyle(
                color: Color(0xFF91887D),
                fontSize: 8.5,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7E8),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE9D7B3)),
                  ),
                  alignment: Alignment.center,
                  child: widget.profile.photo == null
                      ? const Icon(
                          Icons.person_outline,
                          color: Color(0xFFB87912),
                          size: 30,
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(17),
                          child: Image.asset(
                            widget.profile.photo!,
                            width: 68,
                            height: 68,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.person_outline,
                              color: Color(0xFFB87912),
                              size: 30,
                            ),
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.profile.fullName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF3A342E),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.profile.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF91887D),
                          fontSize: 8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: () => _toast('Photo picker will be connected with the API later.'),
                        icon: const Icon(Icons.photo_camera_outlined, size: 14),
                        label: const Text('Change Photo'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF956415),
                          side: const BorderSide(color: Color(0xFFDCC28A)),
                          textStyle: const TextStyle(fontSize: 8),
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 17),
            LayoutBuilder(
              builder: (context, constraints) {
                final twoColumns = constraints.maxWidth >= 520;
                if (!twoColumns) {
                  return Column(
                    children: [
                      _field(_firstName, 'First Name'),
                      const SizedBox(height: 10),
                      _field(_lastName, 'Last Name'),
                    ],
                  );
                }
                return Row(
                  children: [
                    Expanded(child: _field(_firstName, 'First Name')),
                    const SizedBox(width: 10),
                    Expanded(child: _field(_lastName, 'Last Name')),
                  ],
                );
              },
            ),
            const SizedBox(height: 10),
            _readOnlyField(widget.profile.email, 'Email'),
            const SizedBox(height: 10),
            _field(
              _contact,
              'Contact Number',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _address,
              minLines: 3,
              maxLines: 3,
              style: const TextStyle(fontSize: 9.5),
              decoration: _inputDecoration('Street / Unit Address'),
              validator: _required,
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFCFBF8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFEEE7DC)),
              ),
              child: Text(
                'Saved area: ${widget.profile.savedArea}',
                style: const TextStyle(
                  color: Color(0xFF756D63),
                  fontSize: 8,
                  height: 1.45,
                ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 44,
              child: ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _gold,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save Account Changes',
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickLinks() {
    final items = [
      (Icons.local_shipping_outlined, 'Shipping', 'Track active parcels', () => _push(const BuyerShipping())),
      (Icons.notifications_none, 'Notifications', 'Order and delivery updates', () => _push(const BuyerNotifications())),
      (Icons.card_giftcard_outlined, 'Rewards', 'Points and delivered spend', () => _push(const BuyerRewards())),
      (Icons.forum_outlined, 'Messages', 'Talk directly to sellers', () => _push(const BuyerMessages())),
    ];

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Buyer Center',
            style: TextStyle(
              color: Color(0xFF302A24),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
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
              childAspectRatio: 1.75,
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              return InkWell(
                onTap: item.$4,
                borderRadius: BorderRadius.circular(13),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFCFBF8),
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: const Color(0xFFEEE7DC)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF4DE),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(item.$1, color: const Color(0xFFB97810), size: 18),
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
                                color: Color(0xFF433C35),
                                fontSize: 8.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.$3,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF91887D),
                                fontSize: 6.5,
                                height: 1.25,
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

  Widget _supportCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: _cardDecoration(),
      child: Form(
        key: _complaintKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Support / Complaint',
              style: TextStyle(
                color: Color(0xFF302A24),
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Describe your concern and our support flow can send it to the backend later.',
              style: TextStyle(color: Color(0xFF91887D), fontSize: 8, height: 1.45),
            ),
            const SizedBox(height: 11),
            TextFormField(
              controller: _complaint,
              minLines: 4,
              maxLines: 5,
              maxLength: 2000,
              style: const TextStyle(fontSize: 9.5),
              decoration: _inputDecoration('Your concern').copyWith(counterText: ''),
              validator: _required,
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 42,
              child: OutlinedButton.icon(
                onPressed: _sendComplaint,
                icon: const Icon(Icons.support_agent, size: 16),
                label: const Text('Submit Concern'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF956415),
                  side: const BorderSide(color: Color(0xFFD7B876)),
                  textStyle: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w700),
                ),
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
      style: const TextStyle(fontSize: 9.5),
      decoration: _inputDecoration(label),
      validator: _required,
    );
  }

  Widget _readOnlyField(String value, String label) {
    return TextFormField(
      initialValue: value,
      readOnly: true,
      style: const TextStyle(color: Color(0xFF91887D), fontSize: 9.5),
      decoration: _inputDecoration(label).copyWith(fillColor: const Color(0xFFF7F5F2), filled: true),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF62594E), fontSize: 8.5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
      isDense: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE4DDD3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE4DDD3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _gold),
      ),
    );
  }

  BoxDecoration _cardDecoration() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFEBE4DA)),
      );

  String? _required(String? value) => (value ?? '').trim().isEmpty ? 'This field is required.' : null;

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
