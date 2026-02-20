import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mcd/app/modules/game_centre_module/models/game_model.dart';
import 'package:mcd/app/styles/app_colors.dart';
import 'package:mcd/core/network/dio_api_service.dart';
import 'package:mcd/core/services/ads_service.dart';
import 'package:url_launcher/url_launcher.dart';

class GameCentreModuleController extends GetxController {
  final _obj = ''.obs;
  set obj(value) => _obj.value = value;
  get obj => _obj.value;

  final box = GetStorage();
  final apiService = DioApiService();
  final adsService = AdsService();

  // Observables
  final isLoading = true.obs;
  final errorMessage = RxnString();
  final games = <GameModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchGames();
    adsService.showInterstitialAd();
  }

  Future<void> fetchGames() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      final utilityUrl = box.read('utility_service_url') ?? '';
      if (utilityUrl.isEmpty) {
        throw Exception('Service URL not configured');
      }

      final response = await apiService.getrequest('${utilityUrl}games-fetch');

      response.fold(
        (failure) {
          errorMessage.value = failure.message;
          Get.snackbar(
            "Error",
            failure.message,
            backgroundColor: AppColors.errorBgColor,
            colorText: AppColors.textSnackbarColor,
          );
        },
        (data) {
          final gamesResponse = GamesResponse.fromJson(data);

          if (gamesResponse.isSuccess) {
            games.value =
                gamesResponse.games.where((game) => game.isActive).toList();
          } else {
            errorMessage.value = gamesResponse.message;
            Get.snackbar(
              "Error",
              gamesResponse.message,
              backgroundColor: AppColors.errorBgColor,
              colorText: AppColors.textSnackbarColor,
            );
          }
        },
      );
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        "Error",
        "Failed to load games: ${e.toString()}",
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> openGame(GameModel game) async {
    try {
      final uri = Uri.parse(game.url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar(
          "Error",
          "Could not open ${game.name}",
          backgroundColor: AppColors.errorBgColor,
          colorText: AppColors.textSnackbarColor,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to open game: ${e.toString()}",
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
      );
    }
  }

  void retryFetch() {
    fetchGames();
  }
}
