import 'package:latlong2/latlong.dart';

enum RouteType {
  fastest,
  shortest,
  recommended,
  alternative,
}

class RouteStep {
  final double distance; // meters
  final double duration; // seconds
  final int type; // ORS action type
  final String instruction;
  final String name;
  final LatLng location;
  final int waypointIndex;

  RouteStep({
    required this.distance,
    required this.duration,
    required this.type,
    required this.instruction,
    required this.name,
    required this.location,
    required this.waypointIndex,
  });

  factory RouteStep.fromJson(Map<String, dynamic> json, List<LatLng> points) {
    // Les indices de géométrie dans ORS sont inclusifs [start, end]
    final List<dynamic> waypoints = json['way_points'];
    final int startIndex = waypoints[0];
    
    return RouteStep(
      distance: (json['distance'] as num).toDouble(),
      duration: (json['duration'] as num).toDouble(),
      type: json['type'] as int,
      instruction: json['instruction'] as String,
      name: json['name'] as String,
      location: points[startIndex],
      waypointIndex: startIndex,
    );
  }
}

class RouteOption {
  final List<LatLng> points;
  final double distance; // in meters
  final double duration; // in seconds
  final RouteType type;
  final List<RouteStep> steps;

  RouteOption({
    required this.points,
    required this.distance,
    required this.duration,
    required this.type,
    this.steps = const [],
  });

  String get typeLabel {
    switch (type) {
      case RouteType.fastest: return 'Plus rapide';
      case RouteType.shortest: return 'Plus court';
      case RouteType.recommended: return 'Conseillé';
      case RouteType.alternative: return 'Alternative';
    }
  }

  String get distanceLabel {
    if (distance < 1000) return '${distance.toInt()} m';
    return '${(distance / 1000).toStringAsFixed(1)} km';
  }

  String get durationLabel {
    final minutes = (duration / 60).round();
    if (minutes < 60) return '$minutes min';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '${hours}h ${mins.toString().padLeft(2, '0')}';
  }
}
