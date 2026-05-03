import 'package:flutter/material.dart';
import '../models/vehicle.dart';
import '../services/supabase_service.dart';

class VehicleViewModel extends ChangeNotifier {
  List<Vehicle> _vehicles = [];
  bool _isLoading = false;

  List<Vehicle> get vehicles => _vehicles;
  bool get isLoading => _isLoading;

  Future<void> fetchVehicles() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await SupabaseService.client
          .from('vehicles')
          .select()
          .order('registration');
      
      _vehicles = (data as List).map((v) => Vehicle.fromJson(v)).toList();
    } catch (e) {
      debugPrint("Erreur fetch vehicles : ${e.toString()}");
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addVehicle(Vehicle vehicle) async {
    try {
      await SupabaseService.client
          .from('vehicles')
          .insert(vehicle.toJson());
      
      await fetchVehicles();
    } catch (e) {
      debugPrint("Erreur add vehicle : ${e.toString()}");
    }
  }

  Future<void> updateMileage(String vehicleId, double newMileage) async {
    try {
      await SupabaseService.client
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
