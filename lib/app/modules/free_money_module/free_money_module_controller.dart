import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mcd/core/controllers/service_status_controller.dart';
import 'package:mcd/core/import/imports.dart';
import 'package:mcd/core/services/ads_service.dart';
import 'package:mcd/core/services/remote_config_service.dart';

class FreeMoneyModuleController extends GetxController {
  final adsService = AdsService();
  final box = GetStorage();

  final RxBool isWatchingAd = false.obs;
  final RxInt adsWatchedCount = 0.obs;

  final RxString userCountry = 'Nigeria'.obs;
  final RxString userCity = ''.obs;
  final RxString userIp = ''.obs;
  final RxBool isLocationLoading = false.obs;

  String get deviceName => Platform.isAndroid ? 'Android' : (Platform.isIOS ? 'iOS' : 'Mobile');

  @override
  void onInit() {
    super.onInit();
    refreshRemoteConfig();
    fetchUserLocation();
  }

  @override
  void onReady() {
    super.onReady();
    refreshRemoteConfig();
  }

  /// Fetch location info from https://myip.wtf/json
  Future<void> fetchUserLocation() async {
    try {
      isLocationLoading.value = true;
      dev.log('Fetching location from https://myip.wtf/json...', name: 'FreeMoney');

      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ));
      final response = await dio.get('https://myip.wtf/json');

      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> data = response.data is String
            ? jsonDecode(response.data)
            : Map<String, dynamic>.from(response.data);

        final country = data['YourFuckingCountry']?.toString() ??
            data['country']?.toString() ??
            'Nigeria';
        final city = data['YourFuckingCity']?.toString() ??
            data['city']?.toString() ??
            '';
        final ip = data['YourFuckingIPAddress']?.toString() ?? '';

        if (country.isNotEmpty) userCountry.value = country;
        if (city.isNotEmpty) userCity.value = city;
        if (ip.isNotEmpty) userIp.value = ip;

