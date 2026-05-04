import 'vehicle.dart';
import 'package:latlong2/latlong.dart';

enum ActivityType { ps, fs, trip, nettoyage, hlp, bc, photo_planning }

class PlanningActivity {
  final String id;
  final String title;
  final ActivityType type;
  final DateTime startTime;
  final DateTime endTime;
  final String? departure;
  final String? arrival;
  final List<Waypoint>? stops; // Pour les Billet Collectifs (BC)
  final Vehicle? vehicle; // Lien vers l'objet véhicule complet
  final String? driverId; // UUID du conducteur (Diamant)
  final String? filePath; // Chemin vers le PDF sur Supabase Storage

  PlanningActivity({
    required this.id,
    required this.title,
    required this.type,
    required this.startTime,
    required this.endTime,
    this.departure,
    this.arrival,
    this.stops,
    this.vehicle,
    this.driverId,
    this.filePath,
  });

  factory PlanningActivity.fromJson(Map<String, dynamic> json, {Vehicle? vehicle}) {
    return PlanningActivity(
      id: json['id'],
      title: json['title'],
      type: _typeFromString(json['type']),
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      departure: json['departure'],
      arrival: json['arrival'],
      vehicle: vehicle,
      driverId: json['driver_id'],
      filePath: json['file_path'],
      stops: (json['stops'] as List?)?.map((s) => Waypoint.fromJson(s)).toList(),
    );
  }

  static ActivityType _typeFromString(String type) {
    return ActivityType.values.firstWhere(
      (e) => e.name == type, 
      orElse: () => ActivityType.trip
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'type': type.name,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'departure': departure,
      'arrival': arrival,
      'vehicle_id': vehicle?.id,
      'driver_id': driverId,
      'file_path': filePath,
      'stops': stops?.map((s) => s.toJson()).toList(),
    };
  }

  String? get busNumber => vehicle?.registration;

  Duration get duration => endTime.difference(startTime);

  bool get isDriving => type == ActivityType.trip || type == ActivityType.bc || type == ActivityType.hlp;
}

class Waypoint {
  final String name;
  final LatLng location;

  Waypoint({required this.name, required this.location});

  factory Waypoint.fromJson(Map<String, dynamic> json) {
    return Waypoint(
      name: json['name'],
      location: LatLng(json['lat'], json['lng']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'lat': location.latitude,
      'lng': location.longitude,
    };
  }
}
