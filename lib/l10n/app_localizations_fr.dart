// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'MMC Go Drivers';

  @override
  String get selectLanguage => 'Choisissez votre langue';

  @override
  String get continueAction => 'CONTINUER';

  @override
  String get welcome => 'Bienvenue';

  @override
  String get dashboard => 'Tableau de bord';

  @override
  String get navigation => 'Navigation';

  @override
  String get planning => 'Planning';

  @override
  String get vehicle => 'Véhicule';

  @override
  String get documents => 'Documents';

  @override
  String get contact => 'Contact';

  @override
  String get administration => 'Administration';

  @override
  String get superAdmin => 'Super Admin';

  @override
  String get logout => 'Déconnexion';

  @override
  String get login => 'Se connecter';

  @override
  String get register => 'S\'inscrire';

  @override
  String get email => 'Email';

  @override
  String get password => 'Mot de passe';

  @override
  String get hello => 'Bonjour';

  @override
  String get tier => 'Abonnement';

  @override
  String get tools => 'Outils';

  @override
  String get loading => 'Chargement...';

  @override
  String get error => 'Erreur';

  @override
  String get confirm => 'Confirmer';

  @override
  String get cancel => 'Annuler';

  @override
  String get navAndRecording => 'Navigation & Enregistrement';

  @override
  String helloUser(Object username) {
    return 'Bonjour, $username';
  }

  @override
  String get mmcAccount => 'Compte MMC Go';

  @override
  String get manageSubscription => 'Gérer mon abonnement';

  @override
  String get aboutMMC => 'À propos de MMC Go';

  @override
  String get calculatingRoute => 'Calcul de l\'itinéraire PL optimisé...';

  @override
  String vehicleInfo(Object registration) {
    return 'Véhicule: $registration';
  }

  @override
  String get hgvOptimized => '⚠️ Itinéraire optimisé Poids-Lourds';

  @override
  String get startPoint => 'Point de départ';

  @override
  String get destination => 'Destination';

  @override
  String get waypoint => 'Étape';

  @override
  String get addStep => 'Ajouter une étape';

  @override
  String get chooseRoute => 'Choix de l\'itinéraire';

  @override
  String get startNav => 'DÉMARRER';

  @override
  String get calculateRoute => 'CALCULER L\'ITINÉRAIRE';

  @override
  String get saveTrip => 'Enregistrer le trajet';

  @override
  String get tripName => 'Nom du trajet';

  @override
  String get tripHistory => 'Historique des trajets';

  @override
  String get stats => 'Statistiques';

  @override
  String get speed => 'VITESSE';

  @override
  String get distance => 'DISTANCE';

  @override
  String get altitude => 'ALTITUDE';

  @override
  String get universalTool => 'L\'outil universel des transporteurs';

  @override
  String get dbConfig => 'Configuration DB';

  @override
  String get username => 'Identifiant';

  @override
  String get noAccount => 'Pas encore de compte ?';

  @override
  String get loginAction => 'SE CONNECTER';

  @override
  String get registerAction => 'S\'INSCRIRE';

  @override
  String get fullName => 'Nom complet';

  @override
  String get alreadyHaveAccount => 'Déjà un compte ?';

  @override
  String get passwordMinimum =>
      'Le mot de passe doit faire au moins 6 caractères';

  @override
  String get emailRequired => 'L\'email et le mot de passe sont requis';

  @override
  String get createAccount => 'Créer un compte';

  @override
  String get joinMMC => 'Rejoignez MMC Go Drivers';

  @override
  String get confirmPassword => 'Confirmer le mot de passe';

  @override
  String get passwordsDoNotMatch => 'Les mots de passe ne correspondent pas';

  @override
  String get registerAndChoosePlan => 'S\'INSCRIRE ET CHOISIR UN FORFAIT';

  @override
  String get myPlanning => 'Mon Planning';

  @override
  String get exportPdf => 'Exporter en PDF';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get missionPasted => 'Mission collée avec succès';

  @override
  String get pasteMission => 'Coller la mission copiée';

  @override
  String get rseAlerts => 'Alertes RSE';

  @override
  String get noTrips => 'Aucun trajet prévu pour cette période';

  @override
  String get addPersonalMission => 'Ajouter une mission personnelle';

  @override
  String get day => 'Jour';

  @override
  String get week => 'Semaine';

  @override
  String get month => 'Mois';

  @override
  String fromTo(Object end, Object start) {
    return 'Du $start au $end';
  }

  @override
  String get edit => 'Modifier';

  @override
  String get delete => 'Supprimer';

  @override
  String get bus => 'Bus';

  @override
  String get departure => 'Départ';

  @override
  String get arrival => 'Arrivée';

  @override
  String get notes => 'Notes';

  @override
  String get save => 'ENREGISTRER';

  @override
  String get myVehicles => 'Mes Véhicules';

  @override
  String get addVehicle => 'Ajouter un véhicule';

  @override
  String get registration => 'Immatriculation';

  @override
  String get brand => 'Marque';

  @override
  String get model => 'Modèle';

  @override
  String get height => 'Hauteur';

  @override
  String get length => 'Longueur';

  @override
  String get width => 'Largeur';

  @override
  String get unladenWeight => 'Poids à vide';

  @override
  String get ptac => 'PTAC';

  @override
  String get fuelType => 'Type de carburant';

  @override
  String get mileage => 'Kilométrage';

  @override
  String get diesel => 'Diesel';

  @override
  String get electric => 'Électrique';

  @override
  String get gas => 'Gaz';

  @override
  String get essence => 'Essence';

  @override
  String get other => 'Autre';

  @override
  String get dimensions => 'Dimensions';

  @override
  String get weight => 'Poids';

  @override
  String get myFleet => 'Ma Flotte d\'Autocars';

  @override
  String get energy => 'Énergie';

  @override
  String get editVehicle => 'Modifier le véhicule';

  @override
  String get registrationRequired => 'Immatriculation *';

  @override
  String get parkNumber => 'Numéro de Parc';

  @override
  String get initialMileage => 'Kilométrage initial';

  @override
  String get newMileage => 'Nouveau kilométrage (km)';

  @override
  String get vehicleModified => 'Véhicule modifié';

  @override
  String get vehicleSaved => 'Véhicule enregistré';

  @override
  String deleteConfirmVehicle(Object registration) {
    return 'Voulez-vous vraiment supprimer le véhicule $registration ?';
  }

  @override
  String get contactCenter => 'Centre d\'Aide & Contacts';

  @override
  String get techSupport => 'Assistance Technique';

  @override
  String get salesContact => 'Contact Commercial';

  @override
  String get whatsappSupport => 'Support WhatsApp';

  @override
  String get faqDoc => 'FAQ & Documentation';

  @override
  String get sendEmail => 'Envoyer un email';

  @override
  String get call => 'Appeler';

  @override
  String get contactMessage =>
      'Notre équipe est à votre disposition pour toute question technique ou commerciale.';

  @override
  String get usefulContacts => 'Contacts Utiles';

  @override
  String get myDocuments => 'Mes Documents';

  @override
  String get addDocument => 'Ajouter un document';

  @override
  String get documentType => 'Type de document';

  @override
  String get driverLicense => 'Permis de conduire';

  @override
  String get fimoFco => 'FIMO/FCO';

  @override
  String get tachographCard => 'Carte Chronotachygraphe';

  @override
  String get vehicleRegistration => 'Carte Grise';

  @override
  String get insuranceCert => 'Attestation d\'Assurance';

  @override
  String get takePhoto => 'Prendre une photo';

  @override
  String get chooseFile => 'Choisir un fichier';

  @override
  String get expiryDate => 'Date d\'expiration';

  @override
  String get expired => 'EXPIRÉ';

  @override
  String expiresIn(Object days) {
    return 'Expire dans $days jours';
  }

  @override
  String get fileAdded => 'Fichier ajouté';

  @override
  String get fileDeleted => 'Document supprimé';

  @override
  String get replace => 'Remplacer';

  @override
  String get add => 'Ajouter';

  @override
  String get validity => 'Validité';

  @override
  String get noDocumentLoaded => 'Aucun document chargé';

  @override
  String get chooseFromGallery => 'Choisir dans la galerie';

  @override
  String expiresOn(Object date) {
    return 'Expire le : $date';
  }

  @override
  String get noExpiryDate => 'Date de validité non saisie';

  @override
  String get chooseSubscription => 'Choisir mon abonnement';

  @override
  String get currentSubscription => 'ABONNEMENT ACTUEL';

  @override
  String get stayHere => 'RESTER ICI';

  @override
  String get contactUs => 'NOUS CONTACTER';

  @override
  String get subscribeAction => 'S\'ABONNER';

  @override
  String get finalizeSubscription => 'Finaliser l\'abonnement';

  @override
  String get useStripe => 'Utiliser Stripe';

  @override
  String get dummyPayment => 'Paiement par Carte Fictive (Mode Test)';

  @override
  String get cardNumber => 'Numéro de carte';

  @override
  String get cvc => 'CVC';

  @override
  String get confirmDummyPayment => 'CONFIRMER LE PAIEMENT FICTIF';

  @override
  String congratsSubscription(Object tier) {
    return 'Félicitations ! Vous êtes maintenant $tier';
  }

  @override
  String get paymentFailed => 'Le paiement a échoué ou a été annulé.';

  @override
  String get fleetAdminConsole => 'Console d\'Administration Entreprise';

  @override
  String get drivers => 'Conducteurs';

  @override
  String get fleetPlanning => 'Planning Flotte';

  @override
  String get addDriver => 'Ajouter un conducteur';

  @override
  String get driverCreated => 'Compte créé avec succès';

  @override
  String get superAdminTitle => 'Haute Administration';

  @override
  String get users => 'Utilisateurs';

  @override
  String get diamondRequests => 'Demandes Diamant';

  @override
  String get sqlGuide => 'Guide SQL Client';

  @override
  String deleteConfirmUser(Object name) {
    return 'Voulez-vous vraiment supprimer $name ?';
  }

  @override
  String get changeLanguage => 'Changer de langue';

  @override
  String get mapLayers => 'Calques de carte';

  @override
  String get standardView => 'Vue Plan';

  @override
  String get satelliteView => 'Vue Satellite';

  @override
  String get terrainView => 'Vue Relief';

  @override
  String get deleteTrip => 'Supprimer le trajet';

  @override
  String get importKml => 'Importer un KML';
}
