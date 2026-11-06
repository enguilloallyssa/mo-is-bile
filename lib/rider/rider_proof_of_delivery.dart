import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/sari_live_data.dart';
import 'widgets/rider_ui.dart';

/// Actual proof-of-delivery screen used by both direct and last-mile workflows.
///
/// The Rider shell performs the parcel scan before opening this page. This
/// page uploads the evidence to the existing authenticated Rider API; only a
/// successful server response returns true to the delivery workflow.
class RiderProofOfDelivery extends StatefulWidget {
  const RiderProofOfDelivery({
    super.key,
    required this.orderId,
    required this.orderNumber,
    this.recipientName,
  });

  final int orderId;
  final String orderNumber;
  final String? recipientName;

  @override
  State<RiderProofOfDelivery> createState() => _RiderProofOfDeliveryState();
}

class _RiderProofOfDeliveryState extends State<RiderProofOfDelivery> {
  static const int _maxImageSize = 10 * 1024 * 1024;

  final ImagePicker _picker = ImagePicker();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _recipient;
  final TextEditingController _notes = TextEditingController();

  XFile? _photo;
  bool _capturing = false;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _recipient = TextEditingController(text: widget.recipientName ?? '');
  }

  @override
  void dispose() {
    _recipient.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _capture() async {
    if (_capturing || _submitting) return;
    setState(() {
      _capturing = true;
      _error = null;
    });

    try {
      final XFile? captured = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1800,
        maxHeight: 1800,
        requestFullMetadata: false,
      );
      if (captured == null || !mounted) return;

      final File file = File(captured.path);
      final int bytes = await file.length();
      if (bytes <= 0) {
        throw const FormatException('The captured image is empty. Try again.');
      }
      if (bytes > _maxImageSize) {
        throw const FormatException(
          'Photo exceeds 10 MB. Retake it at a lower resolution.',
        );
      }

      if (!mounted) return;
      setState(() => _photo = captured);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = 'Unable to capture photo: $error');
    } finally {
      if (mounted) setState(() => _capturing = false);
    }
  }

  Future<void> _submit() async {
    if (_submitting || _capturing) return;
    if (_photo == null) {
      setState(() => _error = 'Take a photo of the delivered parcel first.');
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final File image = File(_photo!.path);
    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      if (!await image.exists()) {
        throw const FormatException('Photo is no longer available. Retake it.');
      }
      final int bytes = await image.length();
      if (bytes <= 0 || bytes > _maxImageSize) {
        throw const FormatException('Invalid photo. Retake it and try again.');
      }

      final response = await SariLiveData.instance.riderProof(
        orderId: widget.orderId,
        photo: image,
        recipientName: _recipient.text.trim().isEmpty
            ? null
            : _recipient.text.trim(),
        notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      );

      // Never report POD success unless the server explicitly accepted it.
      final bool accepted = response['success'] == true;
      if (!accepted) {
        throw const FormatException(
          'Server did not confirm the proof upload. Please try again.',
        );
      }

      if (!mounted) return;
      // Unlock PopScope, allow the frame to rebuild, then return success.
      // This avoids an upload succeeding while a stale canPop=false blocks
      // the route from closing.
      setState(() => _submitting = false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pop(true);
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = 'Proof not uploaded: $error');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Widget _step(int number, String title, String subtitle, {bool done = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 29,
          height: 29,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: done ? RiderColors.greenSoft : RiderColors.goldSoft,
            borderRadius: BorderRadius.circular(10),
          ),
          child: done
              ? Icon(Icons.check_rounded, color: RiderColors.green, size: 17)
              : Text('$number',
                  style: TextStyle(
                    color: RiderColors.goldDark,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  )),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                    color: RiderColors.text,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  )),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: TextStyle(
                    color: RiderColors.muted,
                    fontSize: 10,
                    height: 1.4,
                  )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _photoArea() {
    final XFile? photo = _photo;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: RiderColors.surfaceSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: RiderColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 1.4,
            child: photo == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: RiderColors.goldSoft,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Icon(Icons.add_a_photo_outlined,
                            color: RiderColors.goldDark, size: 28),
                      ),
                      const SizedBox(height: 12),
                      Text('No delivery photo yet',
                          style: TextStyle(
                            color: RiderColors.text,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          )),
                      const SizedBox(height: 5),
                      Text('Photograph the parcel at the buyer drop-off.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: RiderColors.muted, fontSize: 10)),
                    ],
                  )
                : Image.file(
                    File(photo.path),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Center(
                      child: Text('Photo preview unavailable. Please retake.',
                          style: TextStyle(color: RiderColors.muted)),
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: OutlinedButton.icon(
              onPressed: _submitting || _capturing ? null : _capture,
              icon: _capturing
                  ? const SizedBox(
                      width: 17,
                      height: 17,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(photo == null
                      ? Icons.photo_camera_outlined
                      : Icons.refresh_rounded),
              label: Text(photo == null ? 'Take Delivery Photo' : 'Retake Photo'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(44),
                foregroundColor: RiderColors.goldDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _input(String label, String hint) => InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(13)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
      );

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_submitting,
      child: Scaffold(
        backgroundColor: RiderColors.bg,
        appBar: AppBar(
          title: const Text('Proof of Delivery'),
          backgroundColor: RiderColors.surface,
          foregroundColor: RiderColors.text,
          surfaceTintColor: Colors.transparent,
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              colors: RiderColors.heroGradient),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.all(19),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('DELIVERY EVIDENCE',
                                style: TextStyle(
                                    color: Colors.white70,
                                    letterSpacing: 1.2,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800)),
                            const SizedBox(height: 7),
                            Text(widget.orderNumber,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                )),
                            const SizedBox(height: 8),
                            const Text(
                              'Parcel verification completed. Capture the actual handoff evidence before finishing this delivery.',
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  height: 1.5),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: RiderColors.surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: RiderColors.border),
                        ),
                        child: Column(
                          children: [
                            _step(1, 'Parcel QR verified',
                                'The previous step matched the expected order.',
                                done: true),
                            const SizedBox(height: 15),
                            _step(2, 'Capture handoff photo',
                                'Take a clear photo at the buyer location.',
                                done: _photo != null),
                            const SizedBox(height: 15),
                            _step(3, 'Upload proof',
                                'Server confirmation is required before continuing.'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _photoArea(),
                      const SizedBox(height: 15),
                      Container(
                        decoration: BoxDecoration(
                          color: RiderColors.surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: RiderColors.border),
                        ),
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Delivery details',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: RiderColors.text,
                                )),
                            const SizedBox(height: 13),
                            TextFormField(
                              controller: _recipient,
                              enabled: !_submitting,
                              textCapitalization: TextCapitalization.words,
                              maxLength: 150,
                              decoration: _input('Recipient name (optional)',
                                  'Name of person who received the parcel'),
                              validator: (value) => (value?.trim().length ?? 0) > 150
                                  ? 'Maximum 150 characters.'
                                  : null,
                            ),
                            const SizedBox(height: 3),
                            TextFormField(
                              controller: _notes,
                              enabled: !_submitting,
                              maxLength: 1000,
                              minLines: 2,
                              maxLines: 4,
                              decoration: _input('Notes (optional)',
                                  'e.g. Handed directly to recipient'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: RiderColors.blueSoft,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.info_outline_rounded,
                                size: 17, color: RiderColors.blue),
                            const SizedBox(width: 9),
                            Expanded(
                              child: Text(
                                'Uploading proof does not mark an order delivered. The app will continue to COD confirmation (if required) and the server delivery-completion step afterward.',
                                style: TextStyle(
                                  color: RiderColors.text,
                                  fontSize: 10,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: RiderColors.redSoft,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _error!,
                            style: TextStyle(
                              color: RiderColors.red,
                              fontSize: 11,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(16, 11, 16, 12),
                decoration: BoxDecoration(
                  color: RiderColors.surface,
                  border: Border(top: BorderSide(color: RiderColors.border)),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _photo == null || _submitting || _capturing
                        ? null
                        : _submit,
                    icon: _submitting
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.cloud_upload_outlined),
                    label: Text(_submitting ? 'Uploading proof...' : 'Upload Proof & Continue'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      backgroundColor: RiderColors.gold,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
