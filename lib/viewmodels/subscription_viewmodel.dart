import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' show where;
import 'package:flutter01/models/subscription_tier.dart';
import 'package:flutter01/models/user.dart';
import 'package:flutter01/services/mongo_service.dart';
import 'package:flutter01/services/stripe_service.dart';

class SubscriptionViewModel extends ChangeNotifier {
  User? _currentUser;
  bool _isProcessing = false;

  User? get currentUser => _currentUser;
  bool get isProcessing => _isProcessing;

  void setUser(User user) {
    _currentUser = user;
    notifyListeners();
  }

  Future<bool> subscribe(SubscriptionTier tier, {bool useStripe = false}) async {
    _isProcessing = true;
    notifyListeners();

    bool success = false;

    if (useStripe) {
      // Tentative de paiement réel via Stripe
      success = await StripeService.makePayment(
        amount: tier.price.toString(),
        currency: 'eur',
      );
    } else {
      // Simulation d'un délai de paiement pour la carte fictive
      await Future.delayed(const Duration(seconds: 2));
      success = true; // La carte fictive accepte toujours
    }

    if (success && _currentUser != null) {
      _currentUser!.tier = tier;
      
      // Mise à jour réelle dans MongoDB
      try {
        await MongoService.profiles.updateOne(
          where.eq('id', _currentUser!.id),
          {'\$set': {'tier': tier.name.toLowerCase()}},
        );
      } catch (e) {
        debugPrint("Erreur mise à jour tier MongoDB : ${e.toString()}");
      }
    }

    _isProcessing = false;
    notifyListeners();
    return success;
  }
}
