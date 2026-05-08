import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/secrets.dart';

class SupabaseService {
  static const String _defaultUrl = AppSecrets.supabaseUrl;
  static const String _defaultAnonKey = AppSecrets.supabaseAnonKey;

  static Future<void> init() async {
    await Supabase.initialize(
      url: _defaultUrl,
      anonKey: _defaultAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;

  /// Crée un client temporaire pour une base de données décentralisée (Diamant)
  static SupabaseClient createClient(String url, String anonKey) {
    return SupabaseClient(url, anonKey);
  }
}
