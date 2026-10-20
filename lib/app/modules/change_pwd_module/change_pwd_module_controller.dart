import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mcd/app/styles/app_colors.dart';
import 'package:mcd/core/network/api_constants.dart';
import 'package:mcd/core/network/dio_api_service.dart';
import 'dart:developer' as dev;

class ChangePwdModuleController extends GetxController {
  final formKey = GlobalKey<FormState>();
  
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  
  final isOldPasswordVisible = true.obs;
  final isNewPasswordVisible = true.obs;
  final isConfirmPasswordVisible = true.obs;
  final isLoading = false.obs;
  
  final apiService = DioApiService();
  final box = GetStorage();
  
  @override
  void onClose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
  
  Future<void> changePassword() async {
    if (formKey.currentState == null || !formKey.currentState!.validate()) {
      return;
    }
    
    if (newPasswordController.text != confirmPasswordController.text) {
      Get.snackbar(
        "Error",
        "New passwords do not match",
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
      );
      return;
    }
    
    try {
      isLoading.value = true;
      
      final utilityUrl = box.read('utility_service_url');
      if (utilityUrl == null) {
        Get.snackbar(
          "Error",
          "Service URL not found. Please login again.",
          backgroundColor: AppColors.errorBgColor,
          colorText: AppColors.textSnackbarColor,
        );
        return;
      }
      // final utilityUrl = 'https://auth.mcd.5starcompany.com.ng/api/v2/';
      
      final body = {
        "o_password": oldPasswordController.text.trim(),
        "n_password": newPasswordController.text.trim(),
      };
      
      dev.log('Change password request: $body', name: 'ChangePassword');

      final result = await apiService.postrequest(
        '${ApiConstants.authUrlV2}/change-password',
        body,
      );

      dev.log('Change passowrd url: ${ApiConstants.authUrlV2}/change-password', name: 'ChangePassword');
      
      result.fold(
        (failure) {
          dev.log('Password change failed: ${failure.message}', name: 'ChangePassword');
          Get.snackbar(
            "Error",
            failure.message,
            backgroundColor: AppColors.errorBgColor,
            colorText: AppColors.textSnackbarColor,
          );
        },
        (data) {
          dev.log('Password change response: $data', name: 'ChangePassword');
          if (data['success'] == 1 || data['message']?.toString().toLowerCase().contains('success') == true) {
            Get.snackbar(
              "Success",
              data['message'] ?? "Password changed successfully",
              backgroundColor: AppColors.successBgColor,
              colorText: AppColors.textSnackbarColor,
              duration: const Duration(seconds: 2)
            );
            
            // Clear the form
            oldPasswordController.clear();
            newPasswordController.clear();
            confirmPasswordController.clear();
            
            // Navigate back after a short delay
            Future.delayed(const Duration(seconds: 1), () {
              Get.back();
            });
          } else {
            Get.snackbar(
              "Error",
              data['message'] ?? "Failed to change password",
              backgroundColor: AppColors.errorBgColor,
              colorText: AppColors.textSnackbarColor,
            );
          }
        },
      );
    } catch (e) {
      dev.log('Password change error: $e', name: 'ChangePassword');
      Get.snackbar(
        "Error",
        "An unexpected error occurred",
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
      );
    } finally {
      isLoading.value = false;
    }
  }
}