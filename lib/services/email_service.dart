import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/secrets.dart';

import '../services/supabase_service.dart';

class EmailService {
  static const String _apiKey = AppSecrets.resendApiKey;
  static const String _adminEmail = 'lherissondu41@gmail.com';

  static Future<bool> sendDiamondRequest({
    required String senderEmail,
    required String senderName,
    required String message,
  }) async {
    // 1. Sauvegarde dans Supabase pour le tableau de bord Super-Admin
    try {
      await SupabaseService.client.from('contact_requests').insert({
        'sender_email': senderEmail,
        'sender_name': senderName,
        'message': message,
      });
    } catch (e) {
      debugPrint('Erreur sauvegarde requête Supabase : $e');
    }

    // 2. Envoi de l'email via Resend
    final url = Uri.parse('https://api.resend.com/emails');

    final body = jsonEncode({
      'from': 'MMC Go Drivers <onboarding@resend.dev>', // Resend impose ce domaine par défaut pour les tests
      'to': [_adminEmail],
      'subject': 'Nouvelle demande Forfait Diamant - $senderName',
      'html': '''
        <h1>Nouvelle Demande de Forfait Diamant</h1>
        <p><strong>Nom :</strong> $senderName</p>
        <p><strong>Email de contact :</strong> $senderEmail</p>
        <p><strong>Message :</strong></p>
        <p style="white-space: pre-wrap;">$message</p>
      ''',
    });

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('Email envoyé avec succès via Resend');
        return true;
      } else {
        debugPrint('Erreur Resend (${response.statusCode}): ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Erreur réseau lors de l\'envoi de l\'email: $e');
      return false;
    }
  }
}
