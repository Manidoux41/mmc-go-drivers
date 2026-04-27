import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/subscription_tier.dart';

class FleetAdminViewModel extends ChangeNotifier {
  final List<User> _drivers = [
    User(username: 'driver1', fullName: 'Jean Dupont', tier: SubscriptionTier.professional),
    User(username: 'driver2', fullName: 'Marie Durand', tier: SubscriptionTier.professional),
    User(username: 'driver3', fullName: 'Pierre Martin', tier: SubscriptionTier.professional),
  ];

  // Simulation d'une base de données de mots de passe
  final Map<String, String> _passwords = {
    'driver1': 'password123',
    'driver2': 'password123',
    'driver3': 'password123',
  };

  List<User> get drivers => _drivers;

  void addDriver(String username, String fullName, String password) {
    _drivers.add(User(username: username, fullName: fullName, tier: SubscriptionTier.professional));
    _passwords[username] = password;
    notifyListeners();
  }

  bool validateCredentials(String username, String password) {
    return _passwords.containsKey(username) && _passwords[username] == password;
  }

  User? getDriver(String username) {
    try {
      return _drivers.firstWhere((d) => d.username == username);
    } catch (e) {
      return null;
    }
  }

  void removeDriver(String username) {
    _drivers.removeWhere((d) => d.username == username);
    notifyListeners();
  }
}
