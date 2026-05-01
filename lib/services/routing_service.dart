import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:flutter/foundation.dart';
import '../models/vehicle.dart';

class RoutingService {
  /// REMPLACEZ CETTE CLÉ par votre propre clé gratuite obtenue sur https://openrouteservice.org/
  static const String _apiKey = '5b3ce3597851110001cf624890656a877501463989069d5053702287'; 
  
  static Future<List<LatLng>> getHeavyVehicleRoute({
    required List<LatLng> points,
    required Vehicle vehicle,
  }) async {
    if (points.length < 2) return points;

    final url = Uri.parse('https://api.openrouteservice.org/v2/directions/driving-hgv/geojson');
    
    final body = jsonEncode({
      "coordinates": points.map((p) => [p.longitude, p.latitude]).toList(),
      "options": {
        "vehicle_type": "heavy_heavy_hgv",
        "profile_params": {
          "restrictions": {
            "length": vehicle.length,
            "width": vehicle.width,
            "height": vehicle.height,
            "weight": vehicle.ptac
          }
        }
      },
      "units": "m",
      "language": "fr"
    });

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': _apiKey,
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> coords = data['features'][0]['geometry']['coordinates'];
        return coords.map((c) => LatLng(c[1], c[0])).toList();
      }
    } catch (e) {
      debugPrint('Erreur Routing: $e');
    }

    return points; // Fallback simple
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
