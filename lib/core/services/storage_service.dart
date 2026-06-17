import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

/// Centralized storage service to avoid Get.find dependencies
class StorageService extends GetxService {
  static late StorageService to;

  final _box = GetStorage();

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

  Future<StorageService> init() async {
    to = this;
    return this;
  }

  // Getters
  String? get token => _box.read(keyToken);
  String? get transactionUrl => _box.read(keyTransactionUrl);
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

  // Clear session
  Future<void> clearAuthData() async {
    await _box.remove(keyToken);
    await _box.remove('cached_dashboard');
    await _box.remove('cached_profile');
    await _box.remove(keyUsername);
    await _box.remove(keyUserEmail);
  }
}
