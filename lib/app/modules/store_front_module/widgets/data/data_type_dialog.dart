import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mcd/app/modules/store_front_module/store_front_controller.dart';
import 'package:mcd/app/styles/app_colors.dart';

class DataTypeDialog extends GetView<StoreFrontController> {
  final String providerName;

  const DataTypeDialog({
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Get.back();
                    controller.showDataProviderDialog();
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
                    '$providerName — Select type',
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
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'Pick a data category to view its plans.',
                style: TextStyle(
                  color: AppColors.textPrimaryColor2,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            _buildTypeItem(
              name: 'CG',
              plansCount: '3 plans',
              isEnabled: controller.cgDataEnabled,
              onToggle: (val) => controller.toggleDataType('cg', val),
              onTap: () => controller.showDataPlanListDialog(providerName, 'CG'),
            ),
            const SizedBox(height: 12),
            _buildTypeItem(
              name: 'SME',
              plansCount: '2 plans',
              isEnabled: controller.smeDataEnabled,
              onToggle: (val) => controller.toggleDataType('sme', val),
              onTap: () => controller.showDataPlanListDialog(providerName, 'SME'),
            ),
            const SizedBox(height: 12),
            _buildTypeItem(
              name: 'DG',
              plansCount: '2 plans',
              isEnabled: controller.dgDataEnabled,
              onToggle: (val) => controller.toggleDataType('dg', val),
              onTap: () => controller.showDataPlanListDialog(providerName, 'DG'),
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () {
                Get.back();
                controller.showDataProviderDialog();
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
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeItem({
    required String name,
    required String plansCount,
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
                  Text(
                    plansCount,
                    style: const TextStyle(
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
