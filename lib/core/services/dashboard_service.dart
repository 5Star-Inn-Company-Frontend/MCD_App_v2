import 'dart:convert';
import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mcd/app/modules/home_screen_module/model/dashboard_model.dart';
import 'package:mcd/app/styles/app_colors.dart';
import 'package:mcd/core/network/api_constants.dart';
import 'package:mcd/core/network/dio_api_service.dart';
import 'package:mcd/core/services/storage_service.dart';

class DashboardService extends GetxService {
  static DashboardService get to => Get.find<DashboardService>();

  final DioApiService _apiService = DioApiService();
  final GetStorage _box = GetStorage();

  final Rx<DashboardModel?> dashboardData = Rx<DashboardModel?>(null);
  final RxBool isLoadingDashboard = false.obs;
  final RxString errorMessage = ''.obs;

  final RxString gmBalance = '0.00'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadCachedDashboard();
  }

  void _loadCachedDashboard() {
    try {
      final cachedDashboard = _box.read('cached_dashboard');
      if (cachedDashboard != null) {
        dashboardData.value = DashboardModel.fromJson(cachedDashboard);
        dev.log('Loaded dashboard from cache', name: 'DashboardService');
      }
    } catch (e) {
      dev.log('Error loading cached dashboard: $e', name: 'DashboardService');
    }
  }

  Future<void> fetchDashboard({bool force = false}) async {
    dev.log(
        "fetchDashboard called, force: $force, current data: ${dashboardData.value != null ? 'exists' : 'null'}",
        name: 'DashboardService');

    // Always fetch if data is null
    if (dashboardData.value != null && !force) {
      dev.log("Dashboard already loaded, skipping fetch", name: 'DashboardService');
      return;
    }

    isLoadingDashboard.value = true;
    errorMessage.value = "";
    dev.log("Starting dashboard fetch...", name: 'DashboardService');

    final result =
        await _apiService.getrequest("${ApiConstants.authUrlV2}/dashboard");

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        dev.log("Dashboard fetch failed: ${failure.message}", name: 'DashboardService');
        Get.snackbar("Error", failure.message,
            backgroundColor: AppColors.errorBgColor,
            colorText: AppColors.textSnackbarColor);
      },
      (data) async {
        dashboardData.value = DashboardModel.fromJson(data);
        _box.write('cached_dashboard', data);
        await StorageService.to.setDashboardData(data);
        dev.log(
            "Dashboard model created and cached - User: ${dashboardData.value?.user.userName}, Balance: ${dashboardData.value?.balance.wallet}",
            name: 'DashboardService');

        // save username e.g excade001
        await _box.write(
            'biometric_username_real', dashboardData.value?.user.userName ?? 'MCD');
        dev.log(
            "Biometric username updated in storage: ${_box.read('biometric_username_real')}",
            name: 'DashboardService');

        await _box.write('user_email', dashboardData.value?.user.email ?? '');
        dev.log("User email updated in storage: ${_box.read('user_email')}",
            name: 'DashboardService');

        if (force) {
          dev.log("Dashboard refreshed successfully", name: 'DashboardService');
        }
      },
    );

    isLoadingDashboard.value = false;
  }

  Future<void> fetchGMBalance() async {
    final transactionUrl = _box.read('transaction_service_url');
    if (transactionUrl == null) {
      dev.log('Transaction URL not found',
          name: 'DashboardService', error: 'URL missing');
      return;
    }

    final result =
        await _apiService.getrequest('${transactionUrl}gmtransactions');

    result.fold(
      (failure) {
        dev.log('GM balance fetch failed: ${failure.message}',
            name: 'DashboardService');
      },
      (data) {
        if (data['wallet'] != null) {
          gmBalance.value = data['wallet'].toString();
          dev.log('GM balance updated to: ₦${gmBalance.value}',
              name: 'DashboardService');
        } else {
          dev.log('Wallet balance not found in response',
              name: 'DashboardService');
        }
      },
    );
  }
}
