import 'dart:developer' as dev;
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

  /// Launch rewarded video ad sequence for Free Money
  Future<void> watchAdAndEarn() async {
    if (isWatchingAd.value) return;

    try {
      isWatchingAd.value = true;
      dev.log('Starting Free Money ad sequence', name: 'FreeMoney');

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

          // Auto-repeat sequence if enabled in Remote Config
          if (Get.isRegistered<RemoteConfigService>() &&
              RemoteConfigService.to.isServiceEnabled('ads_showrepeat')) {
            dev.log('Auto-repeat ads enabled, starting next ad', name: 'FreeMoney');
            watchAdAndEarn();
          }
        },
        customData: {
          "username": box.read('biometric_username_real') ?? box.read('username') ?? "",
          "platform": "mobile",
          "type": "freemoney"
        },
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
}
