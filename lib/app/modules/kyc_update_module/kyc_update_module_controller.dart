import 'package:get_storage/get_storage.dart';
import 'package:mcd/core/import/imports.dart';
import 'package:mcd/core/network/api_constants.dart';
import 'package:sprint_check/sprint_check.dart';
import 'package:sprint_check/sprint_check_method_channel.dart';
import 'dart:developer' as dev;

import '../home_screen_module/model/dashboard_model.dart';

class KycUpdateModuleController extends GetxController {
  final box = GetStorage();
  static SprintCheck? _sprintCheckPlugin;
  SprintCheck get sprintCheckPlugin => _sprintCheckPlugin ?? SprintCheck();

  final bvnController = TextEditingController();
  final identifierController = TextEditingController();

  final isLoading = false.obs;
  final isBvnVerified = false.obs;

  final dashboardDataRx = Rxn<DashboardModel>();
  DashboardModel? get dashboardData => dashboardDataRx.value;
  set dashboardData(DashboardModel? value) => dashboardDataRx.value = value;

  @override
  void onInit() {
    super.onInit();
    dev.log('KycUpdateModuleController initialized', name: 'KycUpdate');
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      isLoading.value = true;
      // Fetch fresh dashboard data to get the email
      // Now set identifier and check BVN status with fresh data
      final cachedData = box.read('cached_dashboard');
      if (cachedData != null) {
        try {
          dashboardData = DashboardModel.fromJson(cachedData);
          dev.log("Dashboard loaded from local cache");
        } catch (e) {
          dev.log("Error loading dashboard from cache: $e");
        }
      }
      setIdentifier();
      checkBvnStatus();
    } catch (e) {
      dev.log('Error initializing KYC data', name: 'KycUpdate', error: e);
    } finally {
      isLoading.value = false;
    }
  }

  void _initializeSprintCheckOnce() {
    if (_sprintCheckPlugin == null) {
      _sprintCheckPlugin = SprintCheck();
      initializeSprintCheck();
    }
  }

  @override
  void onClose() {
    bvnController.dispose();
    identifierController.dispose();
    super.onClose();
  }

  void initializeSprintCheck() {
    try {
      sprintCheckPlugin.initialize(
        apiKey: ApiConstants.sprintCheckApiKey,
        encryptionKey: ApiConstants.sprintCheckEncryptionKey,
      );
      dev.log('Sprint Check SDK initialized', name: 'KycUpdate');
    } catch (e) {
      dev.log('Error initializing Sprint Check SDK',
          name: 'KycUpdate', error: e);
    }
  }

  void setIdentifier() {
    // Use email as identifier - ensure it's not empty
    final email = dashboardData?.user.email ?? '';
    final username = dashboardData?.user.userName ?? '';

    dev.log('Dashboard data available: ${dashboardData != null}',
        name: 'KycUpdate');
    dev.log('Email from dashboard: $email', name: 'KycUpdate');
    dev.log('Username from dashboard: $username', name: 'KycUpdate');

    if (email.isNotEmpty) {
      identifierController.text = email;
      dev.log('Identifier set to email: $email', name: 'KycUpdate');
    } else if (username.isNotEmpty) {
      // Fallback to username if email is not available
      identifierController.text = username;
      dev.log('Identifier set to username (email not available): $username',
          name: 'KycUpdate');
    } else {
      dev.log('Warning: No identifier available (no email or username)',
          name: 'KycUpdate');
    }
  }

  void checkBvnStatus() {
    // Check if BVN is already verified from dashboard data
    final bvnValid = dashboardData?.user.bvn ?? false;
    isBvnVerified.value = bvnValid;
    dev.log('BVN verification status: $bvnValid', name: 'KycUpdate');
  }

  Future<void> startBvnVerification(BuildContext context) async {
    if (bvnController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your BVN',
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    if (bvnController.text.length != 11) {
      Get.snackbar(
        'Error',
        'BVN must be 11 digits',
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    try {
      isLoading.value = true;

      // Initialize Sprint Check only when needed
      _initializeSprintCheckOnce();

      dev.log('Starting BVN verification for: ${bvnController.text}',
          name: 'KycUpdate');
      dev.log('Using identifier: ${identifierController.text}',
          name: 'KycUpdate');

      // Ensure we pass string values, not controllers
      final identifier = identifierController.text.trim();
      final bvnNumber = bvnController.text.trim();

      if (identifier.isEmpty) {
        Get.snackbar(
          'Error',
          'User identifier is missing. Please try logging out and back in.',
          backgroundColor: AppColors.errorBgColor,
          colorText: AppColors.textSnackbarColor,
          snackPosition: SnackPosition.TOP,
        );
        isLoading.value = false;
        return;
      }

      final response = await sprintCheckPlugin.checkout(
        context,
        CheckoutMethod.bvn,
        identifier,
        bvn: bvnNumber,
      );

      dev.log('BVN verification response: $response', name: 'KycUpdate');

      // Parse response and handle success/failure
      handleVerificationResponse(response);
    } catch (e) {
      dev.log('Error during BVN verification', name: 'KycUpdate', error: e);
      Get.snackbar(
        'Error',
        'Verification failed: $e',
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void handleVerificationResponse(dynamic response) {
    dev.log('Processing verification response', name: 'KycUpdate');

    String message = 'N/A';
    String name = 'N/A';
    String bvn = 'N/A';
    bool status = false;

    try {
      if (response != null) {
        message = response.message?.toString() ?? 'N/A';
        name = response.name?.toString() ?? 'N/A';
        bvn = response.bvn?.toString() ?? 'N/A';
        status = response.status == true;
      }
    } catch (e) {
      // Fallback if dynamic access fails
      final str = response.toString();
      message = str;
      dev.log('Error parsing response fields: $e', name: 'KycUpdate');
    }

    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Icon(
                status ? Icons.check_circle_outline : Icons.info_outline,
                size: 50,
                color: status ? Colors.green : AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                'Review Details',
                style: TextStyle(
                  fontFamily: AppFonts.manRope,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryColor,
                ),
              ),
            ),
            const SizedBox(height: 15),
            _buildResultRow('Message', message),
            if (name != 'N/A' && name != 'null') ...[
              const SizedBox(height: 10),
              _buildResultRow('Name', name),
            ],
            if (bvn != 'N/A' && bvn != 'null') ...[
              const SizedBox(height: 10),
              _buildResultRow('BVN', bvn),
            ],
          ],
        ),
        actions: [
          if (status) ...[
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel',
                  style: TextStyle(
                      color: Colors.red,
                      fontFamily: AppFonts.manRope,
                      fontWeight: FontWeight.bold)),
            ),
            TextButton(
              onPressed: () {
                Get.back();
                _initializeData();
              },
              child: const Text('Proceed',
                  style: TextStyle(
                      color: AppColors.primaryColor,
                      fontFamily: AppFonts.manRope,
                      fontWeight: FontWeight.bold)),
            ),
          ] else ...[
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Close',
                  style: TextStyle(
                      color: Colors.red,
                      fontFamily: AppFonts.manRope,
                      fontWeight: FontWeight.bold)),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: AppFonts.manRope,
            fontSize: 12,
            color: AppColors.primaryGrey2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontFamily: AppFonts.manRope,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryColor,
          ),
        ),
      ],
    );
  }

  void showAlreadyVerifiedDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              size: 50,
              color: Colors.green,
            ),
            const SizedBox(height: 20),
            const Text(
              'Already Verified',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Your BVN has already been verified.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Close',
              style: TextStyle(
                fontFamily: AppFonts.manRope,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppColors.textPrimaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
