import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'widgets/rider_ui.dart';

class RiderScanner extends StatefulWidget {
  /// Optional parcel code when opening the scanner
  /// from a specific Rider assignment.
  final String? expectedCode;

  /// Optional page title.
  final String title;

  const RiderScanner({
    super.key,
    this.expectedCode,
    this.title = 'Parcel Scanner',
  });

  @override
  State<RiderScanner> createState() =>
      _RiderScannerState();
}

class _RiderScannerState extends State<RiderScanner> {
  final MobileScannerController _controller =
      MobileScannerController(
    formats: const [
      BarcodeFormat.qrCode,
      BarcodeFormat.code128,
      BarcodeFormat.code39,
      BarcodeFormat.code93,
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
    ],
  );

  bool _handled = false;
  bool _torchEnabled = false;

  String? _lastScannedCode;
  String? _errorMessage;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _normalize(
    String value,
  ) {
    return value
        .trim()
        .toUpperCase();
  }

  bool get _hasExpectedCode {
    return widget.expectedCode
            ?.trim()
            .isNotEmpty ==
        true;
  }

  bool _matchesExpected(
    String code,
  ) {
    if (!_hasExpectedCode) {
      return true;
    }

    return _normalize(code) ==
        _normalize(
          widget.expectedCode!,
        );
  }

  void _onDetect(
    BarcodeCapture capture,
  ) {
    if (_handled) {
      return;
    }

    for (final barcode
        in capture.barcodes) {
      final raw =
          barcode.rawValue;

      if (raw == null ||
          raw.trim().isEmpty) {
        continue;
      }

      final code =
          raw.trim();

      setState(() {
        _lastScannedCode = code;
      });

      if (!_matchesExpected(
        code,
      )) {
        setState(() {
          _errorMessage =
              'This parcel does not match the expected assignment.';
        });

        return;
      }

      _handled = true;

      Navigator.of(context).pop(
        code,
      );

      return;
    }
  }

  Future<void> _toggleTorch()
      async {
    await _controller.toggleTorch();

    if (!mounted) {
      return;
    }

    setState(() {
      _torchEnabled =
          !_torchEnabled;
    });
  }

  Future<void> _switchCamera()
      async {
    await _controller.switchCamera();
  }

