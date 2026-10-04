import 'package:mcd/app/modules/free_money_module/free_money_module_controller.dart';
import 'package:mcd/core/import/imports.dart';

class FreeMoneyModulePage extends GetView<FreeMoneyModuleController> {
  const FreeMoneyModulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const PaylonyAppBarTwo(
        title: "Free Money",
        centerTitle: false,
      ),
      body: RefreshIndicator(
        color: AppColors.primaryColor,
        backgroundColor: AppColors.white,
        onRefresh: controller.refreshRemoteConfig,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Reward Banner Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryColor, Color(0xFF1B8A53)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/reward_centre/free-money.png',
                    height: 60,
                    width: 60,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.monetization_on_rounded,
                      size: 60,
                      color: AppColors.white,
                    ),
                  ),
                  const Gap(12),
                  TextBold(
                    'Earn Free Money',
                    fontSize: 22,
                    color: AppColors.white,
                    textAlign: TextAlign.center,
                  ),
                  const Gap(8),
                  Obx(() => Text(
                        'Watch short video advertisements and earn ₦${controller.freeMoneyAmount} directly into your wallet balance for every ad watched!',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: AppFonts.manRope,
                          fontSize: 14,
                          color: AppColors.white,
                          height: 1.4,
                        ),
                      )),
                ],
              ),
            ),
            const Gap(24),

            // How it Works Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.filledBorderIColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextBold(
                    'How to Earn:',
                    fontSize: 16,
                    color: AppColors.background,
                  ),
                  const Gap(16),
                  _buildStepRow(
                    stepNumber: '1',
                    title: 'Click "Watch Advert to Earn"',
                    subtitle: 'Tap the watch button below to request a video ad.',
                  ),
                  const Gap(14),
                  _buildStepRow(
                    stepNumber: '2',
                    title: 'Watch the Full Video',
                    subtitle: 'Keep the video running until it finishes playing.',
                  ),
                  const Gap(14),
                  _buildStepRow(
                    stepNumber: '3',
                    title: 'Get Instant Wallet Credit',
                    subtitle: 'Your wallet will be credited automatically upon ad completion.',
                  ),
                ],
              ),
            ),
            const Gap(20),

            // Session Stats Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xffF3FFF7),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primaryColor.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.play_circle_fill_rounded,
                          color: AppColors.primaryColor, size: 28),
                      const Gap(10),
                      TextSemiBold(
                        'Session Videos Watched',
                        fontSize: 14,
                        color: AppColors.background,
                      ),
                    ],
                  ),
                  Obx(() => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextBold(
                          '${controller.adsWatchedCount.value}',
                          fontSize: 14,
                          color: AppColors.white,
                        ),
                      )),
                ],
              ),
            ),
            const Gap(24),

            // Action Button (Reactively listens to RemoteConfig and loading state)
            Obx(() {
              final isLoading = controller.isWatchingAd.value;
              final isShowRepeatEnabled = controller.isShowRepeatEnabled;

              final String buttonTitle = isShowRepeatEnabled
                  ? 'Watch Multiple Advert to Earn'
                  : 'Watch Advert to Earn';

              final VoidCallback? onButtonTap = isLoading
                  ? null
                  : () {
                      if (isShowRepeatEnabled) {
                        controller.watchMultipleRewardedAds(context);
                      } else {
                        controller.watchSingleAd();
                      }
                    };

              return Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: onButtonTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        disabledBackgroundColor:
                            AppColors.primaryColor.withOpacity(0.6),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: AppColors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.ondemand_video_rounded,
                                    color: AppColors.white, size: 22),
                                const Gap(8),
                                TextBold(
                                  buttonTitle,
                                  fontSize: 16,
                                  color: AppColors.white,
                                ),
                              ],
                            ),
                    ),
                  ),
                  const Gap(24),
                ],
              );
            }),

            // Embedded Native Ad Section
            Center(
              child: SizedBox(
                height: 280,
                width: double.infinity,
                child: controller.adsService.showNativeAdWidget(context),
              ),
            ),
            const Gap(16),
            SizedBox(
              width: double.infinity,
              child: controller.adsService.showBannerAdWidget(),
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildStepRow({
    required String stepNumber,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.primaryColor,
            shape: BoxShape.circle,
          ),
          child: TextBold(
            stepNumber,
            fontSize: 13,
            color: AppColors.white,
          ),
        ),
        const Gap(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextSemiBold(
                title,
                fontSize: 14,
                color: AppColors.background,
              ),
              const Gap(2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontFamily: AppFonts.manRope,
                  fontSize: 12.5,
                  color: AppColors.primaryGrey2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
