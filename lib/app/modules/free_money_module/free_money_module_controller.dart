import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';
import 'package:advert/advert.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mcd/app/modules/more_module/more_module_page.dart';
import 'package:mcd/app/widgets/pulsing_shimmer_card.dart';
import 'package:mcd/core/controllers/service_status_controller.dart';
import 'package:mcd/core/import/imports.dart';
import 'package:mcd/core/network/dio_api_service.dart';
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
        "country": userCountry.value.isNotEmpty ? userCountry.value : "Nigeria",
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

  /// Call Free Money endpoint: https://utility.mcd.5starcompany.com.ng/api/v1/freemoney_new
  Future<void> claimFreeMoneyApi() async {
    try {
      String utilityUrl = box.read('utility_service_url') ?? 'https://utility.mcd.5starcompany.com.ng/api/v1/';
      if (!utilityUrl.endsWith('/')) {
        utilityUrl = '$utilityUrl/';
      }
      final url = '${utilityUrl}freemoney_new';

      dev.log('Calling Free Money API endpoint: $url', name: 'FreeMoney');

      final body = {
        "username": currentUsername,
        "device": deviceName,
        "country": userCountry.value.isNotEmpty ? userCountry.value : "Nigeria",
        "city": userCity.value,
        "ip": userIp.value,
      };

      final result = await DioApiService().postrequest(url, body);
      result.fold(
        (failure) async {
          dev.log('POST freemoney_new failed: ${failure.message}, trying GET fallback...', name: 'FreeMoney');
          final getResult = await DioApiService().getrequest(url);
          getResult.fold(
            (fail) => dev.log('GET freemoney_new failed: ${fail.message}', name: 'FreeMoney'),
            (data) => dev.log('GET freemoney_new success: $data', name: 'FreeMoney'),
          );
        },
        (data) {
          dev.log('POST freemoney_new success: $data', name: 'FreeMoney');
        },
      );
    } catch (e) {
      dev.log('Error calling freemoney_new API: $e', name: 'FreeMoney');
    }
  }

  /// Launch a single rewarded ad
  Future<void> watchSingleAd() async {
    if (isWatchingAd.value) return;

    try {
      isWatchingAd.value = true;
      dev.log('Starting Free Money single ad sequence', name: 'FreeMoney');

      final success = await adsService.showfreemoney(
        onRewarded: (String? provider) async {
          adsWatchedCount.value++;
          dev.log('User earned Free Money reward (Count: ${adsWatchedCount.value})', name: 'FreeMoney');

          if(provider == "Unity") {
            await claimFreeMoneyApi();
          }

          adsService.showInterstitialAd(type: "freemoneyInterstitial");

          showRewardEarnedDialog(amountEarned: freeMoneyAmount);
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
        onAdCompleted: () async {
          // adsWatchedCount.value += totalAds;
          dev.log('User completed $totalAds rewarded ads!', name: 'FreeMoney');

          adsService.showInterstitialAd(type: "freemoneyInterstitial");

          showRewardEarnedDialog(amountEarned: freeMoneyAmount);
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
        onAdWatched: (Advertresponse response) async {
          adsWatchedCount.value++;
          dev.log('User earned Free Money reward (Count: ${adsWatchedCount.value})', name: 'FreeMoney');
        if (response.provider == "Unity"){
          claimFreeMoneyApi();
        }
          dev.log('Individual ad watched in sequence: ${response.message}', name: 'FreeMoney');
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

  void showRewardEarnedDialog({required String amountEarned}) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: AppColors.white,
        child: Padding(
          padding: const EdgeInsets.all(22.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFBBF7D0), width: 2),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.primaryColor,
                  size: 36,
                ),
              ),
              const Gap(14),
              TextBold(
                'Reward Earned!',
                fontSize: 19,
                color: AppColors.background,
              ),
              const Gap(6),
              Text(
                '₦$amountEarned has been added to your wallet balance.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: AppFonts.manRope,
                  fontSize: 13.5,
                  color: AppColors.primaryGrey2,
                ),
              ),
              const Gap(18),
              PulsingShimmerCard(
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFFCD34D)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: TextBold(
                          '2X REWARD',
                          fontSize: 10,
                          color: AppColors.white,
                        ),
                      ),
                      const Gap(8),
                      TextSemiBold(
                        'Upgrade to any paid plan to enjoy x2 anytime you earn.',
                        textAlign: TextAlign.center,
                        fontSize: 12.5,
                        color: const Color(0xFF92400E),
                      ),
                      const Gap(12),
                      SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () {
                            Get.back();
                            MoreModulePage.navigateToSubscriptions();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD97706),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.flash_on_rounded, color: AppColors.white, size: 16),
                              const Gap(4),
                              TextBold(
                                'Upgrade for 2X',
                                fontSize: 13.5,
                                color: AppColors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Gap(12),
              SizedBox(
                width: double.infinity,
                height: 38,
                child: TextButton(
                  onPressed: () => Get.back(),
                  child: TextSemiBold(
                    'Claim & Continue',
                    fontSize: 13.5,
                    color: AppColors.primaryGrey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }
}
