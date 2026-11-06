import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../services/sari_live_data.dart';

import 'widgets/logistics_hub_picker.dart';
import 'widgets/logistics_ui.dart';

class LogisticsScanner extends StatefulWidget {
  const LogisticsScanner({
    super.key,
    this.standalone = false,
  });

  final bool standalone;

  @override
  State<LogisticsScanner> createState() =>
      _LogisticsScannerState();
}

class _LogisticsScannerState extends State<LogisticsScanner> {
  final _controller =
      MobileScannerController(
    autoStart:
        false,

    formats: [
      BarcodeFormat.qrCode,
      BarcodeFormat.code128,
    ],
  );

  final _manual =
      TextEditingController();

  int? _hubId;

  bool _scanning =
      false;

  bool _busy =
      false;

  String? _code;
  String? _error;

  Map<String, dynamic>?
      _verified;

  @override
  void dispose() {
    _controller.dispose();
    _manual.dispose();

    super.dispose();
  }

  void _selectHub(
    int? hub,
  ) {
    _hubId = hub;

    setState(() {
      _verified = null;
      _error = null;
    });
  }

  Future<void> _start()
      async {
    if (_hubId == null ||
        _busy) {
      return;
    }

    setState(() {
      _scanning = true;
      _code = null;
      _verified = null;
      _error = null;
    });

    WidgetsBinding.instance
        .addPostFrameCallback(
      (_) async {
        try {
          await _controller.start();
        } catch (e) {
          if (mounted) {
            setState(() {
              _scanning = false;

              _error =
                  'Camera error: $e';
            });
          }
        }
      },
    );
  }

  Future<void> _stop()
      async {
    setState(
      () =>
          _scanning =
              false,
    );

    try {
      await _controller.stop();
    } catch (_) {}
  }

  Future<void> _capture(
    String raw,
  ) async {
    final value =
        raw.trim();

    if (value.isEmpty ||
        _busy ||
        _code != null) {
      return;
    }

    if (value.length >
        1000) {
      setState(
        () =>
            _error =
                'QR content is too long.',
      );

      return;
    }

    await _stop();

    if (!mounted) {
      return;
    }

    setState(
      () =>
          _code =
              value,
    );

    await _verify();
  }

