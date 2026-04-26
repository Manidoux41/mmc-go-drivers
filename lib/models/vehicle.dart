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
