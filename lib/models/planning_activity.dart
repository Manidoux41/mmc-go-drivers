import 'vehicle.dart';
import 'package:latlong2/latlong.dart';

enum ActivityType { ps, fs, trip, nettoyage, hlp, bc }

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
  final String? driverId; // Pour identifier le conducteur (Diamant)

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
  });

  String? get busNumber => vehicle?.registration;

  Duration get duration => endTime.difference(startTime);

  bool get isDriving => type == ActivityType.trip || type == ActivityType.bc || type == ActivityType.hlp;
}

class Waypoint {
  final String name;
  final LatLng location;

  Waypoint({required this.name, required this.location});
}
