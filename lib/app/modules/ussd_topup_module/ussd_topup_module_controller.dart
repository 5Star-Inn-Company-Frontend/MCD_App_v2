import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mcd/app/styles/app_colors.dart';

import 'package:mcd/core/network/dio_api_service.dart';
import 'package:mcd/app/modules/home_screen_module/home_screen_controller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:developer' as dev;

import '../home_screen_module/model/dashboard_model.dart';
import 'package:mcd/core/models/bank_model.dart';
import 'package:mcd/core/services/bank_service.dart';

class UssdTopupModuleController extends GetxController {
  final apiService = DioApiService();
  final box = GetStorage();

  final formKey = GlobalKey<FormState>();
  final amountController = TextEditingController();
  final bankSearchController = TextEditingController();

  final selectedBank = 'Choose bank'.obs;
  final selectedBankCode = ''.obs;
  final selectedBankUssd = ''.obs;
  final selectedBankUssdTemplate = ''.obs;
  final selectedBankBaseUssd = ''.obs;
  final generatedCode = ''.obs;
  List<BankModel> get banks => BankService.to.banks;
  bool get isLoadingBanks => BankService.to.isLoadingBanks.value;
  final isGeneratingCode = false.obs;
  final _bankSearchQuery = ''.obs;

  // virtual account info
  final hasVirtualAccount = false.obs;
  final virtualAccountNumber = ''.obs;

  String get bankSearchQuery => _bankSearchQuery.value;
  set bankSearchQuery(String value) => _bankSearchQuery.value = value;

  List<BankModel> get filteredBanks {
    if (bankSearchQuery.isEmpty) {
      return BankService.to.banks;
    }
    return BankService.to.banks
        .where((bank) => bank.name
            .toLowerCase()
            .contains(bankSearchQuery.toLowerCase()))
        .toList();
  }

  @override
  void onInit() {
    super.onInit();
    dev.log('UssdTopupModuleController initialized', name: 'UssdTopup');
    _loadVirtualAccount();
    fetchBanks();
  }

  @override
  void onClose() {
    amountController.dispose();
    bankSearchController.dispose();
    super.onClose();
  }

  void _loadVirtualAccount() {
    try {
      // Try to load from cached dashboard data
      final cachedDashboard = box.read('cached_dashboard');
      if (cachedDashboard != null) {
        final dashboard = DashboardModel.fromJson(cachedDashboard);
        if (dashboard.virtualAccounts.hasPrimary) {
          hasVirtualAccount.value = true;
          virtualAccountNumber.value =
              dashboard.virtualAccounts.primaryAccountNumber;
          dev.log('Virtual account loaded from cache: ${virtualAccountNumber.value}',
              name: 'UssdTopup');
          return;
        }
      }
      
      hasVirtualAccount.value = false;
      dev.log('No virtual account found in cache', name: 'UssdTopup');
    } catch (e) {
      dev.log('Error loading virtual account from cache', name: 'UssdTopup', error: e);
      hasVirtualAccount.value = false;
    }
  }

  Future<void> fetchBanks() async {
    await BankService.to.fetchBanks();
  }

  void selectBank(String bankName, String bankCode, String? ussdTemplate,
      String? baseUssd) {
    selectedBank.value = bankName;
    selectedBankCode.value = bankCode;
    selectedBankUssdTemplate.value = ussdTemplate ?? '';
    selectedBankBaseUssd.value = baseUssd ?? '';
    dev.log('Bank selected: $bankName - $bankCode - Template: $ussdTemplate',
        name: 'UssdTopup');
    Get.back();
  }

  Future<void> generateCode() async {
    if (!formKey.currentState!.validate()) return;

    if (selectedBankCode.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select a bank',
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
      );
      return;
    }

    if (selectedBankUssdTemplate.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Selected bank does not support USSD top-up',
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
      );
      return;
    }

    if (!hasVirtualAccount.value || virtualAccountNumber.value.isEmpty) {
      Get.snackbar(
        'Error',
        'No virtual account found. Please complete KYC.',
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
      );
      return;
    }

    try {
      isGeneratingCode.value = true;
      dev.log(
          'Generating USSD code using template: ${selectedBankUssdTemplate.value}',
          name: 'UssdTopup');

      await Future.delayed(const Duration(milliseconds: 500));

      String code = selectedBankUssdTemplate.value;

      // replace placeholders with amount and virtual account number
      code = code.replaceAllMapped(
        RegExp(r'Amount', caseSensitive: false),
        (match) => amountController.text,
      );
      code = code.replaceAllMapped(
        RegExp(r'AccountNumber', caseSensitive: false),
        (match) => virtualAccountNumber.value,
      );

      generatedCode.value = code;

      dev.log(
          'USSD code generated: $code (account: ${virtualAccountNumber.value})',
          name: 'UssdTopup');

      Get.snackbar(
        'Success',
        'USSD code generated successfully',
        backgroundColor: AppColors.successBgColor,
        colorText: AppColors.textSnackbarColor,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      dev.log('Error generating code', name: 'UssdTopup', error: e);
      Get.snackbar(
        'Error',
        'Failed to generate code',
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
      );
    } finally {
      isGeneratingCode.value = false;
    }
  }

  Future<void> copyCode() async {
    if (generatedCode.value.isEmpty) return;

    await Clipboard.setData(ClipboardData(text: generatedCode.value));

    Get.snackbar(
      "Copied",
      "USSD code copied to clipboard",
      backgroundColor: AppColors.primaryColor.withOpacity(0.1),
      colorText: AppColors.primaryColor,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(10),
      icon: const Icon(Icons.check_circle, color: AppColors.primaryColor),
    );
  }

  Future<void> dialCode() async {
    if (generatedCode.value.isEmpty) return;

    try {
      final telUri = Uri(scheme: 'tel', path: generatedCode.value);

      dev.log('Attempting to dial: ${telUri.toString()}', name: 'UssdTopup');

      if (await canLaunchUrl(telUri)) {
        await launchUrl(telUri);
      } else {
        Get.snackbar(
          'Error',
          'Unable to open phone dialer',
          backgroundColor: AppColors.errorBgColor,
          colorText: AppColors.textSnackbarColor,
        );
      }
    } catch (e) {
      dev.log('Error launching dialer', name: 'UssdTopup', error: e);
      Get.snackbar(
        'Error',
        'Failed to open dialer',
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
      );
    }
  }

  void clearGeneratedCode() {
    generatedCode.value = '';
  }

  void resetForm() {
    amountController.clear();
    selectedBank.value = 'Choose bank';
    selectedBankCode.value = '';
    selectedBankUssd.value = '';
    selectedBankUssdTemplate.value = '';
    selectedBankBaseUssd.value = '';
    generatedCode.value = '';
  }
}
