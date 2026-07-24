import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' show where;
import '../models/user.dart';
import '../models/subscription_tier.dart';
import 'package:flutter01/services/mongo_service.dart';

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
      final usersData = await MongoService.profiles
          .find(where.sortBy('full_name'))
          .toList();
      _allUsers = usersData.map((u) => User.fromJson(u)).toList();

      // Fetch toutes les demandes de contact
      final requestsData = await MongoService.contactRequests
          .find(where.sortBy('created_at', descending: true))
          .toList();
      _contactRequests = List<Map<String, dynamic>>.from(requestsData);

    } catch (e) {
      debugPrint("Erreur Super-Admin fetch : $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateUserTier(String userId, SubscriptionTier tier, {String? customUri}) async {
    try {
      final String tierString = tier.name;
      
      final Map<String, dynamic> updates = {
        'tier': tierString,
        'custom_mongo_uri': customUri?.trim(),
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      debugPrint(">>> SYNCHRO DEBUT : Mise à jour $userId vers $tierString");

      await MongoService.profiles.updateOne(
        where.eq('id', userId),
        {'\$set': updates},
      );

      debugPrint(">>> SYNCHRO SUCCES : MongoDB a confirmé l'update");
      
      await fetchAllData();
      return true;
    } catch (e) {
      debugPrint(">>> SYNCHRO ERREUR FATALE : $e");
      return false;
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await MongoService.profiles.deleteOne(where.eq('id', userId));
      // En MongoDB, on devrait aussi supprimer de la collection 'users'
      await MongoService.users.deleteOne(where.eq('_id', userId));
      await fetchAllData();
    } catch (e) {
      debugPrint("Erreur delete user : $e");
    }
  }

  Future<void> markRequestProcessed(String requestId) async {
    try {
      await MongoService.contactRequests.updateOne(
        where.eq('id', requestId),
        {'\$set': {'status': 'processed'}},
      );
      await fetchAllData();
    } catch (e) {
      debugPrint("Erreur update request : $e");
    }
  }
}
