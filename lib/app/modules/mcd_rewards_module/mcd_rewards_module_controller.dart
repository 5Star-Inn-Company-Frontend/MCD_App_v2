import 'package:get/get.dart';
import 'package:mcd/app/modules/leaderboard_module/models/leaderboard_model.dart';
import 'package:mcd/app/modules/more_module/more_module_controller.dart';
import 'package:mcd/app/routes/app_pages.dart';
import 'package:mcd/core/services/dashboard_service.dart';
import 'package:mcd/core/services/leaderboard_service.dart';
import 'package:mcd/core/mixins/service_availability_mixin.dart';
import 'package:url_launcher/url_launcher.dart';

class McdRewardsModuleController extends GetxController
    with ServiceAvailabilityMixin {
  final selectedTabIndex = 0.obs;

  bool get isLoading => LeaderboardService.to.isLoading.value;
  LeaderboardModel? get leaderboardData =>
      LeaderboardService.to.leaderboardData.value;
  List<LeaderboardUser> get allUsers =>
      leaderboardData?.leaderboard ?? [];

  String get currentUserName =>
      DashboardService.to.dashboardData.value?.user.userName ?? '';

  int get userPoints {
    final pointsStr =
        DashboardService.to.dashboardData.value?.balance.points;
    if (pointsStr != null) {
      return (double.tryParse(pointsStr) ?? 0).toInt();
    }
    return 0;
  }

  int get userRank {
    final apiRank = leaderboardData?.rank ?? 0;
    if (apiRank > 0) return apiRank;
    final index = allUsers.indexWhere(
        (u) => u.userName.toLowerCase() == currentUserName.toLowerCase());
    if (index >= 0) return index + 1;
    return 0;
  }

  int get targetPoints {
    if (allUsers.isEmpty) return userPoints > 0 ? userPoints + 500 : 1000;
    final rank = userRank;
    if (rank <= 1) {
      return allUsers.first.pointsValue;
    }
    final userAbove = allUsers.firstWhereOrNull((u) => u.rank == rank - 1);
    if (userAbove != null && userAbove.pointsValue > userPoints) {
      return userAbove.pointsValue;
    }
    return userPoints + 355;
  }

  int get pointsToNext {
    final diff = targetPoints - userPoints;
    return diff > 0 ? diff : 0;
  }

  double get progressRatio {
    if (targetPoints <= 0) return 1.0;
    final ratio = userPoints / targetPoints;
    if (ratio < 0) return 0.0;
    if (ratio > 1) return 1.0;
    return ratio;
  }

  String get progressPercentText {
    final pct = (progressRatio * 100).clamp(0.0, 100.0);
    return '${pct.toStringAsFixed(1)}%';
  }

  String get progressSubtitle {
    final rank = userRank;
    if (rank <= 1) {
      return 'You are in first place';
    }
    if (rank == 2) {
      return '$pointsToNext points to first place';
    }
    if (rank == 3) {
      return '$pointsToNext points to second place';
    }
    if (rank == 4) {
      return '$pointsToNext points to third place';
    }
    return '$pointsToNext points to rank #${rank - 1}';
  }

  @override
  void onInit() {
    super.onInit();
    LeaderboardService.to.fetchLeaderboard(force: true);
  }

  void setTab(int index) {
    selectedTabIndex.value = index;
  }

  void goToRewardTab() {
    selectedTabIndex.value = 2;
  }

  void goToEarnTab() {
    selectedTabIndex.value = 1;
  }

  List<LeaderboardFaq> get faqs => leaderboardData?.safeFaqs ?? [];
  List<LeaderboardWinnerStory> get winnerStories =>
      leaderboardData?.safeWinnerStories ?? [];
  LeaderboardWinnerStory? get primaryWinnerStory =>
      winnerStories.isNotEmpty ? winnerStories.first : null;
  String get banner => leaderboardData?.safeBanner ?? '';

  bool get hasWinnerVideo =>
      primaryWinnerStory != null &&
      primaryWinnerStory!.youtubeUrl.trim().isNotEmpty;

  Future<void> openExternalUrl(String url) async {
    final cleanUrl = url.trim();
    if (cleanUrl.isNotEmpty) {
      final uri = Uri.parse(cleanUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  Future<void> openWinnerVideo() async {
    final url = primaryWinnerStory?.youtubeUrl.trim() ?? '';
    await openExternalUrl(url);
  }

  void openDailyBonus() {
    Get.toNamed(Routes.FREE_MONEY_MODULE);
  }

  void openSubscription() {
    if (Get.isRegistered<MoreModuleController>()) {
      Get.find<MoreModuleController>().switchTab(1);
    }
    Get.toNamed(Routes.MORE_MODULE, arguments: {'initialTab': 1});
  }

  void openReferAndEarn() {
    if (Get.isRegistered<MoreModuleController>()) {
      Get.find<MoreModuleController>().switchTab(2);
    }
    Get.toNamed(Routes.MORE_MODULE, arguments: {'initialTab': 2});
  }

  Future<void> refreshData() async {
    await LeaderboardService.to.fetchLeaderboard(force: true);
  }
}
