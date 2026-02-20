import 'package:get_storage/get_storage.dart';
import 'package:mcd/app/modules/betting_module/model/betting_provider_model.dart';
import 'package:mcd/app/modules/general_payout/general_payout_controller.dart';
import 'package:mcd/core/import/imports.dart';
import 'dart:developer' as dev;

import '../../../core/network/dio_api_service.dart';

class BettingModuleController extends GetxController {
  final apiService = DioApiService();
  final box = GetStorage();

  final userIdController = TextEditingController();
  final amountController = TextEditingController();
  final selectedAmount = ''.obs;
  final selectedProvider = Rxn<BettingProvider>();
  final bettingProviders = <BettingProvider>[].obs;

  final isLoading = true.obs;
  final isPaying = false.obs;
  final errorMessage = RxnString();

  final validatedUserName = RxnString();

  final Map<String, String> providerImages = {
    'MYLOTTOHUB': 'assets/images/betting/MYLOTTOHUB.png',
    'CLOUDBET': 'assets/images/betting/CLOUDBET.png',
    'NAIJABET': 'assets/images/betting/NAIJABET.png',
    'BANGBET': 'assets/images/betting/BANGBET.png',
    'BETWAY': 'assets/images/betting/BETWAY.png',
    'MERRYBET': 'assets/images/betting/MERRYBET.png',
    'BETKING': 'assets/images/betting/BETKING.png',
    'BETLION': 'assets/images/betting/BETLION.png',
    'SPORTYBET': AppAsset.betting,
    'DEFAULT': 'assets/images/betting/1XBET.png',
  };

  @override
  void onInit() {
    super.onInit();
    dev.log('BettingModuleController initialized', name: 'BettingModule');
    fetchBettingProviders();

    // Add listener to clear validation when user ID changes
    userIdController.addListener(() {
      if (userIdController.text.isEmpty || validatedUserName.value != null) {
        // Clear validation if user ID is changed after validation
        validatedUserName.value = null;
        dev.log('User ID changed, clearing validation', name: 'BettingModule');
      }
    });
  }

  @override
  void onClose() {
    userIdController.dispose();
    amountController.dispose();
    super.onClose();
  }

  void onProviderSelected(BettingProvider? provider) {
    if (provider != null) {
      selectedProvider.value = provider;
      validatedUserName.value = null;
      dev.log('Provider selected: ${provider.name}', name: 'BettingModule');
    }
  }

  void onAmountSelected(String amount) {
    amountController.text = amount.replaceAll('₦', '').trim();
    selectedAmount.value = amount;
    dev.log('Amount selected: ${amountController.text}', name: 'BettingModule');
  }

  Future<void> fetchBettingProviders() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;
      dev.log('Fetching betting providers...', name: 'BettingModule');

      final transactionUrl = box.read('transaction_service_url');
      if (transactionUrl == null || transactionUrl.isEmpty) {
        errorMessage.value = "Service URL not found. Please log in again.";
        dev.log('Transaction URL not found',
            name: 'BettingModule', error: errorMessage.value);
        return;
      }

      final fullUrl = '$transactionUrl' 'betting';
      dev.log('Request URL: $fullUrl', name: 'BettingModule');
      final result = await apiService.getrequest(fullUrl);

