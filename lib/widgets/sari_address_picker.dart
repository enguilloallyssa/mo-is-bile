import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';

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
    this.accent = const Color(0xFFD4A62A),
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
  State<SariAddressPicker> createState() =>
      _SariAddressPickerState();
}

class _SariAddressPickerState extends State<SariAddressPicker> {
  final TextEditingController _internalRegion =
      TextEditingController();

  final TextEditingController _internalRegionCode =
      TextEditingController();

  final Map<String, List<_Location>> _cache =
      <String, List<_Location>>{};

  String? _regionCode;
  String? _provinceCode;
  String? _municipalityCode;
  String? _barangayCode;

  TextEditingController get _regionController =>
      widget.region ?? _internalRegion;

  TextEditingController get _regionCodeController =>
      widget.regionCode ?? _internalRegionCode;

  @override
  void initState() {
    super.initState();

    _regionCode =
        _cleanCode(
      _regionCodeController.text,
    );

    _provinceCode =
        _cleanCode(
      widget.provinceCode?.text,
    );

    _municipalityCode =
        _cleanCode(
      widget.municipalityCode?.text,
    );

    _barangayCode =
        _cleanCode(
      widget.barangayCode?.text,
    );
  }

  @override
  void dispose() {
    _internalRegion.dispose();
    _internalRegionCode.dispose();

    super.dispose();
  }

  String? _cleanCode(
    String? value,
  ) {
    final String result =
        value?.trim() ?? '';

    return result.isEmpty
        ? null
        : result;
  }

  // ============================================================
  // ADDRESS API
  // ============================================================

  Future<List<_Location>> _request(
    String path,
  ) async {
    final List<_Location>? cached =
        _cache[path];

    if (cached != null) {
      return cached;
    }

    final String base =
        ApiConfig.baseUrl.replaceFirst(
      RegExp(r'/+$'),
      '',
    );

    final Uri uri =
        Uri.parse(
      '$base$path',
    );

    final http.Response response =
        await http
            .get(
              uri,
              headers:
                  const <String, String>{
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
        'Address lookup unavailable '
        '(HTTP ${response.statusCode}).',
      );
    }

    final dynamic decoded =
        jsonDecode(
      utf8.decode(
        response.bodyBytes,
      ),
    );

    dynamic raw;

    if (decoded is List) {
      raw = decoded;
    } else if (decoded is Map) {
      raw =
          decoded['data'] ??
              decoded['items'];
    }

    if (raw is! List) {
      throw const FormatException(
        'Invalid address response.',
      );
    }

    final List<_Location> result =
        raw
            .whereType<Map>()
            .map(
              (
                Map<dynamic, dynamic> item,
              ) {
                return _Location(
                  code:
                      '${item['code'] ?? ''}'
                          .trim(),
                  name:
                      '${item['name'] ?? ''}'
                          .trim(),
                );
              },
            )
            .where(
              (
                _Location item,
              ) =>
                  item.code.isNotEmpty &&
                  item.name.isNotEmpty,
            )
            .toList();

    result.sort(
      (
        _Location a,
        _Location b,
      ) =>
          a.name
              .toLowerCase()
              .compareTo(
                b.name.toLowerCase(),
              ),
    );

    _cache[path] = result;

    return result;
  }

  Future<List<_Location>> _regions() {
    return _request(
      '/address/regions',
    );
  }

  Future<List<_Location>> _provinces() {
    if (_regionCode == null) {
      return Future.value(
        const <_Location>[],
      );
    }

    return _request(
      '/address/regions/'
      '$_regionCode'
      '/provinces',
    );
  }

  Future<List<_Location>> _municipalities() {
    if (_provinceCode == null) {
      return Future.value(
        const <_Location>[],
      );
    }

    return _request(
      '/address/provinces/'
      '$_provinceCode'
      '/municipalities',
    );
  }

  Future<List<_Location>> _barangays() {
    if (_municipalityCode == null) {
      return Future.value(
        const <_Location>[],
      );
    }

    return _request(
      '/address/municipalities/'
      '$_municipalityCode'
      '/barangays',
    );
  }

  // ============================================================
  // REGION
  // ============================================================

  void _selectRegion(
    _Location item,
  ) {
    setState(() {
      _regionCode = item.code;

      _regionController.text =
          item.name;

      _regionCodeController.text =
          item.code;

      _clearProvince();
    });
  }

  void _clearRegion() {
    setState(() {
      _regionCode = null;

      _regionController.clear();
      _regionCodeController.clear();

      _clearProvince();
    });
  }

  // ============================================================
  // PROVINCE
  // ============================================================

