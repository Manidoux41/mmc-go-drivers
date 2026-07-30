import 'package:mongo_dart/mongo_dart.dart';
import 'package:flutter01/config/secrets.dart';

class MongoService {
  static Db? _db;
  static const String _defaultUri = AppSecrets.mongoUri;

  static Future<void> init() async {
    if (isConnected) {
      print('MongoService: Already connected to ${_db!.databaseName}');
      return;
    }

    try {
      print('MongoService: Initializing with URI: $_defaultUri');
      final dbClient = await Db.create(_defaultUri);
      
      // On ajoute un timeout à l'ouverture de la connexion
      await dbClient.open().timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw Exception('Délai d\'attente de connexion à MongoDB dépassé (15s)'),
      );
      
      _db = dbClient;
      print('MongoService: MongoDB Connected successfully to ${_db!.databaseName}');
      
      // Vérification/Création des collections
      try {
        await _db!.createCollection('users');
        await _db!.createCollection('profiles');
        print('MongoService: Collections verified');
      } catch (e) {
        print('MongoService: Warning while creating collections: $e');
        // On continue même si createCollection échoue (elles existent sûrement déjà)
      }
    } catch (e) {
      print('MongoService: Error connecting to MongoDB: $e');
      _db = null; // S'assurer que _db reste null en cas d'échec
      rethrow;
    }
  }

  static bool get isConnected {
    final connected = _db != null && _db!.isConnected;
    print('MongoService: isConnected check: $connected (_db is ${_db == null ? 'null' : 'active'})');
    return connected;
  }

  static Db get db {
    print('MongoService: accessing db getter (_db is ${_db == null ? 'null' : 'active'})');
    if (_db == null) {
      throw Exception('MongoService not initialized. Call init() first.');
    }
    return _db!;
  }

  // Collections
  static DbCollection get users => db.collection('users');
  static DbCollection get profiles => db.collection('profiles');
  static DbCollection get vehicles => db.collection('vehicles');
  static DbCollection get activities => db.collection('activities');
  static DbCollection get recordedTrips => db.collection('recorded_trips');
  static DbCollection get contactRequests => db.collection('contact_requests');

  /// Crée un client temporaire pour une base de données décentralisée (Diamant)
  static Future<Db> createClient(String uri) async {
    final db = await Db.create(uri);
    await db.open();
    return db;
  }
}
