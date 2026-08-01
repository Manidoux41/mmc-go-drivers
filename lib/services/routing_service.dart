import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter01/models/vehicle.dart';
import 'package:flutter01/models/route_option.dart';
import 'package:flutter01/config/secrets.dart';

class RoutingService {
  static const String _apiKey = AppSecrets.orsApiKey;
  
  static Future<List<RouteOption>> getHeavyVehicleRoutes({
    required List<LatLng> points,
    required Vehicle vehicle,
  }) async {
    if (points.length < 2) return [];

    List<RouteOption> allOptions = [];

    try {
      // 1. Essayer de récupérer l'itinéraire PL (HGV)
      debugPrint('RoutingService: Attempting HGV route calculation...');
      final recommendedOptions = await _fetchFromOrs(
        points, 
        vehicle, 
        "fastest", 
        profile: "driving-hgv",
        includeAlternatives: true,
      );
      
      if (recommendedOptions.isNotEmpty) {
        allOptions.addAll(recommendedOptions);
        
        // 2. Récupérer l'itinéraire LE PLUS COURT PL spécifiquement
        final shortestOptions = await _fetchFromOrs(
          points, 
          vehicle, 
          "shortest", 
          profile: "driving-hgv",
          includeAlternatives: false,
        );
        
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
          }
        }
      } else {
        // FALLBACK: Si le mode HGV échoue, essayer le mode CAR (Voiture)
        debugPrint('RoutingService: HGV failed, falling back to Car profile...');
        final carOptions = await _fetchFromOrs(
          points, 
          vehicle, 
          "fastest", 
          profile: "driving-car",
          includeAlternatives: false,
        );
        
        if (carOptions.isNotEmpty) {
          allOptions.addAll(carOptions.map((o) => RouteOption(
            points: o.points,
            distance: o.distance,
            duration: o.duration,
            type: RouteType.alternative, // Marqué comme alternatif car c'est un fallback
          )));
          debugPrint('RoutingService: Car fallback successful (BEWARE: No HGV restrictions applied)');
        }
      }
    } catch (e) {
      debugPrint('RoutingService: Critical error during routing: $e');
    }

    return allOptions;
  }

  static Future<List<RouteOption>> _fetchFromOrs(
    List<LatLng> points, 
    Vehicle vehicle, 
    String preference, 
    {
      String profile = "driving-hgv",
      bool includeAlternatives = false,
    }
  ) async {
    final url = Uri.parse('https://api.openrouteservice.org/v2/directions/$profile/geojson');
    
    Map<String, dynamic> bodyMap = {
      "coordinates": points.map((p) => [p.longitude, p.latitude]).toList(),
      "preference": preference,
      "units": "m",
      "language": "fr",
      "instructions": true,
    };

    // Les options de gabarit ne sont valides que pour le profil HGV
    if (profile == "driving-hgv") {
      bodyMap["options"] = {
        "vehicle_type": "hgv",
        "profile_params": {
          "restrictions": {
            "length": vehicle.length,
            "width": vehicle.width,
            "height": vehicle.height,
            "weight": vehicle.ptac
          }
        }
      };
    }

    if (includeAlternatives) {
      bodyMap["alternative_routes"] = {
        "target_count": 2,
        "share_factor": 0.6,
        "weight_factor": 1.4
      };
    }

    try {
      debugPrint('RoutingService: POST request to ORS ($profile)...');
      final response = await http.post(
        url,
        headers: {
          'Authorization': _apiKey,
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json, application/geo+json',
        },
        body: jsonEncode(bodyMap),
      ).timeout(const Duration(seconds: 30));

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

          // Parsing des instructions (steps)
          List<RouteStep> routeSteps = [];
          final segments = feature['properties']['segments'] as List<dynamic>;
          for (var segment in segments) {
            final steps = segment['steps'] as List<dynamic>;
            for (var step in steps) {
              routeSteps.add(RouteStep.fromJson(step, routePoints));
            }
          }
          
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
            steps: routeSteps,
          ));
        }
        return results;
      } else {
        debugPrint('RoutingService: ORS API Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('RoutingService: Exception during ORS fetch: $e');
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
