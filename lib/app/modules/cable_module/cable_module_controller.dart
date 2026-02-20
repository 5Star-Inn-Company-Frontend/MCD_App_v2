import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mcd/app/modules/cable_module/model/cable_package_model.dart';
import 'package:mcd/app/modules/cable_module/model/cable_provider_model.dart';
import 'package:mcd/app/modules/general_payout/general_payout_controller.dart';
import 'package:mcd/app/routes/app_pages.dart';
import 'package:mcd/app/styles/app_colors.dart';
import 'dart:developer' as dev;
import 'package:mcd/core/utils/amount_formatter.dart';

import '../../../core/network/dio_api_service.dart';

class CableModuleController extends GetxController {
  final apiService = DioApiService(); // Using Get.find() is best practice
  final box = GetStorage();

  final formKey = GlobalKey<FormState>();
  final smartCardController = TextEditingController();

  final cableProviders = <CableProvider>[].obs;
  final selectedProvider = Rxn<CableProvider>();

  final cablePackages = <CablePackage>[].obs;
  final selectedPackage = Rxn<CablePackage>();

  // isLoadingProviders is now false by default as data is local
  final isLoadingProviders = false.obs;
  final isLoadingPackages = false.obs;
  final isPaying = false.obs;
  final isValidating = false.obs;
  final errorMessage = RxnString();
  final validatedCustomerName = RxnString();
  final validatedBouquetDetails = Rxn<Map<String, dynamic>>();

  final tabBarItems =
      ['1 Month', '2 Month', '3 Month', '4 Month', '5 Month'].obs;
  final selectedTab = '1 Month'.obs;

  final providerImages = {
    'DSTV': 'assets/images/dstv.jpeg',
    'GOTV': 'assets/images/gotv.png',
    'STARTIMES': 'assets/images/startimes.jpeg',
    'SHOWMAX': 'assets/images/cable/showmax.jpeg',
  };

  @override
  void onInit() {
    super.onInit();
    dev.log('CableModuleController initialized', name: 'CableModule');

    // Initialize the static list of providers directly
    final staticProviders = [
      CableProvider(id: 1, name: 'DSTV', code: 'DSTV'),
      CableProvider(id: 2, name: 'GOTV', code: 'GOTV'),
      CableProvider(id: 3, name: 'STARTIMES', code: 'STARTIMES'),
      CableProvider(id: 4, name: 'SHOWMAX', code: 'SHOWMAX'),
    ];

    cableProviders.assignAll(staticProviders);
    dev.log('Loaded ${cableProviders.length} cable providers',
        name: 'CableModule');

    // Automatically select the first provider and fetch its packages
    if (cableProviders.isNotEmpty) {
      onProviderSelected(cableProviders.first);
    }

    // Add listener to clear validation when smart card changes
    smartCardController.addListener(() {
      if (smartCardController.text.isEmpty ||
          validatedCustomerName.value != null) {
        // Clear validation if smart card is changed after validation
        validatedCustomerName.value = null;
        validatedBouquetDetails.value = null;
        dev.log('Smart card number changed, clearing validation',
            name: 'CableModule');
      }
    });
  }

  @override
  void onClose() {
    smartCardController.dispose();
    super.onClose();
  }

  void onProviderSelected(CableProvider? provider) {
    if (provider != null && provider.id != selectedProvider.value?.id) {
      selectedProvider.value = provider;
      validatedCustomerName.value = null;
      validatedBouquetDetails.value = null;
      dev.log('Provider selected: ${provider.name}', name: 'CableModule');
      fetchCablePackages(provider.code);
    }
  }

  void onTabSelected(String tabName) {
    selectedTab.value = tabName;
    dev.log('Tab selected: $tabName', name: 'CableModule');
  }

  void onPackageSelected(CablePackage? package) {
    if (package != null) {
      selectedPackage.value = package;
      try {
        final amt = double.tryParse(package.amount.toString()) ?? 0.0;
        dev.log(
            'Package selected: ${package.name} - ₦${AmountUtil.formatFigure(amt)}',
            name: 'CableModule');
      } catch (e) {
        dev.log('Package selected: ${package.name} - ${package.amount}',
            name: 'CableModule');
      }
    }
  }

