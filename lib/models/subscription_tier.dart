enum SubscriptionTier {
  free,
  expert,
  professional,
  diamond,
}

extension SubscriptionTierExtension on SubscriptionTier {
  String get displayName {
    switch (this) {
      case SubscriptionTier.free:
        return 'Gratuit';
      case SubscriptionTier.expert:
        return 'Expert';
      case SubscriptionTier.professional:
        return 'Professionnel';
      case SubscriptionTier.diamond:
        return 'Diamant';
    }
  }

  double get price {
    switch (this) {
      case SubscriptionTier.free:
        return 0.0;
      case SubscriptionTier.expert:
        return 2.99;
      case SubscriptionTier.professional:
        return 15.99;
      case SubscriptionTier.diamond:
        return 399.0;
    }
  }

  String get description {
    switch (this) {
      case SubscriptionTier.free:
        return '• Navigation standard\n• Enregistrement d\'un seul trajet\n• Idéal pour tester l\'application';
      case SubscriptionTier.expert:
        return '• Navigation poids-lourds (Gabarit/Poids)\n• Enregistrement illimité de trajets\n• Exportation KML/GPX\n• Support prioritaire';
      case SubscriptionTier.professional:
        return '• Tout le forfait Expert\n• Gestion complète du planning\n• Suivi des véhicules et documents\n• Répertoire des contacts transport';
      case SubscriptionTier.diamond:
        return '• Tout le forfait Professionnel\n• Base de données dédiée et sécurisée\n• Multi-utilisateurs et gestion de flotte\n• Personnalisation sur mesure';
    }
  }
}
