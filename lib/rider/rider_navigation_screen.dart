import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../services/sari_live_data.dart';
import '../services/sari_api.dart';
import 'models/rider_delivery_model.dart';
import 'services/rider_navigation_service.dart';
import 'widgets/rider_ui.dart';

class RiderNavigationScreen extends StatefulWidget {
  final RiderDelivery delivery;

  RiderNavigationScreen({
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

  // Sharing is OFF by default. Only the rider can enable it while navigating.
  bool _sharingGps = false;
  bool _sharingBusy = false;
  bool _gpsUploadInFlight = false;
  DateTime? _lastGpsUpload;
  String? _gpsShareMessage;


  String? _error;

  LatLng get _destination => LatLng(
        widget.delivery.destinationLatitude,
        widget.delivery.destinationLongitude,
      );

  String get _destinationLabel =>
      widget.delivery.destinationRoleLabel;

  @override
  void initState() {
    super.initState();
    _startNavigation();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    if (_sharingGps && widget.delivery.id > 0) {
      // Closing navigation automatically stops sharing; no background tracking.
      unawaited(_stopSharingRemote().catchError((Object _) {}));
    }
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
        locationSettings: LocationSettings(
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
        locationSettings: LocationSettings(
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

    if (_sharingGps) {
      unawaited(_sendGpsLocation(position));
    }

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

  Future<void> _sendGpsLocation(Position position) async {
    if (!_sharingGps || _gpsUploadInFlight || widget.delivery.id <= 0) return;
    final now = DateTime.now();
    if (_lastGpsUpload != null &&
        now.difference(_lastGpsUpload!) < const Duration(seconds: 12)) return;
    // Accuracy >150m must not be submitted as a falsely precise reading.
    if (!position.accuracy.isFinite || position.accuracy > 150 ||
        position.accuracy < 0) {
      if (mounted) setState(() => _gpsShareMessage = 'Waiting for accurate GPS (150m or better)…');
      return;
    }
    _lastGpsUpload = now;
    _gpsUploadInFlight = true;
    try {
      await SariLiveData.instance.riderUploadLocation(
        assignmentType: 'order',
        assignmentId: widget.delivery.id,
        latitude: position.latitude,
        longitude: position.longitude,
        recordedAt: now,
        accuracyMeters: position.accuracy.round(),
      );
      if (mounted && _sharingGps) {
        setState(() => _gpsShareMessage = 'Sharing this active route with SARI');
      }
    } catch (error) {
      if (!mounted || !_sharingGps) return;
      // Stop explicitly if the route is no longer permitted by Laravel.
      if (error is SariApiException &&
          (error.statusCode == 401 || error.statusCode == 403 ||
              error.statusCode == 404 || error.statusCode == 422)) {
        setState(() {
          _sharingGps = false;
          _gpsShareMessage = 'Sharing stopped: route is no longer available.';
        });
        unawaited(_stopSharingRemote().catchError((Object _) {}));
      } else {
        setState(() => _gpsShareMessage = 'GPS upload failed. Retry when connected.');
      }
    } finally {
      _gpsUploadInFlight = false;
    }
  }

  Future<void> _stopSharingRemote() async {
    // An in-flight upload could otherwise arrive after DELETE and re-enable
    // sharing. Wait until it finishes, then send DELETE last.
    while (_gpsUploadInFlight) {
      await Future<void>.delayed(const Duration(milliseconds: 150));
    }
    if (widget.delivery.id <= 0) return;
    await SariLiveData.instance.riderStopLocation(
      assignmentType: 'order', assignmentId: widget.delivery.id,
    );
  }

  Future<void> _toggleGpsSharing() async {
    if (_sharingBusy || widget.delivery.id <= 0) return;
    if (_sharingGps) {
      setState(() {
        _sharingGps = false;
        _sharingBusy = true;
      });
      try {
        await _stopSharingRemote();
        if (mounted) setState(() => _gpsShareMessage = 'Live location sharing is off');
      } catch (error) {
        if (mounted) setState(() => _gpsShareMessage = 'Could not stop sharing on server: $error');
      } finally {
        if (mounted) setState(() => _sharingBusy = false);
      }
      return;
    }
    final enable = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Share live location?'),
        content: const Text('While this navigation screen is open, SARI can share your position for this active delivery with its buyer and assigned logistics provider. Sharing stops when you leave navigation or turn it off.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Not now')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Start sharing')),
        ],
      ),
    );
    if (enable != true || !mounted) return;
    setState(() {
      _sharingGps = true;
      _sharingBusy = true;
      _gpsShareMessage = 'Starting location sharing…';
    });
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw StateError('Turn on phone location services first.');
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw StateError('Location permission is required.');
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      await _sendGpsLocation(position);
    } catch (error) {
      if (mounted) {
        setState(() {
          _sharingGps = false;
          _gpsShareMessage = error.toString();
        });
      }
    } finally {
      if (mounted) setState(() => _sharingBusy = false);
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
            Duration(seconds: 15)) {
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
        padding: EdgeInsets.fromLTRB(
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
      backgroundColor: RiderColors.bg,
      appBar: AppBar(
        backgroundColor: RiderColors.surface,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Navigate to $_destinationLabel',
              style: TextStyle(
                color: RiderColors.text,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              widget.delivery.destinationName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: RiderColors.muted,
                fontSize: 10.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: _sharingGps ? 'Stop sharing live GPS' : 'Share live GPS (off by default)',
            onPressed: _sharingBusy ? null : _toggleGpsSharing,
            icon: Icon(_sharingGps ? Icons.location_on_rounded : Icons.location_off_outlined,
              color: _sharingGps ? RiderColors.green : RiderColors.muted),
          ),
          RiderTopActionButton(
            tooltip: 'Fit route',
            onPressed: _fitRoute,
            icon: Icons.route_outlined,
            accent: RiderColors.blue,
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
                    RiderColors.surfaceSoft,
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
                          RiderColors.blue,
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
                          color: RiderColors.blue,
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
                        child: Icon(
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
                            color: widget.delivery.isHeadingToBuyer
                                ? RiderColors.green
                                : widget.delivery.isHeadingToSortingCenter
                                    ? RiderColors.blue
                                    : RiderColors.gold,
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
                                EdgeInsets
                                    .symmetric(
                              horizontal: 5,
                              vertical: 2,
                            ),
                            decoration:
                                BoxDecoration(
                              color:
                                  RiderColors.surfaceElevated,
                              borderRadius:
                                  BorderRadius
                                      .circular(5),
                            ),
                            child: Text(
                              _destinationLabel,
                              style:
                                  TextStyle(
                                color: RiderColors.text,
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
                SimpleAttributionWidget(
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
          if (RiderColors.isDark)
            Positioned.fill(
              child: IgnorePointer(
                child: ColoredBox(
                  color: Color(0x32111D24),
                ),
              ),
            ),
          Positioned(
            left: 12,
            right: 12,
            top: 12,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _routeSummaryCard(),
                if (_gpsShareMessage != null || _sharingGps)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: RiderColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _gpsShareMessage ?? 'Live GPS sharing enabled',
                      style: TextStyle(color: RiderColors.text, fontSize: 11),
                    ),
                  ),
              ],
            ),
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
                      RiderColors.surfaceElevated,
                  foregroundColor: RiderColors.blue,
                  elevation: 4,
                  child: Icon(
                    _followRider
                        ? Icons
                            .my_location
                        : Icons
                            .location_searching,
                  ),
                ),
                SizedBox(height: 8),
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
                      RiderColors.surfaceElevated,
                  foregroundColor: RiderColors.goldDark,
                  elevation: 4,
                  child: Icon(
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
            Positioned.fill(
              child: ColoredBox(
                color: RiderColors.overlay,
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
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            RiderColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: RiderColors.border,
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
          RiderIconBadge(
            icon: Icons.navigation_rounded,
            color: RiderColors.blue,
            background: RiderColors.blueSoft,
            size: 40,
            iconSize: 21,
            radius: 12,
          ),
          SizedBox(width: 10),
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
                  style: TextStyle(
                    color: RiderColors.text,
                    fontSize: 10.5,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  widget.delivery
                      .destinationAddress,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: TextStyle(
                    color: RiderColors.muted,
                    fontSize: 7,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
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
                style: TextStyle(
                  color: RiderColors.text,
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
                style: TextStyle(
                  color: RiderColors.muted,
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
        padding: EdgeInsets.fromLTRB(
          15,
          13,
          15,
          14,
        ),
        decoration: BoxDecoration(
          color: RiderColors.surface,
          border: Border(
            top: BorderSide(
              color: RiderColors.border,
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
                    EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color:
                      RiderColors.redSoft,
                  borderRadius:
                      BorderRadius.circular(10),
                ),
                child: Text(
                  _error!,
                  style: TextStyle(
                    color:
                        RiderColors.red,
                    fontSize: 7.5,
                    height: 1.4,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: 8),
            ],
            Text(
              'NEXT DIRECTION',
              style: TextStyle(
                color: RiderColors.goldDark,
                fontSize: 6.5,
                fontWeight: FontWeight.w800,
                letterSpacing: .7,
              ),
            ),
            SizedBox(height: 4),
            Text(
              firstStep?.instruction ??
                  (_loading
                      ? 'Getting your current location and route...'
                      : 'Follow the highlighted route to the destination.'),
              style: TextStyle(
                color: RiderColors.text,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
            if (firstStep != null &&
                firstStep.distanceMeters > 0) ...[
              SizedBox(height: 3),
              Text(
                'In ${_distanceLabel(firstStep.distanceMeters)}',
                style: TextStyle(
                  color: RiderColors.muted,
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
