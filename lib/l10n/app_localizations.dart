import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_km.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('ja'),
    Locale('km'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In fr, this message translates to:
  /// **'MMC Go Drivers'**
  String get appTitle;

  /// No description provided for @selectLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez votre langue'**
  String get selectLanguage;

  /// No description provided for @continueAction.
  ///
  /// In fr, this message translates to:
  /// **'CONTINUER'**
  String get continueAction;

  /// No description provided for @welcome.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue'**
  String get welcome;

  /// No description provided for @dashboard.
  ///
  /// In fr, this message translates to:
  /// **'Tableau de bord'**
  String get dashboard;

  /// No description provided for @navigation.
  ///
  /// In fr, this message translates to:
  /// **'Navigation'**
  String get navigation;

  /// No description provided for @planning.
  ///
  /// In fr, this message translates to:
  /// **'Planning'**
  String get planning;

  /// No description provided for @vehicle.
  ///
  /// In fr, this message translates to:
  /// **'Véhicule'**
  String get vehicle;

  /// No description provided for @documents.
  ///
  /// In fr, this message translates to:
  /// **'Documents'**
  String get documents;

  /// No description provided for @contact.
  ///
  /// In fr, this message translates to:
  /// **'Contact'**
  String get contact;

  /// No description provided for @administration.
  ///
  /// In fr, this message translates to:
  /// **'Administration'**
  String get administration;

  /// No description provided for @superAdmin.
  ///
  /// In fr, this message translates to:
  /// **'Super Admin'**
  String get superAdmin;

  /// No description provided for @logout.
  ///
  /// In fr, this message translates to:
  /// **'Déconnexion'**
  String get logout;

  /// No description provided for @login.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get login;

  /// No description provided for @register.
  ///
  /// In fr, this message translates to:
  /// **'S\'inscrire'**
  String get register;

  /// No description provided for @email.
  ///
  /// In fr, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get password;

  /// No description provided for @hello.
  ///
  /// In fr, this message translates to:
  /// **'Bonjour'**
  String get hello;

  /// No description provided for @tier.
  ///
  /// In fr, this message translates to:
  /// **'Abonnement'**
  String get tier;

  /// No description provided for @tools.
  ///
  /// In fr, this message translates to:
  /// **'Outils'**
  String get tools;

  /// No description provided for @loading.
  ///
  /// In fr, this message translates to:
  /// **'Chargement...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In fr, this message translates to:
  /// **'Erreur'**
  String get error;

  /// No description provided for @confirm.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer'**
  String get confirm;

  /// No description provided for @cancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get cancel;

  /// No description provided for @navAndRecording.
  ///
  /// In fr, this message translates to:
  /// **'Navigation & Enregistrement'**
  String get navAndRecording;

  /// No description provided for @helloUser.
  ///
  /// In fr, this message translates to:
  /// **'Bonjour, {username}'**
  String helloUser(Object username);

  /// No description provided for @mmcAccount.
  ///
  /// In fr, this message translates to:
  /// **'Compte MMC Go'**
  String get mmcAccount;

  /// No description provided for @manageSubscription.
  ///
  /// In fr, this message translates to:
  /// **'Gérer mon abonnement'**
  String get manageSubscription;

  /// No description provided for @aboutMMC.
  ///
  /// In fr, this message translates to:
  /// **'À propos de MMC Go'**
  String get aboutMMC;

  /// No description provided for @calculatingRoute.
  ///
  /// In fr, this message translates to:
  /// **'Calcul de l\'itinéraire PL optimisé...'**
  String get calculatingRoute;

  /// No description provided for @vehicleInfo.
  ///
  /// In fr, this message translates to:
  /// **'Véhicule: {registration}'**
  String vehicleInfo(Object registration);

  /// No description provided for @hgvOptimized.
  ///
  /// In fr, this message translates to:
  /// **'⚠️ Itinéraire optimisé Poids-Lourds'**
  String get hgvOptimized;

  /// No description provided for @startPoint.
  ///
  /// In fr, this message translates to:
  /// **'Point de départ'**
  String get startPoint;

  /// No description provided for @destination.
  ///
  /// In fr, this message translates to:
  /// **'Destination'**
  String get destination;

  /// No description provided for @waypoint.
  ///
  /// In fr, this message translates to:
  /// **'Étape'**
  String get waypoint;

  /// No description provided for @addStep.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une étape'**
  String get addStep;

  /// No description provided for @chooseRoute.
  ///
  /// In fr, this message translates to:
  /// **'Choix de l\'itinéraire'**
  String get chooseRoute;

  /// No description provided for @startNav.
  ///
  /// In fr, this message translates to:
  /// **'DÉMARRER'**
  String get startNav;

  /// No description provided for @calculateRoute.
  ///
  /// In fr, this message translates to:
  /// **'CALCULER L\'ITINÉRAIRE'**
  String get calculateRoute;

  /// No description provided for @saveTrip.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer le trajet'**
  String get saveTrip;

  /// No description provided for @tripName.
  ///
  /// In fr, this message translates to:
  /// **'Nom du trajet'**
  String get tripName;

  /// No description provided for @tripHistory.
  ///
  /// In fr, this message translates to:
  /// **'Historique des trajets'**
  String get tripHistory;

  /// No description provided for @stats.
  ///
  /// In fr, this message translates to:
  /// **'Statistiques'**
  String get stats;

  /// No description provided for @speed.
  ///
  /// In fr, this message translates to:
  /// **'VITESSE'**
  String get speed;

  /// No description provided for @distance.
  ///
  /// In fr, this message translates to:
  /// **'DISTANCE'**
  String get distance;

  /// No description provided for @altitude.
  ///
  /// In fr, this message translates to:
  /// **'ALTITUDE'**
  String get altitude;

  /// No description provided for @universalTool.
  ///
  /// In fr, this message translates to:
  /// **'L\'outil universel des transporteurs'**
  String get universalTool;

  /// No description provided for @dbConfig.
  ///
  /// In fr, this message translates to:
  /// **'Configuration DB'**
  String get dbConfig;

  /// No description provided for @username.
  ///
  /// In fr, this message translates to:
  /// **'Identifiant'**
  String get username;

  /// No description provided for @noAccount.
  ///
  /// In fr, this message translates to:
  /// **'Pas encore de compte ?'**
  String get noAccount;

  /// No description provided for @loginAction.
  ///
  /// In fr, this message translates to:
  /// **'SE CONNECTER'**
  String get loginAction;

  /// No description provided for @registerAction.
  ///
  /// In fr, this message translates to:
  /// **'S\'INSCRIRE'**
  String get registerAction;

  /// No description provided for @fullName.
  ///
  /// In fr, this message translates to:
  /// **'Nom complet'**
  String get fullName;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In fr, this message translates to:
  /// **'Déjà un compte ?'**
  String get alreadyHaveAccount;

  /// No description provided for @passwordMinimum.
  ///
  /// In fr, this message translates to:
  /// **'Le mot de passe doit faire au moins 6 caractères'**
  String get passwordMinimum;

  /// No description provided for @emailRequired.
  ///
  /// In fr, this message translates to:
  /// **'L\'email et le mot de passe sont requis'**
  String get emailRequired;

  /// No description provided for @createAccount.
  ///
  /// In fr, this message translates to:
  /// **'Créer un compte'**
  String get createAccount;

  /// No description provided for @joinMMC.
  ///
  /// In fr, this message translates to:
  /// **'Rejoignez MMC Go Drivers'**
  String get joinMMC;

  /// No description provided for @confirmPassword.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer le mot de passe'**
  String get confirmPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In fr, this message translates to:
  /// **'Les mots de passe ne correspondent pas'**
  String get passwordsDoNotMatch;

  /// No description provided for @registerAndChoosePlan.
  ///
  /// In fr, this message translates to:
  /// **'S\'INSCRIRE ET CHOISIR UN FORFAIT'**
  String get registerAndChoosePlan;

  /// No description provided for @myPlanning.
  ///
  /// In fr, this message translates to:
  /// **'Mon Planning'**
  String get myPlanning;

  /// No description provided for @exportPdf.
  ///
  /// In fr, this message translates to:
  /// **'Exporter en PDF'**
  String get exportPdf;

  /// No description provided for @today.
  ///
  /// In fr, this message translates to:
  /// **'Aujourd\'hui'**
  String get today;

  /// No description provided for @missionPasted.
  ///
  /// In fr, this message translates to:
  /// **'Mission collée avec succès'**
  String get missionPasted;

  /// No description provided for @pasteMission.
  ///
  /// In fr, this message translates to:
  /// **'Coller la mission copiée'**
  String get pasteMission;

  /// No description provided for @rseAlerts.
  ///
  /// In fr, this message translates to:
  /// **'Alertes RSE'**
  String get rseAlerts;

  /// No description provided for @noTrips.
  ///
  /// In fr, this message translates to:
  /// **'Aucun trajet prévu pour cette période'**
  String get noTrips;

  /// No description provided for @addPersonalMission.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une mission personnelle'**
  String get addPersonalMission;

  /// No description provided for @day.
  ///
  /// In fr, this message translates to:
  /// **'Jour'**
  String get day;

  /// No description provided for @week.
  ///
  /// In fr, this message translates to:
  /// **'Semaine'**
  String get week;

  /// No description provided for @month.
  ///
  /// In fr, this message translates to:
  /// **'Mois'**
  String get month;

  /// No description provided for @fromTo.
  ///
  /// In fr, this message translates to:
  /// **'Du {start} au {end}'**
  String fromTo(Object end, Object start);

  /// No description provided for @edit.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get delete;

  /// No description provided for @bus.
  ///
  /// In fr, this message translates to:
  /// **'Bus'**
  String get bus;

  /// No description provided for @departure.
  ///
  /// In fr, this message translates to:
  /// **'Départ'**
  String get departure;

  /// No description provided for @arrival.
  ///
  /// In fr, this message translates to:
  /// **'Arrivée'**
  String get arrival;

  /// No description provided for @notes.
  ///
  /// In fr, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @save.
  ///
  /// In fr, this message translates to:
  /// **'ENREGISTRER'**
  String get save;

  /// No description provided for @myVehicles.
  ///
  /// In fr, this message translates to:
  /// **'Mes Véhicules'**
  String get myVehicles;

  /// No description provided for @addVehicle.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un véhicule'**
  String get addVehicle;

  /// No description provided for @registration.
  ///
  /// In fr, this message translates to:
  /// **'Immatriculation'**
  String get registration;

  /// No description provided for @brand.
  ///
  /// In fr, this message translates to:
  /// **'Marque'**
  String get brand;

  /// No description provided for @model.
  ///
  /// In fr, this message translates to:
  /// **'Modèle'**
  String get model;

  /// No description provided for @height.
  ///
  /// In fr, this message translates to:
  /// **'Hauteur'**
  String get height;

  /// No description provided for @length.
  ///
  /// In fr, this message translates to:
  /// **'Longueur'**
  String get length;

  /// No description provided for @width.
  ///
  /// In fr, this message translates to:
  /// **'Largeur'**
  String get width;

  /// No description provided for @unladenWeight.
  ///
  /// In fr, this message translates to:
  /// **'Poids à vide'**
  String get unladenWeight;

  /// No description provided for @ptac.
  ///
  /// In fr, this message translates to:
  /// **'PTAC'**
  String get ptac;

  /// No description provided for @fuelType.
  ///
  /// In fr, this message translates to:
  /// **'Type de carburant'**
  String get fuelType;

  /// No description provided for @mileage.
  ///
  /// In fr, this message translates to:
  /// **'Kilométrage'**
  String get mileage;

  /// No description provided for @diesel.
  ///
  /// In fr, this message translates to:
  /// **'Diesel'**
  String get diesel;

  /// No description provided for @electric.
  ///
  /// In fr, this message translates to:
  /// **'Électrique'**
  String get electric;

  /// No description provided for @gas.
  ///
  /// In fr, this message translates to:
  /// **'Gaz'**
  String get gas;

  /// No description provided for @essence.
  ///
  /// In fr, this message translates to:
  /// **'Essence'**
  String get essence;

  /// No description provided for @other.
  ///
  /// In fr, this message translates to:
  /// **'Autre'**
  String get other;

  /// No description provided for @dimensions.
  ///
  /// In fr, this message translates to:
  /// **'Dimensions'**
  String get dimensions;

  /// No description provided for @weight.
  ///
  /// In fr, this message translates to:
  /// **'Poids'**
  String get weight;

  /// No description provided for @myFleet.
  ///
  /// In fr, this message translates to:
  /// **'Ma Flotte d\'Autocars'**
  String get myFleet;

  /// No description provided for @energy.
  ///
  /// In fr, this message translates to:
  /// **'Énergie'**
  String get energy;

  /// No description provided for @editVehicle.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le véhicule'**
  String get editVehicle;

  /// No description provided for @registrationRequired.
  ///
  /// In fr, this message translates to:
  /// **'Immatriculation *'**
  String get registrationRequired;

  /// No description provided for @parkNumber.
  ///
  /// In fr, this message translates to:
  /// **'Numéro de Parc'**
  String get parkNumber;

  /// No description provided for @initialMileage.
  ///
  /// In fr, this message translates to:
  /// **'Kilométrage initial'**
  String get initialMileage;

  /// No description provided for @newMileage.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau kilométrage (km)'**
  String get newMileage;

  /// No description provided for @vehicleModified.
  ///
  /// In fr, this message translates to:
  /// **'Véhicule modifié'**
  String get vehicleModified;

  /// No description provided for @vehicleSaved.
  ///
  /// In fr, this message translates to:
  /// **'Véhicule enregistré'**
  String get vehicleSaved;

  /// No description provided for @deleteConfirmVehicle.
  ///
  /// In fr, this message translates to:
  /// **'Voulez-vous vraiment supprimer le véhicule {registration} ?'**
  String deleteConfirmVehicle(Object registration);

  /// No description provided for @contactCenter.
  ///
  /// In fr, this message translates to:
  /// **'Centre d\'Aide & Contacts'**
  String get contactCenter;

  /// No description provided for @techSupport.
  ///
  /// In fr, this message translates to:
  /// **'Assistance Technique'**
  String get techSupport;

  /// No description provided for @salesContact.
  ///
  /// In fr, this message translates to:
  /// **'Contact Commercial'**
  String get salesContact;

  /// No description provided for @whatsappSupport.
  ///
  /// In fr, this message translates to:
  /// **'Support WhatsApp'**
  String get whatsappSupport;

  /// No description provided for @faqDoc.
  ///
  /// In fr, this message translates to:
  /// **'FAQ & Documentation'**
  String get faqDoc;

  /// No description provided for @sendEmail.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer un email'**
  String get sendEmail;

  /// No description provided for @call.
  ///
  /// In fr, this message translates to:
  /// **'Appeler'**
  String get call;

  /// No description provided for @contactMessage.
  ///
  /// In fr, this message translates to:
  /// **'Notre équipe est à votre disposition pour toute question technique ou commerciale.'**
  String get contactMessage;

  /// No description provided for @usefulContacts.
  ///
  /// In fr, this message translates to:
  /// **'Contacts Utiles'**
  String get usefulContacts;

  /// No description provided for @myDocuments.
  ///
  /// In fr, this message translates to:
  /// **'Mes Documents'**
  String get myDocuments;

  /// No description provided for @addDocument.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un document'**
  String get addDocument;

  /// No description provided for @documentType.
  ///
  /// In fr, this message translates to:
  /// **'Type de document'**
  String get documentType;

  /// No description provided for @driverLicense.
  ///
  /// In fr, this message translates to:
  /// **'Permis de conduire'**
  String get driverLicense;

  /// No description provided for @fimoFco.
  ///
  /// In fr, this message translates to:
  /// **'FIMO/FCO'**
  String get fimoFco;

  /// No description provided for @tachographCard.
  ///
  /// In fr, this message translates to:
  /// **'Carte Chronotachygraphe'**
  String get tachographCard;

  /// No description provided for @vehicleRegistration.
  ///
  /// In fr, this message translates to:
  /// **'Carte Grise'**
  String get vehicleRegistration;

  /// No description provided for @insuranceCert.
  ///
  /// In fr, this message translates to:
  /// **'Attestation d\'Assurance'**
  String get insuranceCert;

  /// No description provided for @takePhoto.
  ///
  /// In fr, this message translates to:
  /// **'Prendre une photo'**
  String get takePhoto;

  /// No description provided for @chooseFile.
  ///
  /// In fr, this message translates to:
  /// **'Choisir un fichier'**
  String get chooseFile;

  /// No description provided for @expiryDate.
  ///
  /// In fr, this message translates to:
  /// **'Date d\'expiration'**
  String get expiryDate;

  /// No description provided for @expired.
  ///
  /// In fr, this message translates to:
  /// **'EXPIRÉ'**
  String get expired;

  /// No description provided for @expiresIn.
  ///
  /// In fr, this message translates to:
  /// **'Expire dans {days} jours'**
  String expiresIn(Object days);

  /// No description provided for @fileAdded.
  ///
  /// In fr, this message translates to:
  /// **'Fichier ajouté'**
  String get fileAdded;

  /// No description provided for @fileDeleted.
  ///
  /// In fr, this message translates to:
  /// **'Document supprimé'**
  String get fileDeleted;

  /// No description provided for @replace.
  ///
  /// In fr, this message translates to:
  /// **'Remplacer'**
  String get replace;

  /// No description provided for @add.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter'**
  String get add;

  /// No description provided for @validity.
  ///
  /// In fr, this message translates to:
  /// **'Validité'**
  String get validity;

  /// No description provided for @noDocumentLoaded.
  ///
  /// In fr, this message translates to:
  /// **'Aucun document chargé'**
  String get noDocumentLoaded;

  /// No description provided for @chooseFromGallery.
  ///
  /// In fr, this message translates to:
  /// **'Choisir dans la galerie'**
  String get chooseFromGallery;

  /// No description provided for @expiresOn.
  ///
  /// In fr, this message translates to:
  /// **'Expire le : {date}'**
  String expiresOn(Object date);

  /// No description provided for @noExpiryDate.
  ///
  /// In fr, this message translates to:
  /// **'Date de validité non saisie'**
  String get noExpiryDate;

  /// No description provided for @chooseSubscription.
  ///
  /// In fr, this message translates to:
  /// **'Choisir mon abonnement'**
  String get chooseSubscription;

  /// No description provided for @currentSubscription.
  ///
  /// In fr, this message translates to:
  /// **'ABONNEMENT ACTUEL'**
  String get currentSubscription;

  /// No description provided for @stayHere.
  ///
  /// In fr, this message translates to:
  /// **'RESTER ICI'**
  String get stayHere;

  /// No description provided for @contactUs.
  ///
  /// In fr, this message translates to:
  /// **'NOUS CONTACTER'**
  String get contactUs;

  /// No description provided for @subscribeAction.
  ///
  /// In fr, this message translates to:
  /// **'S\'ABONNER'**
  String get subscribeAction;

  /// No description provided for @finalizeSubscription.
  ///
  /// In fr, this message translates to:
  /// **'Finaliser l\'abonnement'**
  String get finalizeSubscription;

  /// No description provided for @useStripe.
  ///
  /// In fr, this message translates to:
  /// **'Utiliser Stripe'**
  String get useStripe;

  /// No description provided for @dummyPayment.
  ///
  /// In fr, this message translates to:
  /// **'Paiement par Carte Fictive (Mode Test)'**
  String get dummyPayment;

  /// No description provided for @cardNumber.
  ///
  /// In fr, this message translates to:
  /// **'Numéro de carte'**
  String get cardNumber;

  /// No description provided for @cvc.
  ///
  /// In fr, this message translates to:
  /// **'CVC'**
  String get cvc;

  /// No description provided for @confirmDummyPayment.
  ///
  /// In fr, this message translates to:
  /// **'CONFIRMER LE PAIEMENT FICTIF'**
  String get confirmDummyPayment;

  /// No description provided for @congratsSubscription.
  ///
  /// In fr, this message translates to:
  /// **'Félicitations ! Vous êtes maintenant {tier}'**
  String congratsSubscription(Object tier);

  /// No description provided for @paymentFailed.
  ///
  /// In fr, this message translates to:
  /// **'Le paiement a échoué ou a été annulé.'**
  String get paymentFailed;

  /// No description provided for @fleetAdminConsole.
  ///
  /// In fr, this message translates to:
  /// **'Console d\'Administration Entreprise'**
  String get fleetAdminConsole;

  /// No description provided for @drivers.
  ///
  /// In fr, this message translates to:
  /// **'Conducteurs'**
  String get drivers;

  /// No description provided for @fleetPlanning.
  ///
  /// In fr, this message translates to:
  /// **'Planning Flotte'**
  String get fleetPlanning;

  /// No description provided for @addDriver.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un conducteur'**
  String get addDriver;

  /// No description provided for @driverCreated.
  ///
  /// In fr, this message translates to:
  /// **'Compte créé avec succès'**
  String get driverCreated;

  /// No description provided for @superAdminTitle.
  ///
  /// In fr, this message translates to:
  /// **'Haute Administration'**
  String get superAdminTitle;

  /// No description provided for @users.
  ///
  /// In fr, this message translates to:
  /// **'Utilisateurs'**
  String get users;

  /// No description provided for @diamondRequests.
  ///
  /// In fr, this message translates to:
  /// **'Demandes Diamant'**
  String get diamondRequests;

  /// No description provided for @sqlGuide.
  ///
  /// In fr, this message translates to:
  /// **'Guide SQL Client'**
  String get sqlGuide;

  /// No description provided for @deleteConfirmUser.
  ///
  /// In fr, this message translates to:
  /// **'Voulez-vous vraiment supprimer {name} ?'**
  String deleteConfirmUser(Object name);

  /// No description provided for @changeLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Changer de langue'**
  String get changeLanguage;

  /// No description provided for @mapLayers.
  ///
  /// In fr, this message translates to:
  /// **'Calques de carte'**
  String get mapLayers;

  /// No description provided for @standardView.
  ///
  /// In fr, this message translates to:
  /// **'Vue Plan'**
  String get standardView;

  /// No description provided for @satelliteView.
  ///
  /// In fr, this message translates to:
  /// **'Vue Satellite'**
  String get satelliteView;

  /// No description provided for @terrainView.
  ///
  /// In fr, this message translates to:
  /// **'Vue Relief'**
  String get terrainView;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'de',
    'en',
    'es',
    'fr',
    'ja',
    'km',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'ja':
      return AppLocalizationsJa();
    case 'km':
      return AppLocalizationsKm();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
