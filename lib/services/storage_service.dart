import 'package:universal_io/io.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class StorageService {
  static const String _bucketName = 'plannings';

  static Future<String?> uploadPlanningPdf(File file, String fileName) async {
    try {
      final String path = await SupabaseService.client.storage
          .from(_bucketName)
          .upload(fileName, file);
      
      // Retourne l'URL publique ou le chemin
      return path;
    } catch (e) {
      print('Erreur upload Storage: $e');
      return null;
    }
  }

  static String getPublicUrl(String path) {
    return SupabaseService.client.storage.from(_bucketName).getPublicUrl(path);
  }
}