  Future<void> _manualEntry()
      async {
    final entered =
        await showDialog<String>(
      context:
          context,

      builder:
          (
            context,
          ) =>
              AlertDialog(
        title:
            const Text(
          'Enter signed parcel QR',
        ),

        content:
            TextField(
          controller:
              _manual,

          maxLines:
              2,

          maxLength:
              1000,

          decoration:
              const InputDecoration(
            labelText:
                'Full SARI parcel QR payload',
          ),
        ),

        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(
              context,
            ),

            child:
                const Text(
              'Cancel',
            ),
          ),

          FilledButton(
            onPressed: () =>
                Navigator.pop(
              context,
              _manual.text.trim(),
            ),

            child:
                const Text(
              'Verify',
            ),
          ),
        ],
      ),
    );

    if (entered != null &&
        entered.isNotEmpty &&
        mounted) {
      _code = null;

      await _capture(
        entered,
      );
    }
  }

  Future<void> _verify()
      async {
    if (_hubId == null ||
        _code == null) {
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
      _verified = null;
    });

    try {
      final response =
          await SariLiveData.instance.logisticsScanVerify(
        _code!,
        _hubId!,
      );

      final data =
          response['data'];

      if (!mounted) {
        return;
      }

      setState(
        () =>
            _verified =
                data is Map
                    ? Map<String, dynamic>.from(
                        data,
                      )
                    : null,
      );
    } catch (e) {
      if (mounted) {
        setState(
          () =>
              _error =
                  e.toString(),
        );
      }
    } finally {
      if (mounted) {
        setState(
          () =>
              _busy =
                  false,
        );
      }
    }
  }

  Future<void> _perform(
    String action,
  ) async {
    final data =
        _verified;

    if (data == null ||
        _hubId == null) {
      return;
    }

    final parcel =
        data['parcel'];

    final id =
        parcel is Map
            ? (parcel['id'] as num?)
                ?.toInt()
            : null;

    if (id == null) {
      return;
    }

    final confirmed =
        await showDialog<bool>(
      context:
          context,

      builder:
          (
            context,
          ) =>
              AlertDialog(
        title:
            Text(
          action == 'receive'
              ? 'Confirm hub intake'
              : 'Confirm parcel sorting',
        ),

        content:
            Text(
          'Only proceed after physically checking parcel ${data['order_number']} at this hub.',
        ),

        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(
              context,
              false,
            ),

            child:
                const Text(
              'Cancel',
            ),
          ),

          FilledButton(
            onPressed: () =>
                Navigator.pop(
              context,
              true,
            ),

            child:
                const Text(
              'Confirm',
            ),
          ),
        ],
      ),
    );

    if (confirmed != true ||
        !mounted) {
      return;
    }

    setState(
      () =>
          _busy =
              true,
    );

    try {
      if (action ==
          'receive') {
        await SariLiveData.instance.logisticsReceive(
          id,
          _hubId!,
        );
      }

      if (action ==
          'sort') {
        await SariLiveData.instance.logisticsSort(
          id,
          _hubId!,
        );
      }

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
              Text(
            'Saved to Laravel. Parcel state updated.',
          ),
        ),
      );

      await _verify();
    } catch (e) {
      if (mounted) {
        setState(
          () =>
              _error =
                  e.toString(),
        );
      }
    } finally {
      if (mounted) {
        setState(
          () =>
              _busy =
                  false,
        );
      }
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final data =
        _verified;

    final parcel =
        data?['parcel'];

    final parcelMap =
        parcel is Map
            ? Map<String, dynamic>.from(
                parcel,
              )
            : <String, dynamic>{};

    final action =
        data?['next_action']
            ?.toString();

    return Scaffold(
      backgroundColor:
          LogisticsPalette.canvas,

      appBar:
          widget.standalone
              ? AppBar(
                  title:
                      const Text(
                    'Parcel Scanner',
                  ),
                )
              : null,

      body:
          ListView(
        padding:
            const EdgeInsets.fromLTRB(
          16,
          15,
          16,
          30,
        ),

        children: [
          const LogisticsSectionTitle(
            title:
                'Secure Parcel Scanner',

            subtitle:
                'Signed QR verification and real Laravel parcel workflow.',
          ),

          const SizedBox(
            height: 13,
          ),

          LogisticsHubPicker(
            onChanged:
                _selectHub,
          ),

          const SizedBox(
            height: 15,
          ),

          Container(
            height:
                280,

            clipBehavior:
                Clip.antiAlias,

            decoration:
                BoxDecoration(
              color:
                  const Color(
                0xFF122031,
              ),

              borderRadius:
                  BorderRadius.circular(
                16,
              ),
            ),

            child:
                _scanning
                    ? MobileScanner(
                        controller:
                            _controller,

                        onDetect:
                            (
                              capture,
                            ) {
                          if (_busy ||
                              _code != null) {
                            return;
                          }

                          for (final code
                              in capture.barcodes) {
                            final value =
                                code.rawValue;

                            if (value != null &&
                                value.trim().isNotEmpty) {
                              _capture(
                                value,
                              );

                              break;
                            }
                          }
                        },
                      )
                    : const Center(
                        child:
                            Column(
                          mainAxisSize:
                              MainAxisSize.min,

                          children: [
                            Icon(
                              Icons.qr_code_scanner,

                              color:
                                  Colors.white,

                              size:
                                  65,
                            ),

                            SizedBox(
                              height: 10,
                            ),

                            Text(
                              'Select a hub, then scan',

                              style:
                                  TextStyle(
                                color:
                                    Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
          ),

          const SizedBox(
            height: 13,
          ),

          Row(
            children: [
              Expanded(
                child:
                    FilledButton.icon(
                  onPressed:
                      _hubId == null || _busy
                          ? null
                          : (_scanning
                              ? _stop
                              : _start),

                  icon:
                      Icon(
                    _scanning
                        ? Icons.stop_circle
                        : Icons.qr_code_scanner,
                  ),

                  label:
                      Text(
                    _scanning
                        ? 'Stop camera'
                        : 'Start camera',
                  ),
                ),
              ),

              const SizedBox(
                width: 9,
              ),

              Expanded(
                child:
                    OutlinedButton.icon(
                  onPressed:
                      _hubId == null || _busy
                          ? null
                          : _manualEntry,

                  icon:
                      const Icon(
                    Icons.keyboard,
                  ),

                  label:
                      const Text(
                    'Manual QR',
                  ),
                ),
              ),
            ],
          ),

          if (_busy) ...[
            const SizedBox(
              height: 12,
            ),

            const LinearProgressIndicator(),
          ],

          if (_error != null) ...[
            const SizedBox(
              height: 10,
            ),

            LogisticsInfoBanner(
              message:
                  _error!,
            ),
          ],

          if (_code != null) ...[
            const SizedBox(
              height: 17,
            ),

            LogisticsSurface(
              child:
                  Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Text(
                    data == null
                        ? 'QR scanned — verification failed'
                        : 'Verified SARI Parcel',

                    style:
                        const TextStyle(
                      fontSize:
                          16,

                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  Text(
                    'Code: ${_code!.length > 64 ? '${_code!.substring(0, 64)}…' : _code!}',

                    maxLines:
                        3,
                  ),

                  const SizedBox(
                    height: 6,
                  ),

                  if (data !=
                      null) ...[
                    Text(
                      'Order: ${data['order_number'] ?? ''}',

                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),

                    Text(
                      'Parcel status: ${parcelMap['status'] ?? ''}',
                    ),

                    Text(
                      'Next allowed action: ${action ?? 'None'}',
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    if ((action == 'receive' ||
                            action == 'sort') &&
                        !_busy)
                      SizedBox(
                        width:
                            double.infinity,

                        child:
                            FilledButton.icon(
                          onPressed: () =>
                              _perform(
                            action!,
                          ),

                          icon:
                              const Icon(
                            Icons.check_circle_outline,
                          ),

                          label:
                              Text(
                            action == 'receive'
                                ? 'Confirm receive at hub'
                                : 'Confirm sorting',
                          ),
                        ),
                      ),

                    if (action ==
                        'transfer_receive')
                      const Text(
                        'Open Transfers and confirm the whole manifest at the destination hub.',
                      ),

                    if (action ==
                        'last_mile')
                      const Text(
                        'Ready for last-mile assignment. Use the web for batch planning.',
                      ),
                  ],

                  Align(
                    alignment:
                        Alignment.centerRight,

                    child:
                        TextButton.icon(
                      onPressed: () =>
                          Clipboard.setData(
                        ClipboardData(
                          text:
                              _code!,
                        ),
                      ),

                      icon:
                          const Icon(
                        Icons.copy,
                      ),

                      label:
                          const Text(
                        'Copy QR',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}