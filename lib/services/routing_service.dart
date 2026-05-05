import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:flutter/foundation.dart';
import '../models/vehicle.dart';

import '../config/secrets.dart';

class RoutingService {
  static const String _apiKey = AppSecrets.orsApiKey;
  
  static Future<List<LatLng>> getHeavyVehicleRoute({
    required List<LatLng> points,
    required Vehicle vehicle,
  }) async {
    if (points.length < 2) return points;

    final url = Uri.parse('https://api.openrouteservice.org/v2/directions/driving-hgv/geojson');
    
    final body = jsonEncode({
      "coordinates": points.map((p) => [p.longitude, p.latitude]).toList(),
      "options": {
        "vehicle_type": "hgv", // Corrigé : 'hgv' au lieu de 'heavy_heavy_hgv'
        "profile_params": {
          "restrictions": {
            "length": vehicle.length,
            "width": vehicle.width,
            "height": vehicle.height,
            "weight": vehicle.ptac
          }
        }
      },
      "preference": "fastest",
      "units": "m",
      "language": "fr"
    });

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': _apiKey,
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json, application/geo+json, application/gpx+xml, text/csv; charset=utf-8',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> coords = data['features'][0]['geometry']['coordinates'];
        final route = coords.map((c) => LatLng(c[1].toDouble(), c[0].toDouble())).toList();
        debugPrint('Itinéraire récupéré avec succès : ${route.length} points');
        return route;
      } else {
        debugPrint('Erreur ORS (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      debugPrint('Erreur Routing: $e');
    }

    debugPrint('Échec du calcul d\'itinéraire réel. Retour du tracé direct.');
    return points; // Fallback ligne droite
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
