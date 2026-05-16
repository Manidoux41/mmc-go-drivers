import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../models/user.dart';
import '../models/subscription_tier.dart';
import '../services/supabase_service.dart';

class FleetAdminViewModel extends ChangeNotifier {
  List<User> _drivers = [];
  bool _isLoading = false;
  SupabaseClient? _customClient;

  List<User> get drivers => _drivers;
  bool get isLoading => _isLoading;

  SupabaseClient get _db => _customClient ?? SupabaseService.client;

  void setCustomClient(String? url, String? anonKey) {
    if (url != null && anonKey != null) {
      _customClient = SupabaseClient(url, anonKey);
    } else {
      _customClient = null;
    }
  }

  void clear() {
    _drivers = [];
    _customClient = null;
    notifyListeners();
  }

  Future<void> fetchDrivers() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _db
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

  Future<bool> addDriver(String email, String fullName, String password, {
    SubscriptionTier tier = SubscriptionTier.professional,
    String? customUrl,
    String? customKey,
  }) async {
    try {
      debugPrint("DECENTRALE : Création chauffeur $email");

      // 1. Création du compte Auth dans le système central 
      // Le trigger "handle_new_user" sur la DB MASTER créera automatiquement le profil Master
      final AuthResponse res = await SupabaseService.client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'tier': tier.name.toLowerCase(),
          'custom_supabase_url': customUrl, 
          'custom_supabase_anon_key': customKey,
        },
      );
      
      if (res.user != null) {
        // 2. Enregistrement du profil dans la base de données PRIVÉE de l'entreprise (Diamond)
        if (_customClient != null) {
          debugPrint("DECENTRALE : Enregistrement dans la base privée du client...");
          await _customClient!.from('profiles').insert({
            'id': res.user!.id,
            'username': email,
            'full_name': fullName,
            'tier': tier.name.toLowerCase(), // Accès 'professional' pour le chauffeur
            'custom_supabase_url': customUrl,
            'custom_supabase_anon_key': customKey,
          });
          debugPrint("DECENTRALE : Succès base privée");
        }
      }
      
      await fetchDrivers();
      return true;
    } catch (e) {
      debugPrint("DECENTRALE ERREUR : ${e.toString()}");
      rethrow;
    }
  }

  Future<void> removeDriver(String driverId) async {
    try {
      await _db
          .from('profiles')
          .delete()
          .eq('id', driverId);
      
      await fetchDrivers();
    } catch (e) {
      debugPrint("Erreur remove driver : ${e.toString()}");
    }
  }
}
