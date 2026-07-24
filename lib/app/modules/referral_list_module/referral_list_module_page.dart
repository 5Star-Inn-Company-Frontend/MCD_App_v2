import 'package:mcd/core/import/imports.dart';
import './referral_list_module_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ReferralListModulePage extends GetView<ReferralListModuleController> {
  const ReferralListModulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: TextBold(
          'Referral List',
          fontSize: 20,
          color: AppColors.textPrimaryColor,
          fontWeight: FontWeight.w700,
        ),
        elevation: 0.0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimaryColor),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primaryGreen,
            ),
          );
        }

        if (controller.errorMessage.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.primaryGrey2,
                ),
                const Gap(16),
                TextSemiBold(
                  controller.errorMessage.value,
                  fontSize: 16,
                  color: AppColors.primaryGrey2,
                  textAlign: TextAlign.center,
                ),
                const Gap(24),
                ElevatedButton(
                  onPressed: controller.refresh,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                  child: TextSemiBold(
                    'Retry',
                    fontSize: 14,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          );
        }

        if (controller.referralList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // SvgPicture.asset(
                //   'assets/icons/empty_state.svg',
                //   height: 120,
                // ),
                // const Gap(24),
                TextSemiBold(
                  'No Referrals Yet',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
                const Gap(8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: TextSemiBold(
                    'Share your referral code to start earning bonuses',
                    fontSize: 14,
                    color: AppColors.primaryGrey2,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refresh,
          color: AppColors.primaryGreen,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: controller.referralList.length,
            separatorBuilder: (context, index) => const Gap(12),
            itemBuilder: (context, index) {
              final referral = controller.referralList[index];
              return _buildReferralCard(referral);
            },
          ),
        );
      }),
    );
  }

  Widget _buildReferralCard(dynamic referral) {
    final username = referral['user_name'] ?? 'Unknown';
    final date = referral['reg_date'] ?? '';
    final plan = referral['referral_plan'] ?? 'free';
    final photo = referral['photo']?.toString().trim() ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.primaryGrey.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGrey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: photo.isEmpty
                  ? TextSemiBold(
                      username.isNotEmpty ? username[0].toUpperCase() : '?',
                      fontSize: 20,
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.w700,
                    )
                  : ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: photo,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        errorWidget: (context, error, stackTrace) {
                          return TextSemiBold(
                            username.isNotEmpty ? username[0].toUpperCase() : '?',
                            fontSize: 20,
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.w700,
                          );
                        },
                      ),
                    ),
            ),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextSemiBold(
                  username,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                if (date.isNotEmpty) ...[
                  const Gap(4),
                  TextSemiBold(
                    'Joined: $date',
                    fontSize: 12,
                    color: AppColors.primaryGrey2,
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: plan.toLowerCase() == 'premium'
                  ? AppColors.primaryGreen.withOpacity(0.2)
                  : AppColors.primaryGrey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextSemiBold(
              plan.toUpperCase(),
              fontSize: 10,
              color: plan.toLowerCase() == 'premium'
                  ? AppColors.primaryGreen
                  : AppColors.primaryGrey2,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
