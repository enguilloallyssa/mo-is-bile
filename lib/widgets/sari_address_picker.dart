import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';

/// PSGC address selection for SARI registration.
/// The selection list lives in a modal bottom sheet instead of an OverlayEntry:
/// tapping an item cannot trigger TextField.onTapOutside and close it first.
class SariAddressPicker extends StatefulWidget {
  const SariAddressPicker({
    super.key,
    this.region,
    this.regionCode,
    required this.province,
    required this.municipality,
    required this.barangay,
    this.provinceCode,
    this.municipalityCode,
    this.barangayCode,
    this.accent = const Color(0xFFBA842D),
  });

  final TextEditingController? region;
  final TextEditingController? regionCode;
  final TextEditingController province;
  final TextEditingController municipality;
  final TextEditingController barangay;
  final TextEditingController? provinceCode;
  final TextEditingController? municipalityCode;
  final TextEditingController? barangayCode;
  final Color accent;

  @override
  State<SariAddressPicker> createState() => _SariAddressPickerState();
}

class _Location {
  const _Location({required this.code, required this.name});
  final String code;
  final String name;
}

class _SariAddressPickerState extends State<SariAddressPicker> {
  static const Color _ink = Color(0xFF31271D);
  static const Color _muted = Color(0xFF84786A);
  static const Color _line = Color(0xFFE5CFAD);

  final _ownRegion = TextEditingController();
  final _ownRegionCode = TextEditingController();
  final _ownProvinceCode = TextEditingController();
  final _ownMunicipalityCode = TextEditingController();
  final _ownBarangayCode = TextEditingController();
  final Map<String, List<_Location>> _cache = {};
  final http.Client _client = http.Client();

  TextEditingController get _region => widget.region ?? _ownRegion;
  TextEditingController get _regionId => widget.regionCode ?? _ownRegionCode;
  TextEditingController get _provinceId =>
      widget.provinceCode ?? _ownProvinceCode;
  TextEditingController get _municipalityId =>
      widget.municipalityCode ?? _ownMunicipalityCode;
  TextEditingController get _barangayId =>
      widget.barangayCode ?? _ownBarangayCode;

  @override
  void dispose() {
    _ownRegion.dispose();
    _ownRegionCode.dispose();
    _ownProvinceCode.dispose();
    _ownMunicipalityCode.dispose();
    _ownBarangayCode.dispose();
    _client.close();
    super.dispose();
  }

  bool get _hasRegion => _regionId.text.trim().isNotEmpty;
  bool get _hasProvince => _provinceId.text.trim().isNotEmpty;
  bool get _hasMunicipality => _municipalityId.text.trim().isNotEmpty;

  Future<List<_Location>> _fetch(String route) async {
    final cached = _cache[route];
    if (cached != null) return cached;

    final base = ApiConfig.apiBaseUrl.replaceFirst(RegExp(r'/+$'), '');
    final uri = Uri.parse('$base$route');
    final response = await _client
        .get(uri, headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 22));

    if (response.statusCode != 200) {
      throw Exception(
        'SARI address service returned HTTP ${response.statusCode}.',
      );
    }
    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    final dynamic raw = decoded is List
        ? decoded
        : decoded is Map
        ? (decoded['data'] ?? decoded['items'])
        : null;
    if (raw is! List) throw const FormatException('Invalid address list.');

