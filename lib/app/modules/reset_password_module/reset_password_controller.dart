import 'dart:async';
import 'dart:developer' as dev;

import 'package:mcd/core/import/imports.dart';
import 'package:mcd/core/network/api_constants.dart';

import '../../../core/network/dio_api_service.dart';
/**
 * GetX Template Generator - fb.com/htngu.99
 * */

class ResetPasswordController extends GetxController {
  final _obj = ''.obs;
  set obj(value) => _obj.value = value;
  get obj => _obj.value;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController codeController = TextEditingController();

  // OTP field controller for better control
  final OtpFieldController otpController = OtpFieldController();

  var apiService = DioApiService();

  final formKey1 = GlobalKey<FormState>();
  final formKey2 = GlobalKey<FormState>();
  final formKey3 = GlobalKey<FormState>();
  RxBool isEmail = false.obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();
  final RxBool isOtpSent = false.obs;
  RxBool isValid = false.obs;

  // Password strength tracking
  final _passwordStrength = 0.obs;
  int get passwordStrength => _passwordStrength.value;

  final _passwordStrengthLabel = 'Very Weak'.obs;
  String get passwordStrengthLabel => _passwordStrengthLabel.value;

  // Individual password requirements
  final _hasMinLength = false.obs;
  bool get hasMinLength => _hasMinLength.value;

  final _startsWithUppercase = false.obs;
  bool get startsWithUppercase => _startsWithUppercase.value;

  final _hasUppercase = false.obs;
  bool get hasUppercase => _hasUppercase.value;

  final _hasLowercase = false.obs;
  bool get hasLowercase => _hasLowercase.value;

  final _hasNumber = false.obs;
  bool get hasNumber => _hasNumber.value;

  final _hasSpecialChar = false.obs;
  bool get hasSpecialChar => _hasSpecialChar.value;

  // Track if password field has text
  final _hasPasswordText = false.obs;
  bool get hasPasswordText => _hasPasswordText.value;

  RxInt minutes = 1.obs;
  RxInt seconds = 00.obs;
  Timer? timer;

  bool get canResend => minutes.value == 0 && seconds.value == 0;

