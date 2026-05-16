import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:flutter/foundation.dart';
import '../models/vehicle.dart';
import '../models/route_option.dart';
import '../config/secrets.dart';

class RoutingService {
  static const String _apiKey = AppSecrets.orsApiKey;
  
  static Future<List<RouteOption>> getHeavyVehicleRoutes({
    required List<LatLng> points,
    required Vehicle vehicle,
  }) async {
    if (points.length < 2) return [];

    List<RouteOption> allOptions = [];

    // 1. Récupérer l'itinéraire RECOMMANDÉ (Fastest) avec alternatives
    final recommendedOptions = await _fetchFromOrs(points, vehicle, "fastest", includeAlternatives: true);
    allOptions.addAll(recommendedOptions);

    // 2. Récupérer l'itinéraire LE PLUS COURT spécifiquement
    // On ne le fait que si on n'a pas déjà un candidat très court ou si on veut être sûr
    final shortestOptions = await _fetchFromOrs(points, vehicle, "shortest", includeAlternatives: false);
    
    // Éviter les doublons si le plus court est déjà dans les alternatives
    for (var opt in shortestOptions) {
      bool exists = allOptions.any((existing) => 
        (existing.distance - opt.distance).abs() < 100 && 
        (existing.duration - opt.duration).abs() < 60
      );
      if (!exists) {
        allOptions.add(RouteOption(
          points: opt.points,
          distance: opt.distance,
          duration: opt.duration,
          type: RouteType.shortest,
        ));
      } else {
        // Si il existe déjà, on s'assure qu'il est marqué comme plus court si c'est le cas
        // ou on laisse tel quel.
      }
    }

    return allOptions;
  }

  static Future<List<RouteOption>> _fetchFromOrs(
    List<LatLng> points, 
    Vehicle vehicle, 
    String preference, 
    {bool includeAlternatives = false}
  ) async {
    final url = Uri.parse('https://api.openrouteservice.org/v2/directions/driving-hgv/geojson');
    
    Map<String, dynamic> bodyMap = {
      "coordinates": points.map((p) => [p.longitude, p.latitude]).toList(),
      "options": {
        "vehicle_type": "hgv",
        "profile_params": {
          "restrictions": {
            "length": vehicle.length,
            "width": vehicle.width,
            "height": vehicle.height,
            "weight": vehicle.ptac
          }
        }
      },
      "preference": preference,
      "units": "m",
      "language": "fr"
    };

    if (includeAlternatives) {
      bodyMap["alternative_routes"] = {
        "target_count": 2,
        "share_factor": 0.6,
        "weight_factor": 1.4
      };
    }

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': _apiKey,
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json, application/geo+json',
        },
        body: jsonEncode(bodyMap),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> features = data['features'];
        
        List<RouteOption> results = [];
        for (int i = 0; i < features.length; i++) {
          final feature = features[i];
          final List<dynamic> coords = feature['geometry']['coordinates'];
          final List<LatLng> routePoints = coords.map((c) => LatLng(c[1].toDouble(), c[0].toDouble())).toList();
          
          final summary = feature['properties']['summary'];
          final distance = (summary['distance'] as num).toDouble();
          final duration = (summary['duration'] as num).toDouble();
          
          RouteType type;
          if (preference == "shortest") {
            type = RouteType.shortest;
          } else {
            type = (i == 0) ? RouteType.recommended : RouteType.alternative;
          }
          
          results.add(RouteOption(
            points: routePoints,
            distance: distance,
            duration: duration,
            type: type,
          ));
        }
        return results;
      }
    } catch (e) {
      debugPrint('Erreur ORS _fetch: $e');
    }
    return [];
  }

  static Future<LatLng?> geocode(String address) async {
    final url = Uri.parse('https://nominatim.openstreetmap.org/search?q=$address&format=json&limit=1');
    try {
      final response = await http.get(url, headers: {'User-Agent': 'MMCGoDriversApp'});
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          return LatLng(double.parse(data[0]['lat']), double.parse(data[0]['lon']));
        }
      }
    } catch (e) {
      debugPrint('Erreur Geocoding: $e');
    }
    return null;
  }
}
