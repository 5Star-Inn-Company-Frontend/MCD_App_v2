import 'dart:convert';
import 'dart:developer' as dev;

import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mcd/core/import/imports.dart';
import 'package:mcd/core/network/dio_api_service.dart';
import 'package:mcd/core/services/ads_service.dart';

class RewardCentreModuleController extends GetxController {
  final adsService = AdsService();
  final isPromoLoading = false.obs;

  final _service = {}.obs;
  set service(value) => _service.value = value;
  get service => _service.value;

  final box = GetStorage();
  final apiService = DioApiService();

  @override
  void onInit() {
    super.onInit();
    fetchservicestatus();
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<void> fetchservicestatus() async {
    var storageresult = box.read('serviceenablingdata');
    print("storageresult ${storageresult}");
    if (storageresult != null) {
      var data = jsonDecode(storageresult);
      if (data != null) {
        service = data;
      }
    }
    print("storageresult done");
    final transactionUrl = box.read('transaction_service_url');
    if (transactionUrl == null) {
      dev.log('Transaction URL not found',
          name: 'HomeScreen', error: 'URL missing');
      return;
    }

    final result = await apiService.getrequest('${transactionUrl}services');

    result.fold(
      (failure) {
        dev.log('GM balance fetch failed: ${failure.message}',
            name: 'HomeScreen');
      },
      (data) async {
        dev.log('GM balance response: ${data['data']}', name: 'HomeScreen');
        await box.write('serviceenablingdata', jsonEncode(data['data']));
        if (data['data']['services'] != null) {
          service = data['data']['services'];
        }
      },
    );
  }

  Future<void> showRewardedAd() async {
    dev.log('Showing rewarded ad', name: 'RewardCentre');

    final success = await adsService.showRewardedAd(
      onRewarded: () {
        dev.log('User earned reward', name: 'RewardCentre');
        Get.snackbar(
          'Reward Earned!',
          'You have been rewarded!',
          backgroundColor: AppColors.successBgColor,
          colorText: AppColors.textSnackbarColor,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );
      },
      customData: {
        "username": box.read('username') ?? "",
        "platform": "mobile",
        "type": "reward_centre"
      },
    );

    if (!success) {
      dev.log('Failed to show rewarded ad', name: 'RewardCentre');
      Get.snackbar(
        'Ad Not Available',
        'No ad available at the moment. Please try again later.',
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  Future<void> freemoney() async {
    dev.log('Showing rewarded ad', name: 'RewardCentre');

    final success = await adsService.showfreemoney(
      onRewarded: () {
        dev.log('User earned reward', name: 'RewardCentre');
        Get.snackbar(
          'Reward Earned!',
          'You have been rewarded!',
          backgroundColor: AppColors.successBgColor,
          colorText: AppColors.textSnackbarColor,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );
      },
      customData: {
        "username": box.read('biometric_username_real') ?? "",
        "platform": "mobile",
        "type": "reward_centre"
      },
    );

    if (!success) {
      dev.log('Failed to show rewarded ad', name: 'RewardCentre');
      Get.snackbar(
        'Ad Not Available',
        'No ad available at the moment. Please try again later.',
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  Future<void> tryWinPromoCode() async {
    dev.log('Showing ad for promo code', name: 'RewardCentre');

    final success = await adsService.showRewardedAd(
      onRewarded: () async {
        dev.log('User watched ad for promo code', name: 'RewardCentre');
        await _fetchPromoCode();
      },
      customData: {
        "username": box.read('username') ?? "",
        "platform": "mobile",
        "type": "promo_code"
      },
    );

    if (!success) {
      dev.log('Failed to show ad for promo code', name: 'RewardCentre');
      Get.snackbar(
        'Ad Not Available',
        'No ad available at the moment. Please try again later.',
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  Future<void> _fetchPromoCode() async {
    try {
      isPromoLoading.value = true;
      final utilityUrl = box.read('utility_service_url');

      if (utilityUrl == null || utilityUrl.isEmpty) {
        Get.snackbar(
          'Error',
          'Service URL not found. Please login again.',
          backgroundColor: AppColors.errorBgColor,
          colorText: AppColors.textSnackbarColor,
          snackPosition: SnackPosition.TOP,
        );
        isPromoLoading.value = false;
        return;
      }

      // Show loading dialog
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryColor,
          ),
        ),
        barrierDismissible: false,
      );

      final url = '${utilityUrl}promocode';
      dev.log('Fetching promo code from: $url', name: 'RewardCentre');

      final result = await apiService.getrequest(url);

      // Close loading dialog
      Get.back();

      result.fold(
        (failure) {
          dev.log('Failed to fetch promo code: ${failure.message}',
              name: 'RewardCentre');
          isPromoLoading.value = false;

          // Show dialog to try again
          _showTryAgainDialog();
        },
        (data) {
          dev.log('Promo code response: ${data.toString()}',
              name: 'RewardCentre');
          isPromoLoading.value = false;

          // Check if user won promo code
          final success = data['success'];
          final promoCode = data['data']; // Changed from 'promo_code' to 'data'
          final message = data['message'] ?? '';

          if (success == 1 &&
              promoCode != null &&
              promoCode.toString().isNotEmpty) {
            // User won promo code - save to cache
            box.write('saved_promo_code', promoCode.toString());
            box.write('saved_promo_message', message);
            dev.log('Promo code saved to cache: $promoCode',
                name: 'RewardCentre');

            _showPromoCodeSuccessDialog(promoCode.toString(), message);
          } else {
            // User didn't win, show try again dialog
            _showTryAgainDialog(message: message);
          }
        },
      );
    } catch (e) {
      dev.log('Exception fetching promo code: $e', name: 'RewardCentre');
      isPromoLoading.value = false;

      // Close loading dialog if it's still open (in case of error before result.fold)
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      Get.snackbar(
        'Error',
        'An unexpected error occurred. Please try again.',
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  void _showPromoCodeSuccessDialog(String promoCode, String message) {
    Get.dialog(
      barrierDismissible: false,
      Dialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.card_giftcard,
                  size: 40,
                  color: AppColors.primaryColor,
                ),
              ),
              const SizedBox(height: 20),
              // Title
              Text(
                'Congratulations!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                  fontFamily: AppFonts.manRope,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              // Message
              if (message.isNotEmpty)
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontFamily: AppFonts.manRope,
                  ),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 20),
              // Promo code display with copy button
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primaryColor,
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Your Promo Code',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontFamily: AppFonts.manRope,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            promoCode,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryColor,
                              letterSpacing: 1,
                              fontFamily: AppFonts.manRope,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: promoCode));
                            Get.snackbar(
                              'Copied!',
                              'Promo code copied to clipboard',
                              backgroundColor: AppColors.successBgColor,
                              colorText: AppColors.textSnackbarColor,
                              duration: const Duration(seconds: 2),
                              snackPosition: SnackPosition.TOP,
                            );
                          },
                          icon: const Icon(Icons.copy,
                              color: AppColors.primaryColor),
                          tooltip: 'Copy code',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Close button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontFamily: AppFonts.manRope,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTryAgainDialog({String? message}) {
    Get.dialog(
      barrierDismissible: false,
      Dialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.refresh,
                  size: 40,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 20),
              // Title
              const Text(
                'Better Luck Next Time!',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontFamily: AppFonts.manRope),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              // Message
              Text(
                message ??
                    'You didn\'t win this time. Watch more advertisements to increase your chances of winning a promo code!',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontFamily: AppFonts.manRope,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: AppColors.primaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryColor,
                          fontFamily: AppFonts.manRope,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        tryWinPromoCode();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Try Again',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          fontFamily: AppFonts.manRope,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
