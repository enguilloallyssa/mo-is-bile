import 'package:flutter/material.dart';

import 'rider_register_screen.dart';

class LogisticsProvider {
  final int id;
  final String name;
  final String location;
  final String coverage;
  final int approvedRiders;

  const LogisticsProvider({
    required this.id,
    required this.name,
    required this.location,
    required this.coverage,
    required this.approvedRiders,
  });
}

class RiderLogisticsScreen extends StatefulWidget {
  final List<LogisticsProvider> providers;

  const RiderLogisticsScreen({
    super.key,
    this.providers = const [],
  });

  @override
  State<RiderLogisticsScreen> createState() => _RiderLogisticsScreenState();
}

class _RiderLogisticsScreenState extends State<RiderLogisticsScreen> {
  static const Color gold = Color(0xFFD48F08);
  static const Color background = Color(0xFFF7F4EE);
  static const Color ink = Color(0xFF211D17);
  static const Color muted = Color(0xFF81786C);

  final search = TextEditingController();

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  List<LogisticsProvider> get filtered {
    final q = search.text.trim().toLowerCase();
    if (q.isEmpty) return widget.providers;

    return widget.providers.where((provider) {
      return provider.name.toLowerCase().contains(q) ||
          provider.location.toLowerCase().contains(q) ||
          provider.coverage.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Choose Logistics',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 28),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'SARI RIDER NETWORK',
                    style: TextStyle(
                      color: Color(0xFFB97805),
                      fontSize: 9,
                      letterSpacing: 1.4,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 7),
                  const Text(
                    'Choose your Logistics team',
                    style: TextStyle(
                      color: ink,
                      fontSize: 27,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Rider applications are reviewed by Logistics. Choose an active provider, then submit your Rider requirements directly to their team.',
                    style: TextStyle(
                      color: muted,
                      fontSize: 11,
                      height: 1.55,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(17),
                      border: Border.all(color: const Color(0xFFE7E0D7)),
                    ),
                    child: TextField(
                      controller: search,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Search name, province, or city',
                        prefixIcon: const Icon(Icons.search, size: 19),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(11),
                          borderSide: const BorderSide(
                            color: Color(0xFFE3DDD4),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(11),
                          borderSide: const BorderSide(color: gold),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (filtered.isEmpty)
                    _emptyState()
                  else
                    ...filtered.map(_providerCard),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 42),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.85),
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: const Color(0xFFDDD3C4)),
      ),
      child: Column(
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFFFF5DF),
            ),
            child: const Icon(
              Icons.warehouse_outlined,
              color: Color(0xFFB67814),
            ),
          ),
          const SizedBox(height: 13),
          const Text(
            'No Logistics providers loaded yet',
            style: TextStyle(
              color: Color(0xFF322C25),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'This Flutter screen is ready for your Laravel provider API. '
            'Once connected, approved and active Logistics accounts will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF91887D),
              fontSize: 10.5,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }

  Widget _providerCard(LogisticsProvider provider) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE7E0D7)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.045),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 47,
                  height: 47,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF5DF),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(
                    Icons.warehouse_outlined,
                    color: Color(0xFFB67814),
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDF7F2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text(
                    '●  Active',
                    style: TextStyle(
                      color: Color(0xFF438461),
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              provider.name,
              style: const TextStyle(
                color: Color(0xFF29241E),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              provider.location,
              style: const TextStyle(
                color: Color(0xFF8E857B),
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _stat(
                    'Approved Riders',
                    provider.approvedRiders.toString(),
                  ),
                ),
                Expanded(
                  child: _stat(
                    'Coverage',
                    provider.coverage,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 45,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RiderRegisterScreen(
                        provider: provider,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF211F18),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                ),
                child: const Text(
                  'Apply to this Logistics  →',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFF9B9288),
            fontSize: 7.5,
            letterSpacing: .8,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF2B261F),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
