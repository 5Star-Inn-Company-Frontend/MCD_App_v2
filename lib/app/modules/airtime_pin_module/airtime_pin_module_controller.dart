import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mcd/app/modules/general_payout/general_payout_controller.dart';
import 'package:mcd/app/routes/app_pages.dart';
import 'package:mcd/app/styles/app_colors.dart';
import 'package:mcd/core/network/dio_api_service.dart';
import 'dart:developer' as dev;

class AirtimePinModuleController extends GetxController {
  final apiService = DioApiService();
  final box = GetStorage();
  
  final formKey = GlobalKey<FormState>();
  final amountController = TextEditingController();
  final selectedAmount = ''.obs;
  final quantityController = TextEditingController();
  
  final selectedNetwork = Rx<String?>(null);
  final isProcessing = false.obs;
  final selectedDesign = 1.obs; // Default to design 1
  
  // Available designs
  final designs = [
    {'id': 1, 'name': 'Design 1', 'image': 'assets/images/epin/design-1.png'},
    {'id': 2, 'name': 'Design 2', 'image': 'assets/images/epin/design-2.png'},
    {'id': 3, 'name': 'Design 3', 'image': 'assets/images/epin/design-3.png'},
    {'id': 4, 'name': 'Design 4', 'image': 'assets/images/epin/design-4.png'},
    {'id': 5, 'name': 'Design 5', 'image': 'assets/images/epin/design-5.png'},
    {'id': 6, 'name': 'Design 6', 'image': 'assets/images/epin/design-6.png'},
  ];
  
  // Network providers
  final networks = [
    {'name': 'MTN', 'image': 'assets/images/mtn.png', 'code': 'MTN'},
    {'name': 'Airtel', 'image': 'assets/images/airtel.png', 'code': 'AIRTEL'},
    {'name': '9mobile', 'image': 'assets/images/etisalat.png', 'code': '9MOBILE'},
    {'name': 'Glo', 'image': 'assets/images/glo.png', 'code': 'GLO'},
  ];

  @override
  void onInit() {
    super.onInit();
    dev.log('AirtimePinModuleController initialized', name: 'AirtimePin');
    // Set default values
    quantityController.text = '1';
  }

  @override
  void onClose() {
    amountController.dispose();
    quantityController.dispose();
    super.onClose();
  }

  void onAmountSelected(String amount) {
    amountController.text = amount;
    selectedAmount.value = amount;
    dev.log('Amount selected: ₦$amount', name: 'AirtimePinModule');
  }

  void selectNetwork(String network) {
    selectedNetwork.value = network;
    dev.log('Network selected: $network', name: 'AirtimePin');
  }

  void selectDesign(int designId) {
    selectedDesign.value = designId;
    dev.log('Design selected: $designId', name: 'AirtimePin');
  }

  Map<String, dynamic> get currentDesign {
    return designs.firstWhere(
      (design) => design['id'] == selectedDesign.value,
      orElse: () => designs[0],
    );
  }

  String get username {
    return box.read('biometric_username_real') ?? 'User';
  }

  void incrementQuantity() {
    int current = int.tryParse(quantityController.text) ?? 1;
    if (current < 10) {
      quantityController.text = (current + 1).toString();
    }
  }

  void decrementQuantity() {
    int current = int.tryParse(quantityController.text) ?? 1;
    if (current > 1) {
      quantityController.text = (current - 1).toString();
    }
  }

  Future<void> processPayment() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (selectedNetwork.value == null) {
      Get.snackbar(
        "Validation Error",
        "Please select a network provider",
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
      );
      return;
    }

    if (selectedAmount.value.isEmpty) {
      Get.snackbar(
        "Validation Error",
        "Please select an amount",
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
      );
      return;
    }

    if (selectedDesign.value == 0) {
      Get.snackbar(
        "Validation Error",
        "Please select a design type",
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
      );
      return;
    }

    final amount = double.tryParse(amountController.text);
    if (amount == null || amount < 100 || amount > 50000) {
      Get.snackbar(
        "Validation Error",
        "Amount must be between ₦100 and ₦50,000",
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
      );
      return;
    }

    final quantity = int.tryParse(quantityController.text);
    if (quantity == null || quantity < 1 || quantity > 10) {
      Get.snackbar(
        "Validation Error",
        "Quantity must be between 1 and 10",
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
      );
      return;
    }

    // Navigate to payout page
    final selectedNetworkData = networks.firstWhere(
      (network) => network['code'] == selectedNetwork.value,
      orElse: () => networks[0],
    );

    Get.toNamed(
      Routes.GENERAL_PAYOUT,
      arguments: {
        'paymentType': PaymentType.airtimePin,
        'paymentData': {
          'networkName': selectedNetworkData['name'] ?? '',
          'networkCode': selectedNetworkData['code'] ?? '',
          'networkImage': selectedNetworkData['image'] ?? '',
          'amount': amountController.text,
          'quantity': quantityController.text,
          'designId': selectedDesign.value,
          'designName': currentDesign['name'] ?? '',
          'designImage': currentDesign['image'] ?? '',
        },
      },
    );
  }
}