  void _selectProvince(
    _Location item,
  ) {
    setState(() {
      _provinceCode = item.code;

      widget.province.text =
          item.name;

      widget.provinceCode?.text =
          item.code;

      _clearMunicipality();
    });
  }

  void _clearProvince() {
    _provinceCode = null;

    widget.province.clear();
    widget.provinceCode?.clear();

    _clearMunicipality();
  }

  // ============================================================
  // MUNICIPALITY
  // ============================================================

  void _selectMunicipality(
    _Location item,
  ) {
    setState(() {
      _municipalityCode =
          item.code;

      widget.municipality.text =
          item.name;

      widget.municipalityCode?.text =
          item.code;

      _clearBarangay();
    });
  }

  void _clearMunicipality() {
    _municipalityCode = null;

    widget.municipality.clear();
    widget.municipalityCode?.clear();

    _clearBarangay();
  }

  // ============================================================
  // BARANGAY
  // ============================================================

  void _selectBarangay(
    _Location item,
  ) {
    setState(() {
      _barangayCode =
          item.code;

      widget.barangay.text =
          item.name;

      widget.barangayCode?.text =
          item.code;
    });
  }

  void _clearBarangay() {
    _barangayCode = null;

    widget.barangay.clear();
    widget.barangayCode?.clear();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.stretch,
      children: <Widget>[
        _AddressDropdown(
          label: 'Region',
          hint: 'Search region',
          controller:
              _regionController,
          enabled: true,
          accent:
              widget.accent,
          selectedCode:
              _regionCode,
          loader:
              _regions,
          onSelected:
              _selectRegion,
          onClear:
              _clearRegion,
          icon:
              Icons.map_outlined,
        ),

        const SizedBox(
          height: 11,
        ),

        _AddressDropdown(
          label: 'Province',
          hint: _regionCode == null
              ? 'Choose region first'
              : 'Search province',
          controller:
              widget.province,
          enabled:
              _regionCode != null,
          accent:
              widget.accent,
          selectedCode:
              _provinceCode,
          loader:
              _provinces,
          onSelected:
              _selectProvince,
          onClear:
              () {
            setState(
              _clearProvince,
            );
          },
          icon:
              Icons.location_city_outlined,
        ),

        const SizedBox(
          height: 11,
        ),

        _AddressDropdown(
          label:
              'City / Municipality',
          hint:
              _provinceCode == null
                  ? 'Choose province first'
                  : 'Search city or municipality',
          controller:
              widget.municipality,
          enabled:
              _provinceCode != null,
          accent:
              widget.accent,
          selectedCode:
              _municipalityCode,
          loader:
              _municipalities,
          onSelected:
              _selectMunicipality,
          onClear:
              () {
            setState(
              _clearMunicipality,
            );
          },
          icon:
              Icons.apartment_outlined,
        ),

        const SizedBox(
          height: 11,
        ),

        _AddressDropdown(
          label: 'Barangay',
          hint:
              _municipalityCode == null
                  ? 'Choose city first'
                  : 'Search barangay',
          controller:
              widget.barangay,
          enabled:
              _municipalityCode != null,
          accent:
              widget.accent,
          selectedCode:
              _barangayCode,
          loader:
              _barangays,
          onSelected:
              _selectBarangay,
          onClear:
              () {
            setState(
              _clearBarangay,
            );
          },
          icon:
              Icons.place_outlined,
        ),
      ],
    );
  }
}

// ============================================================
// SEARCHABLE DROPDOWN
// ============================================================

class _AddressDropdown
    extends StatefulWidget {
  const _AddressDropdown({
    required this.label,
    required this.hint,
    required this.controller,
    required this.enabled,
    required this.accent,
    required this.selectedCode,
    required this.loader,
    required this.onSelected,
    required this.onClear,
    required this.icon,
  });

  final String label;
  final String hint;

  final TextEditingController controller;

  final bool enabled;

  final Color accent;

  final String? selectedCode;

  final Future<List<_Location>>
      Function() loader;

  final ValueChanged<_Location>
      onSelected;

  final VoidCallback onClear;

  final IconData icon;

  @override
  State<_AddressDropdown>
      createState() =>
          _AddressDropdownState();
}

