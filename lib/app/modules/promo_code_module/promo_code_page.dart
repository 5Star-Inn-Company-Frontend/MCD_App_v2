import 'package:mcd/app/modules/promo_code_module/promo_code_controller.dart';
import 'package:mcd/core/import/imports.dart';

class PromoCodePage extends GetView<PromoCodeController> {
  const PromoCodePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const PaylonyAppBarTwo(
        title: "Promo Code",
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Hero Banner Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.purpleColor, Color(0xFF3B2E92)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.purpleColor.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/reward_centre/promo-code.png',
                    height: 60,
                    width: 60,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.card_giftcard,
                      size: 60,
                      color: AppColors.white,
                    ),
                  ),
                  const Gap(12),
                  TextBold(
                    'Win Discount Promo Codes',
                    fontSize: 22,
                    color: AppColors.white,
                    textAlign: TextAlign.center,
                  ),
                  const Gap(8),
                  const Text(
                    'Watch video advertisements to win discount codes that apply directly to your airtime, data, bills, and utility payments!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppFonts.manRope,
                      fontSize: 14,
                      color: AppColors.white,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const Gap(24),

            // Active Saved Promo Code Card (if available)
            Obx(() {
              final code = controller.savedPromoCode.value;
              final message = controller.savedPromoMessage.value;
              if (code.isEmpty) return const SizedBox.shrink();

              return Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xffF3FFF7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primaryColor,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.stars_rounded,
                                color: AppColors.primaryColor, size: 24),
                            const Gap(8),
                            TextBold(
                              'Active Promo Code',
                              fontSize: 15,
                              color: AppColors.background,
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: controller.clearSavedCode,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Clear',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.redAccent,
                              fontFamily: AppFonts.manRope,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Gap(12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.primaryColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              code,
                              style: const TextStyle(
                                fontFamily: AppFonts.manRope,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryColor,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: controller.copyPromoCode,
                            icon: const Icon(Icons.copy_rounded,
                                color: AppColors.primaryColor, size: 22),
                            tooltip: 'Copy Code',
                          ),
                        ],
                      ),
                    ),
                    if (message.isNotEmpty) ...[
                      const Gap(8),
                      Text(
                        message,
                        style: const TextStyle(
                          fontFamily: AppFonts.manRope,
                          fontSize: 12.5,
                          color: AppColors.primaryGrey2,
                        ),
                      ),
                    ],
                    const Gap(8),
                    const Text(
                      '💡 Tip: This promo code will automatically populate when you pay for utilities at checkout.',
                      style: TextStyle(
                        fontFamily: AppFonts.manRope,
                        fontSize: 12,
                        color: AppColors.primaryColor2,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }),

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
                    'How to Win:',
                    fontSize: 16,
                    color: AppColors.background,
                  ),
                  const Gap(16),
                  _buildStepRow(
                    stepNumber: '1',
                    title: 'Click "Watch Advert to Win"',
                    subtitle: 'Tap the watch button below to request a video ad.',
                  ),
                  const Gap(14),
                  _buildStepRow(
                    stepNumber: '2',
                    title: 'Watch the Video Completely',
                    subtitle: 'Ensure you watch the full ad without closing.',
                  ),
                  const Gap(14),
                  _buildStepRow(
                    stepNumber: '3',
                    title: 'Get Discount Code',
                    subtitle: 'Win discount promo codes to use during bill checkout!',
                  ),
                ],
              ),
            ),
            const Gap(24),

            // Primary Action Button
            Obx(() {
              final isLoading = controller.isLoading.value;
              return SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: isLoading ? null : controller.tryWinPromoCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.purpleColor,
                    disabledBackgroundColor: AppColors.purpleColor.withOpacity(0.6),
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
                            const Icon(Icons.card_giftcard_rounded,
                                color: AppColors.white, size: 22),
                            const Gap(8),
                            TextBold(
                              'Watch Advert to Win Promo Code',
                              fontSize: 15,
                              color: AppColors.white,
                            ),
                          ],
                        ),
                ),
              );
            }),
            const Gap(24),

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
            color: AppColors.purpleColor,
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
