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
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:mongo_dart/mongo_dart.dart' show where, ObjectId;
import 'package:flutter01/models/recorded_trip.dart';
import 'package:flutter01/services/mongo_service.dart';
import 'package:flutter01/services/mongo_auth_service.dart';
import 'package:flutter01/models/vehicle.dart';
import 'package:flutter01/models/planning_activity.dart' hide Waypoint;
import 'package:flutter01/models/route_option.dart';
import 'package:flutter01/services/routing_service.dart';

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

  RouteStep? _nextStep;
  RouteStep? get nextStep => _nextStep;

  double _distanceToNextStep = 0; // meters
  double get distanceToNextStep => _distanceToNextStep;

  double _durationToArrival = 0; // seconds
  double get durationToArrival => _durationToArrival;

  double _distanceToArrival = 0; // meters
  double get distanceToArrival => _distanceToArrival;

  StreamSubscription? _sharingStreamSubscription;

  NavigationViewModel() {
    _initLocation();
    _loadTripsFromDb();
    _initSharing();
  }

  void _initSharing() {
    // Écouter les fichiers partagés pendant que l'app est ouverte
    _sharingStreamSubscription = ReceiveSharingIntent.instance.getMediaStream().listen((List<SharedMediaFile> value) {
      if (value.isNotEmpty) {
        final kmlFile = value.firstWhere((f) => f.path.endsWith('.kml'), orElse: () => value.first);
        processKmlFile(File(kmlFile.path));
      }
    }, onError: (err) {
      debugPrint("TRACE : Erreur getMediaStream : $err");
    });

    // Vérifier si l'app a été ouverte via un fichier (app fermée au départ)
    ReceiveSharingIntent.instance.getInitialMedia().then((List<SharedMediaFile> value) {
      if (value.isNotEmpty) {
        final kmlFile = value.firstWhere((f) => f.path.endsWith('.kml'), orElse: () => value.first);
        processKmlFile(File(kmlFile.path));
      }
    });
  }

  Future<void> processKmlFile(File file) async {
    try {
      final content = await file.readAsString();
      final document = xml.XmlDocument.parse(content);
      
      // Recherche récursive de toutes les balises <coordinates>
      final coordinatesNodes = document.findAllElements('coordinates');
      List<LatLng> allPoints = [];
      
      for (var node in coordinatesNodes) {
        final coordString = node.text.trim();
        if (coordString.isEmpty) continue;
        
        // Séparateur peut être espace, tabulation ou saut de ligne
        final parts = coordString.split(RegExp(r'[\s\n\t]+'));
        for (var part in parts) {
          final subParts = part.split(',');
          if (subParts.length >= 2) {
            final lng = double.tryParse(subParts[0].trim());
            final lat = double.tryParse(subParts[1].trim());
            if (lat != null && lng != null) {
              allPoints.add(LatLng(lat, lng));
            }
          }
        }
      }

      if (allPoints.isNotEmpty) {
        _routeOptions = [
          RouteOption(
            points: allPoints,
            distance: 0, // Sera calculé si besoin lors du suivi
            duration: 0,
            type: RouteType.recommended,
            steps: [], // On pourrait générer des étapes ici
          )
        ];
        _selectedRouteIndex = 0;
        _plannedWaypoints = [allPoints.first, allPoints.last];
        notifyListeners();
        debugPrint("TRACE : KML importé avec succès (${allPoints.length} points)");
      } else {
        debugPrint("TRACE : Le fichier KML ne contient pas de coordonnées valides.");
      }
    } catch (e) {
      debugPrint("TRACE ERREUR : Échec du traitement KML : $e");
    }
  }

  Future<void> _loadTripsFromDb() async {
    final userId = await MongoAuthService.getCurrentSessionUserId();
    List<RecordedTrip> trips = [];

    // 1. Charger depuis MongoDB (Cloud)
    if (userId != null) {
      try {
        final data = await MongoService.recordedTrips
            .find(where.eq('driver_id', userId).sortBy('start_time', descending: true))
            .toList();
        
        trips.addAll(data.map((json) => RecordedTrip.fromJson(json)));
        debugPrint("TRACE : ${data.length} trajets chargés depuis MongoDB.");
      } catch (e) {
        debugPrint("TRACE : Erreur MongoDB : $e. Passage au mode local.");
      }
    }

    // 2. Charger les fichiers locaux (Cache) pour voir s'il y a des doublons ou des fichiers non sync
    if (!kIsWeb) {
      try {
        final directory = await getApplicationDocumentsDirectory();
        final files = directory.listSync().where((f) => f.path.endsWith('.kml'));
        debugPrint("TRACE : ${files.length} fichiers KML locaux trouvés.");
        // Pour l'instant on se fie surtout à la DB, mais on pourrait parser les KML ici si besoin
      } catch (e) {
        debugPrint("TRACE : Erreur lecture cache local : $e");
      }
    }

    _savedTrips = trips;
    notifyListeners();
  }

  Future<void> deleteTrip(RecordedTrip trip) async {
    try {
      // 1. Supprimer de MongoDB
      if (trip.mongoId != null) {
        await MongoService.recordedTrips.deleteOne(where.id(trip.mongoId!));
      } else {
        await MongoService.recordedTrips.deleteOne(where.eq('id', trip.id));
      }

      // 2. Supprimer le fichier local
      if (trip.localFilePath != null) {
        final file = File(trip.localFilePath!);
        if (await file.exists()) {
          await file.delete();
        }
      }

      // 3. Mettre à jour la liste locale
      _savedTrips.removeWhere((t) => t.id == trip.id);
      notifyListeners();
      debugPrint("TRACE : Trajet ${trip.name} supprimé avec succès.");
    } catch (e) {
      debugPrint("TRACE ERREUR : Échec suppression trajet : $e");
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
      _updateWakelock();
      notifyListeners();
    }
  }

  void stopCalculatedNavigation() {
    _isNavigatingCalculated = false;
    _isFollowing = false;
    _updateWakelock();
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

    if (_isNavigatingCalculated && _routeOptions.isNotEmpty) {
      _updateNavigationGuidance(newPoint);
    }

    notifyListeners();
  }

  void _updateNavigationGuidance(LatLng currentPos) {
    final route = _routeOptions[_selectedRouteIndex];
    if (route.steps.isEmpty) return;

    // 1. Trouver l'étape actuelle (la plus proche devant nous)
    // On cherche l'étape dont l'indice de point est juste après notre position sur le tracé
    // Pour simplifier, on cherche l'étape la plus proche dans un rayon de 50m
    RouteStep? currentStep;
    double minStepDist = double.infinity;
    int currentStepIdx = -1;

    for (int i = 0; i < route.steps.length; i++) {
      final step = route.steps[i];
      final d = Geolocator.distanceBetween(
        currentPos.latitude, currentPos.longitude,
        step.location.latitude, step.location.longitude
      );
      if (d < 50 && d < minStepDist) {
        minStepDist = d;
        currentStepIdx = i;
      }
    }

    // Si on a trouvé une étape proche, la suivante est celle d'après
    if (currentStepIdx != -1 && currentStepIdx < route.steps.length - 1) {
      _nextStep = route.steps[currentStepIdx + 1];
    } else if (_nextStep == null) {
      _nextStep = route.steps.first;
    }

    // 2. Calculer les distances
    if (_nextStep != null) {
      _distanceToNextStep = Geolocator.distanceBetween(
        currentPos.latitude, currentPos.longitude,
        _nextStep!.location.latitude, _nextStep!.location.longitude
      );
    }

    // Distance totale à l'arrivée (somme des segments restants + distance au prochain point du tracé)
    // Pour simplifier, on prend la distance à vol d'oiseau vers la destination finale
    final destination = route.points.last;
    _distanceToArrival = Geolocator.distanceBetween(
      currentPos.latitude, currentPos.longitude,
      destination.latitude, destination.longitude
    );
    
    if (_distanceToArrival < 30) {
      _nextStep = RouteStep(
        distance: 0,
        duration: 0,
        type: 10,
        instruction: "Vous êtes arrivé à destination",
        name: "",
        location: destination,
        waypointIndex: route.points.length - 1
      );
    }

    // Estimation du temps restant (basé sur la vitesse moyenne de 50km/h si arrêt, sinon vitesse actuelle)
    final speedMs = (_currentSpeed > 5) ? (_currentSpeed / 3.6) : (50 / 3.6);
    _durationToArrival = _distanceToArrival / speedMs;
  }

  void _updateWakelock() {
    WakelockPlus.toggle(enable: _isRecording || _isNavigatingCalculated);
  }

  void startRecording() {
    _isRecording = true;
    _updateWakelock();
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
    _updateWakelock();
    
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

    // 3. Sauvegarder le NOM et les stats en BASE DE DONNÉES (MongoDB)
    if (userId != null) {
      try {
        final dataToSave = newTrip.toJson();
        dataToSave['driver_id'] = userId; // Indispensable pour filtrer par chauffeur
        
        await MongoService.recordedTrips.insertOne(dataToSave);
        debugPrint("TRACE : Trajet complet enregistré en DB (Points: ${newTrip.trackPoints.length})");
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
      
      // Points de départ/arrivée pour les marqueurs A/B
      if (trip.waypoints.isNotEmpty) {
        _plannedWaypoints = trip.waypoints.map((w) => w.point).toList();
      } else {
        _plannedWaypoints = [trip.trackPoints.first.point, trip.trackPoints.last.point];
      }
    }
    _currentWaypoints = List.from(trip.waypoints);
    _totalDistance = trip.totalDistance;
    _maxSpeed = trip.maxSpeed;
    _maxAltitude = trip.maxAltitude;
    notifyListeners();
  }

  /// Transforme une trace GPS brute en itinéraire suivant les routes réelles
  /// en se basant sur les étapes (waypoints) enregistrées.
  Future<void> optimizeRecordedTrip(RecordedTrip trip, Vehicle vehicle) async {
    if (trip.waypoints.length < 2) {
      // Si pas assez de waypoints, on prend le premier et dernier point de la trace
      if (trip.trackPoints.length < 2) return;
      _plannedWaypoints = [trip.trackPoints.first.point, trip.trackPoints.last.point];
    } else {
      _plannedWaypoints = trip.waypoints.map((w) => w.point).toList();
    }

    _isCalculating = true;
    notifyListeners();

    try {
      final optimizedRoutes = await RoutingService.getHeavyVehicleRoutes(
        points: _plannedWaypoints,
        vehicle: vehicle,
      );

      if (optimizedRoutes.isNotEmpty) {
        _routeOptions = optimizedRoutes;
        _selectedRouteIndex = 0;
        debugPrint("NavigationViewModel: Trip optimized with road-following points.");
      }
    } catch (e) {
      debugPrint("NavigationViewModel: Optimization failed: $e");
    } finally {
      _isCalculating = false;
      notifyListeners();
    }
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

    try {
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
        
        if (_routeOptions.isEmpty) {
          debugPrint('NavigationViewModel: Routing failed to return any paths.');
        }
      }
    } catch (e) {
      debugPrint('NavigationViewModel: Error in calculateMultiStopRoute: $e');
    } finally {
      _isCalculating = false;
      notifyListeners();
    }
  }

  Future<void> calculateRouteFromActivity(PlanningActivity activity) async {
    if (activity.stops == null || activity.stops!.isEmpty) return;
    if (activity.vehicle == null) return;

    _isCalculating = true;
    _routeOptions = [];
    _plannedWaypoints = activity.stops!.map((s) => s.location).toList();
    _selectedRouteIndex = 0;
    notifyListeners();

    try {
      _routeOptions = await RoutingService.getHeavyVehicleRoutes(
        points: _plannedWaypoints,
        vehicle: activity.vehicle!,
      );
    } catch (e) {
      debugPrint('NavigationViewModel: Error in calculateRouteFromActivity: $e');
    } finally {
      _isCalculating = false;
      notifyListeners();
    }
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
    _plannedWaypoints = [start, destination];
    notifyListeners();
    
    try {
      _routeOptions = await RoutingService.getHeavyVehicleRoutes(
        points: [start, destination], 
        vehicle: vehicle
      );
    } catch (e) {
      debugPrint('NavigationViewModel: Error in calculateTruckRoute: $e');
    } finally {
      _isCalculating = false;
      notifyListeners();
    }
  }

  Future<void> importKml() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['kml'],
      );

      if (result != null && result.files.single.path != null) {
        await processKmlFile(File(result.files.single.path!));
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
    _sharingStreamSubscription?.cancel();
    super.dispose();
  }
}
