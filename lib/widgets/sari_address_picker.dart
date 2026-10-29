import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../config/api_config.dart';

/// Address dropdown powered by the existing Laravel /address/* lookup routes.
/// Saves the display names in legacy registration fields. Clears descendants
/// whenever the parent address changes.
class SariAddressPicker extends StatefulWidget {
  const SariAddressPicker({
    super.key,
    required this.province,
    required this.municipality,
    required this.barangay,
    this.accent = const Color(0xFFD4A62A),
  });

  final TextEditingController province;
  final TextEditingController municipality;
  final TextEditingController barangay;
  final Color accent;

  @override
  State<SariAddressPicker> createState() => _SariAddressPickerState();
}

class _SariAddressPickerState extends State<SariAddressPicker> {
  String? _provinceCode;
  String? _municipalityCode;
  final Map<String, List<_Location>> _cache = {};

  Future<List<_Location>> _load(String path) async {
    if (_cache.containsKey(path)) return _cache[path]!;
    final base = ApiConfig.baseUrl.replaceFirst(RegExp(r'/+$'), '');
    final response = await http.get(
      Uri.parse('$base$path'),
      headers: const {'Accept': 'application/json'},
    ).timeout(const Duration(seconds: 20));
    if (response.statusCode != 200) {
      throw Exception('Address lookup unavailable (HTTP ${response.statusCode})');
    }
    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    final Object? values = decoded is List
        ? decoded
        : decoded is Map
            ? (decoded['data'] ?? decoded['items'])
            : null;
    if (values is! List) throw const FormatException('Invalid address response');
    final result = values.whereType<Map>().map((item) => _Location(
      (item['code'] ?? '').toString(),
      (item['name'] ?? '').toString(),
    )).where((e) => e.code.isNotEmpty && e.name.isNotEmpty).toList();
    result.sort((a, b) => a.name.compareTo(b.name));
    _cache[path] = result;
    return result;
  }

  Future<void> _choose(int level) async {
    if (level == 1 && _provinceCode == null) return;
    if (level == 2 && _municipalityCode == null) return;
    final path = switch (level) {
      0 => '/address/provinces',
      1 => '/address/provinces/$_provinceCode/municipalities',
      _ => '/address/municipalities/$_municipalityCode/barangays',
    };
    final selected = await showDialog<_Location>(
      context: context,
      builder: (context) => _LocationDialog(
        title: switch (level) {
          0 => 'Choose province',
          1 => 'Choose city / municipality',
          _ => 'Choose barangay',
        },
        loader: _load(path),
        accent: widget.accent,
      ),
    );
    if (selected == null || !mounted) return;
    setState(() {
      if (level == 0) {
        _provinceCode = selected.code;
        _municipalityCode = null;
        widget.province.text = selected.name;
        widget.municipality.clear();
        widget.barangay.clear();
      } else if (level == 1) {
        _municipalityCode = selected.code;
        widget.municipality.text = selected.name;
        widget.barangay.clear();
      } else {
        widget.barangay.text = selected.name;
      }
    });
  }

  Widget _field(String label, TextEditingController controller, int level) {
    final enabled = level == 0 || (level == 1 ? _provinceCode != null : _municipalityCode != null);
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        onTap: enabled ? () => _choose(level) : null,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFFBBBBBF)),
          hintText: enabled ? 'Tap to select' : 'Select ${level == 1 ? 'province' : 'city'} first',
          hintStyle: const TextStyle(color: Color(0xFF77777F)),
          suffixIcon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
          filled: true,
          fillColor: const Color(0xFF222226),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(13)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: const BorderSide(color: Color(0xFF37373D)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: BorderSide(color: widget.accent),
          ),
        ),
        validator: (value) => value == null || value.trim().isEmpty ? 'This field is required.' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      _field('Province *', widget.province, 0),
      _field('City or municipality *', widget.municipality, 1),
      _field('Barangay *', widget.barangay, 2),
    ],
  );
}

class _Location {
  const _Location(this.code, this.name);
  final String code;
  final String name;
}

class _LocationDialog extends StatefulWidget {
  const _LocationDialog({required this.title, required this.loader, required this.accent});
  final String title;
  final Future<List<_Location>> loader;
  final Color accent;
  @override
  State<_LocationDialog> createState() => _LocationDialogState();
}

class _LocationDialogState extends State<_LocationDialog> {
  String query = '';
  @override
  Widget build(BuildContext context) => AlertDialog(
    backgroundColor: const Color(0xFF222226),
    title: Text(widget.title, style: const TextStyle(color: Colors.white, fontSize: 18)),
    content: SizedBox(
      width: 440,
      height: 430,
      child: Column(children: [
        TextField(
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Search location',
            hintStyle: TextStyle(color: Colors.white54),
            prefixIcon: Icon(Icons.search, color: Colors.white70),
          ),
          onChanged: (value) => setState(() => query = value),
        ),
        Expanded(child: FutureBuilder<List<_Location>>(
          future: widget.loader,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Unable to load locations. Check internet and retry.\n${snapshot.error}',
                style: const TextStyle(color: Colors.white70)));
            }
            if (!snapshot.hasData) return Center(child: CircularProgressIndicator(color: widget.accent));
            final values = snapshot.data!.where((e) => e.name.toLowerCase().contains(query.toLowerCase())).toList();
            if (values.isEmpty) return const Center(child: Text('No matching locations', style: TextStyle(color: Colors.white70)));
            return ListView.builder(
              itemCount: values.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(values[index].name, style: const TextStyle(color: Colors.white)),
                onTap: () => Navigator.pop(context, values[index]),
              ),
            );
          },
        )),
      ]),
    ),
    actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel'))],
  );
}
