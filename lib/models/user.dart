import 'package:flutter01/models/subscription_tier.dart';

class User {
  final String id; // ID MongoDB (hex string)
  final String username; // Email ou identifiant
  final String? fullName;
  SubscriptionTier tier;
  final String? customMongoUri;

  User({
    required this.id,
    required this.username,
    this.fullName,
    this.tier = SubscriptionTier.free,
    this.customMongoUri,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? json['_id']?.toString() ?? '',
      username: json['username'] ?? '',
      fullName: json['full_name'],
      tier: _tierFromString(json['tier']),
      customMongoUri: json['custom_mongo_uri'],
    );
  }

  static SubscriptionTier _tierFromString(String? tier) {
    if (tier == null) return SubscriptionTier.free;
    final String t = tier.toLowerCase().trim();
    
    switch (t) {
      case 'expert': return SubscriptionTier.expert;
      case 'professional': return SubscriptionTier.professional;
      case 'diamond': return SubscriptionTier.diamond;
      default: return SubscriptionTier.free;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'full_name': fullName,
      'tier': tier.name.toLowerCase(),
      'custom_mongo_uri': customMongoUri,
    };
  }

  bool get isSuperAdmin {
    return username == 'manfredparbatia@gmail.com' || 
           username == 'michael.baze1987@gmail.com';
  }
}
