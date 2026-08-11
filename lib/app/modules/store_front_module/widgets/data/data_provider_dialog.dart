import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mcd/app/modules/store_front_module/store_front_controller.dart';
import 'package:mcd/app/styles/app_colors.dart';

class DataProviderDialog extends GetView<StoreFrontController> {
  const DataProviderDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Center(
                    child: Text(
                      'Data — Select provider',
                      style: TextStyle(
                        color: AppColors.textPrimaryColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
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
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'Choose a network/provider to edit its pricing.',
                style: TextStyle(
                  color: AppColors.textPrimaryColor2,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            _buildProviderItem(
              name: 'MTN',
              icon: Icons.phone_android,
              isEnabled: controller.mtnDataEnabled,
              onToggle: (val) => controller.toggleDataProvider('mtn', val),
              onTap: () => controller.showDataTypeDialog('MTN'),
            ),
            const SizedBox(height: 12),
            _buildProviderItem(
              name: 'Glo',
              icon: Icons.phone_android,
              isEnabled: controller.gloDataEnabled,
              onToggle: (val) => controller.toggleDataProvider('glo', val),
              onTap: () => controller.showDataTypeDialog('Glo'),
            ),
            const SizedBox(height: 12),
            _buildProviderItem(
              name: 'Airtel',
              icon: Icons.phone_android,
              isEnabled: controller.airtelDataEnabled,
              onToggle: (val) => controller.toggleDataProvider('airtel', val),
              onTap: () => controller.showDataTypeDialog('Airtel'),
            ),
            const SizedBox(height: 12),
            _buildProviderItem(
              name: '9mobile',
              icon: Icons.phone_android,
              isEnabled: controller.etisalatDataEnabled,
              onToggle: (val) => controller.toggleDataProvider('9mobile', val),
              onTap: () => controller.showDataTypeDialog('9mobile'),
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () => Get.back(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: AppColors.filledBorderIColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Close',
                style: TextStyle(
                  color: AppColors.textPrimaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderItem({
    required String name,
    required IconData icon,
    required RxBool isEnabled,
    required ValueChanged<bool> onToggle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.filledBorderIColor),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppColors.lightGreen,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppColors.primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: AppColors.textPrimaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Tap to edit Discount setting',
                    style: TextStyle(
                      color: AppColors.textPrimaryColor2,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Obx(
              () => CupertinoSwitch(
                value: isEnabled.value,
                onChanged: onToggle,
                activeColor: AppColors.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