  Future<void> fetchCablePackages(String providerCode) async {
    try {
      isLoadingPackages.value = true;
      cablePackages.clear();
      dev.log('Fetching packages for provider: $providerCode',
          name: 'CableModule');

      final transactionUrl = box.read('transaction_service_url');
      final fullUrl = '$transactionUrl' 'tv/$providerCode';
      dev.log('Request URL: $fullUrl', name: 'CableModule');

      final result = await apiService.getrequest(fullUrl);
      result.fold(
        (failure) {
          dev.log('Failed to fetch packages',
              name: 'CableModule', error: failure.message);
          Get.snackbar("Error", "Could not load packages: ${failure.message}",
              backgroundColor: AppColors.errorBgColor,
              colorText: AppColors.textSnackbarColor);
        },
        (data) {
          final packages = (data['data'] as List)
              .map((item) => CablePackage.fromJson(item))
              .toList();
          cablePackages.assignAll(packages);
          dev.log('Loaded ${packages.length} packages', name: 'CableModule');
        },
      );
    } finally {
      isLoadingPackages.value = false;
    }
  }

  Future<void> validateSmartCard() async {
    // Prevent multiple simultaneous validations
    if (isValidating.value) {
      dev.log('Validation already in progress, skipping', name: 'CableModule');
      return;
    }

    isValidating.value = true;
    validatedCustomerName.value = null;
    validatedBouquetDetails.value = null;
    dev.log(
        'Validating smart card: ${smartCardController.text} for provider: ${selectedProvider.value?.code}',
        name: 'CableModule');

    try {
      final transactionUrl = box.read('transaction_service_url');
      if (transactionUrl == null) {
        dev.log('Transaction URL not found during validation',
            name: 'CableModule', error: 'URL missing');
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
        "service": "tv",
        "provider": selectedProvider.value!.code.toLowerCase(),
        "number": smartCardController.text,
      };

      dev.log('Validation request body: $body', name: 'CableModule');
      final result =
          await apiService.postrequest('$transactionUrl' 'validate', body);

      result.fold(
        (failure) {
          dev.log('Validation failed',
              name: 'CableModule', error: failure.message);
          Get.snackbar(
            "Validation Failed",
            failure.message,
            backgroundColor: AppColors.errorBgColor,
            colorText: AppColors.textSnackbarColor,
            duration: const Duration(seconds: 2),
          );
        },
        (data) {
          dev.log('Validation response: $data', name: 'CableModule');
          if (data['success'] == 1 && data['data'] != null) {
            validatedCustomerName.value = data['data'];

            // Extract bouquet details from the response
            if (data['details'] != null) {
              validatedBouquetDetails.value = {
                'current_bouquet': data['details']['Current_Bouquet'] ?? 'N/A',
                'current_bouquet_price':
                    data['details']['Current_Bouquet_Price']?.toString() ?? '0',
                'due_date': data['details']['Due_Date'] ?? 'N/A',
                'renewal_amount':
                    data['details']['Renewal_Amount']?.toString() ?? '0',
                'status': data['details']['Status'] ?? 'Unknown',
                'customer_type': data['details']['Customer_Type'] ?? '',
                'current_bouquet_code':
                    data['details']['Current_Bouquet_Code'] ?? 'UNKNOWN',
              };
              dev.log(
                  'Bouquet details extracted: ${validatedBouquetDetails.value}',
                  name: 'CableModule');
            }

            dev.log(
                'Smart card validated successfully: ${validatedCustomerName.value}',
                name: 'CableModule');
            Get.snackbar(
              "Validation Successful",
              "Customer: ${validatedCustomerName.value}",
              backgroundColor: AppColors.successBgColor,
              colorText: AppColors.textSnackbarColor,
              duration: const Duration(seconds: 2),
            );
          } else {
            dev.log('Validation unsuccessful',
                name: 'CableModule', error: data['message']);
            Get.snackbar(
              "Validation Failed",
              data['message'] ?? "Could not validate smart card.",
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

  Future<void> proceedToNextScreen() async {
    dev.log('Proceed to next screen initiated', name: 'CableModule');

    if (selectedProvider.value == null) {
      dev.log('Navigation failed: No provider selected',
          name: 'CableModule', error: 'Provider missing');
      Get.snackbar("Error", "Please select a cable provider.",
          backgroundColor: AppColors.errorBgColor,
          colorText: AppColors.textSnackbarColor);
      return;
    }

    if (smartCardController.text.isEmpty) {
      dev.log('Navigation failed: No smart card number',
          name: 'CableModule', error: 'Smart card missing');
      Get.snackbar("Error", "Please enter your smart card number.",
          backgroundColor: AppColors.errorBgColor,
          colorText: AppColors.textSnackbarColor);
      return;
    }

    if (formKey.currentState?.validate() ?? false) {
      // Check if smart card is already validated
      if (validatedCustomerName.value == null) {
        // Not validated yet, validate first
        dev.log('Smart card not validated, validating now',
            name: 'CableModule');
        await validateSmartCard();

        // Check if validation was successful
        if (validatedCustomerName.value == null) {
          dev.log('Navigation cancelled: Smart card validation failed',
              name: 'CableModule');
          return;
        }
      }

      // Navigate to next screen
      dev.log(
          'Navigating to payout with: Provider=${selectedProvider.value?.name}, Customer=${validatedCustomerName.value}',
          name: 'CableModule');
      Get.toNamed(Routes.GENERAL_PAYOUT, arguments: {
        'paymentType': PaymentType.cable,
        'paymentData': {
          'provider': selectedProvider.value,
          'smartCardNumber': smartCardController.text,
          'customerName': validatedCustomerName.value,
          'bouquetDetails': validatedBouquetDetails.value,
          'isRenewal': true,
        },
      });
    }
  }

  Future<void> verifyAndNavigate() async {
    dev.log('Verify and navigate initiated', name: 'CableModule');

    if (selectedProvider.value == null) {
      dev.log('Verification failed: No provider selected',
          name: 'CableModule', error: 'Provider missing');
      Get.snackbar("Error", "Please select a cable provider.",
          backgroundColor: AppColors.errorBgColor,
          colorText: AppColors.textSnackbarColor);
      return;
    }

    if (smartCardController.text.isEmpty) {
      dev.log('Verification failed: No smart card number',
          name: 'CableModule', error: 'Smart card missing');
      Get.snackbar("Error", "Please enter your smart card number.",
          backgroundColor: AppColors.errorBgColor,
          colorText: AppColors.textSnackbarColor);
      return;
    }

    if (formKey.currentState?.validate() ?? false) {
      // Validate the smart card first
      await validateSmartCard();

      // Check if validation was successful
      if (validatedCustomerName.value != null) {
        dev.log(
            'Navigating to payout with: Provider=${selectedProvider.value?.name}, Customer=${validatedCustomerName.value}',
            name: 'CableModule');
        Get.toNamed(Routes.GENERAL_PAYOUT, arguments: {
          'paymentType': PaymentType.cable,
          'paymentData': {
            'provider': selectedProvider.value,
            'smartCardNumber': smartCardController.text,
            'customerName': validatedCustomerName.value,
            'bouquetDetails': validatedBouquetDetails.value,
            'isRenewal': true,
          },
        });
      } else {
        dev.log('Navigation cancelled: Smart card validation failed',
            name: 'CableModule');
      }
    }
  }

  void pay() async {
    dev.log('Payment initiated', name: 'CableModule');

    if (selectedProvider.value == null) {
      dev.log('Payment failed: No provider selected',
          name: 'CableModule', error: 'Provider missing');
      Get.snackbar("Error", "Please select a cable provider.",
          backgroundColor: AppColors.errorBgColor,
          colorText: AppColors.textSnackbarColor);
      return;
    }

    if (selectedPackage.value == null) {
      dev.log('Payment failed: No package selected',
          name: 'CableModule', error: 'Package missing');
      Get.snackbar("Error", "Please select a package.",
          backgroundColor: AppColors.errorBgColor,
          colorText: AppColors.textSnackbarColor);
      return;
    }

    if (smartCardController.text.isEmpty) {
      dev.log('Payment failed: No smart card number',
          name: 'CableModule', error: 'Smart card missing');
      Get.snackbar("Error", "Please enter your smart card number.",
          backgroundColor: AppColors.errorBgColor,
          colorText: AppColors.textSnackbarColor);
      return;
    }

    if (validatedCustomerName.value == null) {
      dev.log('Payment failed: Smart card not validated',
          name: 'CableModule', error: 'Validation missing');
      Get.snackbar("Error", "Please validate your smart card number first.",
          backgroundColor: AppColors.errorBgColor,
          colorText: AppColors.textSnackbarColor);
      return;
    }

    if (formKey.currentState?.validate() ?? false) {
      dev.log(
          'Navigating to payout with: Provider=${selectedProvider.value?.name}, Package=${selectedPackage.value?.name}',
          name: 'CableModule');
      Get.toNamed(Routes.GENERAL_PAYOUT, arguments: {
        'paymentType': PaymentType.cable,
        'paymentData': {
          'provider': selectedProvider.value,
          'smartCardNumber': smartCardController.text,
          'package': selectedPackage.value,
          'customerName': validatedCustomerName.value,
          'isRenewal': false,
        },
      });
    }
  }
}
