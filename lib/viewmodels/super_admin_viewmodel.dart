import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/subscription_tier.dart';
import '../services/supabase_service.dart';

class SuperAdminViewModel extends ChangeNotifier {
  List<User> _allUsers = [];
  List<Map<String, dynamic>> _contactRequests = [];
  bool _isLoading = false;

  List<User> get allUsers => _allUsers;
  List<Map<String, dynamic>> get contactRequests => _contactRequests;
  bool get isLoading => _isLoading;

  Future<void> fetchAllData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Fetch tous les utilisateurs
      final usersData = await SupabaseService.client
          .from('profiles')
          .select()
          .order('full_name');
      _allUsers = (usersData as List).map((u) => User.fromJson(u)).toList();

      // Fetch toutes les demandes de contact
      final requestsData = await SupabaseService.client
          .from('contact_requests')
          .select()
          .order('created_at', ascending: false);
      _contactRequests = List<Map<String, dynamic>>.from(requestsData);

    } catch (e) {
      debugPrint("Erreur Super-Admin fetch : $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateUserTier(String userId, SubscriptionTier tier, {String? customUrl, String? customKey}) async {
    try {
      Map<String, dynamic> updates = {
        'tier': tier.name.toLowerCase(),
      };
      
      if (tier == SubscriptionTier.diamond) {
        updates['custom_supabase_url'] = customUrl;
        updates['custom_supabase_anon_key'] = customKey;
      }

      await SupabaseService.client
          .from('profiles')
          .update(updates)
          .eq('id', userId);
      await fetchAllData();
    } catch (e) {
      debugPrint("Erreur update tier : $e");
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      // La suppression du profil déclenchera la cascade sur les activités
      // Note: Pour supprimer l'Auth user, il faudrait une Edge Function (Admin SDK)
      await SupabaseService.client.from('profiles').delete().eq('id', userId);
      await fetchAllData();
    } catch (e) {
      debugPrint("Erreur delete user : $e");
    }
  }

  Future<void> markRequestProcessed(String requestId) async {
    try {
      await SupabaseService.client
          .from('contact_requests')
          .update({'status': 'processed'})
          .eq('id', requestId);
      await fetchAllData();
    } catch (e) {
      debugPrint("Erreur update request : $e");
    }
  }
}