        dev.log('Location fetched: $country, $city (IP: $ip)', name: 'FreeMoney');
      }
    } catch (e) {
      dev.log('Error fetching location: $e', name: 'FreeMoney');
    } finally {
      isLocationLoading.value = false;
    }
  }

  Map<String, String> get adCustomData => {
        "username": currentUsername,
        "platform": "mobile",
        "type": "freemoney",
        "device": deviceName,
        "country": userCountry.value,
        "city": userCity.value,
        "ip": userIp.value,
      };

  /// Force fetch fresh Remote Config values from Firebase
  Future<void> refreshRemoteConfig() async {
    if (Get.isRegistered<RemoteConfigService>()) {
      dev.log('FreeMoneyModuleController refreshing Remote Config...', name: 'FreeMoney');
      await RemoteConfigService.to.forceRefresh();
    }
  }

  /// Get current user's username
  String get currentUsername =>
      box.read('biometric_username_real') ?? box.read('username') ?? '';

  /// Check if repeat/multiple ads is enabled for the current user
  bool get isShowRepeatEnabled {
    if (!Get.isRegistered<RemoteConfigService>()) return false;
    return RemoteConfigService.to.isShowRepeatEnabledForUser(currentUsername);
  }

  /// Get configured reward amount per video ad
  String get freeMoneyAmount {
    final amount = ServiceStatusController.to.getFreeMoneyAmount();
    if (amount != null && amount.isNotEmpty && amount != '0') {
      return amount;
    }
    if (Get.isRegistered<RemoteConfigService>()) {
      return RemoteConfigService.to.getString('free_money_amount', defaultValue: '10');
    }
    return '10';
  }

  /// Get target max ads count for multiple ads sequence
  int get maxAdsCount {
    if (Get.isRegistered<RemoteConfigService>()) {
      return RemoteConfigService.to.getInt('freemoney_max_ads', defaultValue: 10);
    }
    return 3;
  }

  /// Launch rewarded video ad sequence for Free Money (supports single or multiple ads)
  Future<void> watchAdAndEarn({BuildContext? context}) async {
    final ctx = context ?? Get.context;
    if (ctx != null) {
      await watchMultipleRewardedAds(ctx);
    } else {
      await watchSingleAd();
    }
  }

  /// Launch a single rewarded ad
  Future<void> watchSingleAd() async {
    if (isWatchingAd.value) return;

    try {
      isWatchingAd.value = true;
      dev.log('Starting Free Money single ad sequence', name: 'FreeMoney');

      final success = await adsService.showfreemoney(
        onRewarded: () {
          adsWatchedCount.value++;
          dev.log('User earned Free Money reward (Count: ${adsWatchedCount.value})', name: 'FreeMoney');

          // Show follow-up interstitial ad if configured
          adsService.showInterstitialAd(type: "freemoneyInterstitial");

          Get.snackbar(
            'Reward Earned! 🎉',
            'You earned ₦$freeMoneyAmount for watching the ad!',
            backgroundColor: AppColors.successBgColor,
            colorText: AppColors.textSnackbarColor,
            snackPosition: SnackPosition.TOP,
            duration: const Duration(seconds: 4),
          );

          // // Auto-repeat sequence if enabled in Remote Config
          // if (Get.isRegistered<RemoteConfigService>() &&
          //     RemoteConfigService.to.isServiceEnabled('ads_showrepeat')) {
          //   dev.log('Auto-repeat ads enabled, starting next ad', name: 'FreeMoney');
          //   watchSingleAd();
          // }
        },
        customData: adCustomData,
      );

      if (!success) {
        dev.log('Failed to launch Free Money ad', name: 'FreeMoney');
        Get.snackbar(
          'Ad Currently Unavailable',
          'No video ad is available right now. Please try again in a few moments.',
          backgroundColor: AppColors.errorBgColor,
          colorText: AppColors.textSnackbarColor,
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      dev.log('Error watching ad: $e', name: 'FreeMoney');
      Get.snackbar(
        'Error',
        'An error occurred while loading video ad. Please try again.',
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isWatchingAd.value = false;
    }
  }

  /// Launch multiple rewarded ads sequence
  Future<void> watchMultipleRewardedAds(BuildContext context, {int? maxAds}) async {
    if (isWatchingAd.value) return;

    final totalAds = maxAds ?? maxAdsCount;

    try {
      isWatchingAd.value = true;
      dev.log('Starting Free Money multiple ads sequence ($totalAds ads)', name: 'FreeMoney');

      adsService.showMultipleRewardedAds(
        context,
        maxAds: totalAds,
        adType: 'freemoney',
        reason: 'Free Money Reward',
        customData: adCustomData,
        onAdCompleted: () {
          adsWatchedCount.value += totalAds;
          dev.log('User completed $totalAds rewarded ads!', name: 'FreeMoney');

          // Show follow-up interstitial ad if configured
          adsService.showInterstitialAd(type: "freemoneyInterstitial");

          Get.snackbar(
            'Reward Earned! 🎉',
            'You completed $totalAds video ad(s) and earned ₦$freeMoneyAmount!',
            backgroundColor: AppColors.successBgColor,
            colorText: AppColors.textSnackbarColor,
            snackPosition: SnackPosition.TOP,
            duration: const Duration(seconds: 4),
          );

        },
        onAdFailed: (errorMsg) {
          dev.log('Multiple rewarded ads sequence failed: $errorMsg', name: 'FreeMoney');
          Get.snackbar(
            'Ad Session Interrupted',
            errorMsg,
            backgroundColor: AppColors.errorBgColor,
            colorText: AppColors.textSnackbarColor,
            snackPosition: SnackPosition.TOP,
            duration: const Duration(seconds: 4),
          );
        },
      );
    } catch (e) {
      dev.log('Error watching multiple ads: $e', name: 'FreeMoney');
      Get.snackbar(
        'Error',
        'An error occurred while loading video ads. Please try again.',
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isWatchingAd.value = false;
    }
  }
}