  void _clearMismatch() {
    setState(() {
      _lastScannedCode = null;
      _errorMessage = null;
      _handled = false;
    });
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          Colors.black,
      appBar: AppBar(
        backgroundColor:
            Colors.black,
        foregroundColor:
            Colors.white,
        surfaceTintColor:
            Colors.black,
        elevation: 0,
        title: Text(
          widget.title,
          style:
              const TextStyle(
            fontSize: 17,
            fontWeight:
                FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            tooltip:
                _torchEnabled
                    ? 'Turn flash off'
                    : 'Turn flash on',
            onPressed:
                _toggleTorch,
            icon: Icon(
              _torchEnabled
                  ? Icons
                      .flash_on_rounded
                  : Icons
                      .flash_off_rounded,
            ),
          ),
          IconButton(
            tooltip:
                'Switch camera',
            onPressed:
                _switchCamera,
            icon:
                const Icon(
              Icons
                  .cameraswitch_rounded,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _header(),

            Expanded(
              child:
                  _scannerArea(),
            ),

            _footer(),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.fromLTRB(
        20,
        14,
        20,
        18,
      ),
      color:
          Colors.black,
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            alignment:
                Alignment.center,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFFE8AF), Color(0xFFD69A31)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD69A31).withValues(alpha: .20),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(
              Icons.qr_code_scanner_rounded,
              color: Color(0xFF1B1914),
              size: 27,
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          const Text(
            'Scan SARI Parcel',
            textAlign:
                TextAlign.center,
            style:
                TextStyle(
              color:
                  Colors.white,
              fontSize: 21,
              fontWeight:
                  FontWeight.w900,
            ),
          ),

          const SizedBox(
            height: 6,
          ),

          Text(
            _hasExpectedCode
                ? 'Scan the QR or barcode assigned to this parcel.'
                : 'Scan an assigned SARI parcel QR or barcode.',
            textAlign:
                TextAlign.center,
            style:
                const TextStyle(
              color:
                  Colors.white70,
              fontSize: 11,
              height: 1.5,
            ),
          ),

          if (_hasExpectedCode) ...[
            const SizedBox(
              height: 12,
            ),

            Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 7,
              ),
              decoration:
                  BoxDecoration(
                color:
                    Colors.white
                        .withValues(
                  alpha: .10,
                ),
                borderRadius:
                    BorderRadius.circular(
                  20,
                ),
                border:
                    Border.all(
                  color:
                      Colors.white24,
                ),
              ),
              child: Text(
                'Expected: ${widget.expectedCode}',
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,
                style:
                    const TextStyle(
                  color:
                      Colors.white,
                  fontSize: 9,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _scannerArea() {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 17,
      ),
      child: Stack(
        alignment:
            Alignment.center,
        children: [
          ClipRRect(
            borderRadius:
                BorderRadius.circular(
              22,
            ),
            child: MobileScanner(
              controller:
                  _controller,
              onDetect:
                  _onDetect,
              errorBuilder:
                  (
                context,
                error,
              ) {
                return Container(
                  color:
                      const Color(
                    0xFF171717,
                  ),
                  alignment:
                      Alignment.center,
                  padding:
                      const EdgeInsets.all(
                    24,
                  ),
                  child:
                      const Column(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      Icon(
                        Icons
                            .camera_alt_outlined,
                        color:
                            Colors.white70,
                        size: 44,
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      Text(
                        'Camera unavailable',
                        style:
                            TextStyle(
                          color:
                              Colors.white,
                          fontSize:
                              16,
                          fontWeight:
                              FontWeight.w800,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        'Allow camera access to scan parcel QR and barcodes.',
                        textAlign:
                            TextAlign.center,
                        style:
                            TextStyle(
                          color:
                              Colors.white60,
                          fontSize:
                              10,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          IgnorePointer(
            child:
                Container(
              width: 245,
              height: 245,
              decoration:
                  BoxDecoration(
                borderRadius:
                    BorderRadius.circular(
                  24,
                ),
                border:
                    Border.all(
                  color:
                      Colors.white,
                  width: 2,
                ),
              ),
            ),
          ),

          IgnorePointer(
            child: SizedBox(
              width: 255,
              height: 255,
              child: Stack(
                children: [
                  _corner(
                    top: 0,
                    left: 0,
                  ),
                  _corner(
                    top: 0,
                    right: 0,
                    rotate: 1,
                  ),
                  _corner(
                    bottom: 0,
                    right: 0,
                    rotate: 2,
                  ),
                  _corner(
                    bottom: 0,
                    left: 0,
                    rotate: 3,
                  ),
                ],
              ),
            ),
          ),

          if (_errorMessage !=
              null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 18,
              child:
                  Container(
                padding:
                    const EdgeInsets.all(
                  13,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      const Color(
                    0xFFB84747,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    13,
                  ),
                ),
                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons
                          .error_outline_rounded,
                      color:
                          Colors.white,
                      size: 20,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child:
                          Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Wrong Parcel',
                            style:
                                TextStyle(
                              color:
                                  Colors.white,
                              fontSize:
                                  11,
                              fontWeight:
                                  FontWeight.w800,
                            ),
                          ),
                          const SizedBox(
                            height: 3,
                          ),
                          Text(
                            _errorMessage!,
                            style:
                                const TextStyle(
                              color:
                                  Colors.white70,
                              fontSize:
                                  9,
                              height:
                                  1.4,
                            ),
                          ),
                          if (_lastScannedCode !=
                              null) ...[
                            const SizedBox(
                              height:
                                  4,
                            ),
                            Text(
                              'Scanned: $_lastScannedCode',
                              maxLines:
                                  1,
                              overflow:
                                  TextOverflow.ellipsis,
                              style:
                                  const TextStyle(
                                color:
                                    Colors.white60,
                                fontSize:
                                    8,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip:
                          'Scan again',
                      onPressed:
                          _clearMismatch,
                      icon:
                          const Icon(
                        Icons
                            .refresh_rounded,
                        color:
                            Colors.white,
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

  Widget _corner({
    double? top,
    double? bottom,
    double? left,
    double? right,
    int rotate = 0,
  }) {
    Widget child =
        Container(
      width: 37,
      height: 37,

      // IMPORTANT:
      // This cannot be const because
      // RiderColors.gold is theme-aware.
      decoration:
          BoxDecoration(
        border: Border(
          top: BorderSide(
            color:
                RiderColors.gold,
            width: 5,
          ),
          left: BorderSide(
            color:
                RiderColors.gold,
            width: 5,
          ),
        ),
      ),
    );

    for (var i = 0;
        i < rotate;
        i++) {
      child = RotatedBox(
        quarterTurns: 1,
        child: child,
      );
    }

    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: child,
    );
  }

  Widget _footer() {
    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.fromLTRB(
        22,
        17,
        22,
        20,
      ),
      color:
          Colors.black,
      child: Column(
        children: [
          const Text(
            'Position the parcel QR or barcode inside the frame.',
            textAlign:
                TextAlign.center,
            style:
                TextStyle(
              color:
                  Colors.white70,
              fontSize: 10,
              height: 1.5,
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          const Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Icon(
                Icons
                    .verified_user_outlined,
                color:
                    Colors.white54,
                size: 14,
              ),
              SizedBox(
                width: 5,
              ),
              Flexible(
                child: Text(
                  'Only scan parcels physically assigned to your Rider account.',
                  textAlign:
                      TextAlign.center,
                  style:
                      TextStyle(
                    color:
                        Colors.white54,
                    fontSize: 8,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}