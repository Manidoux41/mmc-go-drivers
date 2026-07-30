// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'MMC Go Drivers';

  @override
  String get selectLanguage => '选择您的语言';

  @override
  String get continueAction => '继续';

  @override
  String get welcome => '欢迎';

  @override
  String get dashboard => '仪表板';

  @override
  String get navigation => '导航';

  @override
  String get planning => '计划';

  @override
  String get vehicle => '车辆';

  @override
  String get documents => '文档';

  @override
  String get contact => '联系方式';

  @override
  String get administration => '管理';

  @override
  String get superAdmin => '超级管理员';

  @override
  String get logout => '登出';

  @override
  String get login => '登录';

  @override
  String get register => '注册';

  @override
  String get email => '电子邮件';

  @override
  String get password => '密码';

  @override
  String get hello => '你好';

  @override
  String get tier => '订阅';

  @override
  String get tools => '工具';

  @override
  String get loading => '正在加载...';

  @override
  String get error => '错误';

  @override
  String get confirm => '确认';

  @override
  String get cancel => '取消';

  @override
  String get navAndRecording => '导航与录制';

  @override
  String helloUser(Object username) {
    return '你好, $username';
  }

  @override
  String get mmcAccount => 'MMC Go 账户';

  @override
  String get manageSubscription => '管理我的订阅';

  @override
  String get aboutMMC => '关于 MMC Go';

  @override
  String get calculatingRoute => '正在计算优化的货车路线...';

  @override
  String vehicleInfo(Object registration) {
    return '车辆: $registration';
  }

  @override
  String get hgvOptimized => '⚠️ 货车优化路线';

  @override
  String get startPoint => '起点';

  @override
  String get destination => '目的地';

  @override
  String get waypoint => '途经点';

  @override
  String get addStep => '添加步骤';

  @override
  String get chooseRoute => '选择路线';

  @override
  String get startNav => '开始';

  @override
  String get calculateRoute => '计算路线';

  @override
  String get saveTrip => '保存行程';

  @override
  String get tripName => '行程名称';

  @override
  String get tripHistory => '行程历史';

  @override
  String get stats => '统计';

  @override
  String get speed => '速度';

  @override
  String get distance => '距离';

  @override
  String get altitude => '海拔';

  @override
  String get universalTool => '承运商的通用工具';

  @override
  String get dbConfig => '数据库配置';

  @override
  String get username => '用户名';

  @override
  String get noAccount => '还没有账号？';

  @override
  String get loginAction => '登录';

  @override
  String get registerAction => '注册';

  @override
  String get fullName => '全名';

  @override
  String get alreadyHaveAccount => '已经有账号了？';

  @override
  String get passwordMinimum => '密码长度必须至少为 6 个字符';

  @override
  String get emailRequired => '电子邮件和密码是必需的';

  @override
  String get createAccount => '创建账户';

  @override
  String get joinMMC => '加入 MMC Go Drivers';

  @override
  String get confirmPassword => '确认密码';

  @override
  String get passwordsDoNotMatch => '密码不匹配';

  @override
  String get registerAndChoosePlan => '注册并选择方案';

  @override
  String get myPlanning => '我的规划';

  @override
  String get exportPdf => '导出为 PDF';

  @override
  String get today => '今天';

  @override
  String get missionPasted => '任务粘贴成功';

  @override
  String get pasteMission => '粘贴已复制的任务';

  @override
  String get rseAlerts => '企业社会责任警报';

  @override
  String get noTrips => '在此期间没有计划行程';

  @override
  String get addPersonalMission => '添加个人任务';

  @override
  String get day => '日';

  @override
  String get week => '周';

  @override
  String get month => '月';

  @override
  String fromTo(Object end, Object start) {
    return '从 $start 到 $end';
  }

  @override
  String get edit => '编辑';

  @override
  String get delete => '删除';

  @override
  String get bus => '巴士';

  @override
  String get departure => '出发';

  @override
  String get arrival => '到达';

  @override
  String get notes => '备注';

  @override
  String get save => '保存';

  @override
  String get myVehicles => '我的车辆';

  @override
  String get addVehicle => '添加车辆';

  @override
  String get registration => '车牌号';

  @override
  String get brand => '品牌';

  @override
  String get model => '型号';

  @override
  String get height => '高度';

  @override
  String get length => '长度';

  @override
  String get width => '宽度';

  @override
  String get unladenWeight => '整备质量';

  @override
  String get ptac => '最大总质量';

  @override
  String get fuelType => '燃料类型';

  @override
  String get mileage => '里程';

  @override
  String get diesel => '柴油';

  @override
  String get electric => '电动';

  @override
  String get gas => '燃气';

  @override
  String get essence => '汽油';

  @override
  String get other => '其他';

  @override
  String get dimensions => '尺寸';

  @override
  String get weight => '重量';

  @override
  String get myFleet => '我的客车车队';

  @override
  String get energy => '能源';

  @override
  String get editVehicle => '编辑车辆';

  @override
  String get registrationRequired => '注册 *';

  @override
  String get parkNumber => '车队编号';

  @override
  String get initialMileage => '初始里程';

  @override
  String get newMileage => '新里程 (公里)';

  @override
  String get vehicleModified => '车辆已修改';

  @override
  String get vehicleSaved => '车辆已保存';

  @override
  String deleteConfirmVehicle(Object registration) {
    return '您确定要删除车辆 $registration 吗？';
  }

  @override
  String get contactCenter => '帮助中心和联系方式';

  @override
  String get techSupport => '技术支持';

  @override
  String get salesContact => '销售联系人';

  @override
  String get whatsappSupport => 'WhatsApp 支持';

  @override
  String get faqDoc => '常见问题解答和文档';

  @override
  String get sendEmail => '发送电子邮件';

  @override
  String get call => '打电话';

  @override
  String get contactMessage => '我们的团队随时为您解答任何技术或商业问题。';

  @override
  String get usefulContacts => '常用联系人';

  @override
  String get myDocuments => '我的文档';

  @override
  String get addDocument => '添加文档';

  @override
  String get documentType => '文档类型';

  @override
  String get driverLicense => '驾驶证';

  @override
  String get fimoFco => 'FIMO/FCO';

  @override
  String get tachographCard => '行驶记录卡';

  @override
  String get vehicleRegistration => '行驶证';

  @override
  String get insuranceCert => '保险证明';

  @override
  String get takePhoto => '拍照';

  @override
  String get chooseFile => '选择文件';

  @override
  String get expiryDate => '过期日期';

  @override
  String get expired => '已过期';

  @override
  String expiresIn(Object days) {
    return '还有 $days 天过期';
  }

  @override
  String get fileAdded => '文件已添加';

  @override
  String get fileDeleted => '文档已删除';

  @override
  String get replace => '替换';

  @override
  String get add => '添加';

  @override
  String get validity => '有效期';

  @override
  String get noDocumentLoaded => '未加载文档';

  @override
  String get chooseFromGallery => '从相册选择';

  @override
  String expiresOn(Object date) {
    return '过期日期：$date';
  }

  @override
  String get noExpiryDate => '未输入过期日期';

  @override
  String get chooseSubscription => '选择我的订阅';

  @override
  String get currentSubscription => '当前订阅';

  @override
  String get stayHere => '留在这里';

  @override
  String get contactUs => '联系我们';

  @override
  String get subscribeAction => '订阅';

  @override
  String get finalizeSubscription => '完成订阅';

  @override
  String get useStripe => '使用 Stripe';

  @override
  String get dummyPayment => '虚拟卡支付（测试模式）';

  @override
  String get cardNumber => '卡号';

  @override
  String get cvc => 'CVC';

  @override
  String get confirmDummyPayment => '确认虚拟支付';

  @override
  String congratsSubscription(Object tier) {
    return '恭喜！您现在是 $tier';
  }

  @override
  String get paymentFailed => '付款失败或已取消。';

  @override
  String get fleetAdminConsole => '车队管理控制台';

  @override
  String get drivers => '驾驶员';

  @override
  String get fleetPlanning => '车队规划';

  @override
  String get addDriver => '添加驾驶员';

  @override
  String get driverCreated => '账号创建成功';

  @override
  String get superAdminTitle => '超级管理';

  @override
  String get users => '用户';

  @override
  String get diamondRequests => '钻石请求';

  @override
  String get sqlGuide => '客户SQL指南';

  @override
  String deleteConfirmUser(Object name) {
    return '确定要删除 $name 吗？';
  }

  @override
  String get changeLanguage => 'Changer de langue';

  @override
  String get mapLayers => '地图图层';

  @override
  String get standardView => '平面视图';

  @override
  String get satelliteView => '卫星视图';

  @override
  String get terrainView => '地形视图';
}
