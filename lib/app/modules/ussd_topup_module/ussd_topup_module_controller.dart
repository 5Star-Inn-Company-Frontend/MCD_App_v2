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
  final banks = <Map<String, dynamic>>[].obs;
  final isLoadingBanks = false.obs;
  final isGeneratingCode = false.obs;
  final _bankSearchQuery = ''.obs;

  // virtual account info
  final hasVirtualAccount = false.obs;
  final virtualAccountNumber = ''.obs;

  String get bankSearchQuery => _bankSearchQuery.value;
  set bankSearchQuery(String value) => _bankSearchQuery.value = value;

  List<Map<String, dynamic>> get filteredBanks {
    if (bankSearchQuery.isEmpty) {
      return banks;
    }
    return banks
        .where((bank) => (bank['name'] as String)
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
      final homeController = Get.find<HomeScreenController>();
      final dashboard = homeController.dashboardData;

      if (dashboard != null && dashboard.virtualAccounts.hasPrimary) {
        hasVirtualAccount.value = true;
        virtualAccountNumber.value =
            dashboard.virtualAccounts.primaryAccountNumber;
        dev.log('Virtual account loaded: ${virtualAccountNumber.value}',
            name: 'UssdTopup');
      } else {
        hasVirtualAccount.value = false;
        dev.log('No virtual account found', name: 'UssdTopup');
      }
    } catch (e) {
      dev.log('Error loading virtual account', name: 'UssdTopup', error: e);
      hasVirtualAccount.value = false;
    }
  }

  Future<void> fetchBanks() async {
    try {
      isLoadingBanks.value = true;

      // try loading from cache first
      final cachedData = box.read('cached_banks');
      if (cachedData != null) {
        try {
          final List<dynamic> cached = jsonDecode(cachedData);
          banks.clear();
          for (var bank in cached) {
            banks.add({
              'name': bank['name'] ?? '',
              'code': bank['code'] ?? '',
              'ussdTemplate': bank['ussdTemplate'],
              'baseUssdCode': bank['baseUssdCode'],
            });
          }
          dev.log('Banks loaded from cache: ${banks.length}',
              name: 'UssdTopup');
          return;
        } catch (e) {
          dev.log('Cache parse error, fetching from API', name: 'UssdTopup');
        }
      }

      // fallback to API
      final transactionUrl = box.read('transaction_service_url');
      if (transactionUrl == null) {
        dev.log('Transaction URL not found', name: 'UssdTopup');
        Get.snackbar(
          'Error',
          'Service configuration error. Please login again.',
          backgroundColor: AppColors.errorBgColor,
          colorText: AppColors.textSnackbarColor,
        );
        return;
      }

      final result = await apiService.getrequest('${transactionUrl}banklist');

      result.fold(
        (failure) {
          dev.log('Failed to fetch banks',
              name: 'UssdTopup', error: failure.message);
          Get.snackbar(
            'Error',
            'Failed to load banks: ${failure.message}',
            backgroundColor: AppColors.errorBgColor,
            colorText: AppColors.textSnackbarColor,
          );
        },
        (data) {
          // handle both response formats
          List<dynamic>? bankList;
          if (data['success'] == 1 && data['data'] != null) {
            bankList = data['data'];
          } else if (data['requestSuccessful'] == true &&
              data['responseBody'] != null) {
            bankList = data['responseBody'];
          }

          if (bankList != null) {
            banks.clear();
            for (var bank in bankList) {
              banks.add({
                'name': bank['name'] ?? '',
                'code': bank['code'] ?? '',
                'ussdTemplate': bank['ussdTemplate'],
                'baseUssdCode': bank['baseUssdCode'],
              });
            }
            dev.log('Banks loaded from API: ${banks.length}',
                name: 'UssdTopup');

            // cache for next time
            final encoded = jsonEncode(banks.toList());
            box.write('cached_banks', encoded);
            box.write('cached_banks_ts', DateTime.now().toIso8601String());
          }
        },
      );
    } catch (e) {
      dev.log('Error fetching banks', name: 'UssdTopup', error: e);
      Get.snackbar(
        'Error',
        'An error occurred while loading banks',
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
      );
    } finally {
      isLoadingBanks.value = false;
    }
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
