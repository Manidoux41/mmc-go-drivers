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

  void clear() {
    _vehicles = [];
    _customClient = null;
    notifyListeners();
  }

  Future<void> fetchVehicles({String? ownerId}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final List<dynamic> data;
      
      // Syntaxe simplifiée au maximum pour éviter les erreurs de type Postgrest
      if (ownerId != null && _customClient == null) {
        data = await _db.from('vehicles').select().eq('owner_id', ownerId).order('registration');
      } else {
        data = await _db.from('vehicles').select().order('registration');
      }
      
      _vehicles = data.map((v) => Vehicle.fromJson(v as Map<String, dynamic>)).toList();
      debugPrint("SYNCHRO : ${_vehicles.length} véhicules récupérés.");
    } catch (e) {
      debugPrint("ERREUR SYNCHRO VEHICULES : $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addVehicle(Vehicle vehicle) async {
    if (_customClient == null && _vehicles.length >= 5) {
      return false;
    }
    try {
      await _db.from('vehicles').insert(vehicle.toJson());
      await fetchVehicles(ownerId: vehicle.ownerId);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateVehicle(Vehicle vehicle) async {
    try {
      await _db.from('vehicles').update(vehicle.toJson()).eq('id', vehicle.id);
      await fetchVehicles(ownerId: vehicle.ownerId);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteVehicle(String vehicleId, {String? ownerId}) async {
    try {
      await _db.from('vehicles').delete().eq('id', vehicleId);
      await fetchVehicles(ownerId: ownerId);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> updateMileage(String vehicleId, double newMileage) async {
    try {
      await _db.from('vehicles').update({'mileage': newMileage}).eq('id', vehicleId);
      await fetchVehicles();
    } catch (e) {
      debugPrint("Erreur mileage: $e");
    }
  }
}
