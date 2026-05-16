import 'package:latlong2/latlong.dart';

class TrackPoint {
  final LatLng point;
  final double altitude;
  final double speed; // in km/h
  final DateTime timestamp;

  TrackPoint({
    required this.point,
    this.altitude = 0,
    this.speed = 0,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'lat': point.latitude,
    'lng': point.longitude,
    'alt': altitude,
    'speed': speed,
    'time': timestamp.toIso8601String(),
  };

  factory TrackPoint.fromJson(Map<String, dynamic> json) => TrackPoint(
    point: LatLng(json['lat'], json['lng']),
    altitude: (json['alt'] as num).toDouble(),
    speed: (json['speed'] as num).toDouble(),
    timestamp: DateTime.parse(json['time']),
  );
}

class Waypoint {
  final LatLng point;
  final String label;
  final String? note;
  final DateTime timestamp;

  Waypoint({
    required this.point,
    required this.label,
    this.note,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'latitude': point.latitude,
    'longitude': point.longitude,
    'label': label,
    'note': note,
    'timestamp': timestamp.toIso8601String(),
  };

  factory Waypoint.fromJson(Map<String, dynamic> json) => Waypoint(
    point: LatLng(json['latitude'], json['longitude']),
    label: json['label'],
    note: json['note'],
    timestamp: DateTime.parse(json['timestamp']),
  );
}

class RecordedTrip {
  final String id;
  final String name;
  final List<TrackPoint> trackPoints;
  final List<Waypoint> waypoints;
  final DateTime startTime;
  final DateTime? endTime;
  
  // Statistics
  final double totalDistance; // in km
  final double maxSpeed; // in km/h
  final double avgSpeed; // in km/h
  final double maxAltitude; // in meters

  // Path to the local KML/JSON file on device
  final String? localFilePath;

  RecordedTrip({
    required this.id,
    required this.name,
    required this.trackPoints,
    required this.waypoints,
    required this.startTime,
    this.endTime,
    this.totalDistance = 0,
    this.maxSpeed = 0,
    this.avgSpeed = 0,
    this.maxAltitude = 0,
    this.localFilePath,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'points': trackPoints.map((p) => p.toJson()).toList(),
    'waypoints': waypoints.map((w) => w.toJson()).toList(),
    'startTime': startTime.toIso8601String(),
    'endTime': endTime?.toIso8601String(),
    'distance': totalDistance,
    'maxSpeed': maxSpeed,
    'avgSpeed': avgSpeed,
    'maxAlt': maxAltitude,
    'localFilePath': localFilePath,
  };

  factory RecordedTrip.fromJson(Map<String, dynamic> json) => RecordedTrip(
    id: json['id'],
    name: json['name'],
    trackPoints: json['points'] != null 
        ? (json['points'] as List).map((p) => TrackPoint.fromJson(p)).toList()
        : [],
    waypoints: json['waypoints'] != null 
        ? (json['waypoints'] as List).map((w) => Waypoint.fromJson(w)).toList()
        : [],
    startTime: DateTime.parse(json['startTime'] ?? json['start_time']),
    endTime: (json['endTime'] ?? json['end_time']) != null 
        ? DateTime.parse(json['endTime'] ?? json['end_time']) 
        : null,
    totalDistance: (json['distance'] ?? json['total_distance'] as num?)?.toDouble() ?? 0,
    maxSpeed: (json['maxSpeed'] ?? json['max_speed'] as num?)?.toDouble() ?? 0,
    avgSpeed: (json['avgSpeed'] as num?)?.toDouble() ?? 0,
    maxAltitude: (json['maxAlt'] ?? json['max_altitude'] as num?)?.toDouble() ?? 0,
    localFilePath: json['localFilePath'] ?? json['local_file_path'],
  );
}
