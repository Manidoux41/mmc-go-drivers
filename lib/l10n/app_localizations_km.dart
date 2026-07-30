// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Khmer Central Khmer (`km`).
class AppLocalizationsKm extends AppLocalizations {
  AppLocalizationsKm([String locale = 'km']) : super(locale);

  @override
  String get appTitle => 'MMC Go Drivers';

  @override
  String get selectLanguage => 'ជ្រើសរើសភាសារបស់អ្នក';

  @override
  String get continueAction => 'បន្ត';

  @override
  String get welcome => 'សូមស្វាគមន៍';

  @override
  String get dashboard => 'ផ្ទាំងគ្រប់គ្រង';

  @override
  String get navigation => 'ការរុករក';

  @override
  String get planning => 'ផែនការ';

  @override
  String get vehicle => 'យានយន្ត';

  @override
  String get documents => 'ឯកសារ';

  @override
  String get contact => 'ទំនាក់ទំនង';

  @override
  String get administration => 'ការគ្រប់គ្រង';

  @override
  String get superAdmin => 'អ្នកគ្រប់គ្រងជាន់ខ្ពស់';

  @override
  String get logout => 'ចាកចេញ';

  @override
  String get login => 'ចូល';

  @override
  String get register => 'ចុះឈ្មោះ';

  @override
  String get email => 'អ៊ីមែល';

  @override
  String get password => 'ពាក្យសម្ងាត់';

  @override
  String get hello => 'សួស្តី';

  @override
  String get tier => 'ការជាវ';

  @override
  String get tools => 'ឧបករណ៍';

  @override
  String get loading => 'កំពុងផ្ទុក...';

  @override
  String get error => 'កំហុស';

  @override
  String get confirm => 'បញ្ជាក់';

  @override
  String get cancel => 'បោះបង់';

  @override
  String get navAndRecording => 'ការរុករក និងការកត់ត្រា';

  @override
  String helloUser(Object username) {
    return 'សួស្តី $username';
  }

  @override
  String get mmcAccount => 'គណនី MMC Go';

  @override
  String get manageSubscription => 'គ្រប់គ្រងការជាវរបស់ខ្ញុំ';

  @override
  String get aboutMMC => 'អំពី MMC Go';

  @override
  String get calculatingRoute =>
      'កំពុងគណនាផ្លូវរថយន្តធុនធំដែលបានធ្វើឱ្យប្រសើរ...';

  @override
  String vehicleInfo(Object registration) {
    return 'យានយន្ត: $registration';
  }

  @override
  String get hgvOptimized => '⚠️ ផ្លូវដែលបានធ្វើឱ្យប្រសើរសម្រាប់រថយន្តធុនធំ';

  @override
  String get startPoint => 'ចំណុចចាប់ផ្តើម';

  @override
  String get destination => 'គោលដៅ';

  @override
  String get waypoint => 'ចំណុចផ្លូវ';

  @override
  String get addStep => 'បន្ថែមជំហាន';

  @override
  String get chooseRoute => 'ជ្រើសរើសផ្លូវ';

  @override
  String get startNav => 'ចាប់ផ្តើម';

  @override
  String get calculateRoute => 'គណនាផ្លូវ';

  @override
  String get saveTrip => 'រក្សាទុកការធ្វើដំណើរ';

  @override
  String get tripName => 'ឈ្មោះដំណើរកម្សាន្ត';

  @override
  String get tripHistory => 'ប្រវត្តិធ្វើដំណើរ';

  @override
  String get stats => 'ស្ថិតិ';

  @override
  String get speed => 'ល្បឿន';

  @override
  String get distance => 'ចម្ងាយ';

  @override
  String get altitude => 'កម្ពស់';

  @override
  String get universalTool => 'ឧបករណ៍សកលសម្រាប់អ្នកដឹកជញ្ជូន';

  @override
  String get dbConfig => 'ការកំណត់រចនាសម្ព័ន្ធ DB';

  @override
  String get username => 'ឈ្មោះអ្នកប្រើប្រាស់';

  @override
  String get noAccount => 'មិនទាន់មានគណនីមែនទេ?';

  @override
  String get loginAction => 'ចូល';

  @override
  String get registerAction => 'ចុះឈ្មោះ';

  @override
  String get fullName => 'ឈ្មោះ​ពេញ';

  @override
  String get alreadyHaveAccount => 'មានគណនីរួចហើយមែនទេ?';

  @override
  String get passwordMinimum => 'ពាក្យសម្ងាត់ត្រូវតែមានយ៉ាងហោចណាស់ 6 តួអក្សر';

  @override
  String get emailRequired => 'អ៊ីមែល និងពាក្យសម្ងាត់ត្រូវបានទាមទារ';

  @override
  String get createAccount => 'បង្កើតគណនី';

  @override
  String get joinMMC => 'ចូលរួមជាមួយ MMC Go Drivers';

