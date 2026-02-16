import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mcd/app/modules/electricity_module/model/electricity_provider_model.dart';
import 'package:mcd/app/modules/general_payout/general_payout_controller.dart';
import 'package:mcd/app/routes/app_pages.dart';
import 'package:mcd/app/styles/app_colors.dart';
import 'dart:developer' as dev;

import '../../../core/network/dio_api_service.dart';

class ElectricityModuleController extends GetxController {
  final apiService = DioApiService();
  final box = GetStorage();

  final formKey = GlobalKey<FormState>();
  final meterNoController = TextEditingController();
  final amountController = TextEditingController();

  final electricityProviders = <ElectricityProvider>[].obs;
  final selectedProvider = Rxn<ElectricityProvider>();
  final paymentTypes = ['Prepaid', 'Postpaid'].obs;
  final selectedPaymentType = 'Prepaid'.obs;

  final isLoading = true.obs;
  final isPaying = false.obs;
  final isValidating = false.obs;
  final errorMessage = RxnString();
  final validatedCustomerName = RxnString();
  final validationDetails = Rxn<Map<String, dynamic>>();

  final Map<String, String> providerImages = {
    'IKEDC': 'assets/images/electricity/IKEDC.png',
    'EKEDC': 'assets/images/electricity/EKEDC.png',
    'IBEDC': 'assets/images/electricity/IBEDC.png',
    'KEDCO': 'assets/images/electricity/KEDCO.png',
    'PHED': 'assets/images/electricity/PHED.png',
    'JED': 'assets/images/electricity/JED.png',
    'KAEDCO': 'assets/images/electricity/KAEDCO.png',
    'AEDC': 'assets/images/electricity/AEDC.png',
    'EEDC': 'assets/images/electricity/EEDC.png',
    'DEFAULT': 'assets/images/electricity/ABA.png',
  };

  @override
  void onInit() {
    super.onInit();
    dev.log('ElectricityModuleController initialized', name: 'ElectricityModule');
    fetchElectricityProviders();

    // Add listener to clear validation when meter number changes
    meterNoController.addListener(() {
      if (meterNoController.text.isEmpty) {
        validatedCustomerName.value = null;
        dev.log('Meter number cleared', name: 'ElectricityModule');
      } else if (validatedCustomerName.value != null) {
        // Clear validation if meter number is changed after validation
        validatedCustomerName.value = null;
        dev.log('Meter number changed, clearing validation', name: 'ElectricityModule');
      }
    });
  }

  @override
  void onClose() {
    meterNoController.dispose();
    amountController.dispose();
    super.onClose();
  }

  void onProviderSelected(ElectricityProvider? provider) {
    if (provider != null) {
      selectedProvider.value = provider;
      validatedCustomerName.value = null;
      dev.log('Provider selected: ${provider.name}', name: 'ElectricityModule');
    }
  }

  void onPaymentTypeSelected(String? type) {
    if (type != null) {
      selectedPaymentType.value = type;
      dev.log('Payment type selected: $type', name: 'ElectricityModule');
    }
  }

  void onAmountSelected(String amount) {
    amountController.text = amount;
    dev.log('Amount selected: ₦$amount', name: 'ElectricityModule');
  }

  Future<void> fetchElectricityProviders() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;
      dev.log('Fetching electricity providers...', name: 'ElectricityModule');

      final transactionUrl = box.read('transaction_service_url');
      if (transactionUrl == null || transactionUrl.isEmpty) {
        errorMessage.value = "Service URL not found.";
        dev.log('Transaction URL not found', name: 'ElectricityModule', error: errorMessage.value);
        return;
      }

      final fullUrl = '$transactionUrl''electricity';
      dev.log('Request URL: $fullUrl', name: 'ElectricityModule');
      final result = await apiService.getrequest(fullUrl);

