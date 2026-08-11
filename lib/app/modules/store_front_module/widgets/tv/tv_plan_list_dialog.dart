import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mcd/app/modules/store_front_module/store_front_controller.dart';
import 'package:mcd/app/styles/app_colors.dart';

class TvPlanListDialog extends GetView<StoreFrontController> {
  final String providerName;

  const TvPlanListDialog({
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
                    controller.showTvProviderDialog();
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
                    providerName,
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
                'Tap a plan to edit its price. Max markup 10%.',
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
                      name: '$providerName Compact',
                      basePrice: 'N15,700',
                      sellPrice: 'N16,000',
                      earn: 'N300',
                      isEnabled: controller.tvCompactEnabled,
                      onToggle: (val) => controller.toggleTvPlan('Compact', val),
                      onTap: () => controller.showEditTvPlanDialog(providerName, 'Compact'),
                    ),
                    const SizedBox(height: 12),
                    _buildPlanItem(
                      name: '$providerName Premium',
                      basePrice: 'N37,000',
                      sellPrice: 'N37,500',
                      earn: 'N500',
                      isEnabled: controller.tvPremiumEnabled,
                      onToggle: (val) => controller.toggleTvPlan('Premium', val),
                      onTap: () => controller.showEditTvPlanDialog(providerName, 'Premium'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () {
                Get.back();
                controller.showTvProviderDialog();
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
