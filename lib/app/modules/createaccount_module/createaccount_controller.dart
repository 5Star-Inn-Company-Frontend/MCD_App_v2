import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mcd/app/modules/home_screen_module/model/dashboard_model.dart';
import 'package:mcd/app/modules/login_screen_module/models/user_signup_data.dart';
import 'package:mcd/app/routes/app_pages.dart';
import 'package:mcd/app/styles/app_colors.dart';
import 'package:mcd/app/widgets/loading_dialog.dart';
import 'package:mcd/core/network/api_constants.dart';
import 'package:mcd/core/utils/validator.dart';
import '../../../core/network/dio_api_service.dart';
/**
 * GetX Template Generator - fb.com/htngu.99
 * */

class createaccountController extends GetxController {
  var _obj = ''.obs;
  set obj(value) => _obj.value = value;
  get obj => _obj.value;

  final formKey = GlobalKey<FormState>();

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController countryController = TextEditingController();

  final _isPasswordVisible = false.obs;
  set isPasswordVisible(value) => _isPasswordVisible.value = value;
  get isPasswordVisible => _isPasswordVisible.value;

  final _isFormValid = false.obs;
  set isFormValid(value) => _isFormValid.value = value;
  get isFormValid => _isFormValid.value;

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

  final box = GetStorage();

  final isLoading = false.obs;
  final errorMessage = RxnString();
  UserSignupData? pendingSignupData;
  final RxBool isOtpSent = false.obs;

  final dashboardData = Rxn<DashboardModel>();

  void validateForm() {
    if (formKey.currentState == null) return;
    isFormValid = formKey.currentState!.validate();
  }

  /// Update password strength in real-time
  void updatePasswordStrength(String password) {
    _hasMinLength.value = CustomValidator.hasMinLength(password);
    _startsWithUppercase.value = CustomValidator.startsWithUppercase(password);
    _hasUppercase.value = CustomValidator.hasUppercase(password);
    _hasLowercase.value = CustomValidator.hasLowercase(password);
    _hasNumber.value = CustomValidator.hasNumber(password);
    _hasSpecialChar.value = CustomValidator.hasSpecialChar(password);
    
    _passwordStrength.value = CustomValidator.calculatePasswordStrength(password);
    _passwordStrengthLabel.value = CustomValidator.getPasswordStrengthLabel(_passwordStrength.value);
  }

  @override
  void onInit() {
    countryController.text = "+234";
    // Listen to password changes
    passwordController.addListener(() {
      updatePasswordStrength(passwordController.text);
    });
    super.onInit();
  }

  @override
  void dispose() {
    passwordController.removeListener(() {});
    super.dispose();
  }

  var apiService = DioApiService();

  Future<void> createaccount(dynamic otp, BuildContext context) async {
    var jsondata = {
      "user_name": usernameController.text.trim(),
      "password": passwordController.text.trim(),
      "phoneno": phoneNumberController.text.trim(),
      "email": emailController.text.trim(),
      "referral": "",
      "code": otp,
      "version": "1.0.0",
    };
    
    dev.log("Request payload: $jsondata", name: 'Signup');
    dev.log("API endpoint: ${ApiConstants.authUrlV2}/signup", name: 'Signup');
    
    try {
      showLoadingDialog(context: context);
      isLoading.value = true;
      
      var result = await apiService.postrequest("${ApiConstants.authUrlV2}/signup", jsondata);
      
      // Close loading dialog
      Get.back();
      isLoading.value = false;
      
      result.fold(
        (failure) {
          errorMessage.value = failure.message;
          dev.log("Signup error: ${errorMessage.value}", name: 'Signup');
          Get.snackbar("Error", errorMessage.value!, backgroundColor: AppColors.errorBgColor, colorText: AppColors.textSnackbarColor);
        },
        (authResult) {
          dev.log("Response data: $authResult", name: 'Signup');
          final success = authResult["success"];
          dev.log("Success value: $success (type: ${success.runtimeType})", name: 'Signup');
          
          if (success == 1 || success == true) {
            dev.log("Signup successful - Redirecting to login", name: 'Signup');
            Get.snackbar("Success", "Registration complete, please login", backgroundColor: AppColors.successBgColor, colorText: AppColors.textSnackbarColor);
            if (Get.currentRoute != Routes.LOGIN_SCREEN) {
              Get.offAllNamed(Routes.LOGIN_SCREEN);
            }
          } else {
            dev.log("Signup failed: ${authResult["message"]}", name: 'Signup');
            Get.snackbar("Error", authResult["message"] ?? "Signup failed", backgroundColor: AppColors.errorBgColor, colorText: AppColors.textSnackbarColor);
          }
        },
      );
    } catch (e) {
      dev.log("Exception occurred: $e", name: 'Signup', error: e);
      
      // Close loading dialog
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      isLoading.value = false;
      
      Get.snackbar("Error", "Unexpected error: $e", backgroundColor: AppColors.errorBgColor, colorText: AppColors.textSnackbarColor);
    }
  }    
}
  