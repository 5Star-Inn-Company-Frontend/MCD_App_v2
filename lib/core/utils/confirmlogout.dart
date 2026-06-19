
import 'dart:developer' as dev;

import 'package:get_storage/get_storage.dart';

import '../import/imports.dart';

class Confirmlogout {

  static final box = GetStorage();

  static Future<void> logout() async {
    try {
      await box.remove('token');
      await box.remove('cached_profile');
      await box.remove('biometric_username_real');
      await box.remove('user_email');
      // optionally clear biometric data on logout
      // await box.remove('biometric_enabled');
    } catch (e) {
      dev.log("Logout error: $e");
    }
  }


  static Future<void> confirmLogout() async {
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
      await logout();
      Get.offAllNamed(Routes.LOGIN_SCREEN);
    }
  }
}