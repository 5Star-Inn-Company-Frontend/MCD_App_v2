import 'dart:developer' as dev;
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mcd/core/import/imports.dart';
import 'package:mcd/core/network/dio_api_service.dart';
import 'package:mcd/core/services/ads_service.dart';

class PromoCodeController extends GetxController {
  final adsService = AdsService();
  final apiService = DioApiService();
  final box = GetStorage();

  final RxBool isLoading = false.obs;
  final RxString savedPromoCode = ''.obs;
  final RxString savedPromoMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadSavedPromoCode();
  }

  /// Load cached promo code from local storage
  void loadSavedPromoCode() {
    final code = box.read('saved_promo_code')?.toString() ?? '';
    final message = box.read('saved_promo_message')?.toString() ?? '';
    savedPromoCode.value = code;
    savedPromoMessage.value = message;
    dev.log('Loaded saved promo code: $code', name: 'PromoCode');
  }

  /// Copy saved promo code to clipboard
  void copyPromoCode() {
    if (savedPromoCode.value.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: savedPromoCode.value));
      Get.snackbar(
        'Copied!',
        'Promo code copied to clipboard',
        backgroundColor: AppColors.successBgColor,
        colorText: AppColors.textSnackbarColor,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    }
  }

  /// Clear saved promo code from cache
  void clearSavedCode() {
    box.remove('saved_promo_code');
    box.remove('saved_promo_message');
    savedPromoCode.value = '';
    savedPromoMessage.value = '';
    Get.snackbar(
      'Cleared',
      'Saved promo code removed',
      backgroundColor: AppColors.primaryColor,
      colorText: AppColors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
    );
  }

  /// Launch rewarded video ad to attempt winning a promo code
  Future<void> tryWinPromoCode() async {
    if (isLoading.value) return;

    dev.log('Showing ad for promo code', name: 'PromoCode');

    final success = await adsService.showRewardedAd(
      onRewarded: () async {
        dev.log('User watched ad for promo code', name: 'PromoCode');
        await _fetchPromoCode();
      },
      customData: {
        "username": box.read('username') ?? "",
        "platform": "mobile",
        "type": "promo_code"
      },
    );

    if (!success) {
      dev.log('Failed to show ad for promo code', name: 'PromoCode');
      Get.snackbar(
        'Ad Not Available',
        'No ad available at the moment. Please try again later.',
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  /// Fetch promo code from API after ad completion
  Future<void> _fetchPromoCode() async {
    try {
      isLoading.value = true;
      final utilityUrl = box.read('utility_service_url');

      if (utilityUrl == null || utilityUrl.isEmpty) {
        Get.snackbar(
          'Error',
          'Service URL not found. Please login again.',
          backgroundColor: AppColors.errorBgColor,
          colorText: AppColors.textSnackbarColor,
          snackPosition: SnackPosition.TOP,
        );
        isLoading.value = false;
        return;
      }

      Get.dialog(
        const Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryColor,
          ),
        ),
        barrierDismissible: false,
      );

      final url = '${utilityUrl}promocode';
      dev.log('Fetching promo code from: $url', name: 'PromoCode');

      final result = await apiService.getrequest(url);

      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      result.fold(
        (failure) {
          dev.log('Failed to fetch promo code: ${failure.message}', name: 'PromoCode');
          isLoading.value = false;
          _showTryAgainDialog();
        },
        (data) {
          dev.log('Promo code response: $data', name: 'PromoCode');
          isLoading.value = false;

          final success = data['success'];
          final promoCode = data['data'];
          final message = data['message'] ?? '';

          if (success == 1 &&
              promoCode != null &&
              promoCode.toString().isNotEmpty) {
            box.write('saved_promo_code', promoCode.toString());
            box.write('saved_promo_message', message);
            savedPromoCode.value = promoCode.toString();
            savedPromoMessage.value = message;
            dev.log('Promo code saved: $promoCode', name: 'PromoCode');

            _showPromoCodeSuccessDialog(promoCode.toString(), message);
          } else {
            _showTryAgainDialog(message: message);
          }
        },
      );
    } catch (e) {
      dev.log('Exception fetching promo code: $e', name: 'PromoCode');
      isLoading.value = false;

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
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.card_giftcard,
                  size: 40,
                  color: AppColors.primaryColor,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Congratulations!',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                  fontFamily: AppFonts.manRope,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
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
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primaryColor,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Your Promo Code',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontFamily: AppFonts.manRope,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            promoCode,
                            style: const TextStyle(
                              fontSize: 20,
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
                          onPressed: copyPromoCode,
                          icon: const Icon(Icons.copy, color: AppColors.primaryColor),
                          tooltip: 'Copy code',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
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
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppColors.primaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
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
