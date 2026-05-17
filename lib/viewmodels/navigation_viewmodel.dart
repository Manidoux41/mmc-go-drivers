import 'dart:async';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:xml/xml.dart' as xml;
import 'package:universal_io/io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/recorded_trip.dart';
import '../services/supabase_service.dart';
import '../models/vehicle.dart';
import '../models/planning_activity.dart' hide Waypoint;
import '../models/route_option.dart';
import '../services/routing_service.dart';

class NavigationViewModel extends ChangeNotifier {
  bool _isRecording = false;
  bool get isRecording => _isRecording;

  bool _isCalculating = false;
  bool get isCalculating => _isCalculating;

  bool _isFollowing = false;
  bool get isFollowing => _isFollowing;

  // Track data
  List<TrackPoint> _recordedTrackPoints = [];
  List<TrackPoint> get recordedTrackPoints => _recordedTrackPoints;
  
  List<LatLng> get recordedRoute => _recordedTrackPoints.map((p) => p.point).toList();

  // Multi-route options
  List<RouteOption> _routeOptions = [];
  List<RouteOption> get routeOptions => _routeOptions;
  
  int _selectedRouteIndex = 0;
  int get selectedRouteIndex => _selectedRouteIndex;
  
  List<LatLng> get plannedRoute => _routeOptions.isNotEmpty ? _routeOptions[_selectedRouteIndex].points : [];

  List<LatLng> _plannedWaypoints = [];
  List<LatLng> get plannedWaypoints => _plannedWaypoints;

  List<Waypoint> _currentWaypoints = [];
  List<Waypoint> get currentWaypoints => _currentWaypoints;

  StreamSubscription<Position>? _positionStreamSubscription;
  LatLng? _currentPosition;
  LatLng? get currentPosition => _currentPosition;

  double _currentHeading = 0; // Bearing en degrés
  double get currentHeading => _currentHeading;
  
  // Real-time Statistics
  double _currentSpeed = 0; // km/h
  double get currentSpeed => _currentSpeed;
  
  double _maxSpeed = 0; // km/h
  double get maxSpeed => _maxSpeed;
  
  double _totalDistance = 0; // km
  double get totalDistance => _totalDistance;
  
  double _altitude = 0; // m
  double get altitude => _altitude;
  
  double _maxAltitude = 0; // m
  double get maxAltitude => _maxAltitude;
  
  DateTime? _recordingStartTime;
  Duration _movingTime = Duration.zero;
  
  double get averageSpeed {
    if (_totalDistance == 0) return 0;
    final hours = _movingTime.inSeconds / 3600;
    if (hours == 0) return 0;
    return _totalDistance / hours;
  }

  List<RecordedTrip> _savedTrips = [];
  List<RecordedTrip> get savedTrips => _savedTrips;

  bool _isNavigatingCalculated = false;
  bool get isNavigatingCalculated => _isNavigatingCalculated;

  NavigationViewModel() {
    _initLocation();
    _loadTripsFromDb();
  }

  Future<void> _loadTripsFromDb() async {
    final session = SupabaseService.client.auth.currentSession;
    if (session?.user != null) {
      try {
        final data = await SupabaseService.client
            .from('recorded_trips')
            .select()
            .eq('driver_id', session!.user.id)
            .order('start_time', ascending: false);
        
        _savedTrips = (data as List).map((json) => RecordedTrip.fromJson(json)).toList();
        notifyListeners();
      } catch (e) {
        debugPrint("TRACE : Erreur chargement historique : $e");
      }
    }
  }

  void toggleFollowing() {
    _isFollowing = !_isFollowing;
    notifyListeners();
  }

  void setFollowing(bool value) {
    _isFollowing = value;
    notifyListeners();
  }

  void startCalculatedNavigation() {
    if (_routeOptions.isNotEmpty) {
      _isNavigatingCalculated = true;
      _isFollowing = true;
      notifyListeners();
    }
  }

  void stopCalculatedNavigation() {
    _isNavigatingCalculated = false;
    _isFollowing = false;
    notifyListeners();
  }

