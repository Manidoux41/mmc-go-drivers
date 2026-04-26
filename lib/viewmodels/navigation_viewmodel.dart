import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/recorded_trip.dart';

class NavigationViewModel extends ChangeNotifier {
  bool _isRecording = false;
  bool get isRecording => _isRecording;

  List<LatLng> _currentRoute = [];
  List<LatLng> get currentRoute => _currentRoute;

  List<Waypoint> _currentWaypoints = [];
  List<Waypoint> get currentWaypoints => _currentWaypoints;

  StreamSubscription<Position>? _positionStreamSubscription;
  LatLng? _currentPosition;
  LatLng? get currentPosition => _currentPosition;

  List<RecordedTrip> _savedTrips = [];
  List<RecordedTrip> get savedTrips => _savedTrips;

  NavigationViewModel() {
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
  }

  void startRecording() {
    _isRecording = true;
    _currentRoute = [];
    _currentWaypoints = [];
    
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 5),
    ).listen((Position position) {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _currentRoute.add(_currentPosition!);
      notifyListeners();
    });
    
    notifyListeners();
  }

  void stopRecording(String name) {
    _isRecording = false;
    _positionStreamSubscription?.cancel();
    
    final newTrip = RecordedTrip(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      route: List.from(_currentRoute),
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
    _currentRoute = List.from(trip.route);
    _currentWaypoints = List.from(trip.waypoints);
    notifyListeners();
  }
}
