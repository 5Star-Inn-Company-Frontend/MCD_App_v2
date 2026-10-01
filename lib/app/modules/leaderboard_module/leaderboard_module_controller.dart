

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mcd/core/services/leaderboard_service.dart';
import 'package:mcd/app/modules/leaderboard_module/models/leaderboard_model.dart';
import 'package:mcd/core/network/dio_api_service.dart';
import 'package:mcd/core/services/ads_service.dart';

class LeaderboardModuleController extends GetxController {
  final apiService = DioApiService();
  final box = GetStorage();
  final adsService = AdsService();

  bool get isLoading => LeaderboardService.to.isLoading.value;
  LeaderboardModel? get leaderboardData => LeaderboardService.to.leaderboardData.value;
  List<LeaderboardUser> get topThree => LeaderboardService.to.topThree;
  List<LeaderboardUser> get remainingUsers => LeaderboardService.to.remainingUsers;

  @override
  void onInit() {
    super.onInit();
    // LeaderboardService handles the fetch, we just show the ad
    adsService.showInterstitialAd();
  }

  Future<void> refreshLeaderboard() async {
    await LeaderboardService.to.fetchLeaderboard(force: true);
  }
}
