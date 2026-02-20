import 'dart:developer' as dev;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mcd/core/import/imports.dart';

class SettingsModuleController extends GetxController {
  final box = GetStorage();
  FirebaseMessaging? _firebaseMessaging;

  FirebaseMessaging get firebaseMessaging {
    try {
      _firebaseMessaging ??= FirebaseMessaging.instance;
      return _firebaseMessaging!;
    } catch (e) {
      dev.log('Firebase not initialized', name: 'SettingsHelper');
      rethrow;
    }
  }

  RxBool biometrics = false.obs;
  RxBool twoFA = false.obs;
  RxBool giveaway = false.obs;
  RxBool promo = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadBiometricSetting();
    loadTwoFASetting();
    loadPromoSetting();
    loadGiveawaySetting();
  }

  @override
  void onReady() {
    super.onReady();
    loadBiometricSetting();
    loadTwoFASetting();
    loadPromoSetting();
    loadGiveawaySetting();
  }

  void loadBiometricSetting() {
    final storedValue = box.read('biometric_enabled') ?? true;
    if (storedValue is bool) {
      biometrics.value = storedValue;
    } else if (storedValue is String) {
      biometrics.value = storedValue.toLowerCase() == 'true';
    } else {
      biometrics.value = false;
    }
  }

  void loadTwoFASetting() {
    final storedValue = box.read('twofa_enabled');
    if (storedValue is bool) {
      twoFA.value = storedValue;
    } else if (storedValue is String) {
      twoFA.value = storedValue.toLowerCase() == 'true';
    } else {
      twoFA.value = false;
    }
  }

  void loadPromoSetting() {
    final storedValue = box.read('promo_enabled');
    if (storedValue is bool) {
      promo.value = storedValue;
    } else if (storedValue is String) {
      promo.value = storedValue.toLowerCase() == 'true';
    } else {
      promo.value = false;
    }
  }

  void loadGiveawaySetting() {
    final storedValue = box.read('giveaway_notification_enabled');
    if (storedValue is bool) {
      giveaway.value = storedValue;
    } else if (storedValue is String) {
      giveaway.value = storedValue.toLowerCase() == 'true';
    } else {
      giveaway.value = false;
    }
  }

  void savePromoSetting(bool value) {
    promo.value = value;
    box.write('promo_enabled', value);
  }

  void saveTwoFASetting(bool value) {
    twoFA.value = value;
    box.write('twofa_enabled', value);
  }

  Future<void> saveGiveawaySetting(bool value) async {
    try {
      if (value) {
        // Request notification permission first
        final settings = await firebaseMessaging.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );

        dev.log(
            'Notification permission status: ${settings.authorizationStatus}',
            name: 'Settings');

        if (settings.authorizationStatus == AuthorizationStatus.denied) {
          Get.snackbar(
            'Permission Denied',
            'Please enable notifications in your device settings',
            snackPosition: SnackPosition.TOP,
            duration: const Duration(seconds: 3),
            backgroundColor: AppColors.errorBgColor,
            colorText: AppColors.textSnackbarColor,
          );
          return;
        }

        if (settings.authorizationStatus != AuthorizationStatus.authorized &&
            settings.authorizationStatus != AuthorizationStatus.provisional) {
          Get.snackbar(
            'Permission Required',
            'Notification permission is required to receive giveaway notifications',
            snackPosition: SnackPosition.TOP,
            duration: const Duration(seconds: 3),
            backgroundColor: AppColors.errorBgColor,
            colorText: AppColors.textSnackbarColor,
          );
          return;
        }

        // Get FCM token
        final token = await firebaseMessaging.getToken();
        dev.log('FCM Token: $token', name: 'Settings');

        // Subscribe to giveaway topic
        await firebaseMessaging.subscribeToTopic('giveaway');
        dev.log('Subscribed to giveaway notifications', name: 'Settings');

        giveaway.value = value;
        box.write('giveaway_notification_enabled', value);

        Get.snackbar(
          'Notifications Enabled',
          'You will now receive giveaway notifications',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
          backgroundColor: AppColors.successBgColor,
          colorText: AppColors.textSnackbarColor,
        );
      } else {
        // Unsubscribe from giveaway topic
        await firebaseMessaging.unsubscribeFromTopic('giveaway');
        dev.log('Unsubscribed from giveaway notifications', name: 'Settings');

        Get.snackbar(
          'Notifications Disabled',
          'You will no longer receive giveaway notifications',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
          backgroundColor: AppColors.successBgColor,
          colorText: AppColors.textSnackbarColor,
        );
      }
    } catch (e) {
      dev.log('Error toggling giveaway notifications',
          error: e, name: 'Settings');
      // Revert the value if Firebase operation fails
      giveaway.value = !value;

      Get.snackbar(
        'Error',
        'Failed to update notification settings',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
      );
    }
  }
}
