import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mcd/app/styles/app_colors.dart';
import 'package:mcd/core/network/dio_api_service.dart';
import 'package:mcd/app/modules/home_screen_module/home_screen_controller.dart';
import 'dart:developer' as dev;

class QrcodeTransferDetailsModuleController extends GetxController {
  final GetStorage _storage = GetStorage();
  final apiService = DioApiService();
  
  // Form key
  final formKey = GlobalKey<FormState>();
  
  // Text editing controller
  final amountController = TextEditingController();
  final referenceController = TextEditingController();

  // Scanned user data
  final _scannedUsername = ''.obs;
  String get scannedUsername => _scannedUsername.value;

  final _scannedEmail = ''.obs;
  String get scannedEmail => _scannedEmail.value;

  final _currentWallet = 0.0.obs;
  double get currentWallet => _currentWallet.value;

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  final _isFetchingUserData = false.obs;
  bool get isFetchingUserData => _isFetchingUserData.value;

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  void _loadData() async {
    // Load current wallet balance from home dashboard
    try {
      final homeController = Get.find<HomeScreenController>();
      if (homeController.dashboardData != null) {
        final walletBalance = homeController.dashboardData.balance.wallet;
        _currentWallet.value = double.tryParse(walletBalance) ?? 0.0;
        dev.log('Current wallet balance: ${_currentWallet.value}');
      } else {
        _currentWallet.value = 0.0;
      }
    } catch (e) {
      dev.log('Error loading wallet balance: $e');
      _currentWallet.value = 0.0;
    }
    
    // Load scanned user data from arguments
    final args = Get.arguments;
    if (args != null && args['username'] != null) {
      _scannedUsername.value = args['username'];
      dev.log('Scanned username: ${_scannedUsername.value}');
      
      // Check if email was provided in QR code (new format)
      if (args['email'] != null && args['email'].toString().isNotEmpty) {
        _scannedEmail.value = args['email'];
        dev.log('Email from QR code: ${_scannedEmail.value}');
      } else {
        // Fallback: Fetch user details by username from the utility service (old format)
        dev.log('Email not in QR code, fetching from API');
        await _fetchUserDetails();
      }
    } else {
      // Default values for testing
      _scannedUsername.value = 'User';
      _scannedEmail.value = 'user@example.com';
    }
  }

  Future<void> _fetchUserDetails() async {
    _isFetchingUserData.value = true;
    
    try {
      // Get utility service URL from storage
      final utilityUrl = _storage.read('utility_service_url');
      if (utilityUrl == null) {
        dev.log('Utility URL not found', name: 'QRTransfer');
        _scannedEmail.value = '${_scannedUsername.value.toLowerCase()}@example.com';
        _isFetchingUserData.value = false;
        return;
      }

      // Call API to get user details by username
      final result = await apiService.postJsonRequest(
        '$utilityUrl/get-user-details',
        {'user_name': _scannedUsername.value},
      );

      result.fold(
        (failure) {
          dev.log('Failed to fetch user details: ${failure.message}');
          // Use placeholder email if fetch fails
          _scannedEmail.value = '${_scannedUsername.value.toLowerCase()}@example.com';
        },
        (data) {
          dev.log('User details response: $data', name: 'QRTransfer');
          if (data['success'] == true || data['success'] == 1) {
            final userData = data['data'];
            if (userData != null) {
              _scannedEmail.value = userData['email'] ?? '${_scannedUsername.value.toLowerCase()}@example.com';
              dev.log('User details fetched - Email: ${_scannedEmail.value}');
            } else {
              _scannedEmail.value = '${_scannedUsername.value.toLowerCase()}@example.com';
            }
          } else {
            _scannedEmail.value = '${_scannedUsername.value.toLowerCase()}@example.com';
            dev.log('User details not found: ${data['message'] ?? 'Unknown error'}');
          }
        },
      );
    } catch (e) {
      dev.log('Error fetching user details: $e');
      _scannedEmail.value = '${_scannedUsername.value.toLowerCase()}@example.com';
    } finally {
      _isFetchingUserData.value = false;
    }
  }

  String _generateReference() {
    final username = _storage.read('biometric_username_real') ?? 'MCD';
    final userPrefix = username.length >= 3
        ? username.substring(0, 3).toUpperCase()
        : username.toUpperCase();
    return 'MCD2_$userPrefix${DateTime.now().microsecondsSinceEpoch}';
  }

  Future<void> transfer() async {
    if (!formKey.currentState!.validate()) return;

    try {
      _isLoading.value = true;

      final amount = double.tryParse(amountController.text) ?? 0.0;
      final ref = _generateReference();

      if (amount <= 0) {
        Get.snackbar(
          'Error',
          'Please enter a valid amount',
          backgroundColor: AppColors.errorBgColor,
          colorText: AppColors.textSnackbarColor,
        );
        _isLoading.value = false;
        return;
      }

      if (amount > currentWallet) {
        Get.snackbar(
          'Error',
          'Insufficient balance',
          backgroundColor: AppColors.errorBgColor,
          colorText: AppColors.textSnackbarColor,
        );
        _isLoading.value = false;
        return;
      }

      // Get transaction URL from storage
      final transactionUrl = _storage.read('transaction_service_url');
      if (transactionUrl == null) {
        dev.log('Transaction URL not found', name: 'QRTransfer');
        Get.snackbar(
          'Error',
          'Transaction service not configured',
          backgroundColor: AppColors.errorBgColor,
          colorText: AppColors.textSnackbarColor,
        );
        _isLoading.value = false;
        return;
      }

      // Prepare request body with auto-generated reference
      final body = {
        'user_name': _scannedUsername.value,
        'amount': amount.toString(),
        'reference': ref,
      };

      dev.log('Transfer request body: $body', name: 'QRTransfer');

      // Call the transfer endpoint
      final result = await apiService.postrequest('${transactionUrl}w2w/transfer', body);

      result.fold(
        (failure) {
          dev.log('Transfer failed: ${failure.message}', name: 'QRTransfer');
          Get.snackbar(
            'Error',
            'Transfer failed: ${failure.message}',
            backgroundColor: AppColors.errorBgColor,
            colorText: AppColors.textSnackbarColor,
          );
        },
        (data) {
          dev.log('Transfer response: $data', name: 'QRTransfer');
          
          if (data['success'] == true) {
            Get.snackbar(
              'Success',
              data['message'] ?? 'Transfer successful',
              backgroundColor: AppColors.successBgColor,
              colorText: AppColors.textSnackbarColor,
            );

            // Refresh dashboard to update balance
            try {
              final homeController = Get.find<HomeScreenController>();
              homeController.refreshDashboard();
            } catch (e) {
              dev.log('Could not refresh dashboard: $e');
            }

            // Navigate back
            Get.back();
          } else {
            Get.snackbar(
              'Error',
              data['message'] ?? 'Transfer failed',
              backgroundColor: AppColors.errorBgColor,
              colorText: AppColors.textSnackbarColor,
            );
          }
        },
      );
    } catch (e) {
      dev.log('Transfer error: $e', name: 'QRTransfer');
      Get.snackbar(
        'Error',
        'Transfer failed: $e',
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  @override
  void onClose() {
    amountController.dispose();
    referenceController.dispose();
    super.onClose();
  }
}
