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

  void clear() {
    _allUsers = [];
    _contactRequests = [];
    notifyListeners();
  }

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

  Future<bool> updateUserTier(String userId, SubscriptionTier tier, {String? customUrl, String? customKey}) async {
    try {
      final String tierString = tier.name;
      
      final Map<String, dynamic> updates = {
        'tier': tierString,
        'custom_supabase_url': customUrl?.trim(),
        'custom_supabase_anon_key': customKey?.trim(),
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      debugPrint(">>> SYNCHRO DEBUT : Mise à jour $userId vers $tierString");

      final response = await SupabaseService.client
          .from('profiles')
          .update(updates)
          .eq('id', userId)
          .select();
      
      if (response == null || (response as List).isEmpty) {
        debugPrint(">>> SYNCHRO ECHEC : Aucun retour de Supabase. Probablement bloqué par RLS.");
        return false;
      }

      debugPrint(">>> SYNCHRO SUCCES : Supabase a confirmé l'update : ${response[0]}");
      
      await fetchAllData();
      return true;
    } catch (e) {
      debugPrint(">>> SYNCHRO ERREUR FATALE : $e");
      return false;
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
