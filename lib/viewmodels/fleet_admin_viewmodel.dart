import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/subscription_tier.dart';
import '../services/supabase_service.dart';

class FleetAdminViewModel extends ChangeNotifier {
  List<User> _drivers = [];
  bool _isLoading = false;

  List<User> get drivers => _drivers;
  bool get isLoading => _isLoading;

  void clear() {
    _drivers = [];
    notifyListeners();
  }

  Future<void> fetchDrivers() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await SupabaseService.client
          .from('profiles')
          .select()
          .order('full_name');
      
      _drivers = (data as List).map((d) => User.fromJson(d)).toList();
    } catch (e) {
      debugPrint("Erreur fetch drivers : ${e.toString()}");
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addDriver(String email, String fullName, String password, {
    SubscriptionTier tier = SubscriptionTier.professional,
    String? customUrl,
    String? customKey,
  }) async {
    try {
      await SupabaseService.client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'tier': tier.name.toLowerCase(),
          'custom_supabase_url': customUrl,
          'custom_supabase_anon_key': customKey,
        },
      );
      
      await fetchDrivers();
    } catch (e) {
      debugPrint("Erreur add driver : ${e.toString()}");
    }
  }

  Future<void> removeDriver(String driverId) async {
    try {
      // Suppression du profil (la cascade supprimera l'auth.user si configuré, 
      // sinon il faut une Edge Function)
      await SupabaseService.client
          .from('profiles')
          .delete()
          .eq('id', driverId);
      
      await fetchDrivers();
    } catch (e) {
      debugPrint("Erreur remove driver : ${e.toString()}");
    }
  }

  // Ces méthodes ne sont plus nécessaires avec la vraie Auth Supabase
  bool validateCredentials(String username, String password) => false;
  User? getDriver(String username) => null;
}
