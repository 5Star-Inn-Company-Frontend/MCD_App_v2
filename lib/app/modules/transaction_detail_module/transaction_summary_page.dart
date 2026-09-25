import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gap/gap.dart';
import 'package:mcd/app/routes/app_pages.dart';
import 'package:mcd/app/styles/app_colors.dart';
import 'package:mcd/core/utils/amount_formatter.dart';
import 'package:mcd/app/modules/home_screen_module/home_screen_controller.dart';
import 'package:mcd/app/modules/home_screen_module/home_screen_page.dart';
import 'package:mcd/app/modules/transaction_detail_module/transaction_detail_module_controller.dart';

class TransactionSummaryPage extends GetView<TransactionDetailModuleController> {
  const TransactionSummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const SizedBox.shrink(),
        actions: [
          TextButton(
            onPressed: () {
              Get.offAllNamed(Routes.HOME_SCREEN);
            },
            child: const Text(
              'Done',
              style: TextStyle(
                color: AppColors.primaryColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Gap(10),
        ],
      ),
      body: SingleChildScrollView(
        child: RepaintBoundary(
          key: controller.summaryReceiptKey,
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
              const Gap(20),
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: AppColors.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const Gap(15),
              const Text(
                'Successful',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimaryColor,
                ),
              ),
              const Gap(5),
              Text(
                '₦${AmountUtil.formatFigure(controller.amount)}',
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: AppColors.background,
                ),
              ),
              const Gap(5),
              const Text(
                'The recipient will receive it shortly',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const Gap(30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => controller.shareReceipt(),
                      icon: const Icon(Icons.share, size: 18, color: AppColors.primaryColor),
                      label: const Text(
                        'Share receipt',
                        style: TextStyle(color: AppColors.primaryColor, fontSize: 14),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const Gap(15),
                  Expanded(
                    child: Obx(() => OutlinedButton.icon(
                      onPressed: controller.isRepeating ? null : () => controller.repeatTransaction(),
                      icon: controller.isRepeating 
                        ? const SizedBox(
                            width: 18, 
                            height: 18, 
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryColor)
                          )
                        : const Icon(Icons.refresh, size: 18, color: AppColors.primaryColor),
                      label: const Text(
                        'Buy again',
                        style: TextStyle(color: AppColors.primaryColor, fontSize: 14),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    )),
                  ),
                ],
              ),
              const Gap(30),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7FBF7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildDetailRow('Recipient', controller.phoneNumber),
                    const Gap(15),
                    _buildDetailRow('Payment type', controller.name),
                    const Gap(15),
                    const Divider(color: Color(0xFFE5E5E5)),
                    const Gap(10),
                    GestureDetector(
                      onTap: () {
                        // Pass existing arguments downstream to details page
                        var args = Get.arguments;
                        Get.toNamed(
                          Routes.TRANSACTION_DETAIL_FULL,
                          arguments: args,
                        );
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'View Details',
                            style: TextStyle(
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          Gap(5),
                          Icon(
                            Icons.chevron_right,
                            color: AppColors.primaryColor,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(30),
              _buildMegaSaleSlider(),
              const Gap(30),
            ],
          ),
        ),
      ),
    ));
  }

  Widget _buildDetailRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.background,
          ),
        ),
      ],
    );
  }

  Widget _buildMegaSaleSlider() {
    try {
      final homeController = Get.find<HomeScreenController>();
      return Obx(() {
        if (homeController.imageSliders.isEmpty) {
          return const SizedBox.shrink();
        }
        return ImageSliderWidget(images: homeController.imageSliders);
      });
    } catch (_) {
      return const SizedBox.shrink();
    }
  }
}
