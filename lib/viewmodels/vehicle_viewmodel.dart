import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' show Db, DbCollection, where;
import '../models/vehicle.dart';
import 'package:flutter01/services/mongo_service.dart';

class VehicleViewModel extends ChangeNotifier {
  List<Vehicle> _vehicles = [];
  bool _isLoading = false;
  Db? _customClient;

  List<Vehicle> get vehicles => _vehicles;
  bool get isLoading => _isLoading;

  DbCollection _getCollection(String name) {
    if (_customClient != null) {
      return _customClient!.collection(name);
    }
    return MongoService.db.collection(name);
  }

  void setCustomClient(String? uri) async {
    if (uri != null) {
      _customClient = await MongoService.createClient(uri);
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
      final List<Map<String, dynamic>> data;
      
      if (ownerId != null && _customClient == null) {
        data = await _getCollection('vehicles')
            .find(where.eq('owner_id', ownerId).sortBy('registration'))
            .toList();
      } else {
        data = await _getCollection('vehicles')
            .find(where.sortBy('registration'))
            .toList();
      }
      
      _vehicles = data.map((v) => Vehicle.fromJson(v)).toList();
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
      await _getCollection('vehicles').insertOne(vehicle.toJson());
      await fetchVehicles(ownerId: vehicle.ownerId);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateVehicle(Vehicle vehicle) async {
    try {
      await _getCollection('vehicles').replaceOne(
        where.eq('id', vehicle.id),
        vehicle.toJson(),
      );
      await fetchVehicles(ownerId: vehicle.ownerId);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteVehicle(String vehicleId, {String? ownerId}) async {
    try {
      await _getCollection('vehicles').deleteOne(where.eq('id', vehicleId));
      await fetchVehicles(ownerId: ownerId);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> updateMileage(String vehicleId, double newMileage) async {
    try {
      await _getCollection('vehicles').updateOne(
        where.eq('id', vehicleId),
        {'\$set': {'mileage': newMileage}},
      );
      await fetchVehicles();
    } catch (e) {
      debugPrint("Erreur mileage: $e");
    }
  }
}
