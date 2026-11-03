import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../config/api_config.dart';

class BuyerAddressPicker extends StatefulWidget {
  final TextEditingController province;
  final TextEditingController municipality;
  final TextEditingController barangay;

  const BuyerAddressPicker({
    super.key,
    required this.province,
    required this.municipality,
    required this.barangay,
  });

  @override
  State<BuyerAddressPicker> createState() =>
      _BuyerAddressPickerState();
}

class _BuyerAddressPickerState
    extends State<BuyerAddressPicker> {
  static const Color gold =
      Color(0xFFCC8A0B);

  String? _provinceCode;
  String? _municipalityCode;

  bool _resolving = false;

  final Map<String, List<_AddressOption>>
      _cache = {};

  @override
  void initState() {
    super.initState();

    _resolveExistingAddress();
  }

  String _normalize(
    String value,
  ) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(
          RegExp(r'\s+'),
          ' ',
        );
  }

  Future<List<_AddressOption>> _load(
    String path,
  ) async {
    if (_cache.containsKey(path)) {
      return _cache[path]!;
    }

    final base = ApiConfig.baseUrl
        .replaceFirst(
          RegExp(r'/+$'),
          '',
        );

    final response = await http
        .get(
          Uri.parse(
            '$base$path',
          ),
          headers: const {
            'Accept':
                'application/json',
          },
        )
        .timeout(
          const Duration(
            seconds: 20,
          ),
        );

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        'Address lookup failed '
        '(HTTP ${response.statusCode}).',
      );
    }

    final decoded = jsonDecode(
      utf8.decode(
        response.bodyBytes,
      ),
    );

    dynamic raw = decoded;

    if (decoded is Map) {
      raw =
          decoded['data'] ??
              decoded['items'];
    }

    if (raw is! List) {
      throw const FormatException(
        'Invalid address response.',
      );
    }

    final options = raw
        .whereType<Map>()
        .map(
          (item) =>
              _AddressOption(
            code:
                '${item['code'] ?? ''}',
            name:
                '${item['name'] ?? ''}',
          ),
        )
        .where(
          (option) =>
              option.code.isNotEmpty &&
              option.name.isNotEmpty,
        )
        .toList()
      ..sort(
        (a, b) =>
            a.name.compareTo(
          b.name,
        ),
      );

    _cache[path] = options;

    return options;
  }

  Future<void>
      _resolveExistingAddress() async {
    if (widget.province.text
        .trim()
        .isEmpty) {
      return;
    }

    setState(() {
      _resolving = true;
    });

    try {
      final provinces = await _load(
        '/address/provinces',
      );

      for (final province in provinces) {
        if (_normalize(province.name) ==
            _normalize(
              widget.province.text,
            )) {
          _provinceCode =
              province.code;
          break;
        }
      }

      if (_provinceCode == null ||
          widget.municipality.text
              .trim()
              .isEmpty) {
        return;
      }

      final municipalities =
          await _load(
        '/address/provinces/'
        '$_provinceCode/municipalities',
      );

      for (final municipality
          in municipalities) {
        if (_normalize(
              municipality.name,
            ) ==
            _normalize(
              widget.municipality.text,
            )) {
          _municipalityCode =
              municipality.code;
          break;
        }
      }
    } catch (_) {
      // Existing values remain visible even
      // when lookup hydration fails.
    } finally {
      if (mounted) {
        setState(() {
          _resolving = false;
        });
      }
    }
  }

  Future<void> _chooseProvince()
      async {
    try {
      final values = await _load(
        '/address/provinces',
      );

      if (!mounted) return;

      final selected =
          await _showPicker(
        title: 'Select Province',
        values: values,
      );

      if (selected == null ||
          !mounted) {
        return;
      }

      setState(() {
        _provinceCode =
            selected.code;

        _municipalityCode =
            null;

        widget.province.text =
            selected.name;

        widget.municipality
            .clear();

        widget.barangay.clear();
      });
    } catch (error) {
      _message(
        error.toString(),
      );
    }
  }

  Future<void>
      _chooseMunicipality() async {
    if (_provinceCode == null) {
      await _resolveExistingAddress();
    }

    if (_provinceCode == null) {
      _message(
        'Select a province first.',
      );
      return;
    }

    try {
      final values = await _load(
        '/address/provinces/'
        '$_provinceCode/municipalities',
      );

      if (!mounted) return;

      final selected =
          await _showPicker(
        title:
            'Select City / Municipality',
        values: values,
      );

      if (selected == null ||
          !mounted) {
        return;
      }

      setState(() {
        _municipalityCode =
            selected.code;

        widget.municipality.text =
            selected.name;

        widget.barangay.clear();
      });
    } catch (error) {
      _message(
        error.toString(),
      );
    }
  }

  Future<void> _chooseBarangay()
      async {
    if (_municipalityCode == null) {
      await _resolveExistingAddress();
    }

    if (_municipalityCode == null) {
      _message(
        'Select a city or municipality first.',
      );
      return;
    }

    try {
      final values = await _load(
        '/address/municipalities/'
        '$_municipalityCode/barangays',
      );

      if (!mounted) return;

      final selected =
          await _showPicker(
        title: 'Select Barangay',
        values: values,
      );

      if (selected == null ||
          !mounted) {
        return;
      }

      setState(() {
        widget.barangay.text =
            selected.name;
      });
    } catch (error) {
      _message(
        error.toString(),
      );
    }
  }

  Future<_AddressOption?> _showPicker({
    required String title,
    required List<_AddressOption>
        values,
  }) async {
    return showDialog<
        _AddressOption>(
      context: context,
      builder: (_) =>
          _BuyerAddressPickerDialog(
        title: title,
        values: values,
      ),
    );
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

  Widget _field({
    required String label,
    required TextEditingController
        controller,
    required VoidCallback onTap,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap:
          _resolving ? null : onTap,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: _resolving
            ? const Padding(
                padding:
                    EdgeInsets.all(14),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child:
                      CircularProgressIndicator(
                    strokeWidth: 2,
                    color: gold,
                  ),
                ),
              )
            : const Icon(
                Icons
                    .keyboard_arrow_down_rounded,
              ),
      ),
      validator: (value) {
        if ((value ?? '')
            .trim()
            .isEmpty) {
          return '$label is required.';
        }

        return null;
      },
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Column(
      children: [
        _field(
          label: 'Province / Area',
          controller:
              widget.province,
          onTap: _chooseProvince,
        ),
        const SizedBox(height: 10),
        _field(
          label:
              'City / Municipality',
          controller:
              widget.municipality,
          onTap:
              _chooseMunicipality,
        ),
        const SizedBox(height: 10),
        _field(
          label: 'Barangay',
          controller:
              widget.barangay,
          onTap: _chooseBarangay,
        ),
      ],
    );
  }
}

