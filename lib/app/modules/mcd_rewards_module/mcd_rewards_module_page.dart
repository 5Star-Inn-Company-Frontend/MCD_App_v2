import 'package:flutter_animate/flutter_animate.dart';
import 'package:mcd/app/modules/leaderboard_module/models/leaderboard_model.dart';
import 'package:mcd/app/widgets/custom_bottom_sheet.dart';
import 'package:mcd/core/utils/amount_formatter.dart';
import 'package:webview_flutter/webview_flutter.dart';
import './mcd_rewards_module_controller.dart';
import 'package:mcd/core/import/imports.dart';

class McdRewardsModulePage extends GetView<McdRewardsModuleController> {
  const McdRewardsModulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF269E5F)),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: Column(
          children: const [
            Text(
              'MCD Rewards',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.background,
                fontFamily: AppFonts.manRope,
              ),
            ),
            Gap(2),
            Text(
              '5Star Inn Company',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Color(0xFF888888),
                fontFamily: AppFonts.manRope,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.card_giftcard_outlined,
                color: Color(0xFF269E5F), size: 23),
            onPressed: controller.goToEarnTab,
          ),
          const Gap(4),
        ],
      ),
      body: RefreshIndicator(
        color: const Color(0xFF269E5F),
        onRefresh: controller.refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Gap(10),
              Obx(() => _buildHeroCard(context)),
              const Gap(10),
              _buildRewardMomentsBanner(),
              const Gap(16),
              Obx(() => _buildTabsBar()),
              const Gap(16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Obx(() {
                  Widget tabContent;
                  switch (controller.selectedTabIndex.value) {
                    case 0:
                      tabContent = _buildLeaderboardTab();
                      break;
                    case 1:
                      tabContent = _buildEarnTab(context);
                      break;
                    case 2:
                      tabContent = _buildRewardTab(context);
                      break;
                    case 3:
                      tabContent = _buildHelpTab();
                      break;
                    default:
                      tabContent = _buildLeaderboardTab();
                  }
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.04, 0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: KeyedSubtree(
                      key: ValueKey(controller.selectedTabIndex.value),
                      child: tabContent,
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF269E5F),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0x33FFFFFF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.military_tech_outlined,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const Gap(12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AmountUtil.formatFigure(
                        controller.userPoints.toDouble()),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      fontFamily: AppFonts.manRope,
                    ),
                  ),
                  Text(
                    'Total points',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      fontFamily: AppFonts.manRope,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Rank #${controller.userRank > 0 ? controller.userRank : '-'}',
                  style: const TextStyle(
                    color: Color(0xFF269E5F),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    fontFamily: AppFonts.manRope,
                  ),
                ),
              )
                  .animate(delay: 150.ms)
                  .scale(
                    begin: const Offset(0.85, 0.85),
                    end: const Offset(1, 1),
                    duration: 350.ms,
                    curve: Curves.easeOutBack,
                  )
                  .fadeIn(duration: 250.ms),
            ],
          ),
          const Gap(16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                controller.progressSubtitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  fontFamily: AppFonts.manRope,
                ),
              ),
              Text(
                controller.progressPercentText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  fontFamily: AppFonts.manRope,
                ),
              ),
            ],
          ),
          const Gap(8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              height: 8,
              color: const Color(0x40FFFFFF),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutCubic,
                      width: constraints.maxWidth *
                          controller.progressRatio,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const Gap(6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${AmountUtil.formatFigure(controller.userPoints.toDouble())} pts',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  fontFamily: AppFonts.manRope,
                ),
              ),
              Text(
                '${AmountUtil.formatFigure(controller.targetPoints.toDouble())} pts',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  fontFamily: AppFonts.manRope,
                ),
              ),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 380.ms)
        .slideY(begin: -0.04, end: 0, curve: Curves.easeOutQuad);
  }

  Widget _buildRewardMomentsBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 3.5,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF269E5F),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const Gap(10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Reward moments',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.background,
                    fontFamily: AppFonts.manRope,
                  ),
                ),
                Gap(2),
                Text(
                  'Meet our previous winners',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6B7280),
                    fontFamily: AppFonts.manRope,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: controller.goToRewardTab,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF269E5F),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'View Reward',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      fontFamily: AppFonts.manRope,
                    ),
                  ),
                  Gap(4),
                  Icon(Icons.north_east_rounded,
                      size: 13, color: Colors.white),
                ],
              ),
            ),
          ),
        ],
      ),
    )
        .animate(delay: 80.ms)
        .fadeIn(duration: 380.ms)
        .slideY(begin: 0.04, end: 0, curve: Curves.easeOutQuad);
  }

  Widget _buildTabsBar() {
    final tabs = ['Leaderboard', 'Earn', 'Reward', 'Help'];
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(tabs.length, (index) {
          final isSelected = controller.selectedTabIndex.value == index;
          return InkWell(
            onTap: () => controller.setTab(index),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: AnimatedScale(
                      scale: isSelected ? 1.04 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutCubic,
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          fontFamily: AppFonts.manRope,
                          color: isSelected
                              ? const Color(0xFF269E5F)
                              : const Color(0xFF6B7280),
                        ),
                        child: Text(tabs[index]),
                      ),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 240),
                    curve: Curves.easeInOutCubic,
                    height: 2.5,
                    width: isSelected ? 50 : 0,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF269E5F)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF2E7D32),
          fontSize: 11,
          fontWeight: FontWeight.w600,
          fontFamily: AppFonts.manRope,
        ),
      ),
    );
  }

  Widget _buildLeaderboardTab() {
    final users = controller.allUsers;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTag('Top performers'),
        const Gap(12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'Leaderboard',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.background,
                fontFamily: AppFonts.manRope,
              ),
            ),
            Icon(Icons.emoji_events_outlined,
                color: Color(0xFF269E5F), size: 22),
          ],
        ),
        const Gap(14),
        if (controller.isLoading && users.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(color: Color(0xFF269E5F)),
            ),
          )
        else if (users.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: Text(
                'No leaderboard records yet.',
                style: TextStyle(
                  fontFamily: AppFonts.manRope,
                  color: Color(0xFF6B7280),
                ),
              ),
            ),
          )
        else
          ...users.asMap().entries.map((entry) {
            final index = entry.key;
            final user = entry.value;
            final isCurrentUser = user.userName.toLowerCase() ==
                controller.currentUserName.toLowerCase();
            return _buildLeaderboardItem(user, index, isCurrentUser);
          }),
      ],
    );
  }

  Widget _buildLeaderboardItem(
      LeaderboardUser user, int index, bool isCurrentUser) {
    Widget leadingWidget;
    if (index == 0) {
      leadingWidget = Container(
        width: 45,
        height: 45,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: AssetImage('assets/images/leaderboard/lead1.png'),
            fit: BoxFit.cover,
          ),
        ),
      );
    } else if (index == 1) {
      leadingWidget = Container(
        width: 45,
        height: 45,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: AssetImage('assets/images/leaderboard/lead2.png'),
            fit: BoxFit.cover,
          ),
        ),
      );
    } else if (index == 2) {
      leadingWidget = Container(
        width: 45,
        height: 45,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: AssetImage('assets/images/leaderboard/lead3.png'),
            fit: BoxFit.cover,
          ),
        ),
      );
    } else {
      leadingWidget = Container(
        width: 45,
        height: 45,
        decoration: const BoxDecoration(
          color: Color(0xFFE8F5E9),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          '${index + 1}',
          style: const TextStyle(
            color: Color(0xFF2E7D32),
            fontSize: 15,
            fontWeight: FontWeight.w700,
            fontFamily: AppFonts.manRope,
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isCurrentUser
              ? const Color(0xFF269E5F)
              : Colors.grey.shade200,
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          leadingWidget,
          const Gap(12),
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    user.userName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontFamily: AppFonts.manRope,
                      color: AppColors.background,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                if (isCurrentUser) ...[
                  const Gap(6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'You',
                      style: TextStyle(
                        color: Color(0xFF2E7D32),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        fontFamily: AppFonts.manRope,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Gap(12),
          Text(
            '${AmountUtil.formatFigure(user.pointsValue.toDouble())} pts',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              fontFamily: AppFonts.manRope,
              color: AppColors.primaryColor,
            ),
          ),
        ],
      ),
    )
        .animate(delay: (index * 40).ms)
        .slideY(begin: 0.08, curve: Curves.easeOutQuad)
        .fadeIn(duration: 300.ms);
  }

  Widget _buildEarnTab(BuildContext context) {
    final activities = [
      {
        'title': 'Daily Bonus',
        'subtitle': 'Your daily reward',
        'linkText': 'Daily bonus',
        'icon': Icons.card_giftcard_rounded,
        'action': controller.openDailyBonus,
      },
      {
        'title': 'Refer & Earn',
        'subtitle': 'Invite your friends',
        'linkText': 'Referral offer',
        'icon': Icons.people_outline_rounded,
        'action': controller.openReferAndEarn,
      },
      {
        'title': 'Buy Airtime',
        'subtitle': 'Daily Topup',
        'linkText': 'Purchase Airtime',
        'icon': Icons.phone_android_rounded,
        'action': () => _showCountrySelectionBottomSheet(
              context: context,
              serviceKeyNigeria: 'airtime',
              serviceKeyForeign: 'foreign_airtime',
              serviceName: 'Airtime',
              redirectTo: Routes.AIRTIME_MODULE,
            ),
      },
      {
        'title': 'Buy Data',
        'subtitle': 'Daily recharge',
        'linkText': 'Purchase Data',
        'icon': Icons.wifi_rounded,
        'action': () => _showCountrySelectionBottomSheet(
              context: context,
              serviceKeyNigeria: 'data',
              serviceKeyForeign: 'foreign_data',
              serviceName: 'Data',
              redirectTo: Routes.DATA_MODULE,
            ),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTag('Loyalty'),
        const Gap(12),
        const Text(
          'Earning activities',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.background,
            fontFamily: AppFonts.manRope,
          ),
        ),
        const Gap(14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: activities.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.98,
          ),
          itemBuilder: (context, index) {
            final item = activities[index];
            return InkWell(
              onTap: item['action'] as VoidCallback,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF0F0F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(item['icon'] as IconData,
                        size: 32, color: const Color(0xFF269E5F)),
                    const Gap(10),
                    Text(
                      item['title'] as String,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.background,
                        fontFamily: AppFonts.manRope,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Gap(3),
                    Text(
                      item['subtitle'] as String,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF6B7280),
                        fontFamily: AppFonts.manRope,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Gap(10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          item['linkText'] as String,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF269E5F),
                            fontFamily: AppFonts.manRope,
                          ),
                        ),
                        const Gap(3),
                        const Icon(Icons.north_east_rounded,
                            size: 12, color: Color(0xFF269E5F)),
                      ],
                    ),
                  ],
                ),
              ),
            )
                .animate(delay: (index * 60).ms)
                .fadeIn(duration: 320.ms)
                .slideY(begin: 0.08, end: 0, curve: Curves.easeOutQuad);
          },
        ),
      ],
    );
  }

  Widget _buildRewardTab(BuildContext context) {
    final story = controller.primaryWinnerStory;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTag(
            story?.tag.isNotEmpty == true ? story!.tag : 'Winner stories'),
        const Gap(12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              story?.winnerName.isNotEmpty == true
                  ? story!.winnerName
                  : 'Previous winners',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.background,
                fontFamily: AppFonts.manRope,
              ),
            ),
            const Icon(Icons.ondemand_video_rounded,
                color: Color(0xFF269E5F), size: 22),
          ],
        ),
        const Gap(14),
        if (controller.hasWinnerVideo)
          InkWell(
            onTap: () {
              if (story != null) {
                _openInAppVideo(context, story);
              } else {
                controller.openWinnerVideo();
              }
            },
            borderRadius: BorderRadius.circular(18),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFF0F0F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFF1E293B),
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(18)),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (story != null &&
                              story.effectiveThumbnail.isNotEmpty)
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(18)),
                              child: Image.network(
                                story.effectiveThumbnail,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Opacity(
                                    opacity: 0.25,
                                    child: Image.asset(
                                      'assets/images/mcdagentlogo.png',
                                      width: 110,
                                    ),
                                  );
                                },
                              ),
                            )
                          else
                            Opacity(
                              opacity: 0.25,
                              child: Image.asset(
                                'assets/images/mcdagentlogo.png',
                                width: 110,
                              ),
                            ),
                          Container(
                            width: 52,
                            height: 52,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              color: Color(0xFF269E5F),
                              size: 34,
                            ),
                          )
                              .animate(
                                  onPlay: (controller) =>
                                      controller.repeat(reverse: true))
                              .scale(
                                begin: const Offset(1, 1),
                                end: const Offset(1.06, 1.06),
                                duration: 1200.ms,
                                curve: Curves.easeInOut,
                              ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            story?.title.isNotEmpty == true
                                ? story!.title
                                : 'Winner testimony',
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.background,
                              fontFamily: AppFonts.manRope,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Gap(8),
                        Row(
                          children: const [
                            Icon(Icons.ondemand_video_rounded,
                                size: 16, color: Color(0xFF269E5F)),
                            Gap(4),
                            Text(
                              'YouTube',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF269E5F),
                                fontFamily: AppFonts.manRope,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (story != null && story.description.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 14, right: 14, bottom: 12),
                      child: Text(
                        story.description,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                          fontFamily: AppFonts.manRope,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          )
              .animate()
              .fadeIn(duration: 320.ms)
              .slideY(begin: 0.06, end: 0, curve: Curves.easeOutQuad)
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFF0F0F0)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.video_library_outlined,
                    color: Color(0xFF94A3B8),
                    size: 28,
                  ),
                ),
                const Gap(14),
                const Text(
                  'No Winner Stories Yet',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.background,
                    fontFamily: AppFonts.manRope,
                  ),
                ),
                const Gap(6),
                const Text(
                  'Winner celebrations and reward stories will appear here soon. Keep earning points to be featured.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                    fontFamily: AppFonts.manRope,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(duration: 320.ms)
              .slideY(begin: 0.06, end: 0, curve: Curves.easeOutQuad),
      ],
    );
  }

  Widget _buildHelpTab() {
    final dynamicFaqs = controller.faqs;
    final fallbackFaqs = [
      {
        'q': 'How do I earn reward points?',
        'a':
            'You earn points automatically every time you purchase airtime, buy data, or refer friends who subscribe to any paid plan on MCD.',
      },
      {
        'q': 'How is my leaderboard rank calculated?',
        'a':
            'Leaderboard ranks are sorted dynamically based on your total accumulated points within the active competition cycle.',
      },
      {
        'q': 'When are winners rewarded?',
        'a':
            'Top performers receive cash prizes, airtime, and exclusive bonuses at the end of every weekly and monthly reward cycle.',
      },
      {
        'q': 'Can I withdraw my bonus earnings?',
        'a':
            'Yes. Points and bonuses can be converted and withdrawn directly to your bank account or used for wallet transactions.',
      },
    ];

    final hasDynamicFaqs = dynamicFaqs.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTag('Information'),
        const Gap(12),
        const Text(
          'Frequently Asked Questions',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.background,
            fontFamily: AppFonts.manRope,
          ),
        ),
        const Gap(14),
        if (hasDynamicFaqs)
          ...dynamicFaqs.asMap().entries.map((entry) {
            return _FaqExpandableTile(
              index: entry.key,
              question: entry.value.question,
              answer: entry.value.answer,
              initialExpanded: entry.key == 0,
            );
          })
        else
          ...fallbackFaqs.asMap().entries.map((entry) {
            return _FaqExpandableTile(
              index: entry.key,
              question: entry.value['q']!,
              answer: entry.value['a']!,
              initialExpanded: entry.key == 0,
            );
          }),
      ],
    );
  }

  void _openInAppVideo(BuildContext context, LeaderboardWinnerStory story) {
    final videoId = story.youtubeVideoId.isNotEmpty
        ? story.youtubeVideoId
        : _extractYouTubeId(story.youtubeUrl);

    if (videoId.isEmpty) {
      controller.openExternalUrl(story.youtubeUrl);
      return;
    }

    final webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(
        Uri.parse(
            'https://www.youtube.com/embed/$videoId?autoplay=1&playsinline=1'),
      );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          margin: const EdgeInsets.only(top: 80),
          decoration: const BoxDecoration(
            color: Color(0xFF1E293B),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          story.title.isNotEmpty
                              ? story.title
                              : 'Winner Testimony',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            fontFamily: AppFonts.manRope,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.open_in_new,
                                color: Colors.white70, size: 20),
                            onPressed: () {
                              controller.openExternalUrl(story.youtubeUrl);
                            },
                          ),
                          IconButton(
                            icon:
                                const Icon(Icons.close, color: Colors.white70),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: WebViewWidget(controller: webViewController),
                ),
                if (story.description.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      story.description,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12.5,
                        fontFamily: AppFonts.manRope,
                        height: 1.4,
                      ),
                    ),
                  ),
                ] else
                  const Gap(16),
              ],
            ),
          ),
        );
      },
    );
  }

  String _extractYouTubeId(String url) {
    if (url.isEmpty) return '';
    final regExp = RegExp(
      r'(?:v=|\/)([0-9A-Za-z_-]{11}).*',
      caseSensitive: false,
    );
    final match = regExp.firstMatch(url);
    if (match != null && match.groupCount >= 1) {
      return match.group(1) ?? '';
    }
    return '';
  }

  void _showCountrySelectionBottomSheet({
    required BuildContext context,
    required String serviceKeyNigeria,
    required String serviceKeyForeign,
    required String serviceName,
    required String redirectTo,
  }) {
    showCustomBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (sheetContext) {
        final options = [
          {
            'title': 'Nigeria',
            'isForeign': false,
            'serviceKey': serviceKeyNigeria,
          },
          {
            'title': 'Other Countries',
            'isForeign': true,
            'serviceKey': serviceKeyForeign,
          },
        ];

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Gap(10),
              Text(
                'Select Destination for $serviceName',
                style: const TextStyle(
                  fontFamily: AppFonts.manRope,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.background,
                ),
              ),
              const Gap(16),
              ...options.map((option) {
                final isAvailable = controller
                    .isServiceAvailable(option['serviceKey'] as String);
                return Opacity(
                  opacity: isAvailable ? 1.0 : 0.5,
                  child: TouchableOpacity(
                    onTap: () async {
                      await controller.checkAndNavigate(
                        option['serviceKey'] as String,
                        serviceName: option['title'] as String,
                        onAvailable: () {
                          Navigator.pop(sheetContext);
                          if (option['isForeign'] as bool) {
                            Get.toNamed(Routes.COUNTRY_SELECTION,
                                arguments: {'redirectTo': redirectTo});
                          } else {
                            Get.toNamed(Routes.NUMBER_VERIFICATION_MODULE,
                                arguments: {'redirectTo': redirectTo});
                          }
                        },
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  option['title'] as String,
                                  style: const TextStyle(
                                    fontFamily: AppFonts.manRope,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.background,
                                  ),
                                ),
                                if (!isAvailable) ...[
                                  const Gap(4),
                                  const Text(
                                    'This service is currently unavailable. Please try again later.',
                                    style: TextStyle(
                                      fontFamily: AppFonts.manRope,
                                      fontSize: 12,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            color: AppColors.background,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const Gap(20),
            ],
          ),
        );
      },
    );
  }
}

class _FaqExpandableTile extends StatefulWidget {
  final int index;
  final String question;
  final String answer;
  final bool initialExpanded;

  const _FaqExpandableTile({
    super.key,
    required this.index,
    required this.question,
    required this.answer,
    this.initialExpanded = false,
  });

  @override
  State<_FaqExpandableTile> createState() => _FaqExpandableTileState();
}

class _FaqExpandableTileState extends State<_FaqExpandableTile> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initialExpanded;
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _isExpanded ? const Color(0xFFFAFDFA) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isExpanded
              ? const Color(0xFF269E5F).withOpacity(0.35)
              : const Color(0xFFE5E7EB),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: _isExpanded
                ? const Color(0xFF269E5F).withOpacity(0.04)
                : Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: _toggle,
          borderRadius: BorderRadius.circular(16),
          splashColor: const Color(0xFF269E5F).withOpacity(0.06),
          highlightColor: const Color(0xFF269E5F).withOpacity(0.03),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        widget.question,
                        style: TextStyle(
                          fontSize: 13.8,
                          fontWeight: FontWeight.w600,
                          color: _isExpanded
                              ? const Color(0xFF269E5F)
                              : AppColors.background,
                          fontFamily: AppFonts.manRope,
                          height: 1.3,
                        ),
                      ),
                    ),
                    const Gap(12),
                    AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 260),
                      curve: Curves.easeOutCubic,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: _isExpanded
                              ? const Color(0xFFE8F5E9)
                              : const Color(0xFFF3F4F6),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 20,
                          color: _isExpanded
                              ? const Color(0xFF269E5F)
                              : const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ],
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox(width: double.infinity, height: 0),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 1,
                          color: const Color(0xFFF0F2F5),
                        ),
                        const Gap(10),
                        Text(
                          widget.answer,
                          style: const TextStyle(
                            fontSize: 12.8,
                            color: Color(0xFF6B7280),
                            fontFamily: AppFonts.manRope,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                  crossFadeState: _isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 260),
                  sizeCurve: Curves.easeOutCubic,
                  firstCurve: Curves.easeInCubic,
                  secondCurve: Curves.easeOutCubic,
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate(delay: (widget.index * 60).ms)
        .fadeIn(duration: 320.ms)
        .slideY(begin: 0.08, end: 0, curve: Curves.easeOutQuad);
  }
}