  @override
  String get confirmPassword => 'បញ្ជាក់ពាក្យសម្ងាត់';

  @override
  String get passwordsDoNotMatch => 'ពាក្យសម្ងាត់មិនត្រូវគ្នាទេ';

  @override
  String get registerAndChoosePlan => 'ចុះឈ្មោះ និងជ្រើសរើសគម្រោង';

  @override
  String get myPlanning => 'ផែនការរបស់ខ្ញុំ';

  @override
  String get exportPdf => 'នាំចេញជា PDF';

  @override
  String get today => 'ថ្ងៃនេះ';

  @override
  String get missionPasted => 'បានបិទភ្ជាប់បេសកកម្មដោយជោគជ័យ';

  @override
  String get pasteMission => 'បិទភ្ជាប់បេសកកម្មដែលបានចម្លង';

  @override
  String get rseAlerts => 'ការជូនដំណឹង RSE';

  @override
  String get noTrips => 'គ្មានការធ្វើដំណើរដែលបានគ្រោងទុកសម្រាប់រយៈពេលនេះទេ';

  @override
  String get addPersonalMission => 'បន្ថែមបេសកកម្មផ្ទាល់ខ្លួន';

  @override
  String get day => 'ថ្ងៃ';

  @override
  String get week => 'សប្តាហ៍';

  @override
  String get month => 'ខែ';

  @override
  String fromTo(Object end, Object start) {
    return 'ពី $start ដល់ $end';
  }

  @override
  String get edit => 'កែសម្រួល';

  @override
  String get delete => 'លុប';

  @override
  String get bus => 'ឡានក្រុង';

  @override
  String get departure => 'ការចាកចេញ';

  @override
  String get arrival => 'ការមកដល់';

  @override
  String get notes => 'កំណត់សម្គាល់';

  @override
  String get save => 'រក្សាទុក';

  @override
  String get myVehicles => 'យានយន្តរបស់ខ្ញុំ';

  @override
  String get addVehicle => 'បន្ថែមយានយន្ត';

  @override
  String get registration => 'ការចុះបញ្ជី';

  @override
  String get brand => 'ម៉ាក';

  @override
  String get model => 'ម៉ូដែល';

  @override
  String get height => 'កម្ពស់';

  @override
  String get length => 'ប្រវែង';

  @override
  String get width => 'ទទឹង';

  @override
  String get unladenWeight => 'ទម្ងន់ទទេ';

  @override
  String get ptac => 'ទម្ងន់សរុបអនុញ្ញាត';

  @override
  String get fuelType => 'ប្រភេទប្រេងឥន្ធនៈ';

  @override
  String get mileage => 'ចម្ងាយចរ';

  @override
  String get diesel => 'ម៉ាស៊ូត';

  @override
  String get electric => 'អគ្គិសនី';

  @override
  String get gas => 'ហ្គាស';

  @override
  String get essence => 'សាំង';

  @override
  String get other => 'ផ្សេងៗ';

  @override
  String get dimensions => 'វិមាត្រ';

  @override
  String get weight => 'ទម្ងន់';

  @override
  String get myFleet => 'កងឡានក្រុងរបស់ខ្ញុំ';

  @override
  String get energy => 'ថាមពល';

  @override
  String get editVehicle => 'កែសម្រួលយានយន្ត';

  @override
  String get registrationRequired => 'ការចុះបញ្ជី *';

  @override
  String get parkNumber => 'លេខកង';

  @override
  String get initialMileage => 'ចម្ងាយផ្លូវដំបូង';

  @override
  String get newMileage => 'ចម្ងាយផ្លូវថ្មី (គីឡូម៉ែត្រ)';

  @override
  String get vehicleModified => 'យានយន្តត្រូវបានកែសម្រួល';

  @override
  String get vehicleSaved => 'យានយន្តត្រូវបានរក្សាទុក';

  @override
  String deleteConfirmVehicle(Object registration) {
    return 'តើអ្នកពិតជាចង់លុបយានយន្ត $registration មែនទេ?';
  }

  @override
  String get contactCenter => 'មជ្ឈមណ្ឌលជំនួយ និងទំនាក់ទំនង';

  @override
  String get techSupport => 'ការគាំទ្រផ្នែកបច្ចេកទេស';

  @override
  String get salesContact => 'ទំនាក់ទំនងផ្នែកលក់';

  @override
  String get whatsappSupport => 'ការគាំទ្រតាម WhatsApp';

  @override
  String get faqDoc => 'សំណួរដែលសួរញឹកញាប់ និងឯកសារ';

  @override
  String get sendEmail => 'ផ្ញើអ៊ីមែល';

  @override
  String get call => 'ហៅទូរស័ព្ទ';

