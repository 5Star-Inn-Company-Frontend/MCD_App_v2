import 'dart:developer' as dev;
import 'dart:io';
import 'package:get_storage/get_storage.dart';
import 'package:mcd/core/import/imports.dart';
import 'package:mcd/core/models/service_status_model.dart';
import 'package:mcd/core/network/dio_api_service.dart';
import 'package:mcd/core/services/remote_config_service.dart';

class ServiceStatusController extends GetxService {
  static late ServiceStatusController to;
  ServiceStatusController() {
    to = this;
  }
  final DioApiService apiService = DioApiService();
  final storage = GetStorage();

  final Rx<ServiceStatusData?> serviceStatus = Rx<ServiceStatusData?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool hasLoadedFromCache = false.obs;

  @override
  void onInit() {
    to = this;
    super.onInit();
    _loadCachedStatus();

    // always attempt background refresh if we have a URL
    final url = storage.read('transaction_service_url');
    if (url != null) {
      fetchServiceStatus();
    }
  }

  Future<bool> fetchServiceStatus() async {
    // only show loader if we have no cached data
    if (serviceStatus.value == null) {
      isLoading.value = true;
    }
    errorMessage.value = '';

    final transactionUrl = storage.read('transaction_service_url');
    if (transactionUrl == null) {
      errorMessage.value = 'Transaction URL not found';
      _loadCachedStatus();
      isLoading.value = false;
      return false;
    }

    final url = '${transactionUrl}services';
    final result = await apiService.getrequest(url);

    bool isSuccess = false;

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        _loadCachedStatus();
      },
      (data) {
        if (data['success'] == 1) {
          final model = ServiceStatusModel.fromJson(data);
          serviceStatus.value = model.data;

          dev.log('Available services fetched: ${model.data?.rawServices}', name: 'ServiceStatus');

          // Cache the service status
          if (model.data != null) {
            storage.write('cached_service_status', data);
            dev.log('Service status cached successfully',
                name: 'ServiceStatus');
          }
          isSuccess = true;
        } else {
          errorMessage.value =
              data['message'] ?? 'Failed to fetch service status';
          _loadCachedStatus();
        }
      },
    );

    isLoading.value = false;
    return isSuccess;
  }

  // Load cached service status
  void _loadCachedStatus() {
    final cached = storage.read('cached_service_status');
    if (cached != null) {
      try {
        final model = ServiceStatusModel.fromJson(cached);
        serviceStatus.value = model.data;
        hasLoadedFromCache.value = true;
        dev.log('Loaded service status from cache. Available services: ${model.data?.rawServices}', name: 'ServiceStatus');
      } catch (e) {
        dev.log('Error loading cached status: $e', name: 'ServiceStatus');
      }
    } else {
      dev.log('No cached service status found', name: 'ServiceStatus');
    }
  }

  // Check if a specific service is available (server status takes precedence, falls back to Remote Config)
  bool isServiceAvailable(String serviceKey) {
    if (serviceStatus.value != null) {
      final isAvailable =
          serviceStatus.value!.services.isServiceAvailable(serviceKey);
      if (!isAvailable) {
        dev.log('Service "$serviceKey" is UNAVAILABLE (via Server)', name: 'ServiceStatus');
      }
      if (isAvailable) {
        // Server data is null, fall back to Remote Config if registered
        if (Get.isRegistered<RemoteConfigService>()) {
          final isRcEnabled = RemoteConfigService.to.isServiceEnabled(serviceKey);
          if (!isRcEnabled) {
            dev.log('Service "$serviceKey" is UNAVAILABLE (via Remote Config fallback)', name: 'ServiceStatus');
          }
          return isRcEnabled;
        }
      }
      return isAvailable;
    }

    return true; // Default to available if neither server nor Remote Config is ready
  }

  // get service availability with user feedback
  Future<bool> checkServiceAvailability(String serviceKey,
      {String? serviceName}) async {
    dev.log(
        'Checking service availability for "${serviceName ?? serviceKey}" (key: $serviceKey)',
        name: 'ServiceStatus');

    // if service status not loaded yet, fetch it
    if (serviceStatus.value == null) {
      dev.log('Service status not loaded, fetching now', name: 'ServiceStatus');
      await fetchServiceStatus();
    }

    final isAvailable = isServiceAvailable(serviceKey);

    if (!isAvailable) {
      dev.log(
          'Service "${serviceName ?? serviceKey}" is UNAVAILABLE, showing dialog',
          name: 'ServiceStatus');
      _showServiceUnavailableDialog(serviceName ?? serviceKey);
    } else {
      dev.log(
          'Service "${serviceName ?? serviceKey}" is AVAILABLE, allowing navigation',
          name: 'ServiceStatus');
    }

    return isAvailable;
  }

  // show service unavailable dialog
  void _showServiceUnavailableDialog(String serviceName) {
    Get.dialog(
      Dialog(
        backgroundColor: AppColors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // warning icon container
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  size: 40,
                  color: AppColors.primaryColor,
                ),
              ),
              const SizedBox(height: 16),

              // title
              TextSemiBold(
                'Service Unavailable',
                fontSize: 18,
                color: AppColors.background,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // description
              Text(
                '$serviceName service is currently unavailable. Please try again later.',
                style: const TextStyle(
                  fontFamily: AppFonts.manRope,
                  fontSize: 13.5,
                  color: AppColors.primaryGrey2,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: AppColors.primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: TextSemiBold(
                    'Close',
                    fontSize: 14,
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  // refresh service status
  Future<void> refresh() async {
    await fetchServiceStatus();
  }

  // get specific service values
  String? getFreeMoneyAmount() {
    return serviceStatus.value?.services.freeMoneyAmount;
  }

  String? getSupportEmail() {
    final serverEmail = serviceStatus.value?.others?.supportEmail;
    if (serverEmail != null && serverEmail.isNotEmpty) {
      return serverEmail;
    }
    if (Get.isRegistered<RemoteConfigService>()) {
      return RemoteConfigService.to.getString('support_email');
    }
    return null;
  }

  String? getAgentPhoneNumber() {
    final serverPhone = serviceStatus.value?.others?.mcdAgentPhoneno;
    if (serverPhone != null && serverPhone.isNotEmpty) {
      return serverPhone;
    }
    if (Get.isRegistered<RemoteConfigService>()) {
      return RemoteConfigService.to.getString('agent_phone_number');
    }
    return null;
  }

  String? getUnityGameId() {
    final serverGameId = serviceStatus.value?.adverts?.unityGameid;
    if (serverGameId != null && serverGameId.isNotEmpty) {
      return serverGameId;
    }
    if (Get.isRegistered<RemoteConfigService>()) {
      return Platform.isAndroid
          ? RemoteConfigService.to.getString('unity_game_id_android')
          : RemoteConfigService.to.getString('unity_game_id_ios');
    }
    return null;
  }

  bool isUnityTestMode() {
    if (serviceStatus.value?.adverts?.unityTestmode != null) {
      if (serviceStatus.value!.adverts!.unityTestmode.toLowerCase() == 'true') {
        if (Get.isRegistered<RemoteConfigService>()) {
          return RemoteConfigService.to.getBool('ads_test_mode');
        }
      }
      return true;
    }
    return false;
  }

  bool isLeaderboardActive() {
    if (serviceStatus.value?.others?.leaderboard != null) {
      if (serviceStatus.value!.others!.leaderboard == '1') {
        if (Get.isRegistered<RemoteConfigService>()) {
          return RemoteConfigService.to.getBool('leaderboard_enabled');
        }
      }
      return true;
    }
    return true;
  }

  // raw services map for action button filtering
  Map<String, dynamic> getRawServices() {
    return serviceStatus.value?.rawServices ?? {};
  }

  // image sliders from others
  List<String> getImageSliders() {
    return serviceStatus.value?.others?.imageSliders ?? [];
  }
}
