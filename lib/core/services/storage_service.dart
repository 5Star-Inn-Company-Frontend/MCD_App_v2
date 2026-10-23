import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../app/modules/home_screen_module/model/dashboard_model.dart';
import '../../../core/network/api_constants.dart';

/// Centralized storage service to avoid Get.find dependencies
class StorageService extends GetxService {
  static late StorageService to;

  final _box = GetStorage();

  // Reactive state
  final Rxn<DashboardModel> dashboardData = Rxn<DashboardModel>();

  // Keys
  static const String keyToken = 'token';
  static const String keyTransactionUrl = 'transaction_service_url';
  static const String keyUtilityUrl = 'utility_service_url';
  static const String keyUsername = 'biometric_username_real';
  static const String keyUserEmail = 'user_email';
  static const String keyBiometricEnabled = 'biometric_enabled';
  static const String keyTwoFactorEnabled = 'twofa_enabled';
  static const String keyGiveawayNotify = 'giveaway_notification_enabled';
  static const String keyPromoEnabled = 'promo_enabled';
  static const String keyCachedDashboard = 'cached_dashboard';

  StorageService() {
    to = this;
  }

  Future<StorageService> init() async {
    _loadInitialData();
    return this;
  }

  void _loadInitialData() {
    final cached = _box.read(keyCachedDashboard);
    if (cached != null) {
      try {
        dashboardData.value = DashboardModel.fromJson(cached);
      } catch (_) {}
    }
  }

  // Getters
  String? get token => _box.read(keyToken);
  String? get transactionUrl => _box.read(keyTransactionUrl);
  String get transactionUrlV2 {
    final transV1 = _box.read(keyTransactionUrl);
    if (transV1 != null && transV1.toString().isNotEmpty) {
      String str = transV1.toString().trim();
      if (str.contains('/api/v2')) {
        while (str.contains('/api/v2/api/v2')) {
          str = str.replaceAll('/api/v2/api/v2', '/api/v2');
        }
        return str.endsWith('/') ? str : '$str/';
      }
      if (str.contains('/api/v1')) {
        final replaced = str.replaceAll('/api/v1', '/api/v2');
        return replaced.endsWith('/') ? replaced : '$replaced/';
      }
      return str.endsWith('/') ? '${str}api/v2/' : '$str/api/v2/';
    }
    return '${ApiConstants.temporaryTransUrl}/api/v2/';
  }
  String? get utilityUrl => _box.read(keyUtilityUrl);
  String? get username => _box.read(keyUsername);
  String? get userEmail => _box.read(keyUserEmail);
  bool get isBiometricEnabled => _box.read(keyBiometricEnabled) ?? true;
  bool get isTwoFactorEnabled => _box.read(keyTwoFactorEnabled) ?? false;
  bool get isGiveawayNotifyEnabled => _box.read(keyGiveawayNotify) ?? false;
  bool get isPromoEnabled => _box.read(keyPromoEnabled) ?? false;

  // Setters
  Future<void> setToken(String value) => _box.write(keyToken, value);
  Future<void> setUrls(String transaction, String utility) async {
    await _box.write(keyTransactionUrl, transaction);
    await _box.write(keyUtilityUrl, utility);
  }

  Future<void> setUsername(String value) => _box.write(keyUsername, value);
  Future<void> setEmail(String value) => _box.write(keyUserEmail, value);

  Future<void> setDashboardData(Map<String, dynamic> data) async {
    await _box.write(keyCachedDashboard, data);
    try {
      dashboardData.value = DashboardModel.fromJson(data);
    } catch (_) {}
  }

  // Clear session
  Future<void> clearAuthData() async {
    await _box.remove(keyToken);
    await _box.remove(keyCachedDashboard);
    await _box.remove('cached_profile');
    await _box.remove(keyUsername);
    await _box.remove(keyUserEmail);
    dashboardData.value = null;
  }
}
