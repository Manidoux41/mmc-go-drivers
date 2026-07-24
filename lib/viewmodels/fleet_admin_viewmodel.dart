import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' show Db, DbCollection, where;
import '../models/user.dart';
import '../models/subscription_tier.dart';
import 'package:flutter01/services/mongo_service.dart';
import 'package:flutter01/services/mongo_auth_service.dart';

class FleetAdminViewModel extends ChangeNotifier {
  List<User> _drivers = [];
  bool _isLoading = false;
  Db? _customClient;

  List<User> get drivers => _drivers;
  bool get isLoading => _isLoading;

  DbCollection _getCollection(String name) {
    if (_customClient != null) {
      return _customClient!.collection(name);
    }
    return MongoService.db.collection(name);
  }

  void setCustomClient(String? uri) async {
    if (uri != null) {
      _customClient = await MongoService.createClient(uri);
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
      final data = await _getCollection('profiles')
          .find(where.sortBy('full_name'))
          .toList();
      
      _drivers = data.map((d) => User.fromJson(d)).toList();
    } catch (e) {
      debugPrint("Erreur fetch drivers : ${e.toString()}");
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addDriver(String email, String fullName, String password, {
    SubscriptionTier tier = SubscriptionTier.professional,
    String? customUri,
  }) async {
    try {
      debugPrint("DECENTRALE : Création chauffeur $email");

      // 1. Création du compte dans le système central
      final profileData = await MongoAuthService.signUp(
        email: email,
        password: password,
        metadata: {
          'full_name': fullName,
          'tier': tier.name.toLowerCase(),
          'custom_mongo_uri': customUri,
        },
      );
      
      if (profileData != null) {
        // 2. Enregistrement du profil dans la base de données PRIVÉE de l'entreprise (Diamond)
        if (_customClient != null) {
          debugPrint("DECENTRALE : Enregistrement dans la base privée du client...");
          await _customClient!.collection('profiles').insertOne({
            'id': profileData['id'],
            'username': email,
            'full_name': fullName,
            'tier': tier.name.toLowerCase(),
            'custom_mongo_uri': customUri,
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

  Future<bool> removeDriver(String driverId) async {
    try {
      await _getCollection('profiles').deleteOne(where.eq('id', driverId));
      
      await fetchDrivers();
      return true;
    } catch (e) {
      debugPrint("ERREUR SUPPRESSION CHAUFFEUR : ${e.toString()}");
      return false;
    }
  }
}
