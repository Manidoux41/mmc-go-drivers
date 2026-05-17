import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/driver_document.dart';

class DocumentViewModel extends ChangeNotifier {
  final ImagePicker _picker = ImagePicker();

  final List<DriverDocument> _documents = [
    DriverDocument(id: '1', title: 'Permis de conduire', type: DocumentType.license),
    DriverDocument(id: '2', title: 'Carte FIMO', type: DocumentType.fimo),
    DriverDocument(id: '3', title: 'Carte Chronotachygraphe', type: DocumentType.chrono),
    DriverDocument(id: '4', title: 'Carte Vitale', type: DocumentType.vitale),
    DriverDocument(id: '5', title: 'Carte d\'identité', type: DocumentType.identity),
  ];

  List<DriverDocument> get documents => _documents;

  Future<void> pickDocument(String id, ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        final index = _documents.indexWhere((doc) => doc.id == id);
        if (index != -1) {
          final oldDoc = _documents[index];
          _documents[index] = DriverDocument(
            id: oldDoc.id,
            title: oldDoc.title,
            type: oldDoc.type,
            expiryDate: oldDoc.expiryDate,
            filePath: image.path,
            isVerified: oldDoc.isVerified,
          );
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint("ERREUR PICK DOCUMENT : $e");
    }
  }

  void updateExpiryDate(String id, DateTime date) {
    final index = _documents.indexWhere((doc) => doc.id == id);
    if (index != -1) {
      final oldDoc = _documents[index];
      _documents[index] = DriverDocument(
        id: oldDoc.id,
        title: oldDoc.title,
        type: oldDoc.type,
        expiryDate: date,
        filePath: oldDoc.filePath,
        isVerified: oldDoc.isVerified,
      );
      notifyListeners();
    }
  }
}