    final results =
        raw
            .whereType<Map>()
            .map(
              (row) => _Location(
                code: (row['code'] ?? '').toString().trim(),
                name: (row['name'] ?? '').toString().trim(),
              ),
            )
            .where((item) => item.code.isNotEmpty && item.name.isNotEmpty)
            .toList()
          ..sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
          );
    if (results.isNotEmpty) _cache[route] = results;
    return results;
  }

  void _clearBarangay() {
    widget.barangay.clear();
    _barangayId.clear();
  }

  void _clearMunicipality() {
    widget.municipality.clear();
    _municipalityId.clear();
    _clearBarangay();
  }

  void _clearProvince() {
    widget.province.clear();
    _provinceId.clear();
    _clearMunicipality();
  }

  Future<void> _select({
    required String title,
    required String route,
    required TextEditingController text,
    required TextEditingController code,
    required VoidCallback resetDependents,
  }) async {
    FocusScope.of(context).unfocus();
    final chosen = await _searchSheet(title, route);
    if (!mounted || chosen == null) return;
    setState(() {
      resetDependents();
      text.text = chosen.name;
      code.text = chosen.code;
    });
  }

  Future<_Location?> _searchSheet(String title, String route) async {
    Future<List<_Location>> request = _fetch(route);
    String query = '';
    return showModalBottomSheet<_Location>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: const Color(0xFFFFFCF7),
      barrierColor: const Color(0x70231B11),
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, sheetSetState) {
          return Padding(
            padding: EdgeInsets.fromLTRB(
              18,
              0,
              18,
              MediaQuery.viewInsetsOf(sheetContext).bottom + 18,
            ),
            child: SizedBox(
              height: (MediaQuery.sizeOf(sheetContext).height * .66).clamp(
                300.0,
                590.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Select $title',
                          style: const TextStyle(
                            color: _ink,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Close',
                        onPressed: () => Navigator.pop(sheetContext),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    autofocus: false,
                    textInputAction: TextInputAction.search,
                    onChanged: (value) => sheetSetState(() => query = value),
                    style: const TextStyle(color: _ink, fontSize: 14),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: _muted,
                      ),
                      hintText: 'Search $title',
                      filled: true,
                      fillColor: const Color(0xFFF8F0E5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: _line),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: _line),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: widget.accent,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: FutureBuilder<List<_Location>>(
                      future: request,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState != ConnectionState.done) {
                          return Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2.3,
                              color: widget.accent,
                            ),
                          );
                        }
                        if (snapshot.hasError) {
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.wifi_off_rounded,
                                  color: _muted,
                                  size: 32,
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Could not load locations',
                                  style: TextStyle(
                                    color: _ink,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 14),
                                  child: Text(
                                    'Check your connection or SARI server, then retry.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: _muted,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: () => sheetSetState(() {
                                    request = _fetch(route);
                                  }),
                                  icon: const Icon(Icons.refresh_rounded),
                                  label: const Text('Try again'),
                                ),
                              ],
                            ),
                          );
                        }
                        final results = (snapshot.data ?? <_Location>[])
                            .where(
                              (item) => item.name.toLowerCase().contains(
                                query.trim().toLowerCase(),
                              ),
                            )
                            .toList();
                        if (results.isEmpty) {
                          return const Center(
                            child: Text(
                              'No matching locations',
                              style: TextStyle(color: _muted),
                            ),
                          );
                        }
                        return ListView.separated(
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          itemCount: results.length,
                          separatorBuilder: (_, _) => const Divider(
                            height: 1,
                            color: Color(0xFFEFE5D7),
                          ),
                          itemBuilder: (context, index) {
                            final item = results[index];
                            return ListTile(
                              minTileHeight: 49,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              leading: Icon(
                                Icons.location_on_outlined,
                                color: widget.accent,
                                size: 19,
                              ),
                              title: Text(
                                item.name,
                                style: const TextStyle(
                                  color: _ink,
                                  fontSize: 13,
                                ),
                              ),
                              trailing: const Icon(
                                Icons.chevron_right_rounded,
                                color: _muted,
                                size: 18,
                              ),
                              onTap: () => Navigator.pop(sheetContext, item),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _locationField({
    required String label,
    required TextEditingController controller,
    required bool enabled,
    required VoidCallback onTap,
    required VoidCallback onClear,
    required String placeholder,
  }) {
    final filled = controller.text.trim().isNotEmpty;
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              '$label *',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _ink,
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: enabled ? onTap : null,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                constraints: const BoxConstraints(minHeight: 51),
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: enabled
                      ? const Color(0xEFFFFFFC)
                      : const Color(0xBFEAE1D7),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: filled ? widget.accent : _line),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.place_outlined,
                      size: 20,
                      color: enabled ? widget.accent : _muted,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        filled ? controller.text : placeholder,
                        style: TextStyle(
                          color: filled ? _ink : _muted,
                          fontSize: 12.5,
                          fontWeight: filled
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                    if (filled && enabled)
                      InkWell(
                        onTap: onClear,
                        borderRadius: BorderRadius.circular(25),
                        child: const Padding(
                          padding: EdgeInsets.all(7),
                          child: Icon(
                            Icons.close_rounded,
                            size: 17,
                            color: _muted,
                          ),
                        ),
                      )
                    else
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: _muted,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _locationField(
          label: 'Region',
          controller: _region,
          enabled: true,
          placeholder: 'Choose region',
          onTap: () => _select(
            title: 'Region',
            route: '/address/regions',
            text: _region,
            code: _regionId,
            resetDependents: _clearProvince,
          ),
          onClear: () => setState(() {
            _region.clear();
            _regionId.clear();
            _clearProvince();
          }),
        ),
        _locationField(
          label: 'Province',
          controller: widget.province,
          enabled: _hasRegion,
          placeholder: _hasRegion ? 'Choose province' : 'Select region first',
          onTap: () => _select(
            title: 'Province',
            route: '/address/regions/${_regionId.text}/provinces',
            text: widget.province,
            code: _provinceId,
            resetDependents: _clearMunicipality,
          ),
          onClear: () => setState(_clearProvince),
        ),
        _locationField(
          label: 'City / Municipality',
          controller: widget.municipality,
          enabled: _hasProvince,
          placeholder: _hasProvince
              ? 'Choose city or municipality'
              : 'Select province first',
          onTap: () => _select(
            title: 'City / Municipality',
            route: '/address/provinces/${_provinceId.text}/municipalities',
            text: widget.municipality,
            code: _municipalityId,
            resetDependents: _clearBarangay,
          ),
          onClear: () => setState(_clearMunicipality),
        ),
        _locationField(
          label: 'Barangay',
          controller: widget.barangay,
          enabled: _hasMunicipality,
          placeholder: _hasMunicipality
              ? 'Choose barangay'
              : 'Select city first',
          onTap: () => _select(
            title: 'Barangay',
            route: '/address/municipalities/${_municipalityId.text}/barangays',
            text: widget.barangay,
            code: _barangayId,
            resetDependents: () {},
          ),
          onClear: () => setState(_clearBarangay),
        ),
      ],
    );
  }
}
