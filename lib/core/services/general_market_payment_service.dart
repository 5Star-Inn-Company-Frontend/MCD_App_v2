import 'dart:async';
import 'dart:developer' as dev;

import 'package:mcd/core/import/imports.dart';
import 'package:mcd/core/services/ads_service.dart';

class GeneralMarketPaymentService {
  static final GeneralMarketPaymentService _instance =
      GeneralMarketPaymentService._internal();
  factory GeneralMarketPaymentService() => _instance;
  GeneralMarketPaymentService._internal();

  final AdsService _adsService = AdsService();
  static const int minimumGMBalance = 300;
  static const int requiredAdsCount = 2;

  bool _isProcessingPayment = false;
  bool get isProcessingPayment => _isProcessingPayment;

  void forceCancelPayment() {
    _isProcessingPayment = false;
    _adsService.forceResetAdState();
    dev.log('Force cancelled GM Payment and reset ad state.');
  }

  Future<bool> processGeneralMarketPayment({
    required double amount,
    required double currentGMBalance,
    required Function() onPaymentSuccess,
    required Function(String) onPaymentFailed,
  }) async {
    if (_isProcessingPayment) {
      if (!_adsService.isCurrentlyShowingAds()) {
        dev.log('Recovering from stuck payment state: ads are not actually showing');
        _isProcessingPayment = false;
      } else {
        dev.log('Error: Payment already in progress');
        onPaymentFailed('Payment already in progress. Please wait.');
        return false;
      }
    }

    if (currentGMBalance < minimumGMBalance) {
      onPaymentFailed(
          'Insufficient General Market balance. Minimum balance required is ₦$minimumGMBalance');
      dev.log('Error: Insufficient GM balance');
      return false;
    }

    if (amount > currentGMBalance) {
      onPaymentFailed(
          'Insufficient General Market balance for this transaction');
      dev.log('Error: Amount exceeds GM balance');
      return false;
    }

    final shouldProceed = await _showGMPaymentDialog();
    if (!shouldProceed) {
      dev.log('User cancelled GM payment');
      return false;
    }

    _isProcessingPayment = true;

    bool _adWasClicked = false;

    _adsService.showMultipleRewardedAds(
      Get.context!,
      maxAds: requiredAdsCount,
      onAdCompleted: () async {
        if (_adWasClicked) return;
        dev.log('Ad finished without click, denying GM payment');
        _isProcessingPayment = false;
        // onPaymentFailed('You need to click on the advert to use General Market');
        await onPaymentSuccess();
      },
      onAdFailed: (error) {
        dev.log('Failed: Ad sequence aborted or failed');
        _isProcessingPayment = false;
        onPaymentFailed(error);
      },
      reason: "Use general Market with 1 ad session",
      onAdClicked: () async {
        if (_adWasClicked) return;
        _adWasClicked = true;
        dev.log('Success: ad clicked, processing payment');
        _isProcessingPayment = false;
      }
    );

    return true;

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
                'Watch Ad to Pay with General Market',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'To complete this purchase using General Market, you need to watch and click on $requiredAdsCount short ad.',
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
                    child: BusyButton(
                      onTap: () {
                        Get.back();
                        completer.complete(true);
                      },
                      title: 'Proceed',
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


  // void _showAdProgressDialog(int completed, int total) {
  //   Get.dialog(
  //     Dialog(
  //       backgroundColor: Colors.white,
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(20),
  //       ),
  //       child: Padding(
  //         padding: const EdgeInsets.all(24),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             CircularProgressIndicator(
  //               color: AppColors.primaryColor,
  //             ),
  //             const SizedBox(height: 20),
  //             Text(
  //               'Watching Ads...',
  //               style: TextStyle(
  //                   fontSize: 18,
  //                   fontWeight: FontWeight.w600,
  //                   color: Colors.black87,
  //                   fontFamily: AppFonts.manRope),
  //             ),
  //             const SizedBox(height: 12),
  //             Text(
  //               'Ad $completed of $total',
  //               style: TextStyle(
  //                   fontSize: 14,
  //                   color: Colors.grey.shade600,
  //                   fontFamily: AppFonts.manRope),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //     barrierDismissible: false,
  //   );
  // }

  static bool canUseGeneralMarket(double gmBalance) {
    return gmBalance >= minimumGMBalance;
  }

  static String getMinimumBalanceErrorMessage() {
    return 'Minimum General Market balance of ₦$minimumGMBalance required to use this payment method';
  }

  static void showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'General Market',
                style: TextStyle(
                  fontFamily: 'plusJakartaSans',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'General Market gets funded by buying data and using free money.\n\n'
                'The fund is available to everyone for use but subject to terms and conditions.\n\n'
                '1. You must have bought data at least twice on that day.\n\n'
                '2. Kindly visit Reward Centre and create at least 2 GiveAways.\n\n'
                '3. On checkout with General Market option, an advertisement will be displayed. You must click on the advert before your request will be processed.\n\n'
                '4. In case someone checks out before you, your request will not be served.\n\n'
                '5. The minimum balance is ₦300.\n\n'
                '6. You must be clicking on free money once in a while to keep General Market active.',
                style: TextStyle(
                  fontFamily: 'ManRope',
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        'OK',
                        style: TextStyle(
                          fontFamily: 'plusJakartaSans',
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryColor,
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
