import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VirtualCardLimitsController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final limitController = TextEditingController();
  final isLimitEnabled = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    // Load saved limit if exists
    limitController.text = '12,00.00';
  }
  
  @override
  void onClose() {
    limitController.dispose();
    super.onClose();
  }
  
  void toggleLimit(bool value) {
    isLimitEnabled.value = value;
    if (!value) {
      limitController.text = '0.00';
    }
  }
  
  void setLimit() {
    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }
    
    Get.back();
    Get.snackbar(
      'Success',
      'Transaction limit updated successfully',
      backgroundColor: const Color(0xFF4CAF50).withOpacity(0.1),
      colorText: const Color(0xFF4CAF50),
    );
  }
}
