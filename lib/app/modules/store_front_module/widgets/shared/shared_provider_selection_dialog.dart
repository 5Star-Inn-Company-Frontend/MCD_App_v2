import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mcd/app/styles/app_colors.dart';

class ProviderItemConfig {
  final String name;
  final String subtitle;
  final String imageAsset;
  final RxBool isEnabled;
  final ValueChanged<bool> onToggle;
  final VoidCallback onTap;

  ProviderItemConfig({
    required this.name,
    required this.subtitle,
    required this.imageAsset,
    required this.isEnabled,
    required this.onToggle,
    required this.onTap,
  });
}

class SharedProviderSelectionDialog extends StatelessWidget {
  final String title;
  final String description;
  final List<ProviderItemConfig> providers;

  const SharedProviderSelectionDialog({
    super.key,
    required this.title,
    required this.description,
    required this.providers,
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      title,
                      style: const TextStyle(
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
            Center(
              child: Text(
                description,
                style: const TextStyle(
                  color: AppColors.textPrimaryColor2,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            ...providers.asMap().entries.map((entry) {
              final index = entry.key;
              final provider = entry.value;
              return Column(
                children: [
                  _buildProviderItem(provider),
                  if (index < providers.length - 1) const SizedBox(height: 12),
                ],
              );
            }).toList(),
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

  Widget _buildProviderItem(ProviderItemConfig config) {
    return InkWell(
      onTap: config.onTap,
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
              child: Image.asset(config.imageAsset, width: 20, height: 20,),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    config.name,
                    style: const TextStyle(
                      color: AppColors.textPrimaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    config.subtitle,
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
                value: config.isEnabled.value,
                onChanged: config.onToggle,
                activeColor: AppColors.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
