import 'package:latlong2/latlong.dart';

enum RouteType {
  fastest,
  shortest,
  recommended,
  alternative,
}

class RouteOption {
  final List<LatLng> points;
  final double distance; // in meters
  final double duration; // in seconds
  final RouteType type;

  RouteOption({
    required this.points,
    required this.distance,
    required this.duration,
    required this.type,
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
