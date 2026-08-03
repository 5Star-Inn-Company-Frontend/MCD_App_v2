import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:mcd/app/styles/app_colors.dart';
import 'package:mcd/app/styles/fonts.dart';
import 'package:mcd/app/widgets/app_bar-two.dart';
import 'package:mcd/core/constants/fonts.dart';
import './virtual_card_limits_controller.dart';

class VirtualCardLimitsPage extends GetView<VirtualCardLimitsController> {
  const VirtualCardLimitsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PaylonyAppBarTwo(
        title: "Limits",
        elevation: 0,
        centerTitle: false,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: controller.formKey,
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Gap(20),
            
            // Transaction Limit Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextSemiBold(
                  'Transaction Limit',
                  fontSize: 16,
                  color: Colors.black87,
                ),
                Obx(() => Switch(
                  value: controller.isLimitEnabled.value,
                  onChanged: controller.toggleLimit,
                  activeColor: AppColors.primaryColor,
                )),
              ],
            ),
            const Gap(20),
            
            // Description
            TextSemiBold(
              'Enter New Amount For Daily Transaction Limit',
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            const Gap(20),
            
            // Amount Input Field
            Obx(() => TextFormField(
              controller: controller.limitController,
              enabled: controller.isLimitEnabled.value,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty || value == '0.00') {
                  return 'Please enter a valid limit amount';
                }
                return null;
              },
              style: TextStyle(
                fontSize: 16,
                fontFamily: AppFonts.manRope,
                color: controller.isLimitEnabled.value 
                    ? Colors.black87 
                    : Colors.grey.shade400,
              ),
              decoration: InputDecoration(
                prefixText: '₦ ',
                prefixStyle: TextStyle(
                  fontSize: 16,
                  fontFamily: AppFonts.manRope,
                  color: controller.isLimitEnabled.value 
                      ? Colors.black87 
                      : Colors.grey.shade400,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: controller.isLimitEnabled.value 
                        ? AppColors.primaryColor 
                        : Colors.grey.shade300,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: controller.isLimitEnabled.value 
                        ? AppColors.primaryColor 
                        : Colors.grey.shade300,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.primaryColor,
                    width: 2,
                  ),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            )),
            const Gap(300),
            
            // Set Limit Button
            Obx(() => SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: controller.isLimitEnabled.value 
                    ? controller.setLimit 
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: controller.isLimitEnabled.value 
                      ? AppColors.primaryColor 
                      : AppColors.primaryColor.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: TextBold(
                  'Set limit',
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )),
          ],
        ),
      ),
      ),
    );
  }
}
