import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mcd/app/widgets/busy_button.dart';
import 'package:mcd/app/widgets/app_bar-two.dart';
import 'package:mcd/app/widgets/touchableOpacity.dart';
import 'package:mcd/app/modules/airtime_pin_module/airtime_pin_module_controller.dart';
import 'package:mcd/app/styles/app_colors.dart';
import 'package:mcd/app/styles/fonts.dart';
import 'package:mcd/core/constants/fonts.dart';

class AirtimePinModulePage extends GetView<AirtimePinModuleController> {
  const AirtimePinModulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const PaylonyAppBarTwo(
        title: 'Airtime Pin',
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description
                TextSemiBold(
                  'Purchase airtime pins and receive them via email',
                  fontSize: 14,
                  color: AppColors.background,
                ),
                const Gap(30),

                // Network Selection
                TextSemiBold(
                  'Select Network',
                  fontSize: 14,
                  color: Colors.black87,
                ),
                const Gap(12),
                Obx(() => Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: controller.networks.map((network) {
                          final isSelected = controller.selectedNetwork.value ==
                              network['code'];
                          return GestureDetector(
                            onTap: () =>
                                controller.selectNetwork(network['code']!),
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primaryColor.withOpacity(0.1)
                                    : Colors.white,
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primaryColor
                                      : Colors.transparent,
                                  width: isSelected ? 2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Image.asset(
                                network['image']!,
                                width: 60,
                                height: 60,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    )),
                const Gap(30),

                // Amount Selection Grid
                Text(
                  'Amount',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const Gap(12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xffF1F1F1)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      GridView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 2.5,
                        ),
                        children: [
                          _amountCard('100'),
                          _amountCard('200'),
                          _amountCard('500'),
                        ],
                      ),
                      // const Gap(15),
                      // Row(
                      //   children: [
                      //     const Text("₦", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                      //     const Gap(8),
                      //     Expanded(
                      //       child: TextFormField(
                      //         controller: controller.amountController,
                      //         keyboardType: TextInputType.number,
                      //         style: TextStyle(fontFamily: AppFonts.manRope),
                      //         inputFormatters: [
                      //           FilteringTextInputFormatter.digitsOnly,
                      //         ],
                      //         decoration: const InputDecoration(
                      //           hintText: '500.00 - 50,000.00',
                      //           hintStyle: TextStyle(color: AppColors.primaryGrey),
                      //           border: UnderlineInputBorder(),
                      //         ),
                      //         validator: (value) {
                      //           if (value == null || value.isEmpty) {
                      //             return 'Please enter amount';
                      //           }
                      //           final amount = double.tryParse(value);
                      //           if (amount == null) {
                      //             return 'Invalid amount';
                      //           }
                      //           if (amount < 100 || amount > 50000) {
                      //             return 'Amount must be between ₦100 and ₦50,000';
                      //           }
                      //           return null;
                      //         },
                      //       ),
                      //     ),
                      //   ],
                      // ),
                    ],
                  ),
                ),
                const Gap(24),

                // Quantity
                TextSemiBold(
                  'Quantity (1 - 10)',
                  fontSize: 14,
                  color: Colors.black87,
                ),
                const Gap(8),
                Row(
                  children: [
                    // Decrement button
                    GestureDetector(
                      onTap: controller.decrementQuantity,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.remove,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Gap(12),
                    // Quantity input
                    Expanded(
                      child: TextFormField(
                        controller: controller.quantityController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppFonts.manRope,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(2),
                        ],
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.primaryGrey2.withOpacity(0.05),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.primaryColor,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter quantity';
                          }
                          final quantity = int.tryParse(value);
                          if (quantity == null) {
                            return 'Invalid';
                          }
                          if (quantity < 1 || quantity > 10) {
                            return '1-10';
                          }
                          return null;
                        },
                      ),
                    ),
                    const Gap(12),
                    // Increment button
                    GestureDetector(
                      onTap: controller.incrementQuantity,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(40),

                // Pay Button
                Obx(() => BusyButton(
                      title: "Pay",
                      isLoading: controller.isProcessing.value,
                      onTap: () => controller.processPayment(),
                    )),
                const Gap(40),
                Center(
                  child: TextSemiBold(
                    'A copy of the pin and the instructions will be sent to your email',
                    fontSize: 13,
                    color: AppColors.errorBgColor,
                  ),
                ),
                const Gap(20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _amountCard(String amount, {bool isFirst = false}) {
    return Obx(() {
      final isSelected = controller.selectedAmount.value == amount;
      return TouchableOpacity(
        onTap: () {
          HapticFeedback.lightImpact();
          controller.onAmountSelected(amount);
        },
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryColor : Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: AppColors.primaryColor,
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              '₦$amount',
              style: GoogleFonts.plusJakartaSans(
                color: isSelected ? AppColors.white : AppColors.primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ),
      );
    });
  }
}
