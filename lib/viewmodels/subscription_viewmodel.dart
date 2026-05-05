import 'package:flutter/material.dart';
import '../models/subscription_tier.dart';
import '../models/user.dart';
import '../services/supabase_service.dart';
import '../services/stripe_service.dart';

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
      
      // Mise à jour réelle dans Supabase
      try {
        await SupabaseService.client
            .from('profiles')
            .update({'tier': tier.name.toLowerCase()})
            .eq('id', _currentUser!.id);
      } catch (e) {
        debugPrint("Erreur mise à jour tier Supabase : ${e.toString()}");
      }
    }

    _isProcessing = false;
    notifyListeners();
    return success;
  }
}
