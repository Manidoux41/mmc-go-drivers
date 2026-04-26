import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/subscription_tier.dart';

class FleetAdminViewModel extends ChangeNotifier {
  final List<User> _drivers = [
    User(username: 'driver1', fullName: 'Jean Dupont', tier: SubscriptionTier.free),
    User(username: 'driver2', fullName: 'Marie Durand', tier: SubscriptionTier.free),
    User(username: 'driver3', fullName: 'Pierre Martin', tier: SubscriptionTier.free),
  ];

  List<User> get drivers => _drivers;

  void addDriver(String username, String fullName) {
    _drivers.add(User(username: username, fullName: fullName, tier: SubscriptionTier.free));
    notifyListeners();
  }

  void removeDriver(String username) {
    _drivers.removeWhere((d) => d.username == username);
    notifyListeners();
  }
}
