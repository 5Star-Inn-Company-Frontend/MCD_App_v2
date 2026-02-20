import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mcd/app/styles/app_colors.dart';
import 'package:mcd/core/network/dio_api_service.dart';
import 'dart:developer' as dev;

class VirtualCardChangePinController extends GetxController {
  final oldPin = ''.obs;
  final newPin = ''.obs;
  final confirmPin = ''.obs;
  final isOldPinStep = true.obs;
  final isNewPinStep = false.obs;
  final isLoading = false.obs;
  
  final apiService = DioApiService();
  final box = GetStorage();
  
  void addDigit(String digit) {
    if (isOldPinStep.value) {
      if (oldPin.value.length < 4) {
        oldPin.value += digit;
        if (oldPin.value.length == 4) {
          // Move to new PIN step after a short delay
          Future.delayed(const Duration(milliseconds: 300), () {
            isOldPinStep.value = false;
            isNewPinStep.value = true;
          });
        }
      }
    } else if (isNewPinStep.value) {
      if (newPin.value.length < 4) {
        newPin.value += digit;
        if (newPin.value.length == 4) {
          // Move to confirm step after a short delay
          Future.delayed(const Duration(milliseconds: 300), () {
            isNewPinStep.value = false;
          });
        }
      }
    } else {
      if (confirmPin.value.length < 4) {
        confirmPin.value += digit;
        if (confirmPin.value.length == 4) {
          // Validate pins match and call API
          validateAndChangePin();
        }
      }
    }
  }
  
  void removeDigit() {
    if (isOldPinStep.value) {
      if (oldPin.value.isNotEmpty) {
        oldPin.value = oldPin.value.substring(0, oldPin.value.length - 1);
      }
    } else if (isNewPinStep.value) {
      if (newPin.value.isNotEmpty) {
        newPin.value = newPin.value.substring(0, newPin.value.length - 1);
      }
    } else {
      if (confirmPin.value.isNotEmpty) {
        confirmPin.value = confirmPin.value.substring(0, confirmPin.value.length - 1);
      }
    }
  }
  
  Future<void> validateAndChangePin() async {
    if (newPin.value != confirmPin.value) {
      // Pins don't match, reset
      Get.snackbar(
        'Error',
        'PINs do not match. Please try again.',
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
        duration: const Duration(seconds: 2),
      );
      Future.delayed(const Duration(seconds: 2), () {
        reset();
      });
      return;
    }

    // Pins match, proceed with API call
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
        isLoading.value = false;
        return;
      }
      
      final body = {
        "o_pin": oldPin.value,
        "n_pin": newPin.value,
      };
      
      dev.log('Change pin request: $body', name: 'VirtualCardChangePin');
      
      final result = await apiService.postrequest(
        '${utilityUrl}change-pin',
        body,
      );
      
      result.fold(
        (failure) {
          dev.log('PIN change failed: ${failure.message}', name: 'VirtualCardChangePin');
          Get.snackbar(
            "Error",
            failure.message,
            backgroundColor: AppColors.errorBgColor,
            colorText: AppColors.textSnackbarColor,
          );
          // Reset after error
          Future.delayed(const Duration(seconds: 2), () {
            reset();
          });
        },
        (data) {
          dev.log('PIN change response: $data', name: 'VirtualCardChangePin');
          if (data['success'] == 1 || data['message']?.toString().toLowerCase().contains('success') == true) {
            Get.snackbar(
              "Success",
              data['message'] ?? "PIN changed successfully",
              backgroundColor: AppColors.successBgColor,
              colorText: AppColors.textSnackbarColor,
            );
            
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
            // Reset after error
            Future.delayed(const Duration(seconds: 2), () {
              reset();
            });
          }
        },
      );
    } catch (e) {
      dev.log('PIN change error: $e', name: 'VirtualCardChangePin');
      Get.snackbar(
        "Error",
        "An unexpected error occurred",
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
      );
      // Reset after error
      Future.delayed(const Duration(seconds: 2), () {
        reset();
      });
    } finally {
      isLoading.value = false;
    }
  }
  
  void reset() {
    oldPin.value = '';
    newPin.value = '';
    confirmPin.value = '';
    isOldPinStep.value = true;
    isNewPinStep.value = false;
  }
}
