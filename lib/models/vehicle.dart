enum FuelType { diesel, electric, hvo, gas }

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
  double mileage;      // en km

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
    required this.mileage,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'],
      registration: json['registration'],
      brand: json['brand'],
      model: json['model'],
      height: (json['height'] as num).toDouble(),
      length: (json['length'] as num).toDouble(),
      width: (json['width'] as num).toDouble(),
      unladenWeight: (json['unladen_weight'] as num).toDouble(),
      ptac: (json['ptac'] as num).toDouble(),
      fuelType: _fuelFromString(json['fuel_type']),
      mileage: (json['mileage'] as num).toDouble(),
    );
  }

  static FuelType _fuelFromString(String? fuel) {
    switch (fuel) {
      case 'electric': return FuelType.electric;
      case 'hvo': return FuelType.hvo;
      case 'gas': return FuelType.gas;
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
      'mileage': mileage,
    };
  }

  String get dimensions => '${length}m x ${width}m x ${height}m';
  
  String get fuelLabel {
    switch (fuelType) {
      case FuelType.diesel: return 'Diesel';
      case FuelType.electric: return 'Électrique';
      case FuelType.hvo: return 'HVO';
      case FuelType.gas: return 'Gaz (GNV)';
    }
  }
}
