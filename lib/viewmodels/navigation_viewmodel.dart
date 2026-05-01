import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/recorded_trip.dart';
import '../models/vehicle.dart';
import '../services/routing_service.dart';

class NavigationViewModel extends ChangeNotifier {
  bool _isRecording = false;
  bool get isRecording => _isRecording;

  bool _isCalculating = false;
  bool get isCalculating => _isCalculating;

  List<LatLng> _recordedRoute = [];
  List<LatLng> get recordedRoute => _recordedRoute;

  List<LatLng> _plannedRoute = [];
  List<LatLng> get plannedRoute => _plannedRoute;

  List<Waypoint> _currentWaypoints = [];
  List<Waypoint> get currentWaypoints => _currentWaypoints;

  StreamSubscription<Position>? _positionStreamSubscription;
  LatLng? _currentPosition;
  LatLng? get currentPosition => _currentPosition;

  List<RecordedTrip> _savedTrips = [];
  List<RecordedTrip> get savedTrips => _savedTrips;

  NavigationViewModel() {
    _initLocation();
  }

  Future<void> _initLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    // Récupérer la position initiale immédiatement
    final position = await Geolocator.getCurrentPosition();
    _currentPosition = LatLng(position.latitude, position.longitude);
    notifyListeners();

    // Écouter en continu pour avoir une position à jour même sans enregistrer
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 10),
    ).listen((Position position) {
      _currentPosition = LatLng(position.latitude, position.longitude);
      if (_isRecording) {
        _recordedRoute.add(_currentPosition!);
      }
      notifyListeners();
    });
  }

  void startRecording() {
    _isRecording = true;
    _recordedRoute = [];
    _currentWaypoints = [];
    if (_currentPosition != null) {
      _recordedRoute.add(_currentPosition!);
    }
    notifyListeners();
  }

  void stopRecording(String name) {
    _isRecording = false;
    
    final newTrip = RecordedTrip(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      route: List.from(_recordedRoute),
      waypoints: List.from(_currentWaypoints),
      startTime: DateTime.now(),
      endTime: DateTime.now(),
    );
    
    _savedTrips.add(newTrip);
    notifyListeners();
  }

  void addWaypoint(String label) {
    if (_currentPosition != null) {
      _currentWaypoints.add(Waypoint(
        point: _currentPosition!,
        label: label,
        timestamp: DateTime.now(),
      ));
      notifyListeners();
    }
  }

  Future<void> shareTrip(RecordedTrip trip) async {
    final jsonString = jsonEncode(trip.toJson());
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/${trip.name}.json');
    await file.writeAsString(jsonString);
    
    await Share.shareXFiles([XFile(file.path)], text: 'Mon trajet de car: ${trip.name}');
  }

  void loadTrip(RecordedTrip trip) {
    _recordedRoute = List.from(trip.route);
    _currentWaypoints = List.from(trip.waypoints);
    notifyListeners();
  }

  void clearPlannedRoute() {
    _plannedRoute = [];
    notifyListeners();
  }

  Future<void> calculateMultiStopRoute(List<String> addresses, Vehicle vehicle) async {
    _isCalculating = true;
    notifyListeners();

    List<LatLng> waypoints = [];
    for (var addr in addresses) {
      final query = addr.trim();
      if (query.isEmpty) continue;
      
      if (query.toLowerCase() == 'ma position') {
        if (_currentPosition != null) waypoints.add(_currentPosition!);
        continue;
      }
      
      final coords = await RoutingService.geocode(query);
      if (coords != null) waypoints.add(coords);
    }

    if (waypoints.length >= 2) {
      final route = await RoutingService.getHeavyVehicleRoute(
        points: waypoints,
        vehicle: vehicle,
      );
      _plannedRoute = route;
    }

    _isCalculating = false;
    notifyListeners();
  }

  Future<void> exportToKML() async {
    if (_plannedRoute.isEmpty) return;

    String kml = '''<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">
  <Document>
    <name>Itinéraire PL MMC Go</name>
    <Style id="routeStyle">
      <LineStyle>
        <color>ff0000ff</color>
        <width>4</width>
      </LineStyle>
    </Style>
    <Placemark>
      <name>Trajet Optimisé</name>
      <styleUrl>#routeStyle</styleUrl>
      <LineString>
        <coordinates>
          ${_plannedRoute.map((p) => "${p.longitude},${p.latitude},0").join(" ")}
        </coordinates>
      </LineString>
    </Placemark>
  </Document>
</kml>''';

    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/itineraire_pl.kml');
    await file.writeAsString(kml);
    
    await Share.shareXFiles([XFile(file.path)], text: 'Mon itinéraire PL exporté');
  }

  Future<void> calculateTruckRoute(LatLng destination, Vehicle vehicle) async {
    // Si la position GPS n'est pas encore disponible, on utilise une position par défaut (Châteaudun) pour le test
    final start = _currentPosition ?? const LatLng(48.069, 1.325);
    
    _isCalculating = true;
    notifyListeners();

    debugPrint("Calcul d'itinéraire PL de $start vers $destination");

    final route = await RoutingService.getHeavyVehicleRoute(
      points: [start, destination],
      vehicle: vehicle,
    );

    _plannedRoute = route;
    _isCalculating = false;
    notifyListeners();
  }
}