class _AddressOption {
  final String code;
  final String name;

  const _AddressOption({
    required this.code,
    required this.name,
  });
}

class _BuyerAddressPickerDialog
    extends StatefulWidget {
  final String title;

  final List<_AddressOption>
      values;

  const _BuyerAddressPickerDialog({
    required this.title,
    required this.values,
  });

  @override
  State<_BuyerAddressPickerDialog>
      createState() =>
          _BuyerAddressPickerDialogState();
}

class _BuyerAddressPickerDialogState
    extends State<
        _BuyerAddressPickerDialog> {
  String _query = '';

  @override
  Widget build(
    BuildContext context,
  ) {
    final query =
        _query.trim().toLowerCase();

    final filtered =
        widget.values.where(
      (option) {
        return query.isEmpty ||
            option.name
                .toLowerCase()
                .contains(query);
      },
    ).toList();

    return AlertDialog(
      title: Text(
        widget.title,
      ),
      content: SizedBox(
        width: 420,
        height: 440,
        child: Column(
          children: [
            TextField(
              autofocus: true,
              onChanged: (value) {
                setState(() {
                  _query = value;
                });
              },
              decoration:
                  const InputDecoration(
                hintText:
                    'Search location...',
                prefixIcon: Icon(
                  Icons.search_rounded,
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: filtered.isEmpty
                  ? const Center(
                      child: Text(
                        'No matching locations.',
                      ),
                    )
                  : ListView.builder(
                      itemCount:
                          filtered.length,
                      itemBuilder:
                          (_, index) {
                        final option =
                            filtered[
                                index];

                        return ListTile(
                          title: Text(
                            option.name,
                          ),
                          onTap: () =>
                              Navigator.of(
                                context,
                              ).pop(
                            option,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.of(
                context,
              ).pop(),
          child: const Text(
            'Cancel',
          ),
        ),
      ],
    );
  }
}