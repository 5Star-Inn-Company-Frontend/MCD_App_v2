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

                // Design Type Selection
                TextSemiBold(
                  'Design Type',
                  fontSize: 14,
                  color: Colors.black87,
                ),
                const Gap(12),
                Obx(() => GestureDetector(
                  onTap: () => _showDesignBottomSheet(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            controller.currentDesign['name'] ?? 'Select Design',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_down,
                          color: AppColors.primaryGrey,
                        ),
                      ],
                    ),
                  ),
                )),
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

  void _showDesignBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.55,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Gap(20),
            
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextSemiBold(
                    'Select Design',
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    color: AppColors.primaryGrey,
                  ),
                ],
              ),
            ),
            const Gap(10),
            
            // Designs List
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: controller.designs.map((design) {
                    return Obx(() {
                      final isSelected = controller.selectedDesign.value == design['id'];
                      
                      return GestureDetector(
                        onTap: () {
                          controller.selectDesign(design['id'] as int);
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: (MediaQuery.of(context).size.width - 56) / 2,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected 
                                  ? AppColors.primaryColor 
                                  : Colors.grey.shade300,
                              width: isSelected ? 3 : 1,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isSelected 
                                      ? AppColors.primaryColor.withOpacity(0.1) 
                                      : Colors.grey.shade50,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    topRight: Radius.circular(12),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      design['name'] as String,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected 
                                            ? AppColors.primaryColor 
                                            : Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Image.asset(
                                design['image'] as String,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ],
                          ),
                        ),
                      );
                    });
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesignOverlay() {
    return Obx(() {
      final networkCode = controller.selectedNetwork.value ?? 'MTN';
      final amount = controller.selectedAmount.value.isEmpty 
          ? '100' 
          : controller.selectedAmount.value;
      final username = controller.username;
      
      // Get network image
      final networkData = controller.networks.firstWhere(
        (network) => network['code'] == networkCode,
        orElse: () => controller.networks[0],
      );
      final networkImage = networkData['image'] as String;
      
      return Positioned.fill(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Network logo
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: const EdgeInsets.all(3),
                child: Image.asset(
                  networkImage,
                  fit: BoxFit.contain,
                ),
              ),
              const Gap(6),
              // Username section
              _buildCardField('Username', username, fontSize: 7),
              const Gap(3),
              _buildCardField('EPIN', '0xe${networkCode}0x4fK0-1', fontSize: 6),
              const Gap(3),
              _buildCardField('CardNo', '52000271178006', fontSize: 6),
              const Gap(3),
              _buildCardField('ExpiryDate', '19/01/2027', fontSize: 6),
              const Gap(3),
              _buildCardField('Serial No', '20673659852090163', fontSize: 6),
              const Gap(3),
              _buildCardField('Pin', '₦$amount', fontSize: 7, valueColor: Colors.white),
              const Spacer(),
              // Bottom text
              Text(
                'To view pin ****',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 5,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildCardField(String label, String value, {double fontSize = 7, Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label:',
          style: GoogleFonts.plusJakartaSans(
            fontSize: fontSize - 1,
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: fontSize,
            color: valueColor ?? Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
