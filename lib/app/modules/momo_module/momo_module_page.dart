import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Add this import
import 'package:get/get.dart';
import 'package:gap/gap.dart';
import 'package:mcd/app/widgets/app_bar-two.dart';
import 'package:mcd/app/modules/momo_module/momo_module_controller.dart';
import 'package:mcd/app/styles/app_colors.dart';
import 'package:mcd/app/styles/fonts.dart';
import 'package:mcd/app/widgets/busy_button.dart';
import 'package:mcd/core/constants/fonts.dart';

class MomoModulePage extends GetView<MomoModuleController> {
  const MomoModulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const PaylonyAppBarTwo(
        title: 'Momo Top Up',
        centerTitle: false,
      ),
      body: Obx(() {
        if (controller.currentStage.value == 1) {
          return _buildSuccessView();
        }
        return _buildFormView();
      }),
    );
  }

  Widget _buildFormView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: controller.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter your bank and the amount to generate a ussd code quickly',
              style: TextStyle(
                fontFamily: AppFonts.manRope,
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            const Gap(24),

            // Currency Dropdown
            TextSemiBold('Select currency',
                fontSize: 14, color: Colors.black87),
            const Gap(8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.primaryGrey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: Obx(() => DropdownButton<String>(
                      dropdownColor: AppColors.white,
                      icon: Icon(Icons.keyboard_arrow_down_rounded),
                      borderRadius: BorderRadius.circular(8),
                      isExpanded: true,
                      hint: Text('Select currency',
                          style: TextStyle(
                              fontFamily: AppFonts.manRope,
                              color: Colors.grey)),
                      value: controller.selectedCurrency.value,
                      items: controller.currencies.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value,
                              style: TextStyle(fontFamily: AppFonts.manRope)),
                        );
                      }).toList(),
                      onChanged: controller.onCurrencyChanged,
                    )),
              ),
            ),
            const Gap(24),

            // Provider Dropdown
            TextSemiBold('Select Mobile Money Provider',
                fontSize: 14, color: Colors.black87),
            const Gap(8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.primaryGrey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: Obx(() => DropdownButton<Map<String, dynamic>>(
                      dropdownColor: AppColors.white,
                      icon: Icon(Icons.keyboard_arrow_down_rounded),
                      borderRadius: BorderRadius.circular(8),
                      isExpanded: true,
                      hint: Text('Select Mobile Money Provider',
                          style: TextStyle(
                              fontFamily: AppFonts.manRope,
                              color: Colors.grey)),
                      value: controller.selectedProvider.value,
                      items: controller.providers
                          .map((Map<String, dynamic> provider) {
                        return DropdownMenuItem<Map<String, dynamic>>(
                          value: provider,
                          child: Row(
                            children: [
                              if (provider['logo'] != null)
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Image.network(provider['logo'],
                                      width: 24,
                                      height: 24,
                                      errorBuilder: (_, __, ___) =>
                                          const SizedBox()),
                                ),
                              Text(provider['name'] ?? '',
                                  style:
                                      TextStyle(fontFamily: AppFonts.manRope)),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (val) =>
                          controller.selectedProvider.value = val,
                    )),
              ),
            ),
            const Gap(24),

            // Phone Number
            TextSemiBold('Enter Mobile Money Number',
                fontSize: 14, color: Colors.black87),
            const Gap(8),
            TextFormField(
              controller: controller.phoneController,
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: TextStyle(fontFamily: AppFonts.manRope),
              decoration: InputDecoration(
                hintText: 'Enter phone number',
                hintStyle: TextStyle(
                  fontFamily: AppFonts.manRope,
                  color: Colors.grey,
                ),
                prefixIcon: Obx(() {
                  final code = controller.selectedCountryCode.value;
                  if (code.isEmpty) return const SizedBox.shrink();
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 14),
                    child: Text(
                      '+$code',
                      style: TextStyle(
                        fontFamily: AppFonts.manRope,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                  );
                }),
                filled: true,
                fillColor: AppColors.primaryGrey.withOpacity(0.1),
                prefixIconConstraints:
                    const BoxConstraints(minWidth: 0, minHeight: 0),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.primaryColor)),
              ),
              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
            ),
            const Gap(24),

            // Amount
            TextSemiBold('Amount', fontSize: 14, color: Colors.black87),
            const Gap(8),
            TextFormField(
              controller: controller.amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: TextStyle(fontFamily: AppFonts.manRope),
              decoration: InputDecoration(
                hintText: '1500.00',
                hintStyle: TextStyle(
                    fontFamily: AppFonts.manRope, color: AppColors.primaryGrey),
                filled: true,
                fillColor: AppColors.primaryGrey.withOpacity(0.1),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.primaryColor)),
              ),
              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
            ),

            const Gap(12),
            // Exchange Rate Display
            Center(
              child: Obx(() {
                if (controller.selectedCurrency.value == null) {
                  return const SizedBox.shrink();
                }

                final currency = controller.selectedCurrency.value!;
                final converted =
                    controller.convertedAmount.value.toStringAsFixed(2);
                final inputAmount = controller.amountController.text.isEmpty
                    ? "0.00"
                    : controller.amountController.text;

                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.primaryColor.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$currency $inputAmount',
                        style: const TextStyle(
                          fontFamily: AppFonts.manRope,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: const Icon(
                          Icons.compare_arrows,
                          color: AppColors.primaryColor,
                          size: 24,
                        ),
                      ),
                      Text(
                        'NGN $converted',
                        style: const TextStyle(
                          fontFamily: AppFonts.manRope,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),

            const Gap(40),
            Obx(() => BusyButton(
                  title: 'Proceed',
                  isLoading: controller.isSubmitting.value,
                  onTap: controller.proceed,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessView() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Check your phone to complete the transaction',
            style: TextStyle(
                fontFamily: AppFonts.manRope,
                fontSize: 16,
                color: Colors.black87),
          ),
          const Gap(24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.successBgColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBulletPoint(
                    'You will receive a notification on your phone to authorize the payment.'),
                const Gap(8),
                _buildBulletPoint(
                    'Proceed to make the transfer by accepting the prompt on your phone'),
              ],
            ),
          ),
          const Spacer(),
          BusyButton(
            title: 'I have completed the prompt',
            onTap: () {
              Get.back(); // Or navigate appropriately
              Get.snackbar('Success', 'Transaction Pending',
                  backgroundColor: AppColors.successBgColor,
                  colorText: Colors.white);
            },
          ),
          const Gap(40),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: CircleAvatar(radius: 2, backgroundColor: Colors.black87),
        ),
        const Gap(8),
        Expanded(
            child: Text(text,
                style: TextStyle(fontFamily: AppFonts.manRope, fontSize: 14))),
      ],
    );
  }
}