  void selectRoute(int index) {
    if (index >= 0 && index < _routeOptions.length) {
      _selectedRouteIndex = index;
      notifyListeners();
    }
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

    final position = await Geolocator.getCurrentPosition();
    _updatePosition(position);

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high, 
        distanceFilter: 5,
      ),
    ).listen((Position position) {
      _updatePosition(position);
    });
  }

  void _updatePosition(Position pos) {
    final newPoint = LatLng(pos.latitude, pos.longitude);
    
    // Mise à jour du cap (bearing) pour la rotation de la carte
    if (pos.heading > 0 || pos.speed > 0.5) {
      _currentHeading = pos.heading;
    }
    
    _currentSpeed = pos.speed * 3.6;
    if (_currentSpeed > _maxSpeed) _maxSpeed = _currentSpeed;
    
    _altitude = pos.altitude;
    if (_altitude > _maxAltitude) _maxAltitude = _altitude;

    if (_isRecording && _currentPosition != null) {
      final dist = Geolocator.distanceBetween(
        _currentPosition!.latitude, _currentPosition!.longitude,
        newPoint.latitude, newPoint.longitude
      );
      
      if (dist > 2) {
        _totalDistance += dist / 1000;
        if (_currentSpeed > 1) {
          _movingTime += const Duration(seconds: 1);
        }
      }

      _recordedTrackPoints.add(TrackPoint(
        point: newPoint,
        altitude: _altitude,
        speed: _currentSpeed,
        timestamp: DateTime.now(),
      ));
    }

    _currentPosition = newPoint;
    notifyListeners();
  }

  void startRecording() {
    _isRecording = true;
    _recordedTrackPoints = [];
    _currentWaypoints = [];
    _totalDistance = 0;
    _maxSpeed = 0;
    _maxAltitude = 0;
    _movingTime = Duration.zero;
    _recordingStartTime = DateTime.now();
    
    if (_currentPosition != null) {
      _recordedTrackPoints.add(TrackPoint(
        point: _currentPosition!,
        altitude: _altitude,
        speed: _currentSpeed,
        timestamp: DateTime.now(),
      ));
    }
    notifyListeners();
  }

  Future<void> stopRecording(String name, String? userId) async {
    _isRecording = false;
    
    final startTime = _recordingStartTime ?? DateTime.now();
    final endTime = DateTime.now();
    final avgSpd = averageSpeed;

    // 1. Générer le contenu KML pour la sauvegarde locale
    final kmlContent = _generateKmlContent(name, _recordedTrackPoints);
    
    // 2. Sauvegarder physiquement le fichier sur le téléphone
    String? localPath;
    if (!kIsWeb) {
      try {
        final directory = await getApplicationDocumentsDirectory();
        final fileName = 'trip_${DateTime.now().millisecondsSinceEpoch}.kml';
        final file = File('${directory.path}/$fileName');
        await file.writeAsString(kmlContent);
        localPath = file.path;
        debugPrint("TRACE : KML sauvegardé localement : $localPath");
      } catch (e) {
        debugPrint("TRACE ERREUR : Échec sauvegarde locale : $e");
      }
    }

    final newTrip = RecordedTrip(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      trackPoints: List.from(_recordedTrackPoints),
      waypoints: List.from(_currentWaypoints),
      startTime: startTime,
      endTime: endTime,
      totalDistance: _totalDistance,
      maxSpeed: _maxSpeed,
      avgSpeed: avgSpd,
      maxAltitude: _maxAltitude,
      localFilePath: localPath,
    );
    
    _savedTrips.add(newTrip);

    // 3. Sauvegarder le NOM et les stats en BASE DE DONNÉES (Supabase)
    if (userId != null) {
      try {
        await SupabaseService.client.from('recorded_trips').insert({
          'name': name,
          'driver_id': userId,
          'start_time': startTime.toIso8601String(),
          'end_time': endTime.toIso8601String(),
          'total_distance': _totalDistance,
          'max_speed': _maxSpeed,
          'local_file_path': localPath,
        });
        debugPrint("TRACE : Nom de la ligne enregistré en DB");
      } catch (e) {
        debugPrint("TRACE ERREUR : Échec enregistrement DB : $e");
      }
    }

    notifyListeners();
  }

  String _generateKmlContent(String name, List<TrackPoint> points) {
    return '''<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">
  <Document>
    <name>$name</name>
    <Style id="roadStyle">
      <LineStyle><color>ff0000ff</color><width>4</width></LineStyle>
    </Style>
    <Placemark>
      <name>Trace GPS</name>
      <styleUrl>#roadStyle</styleUrl>
      <LineString>
        <coordinates>${points.map((p) => "${p.point.longitude},${p.point.latitude},${p.altitude}").join(" ")}</coordinates>
      </LineString>
    </Placemark>
  </Document>
</kml>''';
  }

  void addWaypoint(String label, {String? note}) {
    if (_currentPosition != null) {
      _currentWaypoints.add(Waypoint(
        point: _currentPosition!,
        label: label,
        note: note,
        timestamp: DateTime.now(),
      ));
      notifyListeners();
    }
  }

  Future<void> shareTrip(RecordedTrip trip) async {
    if (kIsWeb) return;

    String? filePath = trip.localFilePath;
    
    // Si le fichier local n'existe plus ou n'est pas renseigné, on le régénère à la volée
    if (filePath == null || !File(filePath).existsSync()) {
      final kml = _generateKmlContent(trip.name, trip.trackPoints);
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/export_${trip.name}.kml');
      await file.writeAsString(kml);
      filePath = file.path;
    }
    
    await Share.shareXFiles([XFile(filePath!)], text: 'Export KML de la ligne : ${trip.name}');
  }

  void loadTrip(RecordedTrip trip) {
    if (trip.trackPoints.isNotEmpty) {
      _routeOptions = [
        RouteOption(
          points: trip.trackPoints.map((p) => p.point).toList(),
          distance: trip.totalDistance * 1000,
          duration: trip.endTime?.difference(trip.startTime).inSeconds.toDouble() ?? 0,
          type: RouteType.recommended,
        )
      ];
      _selectedRouteIndex = 0;
      _plannedWaypoints = [trip.trackPoints.first.point, trip.trackPoints.last.point];
    }
    _currentWaypoints = List.from(trip.waypoints);
    _totalDistance = trip.totalDistance;
    _maxSpeed = trip.maxSpeed;
    _maxAltitude = trip.maxAltitude;
    notifyListeners();
  }

  void clearPlannedRoute() {
    _routeOptions = [];
    _plannedWaypoints = [];
    _selectedRouteIndex = 0;
    _isNavigatingCalculated = false;
    notifyListeners();
  }

  Future<void> calculateMultiStopRoute(List<String> addresses, Vehicle vehicle) async {
    _isCalculating = true;
    _routeOptions = [];
    _plannedWaypoints = [];
    _selectedRouteIndex = 0;
    notifyListeners();

    List<LatLng> waypoints = [];
    for (var addr in addresses) {
      final query = addr.trim();
      if (query.isEmpty) continue;
      
      if (query.toLowerCase() == 'ma position') {
        final pos = _currentPosition ?? const LatLng(48.069, 1.325);
        waypoints.add(pos);
        continue;
      }
      
      final coords = await RoutingService.geocode(query);
      if (coords != null) waypoints.add(coords);
    }

    if (waypoints.length >= 2) {
      _plannedWaypoints = List.from(waypoints);
      _routeOptions = await RoutingService.getHeavyVehicleRoutes(
        points: waypoints,
        vehicle: vehicle,
      );
    }

    _isCalculating = false;
    notifyListeners();
  }

  Future<void> calculateRouteFromActivity(PlanningActivity activity) async {
    if (activity.stops == null || activity.stops!.isEmpty) return;
    if (activity.vehicle == null) return;

    _isCalculating = true;
    _routeOptions = [];
    _plannedWaypoints = activity.stops!.map((s) => s.location).toList();
    _selectedRouteIndex = 0;
    notifyListeners();

    _routeOptions = await RoutingService.getHeavyVehicleRoutes(
      points: _plannedWaypoints,
      vehicle: activity.vehicle!,
    );

    _isCalculating = false;
    notifyListeners();
  }

  Future<void> exportToKML() async {
    final route = plannedRoute;
    if (route.isEmpty) return;
    if (kIsWeb) return;

    String kml = '''<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">
  <Document>
    <name>Itinéraire PL MMC Go</name>
    <Style id="routeStyle">
      <LineStyle><color>ff0000ff</color><width>4</width></LineStyle>
    </Style>
    <Placemark>
      <name>Trajet Optimisé</name>
      <styleUrl>#routeStyle</styleUrl>
      <LineString>
        <coordinates>${route.map((p) => "${p.longitude},${p.latitude},0").join(" ")}</coordinates>
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
    final start = _currentPosition ?? const LatLng(48.069, 1.325);
    _isCalculating = true;
    _routeOptions = [];
    _selectedRouteIndex = 0;
    notifyListeners();
    
    _routeOptions = await RoutingService.getHeavyVehicleRoutes(
      points: [start, destination], 
      vehicle: vehicle
    );

    _isCalculating = false;
    notifyListeners();
  }

  Future<void> importKml() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['kml'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final content = await file.readAsString();
        
        final document = xml.XmlDocument.parse(content);
        final coordinatesNodes = document.findAllElements('coordinates');
        
        if (coordinatesNodes.isNotEmpty) {
          final coordString = coordinatesNodes.first.text.trim();
          final List<LatLng> points = [];
          
          final parts = coordString.split(RegExp(r'\s+'));
          for (var part in parts) {
            final subParts = part.split(',');
            if (subParts.length >= 2) {
              final lng = double.tryParse(subParts[0]);
              final lat = double.tryParse(subParts[1]);
              if (lat != null && lng != null) {
                points.add(LatLng(lat, lng));
              }
            }
          }

          if (points.isNotEmpty) {
            _routeOptions = [
              RouteOption(
                points: points,
                distance: 0,
                duration: 0,
                type: RouteType.recommended,
              )
            ];
            _selectedRouteIndex = 0;
            _plannedWaypoints = [points.first, points.last];
            notifyListeners();
          }
        }
      }
    } on PlatformException catch (e) {
      if (e.code == 'error' && e.message?.contains('MissingPluginException') == true) {
        debugPrint("KML ERREUR : Plugin FilePicker non enregistré. Effectuez un Build complet (Stop + Play).");
      } else {
        debugPrint("KML ERREUR PLATEFORME : $e");
      }
    } on MissingPluginException {
      debugPrint("KML ERREUR : Plugin FilePicker manquant. Effectuez un Build complet (Stop + Play).");
    } catch (e) {
      debugPrint("KML ERREUR : $e");
    }
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }
}
