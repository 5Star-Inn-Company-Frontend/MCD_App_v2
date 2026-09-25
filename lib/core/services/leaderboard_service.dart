import 'dart:developer' as dev;
import 'package:get/get.dart';
import 'package:mcd/app/modules/leaderboard_module/models/leaderboard_model.dart';
import 'package:mcd/core/network/api_constants.dart';
import 'package:mcd/core/network/dio_api_service.dart';

class LeaderboardService extends GetxService {
  static LeaderboardService get to => Get.find<LeaderboardService>();

  final DioApiService _apiService = DioApiService();

  final Rx<LeaderboardModel?> leaderboardData = Rx<LeaderboardModel?>(null);
  final RxBool isLoading = false.obs;

  List<LeaderboardUser> get topThree {
    if (leaderboardData.value == null || leaderboardData.value!.leaderboard.isEmpty) {
      return [];
    }
    return leaderboardData.value!.leaderboard.take(3).toList();
  }

  List<LeaderboardUser> get remainingUsers {
    if (leaderboardData.value == null || leaderboardData.value!.leaderboard.length <= 3) {
      return [];
    }
    return leaderboardData.value!.leaderboard.skip(3).toList();
  }

  @override
  void onInit() {
    super.onInit();
    fetchLeaderboard();
  }

  Future<void> fetchLeaderboard({bool force = false}) async {
    if (leaderboardData.value != null && !force) {
      return;
    }

    try {
      isLoading.value = true;
      final url = '${ApiConstants.authUrlV2}/leaderboard';
      dev.log("Leaderboard URL: $url");

      final result = await _apiService.getrequest(url);

      result.fold(
        (failure) {
          dev.log("Leaderboard fetch failed: ${failure.message}");
        },
        (data) {
          dev.log("Leaderboard data received: ${data.toString()}");
          leaderboardData.value = LeaderboardModel.fromJson(data);
          dev.log("Leaderboard loaded: ${leaderboardData.value?.leaderboard.length} users");
        },
      );
    } catch (e) {
      dev.log("Leaderboard fetch error: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
