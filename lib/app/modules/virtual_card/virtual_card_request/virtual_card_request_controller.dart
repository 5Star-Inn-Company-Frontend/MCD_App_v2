import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mcd/app/styles/app_colors.dart';
import 'package:mcd/core/network/dio_api_service.dart';
import 'package:mcd/app/modules/virtual_card/models/created_card_model.dart';
import 'package:mcd/app/routes/app_pages.dart';
import 'dart:developer' as dev;

class VirtualCardRequestController extends GetxController {
  final apiService = DioApiService();
  final box = GetStorage();

  final amountController = TextEditingController();

  final selectedCurrency1 = ''.obs;
  final selectedCardType = ''.obs;
  final isCreating = false.obs;
  final isLoadingFees = false.obs;
  final createFee = 0.0.obs;
  final rate = 0.0.obs;
  final convertedAmount = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCardFees();
  }

  @override
  void onClose() {
    amountController.dispose();
    super.onClose();
  }

  // Calculate the converted amount based on the rate
  void calculateConversion() {
    final amount = double.tryParse(amountController.text) ?? 0;
    if (amount > 0 && rate.value > 0) {
      convertedAmount.value = amount * rate.value;
    } else {
      convertedAmount.value = 0;
    }
  }

  // Fetch card creation fees from API
  Future<void> fetchCardFees() async {
    try {
      isLoadingFees.value = true;
      dev.log('Fetching card creation fees');

      final transactionUrl = box.read('transaction_service_url');
      if (transactionUrl == null) {
        dev.log('Error: Transaction URL not found');
        return;
      }

      final result = await apiService.getrequest(
        '${transactionUrl}virtual-card/list',
      );

      result.fold(
        (failure) {
          dev.log('Error fetching fees: ${failure.message}');
        },
        (data) {
          if (data['success'] == 1) {
            createFee.value = (data['create_fee'] ?? 2).toDouble();
            rate.value = (data['rate'] ?? 0).toDouble();
            dev.log('Fetched fees - Create Fee: \$${createFee.value}, Rate: ${rate.value}');
          }
        },
      );
    } catch (e) {
      dev.log('Error fetching fees: $e');
    } finally {
      isLoadingFees.value = false;
    }
  }

  // validates inputs before creating card
  bool validateInputs() {
    if (selectedCurrency1.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select currency',
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
      );
      return false;
    }
    if (selectedCardType.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select card type',
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
      );
      return false;
    }
    if (amountController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter amount',
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
      );
      return false;
    }
    return true;
  }

  // creates virtual card and navigates to application page with card data
  Future<void> createVirtualCard() async {
    if (!validateInputs()) return;

    try {
      isCreating.value = true;
      dev.log('Creating virtual card');

      final transactionUrl = box.read('transaction_service_url');
      if (transactionUrl == null) {
        dev.log('Error: Transaction URL not found');
        Get.snackbar(
          'Error',
          'Service unavailable',
          backgroundColor: AppColors.errorBgColor,
          colorText: AppColors.textSnackbarColor,
        );
        return;
      }

      // map display values to api values
      String currency = selectedCurrency1.value.toUpperCase();
      if (currency == 'DOLLAR') currency = 'USD';
      if (currency == 'NAIRA') currency = 'NGN';
      if (currency == 'POUND') currency = 'GBP';
      if (currency == 'EURO') currency = 'EUR';

      String brand = selectedCardType.value.toLowerCase();
      if (brand == 'master card') brand = 'mastercard';
      if (brand == 'visa card') brand = 'visa';

      final body = {
        'currency': currency,
        'amount': amountController.text,
        'brand': brand,
      };

      dev.log('Creating virtual card with body: $body');

      final result = await apiService.postrequest(
        '${transactionUrl}virtual-card/create',
        body,
      );

      result.fold(
        (failure) {
          dev.log('Error: ${failure.message}');
          Get.snackbar(
            'Error',
            failure.message,
            backgroundColor: AppColors.errorBgColor,
            colorText: AppColors.textSnackbarColor,
          );
        },
        (data) {
          if (data['success'] == 1) {
            dev.log('Success: ${data['message']}');

            // parse card data from response
            final cardData = CreatedCardModel.fromJson(data['data']);

            // navigate to application page with card details
            Get.offNamed(
              Routes.VIRTUAL_CARD_APPLICATION,
              arguments: {'cardData': cardData},
            );
          } else {
            dev.log('Error: ${data['message']}');
            Get.snackbar(
              'Error',
              data['message']?.toString() ?? 'Failed to create card',
              backgroundColor: AppColors.errorBgColor,
              colorText: AppColors.textSnackbarColor,
            );
          }
        },
      );
    } catch (e) {
      dev.log('Error: $e');
      Get.snackbar(
        'Error',
        'An error occurred',
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
      );
    } finally {
      isCreating.value = false;
    }
  }
}
