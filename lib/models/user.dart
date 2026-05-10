import 'subscription_tier.dart';

class User {
  final String id; // UUID de Supabase
  final String username; // Email ou identifiant
  final String? fullName;
  SubscriptionTier tier;
  final String? customSupabaseUrl;
  final String? customSupabaseAnonKey;

  User({
    required this.id,
    required this.username,
    this.fullName,
    this.tier = SubscriptionTier.free,
    this.customSupabaseUrl,
    this.customSupabaseAnonKey,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'] ?? '',
      fullName: json['full_name'],
      tier: _tierFromString(json['tier']),
      customSupabaseUrl: json['custom_supabase_url'],
      customSupabaseAnonKey: json['custom_supabase_anon_key'],
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
      'custom_supabase_url': customSupabaseUrl,
      'custom_supabase_anon_key': customSupabaseAnonKey,
    };
  }

  bool get isSuperAdmin {
    return username == 'manfredparbatia@gmail.com' || 
           username == 'michael.baze1987@gmail.com';
  }
}
