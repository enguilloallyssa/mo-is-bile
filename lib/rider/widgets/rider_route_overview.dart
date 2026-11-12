import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/rider_delivery_model.dart';
import 'rider_map.dart';
import 'rider_ui.dart';

/// An interactive OSM overview. Real assignment coordinates take precedence;
/// no route, rider position, or ETA is fabricated for empty assignments.
class RiderRouteOverview extends StatefulWidget {
  const RiderRouteOverview({super.key, this.delivery});

  final RiderDelivery? delivery;

  @override
  State<RiderRouteOverview> createState() => _RiderRouteOverviewState();
}

class _RiderRouteOverviewState extends State<RiderRouteOverview> {
  final MapController _controller = MapController();
  static const _philippines = LatLng(12.8797, 121.7740);
  bool _mapReady = false;

  bool _hasLocation(RiderDelivery delivery) {
    bool valid(double lat, double lng) =>
        lat.abs() > .001 && lng.abs() > .001 && lat.abs() <= 90 && lng.abs() <= 180;
    return valid(delivery.buyerLatitude, delivery.buyerLongitude) ||
        valid(delivery.pickupLatitude, delivery.pickupLongitude) ||
        valid(delivery.destinationLatitude, delivery.destinationLongitude);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final delivery = widget.delivery;
    if (delivery != null && _hasLocation(delivery)) {
      return RiderMap(
        key: ValueKey('route-${delivery.id}'),
        delivery: delivery,
        height: 230,
      );
    }

    return RiderSurface(
      padding: EdgeInsets.zero,
      shadow: true,
      radius: 22,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 15, 15, 13),
              child: Row(
                children: [
                  Container(
                    width: 43,
                    height: 43,
                    decoration: BoxDecoration(
                      color: RiderColors.goldSoft,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Icon(Icons.map_outlined, color: RiderColors.goldDark, size: 23),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Delivery route overview',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: RiderColors.text, fontSize: 13, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          delivery == null ? 'Awaiting your next assignment' : 'Location details not yet available',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: RiderColors.muted, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  RiderStatusPill(
                    label: 'OSM',
                    icon: Icons.public_rounded,
                    color: RiderColors.green,
                    background: RiderColors.greenSoft,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 235,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: FlutterMap(
                      mapController: _controller,
                      options: MapOptions(
                        initialCenter: _philippines,
                        initialZoom: 5.4,
                        minZoom: 3,
                        maxZoom: 18,
                        backgroundColor: RiderColors.surfaceSoft,
                        onMapReady: () {
                          if (mounted) setState(() => _mapReady = true);
                        },
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.sari.marketplace',
                        ),
                        const SimpleAttributionWidget(
                          source: Text('© OpenStreetMap contributors', style: TextStyle(fontSize: 9)),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 12,
                    top: 12,
                    right: 65,
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: RiderColors.surface,
                          borderRadius: BorderRadius.circular(13),
                          boxShadow: const [BoxShadow(color: Color(0x16000000), blurRadius: 14)],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.info_outline_rounded, color: RiderColors.goldDark, size: 17),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'Your next stop appears after dispatch.',
                                style: TextStyle(color: RiderColors.text, fontSize: 11, height: 1.35),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 12,
                    bottom: 22,
                    child: Column(
                      children: [
                        _zoom(Icons.add_rounded, true),
                        const SizedBox(height: 6),
                        _zoom(Icons.remove_rounded, false),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 17, color: RiderColors.goldDark),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      delivery == null
                          ? 'No active route yet. Your map updates with assigned work.'
                          : 'The destination will appear when coordinates are available.',
                      style: TextStyle(color: RiderColors.muted, fontSize: 11.5, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _zoom(IconData icon, bool zoomIn) => Material(
        color: RiderColors.surface,
        borderRadius: BorderRadius.circular(12),
        elevation: 2,
        child: IconButton(
          icon: Icon(icon, size: 21, color: RiderColors.text),
          tooltip: zoomIn ? 'Zoom in' : 'Zoom out',
          constraints: const BoxConstraints(minWidth: 42, minHeight: 42),
          onPressed: !_mapReady
              ? null
              : () {
                  final camera = _controller.camera;
                  final nextZoom = (camera.zoom + (zoomIn ? 1 : -1)).clamp(3.0, 18.0);
                  _controller.move(camera.center, nextZoom.toDouble());
                },
        ),
      );
}
