import 'subscription_tier.dart';

class User {
  final String username;
  final String? fullName;
  SubscriptionTier tier;

  User({
    required this.username,
    this.fullName,
    this.tier = SubscriptionTier.free,
  });
}
