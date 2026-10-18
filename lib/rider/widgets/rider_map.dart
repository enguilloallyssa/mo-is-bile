import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/rider_delivery_model.dart';
import '../rider_navigation_screen.dart';

class RiderMap extends StatefulWidget {
  final RiderDelivery delivery;
  final double height;

  const RiderMap({
    super.key,
    required this.delivery,
    this.height = 265,
  });

  @override
  State<RiderMap> createState() => _RiderMapState();
}

class _RiderMapState extends State<RiderMap> {
  bool _tileLoadFailed = false;

  LatLng get _riderPoint => LatLng(
        widget.delivery.riderLatitude,
        widget.delivery.riderLongitude,
      );

  LatLng get _sellerPoint => LatLng(
        widget.delivery.pickupLatitude,
        widget.delivery.pickupLongitude,
      );

  LatLng get _buyerPoint => LatLng(
        widget.delivery.buyerLatitude,
        widget.delivery.buyerLongitude,
      );

  LatLng get _destinationPoint => LatLng(
        widget.delivery.destinationLatitude,
        widget.delivery.destinationLongitude,
      );

  @override
  Widget build(BuildContext context) {
    final bool goingToBuyer = widget.delivery.isHeadingToBuyer;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFEADFC9),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: goingToBuyer
                        ? const Color(0xFFEAF3ED)
                        : const Color(0xFFFFF2D8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    goingToBuyer
                        ? Icons.home_outlined
                        : Icons.storefront_outlined,
                    size: 18,
                    color: goingToBuyer
                        ? const Color(0xFF4F7D63)
                        : const Color(0xFFD99600),
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.delivery.mapStageLabel,
                        style: const TextStyle(
                          color: Color(0xFFA8731F),
                          fontSize: 6.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: .7,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        widget.delivery.destinationName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF211D17),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.delivery.destinationAddress,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF817769),
                          fontSize: 7,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F7F4),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFD9E5DC),
                    ),
                  ),
                  child: const Text(
                    'OPENSTREETMAP',
                    style: TextStyle(
                      color: Color(0xFF4F7D63),
                      fontSize: 5.8,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            height: 1,
            color: Color(0xFFEADFC9),
          ),
          SizedBox(
            height: widget.height,
            child: Stack(
              children: [
                Positioned.fill(
                  child: FlutterMap(
                    key: ValueKey<String>(
                      'osm-${widget.delivery.id}-${widget.delivery.status}',
                    ),
                    options: MapOptions(
                      initialCenter: _destinationPoint,
                      initialZoom: 14.5,
                      minZoom: 3,
                      maxZoom: 19,
                      backgroundColor: const Color(0xFFF2EFE9),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.sari.marketplace',
                        tileProvider: NetworkTileProvider(),
                        maxNativeZoom: 19,
                        panBuffer: 0,
                        retinaMode: false,
                        evictErrorTileStrategy:
                            EvictErrorTileStrategy.dispose,
                        errorTileCallback: (
                          TileImage tile,
                          Object error,
                          StackTrace? stackTrace,
                        ) {
                          if (_tileLoadFailed || !mounted) return;

                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (!mounted || _tileLoadFailed) return;
                            setState(() {
                              _tileLoadFailed = true;
                            });
                          });
                        },
                      ),
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: [
                              _riderPoint,
                              _destinationPoint,
                            ],
                            strokeWidth: 4,
                            color: const Color(0xFF3C6E91),
                          ),
                        ],
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _riderPoint,
                            width: 52,
                            height: 52,
                            alignment: Alignment.topCenter,
                            child: _marker(
                              icon: Icons.two_wheeler,
                              background: const Color(0xFF3C6E91),
                              label: 'Rider',
                            ),
                          ),
                          Marker(
                            point: _sellerPoint,
                            width: 52,
                            height: 52,
                            alignment: Alignment.topCenter,
                            child: _marker(
                              icon: Icons.storefront_outlined,
                              background: const Color(0xFFD99600),
                              label: 'Seller',
                            ),
                          ),
                          Marker(
                            point: _buyerPoint,
                            width: 52,
                            height: 52,
                            alignment: Alignment.topCenter,
                            child: _marker(
                              icon: Icons.home_outlined,
                              background: const Color(0xFF4F7D63),
                              label: 'Buyer',
                            ),
                          ),
                        ],
                      ),
                      const SimpleAttributionWidget(
                        source: Text(
                          '© OpenStreetMap contributors',
                          style: TextStyle(
                            fontSize: 9,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_tileLoadFailed)
                  Positioned(
                    left: 10,
                    right: 10,
                    top: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDECEC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFFF2C6C6),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.wifi_off_rounded,
                            size: 15,
                            color: Color(0xFFAA4D4D),
                          ),
                          SizedBox(width: 7),
                          Expanded(
                            child: Text(
                              'Map tiles could not load. Check Android INTERNET permission and device connection.',
                              style: TextStyle(
                                color: Color(0xFF7D3F3F),
                                fontSize: 7,
                                fontWeight: FontWeight.w700,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(13, 10, 13, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      goingToBuyer
                          ? Icons.delivery_dining_outlined
                          : Icons.inventory_2_outlined,
                      size: 14,
                      color: goingToBuyer
                          ? const Color(0xFF4F7D63)
                          : const Color(0xFFD99600),
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        goingToBuyer
                            ? 'Package picked up. The map is now focused on the Buyer delivery location.'
                            : 'Follow the map to the Seller pickup point. After pickup, it switches to the Buyer.',
                        style: const TextStyle(
                          color: Color(0xFF817769),
                          fontSize: 7,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => RiderNavigationScreen(
                          delivery: widget.delivery,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3C6E91),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    minimumSize: const Size.fromHeight(42),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                  icon: const Icon(
                    Icons.navigation_rounded,
                    size: 17,
                  ),
                  label: Text(
                    goingToBuyer
                        ? 'Navigate to Buyer'
                        : 'Navigate to Seller',
                    style: const TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _marker({
    required IconData icon,
    required Color background,
    required String label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: background,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 2,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 16,
          ),
        ),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .94),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF3D372F),
              fontSize: 5.8,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
