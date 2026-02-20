import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mcd/app/styles/app_colors.dart';
import 'package:mcd/app/styles/fonts.dart';
import 'package:mcd/app/widgets/busy_button.dart';
import 'package:mcd/app/widgets/app_bar-two.dart';
import 'package:mcd/core/constants/fonts.dart';
import './virtual_card_request_controller.dart';

class VirtualCardRequestPage extends GetView<VirtualCardRequestController> {
  const VirtualCardRequestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PaylonyAppBarTwo(
        title: "Request For Card",
        elevation: 0,
        centerTitle: false,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Gap(10),

            TextSemiBold(
              'Currency',
              fontSize: 14,
              color: Colors.black87,
            ),
            const Gap(8),
            Obx(() => Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: controller.selectedCurrency1.value.isEmpty
                        ? null
                        : controller.selectedCurrency1.value,
                    hint: TextSemiBold(
                      'Select',
                      fontSize: 14,
                      color: Colors.grey.shade400,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    dropdownColor: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    icon: Icon(Icons.keyboard_arrow_down,
                        color: Colors.grey.shade600),
                    isExpanded: true,
                    items: ['Dollar']
                        .map((currency) => DropdownMenuItem(
                              value: currency,
                              child: TextSemiBold(currency, fontSize: 14),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        controller.selectedCurrency1.value = value;
                      }
                    },
                  ),
                )),
            const Gap(24),

            TextSemiBold(
              'Card Type',
              fontSize: 14,
              color: Colors.black87,
            ),
            const Gap(8),
            Obx(() => Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: controller.selectedCardType.value.isEmpty
                        ? null
                        : controller.selectedCardType.value,
                    hint: TextSemiBold(
                      'Select',
                      fontSize: 14,
                      color: Colors.grey.shade400,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    dropdownColor: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    icon: Icon(Icons.keyboard_arrow_down,
                        color: Colors.grey.shade600),
                    isExpanded: true,
                    items: ['Mastercard', 'Visa']
                        .map((cardType) => DropdownMenuItem(
                              value: cardType,
                              child: TextSemiBold(cardType, fontSize: 14),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        controller.selectedCardType.value = value;
                      }
                    },
                  ),
                )),
            const Gap(24),

            // top up amount
            TextSemiBold(
              'Top Up Amount',
              fontSize: 14,
              color: Colors.black87,
            ),
            const Gap(8),
            TextFormField(
              controller: controller.amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(fontFamily: AppFonts.manRope),
              onChanged: (value) => controller.calculateConversion(),
              decoration: InputDecoration(
                prefixText: '\$ ',
                prefixStyle: const TextStyle(
                  fontFamily: AppFonts.manRope,
                  fontSize: 16,
                  color: Colors.black,
                ),
                hintText: 'Amount',
                hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                    fontFamily: AppFonts.manRope),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: AppColors.primaryColor, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 16),
              ),
            ),
            const Gap(8),
            
            // Rate conversion display
            Obx(() {
              if (controller.amountController.text.isEmpty) {
                return const SizedBox.shrink();
              }
              
              final amount = double.tryParse(controller.amountController.text) ?? 0;
              if (amount <= 0) {
                return const SizedBox.shrink();
              }
              
              if (controller.rate.value == 0) {
                return const SizedBox.shrink();
              }
              
              final convertedAmount = controller.convertedAmount.value;
              
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.primaryColor.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextSemiBold(
                          'Exchange Rate:',
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                        TextSemiBold(
                          '₦${controller.rate.value.toStringAsFixed(2)}',
                          fontSize: 13,
                          color: AppColors.primaryColor,
                          style: GoogleFonts.plusJakartaSans(),
                        ),
                      ],
                    ),
                    const Gap(4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextBold(
                          'You will pay:',
                          fontSize: 14,
                          color: Colors.black,
                        ),
                        TextBold(
                          '₦${convertedAmount.toStringAsFixed(2)}',
                          fontSize: 14,
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w700,
                          style: GoogleFonts.plusJakartaSans(),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
            const Gap(32),

            // fee and charges section
            TextBold(
              'Fee and Charges',
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
            const Gap(20),

            // issuance fee
            Obx(() => controller.isLoadingFees.value
                ? _buildDetailRow('Issuance Fee', 'Loading...')
                : _buildDetailRow(
                    'Issuance Fee',
                    '\$${controller.createFee.value.toStringAsFixed(2)}',
                  )),
            // const Gap(16),

            // // fee
            // _buildDetailRow('Fee', '\$0.50'),
            const Gap(40),

            // proceed button
            Obx(() => BusyButton(
                  title: 'Proceed',
                  isLoading: controller.isCreating.value,
                  onTap: () => controller.createVirtualCard(),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextBold(
          label,
          fontSize: 16,
          color: Colors.black87,
          fontWeight: FontWeight.w800,
        ),
        Flexible(
          child: TextSemiBold(
            value,
            fontSize: 14,
            color: Colors.black,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
