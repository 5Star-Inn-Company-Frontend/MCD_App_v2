import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mcd/app/modules/store_front_module/store_front_controller.dart';
import 'package:mcd/app/styles/app_colors.dart';

class EditDiscountDialog extends GetView<StoreFrontController> {
  final String providerName;

  const EditDiscountDialog({
    super.key,
    required this.providerName,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Get.back();
                      controller.showSelectProviderDialog();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.boxColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chevron_left,
                        color: AppColors.textPrimaryColor,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      '$providerName Discount',
                      style: const TextStyle(
                        color: AppColors.textPrimaryColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: const Icon(
                      Icons.close,
                      color: AppColors.textPrimaryColor2,
                      size: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Set discount between 0% and 3%(our base).',
                style: TextStyle(
                  color: AppColors.textPrimaryColor2,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.lightGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'MCD base cost',
                      style: TextStyle(
                        color: AppColors.textPrimaryColor2,
                        fontSize: 14,
                      ),
                    ),
                    Obx(
                      () => Text(
                        controller.mcdBaseCost.value,
                        style: const TextStyle(
                          color: AppColors.textPrimaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Discount to Price (%)',
                style: TextStyle(
                  color: AppColors.textPrimaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: TextEditingController(text: controller.mtnDiscount.value),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  enabledBorder: OutlineBorder(
                    borderSide: const BorderSide(color: AppColors.filledBorderIColor),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineBorder(
                    borderSide: const BorderSide(color: AppColors.primaryColor),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (val) {
                  controller.mtnDiscount.value = val;
                },
              ),
              const SizedBox(height: 8),
              const Text(
                'Your commission per sale: 1% of amount', // Fixed value for UI prototype
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  Get.back();
                  controller.showSelectProviderDialog();
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: AppColors.filledBorderIColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Back',
                  style: TextStyle(
                    color: AppColors.textPrimaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OutlineBorder extends OutlineInputBorder {
  const OutlineBorder({
    super.borderSide,
    super.borderRadius,
  });
}
