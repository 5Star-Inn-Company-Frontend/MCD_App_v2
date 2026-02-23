import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mcd/app/modules/general_payout/general_payout_controller.dart';
import 'package:mcd/app/routes/app_pages.dart';
import 'dart:developer' as dev;

import '../../../core/network/dio_api_service.dart';

class NinValidationModuleController extends GetxController {
  final apiService = DioApiService();
  final box = GetStorage();

  final formKey = GlobalKey<FormState>();
  final ninController = TextEditingController();

  final isValidating = false.obs;

  @override
  void onInit() {
    super.onInit();
    dev.log('NinValidationModuleController initialized', name: 'NinValidation');
  }

  @override
  void onClose() {
    ninController.dispose();
    super.onClose();
  }

  void proceedToPayout() {
    if (formKey.currentState?.validate() ?? false) {
      dev.log('Proceeding to NIN validation payout', name: 'NinValidation');
      
      Get.toNamed(
        Routes.GENERAL_PAYOUT,
        arguments: {
          'paymentType': PaymentType.ninValidation,
          'paymentData': {
            'ninNumber': ninController.text,
            'amount': '100',
          },
        },
      );
    }
  }
}