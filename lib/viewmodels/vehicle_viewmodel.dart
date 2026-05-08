import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/vehicle.dart';
import '../services/supabase_service.dart';

class VehicleViewModel extends ChangeNotifier {
  List<Vehicle> _vehicles = [];
  bool _isLoading = false;
  SupabaseClient? _customClient;

  List<Vehicle> get vehicles => _vehicles;
  bool get isLoading => _isLoading;

  SupabaseClient get _db => _customClient ?? SupabaseService.client;

  void setCustomClient(String? url, String? anonKey) {
    if (url != null && anonKey != null) {
      _customClient = SupabaseClient(url, anonKey);
    } else {
      _customClient = null;
    }
  }

  Future<void> fetchVehicles() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _db
          .from('vehicles')
          .select()
          .order('registration');
// ...
      
      _vehicles = (data as List).map((v) => Vehicle.fromJson(v)).toList();
    } catch (e) {
      debugPrint("Erreur fetch vehicles : ${e.toString()}");
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addVehicle(Vehicle vehicle) async {
    try {
      await _db
          .from('vehicles')
          .insert(vehicle.toJson());
      
      await fetchVehicles();
    } catch (e) {
      debugPrint("Erreur add vehicle : ${e.toString()}");
    }
  }

  Future<void> updateMileage(String vehicleId, double newMileage) async {
    try {
      await _db
          .from('vehicles')
          .update({'mileage': newMileage})
          .eq('id', vehicleId);
      
      await fetchVehicles();
    } catch (e) {
      debugPrint("Erreur update mileage : ${e.toString()}");
    }
  }

  Vehicle? getVehicleByRegistration(String registration) {
    try {
      return _vehicles.firstWhere((v) => v.registration == registration);
    } catch (e) {
      return null;
    }
  }
}
