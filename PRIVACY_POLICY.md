# Politique de Confidentialité - MMC Go Drivers

**Dernière mise à jour : 20 mai 2024**

Chez **MMC Go Drivers**, la protection de votre vie privée est notre priorité. Cette politique explique comment nous traitons vos données dans le cadre de notre application de gestion de transport.

## 1. Données Collectées

### 1.1 Données de Localisation (Essentiel)
L'application collecte vos données de localisation précises (GPS) même lorsque l'application est fermée ou n'est pas utilisée.
- **Pourquoi ?** Pour permettre l'enregistrement de vos trajets professionnels, le guidage GPS spécialisé Poids-Lourds (évitement des ponts bas, zones restreintes) et le suivi des missions en temps réel.

### 1.2 Informations du Compte
Nous utilisons **Supabase** pour gérer votre authentification. Nous collectons :
- Votre adresse email (identifiant).
- Votre nom complet.
- Votre niveau d'abonnement (Gratuit, Expert, Professionnel, Diamant).

### 1.3 Informations Véhicule
Pour le calcul d'itinéraires PL, nous stockons :
- Immatriculation, marque et modèle.
- Dimensions (hauteur, largeur, longueur) et tonnage (PTAC).

### 1.4 Documents et Médias
- **Planning Photo** : Vos photos de plannings papier sont converties en PDF et stockées sur nos serveurs sécurisés (**Supabase Storage**).

## 2. Services Tiers et Partage

Nous partageons vos données uniquement avec les services nécessaires au fonctionnement de l'application :
- **Supabase** : Hébergement de la base de données et authentification.
- **Stripe** : Traitement sécurisé des paiements (nous ne stockons jamais vos numéros de carte).
- **OpenRouteService** : Calcul d'itinéraires techniques (envoi anonymisé des coordonnées et du gabarit).
- **Resend** : Envoi des demandes de contact et notifications par email.

## 3. Conservation et Sécurité
Vos données sont conservées tant que votre compte est actif. Elles sont sécurisées par un chiffrement de bout en bout lors des transferts (HTTPS).

## 4. Vos Droits (RGPD)
Vous disposez d'un droit d'accès, de rectification et de suppression de vos données à tout moment.

## 5. Suppression de Compte
Vous pouvez demander la suppression immédiate de votre compte et de toutes les données associées (profil, trajets, PDF) :
- Directement via notre [Formulaire de suppression](https://mmcgo-drivers.com/data_deletion) (Lien à adapter).
- Par email à : lherissondu41@gmail.com
