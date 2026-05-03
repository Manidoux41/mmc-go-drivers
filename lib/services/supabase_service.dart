import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/secrets.dart';

class SupabaseService {
  static const String _url = AppSecrets.supabaseUrl;
  static const String _anonKey = AppSecrets.supabaseAnonKey;

  static Future<void> init() async {
    await Supabase.initialize(
      url: _url,
      anonKey: _anonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
