import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mcd/app/routes/app_pages.dart';
import 'package:mcd/app/styles/app_colors.dart';
import 'package:mcd/core/network/api_constants.dart';
import 'package:mcd/core/network/dio_api_service.dart';
import 'dart:developer' as dev;

class NewDeviceVerifyController extends GetxController {
  final apiService = DioApiService();
  final box = GetStorage();

  final codeController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final isLoading = false.obs;
  final isResending = false.obs;

  String? username;
  String? password;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    username = args?['username'];
    password = args?['password'];
    dev.log('NewDeviceVerify initialized for: $username', name: 'DeviceVerify');
  }

  @override
  void onClose() {
    codeController.dispose();
    super.onClose();
  }

  // verify the 8-digit code
  Future<void> verifyCode() async {
    if (!formKey.currentState!.validate()) return;

    final code = codeController.text.trim();
    if (code.length != 8) {
      Get.snackbar(
        'Error',
        'Please enter the 8-digit verification code',
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
      );
      return;
    }

    try {
      isLoading.value = true;

      final endpoint = '${ApiConstants.authUrlV2}/newdevice';
      final payload = {
        'user_name': username,
        'code': code,
      };
      dev.log('Verifying device - URL: $endpoint', name: 'DeviceVerify');
      dev.log('Verifying device - Payload: $payload', name: 'DeviceVerify');

      final result = await apiService.postrequest(endpoint, payload);

      result.fold(
        (failure) {
          dev.log('Verification failed: ${failure.message}',
              name: 'DeviceVerify');
          Get.snackbar(
            'Error',
            failure.message,
            backgroundColor: AppColors.errorBgColor,
            colorText: AppColors.textSnackbarColor,
          );
        },
        (data) async {
          dev.log('Verification response: $data', name: 'DeviceVerify');

          if (data['success'] == 1) {
            // verification successful
            if (data['token'] != null) {
              // token provided, save and navigate to home
              final token = data['token'];
              final transactionUrl = data['transaction_service'];
              final utilityUrl = data['ultility_service'];

              await box.write('token', token);
              if (transactionUrl != null) {
                await box.write('transaction_service_url', transactionUrl);
              }
              if (utilityUrl != null) {
                await box.write('utility_service_url', utilityUrl);
              }

              dev.log('Device verified, navigating to home...',
                  name: 'DeviceVerify');
              Get.snackbar(
                'Success',
                'Device verified successfully',
                backgroundColor: AppColors.successBgColor,
                colorText: AppColors.textSnackbarColor,
              );
              Get.offAllNamed(Routes.HOME_SCREEN);
            } else {
              // no token, go back to login
              Get.snackbar(
                'Success',
                data['message'] ?? 'Device verified. Please login again.',
                backgroundColor: AppColors.successBgColor,
                colorText: AppColors.textSnackbarColor,
              );
              if (Get.currentRoute != Routes.LOGIN_SCREEN) {
                Get.offAllNamed(Routes.LOGIN_SCREEN);
              }
            }
          } else {
            Get.snackbar(
              'Error',
              data['message'] ?? 'Invalid verification code',
              backgroundColor: AppColors.errorBgColor,
              colorText: AppColors.textSnackbarColor,
            );
          }
        },
      );
    } catch (e) {
      dev.log('Verification error: $e', name: 'DeviceVerify');
      Get.snackbar(
        'Error',
        'Verification failed. Please try again.',
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // resend verification code
  Future<void> resendCode() async {
    if (username == null) return;

    try {
      isResending.value = true;

      // re-trigger login to resend code
      final endpoint = '${ApiConstants.authUrlV2}/login';
      dev.log('Resending code via login: $endpoint', name: 'DeviceVerify');

      final result = await apiService.postrequest(endpoint, {
        'user_name': username,
        'password': password ?? '',
      });

      result.fold(
        (failure) {
          Get.snackbar(
            'Error',
            'Failed to resend code',
            backgroundColor: AppColors.errorBgColor,
            colorText: AppColors.textSnackbarColor,
          );
        },
        (data) {
          if (data['success'] == 2 ||
              data['message']?.toString().contains('device') == true) {
            Get.snackbar(
              'Code Sent',
              'A new verification code has been sent to your email',
              backgroundColor: AppColors.successBgColor,
              colorText: AppColors.textSnackbarColor,
            );
          }
        },
      );
    } catch (e) {
      dev.log('Resend error: $e', name: 'DeviceVerify');
    } finally {
      isResending.value = false;
    }
  }
}