class _AddressDropdownState
    extends State<_AddressDropdown> {
  final LayerLink _layerLink =
      LayerLink();

  final FocusNode _focusNode =
      FocusNode();

  OverlayEntry? _overlay;

  List<_Location> _items =
      <_Location>[];

  bool _loading = false;

  String? _error;

  String _search = '';

  @override
  void initState() {
    super.initState();

    _focusNode.addListener(
      _focusChanged,
    );
  }

  @override
  void didUpdateWidget(
    covariant _AddressDropdown oldWidget,
  ) {
    super.didUpdateWidget(
      oldWidget,
    );

    if (!widget.enabled &&
        oldWidget.enabled) {
      _hide();

      _focusNode.unfocus();
    }
  }

  @override
  void dispose() {
    _hide();

    _focusNode.removeListener(
      _focusChanged,
    );

    _focusNode.dispose();

    super.dispose();
  }

  void _focusChanged() {
    if (_focusNode.hasFocus &&
        widget.enabled) {
      _show();
    } else {
      _hide();
    }
  }

  Future<void> _load() async {
    if (!widget.enabled) {
      return;
    }

    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    _rebuildOverlay();

    try {
      final List<_Location> result =
          await widget.loader();

      if (!mounted) {
        return;
      }

      setState(() {
        _items = result;
        _loading = false;
      });

      _rebuildOverlay();
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;
        _error =
            error.toString();
      });

      _rebuildOverlay();
    }
  }

  void _show() {
    if (!widget.enabled) {
      return;
    }

    if (_overlay == null) {
      final RenderBox box =
          context.findRenderObject()
              as RenderBox;

      final Size size =
          box.size;

      _overlay =
          OverlayEntry(
        builder:
            (
              BuildContext context,
            ) {
          return Positioned(
            width: size.width,
            child:
                CompositedTransformFollower(
              link:
                  _layerLink,
              showWhenUnlinked:
                  false,
              targetAnchor:
                  Alignment.bottomLeft,
              followerAnchor:
                  Alignment.topLeft,
              offset:
                  const Offset(
                0,
                4,
              ),
              child:
                  _dropdown(),
            ),
          );
        },
      );

      Overlay.of(
        context,
        rootOverlay: true,
      ).insert(
        _overlay!,
      );
    }

    _load();
  }

  void _hide() {
    _overlay?.remove();

    _overlay = null;
  }

  void _rebuildOverlay() {
    _overlay?.markNeedsBuild();
  }

  List<_Location>
      get _filtered {
    final String search =
        _search
            .trim()
            .toLowerCase();

    if (search.isEmpty) {
      return _items;
    }

    return _items
        .where(
          (
            _Location item,
          ) =>
              item.name
                  .toLowerCase()
                  .contains(search),
        )
        .toList();
  }

  void _choose(
    _Location item,
  ) {
    widget.onSelected(
      item,
    );

    _search = '';

    _focusNode.unfocus();

    _hide();
  }

  Widget _dropdown() {
    final List<_Location> values =
        _filtered;

    return Material(
      color:
          Colors.transparent,
      child: Container(
        constraints:
            const BoxConstraints(
          maxHeight: 205,
        ),
        decoration:
            BoxDecoration(
          color:
              const Color(
            0xFF222226,
          ),
          borderRadius:
              BorderRadius.circular(
            11,
          ),
          border:
              Border.all(
            color:
                const Color(
              0xFF3A3A40,
            ),
          ),
          boxShadow:
              const <BoxShadow>[
            BoxShadow(
              color:
                  Color(
                0x66000000,
              ),
              blurRadius: 18,
              offset:
                  Offset(
                0,
                8,
              ),
            ),
          ],
        ),
        clipBehavior:
            Clip.antiAlias,
        child: _loading
            ? SizedBox(
                height: 65,
                child: Center(
                  child:
                      CircularProgressIndicator(
                    color:
                        widget.accent,
                    strokeWidth: 2,
                  ),
                ),
              )
            : _error != null
                ? Padding(
                    padding:
                        const EdgeInsets.all(
                      13,
                    ),
                    child: Column(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: <Widget>[
                        const Icon(
                          Icons
                              .cloud_off_outlined,
                          color:
                              Colors.white54,
                          size: 22,
                        ),

                        const SizedBox(
                          height: 6,
                        ),

                        Text(
                          _error!,
                          textAlign:
                              TextAlign.center,
                          style:
                              const TextStyle(
                            color:
                                Colors.white54,
                            fontSize: 8.5,
                          ),
                        ),

                        TextButton(
                          onPressed:
                              _load,
                          child:
                              const Text(
                            'Retry',
                          ),
                        ),
                      ],
                    ),
                  )
                : values.isEmpty
                    ? const SizedBox(
                        height: 65,
                        child: Center(
                          child: Text(
                            'No matching locations',
                            style:
                                TextStyle(
                              color:
                                  Colors.white54,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        padding:
                            const EdgeInsets.symmetric(
                          vertical: 4,
                        ),
                        itemCount:
                            values.length,
                        itemBuilder:
                            (
                              BuildContext context,
                              int index,
                            ) {
                          final _Location item =
                              values[index];

                          final bool selected =
                              widget.selectedCode ==
                                  item.code;

                          return InkWell(
                          onTap: () {
                      _choose(
                    item,
                  );
                  },
              child: Container(
          constraints:
        const BoxConstraints(
            minHeight: 36,
          ),
              padding:
              const EdgeInsets.symmetric(
            horizontal: 12,
              vertical: 8,
              ),
                              color: selected
                                  ? widget.accent
                                      .withValues(
                                        alpha: .12,
                                      )
                                  : Colors
                                      .transparent,
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      item.name,
                                      style:
                                          TextStyle(
                                        color: selected
                                            ? widget
                                                .accent
                                            : Colors
                                                .white,
                                        fontSize:
                                            9.5,
                                        fontWeight:
                                            selected
                                                ? FontWeight
                                                    .w700
                                                : FontWeight
                                                    .w400,
                                      ),
                                    ),
                                  ),

                                  if (selected)
                                    Icon(
                                      Icons
                                          .check_rounded,
                                      color:
                                          widget.accent,
                                      size: 14,
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final bool hasValue =
        widget.controller.text
            .trim()
            .isNotEmpty;

    return CompositedTransformTarget(
      link:
          _layerLink,
      child: TextFormField(
        controller:
            widget.controller,
        focusNode:
            _focusNode,
        enabled:
            widget.enabled,
        style:
            TextStyle(
          color:
              widget.enabled
                  ? Colors.white
                  : Colors.white38,
          fontSize: 10.5,
        ),
        onTap: () {
          if (widget.enabled) {
            _show();
          }
        },
        onChanged:
            (
              String value,
            ) {
          _search = value;

          _rebuildOverlay();
        },
        onTapOutside:
            (
              PointerDownEvent event,
            ) {
          _focusNode.unfocus();

          _hide();
        },
        decoration:
            InputDecoration(
          isDense: true,

          labelText:
              '${widget.label} *',

          hintText:
              widget.hint,

          labelStyle:
              TextStyle(
            color:
                widget.enabled
                    ? Colors.white60
                    : Colors.white30,
            fontSize: 9.5,
            fontWeight:
                FontWeight.w600,
          ),

          hintStyle:
              TextStyle(
            color:
                widget.enabled
                    ? Colors.white38
                    : Colors.white24,
            fontSize: 9.5,
          ),

          prefixIcon:
              Icon(
            widget.icon,
            size: 16,
            color:
                widget.enabled
                    ? widget.accent
                    : Colors.white24,
          ),

          prefixIconConstraints:
              const BoxConstraints(
            minWidth: 39,
          ),

          suffixIcon:
              hasValue &&
                      widget.enabled
                  ? IconButton(
                      onPressed: () {
                        widget.onClear();

                        _search = '';

                        _rebuildOverlay();
                      },
                      icon:
                          const Icon(
                        Icons
                            .close_rounded,
                        size: 15,
                      ),
                    )
                  : Icon(
                      Icons
                          .keyboard_arrow_down_rounded,
                      size: 18,
                      color:
                          widget.enabled
                              ? Colors.white54
                              : Colors.white24,
                    ),

          contentPadding:
              const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 12,
          ),

          filled: true,

          fillColor:
              widget.enabled
                  ? const Color(
                      0xFF222226,
                    )
                  : const Color(
                      0xFF18181C,
                    ),

          border:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
              11,
            ),
          ),

          enabledBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
              11,
            ),
            borderSide:
                const BorderSide(
              color:
                  Color(
                0xFF38383E,
              ),
            ),
          ),

          disabledBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
              11,
            ),
            borderSide:
                const BorderSide(
              color:
                  Color(
                0xFF29292E,
              ),
            ),
          ),

          focusedBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
              11,
            ),
            borderSide:
                BorderSide(
              color:
                  widget.accent,
              width: 1.2,
            ),
          ),

          errorBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
              11,
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
              11,
            ),
            borderSide:
                const BorderSide(
              color:
                  Colors.redAccent,
            ),
          ),
        ),

        validator:
            (
              String? value,
            ) {
          if (!widget.enabled) {
            return null;
          }

          if ((value ?? '')
              .trim()
              .isEmpty) {
            return '${widget.label} is required.';
          }

          if ((widget.selectedCode ??
                  '')
              .trim()
              .isEmpty) {
            return 'Choose a valid ${widget.label.toLowerCase()}.';
          }

          return null;
        },
      ),
    );
  }
}

class _Location {
  const _Location({
    required this.code,
    required this.name,
  });

  final String code;
  final String name;
} 