  void startTimer({int startMinutes = 1, int startSeconds = 30}) {
    // cancel any existing timer before starting a new one
    timer?.cancel();
    minutes.value = startMinutes;
    seconds.value = startSeconds;
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (minutes.value == 0 && seconds.value == 0) {
        t.cancel();
      } else if (seconds.value == 0) {
        minutes.value -= 1;
        seconds.value = 59;
      } else {
        seconds.value -= 1;
      }
    });
  }

  void cancelTimer() {
    timer?.cancel();
  }

  /// Update password strength in real-time
  void updatePasswordStrength(String password) {
    _hasPasswordText.value = password.isNotEmpty;
    _hasMinLength.value = CustomValidator.hasMinLength(password);
    _startsWithUppercase.value = CustomValidator.startsWithUppercase(password);
    _hasUppercase.value = CustomValidator.hasUppercase(password);
    _hasLowercase.value = CustomValidator.hasLowercase(password);
    _hasNumber.value = CustomValidator.hasNumber(password);
    _hasSpecialChar.value = CustomValidator.hasSpecialChar(password);

    _passwordStrength.value =
        CustomValidator.calculatePasswordStrength(password);
    _passwordStrengthLabel.value =
        CustomValidator.getPasswordStrengthLabel(_passwordStrength.value);
  }

  @override
  void onInit() {
    // Listen to password changes
    newPasswordController.addListener(() {
      updatePasswordStrength(newPasswordController.text);
    });
    super.onInit();
  }

  @override
  void dispose() {
    cancelTimer();
    newPasswordController.removeListener(() {});
    emailController.dispose();
    passwordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void validateInput() {
    if (formKey3.currentState == null) return;
    if (formKey3.currentState!.validate()) {
      isValid.value = true;
    } else {
      isValid.value = true;
    }
  }

  Future<void> resetPassword(BuildContext context, String email) async {
    try {
      showLoadingDialog(context: context);
      isLoading.value = true;
      errorMessage.value = null;

      final result = await apiService.postrequest(
          "${ApiConstants.authUrlV2}/resetpassword", {"email": email.trim()});

      Get.back(); // close loader

      result.fold(
        (failure) {
          errorMessage.value = failure.message;
          dev.log("Reset password error: ${errorMessage.value}");
          Get.snackbar(
            "Error",
            errorMessage.value!,
            backgroundColor: AppColors.errorBgColor,
            colorText: AppColors.textSnackbarColor,
          );
        },
        (data) {
          dev.log("Reset password response: $data");
          final success = data['success'];

          if (success == 1) {
            isOtpSent.value = true;
            dev.log("OTP sent successfully to $email");
            Get.snackbar(
              "Success",
              data['message'] ?? "OTP sent to $email",
              backgroundColor: AppColors.successBgColor,
              colorText: AppColors.textSnackbarColor,
            );
            startTimer();
            Get.toNamed(Routes.VERIFY_RESET_PASSWORD_OTP,
                arguments: {'email': email});
          } else {
            errorMessage.value = data['message'] ?? "Failed to send OTP";
            dev.log("Reset password failed: ${errorMessage.value}");
            Get.snackbar(
              "Error",
              errorMessage.value!,
              backgroundColor: AppColors.errorBgColor,
              colorText: AppColors.textSnackbarColor,
            );
          }
        },
      );
    } catch (e) {
      // Safely close loader
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      isLoading.value = false;
      errorMessage.value = "An unexpected error occurred, please try again";
      dev.log("Reset password exception: $e");
      Get.snackbar(
        "Error",
        errorMessage.value!,
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
      );
    }
  }

  Future<void> resetPasswordCheck(
      BuildContext context, String email, String code) async {
    try {
      showLoadingDialog(context: context);
      isLoading.value = true;
      errorMessage.value = null;
      dev.log("Verifying code: $code for email: $email");

      final result = await apiService.postrequest(
          "${ApiConstants.authUrlV2}/resetpassword-check",
          {"email": email.trim(), 'code': code.trim()});

      // Safely close loader
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      isLoading.value = false;

      result.fold(
        (failure) {
          errorMessage.value = failure.message;
          dev.log("Code verification error: ${errorMessage.value}");
          Get.snackbar(
            "Error",
            errorMessage.value!,
            backgroundColor: AppColors.errorBgColor,
            colorText: AppColors.textSnackbarColor,
          );
        },
        (data) {
          dev.log("Code verification response: $data");
          final success = data['success'];

          if (success == 1) {
            dev.log("Code verified successfully");
            Get.snackbar(
              "Success",
              data['message'] ?? "Code verified successfully",
              backgroundColor: AppColors.successBgColor,
              colorText: AppColors.textSnackbarColor,
            );
            Get.toNamed(Routes.CHANGE_RESET_PASSWORD,
                arguments: {'email': email, 'code': code});
          } else {
            errorMessage.value = data['message'] ?? "Invalid code";
            dev.log("Code verification failed: ${errorMessage.value}");
            Get.back();
            Get.snackbar(
              "Error",
              errorMessage.value!,
              backgroundColor: AppColors.errorBgColor,
              colorText: AppColors.textSnackbarColor,
            );
          }
        },
      );
    } catch (e) {
      // Safely close loader
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      isLoading.value = false;
      errorMessage.value = "An unexpected error occurred, please try again";
      dev.log("Code verification exception: $e");
      Get.snackbar(
        "Error",
        errorMessage.value!,
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
      );
    }
  }

  Future<void> changeResetPassword(
      BuildContext context, String email, String code, String password) async {
    try {
      showLoadingDialog(context: context);
      isLoading.value = true;
      errorMessage.value = null;
      dev.log("Changing password for: $email");

      final result = await apiService.putrequest(
          "${ApiConstants.authUrlV2}/resetpassword", {
        "email": email.trim(),
        'code': code.trim(),
        'password': password.trim()
      });

      // Safely close loader
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      isLoading.value = false;

      result.fold(
        (failure) {
          errorMessage.value = failure.message;
          dev.log("Password change error: ${errorMessage.value}");
          Get.snackbar(
            "Error",
            errorMessage.value!,
            backgroundColor: AppColors.errorBgColor,
            colorText: AppColors.textSnackbarColor,
          );
        },
        (data) {
          dev.log("Password change response: $data");
          final success = data['success'];

          if (success == 1) {
            dev.log("Password changed successfully");

            // Navigate to login immediately to avoid Obx errors
            if (Get.currentRoute != Routes.LOGIN_SCREEN) {
              Get.offAllNamed(Routes.LOGIN_SCREEN);
            }

            // Show success message after navigation
            Future.delayed(const Duration(milliseconds: 300), () {
              Get.snackbar(
                "Success",
                data['message'] ?? "Password changed successfully",
                backgroundColor: AppColors.successBgColor,
                colorText: AppColors.textSnackbarColor,
              );
            });
          } else {
            errorMessage.value = data['message'] ?? "Failed to change password";
            dev.log("Password change failed: ${errorMessage.value}");
            Get.snackbar(
              "Error",
              errorMessage.value!,
              backgroundColor: AppColors.errorBgColor,
              colorText: AppColors.textSnackbarColor,
            );
          }
        },
      );
    } catch (e) {
      // Safely close loader
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      isLoading.value = false;
      errorMessage.value = "An unexpected error occurred, please try again";
      dev.log("Password change exception: $e");
      Get.snackbar(
        "Error",
        errorMessage.value!,
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
      );
    }
  }

  Future<void> resendOtp(BuildContext context, String email) async {
    try {
      showLoadingDialog(context: context);
      isLoading.value = true;
      errorMessage.value = null;
      dev.log("Resending OTP to: $email");

      final result = await apiService.postrequest(
          "${ApiConstants.authUrlV2}/resetpassword", {"email": email.trim()});

      // Safely close loader
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      isLoading.value = false;

      result.fold(
        (failure) {
          errorMessage.value = failure.message;
          dev.log("Resend OTP error: ${errorMessage.value}");
          dev.log("Reset password error: ${errorMessage.value}");
          Get.snackbar(
            "Error",
            errorMessage.value!,
            backgroundColor: AppColors.errorBgColor,
            colorText: AppColors.textSnackbarColor,
          );
        },
        (data) {
          dev.log("Reset password response: $data");
          final success = data['success'];
          if (success == 1) {
            isOtpSent.value = true;
            dev.log("OTP resent successfully to $email");
            Get.snackbar(
              "Success",
              data['message'] ?? "OTP sent to $email",
              backgroundColor: AppColors.successBgColor,
              colorText: AppColors.textSnackbarColor,
            );
            // Restart countdown on success with 1 minute 30 seconds
            startTimer(startMinutes: 1, startSeconds: 30);
          } else {
            errorMessage.value = data['message'] ?? "Failed to resend OTP";
            dev.log("Resend OTP failed: ${errorMessage.value}");
            Get.snackbar(
              "Error",
              errorMessage.value!,
              backgroundColor: AppColors.errorBgColor,
              colorText: AppColors.textSnackbarColor,
            );
          }
        },
      );
    } catch (e) {
      // Safely close loader
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      isLoading.value = false;
      errorMessage.value = "An unexpected error occurred, please try again";
      dev.log("Resend OTP exception: $e");
      Get.snackbar(
        "Error",
        errorMessage.value!,
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
      );
    }
  }
}
