import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:mcd/core/import/imports.dart';

import './spin_win_module_controller.dart';

class SpinWinModulePage extends GetView<SpinWinModuleController> {
  const SpinWinModulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const PaylonyAppBarTwo(
        title: "Spin & Win",
        centerTitle: false,
      ),
      body: Obx(() {
        if (controller.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryColor),
          );
        }

        // Show error state if no items
        if (controller.spinItems.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 60,
                  color: AppColors.primaryGrey,
                ),
                const Gap(16),
                TextSemiBold(
                  'No spin items available',
                  fontSize: 16,
                  color: AppColors.primaryGrey,
                ),
                const Gap(24),
                BusyButton(
                  title: 'Retry',
                  onTap: controller.fetchSpinData,
                  width: 120,
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome text
              TextBold(
                "Welcome to SPIN & WIN.",
                fontSize: 20,
                fontWeight: FontWeight.w700,
                style: const TextStyle(fontFamily: AppFonts.manRope),
              ),
              const Gap(10),
              // Instructions text
              controller.chancesRemaining <= 0
                  ? SizedBox.shrink()
                  : Text(
                      controller.freeSpinsRemaining > 0
                          ? "You have ${controller.freeSpinsRemaining} FREE spin(s)! No ads required. Spin now and claim your reward if you win."
                          : "No Free Spin! But you can spin by watching Ads, you have 5 chances. Click on Roll Button below",
                      // : "You have 5 chances every 5 hours. You must watch 5 ads before each spin. Use correct recipient details as refunds won't be made for errors.",
                      style: const TextStyle(
                        fontFamily: AppFonts.manRope,
                        fontSize: 13,
                        height: 1.5,
                        color: Colors.black87,
                      ),
                    ),

              // free spins with progressive upgrade prompts
              if (controller.chancesRemaining <= 0) ...[
                const SizedBox.shrink()
              ] else ...[
                _buildFreeSpinSection(controller),
              ],

              const Gap(40),
              // Fortune Wheel
              Center(
                child: SizedBox(
                  height: 350,
                  child: FortuneWheel(
                    selected: controller.selectedStream,
                    items: controller.spinItems
                        .map((item) => FortuneItem(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              style: FortuneItemStyle(
                                color: _getItemColor(
                                    controller.spinItems.indexOf(item)),
                                borderColor: Colors.white,
                                borderWidth: 2,
                              ),
                            ))
                        .toList(),
                    animateFirst: false,
                    indicators: const [
                      FortuneIndicator(
                        alignment: Alignment.topCenter,
                        child: TriangleIndicator(
                          color: Colors.amber,
                          width: 30.0,
                          height: 30.0,
                        ),
                      ),
                    ],
                    onAnimationEnd: () {
                      // Animation completed
                    },
                  ),
                ),
              ),
              const Gap(10),

              // Ad progress indicator when playing ads
              if (controller.isPlayingAds) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      const CircularProgressIndicator(
                        color: AppColors.primaryColor,
                        strokeWidth: 3,
                      ),
                      const Gap(16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextSemiBold(
                              'Watching Ads: ${controller.adsWatched}/5',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            const Gap(4),
                            Text(
                              'Please complete all ads to spin',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.blue.shade700,
                                fontFamily: AppFonts.manRope,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(20),
              ],

              // Chances remaining
              Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xffF9F9F9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xffE5E5E5)),
                  ),
                  child: TextSemiBold(
                    "Chances Remaining: ${controller.chancesRemaining}/5",
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    style: const TextStyle(fontFamily: AppFonts.manRope),
                  ),
                ),
              ),
              const Gap(20),
              // Roll button
              controller.chancesRemaining <= 0
                  ? SizedBox.shrink()
                  : SizedBox(
                      width: double.infinity,
                      child: Obx(() => BusyButton(
                            title: controller.freeSpinsRemaining > 0
                                ? "Roll (Free)"
                                : "Roll (Watch Ads)",
                            isLoading: controller.isSpinning ||
                                controller.isPlayingAds,
                            onTap: controller.isSpinning ||
                                    controller.isPlayingAds ||
                                    controller.chancesRemaining <= 0
                                ? () {}
                                : () => controller.performSpin(),
                          )),
                    ),

              // Info text when no chances left with countdown
              if (controller.chancesRemaining == 0) ...[
                const Gap(20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.timer_outlined, color: Colors.orange.shade700),
                      const Gap(12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'No chances left',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.orange.shade900,
                                fontFamily: AppFonts.manRope,
                              ),
                            ),
                            if (controller.timeUntilReset.isNotEmpty) ...[
                              const Gap(4),
                              Text(
                                'Resets in: ${controller.timeUntilReset}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade700,
                                  fontFamily: AppFonts.manRope,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(10),
                controller.adsService.showBannerAdWidget()
              ],
            ],
          ),
        );
      }),
    );
  }

  // Generate alternating purple/green colors for wheel segments
  Color _getItemColor(int index) {
    final colors = [
      const Color(0xFF7E57C2), // Deep purple
      const Color(0xFF4CAF50), // Green (matching primary color)
      const Color(0xFF9575CD), // Medium purple
      const Color(0xFF66BB6A), // Light green
      const Color(0xFFB39DDB), // Light purple
      const Color(0xFF81C784), // Medium green
    ];
    return colors[index % colors.length];
  }

  // progressive free spin section with upgrade prompts
  Widget _buildFreeSpinSection(SpinWinModuleController controller) {
    final remaining = controller.freeSpinsRemaining;
    final max = controller.maxFreeSpins;
    final isFreePlan = max == 0;
    final isDepleted = remaining == 0 && max > 0;
    final isLastSpin = remaining == 1;

    // free plan - always show upgrade prompt
    if (isFreePlan) {
      return Column(
        children: [
          const Gap(16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.stars_outlined,
                        color: Colors.blue.shade700, size: 20),
                    const Gap(8),
                    Expanded(
                      child: Text(
                        'Free Spins: 0',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: AppFonts.manRope,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(8),
                Text(
                  'Your plan doesn\'t include free monthly spins. Upgrade to get up to 10 free spins monthly!',
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: AppFonts.manRope,
                    color: Colors.blue.shade800,
                  ),
                ),
                const Gap(8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Get.toNamed(Routes.MORE_MODULE,
                        arguments: {'initialTab': 2}),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'View Plans',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // depleted state - show full upgrade card
    if (isDepleted) {
      return Column(
        children: [
          const Gap(16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.stars_outlined,
                        color: Colors.orange.shade700, size: 20),
                    const Gap(8),
                    Text(
                      'Free Spins: 0/$max',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: AppFonts.manRope,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ],
                ),
                const Gap(8),
                Text(
                  'You\'ve used all your free spins. Upgrade for more!',
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: AppFonts.manRope,
                    color: Colors.orange.shade800,
                  ),
                ),
                const Gap(8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Get.toNamed(Routes.MORE_MODULE,
                        arguments: {'initialTab': 1}),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Upgrade Now',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // last spin - show counter with upgrade hint
    if (isLastSpin) {
      return Column(
        children: [
          const Gap(16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.stars, color: Colors.orange),
                const Gap(12),
                Expanded(
                  child: Row(
                    children: [
                      TextSemiBold(
                        "Free Spins: $remaining/$max",
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange.shade700,
                      ),
                      const Gap(8),
                      GestureDetector(
                        onTap: () => Get.toNamed(Routes.MORE_MODULE,
                            arguments: {'initialTab': 1}),
                        child: Text(
                          '• Upgrade for more',
                          style: TextStyle(
                            fontSize: 11,
                            fontFamily: AppFonts.manRope,
                            color: AppColors.primaryColor,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // normal state - just show counter
    if (remaining > 0) {
      return Column(
        children: [
          const Gap(16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border:
                  Border.all(color: AppColors.primaryColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.stars, color: AppColors.primaryColor),
                const Gap(12),
                Expanded(
                  child: TextSemiBold(
                    "Free Spins: $remaining/$max",
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}
