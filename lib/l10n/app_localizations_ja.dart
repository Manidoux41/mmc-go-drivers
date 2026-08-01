// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'MMC Go Drivers';

  @override
  String get selectLanguage => '言語を選択してください';

  @override
  String get continueAction => '続行';

  @override
  String get welcome => 'ようこそ';

  @override
  String get dashboard => 'ダッシュボード';

  @override
  String get navigation => 'ナビゲーション';

  @override
  String get planning => 'プランニング';

  @override
  String get vehicle => '車両';

  @override
  String get documents => 'ドキュメント';

  @override
  String get contact => '連絡先';

  @override
  String get administration => '管理';

  @override
  String get superAdmin => 'スーパーアドミン';

  @override
  String get logout => 'ログアウト';

  @override
  String get login => 'ログイン';

  @override
  String get register => '登録';

  @override
  String get email => 'メール';

  @override
  String get password => 'パスワード';

  @override
  String get hello => 'こんにちは';

  @override
  String get tier => 'サブスクリプション';

  @override
  String get tools => 'ツール';

  @override
  String get loading => '読み込み中...';

  @override
  String get error => 'エラー';

  @override
  String get confirm => '確認';

  @override
  String get cancel => 'キャンセル';

  @override
  String get navAndRecording => 'ナビゲーションと録音';

  @override
  String helloUser(Object username) {
    return 'こんにちは、$username';
  }

  @override
  String get mmcAccount => 'MMC Go アカウント';

  @override
  String get manageSubscription => 'サブスクリプションを管理する';

  @override
  String get aboutMMC => 'MMC Go について';

  @override
  String get calculatingRoute => '最適化された大型車ルートを計算中...';

  @override
  String vehicleInfo(Object registration) {
    return '車両: $registration';
  }

  @override
  String get hgvOptimized => '⚠️ 大型車最適化ルート';

  @override
  String get startPoint => '出発点';

  @override
  String get destination => '目的地';

  @override
  String get waypoint => '経由地';

  @override
  String get addStep => 'ステップを追加';

  @override
  String get chooseRoute => 'ルートを選択';

  @override
  String get startNav => 'スタート';

  @override
  String get calculateRoute => 'ルートを計算';

  @override
  String get saveTrip => '旅行を保存';

  @override
  String get tripName => '旅行名';

  @override
  String get tripHistory => '旅行履歴';

  @override
  String get stats => '統計';

  @override
  String get speed => '速度';

  @override
  String get distance => '距離';

  @override
  String get altitude => '高度';

  @override
  String get universalTool => '運送業者のためのユニバーサルツール';

  @override
  String get dbConfig => 'DB設定';

  @override
  String get username => 'ユーザー名';

  @override
  String get noAccount => 'アカウントをお持ちでないですか？';

  @override
  String get loginAction => 'ログイン';

  @override
  String get registerAction => '登録';

  @override
  String get fullName => 'フルネーム';

  @override
  String get alreadyHaveAccount => 'すでにアカウントをお持ちですか？';

  @override
  String get passwordMinimum => 'パスワードは6文字以上である必要があります';

  @override
  String get emailRequired => 'メールアドレスとパスワードは必須です';

  @override
  String get createAccount => 'アカウントを作成';

  @override
  String get joinMMC => 'MMC Go Driversに参加';

  @override
  String get confirmPassword => 'パスワードを再入力';

  @override
  String get passwordsDoNotMatch => 'パスワードが一致しません';

  @override
  String get registerAndChoosePlan => '登録してプランを選択';

  @override
  String get myPlanning => 'マイプランニング';

  @override
  String get exportPdf => 'PDFとして書き出し';

  @override
  String get today => '今日';

  @override
  String get missionPasted => 'ミッションの貼り付けに成功しました';

  @override
  String get pasteMission => 'コピーしたミッションを貼り付け';

  @override
  String get rseAlerts => 'CSRアラート';

  @override
  String get noTrips => 'この期間の予定はありません';

  @override
  String get addPersonalMission => '個人的なミッションを追加';

  @override
  String get day => '日';

  @override
  String get week => '週';

  @override
  String get month => '月';

  @override
  String fromTo(Object end, Object start) {
    return '$startから$endまで';
  }

  @override
  String get edit => '編集';

  @override
  String get delete => '削除';

  @override
  String get bus => 'バス';

  @override
  String get departure => '出発';

  @override
  String get arrival => '到着';

  @override
  String get notes => 'メモ';

  @override
  String get save => '保存';

  @override
  String get myVehicles => '私の車両';

  @override
  String get addVehicle => '車両を追加';

  @override
  String get registration => '登録';

  @override
  String get brand => 'ブランド';

  @override
  String get model => 'モデル';

  @override
  String get height => '高さ';

  @override
  String get length => '長さ';

  @override
  String get width => '幅';

  @override
  String get unladenWeight => '車両総重量';

  @override
  String get ptac => '車両総重量';

  @override
  String get fuelType => '燃料の種類';

  @override
  String get mileage => '走行距離';

  @override
  String get diesel => 'ディーゼル';

  @override
  String get electric => '電気';

  @override
  String get gas => 'ガス';

  @override
  String get essence => 'ガソリン';

  @override
  String get other => 'その他';

  @override
  String get dimensions => '寸法';

  @override
  String get weight => '重量';

  @override
  String get myFleet => '私のコーチフリート';

  @override
  String get energy => 'エネルギー';

  @override
  String get editVehicle => '車両を編集';

  @override
  String get registrationRequired => '登録 *';

  @override
  String get parkNumber => '車両番号';

  @override
  String get initialMileage => '初期走行距離';

  @override
  String get newMileage => '新しい走行距離 (km)';

  @override
  String get vehicleModified => '車両が変更されました';

  @override
  String get vehicleSaved => '車両が保存されました';

  @override
  String deleteConfirmVehicle(Object registration) {
    return '本当に車両 $registration を削除しますか？';
  }

  @override
  String get contactCenter => 'ヘルプセンターと連絡先';

  @override
  String get techSupport => 'テクニカルサポート';

  @override
  String get salesContact => '販売窓口';

  @override
  String get whatsappSupport => 'WhatsAppサポート';

  @override
  String get faqDoc => 'よくある質問とドキュメント';

  @override
  String get sendEmail => 'メールを送る';

  @override
  String get call => '電話する';

  @override
  String get contactMessage => '当社のチームは、技術的または商業的な質問に対して、いつでもお手伝いいたします。';

  @override
  String get usefulContacts => '役立つ連絡先';

  @override
  String get myDocuments => 'マイドキュメント';

  @override
  String get addDocument => 'ドキュメントを追加';

  @override
  String get documentType => 'ドキュメントの種類';

  @override
  String get driverLicense => '運転免許証';

  @override
  String get fimoFco => 'FIMO/FCO';

  @override
  String get tachographCard => 'タコグラフカード';

  @override
  String get vehicleRegistration => '車検証';

  @override
  String get insuranceCert => '保険証';

  @override
  String get takePhoto => '写真を撮る';

  @override
  String get chooseFile => 'ファイルを選択';

  @override
  String get expiryDate => '有効期限';

  @override
  String get expired => '期限切れ';

  @override
  String expiresIn(Object days) {
    return '$days日後に期限切れ';
  }

  @override
  String get fileAdded => 'ファイルを追加しました';

  @override
  String get fileDeleted => 'ドキュメントを削除しました';

  @override
  String get replace => '置き換える';

  @override
  String get add => '追加';

  @override
  String get validity => '有効性';

  @override
  String get noDocumentLoaded => 'ドキュメントが読み込まれていません';

  @override
  String get chooseFromGallery => 'ギャラリーから選択';

  @override
  String expiresOn(Object date) {
    return '有効期限: $date';
  }

  @override
  String get noExpiryDate => '有効期限が入力されていません';

  @override
  String get chooseSubscription => 'サブスクリプションを選択';

  @override
  String get currentSubscription => '現在のサブスクリプション';

  @override
  String get stayHere => 'ここに留まる';

  @override
  String get contactUs => 'お問い合わせ';

  @override
  String get subscribeAction => '購読する';

  @override
  String get finalizeSubscription => 'サブスクリプションを完了する';

  @override
  String get useStripe => 'Stripeを使用する';

  @override
  String get dummyPayment => 'ダミーカード決済（テストモード）';

  @override
  String get cardNumber => 'カード番号';

  @override
  String get cvc => 'CVC';

  @override
  String get confirmDummyPayment => 'ダミー決済を確認';

  @override
  String congratsSubscription(Object tier) {
    return 'おめでとうございます！あなたは現在 $tier です';
  }

  @override
  String get paymentFailed => '支払いに失敗したか、キャンセルされました。';

  @override
  String get fleetAdminConsole => '車両管理コンソール';

  @override
  String get drivers => 'ドライバー';

  @override
  String get fleetPlanning => '車両計画';

  @override
  String get addDriver => 'ドライバーを追加';

  @override
  String get driverCreated => 'アカウントが正常に作成されました';

  @override
  String get superAdminTitle => 'スーパー管理者';

  @override
  String get users => 'ユーザー';

  @override
  String get diamondRequests => 'ダイヤモンド・リクエスト';

  @override
  String get sqlGuide => 'クライアントSQLガイド';

  @override
  String deleteConfirmUser(Object name) {
    return '$nameを本当に削除しますか？';
  }

  @override
  String get changeLanguage => 'Changer de langue';

  @override
  String get mapLayers => 'マップレイヤー';

  @override
  String get standardView => '平面ビュー';

  @override
  String get satelliteView => 'サテライトビュー';

  @override
  String get terrainView => '地形ビュー';

  @override
  String get deleteTrip => '旅行を削除';

  @override
  String get importKml => 'Importer un KML';
}
