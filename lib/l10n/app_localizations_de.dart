// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'MMC Go Drivers';

  @override
  String get selectLanguage => 'Wählen Sie Ihre Sprache';

  @override
  String get continueAction => 'WEITER';

  @override
  String get welcome => 'Willkommen';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get navigation => 'Navigation';

  @override
  String get planning => 'Planung';

  @override
  String get vehicle => 'Fahrzeug';

  @override
  String get documents => 'Dokumente';

  @override
  String get contact => 'Kontakt';

  @override
  String get administration => 'Administration';

  @override
  String get superAdmin => 'Super-Admin';

  @override
  String get logout => 'Abmelden';

  @override
  String get login => 'Anmelden';

  @override
  String get register => 'Registrieren';

  @override
  String get email => 'E-Mail';

  @override
  String get password => 'Passwort';

  @override
  String get hello => 'Hallo';

  @override
  String get tier => 'Abonnement';

  @override
  String get tools => 'Werkzeuge';

  @override
  String get loading => 'Laden...';

  @override
  String get error => 'Fehler';

  @override
  String get confirm => 'Bestätigen';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get navAndRecording => 'Navigation & Aufnahme';

  @override
  String helloUser(Object username) {
    return 'Hallo, $username';
  }

  @override
  String get mmcAccount => 'MMC Go Konto';

  @override
  String get manageSubscription => 'Mein Abonnement verwalten';

  @override
  String get aboutMMC => 'Über MMC Go';

  @override
  String get calculatingRoute => 'Optimierte LKW-Route wird berechnet...';

  @override
  String vehicleInfo(Object registration) {
    return 'Fahrzeug: $registration';
  }

  @override
  String get hgvOptimized => '⚠️ LKW-optimierte Route';

  @override
  String get startPoint => 'Startpunkt';

  @override
  String get destination => 'Ziel';

  @override
  String get waypoint => 'Wegpunkt';

  @override
  String get addStep => 'Schritt hinzufügen';

  @override
  String get chooseRoute => 'Route wählen';

  @override
  String get startNav => 'STARTEN';

  @override
  String get calculateRoute => 'ROUTE BERECHNEN';

  @override
  String get saveTrip => 'Fahrt speichern';

  @override
  String get tripName => 'Fahrtname';

  @override
  String get tripHistory => 'Fahrtverlauf';

  @override
  String get stats => 'Statistiken';

  @override
  String get speed => 'GESCHWINDIGKEIT';

  @override
  String get distance => 'DISTANZ';

  @override
  String get altitude => 'HÖHE';

  @override
  String get universalTool => 'Das universelle Werkzeug für Speditionen';

  @override
  String get dbConfig => 'DB-Konfiguration';

  @override
  String get username => 'Benutzername';

  @override
  String get noAccount => 'Noch kein Konto?';

  @override
  String get loginAction => 'ANMELDEN';

  @override
  String get registerAction => 'REGISTRIEREN';

  @override
  String get fullName => 'Vollständiger Name';

  @override
  String get alreadyHaveAccount => 'Haben Sie bereits ein Konto?';

  @override
  String get passwordMinimum =>
      'Das Passwort muss mindestens 6 Zeichen lang sein';

  @override
  String get emailRequired => 'E-Mail und Passwort sind erforderlich';

  @override
  String get createAccount => 'Konto erstellen';

  @override
  String get joinMMC => 'Treten Sie MMC Go Drivers bei';

  @override
  String get confirmPassword => 'Passwort bestätigen';

  @override
  String get passwordsDoNotMatch => 'Passwörter stimmen nicht überein';

  @override
  String get registerAndChoosePlan => 'REGISTRIEREN UND PLAN WÄHLEN';

  @override
  String get myPlanning => 'Mein Plan';

  @override
  String get exportPdf => 'Als PDF exportieren';

  @override
  String get today => 'Heute';

  @override
  String get missionPasted => 'Mission erfolgreich eingefügt';

  @override
  String get pasteMission => 'Kopierte Mission einfügen';

  @override
  String get rseAlerts => 'CSR-Warnungen';

  @override
  String get noTrips => 'Keine Fahrten für diesen Zeitraum geplant';

  @override
  String get addPersonalMission => 'Persönliche Mission hinzufügen';

  @override
  String get day => 'Tag';

  @override
  String get week => 'Woche';

  @override
  String get month => 'Monat';

  @override
  String fromTo(Object end, Object start) {
    return 'Von $start bis $end';
  }

  @override
  String get edit => 'Bearbeiten';

  @override
  String get delete => 'Löschen';

  @override
  String get bus => 'Bus';

  @override
  String get departure => 'Abfahrt';

  @override
  String get arrival => 'Ankunft';

  @override
  String get notes => 'Notizen';

  @override
  String get save => 'SPEICHERN';

  @override
  String get myVehicles => 'Meine Fahrzeuge';

  @override
  String get addVehicle => 'Fahrzeug hinzufügen';

  @override
  String get registration => 'Kennzeichen';

  @override
  String get brand => 'Marke';

  @override
  String get model => 'Modell';

  @override
  String get height => 'Höhe';

  @override
  String get length => 'Länge';

  @override
  String get width => 'Breite';

  @override
  String get unladenWeight => 'Leergewicht';

  @override
  String get ptac => 'zGG';

  @override
  String get fuelType => 'Kraftstoffart';

  @override
  String get mileage => 'Kilometerstand';

  @override
  String get diesel => 'Diesel';

  @override
  String get electric => 'Elektrisch';

  @override
  String get gas => 'Gas';

  @override
  String get essence => 'Benzin';

  @override
  String get other => 'Andere';

  @override
  String get dimensions => 'Abmessungen';

  @override
  String get weight => 'Gewicht';

  @override
  String get myFleet => 'Meine Busflotte';

  @override
  String get energy => 'Energie';

  @override
  String get editVehicle => 'Fahrzeug bearbeiten';

  @override
  String get registrationRequired => 'Kennzeichen *';

  @override
  String get parkNumber => 'Wagennummer';

  @override
  String get initialMileage => 'Anfangskilometerstand';

  @override
  String get newMileage => 'Neuer Kilometerstand (km)';

  @override
  String get vehicleModified => 'Fahrzeug geändert';

  @override
  String get vehicleSaved => 'Fahrzeug gespeichert';

  @override
  String deleteConfirmVehicle(Object registration) {
    return 'Möchten Sie das Fahrzeug $registration wirklich löschen?';
  }

  @override
  String get contactCenter => 'Hilfecenter & Kontakte';

  @override
  String get techSupport => 'Technischer Support';

  @override
  String get salesContact => 'Vertriebskontakt';

  @override
  String get whatsappSupport => 'WhatsApp-Support';

  @override
  String get faqDoc => 'FAQ & Dokumentation';

  @override
  String get sendEmail => 'E-Mail senden';

  @override
  String get call => 'Anrufen';

  @override
  String get contactMessage =>
      'Unser Team steht Ihnen für technische oder kommerzielle Fragen zur Verfügung.';

  @override
  String get usefulContacts => 'Nützliche Kontakte';

  @override
  String get myDocuments => 'Meine Dokumente';

  @override
  String get addDocument => 'Dokument hinzufügen';

  @override
  String get documentType => 'Dokumenttyp';

  @override
  String get driverLicense => 'Führerschein';

  @override
  String get fimoFco => 'FIMO/FCO';

  @override
  String get tachographCard => 'Fahrerkarte';

  @override
  String get vehicleRegistration => 'Fahrzeugschein';

  @override
  String get insuranceCert => 'Versicherungsbescheinigung';

  @override
  String get takePhoto => 'Foto aufnehmen';

  @override
  String get chooseFile => 'Datei auswählen';

  @override
  String get expiryDate => 'Ablaufdatum';

  @override
  String get expired => 'ABGELAUFEN';

  @override
  String expiresIn(Object days) {
    return 'Läuft in $days Tagen ab';
  }

  @override
  String get fileAdded => 'Datei hinzugefügt';

  @override
  String get fileDeleted => 'Dokument gelöscht';

  @override
  String get replace => 'Ersetzen';

  @override
  String get add => 'Hinzufügen';

  @override
  String get validity => 'Gültigkeit';

  @override
  String get noDocumentLoaded => 'Kein Dokument geladen';

  @override
  String get chooseFromGallery => 'Aus der Galerie auswählen';

  @override
  String expiresOn(Object date) {
    return 'Läuft am $date ab';
  }

  @override
  String get noExpiryDate => 'Kein Ablaufdatum eingegeben';

  @override
  String get chooseSubscription => 'Mein Abonnement wählen';

  @override
  String get currentSubscription => 'AKTUELLES ABONNEMENT';

  @override
  String get stayHere => 'HIER BLEIBEN';

  @override
  String get contactUs => 'KONTAKTIEREN SIE UNS';

  @override
  String get subscribeAction => 'ABONNIEREN';

  @override
  String get finalizeSubscription => 'Abonnement abschließen';

  @override
  String get useStripe => 'Stripe verwenden';

  @override
  String get dummyPayment => 'Dummy-Kartenzahlung (Testmodus)';

  @override
  String get cardNumber => 'Kartennummer';

  @override
  String get cvc => 'CVC';

  @override
  String get confirmDummyPayment => 'DUMMY-ZAHLUNG BESTÄTIGEN';

  @override
  String congratsSubscription(Object tier) {
    return 'Herzlichen Glückwunsch! Sie sind jetzt $tier';
  }

  @override
  String get paymentFailed => 'Zahlung fehlgeschlagen oder abgebrochen.';

  @override
  String get fleetAdminConsole => 'Flotten-Admin-Konsole';

  @override
  String get drivers => 'Fahrer';

  @override
  String get fleetPlanning => 'Flottenplanung';

  @override
  String get addDriver => 'Fahrer hinzufügen';

  @override
  String get driverCreated => 'Konto erfolgreich erstellt';

  @override
  String get superAdminTitle => 'Super-Administration';

  @override
  String get users => 'Benutzer';

  @override
  String get diamondRequests => 'Diamant-Anfragen';

  @override
  String get sqlGuide => 'Kunden-SQL-Leitfaden';

  @override
  String deleteConfirmUser(Object name) {
    return 'Sind Sie sicher, dass Sie $name löschen möchten?';
  }

  @override
  String get changeLanguage => 'Changer de langue';

  @override
  String get mapLayers => 'Kartenansichten';

  @override
  String get standardView => 'Standardansicht';

  @override
  String get satelliteView => 'Satellitenansicht';

  @override
  String get terrainView => 'Reliefansicht';
}
