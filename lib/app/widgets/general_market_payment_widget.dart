import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mcd/app/styles/app_colors.dart';
import 'package:mcd/app/styles/fonts.dart';
import 'package:mcd/core/services/general_market_payment_service.dart';
import 'package:mcd/core/utils/amount_formatter.dart';

class GeneralMarketPaymentWidget extends StatelessWidget {
  final double amount;
  final double gmBalance;
  final VoidCallback onPaymentSuccess;
  final Function(String) onPaymentFailed;
  final String title;
  final String description;

  const GeneralMarketPaymentWidget({
    super.key,
    required this.amount,
    required this.gmBalance,
    required this.onPaymentSuccess,
    required this.onPaymentFailed,
    this.title = 'Pay with General Market',
    this.description = 'Use your General Market balance to complete this purchase',
  });

  @override
  Widget build(BuildContext context) {
    final canUseGM = GeneralMarketPaymentService.canUseGeneralMarket(gmBalance);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: canUseGM ? AppColors.primaryColor : Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet,
                color: canUseGM ? AppColors.primaryColor : Colors.grey.shade400,
                size: 24,
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextSemiBold(
                      title,
                      fontSize: 16,
                      color: canUseGM ? Colors.black87 : Colors.grey.shade600,
                    ),
                    const Gap(4),
                    TextSemiBold(
                      description,
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: canUseGM 
                  ? AppColors.primaryColor.withOpacity(0.1) 
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextSemiBold(
                  'Available Balance:',
                  fontSize: 14,
                  color: Colors.black87,
                ),
                Text(
                  '₦${AmountUtil.formatFigure(gmBalance)}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: canUseGM ? AppColors.primaryColor : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          if (!canUseGM) ...[
            const Gap(8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.red.shade700,
                    size: 16,
                  ),
                  const Gap(8),
                  Expanded(
                    child: TextSemiBold(
                      GeneralMarketPaymentService.getMinimumBalanceErrorMessage(),
                      fontSize: 12,
                      color: Colors.red.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (canUseGM) ...[
            const Gap(8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.play_circle_outline,
                    color: Colors.blue.shade700,
                    size: 16,
                  ),
                  const Gap(8),
                  Expanded(
                    child: TextSemiBold(
                      'Watch 3 short ads to complete payment',
                      fontSize: 12,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const Gap(16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: canUseGM ? _handlePayment : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                disabledBackgroundColor: Colors.grey.shade300,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                'Pay ₦${AmountUtil.formatFigure(amount)}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handlePayment() async {
    final gmPaymentService = GeneralMarketPaymentService();

    await gmPaymentService.processGeneralMarketPayment(
      amount: amount,
      currentGMBalance: gmBalance,
      onPaymentSuccess: onPaymentSuccess,
      onPaymentFailed: onPaymentFailed,
    );
  }
}
