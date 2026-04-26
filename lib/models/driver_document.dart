import 'dart:io';

enum DocumentType {
  license,
  fimo,
  chrono,
  vitale,
  identity
}

class DriverDocument {
  final String id;
  final String title;
  final DocumentType type;
  final DateTime? expiryDate;
  final String? filePath; // Chemin local du fichier/image
  final bool isVerified;

  DriverDocument({
    required this.id,
    required this.title,
    required this.type,
    this.expiryDate,
    this.filePath,
    this.isVerified = false,
  });

  bool get isExpired => expiryDate != null && expiryDate!.isBefore(DateTime.now());
}
