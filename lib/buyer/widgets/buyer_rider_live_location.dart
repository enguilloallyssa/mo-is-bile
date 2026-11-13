import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../services/sari_api.dart';
import '../../services/sari_live_data.dart';
import '../buyer_theme.dart';

/// Live location is read only for an order owned by this Buyer.
/// Laravel returns null if the Rider opted out, stopped, or the point is stale.
class BuyerRiderLiveLocation extends StatefulWidget {
  const BuyerRiderLiveLocation({super.key, required this.orderId});
  final int orderId;

  @override
  State<BuyerRiderLiveLocation> createState() => _BuyerRiderLiveLocationState();
}

class _BuyerRiderLiveLocationState extends State<BuyerRiderLiveLocation>
    with WidgetsBindingObserver {
  Timer? _timer;
  bool _fetching = false;
  LatLng? _point;
  String? _updatedAt;
  String? _error;
  bool _firstLoad = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh();
    _timer = Timer.periodic(const Duration(seconds: 25), (_) => _refresh());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _timer ??= Timer.periodic(const Duration(seconds: 25), (_) => _refresh());
      _refresh();
    } else {
      _timer?.cancel();
      _timer = null;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _refresh() async {
    if (_fetching || !mounted) return;
    _fetching = true;
    try {
      final response = await SariLiveData.instance.buyerRiderLocation(widget.orderId);
      final data = response['data'];
      final raw = data is Map ? data['location'] : null;
      final location = raw is Map ? Map<String, dynamic>.from(raw) : null;
      final lat = (location?['latitude'] as num?)?.toDouble();
      final lng = (location?['longitude'] as num?)?.toDouble();
      final LatLng? point = lat != null && lng != null &&
              lat.isFinite && lng.isFinite && lat.abs() <= 90 && lng.abs() <= 180
          ? LatLng(lat, lng) : null;
      if (!mounted) return;
      setState(() {
        _point = point;
        _updatedAt = location?['recorded_at']?.toString();
        _error = null;
        _firstLoad = false;
      });
    } on SariApiException catch (e) {
      if (!mounted) return;
      setState(() {
        // 404 also means delivery not actively underway. Do not leak anything.
        _point = null;
        _error = e.statusCode == 404
            ? null
            : 'Unable to refresh live location. Swipe to retry.';
        _firstLoad = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _point = null;
        _error = 'Unable to refresh live location. Check your connection.';
        _firstLoad = false;
      });
    } finally {
      _fetching = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = _point;
    return Container(
      margin: const EdgeInsets.only(top: 16, bottom: 12),
      padding: const EdgeInsets.all(13),
      decoration: BuyerTheme.card(radius: 18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.location_on_rounded, color: BuyerTheme.goldDark, size: 20),
          const SizedBox(width: 8),
          const Expanded(child: Text('Rider live location',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14))),
          IconButton(onPressed: _refresh, tooltip: 'Refresh location',
              icon: const Icon(Icons.refresh_rounded, size: 20)),
        ]),
        if (_firstLoad)
          const Padding(padding: EdgeInsets.all(14),
              child: Center(child: CircularProgressIndicator()))
        else if (p == null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Text(_error ??
                'Rider location is currently unavailable. Live location only appears while an assigned rider is sharing during an active delivery.',
                style: const TextStyle(color: BuyerTheme.muted, fontSize: 12)),
          )
        else ...[
          SizedBox(
            height: 200,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(13),
              child: FlutterMap(
                key: ValueKey('buyer-rider-${p.latitude}-${p.longitude}'),
                options: MapOptions(initialCenter: p, initialZoom: 15),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.sari.marketplace',
                  ),
                  MarkerLayer(markers: [
                    Marker(point: p, width: 46, height: 46,
                        child: const Icon(Icons.delivery_dining_rounded,
                            color: BuyerTheme.goldDark, size: 42)),
                  ]),
                  const SimpleAttributionWidget(source: Text('© OpenStreetMap contributors',
                      style: TextStyle(fontSize: 9))),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text('Updated: ${_updatedAt ?? 'just now'}  •  Only available during active delivery',
              style: const TextStyle(color: BuyerTheme.muted, fontSize: 10)),
        ],
      ]),
    );
  }
}
