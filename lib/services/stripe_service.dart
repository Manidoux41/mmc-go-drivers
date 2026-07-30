import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

import 'package:flutter01/config/secrets.dart';

class StripeService {
  static const String _publishableKey = AppSecrets.stripePublishableKey;
  static const String _secretKey = AppSecrets.stripeSecretKey;

  static Future<void> init() async {
    Stripe.publishableKey = _publishableKey;
    await Stripe.instance.applySettings();
  }

  static Future<bool> makePayment({
    required String amount,
    required String currency,
  }) async {
    try {
      // 1. Créer le PaymentIntent
      final paymentIntent = await _createPaymentIntent(amount, currency);
      
      if (paymentIntent['client_secret'] == null) {
        debugPrint('Erreur: Le serveur Stripe n\'a pas renvoyé de client_secret');
        debugPrint('Réponse Stripe: $paymentIntent');
        return false;
      }

      // 2. Initialiser le Payment Sheet
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
        if (e.error.code == FailureCode.Canceled) {
          debugPrint('Paiement annulé par l\'utilisateur');
        } else {
          debugPrint('Erreur Stripe fatale: ${e.error.localizedMessage}');
        }
      } else {
        debugPrint('Erreur inconnue lors du paiement: $e');
      }
      return false;
    }
  }

  static Future<Map<String, dynamic>> _createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': _calculateAmount(amount),
        'currency': currency,
        'automatic_payment_methods[enabled]': 'true',
      };

      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $_secretKey',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );
      
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (data['error'] != null) {
        debugPrint('Erreur API Stripe (PaymentIntent): ${data['error']['message']}');
      }
      return data;
    } catch (err) {
      debugPrint('Erreur réseau createPaymentIntent: ${err.toString()}');
      rethrow;
    }
  }

  static String _calculateAmount(String amount) {
    final a = (double.parse(amount) * 100).toInt();
    return a.toString();
  }
}
