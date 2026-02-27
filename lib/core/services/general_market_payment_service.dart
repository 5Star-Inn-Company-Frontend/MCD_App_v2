import 'dart:async';
import 'package:mcd/core/import/imports.dart';
import 'package:mcd/core/services/ads_service.dart';
import 'dart:developer' as dev;

class GeneralMarketPaymentService {
  static final GeneralMarketPaymentService _instance = GeneralMarketPaymentService._internal();
  factory GeneralMarketPaymentService() => _instance;
  GeneralMarketPaymentService._internal();

  final AdsService _adsService = AdsService();
  static const int minimumGMBalance = 300;
  static const int requiredAdsCount = 3;

  bool _isProcessingPayment = false;
  bool get isProcessingPayment => _isProcessingPayment;

  Future<bool> processGeneralMarketPayment({
    required double amount,
    required double currentGMBalance,
    required Function() onPaymentSuccess,
    required Function(String) onPaymentFailed,
  }) async {
    if (_isProcessingPayment) {
      dev.log('Error: Payment already in progress');
      return false;
    }

    if (currentGMBalance < minimumGMBalance) {
      onPaymentFailed('Insufficient General Market balance. Minimum balance required is ₦$minimumGMBalance');
      dev.log('Error: Insufficient GM balance');
      return false;
    }

    if (amount > currentGMBalance) {
      onPaymentFailed('Insufficient General Market balance for this transaction');
      dev.log('Error: Amount exceeds GM balance');
      return false;
    }

    final shouldProceed = await _showGMPaymentDialog();
    if (!shouldProceed) {
      dev.log('User cancelled GM payment');
      return false;
    }

    _isProcessingPayment = true;

    final adsCompleted = await _playRequiredAds();

    _isProcessingPayment = false;

    if (adsCompleted) {
      dev.log('Success: All ads watched, processing payment');
      onPaymentSuccess();
      return true;
    } else {
      onPaymentFailed('You need to watch all $requiredAdsCount ads to complete payment with General Market');
      dev.log('Error: Not all ads were watched');
      return false;
    }
  }

  Future<bool> _showGMPaymentDialog() async {
    final completer = Completer<bool>();

    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.play_circle_outline,
                size: 64,
                color: AppColors.primaryColor,
              ),
              const SizedBox(height: 20),
              Text(
                'Watch Ads to Pay with General Market',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'To complete this purchase using General Market, you need to watch $requiredAdsCount short ads.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Get.back();
                        completer.complete(false);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        completer.complete(true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0
                      ),
                      child: Text(
                        'Proceed',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
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
      barrierDismissible: false,
    );

    return completer.future;
  }

  Future<bool> _playRequiredAds() async {
    int completedAds = 0;

    _showAdProgressDialog(0, requiredAdsCount);

    final allAdsWatched = await _adsService.showMultipleRewardedAds(
      maxAds: requiredAdsCount,
      onAdCompleted: (count) {
        completedAds = count;
        _updateAdProgressDialog(count, requiredAdsCount);
      },
    );

    Get.back();

    return allAdsWatched;
  }

  void _showAdProgressDialog(int completed, int total) {
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  color: AppColors.primaryColor,
                ),
                const SizedBox(height: 20),
                Text(
                  'Watching Ads...',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    fontFamily: AppFonts.manRope
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Ad $completed of $total',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600, fontFamily: AppFonts.manRope
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _updateAdProgressDialog(int completed, int total) {
    if (Get.isDialogOpen == true) {
      Get.back();
      _showAdProgressDialog(completed, total);
    }
  }

  static bool canUseGeneralMarket(double gmBalance) {
    return gmBalance >= minimumGMBalance;
  }

  static String getMinimumBalanceErrorMessage() {
    return 'Minimum General Market balance of ₦$minimumGMBalance required to use this payment method';
  }
}
