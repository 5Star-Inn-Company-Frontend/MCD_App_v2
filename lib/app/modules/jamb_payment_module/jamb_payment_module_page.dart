import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mcd/app/styles/app_colors.dart';
import 'package:mcd/app/styles/fonts.dart';
import 'package:mcd/app/widgets/app_bar-two.dart';
import 'package:mcd/app/widgets/busy_button.dart';
import 'package:mcd/core/constants/textField.dart';
import 'package:mcd/core/utils/ui_helpers.dart';
import './jamb_payment_module_controller.dart';

class JambPaymentModulePage extends GetView<JambPaymentModuleController> {
  const JambPaymentModulePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PaylonyAppBarTwo(
        title: "Verify Account",
        elevation: 0,
        centerTitle: false,
        actions: [],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Column(
                children: [
                  _buildInfoRow("Service", "Exam Result"),
                  const Gap(12),
                  _buildInfoRow("Exam Type", controller.examName),
                  const Gap(12),
                  _buildInfoRow("Amount", "₦${controller.amount}"),
                  const Gap(12),
                  _buildInfoRow("ATM/Wallet",
                      "${controller.atmFee.toStringAsFixed(2)}/₦${controller.walletFee.toStringAsFixed(2)}"),
                  const Gap(12),
                  _buildInfoRow(
                    "Total Due",
                    "₦${controller.totalDue.toStringAsFixed(2)}",
                    valueColor: const Color(0xffFF9F9F),
                  ),
                ],
              ),
            ),

            const Gap(30),

            TextSemiBold(
              "Recipient",
              fontSize: 14,
            ),
            const Gap(8),
            TextFormField(
              controller: controller.recipientController,
              keyboardType: TextInputType.phone,
              decoration: textInputDecoration.copyWith(
                filled: true,
                fillColor: const Color(0xffFFFFFF),
                hintText: "0123456789",
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade100)),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade100)),
              ),
            ),
            const Gap(10),
            Align(
              alignment: Alignment.centerLeft,
              child: TextSemiBold(
                "Account Name: User Name",
                fontSize: 13,
                color: AppColors.primaryGrey2,
              ),
            ),

            const Gap(20),
            // Payment Method Selection
            Builder(
              builder: (context) => InkWell(
                onTap: () => _showPaymentMethodBottomSheet(context),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primaryColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextSemiBold(
                        'Payment Method:',
                        fontSize: 14,
                        color: AppColors.primaryGrey2,
                      ),
                      Row(
                        children: [
                          Obx(() => TextSemiBold(
                                _getPaymentMethodLabel(
                                    controller.selectedPaymentMethod.value),
                                fontSize: 14,
                                color: AppColors.primaryColor,
                              )),
                          const Gap(8),
                          Icon(
                            Icons.arrow_drop_down,
                            color: AppColors.primaryColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Gap(130),
            Center(
              child: Obx(() => BusyButton(
                    width: screenWidth(context) * 0.6,
                    title: "Pay",
                    onTap: controller.pay,
                    disabled: controller.isPaying.value,
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextSemiBold(
          label,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.background,
        ),
        TextSemiBold(
          value,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: valueColor ?? AppColors.background,
        ),
      ],
    );
  }

  String _getPaymentMethodLabel(String method) {
    switch (method) {
      case 'wallet':
        return 'Wallet';
      case 'paystack':
        return 'Paystack';
      case 'pay_gm':
        return 'General Market';
      case 'mega_bonus':
        return 'Mega Bonus';
      default:
        return 'Wallet';
    }
  }

  void _showPaymentMethodBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextSemiBold(
              'Select Payment Method',
              fontSize: 18,
              color: AppColors.primaryColor,
            ),
            const Gap(20),
            _paymentMethodTile(
                'wallet', 'Wallet', Icons.account_balance_wallet, context),
            _paymentMethodTile('paystack', 'Paystack', Icons.payment, context),
            _paymentMethodTile(
                'general_market', 'General Market', Icons.store, context),
            _paymentMethodTile(
                'mega_bonus', 'Mega Bonus', Icons.card_giftcard, context),
            const Gap(10),
          ],
        ),
      ),
    );
  }

  Widget _paymentMethodTile(
      String value, String label, IconData icon, BuildContext context) {
    return Obx(() {
      final isSelected = controller.selectedPaymentMethod.value == value;
      return InkWell(
        onTap: () {
          controller.setPaymentMethod(value);
          Navigator.pop(context);
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? AppColors.primaryColor : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
            color: isSelected
                ? AppColors.primaryColor.withOpacity(0.1)
                : Colors.transparent,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.primaryColor : Colors.grey,
              ),
              const Gap(12),
              Expanded(
                child: TextSemiBold(
                  label,
                  fontSize: 16,
                  color: isSelected ? AppColors.primaryColor : Colors.black87,
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: AppColors.primaryColor,
                ),
            ],
          ),
        ),
      );
    });
  }
}