      result.fold(
        (failure) {
          errorMessage.value = failure.message;
          dev.log('Failed to fetch providers', name: 'ElectricityModule', error: failure.message);
        },
        (data) {
          dev.log('Providers fetched successfully', name: 'ElectricityModule');
          if (data['data'] != null && data['data'] is List) {
            final providers = (data['data'] as List)
                .map((item) => ElectricityProvider.fromJson(item))
                .toList();
            electricityProviders.assignAll(providers);
            dev.log('Loaded ${providers.length} providers', name: 'ElectricityModule');
            if (providers.isNotEmpty) {
              selectedProvider.value = providers.first;
              dev.log('Auto-selected provider: ${selectedProvider.value?.name}', name: 'ElectricityModule');
            }
          } else {
            errorMessage.value = "No providers found.";
            dev.log('No providers in response', name: 'ElectricityModule', error: errorMessage.value);
          }
        },
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> validateMeterNumber() async {
    // Prevent multiple simultaneous validations
    if (isValidating.value) {
      dev.log('Validation already in progress, skipping', name: 'ElectricityModule');
      return;
    }

    isValidating.value = true;
    validatedCustomerName.value = null;
    dev.log('Validating meter: ${meterNoController.text} for provider: ${selectedProvider.value?.code}', name: 'ElectricityModule');

    try {
      final transactionUrl = box.read('transaction_service_url');
      if (transactionUrl == null) {
        dev.log('Transaction URL not found during validation', name: 'ElectricityModule', error: 'URL missing');
        Get.snackbar("Error", "Transaction URL not found.", backgroundColor: AppColors.errorBgColor, colorText: AppColors.textSnackbarColor);
        return;
      }

      final body = {
        "service": "electricity",
        "provider": selectedProvider.value!.code.toLowerCase(),
        "number": meterNoController.text,
      };

      dev.log('Validation request body: $body', name: 'ElectricityModule');
      final result = await apiService.postrequest('$transactionUrl''validate', body);

      result.fold(
        (failure) {
          dev.log('Validation failed', name: 'ElectricityModule', error: failure.message);
          Get.snackbar("Validation Failed", failure.message, backgroundColor: AppColors.errorBgColor, colorText: AppColors.textSnackbarColor);
        },
        (data) {
          dev.log('Validation response: $data', name: 'ElectricityModule');
          if (data['success'] == 1) {
            // Try multiple possible locations for customer name
            String? customerName;
            
            // Check if data field is a string (customer name directly)
            if (data['data'] != null && data['data'] is String) {
              customerName = data['data'].toString().trim();
            }
            // Check details object
            else if (data['details'] != null && data['details']['Customer_Name'] != null) {
              customerName = data['details']['Customer_Name'].toString().trim();
            }
            // Check data object with name field
            else if (data['data'] != null && data['data'] is Map && data['data']['name'] != null) {
              customerName = data['data']['name'].toString().trim();
            }
            
            if (customerName != null && customerName.isNotEmpty) {
              validatedCustomerName.value = customerName;
              // Store full validation details
              validationDetails.value = data['details'] ?? {};
              dev.log('Meter validated successfully: ${validatedCustomerName.value}', name: 'ElectricityModule');
              Get.snackbar(
                "Validation Successful", 
                "Customer: ${validatedCustomerName.value}", 
                backgroundColor: AppColors.successBgColor, 
                colorText: AppColors.textSnackbarColor,
                duration: const Duration(seconds: 2),
              );
            } else {
              dev.log('Validation unsuccessful: No customer name found', name: 'ElectricityModule', error: 'Customer name missing');
              Get.snackbar(
                "Validation Failed", 
                "Could not retrieve customer name.", 
                backgroundColor: AppColors.errorBgColor, 
                colorText: AppColors.textSnackbarColor,
                duration: const Duration(seconds: 2),
              );
            }
          } else {
            dev.log('Validation unsuccessful', name: 'ElectricityModule', error: data['message']);
            Get.snackbar(
              "Validation Failed", 
              data['message'] ?? "Could not validate meter number.", 
              backgroundColor: AppColors.errorBgColor, 
              colorText: AppColors.textSnackbarColor,
              duration: const Duration(seconds: 2),
            );
          }
        },
      );
    } finally {
      isValidating.value = false;
    }
  }

  void pay() {
    dev.log('Payment initiated', name: 'ElectricityModule');

    if (selectedProvider.value == null) {
      dev.log('Payment failed: No provider selected', name: 'ElectricityModule', error: 'Provider missing');
      Get.snackbar("Error", "Please select an electricity provider.", backgroundColor: AppColors.errorBgColor, colorText: AppColors.textSnackbarColor);
      return;
    }

    if (meterNoController.text.isEmpty) {
      dev.log('Payment failed: No meter number', name: 'ElectricityModule', error: 'Meter number missing');
      Get.snackbar("Error", "Please enter your meter number.", backgroundColor: AppColors.errorBgColor, colorText: AppColors.textSnackbarColor);
      return;
    }

    if (validatedCustomerName.value == null) {
      dev.log('Payment failed: Meter not validated', name: 'ElectricityModule', error: 'Validation missing');
      Get.snackbar("Error", "Please validate your meter number first.", backgroundColor: AppColors.errorBgColor, colorText: AppColors.textSnackbarColor);
      return;
    }

    if (formKey.currentState?.validate() ?? false) {
      // Get provider image
      String providerImage = '';
      if (selectedProvider.value?.name != null) {
        providerImage = providerImages[selectedProvider.value!.name.toUpperCase()] ?? providerImages['DEFAULT']!;
      }
      
      dev.log('Navigating to payout with: Provider=${selectedProvider.value?.name}, Amount=₦${amountController.text}', name: 'ElectricityModule');
      Get.toNamed(
        Routes.GENERAL_PAYOUT,
        arguments: {
          'paymentType': PaymentType.electricity,
          'paymentData': {
            'provider': selectedProvider.value,
            'providerImage': providerImage,
            'meterNumber': meterNoController.text,
            'amount': double.tryParse(amountController.text) ?? 0.0,
            'paymentType': selectedPaymentType.value,
            'customerName': validatedCustomerName.value,
            'validationDetails': validationDetails.value,
          },
        },
      );
    }
  }
}