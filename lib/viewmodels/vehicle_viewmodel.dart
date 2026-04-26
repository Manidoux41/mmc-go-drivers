import 'package:flutter/material.dart';
import '../models/vehicle.dart';

class VehicleViewModel extends ChangeNotifier {
  final List<Vehicle> _vehicles = [
    Vehicle(
      id: 'V1',
      registration: 'AA-123-BB',
      brand: 'Mercedes-Benz',
      model: 'Intouro',
      height: 3.35,
      length: 12.14,
      width: 2.55,
      unladenWeight: 11.2,
      ptac: 19.0,
      fuelType: FuelType.diesel,
      mileage: 125400,
    ),
    Vehicle(
      id: 'V2',
      registration: 'CC-456-DD',
      brand: 'IVECO',
      model: 'Crossway Pop',
      height: 3.45,
      length: 12.96,
      width: 2.55,
      unladenWeight: 11.8,
      ptac: 18.0,
      fuelType: FuelType.hvo,
      mileage: 89200,
    ),
    Vehicle(
      id: 'V3',
      registration: 'EE-789-FF',
      brand: 'MAN',
      model: 'Lion\'s Coach',
      height: 3.87,
      length: 13.09,
      width: 2.55,
      unladenWeight: 13.5,
      ptac: 19.5,
      fuelType: FuelType.diesel,
      mileage: 210500,
    ),
    Vehicle(
      id: 'V4',
      registration: 'GG-012-HH',
      brand: 'IVECO',
      model: 'Crossway Natural Power',
      height: 3.55,
      length: 12.10,
      width: 2.55,
      unladenWeight: 12.5,
      ptac: 18.0,
      fuelType: FuelType.gas,
      mileage: 45600,
    ),
    Vehicle(
      id: 'V5',
      registration: 'II-345-JJ',
      brand: 'Volvo',
      model: '7900 Electric',
      height: 3.30,
      length: 12.00,
      width: 2.55,
      unladenWeight: 12.0,
      ptac: 19.0,
      fuelType: FuelType.electric,
      mileage: 32100,
    ),
    Vehicle(
      id: 'V6',
      registration: 'KK-678-LL',
      brand: 'Setra',
      model: 'S 515 HD',
      height: 3.77,
      length: 12.30,
      width: 2.55,
      unladenWeight: 13.2,
      ptac: 18.0,
      fuelType: FuelType.diesel,
      mileage: 156000,
    ),
    Vehicle(
      id: 'V7',
      registration: 'MM-901-NN',
      brand: 'Mercedes-Benz',
      model: 'Tourismo',
      height: 3.68,
      length: 13.11,
      width: 2.55,
      unladenWeight: 13.8,
      ptac: 19.0,
      fuelType: FuelType.diesel,
      mileage: 178900,
    ),
    Vehicle(
      id: 'V8',
      registration: 'OO-234-PP',
      brand: 'IVECO',
      model: 'Daily Blue Power',
      height: 2.70,
      length: 7.10,
      width: 2.00,
      unladenWeight: 3.5,
      ptac: 7.0,
      fuelType: FuelType.gas,
      mileage: 67000,
    ),
    Vehicle(
      id: 'V9',
      registration: 'QQ-567-RR',
      brand: 'Irizar',
      model: 'ie bus',
      height: 3.20,
      length: 12.16,
      width: 2.55,
      unladenWeight: 12.8,
      ptac: 19.5,
      fuelType: FuelType.electric,
      mileage: 15000,
    ),
    Vehicle(
      id: 'V10',
      registration: 'SS-890-TT',
      brand: 'MAN',
      model: 'Lion\'s Intercity LE',
      height: 3.40,
      length: 12.44,
      width: 2.55,
      unladenWeight: 11.5,
      ptac: 18.0,
      fuelType: FuelType.hvo,
      mileage: 23000,
    ),
  ];

  List<Vehicle> get vehicles => _vehicles;

  void updateMileage(String vehicleId, double newMileage) {
    final index = _vehicles.indexWhere((v) => v.id == vehicleId);
    if (index != -1 && newMileage > _vehicles[index].mileage) {
      _vehicles[index].mileage = newMileage;
      notifyListeners();
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
