import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:mcd/app/styles/app_colors.dart';
import 'package:mcd/app/widgets/app_bar-two.dart';
import 'package:mcd/core/constants/fonts.dart';

import './game_centre_module_controller.dart';

class GameCentreModulePage extends GetView<GameCentreModuleController> {
  const GameCentreModulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PaylonyAppBarTwo(
        title: "Game Centre",
        centerTitle: false,
      ),
      body: Obx(() {
        // Loading state
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // Error state
        if (controller.errorMessage.value != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 60,
                    color: AppColors.errorBgColor,
                  ),
                  const Gap(16),
                  Text(
                    controller.errorMessage.value ?? 'An error occurred',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.primaryGrey2,
                      fontFamily: AppFonts.manRope,
                    ),
                  ),
                  const Gap(24),
                  ElevatedButton(
                    onPressed: controller.retryFetch,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'Retry',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: AppFonts.manRope,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Empty state
        if (controller.games.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.sports_esports_outlined,
                  size: 80,
                  color: AppColors.primaryGrey2.withOpacity(0.5),
                ),
                const Gap(16),
                const Text(
                  'No games available',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.primaryGrey2,
                    fontFamily: AppFonts.manRope,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Gap(8),
                const Text(
                  'Check back later for new games',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.primaryGrey2,
                    fontFamily: AppFonts.manRope,
                  ),
                ),
              ],
            ),
          );
        }

        // Games list
        return RefreshIndicator(
          onRefresh: controller.fetchGames,
          color: AppColors.primaryColor,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Available Games',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: AppFonts.manRope,
                  color: AppColors.background,
                ),
              ),
              const Gap(8),
              Text(
                'Play games and earn rewards',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.primaryGrey2,
                  fontFamily: AppFonts.manRope,
                ),
              ),
              const Gap(20),
              ...controller.games.map((game) => _buildGameCard(game)).toList(),
              controller.adsService.showBannerAdWidget(),
              const Gap(20),
              controller.adsService.showBannerAdWidget()
            ],
          ),
        );
      }),
    );
  }

  Widget _buildGameCard(dynamic game) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffF0F0F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => controller.openGame(game),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Game Logo
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: game.logo,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 60,
                      height: 60,
                      color: AppColors.boxColor,
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 60,
                      height: 60,
                      color: AppColors.boxColor,
                      child: const Icon(
                        Icons.sports_esports,
                        color: AppColors.primaryGrey2,
                      ),
                    ),
                  ),
                ),
                const Gap(12),
                // Game Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        game.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: AppFonts.manRope,
                          color: AppColors.background,
                        ),
                      ),
                      const Gap(4),
                      Text(
                        'Tap to play and earn rewards',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.primaryGrey2,
                          fontFamily: AppFonts.manRope,
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(8),
                // Arrow Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xffF3FFF7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColors.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
