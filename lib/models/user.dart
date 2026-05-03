import 'subscription_tier.dart';

class User {
  final String id; // UUID de Supabase
  final String username; // Email ou identifiant
  final String? fullName;
  SubscriptionTier tier;

  User({
    required this.id,
    required this.username,
    this.fullName,
    this.tier = SubscriptionTier.free,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'] ?? '',
      fullName: json['full_name'],
      tier: _tierFromString(json['tier']),
    );
  }

  static SubscriptionTier _tierFromString(String? tier) {
    switch (tier) {
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
    };
  }
}
