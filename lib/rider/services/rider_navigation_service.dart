import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class RiderRouteStep {
  final String instruction;
  final String roadName;
  final double distanceMeters;

  const RiderRouteStep({
    required this.instruction,
    required this.roadName,
    required this.distanceMeters,
  });
}

class RiderRouteResult {
  final List<LatLng> points;
  final double distanceMeters;
  final double durationSeconds;
  final List<RiderRouteStep> steps;

  const RiderRouteResult({
    required this.points,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.steps,
  });
}

class RiderNavigationService {
  // Development/demo endpoint.
  //
  // For production, replace this with your own OSRM/routing endpoint
  // or the same endpoint already used by your Laravel website.
  static const String _baseUrl = 'https://router.project-osrm.org';

  static Future<RiderRouteResult> getDrivingRoute({
    required LatLng start,
    required LatLng destination,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/route/v1/driving/'
      '${start.longitude},${start.latitude};'
      '${destination.longitude},${destination.latitude}'
      '?overview=full&geometries=geojson&steps=true',
    );

    final response = await http
        .get(
          uri,
          headers: const {
            'User-Agent': 'SARI-Rider/1.0',
            'Accept': 'application/json',
          },
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception(
        'Routing server returned ${response.statusCode}.',
      );
    }

    final body = jsonDecode(response.body);

    if (body is! Map<String, dynamic>) {
      throw Exception('Invalid routing response.');
    }

    if (body['code'] != 'Ok') {
      throw Exception(
        body['message']?.toString() ?? 'No route was found.',
      );
    }

    final routes = body['routes'];

    if (routes is! List || routes.isEmpty) {
      throw Exception('No route was found.');
    }

    final route = routes.first as Map<String, dynamic>;
    final geometry = route['geometry'] as Map<String, dynamic>;
    final coordinates = geometry['coordinates'] as List;

    final points = coordinates.map<LatLng>((coordinate) {
      final pair = coordinate as List;
      return LatLng(
        (pair[1] as num).toDouble(),
        (pair[0] as num).toDouble(),
      );
    }).toList();

    final steps = <RiderRouteStep>[];
    final legs = route['legs'];

    if (legs is List && legs.isNotEmpty) {
      final leg = legs.first as Map<String, dynamic>;
      final rawSteps = leg['steps'];

      if (rawSteps is List) {
        for (final raw in rawSteps) {
          final step = raw as Map<String, dynamic>;
          final maneuver =
              (step['maneuver'] as Map?)?.cast<String, dynamic>() ??
                  const <String, dynamic>{};

          final roadName = step['name']?.toString().trim() ?? '';
          final distance =
              (step['distance'] as num?)?.toDouble() ?? 0;

          steps.add(
            RiderRouteStep(
              instruction: _instructionFor(
                maneuver: maneuver,
                roadName: roadName,
              ),
              roadName: roadName,
              distanceMeters: distance,
            ),
          );
        }
      }
    }

    return RiderRouteResult(
      points: points,
      distanceMeters:
          (route['distance'] as num?)?.toDouble() ?? 0,
      durationSeconds:
          (route['duration'] as num?)?.toDouble() ?? 0,
      steps: steps,
    );
  }

  static String _instructionFor({
    required Map<String, dynamic> maneuver,
    required String roadName,
  }) {
    final type = maneuver['type']?.toString() ?? '';
    final modifier = maneuver['modifier']?.toString() ?? '';

    final roadSuffix =
        roadName.isEmpty ? '' : ' onto $roadName';

    switch (type) {
      case 'depart':
        return roadName.isEmpty
            ? 'Start driving'
            : 'Start on $roadName';
      case 'arrive':
        return 'Arrive at your destination';
      case 'roundabout':
      case 'rotary':
        return roadName.isEmpty
            ? 'Enter the roundabout'
            : 'Enter the roundabout toward $roadName';
      case 'merge':
        return 'Merge${_modifierText(modifier)}$roadSuffix';
      case 'fork':
        return 'Keep${_modifierText(modifier)}$roadSuffix';
      case 'continue':
      case 'new name':
      case 'notification':
        return roadName.isEmpty
            ? 'Continue straight'
            : 'Continue on $roadName';
      case 'turn':
      case 'end of road':
        return 'Turn${_modifierText(modifier)}$roadSuffix';
      default:
        if (modifier.isNotEmpty) {
          return 'Go${_modifierText(modifier)}$roadSuffix';
        }

        return roadName.isEmpty
            ? 'Continue'
            : 'Continue on $roadName';
    }
  }

  static String _modifierText(String modifier) {
    switch (modifier) {
      case 'uturn':
        return ' around';
      case 'sharp right':
        return ' sharp right';
      case 'right':
        return ' right';
      case 'slight right':
        return ' slightly right';
      case 'straight':
        return ' straight';
      case 'slight left':
        return ' slightly left';
      case 'left':
        return ' left';
      case 'sharp left':
        return ' sharp left';
      default:
        return modifier.isEmpty ? '' : ' $modifier';
    }
  }
}
