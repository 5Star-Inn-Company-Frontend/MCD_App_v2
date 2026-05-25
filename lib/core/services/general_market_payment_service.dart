import 'dart:async';
import 'dart:developer' as dev;

import 'package:google_fonts/google_fonts.dart';
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
        dev.log(
            'Recovering from stuck payment state: ads are not actually showing');
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

    _adsService.showMultipleRewardedAds(Get.context!,
        maxAds: requiredAdsCount,
        onAdCompleted: () async {
          dev.log('Ad sequence completed, processing GM payment');
          _isProcessingPayment = false;
          await onPaymentSuccess();
        },
        onAdFailed: (error) {
          dev.log('Failed: Ad sequence aborted or failed');
          _isProcessingPayment = false;
          onPaymentFailed(error);
        },
        reason: "Use general Market with 1 ad session",
        onAdClicked: () {
          // ad clicked
          dev.log('Ad clicked');
        });

    return true;
  }

  Future<bool> _showGMPaymentDialog() async {
    final completer = Completer<bool>();

    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // icon header container
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.play_circle_filled_rounded,
                  size: 40,
                  color: AppColors.primaryColor,
                ),
              ),
              const SizedBox(height: 16),

              // title
              Text(
                'Watch Ad to Pay',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // badge
              // Container(
              //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              //   decoration: BoxDecoration(
              //     color: AppColors.primaryColor.withOpacity(0.08),
              //     borderRadius: BorderRadius.circular(100),
              //   ),
              //   child: Text(
              //     'General Market Option',
              //     style: GoogleFonts.plusJakartaSans(
              //       fontSize: 11,
              //       fontWeight: FontWeight.w600,
              //       color: AppColors.primaryColor,
              //     ),
              //   ),
              // ),
              // const SizedBox(height: 16),

              // description
              Text(
                'To complete this purchase using General Market, you need to watch $requiredAdsCount short ads completely.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // rules container
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.check_circle_outline_rounded,
                            size: 16, color: AppColors.primaryColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Watch $requiredAdsCount ads completely without skipping.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.check_circle_outline_rounded,
                            size: 16, color: AppColors.primaryColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Transaction fulfills automatically on completion.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // buttons
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
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Get.back();
                        completer.complete(true);
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Proceed',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
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
                '3. On checkout with General Market option, advertisements will be displayed. You must watch the advertisements completely before your request will be processed.\n\n'
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
