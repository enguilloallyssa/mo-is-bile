
import 'package:flutter/material.dart';

import '../services/sari_live_data.dart';
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
  static const Color gold = Color(0xFFD9950B);
  static const Color dark = Color(0xFF292929);
  static const Color canvas = Color(0xFFF4F5F7);
  static const Color border = Color(0xFFE6E8EC);
  static const Color muted = Color(0xFF818A97);

  Map<String, dynamic>? _user;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAccount();
  }

  String _value(dynamic value, [String fallback = '']) {
    if (value == null) return fallback;
    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }

  Future<void> _loadAccount() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response =
          await SariLiveData.instance.currentAccount();

      final payload = response['data'];

      if (payload is! Map) {
        throw const FormatException(
          'Invalid account response from Laravel.',
        );
      }

      final user = payload['user'];

      if (user is! Map) {
        throw const FormatException(
          'Buyer account information is missing.',
        );
      }

      final data = Map<String, dynamic>.from(user);

      if (_value(data['role']) != 'buyer') {
        throw const FormatException(
          'The authenticated account is not a Buyer.',
        );
      }

      if (!mounted) return;

      setState(() {
        _user = data;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  void _navigate(int index) {
    widget.onTabChanged?.call(index);
  }

  void _unavailable(String feature) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            '$feature is not yet available through '
            'the Laravel mobile API.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Widget _card({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(16),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _sectionHeader(
    IconData icon,
    String title,
  ) {
    return Row(
      children: [
        Icon(icon, color: gold, size: 20),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: dark,
            ),
          ),
        ),
      ],
    );
  }

  Widget _profileHero() {
    final name = _value(
      _user?['name'],
      'SARI Buyer',
    );

    final email = _value(
      _user?['email'],
      'No email available',
    );

    final status = _value(
      _user?['account_status'],
      'Unknown',
    );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFF9ED),
            Color(0xFFFFECC7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFECD4A5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFE5BE70),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: gold,
                  size: 36,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: dark,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      email,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: muted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 17),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _badge(
                'BUYER ACCOUNT',
                Icons.verified_user_outlined,
              ),
              _badge(
                status.toUpperCase(),
                Icons.circle,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _badge(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFEADBBE),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: gold, size: 12),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF99670D),
              fontSize: 9,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _personalInformation() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            Icons.badge_outlined,
            'Personal Information',
          ),
          const SizedBox(height: 14),
          const Divider(color: border),
          _infoRow(
            'Full Name',
            _value(
              _user?['name'],
              'Not available',
            ),
          ),
          _infoRow(
            'Email Address',
            _value(
              _user?['email'],
              'Not available',
            ),
          ),
          _infoRow(
            'Contact Number',
            _value(
              _user?['contact_number'],
              'Not available',
            ),
          ),
          _infoRow(
            'Account ID',
            _value(
              _user?['id'],
              'Not available',
            ),
          ),
          _infoRow(
            'Account Status',
            _value(
              _user?['account_status'],
              'Unknown',
            ).toUpperCase(),
          ),
          const SizedBox(height: 12),
          const Divider(color: border),
          const SizedBox(height: 8),
          const Text(
            'Your account information is retrieved '
            'from the SARI Laravel database.',
            style: TextStyle(
              color: muted,
              fontSize: 11,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 11,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: muted,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 5),
          SelectableText(
            value,
            style: const TextStyle(
              color: dark,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickActions() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            Icons.dashboard_customize_outlined,
            'Buyer Center',
          ),
          const SizedBox(height: 12),
          _menuItem(
            Icons.shopping_bag_outlined,
            'My Orders',
            'View your purchases and order status',
            () => _navigate(3),
          ),
          const Divider(color: border, height: 1),
          _menuItem(
            Icons.storefront_outlined,
            'Browse Products',
            'Discover products from SARI sellers',
            () => _navigate(1),
          ),
          const Divider(color: border, height: 1),
          _menuItem(
            Icons.shopping_cart_outlined,
            'My Cart',
            'View your local shopping cart',
            () => _navigate(2),
          ),
          const Divider(color: border, height: 1),
          _menuItem(
            Icons.notifications_none_rounded,
            'Notifications',
            'View notifications in the Buyer UI',
            () => _navigate(5),
          ),
          const Divider(color: border, height: 1),
          _menuItem(
            Icons.chat_bubble_outline_rounded,
            'Messages',
            'Open the Buyer messaging screen',
            () => _navigate(6),
          ),
        ],
      ),
    );
  }

  Widget _menuItem(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 13,
        ),
        child: Row(
          children: [
            Container(
              width: 41,
              height: 41,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4DF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: gold,
                size: 21,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: dark,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: muted,
                      fontSize: 10,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: muted,
              size: 21,
            ),
          ],
        ),
      ),
    );
  }

  Widget _accountSettings() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            Icons.settings_outlined,
            'Account Settings',
          ),
          const SizedBox(height: 12),
          _menuItem(
            Icons.edit_outlined,
            'Edit Profile',
            'Requires the mobile profile update API',
            () => _unavailable('Edit Profile'),
          ),
          const Divider(color: border, height: 1),
          _menuItem(
            Icons.location_on_outlined,
            'Manage Addresses',
            'Requires the mobile address API',
            () => _unavailable('Manage Addresses'),
          ),
          const Divider(color: border, height: 1),
          _menuItem(
            Icons.lock_outline_rounded,
            'Change Password',
            'Requires the mobile password update API',
            () => _unavailable('Change Password'),
          ),
        ],
      ),
    );
  }

  Widget _errorState() {
    return _card(
      child: Column(
        children: [
          const Icon(
            Icons.wifi_off_rounded,
            size: 45,
            color: muted,
          ),
          const SizedBox(height: 15),
          const Text(
            'Unable to Load Account',
            style: TextStyle(
              color: dark,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _error ?? 'Unknown error',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: muted,
              fontSize: 12,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 17),
          ElevatedButton.icon(
            onPressed: _loadAccount,
            icon: const Icon(
              Icons.refresh_rounded,
            ),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: gold,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: canvas,
      body: Column(
        children: [
          BuyerHeader(
            pageTitle: 'My Account',
            cartCount: 0,
            onSearchTap: () => _navigate(1),
            onCartTap: () => _navigate(2),
            onProfileTap: () => _navigate(4),
          ),
          Expanded(
            child: RefreshIndicator(
              color: gold,
              onRefresh: _loadAccount,
              child: ListView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  14, 18, 14, 28,
                ),
                children: [
                  const Text(
                    'ACCOUNT MANAGEMENT',
                    style: TextStyle(
                      color: gold,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'My Account',
                    style: TextStyle(
                      color: dark,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Manage your SARI Buyer account.',
                    style: TextStyle(
                      color: muted,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 20),

                  if (_loading)
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 70,
                      ),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: gold,
                        ),
                      ),
                    )
                  else if (_error != null)
                    _errorState()
                  else if (_user != null) ...[
                    _profileHero(),
                    const SizedBox(height: 14),
                    _personalInformation(),
                    const SizedBox(height: 14),
                    _quickActions(),
                    const SizedBox(height: 14),
                    _accountSettings(),
                  ],

                  const SizedBox(height: 22),
                  const Center(
                    child: Text(
                      'SARI • Elevated Everyday',
                      style: TextStyle(
                        color: muted,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
