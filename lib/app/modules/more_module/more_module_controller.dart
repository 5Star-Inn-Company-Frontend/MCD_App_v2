import 'package:mcd/core/import/imports.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:get_storage/get_storage.dart';

class MoreModuleController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final LoginScreenController authController =
      Get.find<LoginScreenController>();
  final box = GetStorage();

  late TabController tabController;

  @override
  void onInit() {
    super.onInit();
    // get initial tab from arguments (first load)
    final currentArgs = Get.arguments as Map<String, dynamic>?;
    final initialTab = currentArgs?['initialTab'] as int?;
    final startIndex = (initialTab != null && initialTab >= 0 && initialTab < 5)
        ? initialTab
        : 0;

    tabController = TabController(
      length: 5,
      vsync: this,
      initialIndex: startIndex,
    );
  }

  @override
  void onReady() {
    super.onReady();
    // fetch fresh arguments (for re-navigation to this screen)
    final currentArgs = Get.arguments as Map<String, dynamic>?;
    final initialTab = currentArgs?['initialTab'] as int?;
    if (initialTab != null && initialTab >= 0 && initialTab < 5) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (tabController.index != initialTab) {
          tabController.animateTo(initialTab);
        }
      });
    }
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  // get user's referral code (username) from local storage
  String getReferralCode() {
    // First try to get from local storage (faster, no API wait)
    final storedUsername = box.read('biometric_username_real');
    if (storedUsername != null && storedUsername.toString().isNotEmpty) {
      return storedUsername.toString();
    }
    // Fallback to dashboard data if local storage is empty
    return authController.dashboardData?.user.userName ?? '';
  }

  // copy referral code to clipboard
  Future<void> copyReferralCode() async {
    final referralCode = getReferralCode();
    if (referralCode.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: referralCode));
      Get.snackbar(
        'Copied!',
        'Referral code copied to clipboard',
        backgroundColor: AppColors.successBgColor,
        colorText: AppColors.textSnackbarColor,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    }
  }

  // share referral code
  Future<void> shareReferralCode() async {
    final referralCode = getReferralCode();
    if (referralCode.isNotEmpty) {
      final message =
          'Use my referral code "$referralCode" to join MEGA Cheap Data and enjoy amazing bonuses! Download now: https://play.google.com/store/apps/details?id=a5starcompany.com.megacheapdata';
      await Share.share(message);
    }
  }

  // navigate to referral list
  void viewReferralList() {
    Get.toNamed(Routes.REFERRAL_LIST_MODULE);
  }

  Future<void> logoutUser() async {
    // Show confirmation dialog
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: AppColors.white,
        title: TextSemiBold(
          'Confirm Logout',
          fontSize: 18,
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(
            fontSize: 14,
            fontFamily: AppFonts.manRope,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: TextSemiBold(
              'Cancel',
              fontSize: 14,
              color: AppColors.primaryGrey2,
            ),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: TextSemiBold(
              'Logout',
              fontSize: 14,
              color: AppColors.errorBgColor,
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );

    // If user confirmed, proceed with logout
    if (confirmed == true) {
      await authController.logout();
      Get.offAllNamed(Routes.LOGIN_SCREEN);
    }
  }
}
