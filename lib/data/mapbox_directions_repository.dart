import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_runtime_config.dart';
import '../domain/entities/route_path.dart';
import '../domain/entities/tour_stop.dart';
import '../domain/repositories/route_directions_repository.dart';

class MapboxDirectionsRepository implements RouteDirectionsRepository {
  MapboxDirectionsRepository({http.Client? client})
    : _client = client ?? http.Client();

  static const _directionsEndpoint = 'api.mapbox.com';
  static const _walkingProfile = 'mapbox/walking';

  final http.Client _client;

  @override
  Future<RoutePath> getWalkingRoute({
    required GeoPoint origin,
    required GeoPoint destination,
  }) async {
    final accessToken = AppRuntimeConfig.mapboxAccessToken.trim();
    if (accessToken.isEmpty) {
      throw const MapboxDirectionsException('Missing Mapbox access token.');
    }

    final uri = Uri.https(
      _directionsEndpoint,
      '/directions/v5/$_walkingProfile/'
      '${origin.longitude},${origin.latitude};'
      '${destination.longitude},${destination.latitude}',
      {
        'access_token': accessToken,
        'geometries': 'geojson',
        'overview': 'full',
        'alternatives': 'false',
        'steps': 'false',
      },
    );

    final response = await _client.get(uri).timeout(const Duration(seconds: 8));
    if (response.statusCode != 200) {
      throw MapboxDirectionsException(
        'Mapbox Directions failed with status ${response.statusCode}.',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const MapboxDirectionsException('Invalid Mapbox response.');
    }

    final routes = decoded['routes'];
    if (routes is! List || routes.isEmpty) {
      throw const MapboxDirectionsException('Mapbox response has no routes.');
    }

    final firstRoute = routes.first;
    if (firstRoute is! Map<String, dynamic>) {
      throw const MapboxDirectionsException('Invalid Mapbox route.');
    }

    final geometry = firstRoute['geometry'];
    if (geometry is! Map<String, dynamic>) {
      throw const MapboxDirectionsException('Invalid Mapbox geometry.');
    }

    final coordinates = geometry['coordinates'];
    if (coordinates is! List) {
      throw const MapboxDirectionsException('Invalid Mapbox coordinates.');
    }

    final points = coordinates.map(_coordinateToGeoPoint).toList(growable: false);
    return RoutePath(points: points);
  }

  GeoPoint _coordinateToGeoPoint(Object? coordinate) {
    if (coordinate is! List || coordinate.length < 2) {
      throw const MapboxDirectionsException('Invalid route coordinate.');
    }

    final longitude = coordinate[0];
    final latitude = coordinate[1];
    if (longitude is! num || latitude is! num) {
      throw const MapboxDirectionsException('Invalid route coordinate values.');
    }

    return GeoPoint(
      latitude: latitude.toDouble(),
      longitude: longitude.toDouble(),
    );
  }
}

class MapboxDirectionsException implements Exception {
  const MapboxDirectionsException(this.message);

  final String message;

  @override
  String toString() => 'MapboxDirectionsException: $message';
}
