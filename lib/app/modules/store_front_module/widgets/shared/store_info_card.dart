import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mcd/app/modules/store_front_module/store_front_controller.dart';
import 'package:mcd/app/styles/app_colors.dart';
import 'package:mcd/app/modules/store_front_module/widgets/edit_store_profile_dialog.dart';

class StoreInfoCard extends GetView<StoreFrontController> {
  const StoreInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [AppColors.primaryColor, AppColors.primaryColor2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Obx(
        () {
          final name = controller.storeName.value.isNotEmpty
              ? controller.storeName.value
              : (controller.isLoadingDashboard.value ? 'Loading store...' : 'Tap edit to set store name');
          final code = controller.storeCode.value.isNotEmpty
              ? controller.storeCode.value
              : (controller.isLoadingDashboard.value ? '...' : 'No code');
          final statusText = controller.status.value ? 'Active' : 'Inactive';
          final welcome = controller.welcomeMessage.value.isNotEmpty
              ? '"${controller.welcomeMessage.value}"'
              : (controller.isLoadingDashboard.value ? 'Loading...' : 'Tap edit to set a welcome message for your store.');

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Image.asset('assets/icons/storefront/store.png', width: 28, height: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Store Name',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ref: $code · $statusText',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Get.dialog(const EditStoreProfileDialog());
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset('assets/icons/storefront/edit.png', width: 18, height: 18),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                welcome.startsWith('"') ? welcome : '"$welcome"',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
