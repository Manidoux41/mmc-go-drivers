import 'package:universal_io/io.dart';

class StorageService {
  // En attendant une solution de stockage cloud (S3, Firebase, GridFS),
  // On gère les chemins de fichiers locaux.
  
  static Future<String?> uploadPlanningPdf(File file, String fileName) async {
    try {
      // Pour l'instant, on retourne simplement le path local du fichier
      // Dans une version finale, on uploaderait vers S3 ou GridFS
      return file.path;
    } catch (e) {
      print('Erreur upload Storage: $e');
      return null;
    }
  }

  static String getPublicUrl(String path) {
    // Retourne le path tel quel pour un usage local
    return path;
  }
}
