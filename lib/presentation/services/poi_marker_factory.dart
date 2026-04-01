import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/entities/poi.dart';

class PoiMarkerFactory {
  const PoiMarkerFactory();

  Marker fromPoi(Poi poi) {
    return Marker(
      point: LatLng(poi.latitude, poi.longitude),
      width: 120,
      height: 80,
      child: Column(
        children: [
          Icon(Icons.location_on, color: _colorFromType(poi.type), size: 40),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              boxShadow: const [BoxShadow(blurRadius: 2, color: Colors.black26)],
            ),
            child: Text(
              poi.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Color _colorFromType(String type) {
    switch (type) {
      case 'school':
        return Colors.red;
      case 'bridge':
        return Colors.green;
      case 'library':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }
}