  @override
  String get contactMessage =>
      'ក្រុមរបស់យើងនៅទីនេះដើម្បីជួយអ្នកសម្រាប់រាល់សំណួរបច្ចេកទេស ឬពាណិជ្ជកម្ម។';

  @override
  String get usefulContacts => 'ទំនាក់ទំនងមានប្រយោជន៍';

  @override
  String get myDocuments => 'ឯកសាររបស់ខ្ញុំ';

  @override
  String get addDocument => 'បន្ថែមឯកសារ';

  @override
  String get documentType => 'ប្រភេទឯកសារ';

  @override
  String get driverLicense => 'ប័ណ្ណបើកបរ';

  @override
  String get fimoFco => 'FIMO/FCO';

  @override
  String get tachographCard => 'ប័ណ្ណតាខូក្រាហ្វ';

  @override
  String get vehicleRegistration => 'ប័ណ្ណសម្គាល់យានយន្ត';

  @override
  String get insuranceCert => 'វិញ្ញាបនប័ត្រធានារ៉ាប់រង';

  @override
  String get takePhoto => 'ថតរូប';

  @override
  String get chooseFile => 'ជ្រើសរើសឯកសារ';

  @override
  String get expiryDate => 'កាលបរិច្ឆេទផុតកំណត់';

  @override
  String get expired => 'ផុតកំណត់';

  @override
  String expiresIn(Object days) {
    return 'ផុតកំណត់ក្នុងរយៈពេល $days ថ្ងៃ';
  }

  @override
  String get fileAdded => 'បានបន្ថែមឯកសារ';

  @override
  String get fileDeleted => 'បានលុបឯកសារ';

  @override
  String get replace => 'ជំនួស';

  @override
  String get add => 'បន្ថែម';

  @override
  String get validity => 'សុពលភាព';

  @override
  String get noDocumentLoaded => 'មិនមានឯកសារត្រូវបានផ្ទុកទេ';

  @override
  String get chooseFromGallery => 'ជ្រើសរើសពីវិចិត្រសាល';

  @override
  String expiresOn(Object date) {
    return 'ផុតកំណត់នៅថ្ងៃទី៖ $date';
  }

  @override
  String get noExpiryDate => 'មិនបានបញ្ចូលកាលបរិច្ឆេទផុតកំណត់ទេ';

  @override
  String get chooseSubscription => 'ជ្រើសរើសការជាវរបស់ខ្ញុំ';

  @override
  String get currentSubscription => 'ការជាវបច្ចុប្បន្ន';

  @override
  String get stayHere => 'ស្នាក់នៅទីនេះ';

  @override
  String get contactUs => 'ទាក់ទងមកយើង';

  @override
  String get subscribeAction => 'ជាវ';

  @override
  String get finalizeSubscription => 'បញ្ចប់ការជាវ';

  @override
  String get useStripe => 'ប្រើ Stripe';

  @override
  String get dummyPayment => 'ការទូទាត់តាមកាតសិប្បនិម្មិត (របៀបសាកល្បង)';

  @override
  String get cardNumber => 'លេខកាត';

  @override
  String get cvc => 'CVC';

  @override
  String get confirmDummyPayment => 'បញ្ជាក់ការទូទាត់សិប្បនិម្មិត';

  @override
  String congratsSubscription(Object tier) {
    return 'សូមអបអរសាទរ! ឥឡូវនេះអ្នកគឺជា $tier';
  }

  @override
  String get paymentFailed => 'ការទូទាត់បានបរាជ័យ ឬត្រូវបានលុបចោល';

  @override
  String get fleetAdminConsole => 'ផ្ទាំងគ្រប់គ្រងរថយន្ត';

  @override
  String get drivers => 'អ្នកបើកបរ';

  @override
  String get fleetPlanning => 'ការរៀបចំផែនការរថយន្ត';

  @override
  String get addDriver => 'បន្ថែមអ្នកបើកបរ';

  @override
  String get driverCreated => 'គណនីត្រូវបានបង្កើតដោយជោគជ័យ';

  @override
  String get superAdminTitle => 'ការគ្រប់គ្រងជាន់ខ្ពស់';

  @override
  String get users => 'អ្នកប្រើប្រាស់';

  @override
  String get diamondRequests => 'សំណើពេជ្រ';

  @override
  String get sqlGuide => 'មគ្គុទ្ទេសក៍ SQL សម្រាប់អតិថិជន';

  @override
  String deleteConfirmUser(Object name) {
    return 'តើអ្នកប្រាកដថាចង់លុប $name ឬទេ?';
  }

  @override
  String get changeLanguage => 'Changer de langue';

  @override
  String get mapLayers => 'ស្រទាប់ផែនទី';

  @override
  String get standardView => 'ទិដ្ឋភាពប្លង់';

  @override
  String get satelliteView => 'ទិដ្ឋភាពផ្កាយរណប';

  @override
  String get terrainView => 'ទិដ្ឋភាពដី';
}
