import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/secrets.dart';
import 'package:flutter01/services/mongo_service.dart';

class EmailService {
  static const String _resendApiKey = AppSecrets.resendApiKey;
  static const String _baseUrl = 'https://api.resend.com/emails';

  static Future<bool> sendDiamondRequest({
    required String senderEmail,
    required String senderName,
    required String message,
  }) async {
    try {
      // 1. Sauvegarde dans MongoDB pour le tableau de bord Super-Admin
      try {
        await MongoService.contactRequests.insertOne({
          'sender_email': senderEmail,
          'sender_name': senderName,
          'message': message,
          'status': 'pending',
          'created_at': DateTime.now().toIso8601String(),
        });
        debugPrint('Requête sauvegardée en base MongoDB');
      } catch (e) {
        debugPrint('Erreur sauvegarde requête MongoDB : $e');
      }

      // 2. Envoi de l'email via Resend
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $_resendApiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'from': 'MMC Go <onboarding@resend.dev>', // Email vérifié par défaut
          'to': ['manfredparbatia@gmail.com'], // Destinataire admin
          'subject': 'Nouvelle demande Forfait DIAMANT',
          'html': '''
            <h2>Nouvelle demande d\'abonnement Diamant</h2>
            <p><strong>Nom :</strong> $senderName</p>
            <p><strong>Email :</strong> $senderEmail</p>
            <p><strong>Message :</strong></p>
            <p>$message</p>
            <hr>
            <p>Demande reçue via l\'application MMC Go Drivers</p>
          ''',
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('Email envoyé avec succès');
        return true;
      } else {
        debugPrint('Erreur Resend : ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Erreur critique envoi email : $e');
      return false;
    }
  }
}
