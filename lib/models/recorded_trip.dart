import 'package:latlong2/latlong.dart';

class Waypoint {
  final LatLng point;
  final String label;
  final DateTime timestamp;

  Waypoint({required this.point, required this.label, required this.timestamp});

  Map<String, dynamic> toJson() => {
    'latitude': point.latitude,
    'longitude': point.longitude,
    'label': label,
    'timestamp': timestamp.toIso8601String(),
  };

  factory Waypoint.fromJson(Map<String, dynamic> json) => Waypoint(
    point: LatLng(json['latitude'], json['longitude']),
    label: json['label'],
    timestamp: DateTime.parse(json['timestamp']),
  );
}

class RecordedTrip {
  final String id;
  final String name;
  final List<LatLng> route;
  final List<Waypoint> waypoints;
  final DateTime startTime;
  final DateTime? endTime;

  RecordedTrip({
    required this.id,
    required this.name,
    required this.route,
    required this.waypoints,
    required this.startTime,
    this.endTime,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'route': route.map((p) => {'lat': p.latitude, 'lng': p.longitude}).toList(),
    'waypoints': waypoints.map((w) => w.toJson()).toList(),
    'startTime': startTime.toIso8601String(),
    'endTime': endTime?.toIso8601String(),
  };
}
