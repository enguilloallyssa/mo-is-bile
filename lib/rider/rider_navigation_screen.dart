import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import 'models/rider_delivery_model.dart';
import 'services/rider_navigation_service.dart';

class RiderNavigationScreen extends StatefulWidget {
  final RiderDelivery delivery;

  const RiderNavigationScreen({
    super.key,
    required this.delivery,
  });

  @override
  State<RiderNavigationScreen> createState() =>
      _RiderNavigationScreenState();
}

class _RiderNavigationScreenState
    extends State<RiderNavigationScreen> {
  final MapController _mapController = MapController();

  StreamSubscription<Position>? _positionSubscription;

  LatLng? _currentPosition;
  RiderRouteResult? _route;
  LatLng? _lastRouteOrigin;
  DateTime? _lastRouteRequestAt;

  bool _loading = true;
  bool _mapReady = false;
  bool _followRider = true;

  String? _error;

  LatLng get _destination => LatLng(
        widget.delivery.destinationLatitude,
        widget.delivery.destinationLongitude,
      );

  String get _destinationLabel =>
      widget.delivery.isHeadingToBuyer
          ? 'Buyer'
          : 'Seller';

  @override
  void initState() {
    super.initState();
    _startNavigation();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _startNavigation() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final serviceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        throw Exception(
          'Location/GPS is turned off. Enable Location on your phone.',
        );
      }

      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        throw Exception(
          'Location permission was denied.',
        );
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(
          'Location permission is permanently denied. Enable it in app settings.',
        );
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      final current = LatLng(
        position.latitude,
        position.longitude,
      );

      if (!mounted) return;

      setState(() {
        _currentPosition = current;
      });

      await _loadRoute(
        current,
        fitRoute: true,
      );

      _positionSubscription =
          Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      ).listen(
        _onPositionChanged,
        onError: (Object error) {
          if (!mounted) return;
          setState(() {
            _error = 'GPS update failed: $error';
          });
        },
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _error = error.toString().replaceFirst(
              'Exception: ',
              '',
            );
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _onPositionChanged(
    Position position,
  ) async {
    final current = LatLng(
      position.latitude,
      position.longitude,
    );

    if (!mounted) return;

    setState(() {
      _currentPosition = current;
    });

    if (_followRider && _mapReady) {
      _mapController.move(
        current,
        17,
      );
    }

    if (_shouldRecalculateRoute(current)) {
      await _loadRoute(
        current,
        fitRoute: false,
      );
    }
  }

  bool _shouldRecalculateRoute(
    LatLng current,
  ) {
    final previous = _lastRouteOrigin;

    if (previous == null) return true;

    final lastRequest = _lastRouteRequestAt;

    if (lastRequest != null &&
        DateTime.now().difference(lastRequest) <
            const Duration(seconds: 15)) {
      return false;
    }

    final meters = Geolocator.distanceBetween(
      previous.latitude,
      previous.longitude,
      current.latitude,
      current.longitude,
    );

    return meters >= 75;
  }

  Future<void> _loadRoute(
    LatLng current, {
    required bool fitRoute,
  }) async {
    try {
      _lastRouteRequestAt = DateTime.now();

      final route =
          await RiderNavigationService.getDrivingRoute(
        start: current,
        destination: _destination,
      );

      if (!mounted) return;

      setState(() {
        _route = route;
        _lastRouteOrigin = current;
        _error = null;
      });

      if (fitRoute && _mapReady) {
        _fitRoute();
      }
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _error =
            'Route unavailable: ${error.toString().replaceFirst('Exception: ', '')}';
      });
    }
  }

  void _fitRoute() {
    final current = _currentPosition;
    final route = _route;

    if (!_mapReady || current == null) return;

    final coordinates =
        route?.points.isNotEmpty == true
            ? route!.points
            : <LatLng>[
                current,
                _destination,
              ];

    _mapController.fitCamera(
      CameraFit.coordinates(
        coordinates: coordinates,
        padding: const EdgeInsets.fromLTRB(
          45,
          130,
          45,
          220,
        ),
        maxZoom: 17,
      ),
    );
  }

  void _centerOnRider() {
    final current = _currentPosition;
    if (current == null || !_mapReady) return;

    setState(() {
      _followRider = true;
    });

    _mapController.move(
      current,
      17,
    );
  }

  @override
  Widget build(BuildContext context) {
    final current =
        _currentPosition ??
        LatLng(
          widget.delivery.riderLatitude,
          widget.delivery.riderLongitude,
        );

    final routePoints =
        _route?.points.isNotEmpty == true
            ? _route!.points
            : <LatLng>[
                current,
                _destination,
              ];

    return Scaffold(
      backgroundColor: const Color(0xFFFBF8F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFDF8),
        surfaceTintColor: Colors.transparent,
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Navigate to $_destinationLabel',
              style: const TextStyle(
                color: Color(0xFF211D17),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              widget.delivery.destinationName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF817769),
                fontSize: 8,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Fit route',
            onPressed: _fitRoute,
            icon: const Icon(
              Icons.route_outlined,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: current,
                initialZoom: 15,
                minZoom: 3,
                maxZoom: 19,
                backgroundColor:
                    const Color(0xFFF2EFE9),
                onMapReady: () {
                  _mapReady = true;
                  WidgetsBinding.instance
                      .addPostFrameCallback((_) {
                    if (!mounted) return;
                    _fitRoute();
                  });
                },
                onPositionChanged: (
                  MapCamera camera,
                  bool hasGesture,
                ) {
                  if (hasGesture && _followRider) {
                    setState(() {
                      _followRider = false;
                    });
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName:
                      'com.sari.marketplace',
                  tileProvider:
                      NetworkTileProvider(),
                  maxNativeZoom: 19,
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: routePoints,
                      strokeWidth: 6,
                      color:
                          const Color(0xFF3C6E91),
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: current,
                      width: 54,
                      height: 54,
                      alignment:
                          Alignment.center,
                      child: Container(
                        decoration:
                            BoxDecoration(
                          color: const Color(
                            0xFF3C6E91,
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 3,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color:
                                  Color(0x33000000),
                              blurRadius: 7,
                              offset:
                                  Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.two_wheeler,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                    Marker(
                      point: _destination,
                      width: 58,
                      height: 64,
                      alignment:
                          Alignment.topCenter,
                      child: Column(
                        mainAxisSize:
                            MainAxisSize.min,
                        children: [
                          Icon(
                            widget.delivery
                                    .isHeadingToBuyer
                                ? Icons
                                    .location_on
                                : Icons
                                    .location_on,
                            color: widget.delivery
                                    .isHeadingToBuyer
                                ? const Color(
                                    0xFF4F7D63,
                                  )
                                : const Color(
                                    0xFFD99600,
                                  ),
                            size: 42,
                            shadows: const [
                              Shadow(
                                color: Color(
                                  0x44000000,
                                ),
                                blurRadius: 5,
                                offset:
                                    Offset(0, 2),
                              ),
                            ],
                          ),
                          Container(
                            padding:
                                const EdgeInsets
                                    .symmetric(
                              horizontal: 5,
                              vertical: 2,
                            ),
                            decoration:
                                BoxDecoration(
                              color:
                                  Colors.white,
                              borderRadius:
                                  BorderRadius
                                      .circular(5),
                            ),
                            child: Text(
                              _destinationLabel,
                              style:
                                  const TextStyle(
                                color: Color(
                                  0xFF3D372F,
                                ),
                                fontSize: 6,
                                fontWeight:
                                    FontWeight
                                        .w700,
                              ),
                            ),
                          ),
                        ],
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
          Positioned(
            left: 12,
            right: 12,
            top: 12,
            child: _routeSummaryCard(),
          ),
          Positioned(
            right: 12,
            bottom: 178,
            child: Column(
              children: [
                FloatingActionButton.small(
                  heroTag:
                      'rider-nav-location',
                  onPressed: _centerOnRider,
                  backgroundColor:
                      Colors.white,
                  foregroundColor:
                      const Color(0xFF3C6E91),
                  child: Icon(
                    _followRider
                        ? Icons
                            .my_location
                        : Icons
                            .location_searching,
                  ),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag:
                      'rider-nav-refresh',
                  onPressed:
                      _currentPosition == null
                          ? null
                          : () => _loadRoute(
                                _currentPosition!,
                                fitRoute: true,
                              ),
                  backgroundColor:
                      Colors.white,
                  foregroundColor:
                      const Color(0xFF3C6E91),
                  child: const Icon(
                    Icons.refresh_rounded,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child:
                _instructionPanel(),
          ),
          if (_loading)
            const Positioned.fill(
              child: ColoredBox(
                color: Color(0x44FFFFFF),
                child: Center(
                  child:
                      CircularProgressIndicator(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _routeSummaryCard() {
    final route = _route;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            Colors.white.withValues(alpha: .96),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFEADFC9),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color:
                  const Color(0xFFEAF2F7),
              borderRadius:
                  BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.navigation_rounded,
              color: Color(0xFF3C6E91),
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  widget.delivery
                      .destinationName,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF211D17),
                    fontSize: 10.5,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  widget.delivery
                      .destinationAddress,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF817769),
                    fontSize: 7,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment:
                CrossAxisAlignment.end,
            children: [
              Text(
                route == null
                    ? '--'
                    : _distanceLabel(
                        route.distanceMeters,
                      ),
                style: const TextStyle(
                  color: Color(0xFF211D17),
                  fontSize: 11,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
              Text(
                route == null
                    ? 'Route'
                    : _durationLabel(
                        route.durationSeconds,
                      ),
                style: const TextStyle(
                  color: Color(0xFF817769),
                  fontSize: 7,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _instructionPanel() {
    final route = _route;
    final firstStep =
        route?.steps.isNotEmpty == true
            ? route!.steps.first
            : null;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          15,
          13,
          15,
          14,
        ),
        decoration: const BoxDecoration(
          color: Color(0xFFFFFDF8),
          border: Border(
            top: BorderSide(
              color: Color(0xFFEADFC9),
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_error != null) ...[
              Container(
                padding:
                    const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color:
                      const Color(0xFFFDECEC),
                  borderRadius:
                      BorderRadius.circular(10),
                ),
                child: Text(
                  _error!,
                  style: const TextStyle(
                    color:
                        Color(0xFF9A4D4D),
                    fontSize: 7.5,
                    height: 1.4,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
            const Text(
              'NEXT DIRECTION',
              style: TextStyle(
                color: Color(0xFFA8731F),
                fontSize: 6.5,
                fontWeight: FontWeight.w800,
                letterSpacing: .7,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              firstStep?.instruction ??
                  (_loading
                      ? 'Getting your current location and route...'
                      : 'Follow the highlighted route to the destination.'),
              style: const TextStyle(
                color: Color(0xFF211D17),
                fontSize: 12,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
            if (firstStep != null &&
                firstStep.distanceMeters > 0) ...[
              const SizedBox(height: 3),
              Text(
                'In ${_distanceLabel(firstStep.distanceMeters)}',
                style: const TextStyle(
                  color: Color(0xFF817769),
                  fontSize: 7.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _distanceLabel(double meters) {
    if (meters < 1000) {
      return '${meters.round()} m';
    }

    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  String _durationLabel(double seconds) {
    final minutes = (seconds / 60).ceil();

    if (minutes < 60) {
      return '$minutes min';
    }

    final hours = minutes ~/ 60;
    final remaining = minutes % 60;

    if (remaining == 0) {
      return '$hours hr';
    }

    return '$hours hr $remaining min';
  }
}
