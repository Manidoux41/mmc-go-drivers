enum FuelType { diesel, electric, hvo, gas, essence, other }

class Vehicle {
  final String id;
  final String registration; // Plaque d'immatriculation
  final String brand;
  final String model;
  final double height; // en mètres
  final double length; // en mètres
  final double width;  // en mètres
  final double unladenWeight; // Poids à vide en tonnes
  final double ptac;          // Poids Total Autorisé en Charge en tonnes
  final FuelType fuelType;
  final String? parkNumber; // Numéro de parc
  double mileage;      // en km
  final String? ownerId; // UUID du propriétaire (pour le forfait pro individuel)

  Vehicle({
    required this.id,
    required this.registration,
    required this.brand,
    required this.model,
    required this.height,
    required this.length,
    required this.width,
    required this.unladenWeight,
    required this.ptac,
    required this.fuelType,
    this.parkNumber,
    required this.mileage,
    this.ownerId,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'].toString(),
      registration: json['registration'] ?? '',
      brand: json['brand'] ?? '',
      model: json['model'] ?? '',
      height: (json['height'] as num?)?.toDouble() ?? 3.5,
      length: (json['length'] as num?)?.toDouble() ?? 12.0,
      width: (json['width'] as num?)?.toDouble() ?? 2.5,
      unladenWeight: (json['unladen_weight'] as num?)?.toDouble() ?? 12.0,
      ptac: (json['ptac'] as num?)?.toDouble() ?? 19.0,
      fuelType: _fuelFromString(json['fuel_type']),
      parkNumber: json['park_number'],
      mileage: (json['mileage'] as num?)?.toDouble() ?? 0,
      ownerId: json['owner_id'],
    );
  }

  static FuelType _fuelFromString(String? fuel) {
    switch (fuel) {
      case 'electric': return FuelType.electric;
      case 'hvo': return FuelType.hvo;
      case 'gas': return FuelType.gas;
      case 'essence': return FuelType.essence;
      case 'other': return FuelType.other;
      default: return FuelType.diesel;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'registration': registration,
      'brand': brand,
      'model': model,
      'height': height,
      'length': length,
      'width': width,
      'unladen_weight': unladenWeight,
      'ptac': ptac,
      'fuel_type': fuelType.name.toLowerCase(),
      'park_number': parkNumber,
      'mileage': mileage,
      'owner_id': ownerId,
    };
  }

  String get dimensions => '${length}m x ${width}m x ${height}m';
  
  String get fuelLabel {
    switch (fuelType) {
      case FuelType.diesel: return 'Diesel';
      case FuelType.electric: return 'Électrique';
      case FuelType.hvo: return 'HVO';
      case FuelType.gas: return 'Gaz (GNV)';
      case FuelType.essence: return 'Essence';
      case FuelType.other: return 'Autre';
    }
  }
}
