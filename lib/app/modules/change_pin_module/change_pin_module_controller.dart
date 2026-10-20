import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mcd/app/styles/app_colors.dart';
import 'package:mcd/core/network/api_constants.dart';
import 'package:mcd/core/network/dio_api_service.dart';
import 'dart:developer' as dev;

class ChangePinModuleController extends GetxController {
  final formKey = GlobalKey<FormState>();
  
  final oldPinController = TextEditingController();
  final newPinController = TextEditingController();
  final confirmPinController = TextEditingController();
  
  final isLoading = false.obs;
  
  final apiService = DioApiService();
  final box = GetStorage();
  
  @override
  void onClose() {
    oldPinController.dispose();
    newPinController.dispose();
    confirmPinController.dispose();
    super.onClose();
  }
  
  Future<void> changePin() async {
    if (formKey.currentState == null || !formKey.currentState!.validate()) {
      return;
    }
    
    if (newPinController.text != confirmPinController.text) {
      Get.snackbar(
        "Error",
        "New PINs do not match",
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
      );
      return;
    }
    
    try {
      isLoading.value = true;
      
      final utilityUrl = box.read('utility_service_url');
      // final utilityUrl = 'https://auth.mcd.5starcompany.com.ng/api/v2/';
      if (utilityUrl == null) {
        Get.snackbar(
          "Error",
          "Service URL not found. Please login again.",
          backgroundColor: AppColors.errorBgColor,
          colorText: AppColors.textSnackbarColor,
        );
        return;
      }
      
      final body = {
        "o_pin": oldPinController.text.trim(),
        "n_pin": newPinController.text.trim(),
      };
      
      dev.log('Change pin request: $body', name: 'ChangePin');
      
      // final result = await apiService.postrequest(
      //   '${utilityUrl}change-pin',
      //   body,
      // );
      final result = await apiService.postrequest(
        '${ApiConstants.authUrlV2}/change-pin',
        body,
      );
      
      result.fold(
        (failure) {
          dev.log('PIN change failed: ${failure.message}', name: 'ChangePin');
          Get.snackbar(
            "Error",
            failure.message,
            backgroundColor: AppColors.errorBgColor,
            colorText: AppColors.textSnackbarColor,
          );
        },
        (data) {
          dev.log('PIN change response: $data', name: 'ChangePin');
          if (data['success'] == 1 || data['message']?.toString().toLowerCase().contains('success') == true) {
            Get.snackbar(
              "Success",
              data['message'] ?? "PIN changed successfully",
              backgroundColor: AppColors.successBgColor,
              colorText: AppColors.textSnackbarColor,
            );
            
            // Clear the form
            oldPinController.clear();
            newPinController.clear();
            confirmPinController.clear();
            
            // Navigate back after a short delay
            Future.delayed(const Duration(seconds: 1), () {
              Get.back();
            });
          } else {
            Get.snackbar(
              "Error",
              data['message'] ?? "Failed to change PIN",
              backgroundColor: AppColors.errorBgColor,
              colorText: AppColors.textSnackbarColor,
            );
          }
        },
      );
    } catch (e) {
      dev.log('PIN change error: $e', name: 'ChangePin');
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