import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/rider_delivery_model.dart';
import '../rider_navigation_screen.dart';
import 'rider_ui.dart';

class RiderMap extends StatefulWidget {
  final RiderDelivery delivery;
  final double height;

  RiderMap({super.key, required this.delivery, this.height = 255});

  @override
  State<RiderMap> createState() => _RiderMapState();
}

class _RiderMapState extends State<RiderMap> {
  bool _tileLoadFailed = false;

  LatLng get _riderPoint => LatLng(widget.delivery.riderLatitude, widget.delivery.riderLongitude);
  LatLng get _sellerPoint => LatLng(widget.delivery.pickupLatitude, widget.delivery.pickupLongitude);
  LatLng get _sortingPoint => LatLng(widget.delivery.sortingCenterLatitude, widget.delivery.sortingCenterLongitude);
  LatLng get _buyerPoint => LatLng(widget.delivery.buyerLatitude, widget.delivery.buyerLongitude);
  LatLng get _destinationPoint => LatLng(widget.delivery.destinationLatitude, widget.delivery.destinationLongitude);

  Color get _destinationColor {
    if (widget.delivery.isHeadingToBuyer) return RiderColors.green;
    if (widget.delivery.isHeadingToSortingCenter) return RiderColors.blue;
    return RiderColors.gold;
  }

  IconData get _destinationIcon {
    if (widget.delivery.isHeadingToBuyer) return Icons.home_outlined;
    if (widget.delivery.isHeadingToSortingCenter) return Icons.warehouse_outlined;
    return Icons.storefront_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return RiderSurface(
      padding: EdgeInsets.zero,
      shadow: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Padding(
            padding: EdgeInsets.fromLTRB(14, 13, 14, 11),
            child: Row(children: [
              Container(width: 40, height: 40, decoration: BoxDecoration(color: _destinationColor.withValues(alpha: .12), borderRadius: BorderRadius.circular(13)), child: Icon(_destinationIcon, color: _destinationColor, size: 21)),
              SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('NEXT STOP • ${widget.delivery.destinationRoleLabel.toUpperCase()}', style: TextStyle(color: _destinationColor, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: .55)),
                SizedBox(height: 3),
                Text(widget.delivery.destinationName, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: RiderColors.text, fontSize: 13, fontWeight: FontWeight.w900)),
                Text(widget.delivery.destinationAddress, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: RiderColors.muted, fontSize: 10)),
              ])),
              RiderStatusPill(label: 'OSM', color: RiderColors.green, background: RiderColors.greenSoft),
            ]),
          ),
          SizedBox(
            height: widget.height,
            child: Stack(children: [
              Positioned.fill(
                child: FlutterMap(
                  key: ValueKey('osm-${widget.delivery.id}-${widget.delivery.status}'),
                  options: MapOptions(initialCenter: _destinationPoint, initialZoom: 14.4, minZoom: 3, maxZoom: 19, backgroundColor: RiderColors.surfaceSoft),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.sari.marketplace',
                      tileProvider: NetworkTileProvider(),
                      maxNativeZoom: 19,
                      panBuffer: 0,
                      retinaMode: false,
                      evictErrorTileStrategy: EvictErrorTileStrategy.dispose,
                      errorTileCallback: (TileImage tile, Object error, StackTrace? stackTrace) {
                        if (_tileLoadFailed || !mounted) return;
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (!mounted || _tileLoadFailed) return;
                          setState(() => _tileLoadFailed = true);
                        });
                      },
                    ),
                    PolylineLayer(polylines: [Polyline(points: [_riderPoint, _destinationPoint], strokeWidth: 5, color: RiderColors.blue)]),
                    MarkerLayer(markers: [
                      Marker(point: _riderPoint, width: 58, height: 58, alignment: Alignment.topCenter, child: _marker(icon: Icons.two_wheeler, background: RiderColors.blue, label: 'You')),
                      Marker(point: _sellerPoint, width: 58, height: 58, alignment: Alignment.topCenter, child: _marker(icon: Icons.storefront_outlined, background: RiderColors.gold, label: 'Seller')),
                      Marker(point: _sortingPoint, width: 64, height: 58, alignment: Alignment.topCenter, child: _marker(icon: Icons.warehouse_outlined, background: RiderColors.blue, label: 'Sorting')),
                      Marker(point: _buyerPoint, width: 60, height: 58, alignment: Alignment.topCenter, child: _marker(icon: Icons.home_outlined, background: RiderColors.green, label: 'Buyer')),
                    ]),
                    SimpleAttributionWidget(source: Text('© OpenStreetMap contributors', style: TextStyle(fontSize: 9))),
                  ],
                ),
              ),
              if (RiderColors.isDark)
                Positioned.fill(
                  child: IgnorePointer(
                    child: ColoredBox(
                      color: Color(0x32111D24),
                    ),
                  ),
                ),
              if (_tileLoadFailed)
                Positioned(
                  left: 10,
                  right: 10,
                  top: 10,
                  child: Container(
                    padding: EdgeInsets.all(9),
                    decoration: BoxDecoration(color: RiderColors.redSoft, borderRadius: BorderRadius.circular(12), border: Border.all(color: RiderColors.red)),
                    child: Row(children: [
                      Icon(Icons.wifi_off_rounded, size: 16, color: RiderColors.red),
                      SizedBox(width: 7),
                      Expanded(child: Text('Map tiles could not load. Check connection and Android INTERNET permission.', style: TextStyle(color: RiderColors.red, fontSize: 10, fontWeight: FontWeight.w700))),
                    ]),
                  ),
                ),
            ]),
          ),
          Padding(
            padding: EdgeInsets.all(12),
            child: ElevatedButton.icon(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => RiderNavigationScreen(delivery: widget.delivery))),
              style: ElevatedButton.styleFrom(backgroundColor: RiderColors.blue, foregroundColor: Colors.white, elevation: 0, minimumSize: Size.fromHeight(46), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              icon: Icon(Icons.navigation_rounded, size: 18),
              label: Text('Navigate to ${widget.delivery.destinationRoleLabel}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _marker({required IconData icon, required Color background, required String label}) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 32, height: 32, decoration: BoxDecoration(color: background, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2), boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 6, offset: Offset(0, 2))]), child: Icon(icon, color: Colors.white, size: 17)),
      SizedBox(height: 2),
      Container(padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2), decoration: BoxDecoration(color: RiderColors.surfaceElevated.withValues(alpha: .95), borderRadius: BorderRadius.circular(6), border: Border.all(color: RiderColors.border)), child: Text(label, style: TextStyle(color: RiderColors.text, fontSize: 7, fontWeight: FontWeight.w800))),
    ]);
  }
}
