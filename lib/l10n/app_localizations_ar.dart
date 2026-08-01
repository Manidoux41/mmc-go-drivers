// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'MMC Go Drivers';

  @override
  String get selectLanguage => 'اختر لغتك';

  @override
  String get continueAction => 'استمرار';

  @override
  String get welcome => 'مرحباً';

  @override
  String get dashboard => 'لوحة القيادة';

  @override
  String get navigation => 'الملاحة';

  @override
  String get planning => 'التخطيط';

  @override
  String get vehicle => 'المركبة';

  @override
  String get documents => 'المستندات';

  @override
  String get contact => 'اتصال';

  @override
  String get administration => 'الإدارة';

  @override
  String get superAdmin => 'مسؤول فائق';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get register => 'تسجيل';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get hello => 'مرحباً';

  @override
  String get tier => 'اشتراك';

  @override
  String get tools => 'أدوات';

  @override
  String get loading => 'جارٍ التحميل...';

  @override
  String get error => 'خطأ';

  @override
  String get confirm => 'تأكيد';

  @override
  String get cancel => 'إلغاء';

  @override
  String get navAndRecording => 'الملاحة والتسجيل';

  @override
  String helloUser(Object username) {
    return 'مرحبًا، $username';
  }

  @override
  String get mmcAccount => 'حساب MMC Go';

  @override
  String get manageSubscription => 'إدارة اشتراكي';

  @override
  String get aboutMMC => 'حول MMC Go';

  @override
  String get calculatingRoute => 'جاري حساب مسار الشاحنات المحسن...';

  @override
  String vehicleInfo(Object registration) {
    return 'المركبة: $registration';
  }

  @override
  String get hgvOptimized => '⚠️ مسار محسن للشاحنات';

  @override
  String get startPoint => 'نقطة البداية';

  @override
  String get destination => 'الوجهة';

  @override
  String get waypoint => 'نقطة الطريق';

  @override
  String get addStep => 'إضافة خطوة';

  @override
  String get chooseRoute => 'اختيار المسار';

  @override
  String get startNav => 'ابدأ';

  @override
  String get calculateRoute => 'حساب المسار';

  @override
  String get saveTrip => 'حفظ الرحلة';

  @override
  String get tripName => 'اسم الرحلة';

  @override
  String get tripHistory => 'سجل الرحلات';

  @override
  String get stats => 'الإحصائيات';

  @override
  String get speed => 'السرعة';

  @override
  String get distance => 'المسافة';

  @override
  String get altitude => 'الارتفاع';

  @override
  String get universalTool => 'الأداة العالمية للناقلين';

  @override
  String get dbConfig => 'تكوين قاعدة البيانات';

  @override
  String get username => 'اسم المستخدم';

  @override
  String get noAccount => 'ليس لديك حساب بعد؟';

  @override
  String get loginAction => 'تسجيل الدخول';

  @override
  String get registerAction => 'إنشاء حساب';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get alreadyHaveAccount => 'هل لديك حساب بالفعل؟';

  @override
  String get passwordMinimum => 'يجب أن تتكون كلمة المرور من 6 أحرف على الأقل';

  @override
  String get emailRequired => 'البريد الإلكتروني وكلمة المرور مطلوبان';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get joinMMC => 'انضم إلى MMC Go Drivers';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get passwordsDoNotMatch => 'كلمات المرور غير متطابقة';

  @override
  String get registerAndChoosePlan => 'سجل واختر خطة';

  @override
  String get myPlanning => 'تخطيطي';

  @override
  String get exportPdf => 'تصدير بصيغة PDF';

  @override
  String get today => 'اليوم';

  @override
  String get missionPasted => 'تم لصق المهمة بنجاح';

  @override
  String get pasteMission => 'لصق المهمة المنسوخة';

  @override
  String get rseAlerts => 'تنبيهات المسؤولية الاجتماعية للشركات';

  @override
  String get noTrips => 'لا توجد رحلات مخططة لهذه الفترة';

  @override
  String get addPersonalMission => 'إضافة مهمة شخصية';

  @override
  String get day => 'يوم';

  @override
  String get week => 'أسبوع';

  @override
  String get month => 'شهر';

  @override
  String fromTo(Object end, Object start) {
    return 'من $start إلى $end';
  }

  @override
  String get edit => 'تعديل';

  @override
  String get delete => 'حذف';

  @override
  String get bus => 'حافلة';

  @override
  String get departure => 'المغادرة';

  @override
  String get arrival => 'الوصول';

  @override
  String get notes => 'ملاحظات';

  @override
  String get save => 'حفظ';

  @override
  String get myVehicles => 'مركباتي';

  @override
  String get addVehicle => 'إضافة مركبة';

  @override
  String get registration => 'التسجيل';

  @override
  String get brand => 'العلامة التجارية';

  @override
  String get model => 'الطراز';

  @override
  String get height => 'الارتفاع';

  @override
  String get length => 'الطول';

  @override
  String get width => 'العرض';

  @override
  String get unladenWeight => 'الوزن الفارغ';

  @override
  String get ptac => 'الوزن الإجمالي المسموح به';

  @override
  String get fuelType => 'نوع الوقود';

  @override
  String get mileage => 'المسافة المقطوعة';

  @override
  String get diesel => 'ديزل';

  @override
  String get electric => 'كهربائي';

  @override
  String get gas => 'غاز';

  @override
  String get essence => 'بنزين';

  @override
  String get other => 'أخرى';

  @override
  String get dimensions => 'الأبعاد';

  @override
  String get weight => 'الوزن';

  @override
  String get myFleet => 'أسطولي من الحافلات';

  @override
  String get energy => 'طاقة';

  @override
  String get editVehicle => 'تعديل المركبة';

  @override
  String get registrationRequired => 'التسجيل *';

  @override
  String get parkNumber => 'رقم الأسطول';

  @override
  String get initialMileage => 'المسافة المقطوعة الأولية';

  @override
  String get newMileage => 'المسافة المقطوعة الجديدة (كم)';

  @override
  String get vehicleModified => 'تم تعديل المركبة';

  @override
  String get vehicleSaved => 'تم حفظ المركبة';

  @override
  String deleteConfirmVehicle(Object registration) {
    return 'هل أنت متأكد أنك تريد حذف المركبة $registration؟';
  }

  @override
  String get contactCenter => 'مركز المساعدة وجهات الاتصال';

  @override
  String get techSupport => 'الدعم الفني';

  @override
  String get salesContact => 'جهة اتصال المبيعات';

  @override
  String get whatsappSupport => 'دعم واتساب';

  @override
  String get faqDoc => 'الأسئلة الشائعة والوثائق';

  @override
  String get sendEmail => 'إرسال بريد إلكتروني';

  @override
  String get call => 'اتصال';

  @override
  String get contactMessage => 'فريقنا في خدمتكم لأي استفسارات فنية أو تجارية.';

  @override
  String get usefulContacts => 'جهات اتصال مفيدة';

  @override
  String get myDocuments => 'مستنداتي';

  @override
  String get addDocument => 'إضافة مستند';

  @override
  String get documentType => 'نوع المستند';

  @override
  String get driverLicense => 'رخصة القيادة';

  @override
  String get fimoFco => 'FIMO/FCO';

  @override
  String get tachographCard => 'بطاقة التاكوغراف';

  @override
  String get vehicleRegistration => 'رخصة المركبة';

  @override
  String get insuranceCert => 'شهادة التأمين';

  @override
  String get takePhoto => 'التقاط صورة';

  @override
  String get chooseFile => 'اختيار ملف';

  @override
  String get expiryDate => 'تاريخ الانتهاء';

  @override
  String get expired => 'منتهي الصلاحية';

  @override
  String expiresIn(Object days) {
    return 'تنتهي الصلاحية خلال $days أيام';
  }

  @override
  String get fileAdded => 'تم إضافة الملف';

  @override
  String get fileDeleted => 'تم حذف المستند';

  @override
  String get replace => 'استبدال';

  @override
  String get add => 'إضافة';

  @override
  String get validity => 'الصلاحية';

  @override
  String get noDocumentLoaded => 'لم يتم تحميل أي مستند';

  @override
  String get chooseFromGallery => 'اختيار من المعرض';

  @override
  String expiresOn(Object date) {
    return 'تنتهي الصلاحية في: $date';
  }

  @override
  String get noExpiryDate => 'لم يتم إدخال تاريخ انتهاء الصلاحية';

  @override
  String get chooseSubscription => 'اختر اشتراكي';

  @override
  String get currentSubscription => 'الاشتراك الحالي';

  @override
  String get stayHere => 'ابق هنا';

  @override
  String get contactUs => 'اتصل بنا';

  @override
  String get subscribeAction => 'اشتراك';

  @override
  String get finalizeSubscription => 'إنهاء الاشتراك';

  @override
  String get useStripe => 'استخدم Stripe';

  @override
  String get dummyPayment => 'دفع ببطاقة وهمية (وضع الاختبار)';

  @override
  String get cardNumber => 'رقم البطاقة';

  @override
  String get cvc => 'CVC';

  @override
  String get confirmDummyPayment => 'تأكيد الدفع الوهمي';

  @override
  String congratsSubscription(Object tier) {
    return 'تهانينا! أنت الآن $tier';
  }

  @override
  String get paymentFailed => 'فشلت عملية الدفع أو تم إلغاؤها.';

  @override
  String get fleetAdminConsole => 'لوحة تحكم إدارة الأسطول';

  @override
  String get drivers => 'السائقون';

  @override
  String get fleetPlanning => 'تخطيط الأسطول';

  @override
  String get addDriver => 'إضافة سائق';

  @override
  String get driverCreated => 'تم إنشاء الحساب بنجاح';

  @override
  String get superAdminTitle => 'الإدارة العليا';

  @override
  String get users => 'المستخدمون';

  @override
  String get diamondRequests => 'طلبات الماس';

  @override
  String get sqlGuide => 'دليل SQL للعملاء';

  @override
  String deleteConfirmUser(Object name) {
    return 'هل أنت متأكد أنك تريد حذف $name؟';
  }

  @override
  String get changeLanguage => 'Changer de langue';

  @override
  String get mapLayers => 'طبقات الخريطة';

  @override
  String get standardView => 'عرض المخطط';

  @override
  String get satelliteView => 'عرض القمر الصناعي';

  @override
  String get terrainView => 'عرض التضاريس';

  @override
  String get deleteTrip => 'حذف الرحلة';

  @override
  String get importKml => 'Importer un KML';
}
