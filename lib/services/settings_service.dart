import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _dbUrlKey = 'database_url';

  Future<void> saveDatabaseUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dbUrlKey, url);
  }

  Future<String?> getDatabaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_dbUrlKey);
  }
}
