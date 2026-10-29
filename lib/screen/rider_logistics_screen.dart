import 'package:flutter/material.dart';

import '../services/registration_api.dart';
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

  factory LogisticsProvider.fromMap(
    Map<String, Object> data,
  ) {
    return LogisticsProvider(
      id: _toInt(data['id']),
      name: _toText(
        data['name'],
        fallback: 'Logistics Provider',
      ),
      location: _toText(
        data['location'],
        fallback: 'SARI Logistics network',
      ),
      coverage: _toText(
        data['coverage'],
        fallback: 'Philippines',
      ),
      approvedRiders: _toInt(
        data['approvedRiders'],
      ),
    );
  }

  static int _toInt(Object? value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(
          value?.toString().replaceAll(',', '') ?? '',
        ) ??
        0;
  }

  static String _toText(
    Object? value, {
    required String fallback,
  }) {
    final String text = value?.toString().trim() ?? '';

    return text.isEmpty ? fallback : text;
  }
}

class RiderLogisticsScreen extends StatefulWidget {
  const RiderLogisticsScreen({
    super.key,
  });

  @override
  State<RiderLogisticsScreen> createState() =>
      _RiderLogisticsScreenState();
}

class _RiderLogisticsScreenState
    extends State<RiderLogisticsScreen> {
  static const Color _background = Color(0xFF0A0A0C);
  static const Color _surface = Color(0xFF18181C);
  static const Color _fieldColor = Color(0xFF222226);
  static const Color _border = Color(0xFF37373D);
  static const Color _gold = Color(0xFFD4A62A);
  static const Color _muted = Color(0xFFAAAAB2);

  final TextEditingController _searchController =
      TextEditingController();

  List<LogisticsProvider> _providers =
      <LogisticsProvider>[];

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProviders();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<LogisticsProvider> get _filteredProviders {
    final String query =
        _searchController.text.trim().toLowerCase();

    if (query.isEmpty) {
      return _providers;
    }

    return _providers.where(
      (LogisticsProvider provider) {
        return provider.name.toLowerCase().contains(query) ||
            provider.location
                .toLowerCase()
                .contains(query) ||
            provider.coverage
                .toLowerCase()
                .contains(query);
      },
    ).toList();
  }

  Future<void> _loadProviders() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final List<Map<String, Object>> result =
          await RegistrationApi.instance
              .loadRiderLogistics();

      if (!mounted) {
        return;
      }

      final List<LogisticsProvider> loadedProviders =
          result
              .map(
                (Map<String, Object> data) =>
                    LogisticsProvider.fromMap(data),
              )
              .where(
                (LogisticsProvider provider) =>
                    provider.id > 0,
              )
              .toList();

      setState(() {
        _providers = loadedProviders;
        _isLoading = false;
      });
    } on RegistrationApiException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = error.message;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage =
            'Cannot load Logistics providers. '
            'Check the Laravel server and SARI_API_URL.';
        _isLoading = false;
      });
    }
  }

  void _openRegistration(
    LogisticsProvider provider,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return RiderRegisterScreen(
            provider: provider,
          );
        },
      ),
    );
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Choose Logistics',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          color: _gold,
          backgroundColor: _surface,
          onRefresh: _loadProviders,
          child: ListView(
            physics:
                const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              16,
              12,
              16,
              30,
            ),
            children: <Widget>[
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 700,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const Text(
                        'SARI RIDER NETWORK',
                        style: TextStyle(
                          color: _gold,
                          fontSize: 9,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Choose your Logistics team',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.7,
                        ),
                      ),
                      const SizedBox(height: 9),
                      const Text(
                        'Choose an approved provider and '
                        'submit your Rider application '
                        'directly to its Logistics team.',
                        style: TextStyle(
                          color: _muted,
                          fontSize: 11.5,
                          height: 1.55,
                        ),
                      ),
                      const SizedBox(height: 22),
                      _buildSearchField(),
                      const SizedBox(height: 17),
                      _buildContent(),
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

  Widget _buildContent() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_filteredProviders.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: _filteredProviders
          .map(_buildProviderCard)
          .toList(),
    );
  }

  Widget _buildSearchField() {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(0.07),
        ),
      ),
      child: TextField(
        controller: _searchController,
        enabled: !_isLoading,
        style: const TextStyle(
          color: Colors.white,
        ),
        onChanged: (String value) {
          setState(() {});
        },
        decoration: InputDecoration(
          hintText:
              'Search provider, province, or city',
          hintStyle: const TextStyle(
            color: Color(0xFF77777F),
            fontSize: 12,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: _muted,
            size: 20,
          ),
          suffixIcon: _searchController.text.isEmpty
              ? null
              : IconButton(
                  onPressed: _clearSearch,
                  icon: const Icon(
                    Icons.close_rounded,
                    color: _muted,
                    size: 19,
                  ),
                ),
          filled: true,
          fillColor: _fieldColor,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: const BorderSide(
              color: _border,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: const BorderSide(
              color: _gold,
              width: 1.4,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 22,
        vertical: 55,
      ),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.07),
        ),
      ),
      child: const Column(
        children: <Widget>[
          CircularProgressIndicator(
            color: _gold,
            strokeWidth: 2.5,
          ),
          SizedBox(height: 17),
          Text(
            'Loading Logistics providers...',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _muted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(23),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF744545),
        ),
      ),
      child: Column(
        children: <Widget>[
          Container(
            width: 58,
            height: 58,
            decoration: const BoxDecoration(
              color: Color(0xFF372426),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.cloud_off_outlined,
              color: Color(0xFFFF8A8A),
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            'Unable to load providers',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            _errorMessage ??
                'An unexpected error occurred.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _muted,
              fontSize: 10.5,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 17),
          OutlinedButton.icon(
            onPressed: _loadProviders,
            icon: const Icon(
              Icons.refresh_rounded,
              size: 18,
            ),
            label: const Text('Try again'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(
                color: _border,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final bool hasSearch =
        _searchController.text.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 22,
        vertical: 45,
      ),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.07),
        ),
      ),
      child: Column(
        children: <Widget>[
          Container(
            width: 59,
            height: 59,
            decoration: const BoxDecoration(
              color: Color(0xFF292820),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.warehouse_outlined,
              color: _gold,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            hasSearch
                ? 'No matching provider'
                : 'No available Logistics provider',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            hasSearch
                ? 'Try searching with a different '
                    'provider name, province, or city.'
                : 'Approved and active Logistics '
                    'providers will appear here.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _muted,
              fontSize: 10.5,
              height: 1.5,
            ),
          ),
          if (hasSearch) ...<Widget>[
            const SizedBox(height: 14),
            TextButton(
              onPressed: _clearSearch,
              child: const Text(
                'Clear search',
                style: TextStyle(
                  color: _gold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProviderCard(
    LogisticsProvider provider,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.07),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withOpacity(0.28),
              blurRadius: 25,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 51,
                  height: 51,
                  decoration: BoxDecoration(
                    color: const Color(0xFF292820),
                    borderRadius:
                        BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.local_shipping_outlined,
                    color: _gold,
                    size: 25,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF213329),
                    borderRadius:
                        BorderRadius.circular(30),
                  ),
                  child: const Text(
                    '●  ACTIVE',
                    style: TextStyle(
                      color: Color(0xFF79C58E),
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              provider.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 5),
            Row(
              children: <Widget>[
                const Icon(
                  Icons.location_on_outlined,
                  color: _muted,
                  size: 15,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    provider.location,
                    style: const TextStyle(
                      color: _muted,
                      fontSize: 10.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 17),
            Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: _fieldColor,
                borderRadius:
                    BorderRadius.circular(14),
                border: Border.all(
                  color: _border,
                ),
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: _buildStat(
                      label: 'Approved riders',
                      value: provider.approvedRiders
                          .toString(),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 31,
                    color: _border,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildStat(
                      label: 'Coverage',
                      value: provider.coverage,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  _openRegistration(provider);
                },
                icon: const Icon(
                  Icons.assignment_outlined,
                  size: 19,
                ),
                label: const Text(
                  'Apply to this Logistics',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _gold,
                  foregroundColor:
                      const Color(0xFF151515),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(13),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat({
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFF7D7D85),
            fontSize: 7.5,
            letterSpacing: 0.7,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}