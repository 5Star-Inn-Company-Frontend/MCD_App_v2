import 'dart:developer' as dev;
import 'package:get_storage/get_storage.dart';
import 'package:mcd/core/import/imports.dart';
import 'package:mcd/core/models/service_status_model.dart';
import 'package:mcd/core/network/dio_api_service.dart';

class ServiceStatusController extends GetxController {
  final DioApiService apiService = DioApiService();
  final storage = GetStorage();

  final Rx<ServiceStatusData?> serviceStatus = Rx<ServiceStatusData?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool hasLoadedFromCache = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Load from cache on initialization instead of making API call
    _loadCachedStatus();
    
    // Only fetch fresh data if cache is empty or expired
    if (serviceStatus.value == null || _isCacheExpired()) {
      dev.log('Cache is empty or expired, fetching fresh service status', 
          name: 'ServiceStatus');
      fetchServiceStatus();
    } else {
      dev.log('Using cached service status from storage', name: 'ServiceStatus');
    }
  }

  /// Check if cached data is older than 24 hours
  bool _isCacheExpired() {
    final timestamp = storage.read('service_status_timestamp');
    if (timestamp == null) return true;
    
    try {
      final cachedTime = DateTime.parse(timestamp);
      final difference = DateTime.now().difference(cachedTime);
      return difference.inHours > 24;
    } catch (e) {
      dev.log('Error parsing cache timestamp: $e', name: 'ServiceStatus');
      return true;
    }
  }

  Future<void> fetchServiceStatus() async {
    isLoading.value = true;
    errorMessage.value = '';

    final transactionUrl = storage.read('transaction_service_url');
    if (transactionUrl == null) {
      errorMessage.value = 'Transaction URL not found';
      _loadCachedStatus();
      isLoading.value = false;
      return;
    }

    final url = '${transactionUrl}services';
    final result = await apiService.getrequest(url);

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        _loadCachedStatus();
      },
      (data) {
        if (data['success'] == 1) {
          final model = ServiceStatusModel.fromJson(data);
          serviceStatus.value = model.data;
          
          // Cache the service status
          if (model.data != null) {
            storage.write('cached_service_status', data);
            storage.write('service_status_timestamp', DateTime.now().toIso8601String());
            dev.log('Service status cached successfully', name: 'ServiceStatus');
          }
        } else {
          errorMessage.value = data['message'] ?? 'Failed to fetch service status';
          _loadCachedStatus();
        }
      },
    );

    isLoading.value = false;
  }

  // Load cached service status
  void _loadCachedStatus() {
    final cached = storage.read('cached_service_status');
    if (cached != null) {
      try {
        final model = ServiceStatusModel.fromJson(cached);
        serviceStatus.value = model.data;
        hasLoadedFromCache.value = true;
        dev.log('Loaded service status from cache', name: 'ServiceStatus');
      } catch (e) {
        dev.log('Error loading cached status: $e', name: 'ServiceStatus');
      }
    } else {
      dev.log('No cached service status found', name: 'ServiceStatus');
    }
  }

  // Check if a specific service is available (silent check, no logging unless unavailable)
  bool isServiceAvailable(String serviceKey) {
    if (serviceStatus.value == null) {
      return true; // Allow access if status not yet fetched
    }
    final isAvailable = serviceStatus.value!.services.isServiceAvailable(serviceKey);
    
    if (!isAvailable) {
      dev.log('Service "$serviceKey" is UNAVAILABLE', name: 'ServiceStatus');
    }
    
    return isAvailable;
  }

  // get service availability with user feedback
  Future<bool> checkServiceAvailability(String serviceKey, {String? serviceName}) async {
    dev.log('Checking service availability for "${serviceName ?? serviceKey}" (key: $serviceKey)', name: 'ServiceStatus');
    
    // if service status not loaded yet, fetch it
    if (serviceStatus.value == null) {
      dev.log('Service status not loaded, fetching now', name: 'ServiceStatus');
      await fetchServiceStatus();
    }

    final isAvailable = isServiceAvailable(serviceKey);

    if (!isAvailable) {
      dev.log('Service "${serviceName ?? serviceKey}" is UNAVAILABLE, showing dialog', name: 'ServiceStatus');
      _showServiceUnavailableDialog(serviceName ?? serviceKey);
    } else {
      dev.log('Service "${serviceName ?? serviceKey}" is AVAILABLE, allowing navigation', name: 'ServiceStatus');
    }

    return isAvailable;
  }

  // show service unavailable dialog
  void _showServiceUnavailableDialog(String serviceName) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 12),
            TextSemiBold('Service Unavailable', fontSize: 20),
          ],
        ),
        content: TextSemiBold(
          '$serviceName service is currently unavailable. Please try again later.', fontSize: 16
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: TextSemiBold('Close', color: AppColors.primaryOrange, fontSize: 16),
          ),
          // ElevatedButton(
          //   onPressed: () {
          //     Get.back();
          //     fetchServiceStatus();
          //   },
          //   style: ElevatedButton.styleFrom(
          //     backgroundColor: AppColors.primaryColor,
          //     padding: const EdgeInsets.symmetric(vertical: 14),
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.circular(8),
          //     ),
          //   ),
          //   child: const Text(
          //     'Retry',
          //     style: TextStyle(
          //       fontSize: 16,
          //       fontWeight: FontWeight.w600,
          //       color: Colors.white,
          //       fontFamily: AppFonts.manRope,
          //     ),
          //   ),
          // ),
        ],
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
    return serviceStatus.value?.others?.supportEmail;
  }

  String? getAgentPhoneNumber() {
    return serviceStatus.value?.others?.mcdAgentPhoneno;
  }

  String? getUnityGameId() {
    return serviceStatus.value?.adverts?.unityGameid;
  }

  bool isUnityTestMode() {
    return serviceStatus.value?.adverts?.unityTestmode.toLowerCase() == 'true';
  }

  bool isLeaderboardActive() {
    return serviceStatus.value?.others?.leaderboard == '1';
  }
}
