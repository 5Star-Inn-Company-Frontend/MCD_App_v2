import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mcd/app/modules/card_topup_module/card_topup_module_controller.dart';
import 'package:mcd/app/styles/app_colors.dart';
import 'package:mcd/app/styles/fonts.dart';
import 'package:mcd/app/widgets/app_bar-two.dart';
import 'package:mcd/core/constants/fonts.dart';

class CardTopupAmountPage extends GetView<CardTopupModuleController> {
  const CardTopupAmountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const PaylonyAppBarTwo(
        title: 'Fund Wallet',
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextSemiBold(
                    'Enter Amount',
                    fontSize: 16,
                    color: AppColors.background.withOpacity(0.7),
                  ),
                  const Gap(20),
                  // Amount Display
                  Obx(() => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Text(
                          '₦ ${controller.formattedAmount}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )),
                  const Gap(10),
                  Obx(() {
                    final error = controller.amountError.value;
                    if (error == null || error.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Text(
                        error,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.errorBgColor,
                        ),
                      ),
                    );
                  }),
                  const Gap(40),
                ],
              ),
            ),
            // Custom Numeric Keypad
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Row 1
                  Row(
                    children: [
                      _buildKeypadButton('1'),
                      const Gap(12),
                      _buildKeypadButton('2'),
                      const Gap(12),
                      _buildKeypadButton('3'),
                    ],
                  ),
                  const Gap(12),
                  // Row 2
                  Row(
                    children: [
                      _buildKeypadButton('4'),
                      const Gap(12),
                      _buildKeypadButton('5'),
                      const Gap(12),
                      _buildKeypadButton('6'),
                    ],
                  ),
                  const Gap(12),
                  // Row 3
                  Row(
                    children: [
                      _buildKeypadButton('7'),
                      const Gap(12),
                      _buildKeypadButton('8'),
                      const Gap(12),
                      _buildKeypadButton('9'),
                    ],
                  ),
                  const Gap(12),
                  // Row 4
                  Row(
                    children: [
                      _buildKeypadButton('00'),
                      const Gap(12),
                      _buildKeypadButton('0'),
                      const Gap(12),
                      _buildDeleteButton(),
                    ],
                  ),
                  const Gap(20),
                  // Fund Wallet Button
                  Obx(() => SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: controller.canProceedWithFunding
                              ? () => controller.showConfirmationBottomSheet()
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            disabledBackgroundColor:
                                AppColors.primaryGrey2.withOpacity(0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Fund Wallet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              fontFamily: AppFonts.manRope,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypadButton(String value) {
    return Expanded(
      child: InkWell(
        onTap: () => controller.addDigit(value),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                fontFamily: AppFonts.manRope,
                color: AppColors.background,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return Expanded(
      child: InkWell(
        onTap: () => controller.deleteDigit(),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: Colors.red[50],
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.backspace_outlined,
              size: 28,
              color: Colors.red,
            ),
          ),
        ),
      ),
    );
  }
}
