import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../services/sari_live_data.dart';
import 'widgets/logistics_ui.dart';

/// Provider-scoped riders only. Backend filters by logistics account.
class LogisticsRiderLocations extends StatefulWidget {
  const LogisticsRiderLocations({super.key});
  @override
  State<LogisticsRiderLocations> createState() => _LogisticsRiderLocationsState();
}

class _LogisticsRiderLocationsState extends State<LogisticsRiderLocations> {
  List<Map<String, dynamic>> _riders = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    if (mounted) setState(() { _loading = true; _error = null; });
    try {
      final response = await SariLiveData.instance.logisticsRiders();
      final data = response['data'];
      final rows = data is Map ? data['items'] : null;
      if (!mounted) return;
      setState(() => _riders = rows is List
          ? rows.whereType<Map>().map((r) => Map<String, dynamic>.from(r)).toList()
          : []);
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    } finally { if (mounted) setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: LogisticsPalette.canvas,
    appBar: AppBar(title: const Text('Live Rider Monitoring')),
    body: RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const LogisticsSectionTitle(
            title: 'Rider locations',
            subtitle: 'Only currently shared and authorized positions are shown.',
          ),
          const SizedBox(height: 13),
          if (_loading) const LinearProgressIndicator(),
          if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
          if (_riders.isEmpty && !_loading && _error == null)
            const Text('No active riders found.'),
          ..._riders.map((rider) {
            final id = (rider['id'] as num?)?.toInt() ?? 0;
            final name = [rider['first_name'], rider['last_name']]
                .where((s) => (s?.toString() ?? '').trim().isNotEmpty)
                .map((s) => s.toString()).join(' ');
            return Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: LogisticsSurface(child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.two_wheeler_rounded)),
                title: Text(name.isEmpty ? 'Rider #$id' : name),
                subtitle: Text(rider['email']?.toString() ?? ''),
                trailing: const Icon(Icons.map_outlined),
                enabled: id > 0,
                onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                  builder: (_) => _RiderLocationDetails(riderId: id, name: name),
                )),
              )),
            );
          }),
        ],
      ),
    ),
  );
}

class _RiderLocationDetails extends StatefulWidget {
  const _RiderLocationDetails({required this.riderId, required this.name});
  final int riderId;
  final String name;
  @override
  State<_RiderLocationDetails> createState() => _RiderLocationDetailsState();
}

class _RiderLocationDetailsState extends State<_RiderLocationDetails>
    with WidgetsBindingObserver {
  Timer? _timer;
  LatLng? _point;
  String? _recordedAt;
  String? _message;
  bool _busy = false;

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
    } else { _timer?.cancel(); _timer = null; }
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _refresh() async {
    if (!mounted || _busy) return;
    _busy = true;
    try {
      final res = await SariLiveData.instance.logisticsRiderLocation(widget.riderId);
      final data = res['data'];
      final raw = data is Map ? data['location'] : null;
      final m = raw is Map ? Map<String, dynamic>.from(raw) : null;
      final lat = (m?['latitude'] as num?)?.toDouble();
      final lon = (m?['longitude'] as num?)?.toDouble();
      final LatLng? point = lat != null && lon != null && lat.abs() <= 90 &&
          lon.abs() <= 180 && lat.isFinite && lon.isFinite
          ? LatLng(lat, lon) : null;
      if (mounted) setState(() {
        _point = point;
        _recordedAt = m?['recorded_at']?.toString();
        _message = null;
      });
    } catch (_) {
      if (mounted) setState(() {
        _point = null;
        _message = 'Position unavailable. Retry when connected.';
      });
    } finally { _busy = false; }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: LogisticsPalette.canvas,
    appBar: AppBar(
      title: Text(widget.name.isEmpty ? 'Rider #${widget.riderId}' : widget.name),
      actions: [IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh_rounded))],
    ),
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: _point == null
          ? LogisticsSurface(child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('No live shared position',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Text(_message ?? 'The rider has not enabled sharing, is no longer on an active route, or the last GPS reading is stale.'),
              ],
            ))
          : Column(children: [
              LogisticsSurface(child: Text('Last reported: ${_recordedAt ?? 'Recently'}')),
              const SizedBox(height: 12),
              Expanded(child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: FlutterMap(
                  key: ValueKey('logistics-${_point!.latitude}-${_point!.longitude}'),
                  options: MapOptions(initialCenter: _point!, initialZoom: 15),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.sari.marketplace',
                    ),
                    MarkerLayer(markers: [Marker(point: _point!, width: 50, height: 50,
                      child: const Icon(Icons.delivery_dining_rounded,
                          color: Color(0xFFB8860B), size: 42))]),
                    const SimpleAttributionWidget(source: Text('© OpenStreetMap contributors')),
                  ],
                ),
              )),
            ]),
    ),
  );
}
