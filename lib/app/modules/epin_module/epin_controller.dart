import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
// import 'package:mcd/app/modules/general_payout/general_payout_controller.dart';
// import 'package:mcd/app/routes/app_pages.dart';
import 'package:mcd/app/styles/app_colors.dart';
import 'package:mcd/core/network/dio_api_service.dart';
import 'dart:developer' as dev;

class EpinController extends GetxController {
  final apiService = DioApiService();
  final box = GetStorage();

  final _selectedNetwork = ''.obs;
  String get selectedNetwork => _selectedNetwork.value;

  final _selectedAmount = ''.obs;
  String get selectedAmount => _selectedAmount.value;

  final TextEditingController recipientController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  
  final formKey = GlobalKey<FormState>();

  final networks = [
    {'code': 'MTN', 'name': 'MTN', 'image': 'assets/images/mtn.png'},
    {'code': 'AIRTEL', 'name': 'Airtel', 'image': 'assets/images/airtel.png'},
    {'code': '9MOBILE', 'name': '9mobile', 'image': 'assets/images/9mobile.png'},
    {'code': 'GLO', 'name': 'Glo', 'image': 'assets/images/glo.png'},
  ];

  final amounts = ['100', '200', '500', '1000', '1500', '2000', '5000', '10000'];

  void selectNetwork(String code) {
    _selectedNetwork.value = code;
  }

  void selectAmount(String amount) {
    _selectedAmount.value = amount;
  }

  Future<void> proceedToPurchase() async {
    if (formKey.currentState!.validate()) {
      if (_selectedNetwork.value.isEmpty) {
        Get.snackbar("Error", "Please select a network provider.", 
          backgroundColor: AppColors.errorBgColor, colorText: AppColors.textSnackbarColor);
        return;
      }
      if (_selectedAmount.value.isEmpty) {
        Get.snackbar("Error", "Please select an amount.", 
          backgroundColor: AppColors.errorBgColor, colorText: AppColors.textSnackbarColor);
        return;
      }

      // final selectedNetworkData = networks.firstWhere(
      //   (network) => network['code'] == _selectedNetwork.value,
      //   orElse: () => networks[0],
      // );

      dev.log('Navigating to E-pin payout screen', name: 'EpinModule');
      // Get.toNamed(
      //   Routes.GENERAL_PAYOUT,
      //   arguments: {
      //     'paymentType': PaymentType.epin,
      //     'paymentData': {
      //       'networkName': selectedNetworkData['name'] ?? '',
      //       'networkCode': selectedNetworkData['code'] ?? '',
      //       'networkImage': selectedNetworkData['image'] ?? '',
      //       'designType': 'Standard',
      //       'quantity': quantityController.text.isNotEmpty ? quantityController.text : '1',
      //       'amount': _selectedAmount.value,
      //       'recipient': recipientController.text,
      //     },
      //   },
      // );
    }
  }

  @override
  void onClose() {
    recipientController.dispose();
    quantityController.dispose();
    super.onClose();
  }
}
