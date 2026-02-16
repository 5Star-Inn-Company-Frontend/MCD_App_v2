import 'package:google_fonts/google_fonts.dart';
import 'package:mcd/app/modules/plans_module/plans_module_controller.dart';
import 'package:mcd/app/widgets/skeleton_loader.dart';
import 'package:mcd/core/import/imports.dart';

class PlansModulePage extends GetView<PlansModuleController> {
  const PlansModulePage({super.key, this.isAppbar = true});

  final bool? isAppbar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: isAppbar == true
          ? const PaylonyAppBarTwo(
              title: "Plans",
              centerTitle: false,
            )
          : null,
      body: Obx(() {
        if (controller.isLoading) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Column(
              children: [
                // badge skeleton
                const SkeletonLoader(width: 80, height: 24, borderRadius: 20),
                const Gap(16),
                // title skeleton
                const SkeletonText(width: 150, height: 28),
                const Gap(20),
                // description skeleton
                const SkeletonText(width: 250, height: 14),
                const Gap(8),
                const SkeletonText(width: 200, height: 14),
                const Gap(20),
                // price skeleton
                const SkeletonText(width: 120, height: 36),
                const Gap(40),
                // feature cards skeleton
                const SkeletonCard(height: 50),
                const Gap(12),
                const SkeletonCard(height: 50),
                const Gap(12),
                const SkeletonCard(height: 50),
                const Gap(12),
                const SkeletonCard(height: 50),
                const Gap(40),
                // button skeleton
                const SkeletonCard(width: 200, height: 48, borderRadius: 8),
              ],
            ),
          );
        }

        if (controller.plans.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 64,
                  color: AppColors.primaryGrey,
                ),
                const Gap(16),
                TextSemiBold(
                  'No plans available',
                  fontSize: 16,
                ),
                const Gap(16),
                ElevatedButton(
                  onPressed: controller.fetchPlans,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: PageView.builder(
                itemCount: controller.plans.length,
                onPageChanged: controller.onPageChanged,
                itemBuilder: (context, index) {
                  final plan = controller.plans[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 40, horizontal: 15),
                    child: Scrollbar(
                      thumbVisibility: true,
                      thickness: 4,
                      radius: const Radius.circular(4),
                      child: SingleChildScrollView(
                        primary: false,
                        child: Column(
                          children: [
                            // Plan header
                            Column(
                              children: [
                                if (plan.badge != null) ...[
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryGreen
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: TextSemiBold(
                                      plan.badge!,
                                      fontSize: 12,
                                      color: AppColors.primaryGreen,
                                    ),
                                  ),
                                  const Gap(12),
                                ],
                                TextBold(
                                  plan.name.toUpperCase(),
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                ),
                                const Gap(20),
                                TextSemiBold(
                                  plan.description,
                                  fontSize: 14,
                                  textAlign: TextAlign.center,
                                ),
                                const Gap(20),
                                plan.formattedPrice == 'Free'
                                    ? TextBold(
                                        'Free',
                                        fontSize: 32,
                                        fontWeight: FontWeight.w700,
                                      )
                                    : RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: plan.nairaSymbol,
                                              style: const TextStyle(
                                                fontFamily: 'plusJakartaSans',
                                                fontSize: 28,
                                                fontWeight: FontWeight.w700,
                                                color:
                                                    AppColors.textPrimaryColor,
                                              ),
                                            ),
                                            TextSpan(
                                              text: plan.priceAmount,
                                              style: const TextStyle(
                                                fontFamily: AppFonts.manRope,
                                                fontSize: 32,
                                                fontWeight: FontWeight.w700,
                                                color:
                                                    AppColors.textPrimaryColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                              ],
                            ),
                            const Gap(40),
                            // Plan features
                            Column(
                              children: plan.features
                                  .map((feature) => _planCard(feature))
                                  .toList(),
                            ),
                            const Gap(40),
                            // Upgrade button with conditional logic
                            Obx(() {
                              final isCurrentPlan = controller.isUserPlan(plan);
                              final canUpgrade = controller.canUpgradeTo(plan);

                              // current plan - show disabled "Current Plan" button
                              if (isCurrentPlan) {
                                return Container(
                                  width: screenWidth(context) * 0.7,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  decoration: BoxDecoration(
                                    color:
                                        AppColors.primaryGrey.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: AppColors.primaryGrey),
                                  ),
                                  child: Center(
                                    child: TextSemiBold(
                                      'Current Plan',
                                      fontSize: 16,
                                      color: AppColors.primaryGrey,
                                    ),
                                  ),
                                );
                              }

                              // can upgrade - show upgrade button
                              if (canUpgrade) {
                                return BusyButton(
                                  width: screenWidth(context) * 0.7,
                                  title: "Upgrade",
                                  isLoading: controller.isUpgrading,
                                  onTap: controller.isUpgrading
                                      ? () {}
                                      : () {
                                          _showUpgradeConfirmationDialog(
                                            context,
                                            plan,
                                            () =>
                                                controller.upgradePlan(plan.id),
                                          );
                                        },
                                );
                              }

                              // lower plan - hide button (can't downgrade)
                              return const SizedBox.shrink();
                            }),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Page indicator
            Obx(() => _buildPageIndicator()),
            const Gap(20),
          ],
        );
      }),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        controller.plans.length,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: controller.currentPlanIndex == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: controller.currentPlanIndex == index
                ? AppColors.primaryGreen
                : AppColors.primaryGrey.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _planCard(String title) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.primaryGrey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          SvgPicture.asset(AppAsset.greenTick),
          const Gap(12),
          Expanded(
            child: TextSemiBold(
              title,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showUpgradeConfirmationDialog(
      BuildContext context, dynamic plan, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextBold(
                "Confirm Upgrade",
                fontSize: 18,
                fontWeight: FontWeight.w700,
                style: const TextStyle(fontFamily: AppFonts.manRope),
              ),
              const Gap(16),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    fontFamily: AppFonts.manRope,
                    fontSize: 14,
                    color: AppColors.textPrimaryColor,
                  ),
                  children: [
                    const TextSpan(
                        text: "Your wallet will be debited with the sum of "),
                    TextSpan(
                      text: "${plan.nairaSymbol}",
                      style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700),
                    ),
                    TextSpan(
                      text: "${plan.priceAmount}",
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const TextSpan(text: " for "),
                    TextSpan(
                      text: plan.name.toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const TextSpan(
                        text:
                            " Plan. Kindly note that this is not reversible.x"),
                  ],
                ),
              ),
              const Gap(24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: AppColors.primaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: TextSemiBold(
                        "Cancel",
                        color: AppColors.primaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Gap(16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        onConfirm();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: TextSemiBold(
                        "Proceed",
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
