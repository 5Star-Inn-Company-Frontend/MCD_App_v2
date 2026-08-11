import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mcd/app/modules/store_front_module/store_front_controller.dart';
import 'package:mcd/app/styles/app_colors.dart';

class DataPlanListDialog extends GetView<StoreFrontController> {
  final String providerName;
  final String typeName;

  const DataPlanListDialog({
    super.key,
    required this.providerName,
    required this.typeName,
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
                    controller.showDataTypeDialog(providerName);
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
                    '$providerName · $typeName',
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
                'Tap a plan to edit its price. Max markup 20%.',
                style: TextStyle(
                  color: AppColors.textPrimaryColor2,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildPlanItem(
                      name: '$providerName $typeName 1GB - 30d',
                      basePrice: 'N350',
                      sellPrice: 'N400',
                      earn: 'N50',
                      isEnabled: controller.plan1GBEnabled,
                      onToggle: (val) => controller.toggleDataPlan('1GB', val),
                      onTap: () => controller.showEditDataPlanDialog(providerName, typeName, '1GB - 30d'),
                    ),
                    const SizedBox(height: 12),
                    _buildPlanItem(
                      name: '$providerName $typeName 2GB - 30d',
                      basePrice: 'N950',
                      sellPrice: 'N1,000',
                      earn: 'N50',
                      isEnabled: controller.plan2GBEnabled,
                      onToggle: (val) => controller.toggleDataPlan('2GB', val),
                      onTap: () => controller.showEditDataPlanDialog(providerName, typeName, '2GB - 30d'),
                    ),
                    const SizedBox(height: 12),
                    _buildPlanItem(
                      name: '$providerName $typeName 5GB - 30d',
                      basePrice: 'N2,400',
                      sellPrice: 'N2,500',
                      earn: 'N100',
                      isEnabled: controller.plan5GBEnabled,
                      onToggle: (val) => controller.toggleDataPlan('5GB', val),
                      onTap: () => controller.showEditDataPlanDialog(providerName, typeName, '5GB - 30d'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () {
                Get.back();
                controller.showDataTypeDialog(providerName);
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

  Widget _buildPlanItem({
    required String name,
    required String basePrice,
    required String sellPrice,
    required String earn,
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
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Base $basePrice',
                        style: const TextStyle(
                          color: AppColors.textPrimaryColor2,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        '-',
                        style: TextStyle(
                          color: AppColors.textPrimaryColor2,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Sell $sellPrice',
                        style: const TextStyle(
                          color: AppColors.textPrimaryColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'Earn',
                  style: TextStyle(
                    color: AppColors.textPrimaryColor2,
                    fontSize: 10,
                  ),
                ),
                Text(
                  earn,
                  style: const TextStyle(
                    color: AppColors.textPrimaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
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