      result.fold(
        (failure) {
          errorMessage.value = failure.message;
          dev.log('Failed to fetch providers',
              name: 'BettingModule', error: failure.message);
        },
        (data) {
          dev.log('Providers fetched successfully', name: 'BettingModule');
          if (data['data'] != null && data['data'] is List) {
            final List<dynamic> providersJson = data['data'];
            bettingProviders.assignAll(
              providersJson
                  .map((item) => BettingProvider.fromJson(item))
                  .toList(),
            );
            dev.log('Loaded ${bettingProviders.length} providers',
                name: 'BettingModule');
            if (bettingProviders.isNotEmpty) {
              selectedProvider.value = bettingProviders.first;
              dev.log('Auto-selected provider: ${selectedProvider.value?.name}',
                  name: 'BettingModule');
            }
          } else {
            errorMessage.value = "No betting providers found.";
            dev.log('No providers in response',
                name: 'BettingModule', error: errorMessage.value);
          }
        },
      );
    } catch (e) {
      errorMessage.value = "An unexpected error occurred: $e";
      dev.log("Error fetching providers", name: 'BettingModule', error: e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> validateUser() async {
    // Prevent multiple simultaneous validations
    if (isPaying.value) {
      dev.log('Validation already in progress, skipping',
          name: 'BettingModule');
      return;
    }

    isPaying.value = true;
    validatedUserName.value = null;
    dev.log(
        'Validating user: ${userIdController.text} with provider: ${selectedProvider.value?.code}',
        name: 'BettingModule');

    try {
      final transactionUrl = box.read('transaction_service_url');
      if (transactionUrl == null) {
        dev.log('Transaction URL not found during validation',
            name: 'BettingModule', error: 'URL missing');
        Get.snackbar(
          "Error",
          "Transaction URL not found.",
          backgroundColor: AppColors.errorBgColor,
          colorText: AppColors.textSnackbarColor,
          duration: const Duration(seconds: 2),
        );
        return;
      }

      final body = {
        "service": "betting",
        "provider": selectedProvider.value!.code,
        "number": userIdController.text,
      };

      dev.log('Validation request body: $body', name: 'BettingModule');
      final result =
          await apiService.postrequest('$transactionUrl' 'validate', body);

      result.fold(
        (failure) {
          dev.log('Validation failed',
              name: 'BettingModule', error: failure.message);
          Get.snackbar(
            "Validation Failed",
            failure.message,
            backgroundColor: AppColors.errorBgColor,
            colorText: AppColors.textSnackbarColor,
            duration: const Duration(seconds: 2),
          );
        },
        (data) {
          dev.log('Validation response: $data', name: 'BettingModule');
          try {
            final dynamic d = data['data'];
            if (data['success'] == 1) {
              // data['data'] may be a Map with a 'name' key, or a String like 'N/A'.
              if (d is Map && d['name'] != null) {
                validatedUserName.value = d['name'].toString();
              } else if (d is String &&
                  d.trim().isNotEmpty &&
                  d.toUpperCase() != 'N/A') {
                validatedUserName.value = d.toString();
              } else {
                validatedUserName.value = selectedProvider.value?.name ?? '';
              }

              dev.log('User validated successfully: ${validatedUserName.value}',
                  name: 'BettingModule');
              Get.snackbar(
                "Validation Successful",
                validatedUserName.value != null &&
                        validatedUserName.value!.isNotEmpty
                    ? "User: ${validatedUserName.value}"
                    : (data['message']?.toString() ?? "Validation Successful"),
                backgroundColor: AppColors.successBgColor,
                colorText: AppColors.textSnackbarColor,
                duration: const Duration(seconds: 2),
              );
            } else {
              dev.log('Validation unsuccessful',
                  name: 'BettingModule', error: data['message']);
              Get.snackbar(
                "Validation Failed",
                data['message'] ?? "Could not validate user.",
                backgroundColor: AppColors.errorBgColor,
                colorText: AppColors.textSnackbarColor,
                duration: const Duration(seconds: 2),
              );
            }
          } catch (e) {
            dev.log('Error parsing validation response',
                name: 'BettingModule', error: e);
            Get.snackbar(
              "Validation Failed",
              data['message'] ?? "Could not validate user.",
              backgroundColor: AppColors.errorBgColor,
              colorText: AppColors.textSnackbarColor,
              duration: const Duration(seconds: 2),
            );
          }
        },
      );
    } finally {
      isPaying.value = false;
    }
  }

  void pay() async {
    dev.log('Navigating to payout screen', name: 'BettingModule');

    if (selectedProvider.value == null) {
      dev.log('Navigation failed: No provider selected',
          name: 'BettingModule', error: 'Provider missing');
      Get.snackbar("Error", "Please select a betting provider.",
          backgroundColor: AppColors.errorBgColor,
          colorText: AppColors.textSnackbarColor);
      return;
    }

    if (userIdController.text.isEmpty) {
      dev.log('Navigation failed: No user ID',
          name: 'BettingModule', error: 'User ID missing');
      Get.snackbar("Error", "Please enter a User ID.",
          backgroundColor: AppColors.errorBgColor,
          colorText: AppColors.textSnackbarColor);
      return;
    }

    if (amountController.text.isEmpty) {
      dev.log('Navigation failed: No amount',
          name: 'BettingModule', error: 'Amount missing');
      Get.snackbar("Error", "Please enter an amount.",
          backgroundColor: AppColors.errorBgColor,
          colorText: AppColors.textSnackbarColor);
      return;
    }

    final selectedImage = providerImages[selectedProvider.value!.name] ??
        providerImages['DEFAULT']!;
    final cleanAmount =
        amountController.text.replaceAll('₦', '').replaceAll(',', '').trim();

    Get.toNamed(
      Routes.GENERAL_PAYOUT,
      arguments: {
        'paymentType': PaymentType.betting,
        'paymentData': {
          'providerName': selectedProvider.value!.name,
          'providerCode': selectedProvider.value!.code,
          'providerImage': selectedImage,
          'userId': userIdController.text,
          'customerName':
              validatedUserName.value ?? selectedProvider.value!.name,
          'amount': cleanAmount,
        },
      },
    );
  }
}
