import 'package:flutter/material.dart';
import '../models/subscription_tier.dart';
import '../models/user.dart';

class SubscriptionViewModel extends ChangeNotifier {
  User? _currentUser;
  bool _isProcessing = false;

  User? get currentUser => _currentUser;
  bool get isProcessing => _isProcessing;

  void setUser(User user) {
    _currentUser = user;
    notifyListeners();
  }

  Future<bool> subscribe(SubscriptionTier tier, String cardNumber, String expiry, String cvc) async {
    _isProcessing = true;
    notifyListeners();

    // Simulation d'un délai de paiement Stripe
    await Future.delayed(const Duration(seconds: 2));

    // Simulation de succès (on pourrait ajouter des validations ici)
    if (_currentUser != null) {
      _currentUser!.tier = tier;
      _isProcessing = false;
      notifyListeners();
      return true;
    }

    _isProcessing = false;
    notifyListeners();
    return false;
  }
}
