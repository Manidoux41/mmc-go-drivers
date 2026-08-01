// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'MMC Go Drivers';

  @override
  String get selectLanguage => 'Choose your language';

  @override
  String get continueAction => 'CONTINUE';

  @override
  String get welcome => 'Welcome';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get navigation => 'Navigation';

  @override
  String get planning => 'Planning';

  @override
  String get vehicle => 'Vehicle';

  @override
  String get documents => 'Documents';

  @override
  String get contact => 'Contact';

  @override
  String get administration => 'Administration';

  @override
  String get superAdmin => 'Super Admin';

  @override
  String get logout => 'Logout';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get hello => 'Hello';

  @override
  String get tier => 'Subscription';

  @override
  String get tools => 'Tools';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get confirm => 'Confirm';

  @override
  String get cancel => 'Cancel';

  @override
  String get navAndRecording => 'Navigation & Recording';

  @override
  String helloUser(Object username) {
    return 'Hello, $username';
  }

  @override
  String get mmcAccount => 'MMC Go Account';

  @override
  String get manageSubscription => 'Manage my subscription';

  @override
  String get aboutMMC => 'About MMC Go';

  @override
  String get calculatingRoute => 'Calculating optimized HGV route...';

  @override
  String vehicleInfo(Object registration) {
    return 'Vehicle: $registration';
  }

  @override
  String get hgvOptimized => '⚠️ HGV Optimized Route';

  @override
  String get startPoint => 'Start point';

  @override
  String get destination => 'Destination';

  @override
  String get waypoint => 'Waypoint';

  @override
  String get addStep => 'Add step';

  @override
  String get chooseRoute => 'Choose route';

  @override
  String get startNav => 'START';

  @override
  String get calculateRoute => 'CALCULATE ROUTE';

  @override
  String get saveTrip => 'Save trip';

  @override
  String get tripName => 'Trip name';

  @override
  String get tripHistory => 'Trip history';

  @override
  String get stats => 'Statistics';

  @override
  String get speed => 'SPEED';

  @override
  String get distance => 'DISTANCE';

  @override
  String get altitude => 'ALTITUDE';

  @override
  String get universalTool => 'The universal tool for carriers';

  @override
  String get dbConfig => 'DB Configuration';

  @override
  String get username => 'Username';

  @override
  String get noAccount => 'No account yet?';

  @override
  String get loginAction => 'LOGIN';

  @override
  String get registerAction => 'REGISTER';

  @override
  String get fullName => 'Full name';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get passwordMinimum => 'Password must be at least 6 characters';

  @override
  String get emailRequired => 'Email and password are required';

  @override
  String get createAccount => 'Create account';

  @override
  String get joinMMC => 'Join MMC Go Drivers';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get registerAndChoosePlan => 'REGISTER AND CHOOSE A PLAN';

  @override
  String get myPlanning => 'My Planning';

  @override
  String get exportPdf => 'Export to PDF';

  @override
  String get today => 'Today';

  @override
  String get missionPasted => 'Mission pasted successfully';

  @override
  String get pasteMission => 'Paste copied mission';

  @override
  String get rseAlerts => 'CSR Alerts';

  @override
  String get noTrips => 'No trips planned for this period';

  @override
  String get addPersonalMission => 'Add personal mission';

  @override
  String get day => 'Day';

  @override
  String get week => 'Week';

  @override
  String get month => 'Month';

  @override
  String fromTo(Object end, Object start) {
    return 'From $start to $end';
  }

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get bus => 'Bus';

  @override
  String get departure => 'Departure';

  @override
  String get arrival => 'Arrival';

  @override
  String get notes => 'Notes';

  @override
  String get save => 'SAVE';

  @override
  String get myVehicles => 'My Vehicles';

  @override
  String get addVehicle => 'Add vehicle';

  @override
  String get registration => 'Registration';

  @override
  String get brand => 'Brand';

  @override
  String get model => 'Model';

  @override
  String get height => 'Height';

  @override
  String get length => 'Length';

  @override
  String get width => 'Width';

  @override
  String get unladenWeight => 'Unladen weight';

  @override
  String get ptac => 'GVWR';

  @override
  String get fuelType => 'Fuel type';

  @override
  String get mileage => 'Mileage';

  @override
  String get diesel => 'Diesel';

  @override
  String get electric => 'Electric';

  @override
  String get gas => 'Gas';

  @override
  String get essence => 'Petrol';

  @override
  String get other => 'Other';

  @override
  String get dimensions => 'Dimensions';

  @override
  String get weight => 'Weight';

  @override
  String get myFleet => 'My Coach Fleet';

  @override
  String get energy => 'Energy';

  @override
  String get editVehicle => 'Edit Vehicle';

  @override
  String get registrationRequired => 'Registration *';

  @override
  String get parkNumber => 'Fleet Number';

  @override
  String get initialMileage => 'Initial Mileage';

  @override
  String get newMileage => 'New Mileage (km)';

  @override
  String get vehicleModified => 'Vehicle modified';

  @override
  String get vehicleSaved => 'Vehicle saved';

  @override
  String deleteConfirmVehicle(Object registration) {
    return 'Are you sure you want to delete the vehicle $registration?';
  }

  @override
  String get contactCenter => 'Help Center & Contacts';

  @override
  String get techSupport => 'Technical Support';

  @override
  String get salesContact => 'Sales Contact';

  @override
  String get whatsappSupport => 'WhatsApp Support';

  @override
  String get faqDoc => 'FAQ & Documentation';

  @override
  String get sendEmail => 'Send an email';

  @override
  String get call => 'Call';

  @override
  String get contactMessage =>
      'Our team is at your disposal for any technical or commercial questions.';

  @override
  String get usefulContacts => 'Useful Contacts';

  @override
  String get myDocuments => 'My Documents';

  @override
  String get addDocument => 'Add a document';

  @override
  String get documentType => 'Document type';

  @override
  String get driverLicense => 'Driver\'s license';

  @override
  String get fimoFco => 'FIMO/FCO';

  @override
  String get tachographCard => 'Tachograph card';

  @override
  String get vehicleRegistration => 'Registration document';

  @override
  String get insuranceCert => 'Insurance certificate';

  @override
  String get takePhoto => 'Take a photo';

  @override
  String get chooseFile => 'Choose a file';

  @override
  String get expiryDate => 'Expiry date';

  @override
  String get expired => 'EXPIRED';

  @override
  String expiresIn(Object days) {
    return 'Expires in $days days';
  }

  @override
  String get fileAdded => 'File added';

  @override
  String get fileDeleted => 'Document deleted';

  @override
  String get replace => 'Replace';

  @override
  String get add => 'Add';

  @override
  String get validity => 'Validity';

  @override
  String get noDocumentLoaded => 'No document loaded';

  @override
  String get chooseFromGallery => 'Choose from gallery';

  @override
  String expiresOn(Object date) {
    return 'Expires on: $date';
  }

  @override
  String get noExpiryDate => 'No expiry date entered';

  @override
  String get chooseSubscription => 'Choose my subscription';

  @override
  String get currentSubscription => 'CURRENT SUBSCRIPTION';

  @override
  String get stayHere => 'STAY HERE';

  @override
  String get contactUs => 'CONTACT US';

  @override
  String get subscribeAction => 'SUBSCRIBE';

  @override
  String get finalizeSubscription => 'Finalize subscription';

  @override
  String get useStripe => 'Use Stripe';

  @override
  String get dummyPayment => 'Dummy Card Payment (Test Mode)';

  @override
  String get cardNumber => 'Card number';

  @override
  String get cvc => 'CVC';

  @override
  String get confirmDummyPayment => 'CONFIRM DUMMY PAYMENT';

  @override
  String congratsSubscription(Object tier) {
    return 'Congratulations! You are now $tier';
  }

  @override
  String get paymentFailed => 'Payment failed or was cancelled.';

  @override
  String get fleetAdminConsole => 'Fleet Admin Console';

  @override
  String get drivers => 'Drivers';

  @override
  String get fleetPlanning => 'Fleet Planning';

  @override
  String get addDriver => 'Add a driver';

  @override
  String get driverCreated => 'Account created successfully';

  @override
  String get superAdminTitle => 'Super Administration';

  @override
  String get users => 'Users';

  @override
  String get diamondRequests => 'Diamond Requests';

  @override
  String get sqlGuide => 'Client SQL Guide';

  @override
  String deleteConfirmUser(Object name) {
    return 'Are you sure you want to delete $name?';
  }

  @override
  String get changeLanguage => 'Changer de langue';

  @override
  String get mapLayers => 'Map Layers';

  @override
  String get standardView => 'Plan View';

  @override
  String get satelliteView => 'Satellite View';

  @override
  String get terrainView => 'Terrain View';

  @override
  String get deleteTrip => 'Delete trip';

  @override
  String get importKml => 'Import KML';
}
