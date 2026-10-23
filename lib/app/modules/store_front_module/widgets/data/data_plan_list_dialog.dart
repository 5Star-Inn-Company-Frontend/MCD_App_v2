import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
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
    final currencyFormatter = NumberFormat('#,##0', 'en_US');

    void goBack() {
      Get.back();
      final prov = controller.dataProviders.firstWhereOrNull(
        (p) => p.provider.toLowerCase() == providerName.toLowerCase(),
      );
      if (prov != null) {
        controller.showDataTypeDialog(prov);
      } else {
        controller.showDataProviderDialog();
      }
    }

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
                  onTap: goBack,
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
                    '${providerName.toUpperCase()} · $typeName',
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
                'Tap a plan to customize your resale price.',
                style: TextStyle(
                  color: AppColors.textPrimaryColor2,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Obx(() {
                if (controller.isLoadingPlans.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryColor,
                    ),
                  );
                }
                if (controller.activePlans.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'No plans available for this category.',
                          style: TextStyle(
                            color: AppColors.textPrimaryColor2,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () => controller.fetchPlans(
                            category: 'data',
                            provider: providerName,
                            type: typeName,
                          ),
                          child: const Text(
                            'Retry',
                            style: TextStyle(color: AppColors.primaryColor),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: controller.activePlans.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final plan = controller.activePlans[index];
                    final baseStr = 'N${currencyFormatter.format(plan.baseCost)}';
                    final sellStr = 'N${currencyFormatter.format(plan.sellPrice)}';
                    final earnStr = 'N${currencyFormatter.format(plan.commission)}';
                    return _buildPlanItem(
                      name: plan.name,
                      basePrice: baseStr,
                      sellPrice: sellStr,
                      earn: earnStr,
                      isEnabled: plan.isEnabled,
                      onToggle: (val) {
                        controller.updatePlanToggle(
                          category: 'data',
                          plan: plan,
                          isEnabled: val,
                        );
                      },
                      onTap: () => controller.showEditDataPlanDialog(
                        providerName: providerName,
                        typeName: typeName,
                        plan: plan,
                      ),
                    );
                  },
                );
              }),
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: goBack,
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
    required bool isEnabled,
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
                        '·',
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
                  'Profit',
                  style: TextStyle(
                    color: AppColors.textPrimaryColor2,
                    fontSize: 10,
                  ),
                ),
                Text(
                  earn,
                  style: const TextStyle(
                    color: AppColors.primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            CupertinoSwitch(
              value: isEnabled,
              onChanged: onToggle,
              activeColor: AppColors.primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}
