import 'package:get_storage/get_storage.dart';
import 'package:mcd/core/import/imports.dart';

import './reward_centre_module_controller.dart';

class RewardCentreModulePage extends GetView<RewardCentreModuleController> {
  const RewardCentreModulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PaylonyAppBarTwo(
        title: "Reward Centre",
        centerTitle: false,
      ),
      body: Obx(() {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          child: GridView(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
            children: [
              if (controller.service['giveaway'] == '1')
                InkWell(
                  onTap: () {
                    Get.toNamed(Routes.GIVEAWAY_MODULE);
                  },
                  child: AspectRatio(
                      aspectRatio: 3 / 2,
                      child: _boxCard('assets/icons/hold-seeds-filled.png',
                          "Give away", 'Create and claim giveaways')),
                ),
              if (controller.service['freemoney'] == '1')
                InkWell(
                  onTap: () {
                    controller.freemoney();
                  },
                  child: AspectRatio(
                      aspectRatio: 3 / 2,
                      child: _boxCard(
                          'assets/images/reward_centre/free-money.png',
                          "Free Money",
                          'Watch advert and get paid for it')),
                ),
              InkWell(
                onTap: () {
                  controller.tryWinPromoCode();
                },
                child: AspectRatio(
                    aspectRatio: 3 / 2,
                    child: _boxCard(
                        'assets/images/reward_centre/promo-code.png',
                        "Promo Code",
                        'Watch advert and get promo code')),
              ),
              if (controller.service['spinwin'] == '1')
                InkWell(
                  onTap: () {
                    Get.toNamed(Routes.SPIN_WIN_MODULE);
                  },
                  child: AspectRatio(
                      aspectRatio: 3 / 2,
                      child: _boxCard('assets/images/reward_centre/spinwin.png',
                          "Spin & Win", 'Spin and win airtime,data and more')),
                ),
              if (controller.service['predictwin'] == '1')
                InkWell(
                  onTap: () {
                    Get.toNamed(Routes.PREDICT_WIN_MODULE);
                  },
                  child: AspectRatio(
                      aspectRatio: 3 / 2,
                      child: _boxCard(
                          'assets/images/reward_centre/spinwin.png',
                          "Predict and Win",
                          'Predict match outcomes and win rewards')),
                ),
              InkWell(
                onTap: () {
                  Get.toNamed(Routes.LEADERBOARD_MODULE);
                },
                child: AspectRatio(
                    aspectRatio: 3 / 5,
                    child: _boxCard(
                        'assets/images/reward_centre/leaderboard.png',
                        "Leaderboard",
                        'Earn points via purchases and climb the ranks to become MCD customer of the Year')),
              ),
              InkWell(
                onTap: () {
                  Get.toNamed(Routes.GAME_CENTRE_MODULE);
                },
                child: AspectRatio(
                    aspectRatio: 3 / 2,
                    child: _boxCard(
                        'assets/images/reward_centre/game-centre.png',
                        "Game Centre",
                        'Play games and earn rewards')),
              ),
              controller.adsService.showBannerAdWidget()
            ],
          ),
        );
      }),
    );
  }

  Widget _boxCard(String image, String title, String text) {
    return Container(
      height: 300,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
          color: const Color(0xffF3FFF7),
          border: Border.all(color: const Color(0xffF0F0F0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Image.asset(
            image,
            width: 26,
            height: 26,
          ),
          const Gap(10),
          TextSemiBold(
            title,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          const Gap(12),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: AppFonts.manRope,
            ),
          )
        ],
      ),
    );
  }

  bool _isPromoEnabled() {
    final box = GetStorage();
    final storedValue = box.read('promo_enabled');
    if (storedValue is bool) {
      return storedValue;
    } else if (storedValue is String) {
      return storedValue.toLowerCase() == 'true';
    }
    return false;
  }
}
