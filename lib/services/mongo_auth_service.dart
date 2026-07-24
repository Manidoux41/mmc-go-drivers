import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter01/services/mongo_service.dart';

class MongoAuthService {
  static const String _sessionKey = 'current_user_id';

  static String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  static Future<Map<String, dynamic>?> signUp({
    required String email,
    required String password,
    required Map<String, dynamic> metadata,
  }) async {
    try {
      print('MongoAuthService: Starting signUp for $email');
      
      if (!MongoService.isConnected) {
        print('MongoAuthService: Database not connected, attempting to initialize...');
        await MongoService.init();
      }

      final existingUser = await MongoService.users.findOne(where.eq('email', email)).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Délai d\'attente dépassé lors de la vérification de l\'utilisateur'),
      );

      if (existingUser != null) {
        print('MongoAuthService: User already exists');
        throw Exception('Un utilisateur avec cet email existe déjà');
      }

      final userId = ObjectId().toHexString();
      final user = {
        '_id': userId,
        'email': email,
        'password': _hashPassword(password),
        'created_at': DateTime.now().toIso8601String(),
      };

      print('MongoAuthService: Inserting into users collection...');
      await MongoService.users.insertOne(user).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Délai d\'attente dépassé lors de la création du compte'),
      );

      // Create profile
      final profile = {
        'id': userId,
        'username': email,
        'full_name': metadata['full_name'],
        'tier': metadata['tier'] ?? 'free',
        'custom_mongo_uri': metadata['custom_mongo_uri'],
        'updated_at': DateTime.now().toIso8601String(),
      };
      print('MongoAuthService: Inserting into profiles collection...');
      await MongoService.profiles.insertOne(profile).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Délai d\'attente dépassé lors de la création du profil'),
      );

      print('MongoAuthService: Saving session...');
      await _saveSession(userId);
      print('MongoAuthService: signUp completed successfully');
      return profile;
    } catch (e) {
      print('MongoAuthService: signUp Error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      if (!MongoService.isConnected) {
        print('MongoAuthService: Database not connected, attempting to initialize...');
        await MongoService.init();
      }

      final hashedPassword = _hashPassword(password);
      final user = await MongoService.users.findOne(
        where.eq('email', email).eq('password', hashedPassword),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Délai d\'attente de connexion dépassé'),
      );

      if (user == null) {
        return null;
      }

      final profile = await MongoService.profiles.findOne(where.eq('id', user['_id'])).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Délai d\'attente lors de la récupération du profil'),
      );

      if (profile != null) {
        await _saveSession(user['_id']);
      }
      return profile;
    } catch (e) {
      print('MongoAuthService: signIn Error: $e');
      rethrow;
    }
  }

  static Future<String?> getCurrentSessionUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_sessionKey);
  }

  static Future<void> _saveSession(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, userId);
  }

  static Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }
}
