import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

class StripeService {
  // Clé publique de test (à remplacer par la vôtre en prod)
  static const String _publishableKey = 'pk_test_51PqJ...' ; // Remplacer par une vraie pk_test
  
  // Dans une vraie app, cette clé REST reste sur votre serveur (backend)
  // Pour la démo, on simule l'appel backend ici.
  static const String _secretKey = 'sk_test_...' ; 

  static Future<void> init() async {
    Stripe.publishableKey = _publishableKey;
    await Stripe.instance.applySettings();
  }

  static Future<bool> makePayment({
    required String amount,
    required String currency,
  }) async {
    try {
      // 1. Créer le PaymentIntent côté "Serveur" (Simulation)
      final paymentIntent = await _createPaymentIntent(amount, currency);

      // 2. Initialiser le Payment Sheet (Fenêtre native Stripe)
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent['client_secret'],
          style: ThemeMode.light,
          merchantDisplayName: 'MMC Go Drivers',
        ),
      );

      // 3. Afficher la fenêtre de paiement
      await Stripe.instance.presentPaymentSheet();

      return true;
    } catch (e) {
      if (e is StripeException) {
        debugPrint('Erreur Stripe: ${e.error.localizedMessage}');
      } else {
        debugPrint('Erreur de paiement: $e');
      }
      return false;
    }
  }

  static Future<Map<String, dynamic>> _createPaymentIntent(String amount, String currency) async {
    // Note: Dans une app réelle, ce code DOIT être sur votre serveur Node/Python/PHP
    // Car la secretKey ne doit JAMAIS être dans l'app mobile.
    try {
      Map<String, dynamic> body = {
        'amount': _calculateAmount(amount),
        'currency': currency,
        'payment_method_types[]': 'card'
      };

      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $_secretKey',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );
      return jsonDecode(response.body);
    } catch (err) {
      debugPrint('Erreur createPaymentIntent: ${err.toString()}');
      rethrow;
    }
  }

  static String _calculateAmount(String amount) {
    // Stripe attend le montant en centimes (ex: 2.99€ -> 299)
    final a = (double.parse(amount) * 100).toInt();
    return a.toString();
  }
}
