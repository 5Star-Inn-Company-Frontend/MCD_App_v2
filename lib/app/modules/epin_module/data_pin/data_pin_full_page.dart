import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gap/gap.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mcd/app/modules/epin_module/data_pin/data_pin_controller.dart';
import 'package:mcd/app/widgets/busy_button.dart';
import 'package:mcd/app/widgets/app_bar-two.dart';
import 'package:mcd/app/styles/app_colors.dart';
import 'package:mcd/app/styles/fonts.dart';
import 'package:mcd/core/constants/fonts.dart';
import 'package:mcd/core/constants/textField.dart';

class DataPinFullPage extends GetView<DataPinController> {
  const DataPinFullPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const PaylonyAppBarTwo(
        title: 'Data-pin',
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
                // network selection
                Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: controller.networks.map((network) {
                    final isSelected = controller.selectedNetwork == network['code'];
                    return GestureDetector(
                      onTap: () => controller.selectNetwork(network['code']!),
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primaryColor.withOpacity(0.1) : Colors.white,
                          border: Border.all(
                            color: isSelected ? AppColors.primaryColor : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Image.asset(
                            network['image']!,
                            width: 45,
                            height: 45,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 45,
                                height: 45,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: TextSemiBold(
                                    network['code']![0],
                                    color: Colors.white,
                                    fontSize: 20,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                )),
                const Gap(30),
                
                // denomination
                TextSemiBold(
                  'Denomination',
                  fontSize: 14,
                  color: Colors.black87,
                ),
                const Gap(8),
                Obx(() => DropdownButtonFormField<String>(
                  value: controller.selectedDenomination.isEmpty ? null : controller.selectedDenomination,
                  decoration: textInputDecoration.copyWith(
                    hintText: 'Select Type',
                    hintStyle: const TextStyle(
                      color: AppColors.primaryGrey2,
                      fontFamily: AppFonts.manRope,
                    ),
                  ),
                  items: controller.denominations.map((denomination) {
                    return DropdownMenuItem(
                      value: denomination,
                      child: Text(
                        denomination,
                        style: const TextStyle(fontFamily: AppFonts.manRope),
                      ),
                    );
                  }).toList(),
                  onChanged: controller.selectDenomination,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a denomination';
                    }
                    return null;
                  },
                )),
                const Gap(25),
                
                // design type
                TextSemiBold(
                  'Design Type',
                  fontSize: 14,
                  color: Colors.black87,
                ),
                const Gap(8),
                GestureDetector(
                  onTap: () => _showDesignBottomSheet(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primaryGrey2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Obx(() => Text(
                          controller.selectedDesign.value == 0 
                              ? 'Select Design'
                              : controller.currentDesign['name'] ?? 'Select Design',
                          style: TextStyle(
                            color: controller.selectedDesign.value == 0 
                                ? AppColors.primaryGrey2 
                                : Colors.black87,
                            fontFamily: AppFonts.manRope,
                            fontSize: 14,
                          ),
                        )),
                        const Icon(Icons.keyboard_arrow_down, color: AppColors.primaryGrey2),
                      ],
                    ),
                  ),
                ),
                const Gap(25),
                
                // quantity
                TextSemiBold(
                  'Quantity',
                  fontSize: 14,
                  color: Colors.black87,
                ),
                const Gap(8),
                TextFormField(
                  controller: controller.quantityController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(fontFamily: AppFonts.manRope),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: textInputDecoration.copyWith(
                    hintText: '1-10',
                    hintStyle: const TextStyle(
                      color: AppColors.primaryGrey2,
                      fontFamily: AppFonts.manRope,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter quantity';
                    }
                    final qty = int.tryParse(value);
                    if (qty == null || qty < 1 || qty > 10) {
                      return 'Quantity must be between 1 and 10';
                    }
                    return null;
                  },
                ),
                const Gap(40),
                
                // pay button
                BusyButton(
                  onTap: () => controller.proceedToPurchase(context),
                  title: 'Pay',
                ),
                const Gap(20),
                
                // info text
                Center(
                  child: TextSemiBold(
                    'A copy of the pin and the instructions will be sen to your email',
                    fontSize: 12,
                    color: AppColors.primaryColor.withOpacity(0.7),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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

  // Widget _buildDesignOverlay(Map<String, dynamic> design, double cardWidth) {
  //   final networkData = controller.selectedNetworkData;
  //   final networkImage = networkData['image'] ?? '';
  //   final username = controller.username;
  //   final amount = controller.selectedDenomination.isNotEmpty 
  //       ? controller.selectedDenomination 
  //       : '100';

  //   return Positioned.fill(
  //     child: Container(
  //       padding: EdgeInsets.symmetric(
  //         horizontal: cardWidth * 0.08,
  //         vertical: cardWidth * 0.12,
  //       ),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           if (networkImage.isNotEmpty)
  //             CachedNetworkImage(
  //               imageUrl: networkImage,
  //               width: 24,
  //               height: 24,
  //               fit: BoxFit.contain,
  //               errorWidget: (context, url, error) => const SizedBox.shrink(),
  //             ),
  //           SizedBox(height: cardWidth * 0.08),
  //           TextSemiBold(
  //             username,
  //             fontSize: cardWidth * 0.055,
  //             color: Colors.black,
  //           ),
  //           const Spacer(),
  //           _buildCardField('EPIN', '', cardWidth),
  //           _buildCardField('CardNo', '', cardWidth),
  //           _buildCardField('ExpiryDate', '', cardWidth),
  //           _buildCardField('Serial No', '', cardWidth),
  //           _buildCardField('Pin', amount, cardWidth),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildCardField(String label, String value, double cardWidth) {
    return Padding(
      padding: EdgeInsets.only(bottom: cardWidth * 0.02),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextSemiBold(
            '$label:',
            fontSize: cardWidth * 0.045,
            color: Colors.black87,
          ),
          TextSemiBold(
            value,
            fontSize: cardWidth * 0.045,
            color: Colors.black87,
          ),
        ],
      ),
    );
  }
}
