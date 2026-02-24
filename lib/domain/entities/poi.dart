class Poi {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String type; // es. 'monument', 'bridge', 'school'

  Poi({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.type,
  });
}