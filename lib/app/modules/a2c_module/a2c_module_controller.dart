import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/material.dart';
import 'package:mcd/app/modules/a2c_module/models/bank_model.dart';
import 'package:mcd/app/styles/app_colors.dart';
import 'package:mcd/core/import/imports.dart';
import 'package:mcd/core/network/dio_api_service.dart';
import 'dart:developer' as dev;

class A2CModuleController extends GetxController {
  final apiService = DioApiService();
  final box = GetStorage();

  final formKey = GlobalKey<FormState>();
  final phoneController = TextEditingController();
  final amountController = TextEditingController();
  final accountNumberController = TextEditingController();
  final bankSearchController = TextEditingController();

  final _selectedNetwork = 'MTN'.obs;
  String get selectedNetwork => _selectedNetwork.value;
  set selectedNetwork(String value) => _selectedNetwork.value = value;

  final _selectedPaymentMethod = 'wallet'.obs;
  String get selectedPaymentMethod => _selectedPaymentMethod.value;
  set selectedPaymentMethod(String value) {
    _selectedPaymentMethod.value = value;
    if (value == 'wallet') {
      // Clear bank-related fields when switching to wallet
      selectedBank.value = null;
      accountNumberController.clear();
      _accountName.value = null;
      _isAccountVerified.value = false;
    }
  }

  final _selectedBank = Rxn<BankModel>();
  Rxn<BankModel> get selectedBank => _selectedBank;

  final _banks = <BankModel>[].obs;
  List<BankModel> get banks => _banks;

  final _bankSearchQuery = ''.obs;
  String get bankSearchQuery => _bankSearchQuery.value;
  set bankSearchQuery(String value) => _bankSearchQuery.value = value;

  List<BankModel> get filteredBanks {
    if (bankSearchQuery.isEmpty) {
      return _banks;
    }
    return _banks.where((bank) => 
      bank.name.toLowerCase().contains(bankSearchQuery.toLowerCase())
    ).toList();
  }

  final _isLoadingBanks = false.obs;
  bool get isLoadingBanks => _isLoadingBanks.value;

  final _isVerifyingAccount = false.obs;
  bool get isVerifyingAccount => _isVerifyingAccount.value;

  final _isAccountVerified = false.obs;
  bool get isAccountVerified => _isAccountVerified.value;

  final _accountName = RxnString();
  String? get accountName => _accountName.value;

  final _isConverting = false.obs;
  bool get isConverting => _isConverting.value;

  final List<String> networks = ['MTN', 'Airtel', 'Glo', '9mobile'];

  final Map<String, String> networkImages = {
    'MTN': 'assets/images/mtn.png',
    'Airtel': 'assets/images/airtel.png',
    'Glo': 'assets/images/glo.png',
    '9mobile': 'assets/images/etisalat.png',
  };

  @override
  void onInit() {
    super.onInit();
    dev.log('A2C Module initialized', name: 'A2CModule');
  }

  @override
  void onClose() {
    phoneController.dispose();
    amountController.dispose();
    accountNumberController.dispose();
    super.onClose();
  }

  // Fetch bank list
  Future<void> fetchBanks() async {
    if (_banks.isNotEmpty) {
      dev.log('Banks already loaded', name: 'A2CModule');
      return;
    }

    try {
      _isLoadingBanks.value = true;
      dev.log('Fetching banks...', name: 'A2CModule');

      final transactionUrl = box.read('transaction_service_url') ?? '';
      final url = '${transactionUrl}banklist';
      dev.log('Request URL: $url', name: 'A2CModule');

      final response = await apiService.getrequest(url);

      response.fold(
        (failure) {
          dev.log('Failed to fetch banks', name: 'A2CModule', error: failure.message);
          Get.snackbar(
            'Error',
            failure.message,
            backgroundColor: AppColors.errorBgColor,
            colorText: AppColors.textSnackbarColor,
            duration: const Duration(seconds: 2),
          );
        },
        (data) {
          dev.log('Banks fetched successfully', name: 'A2CModule');
          if (data['success'] == 1 && data['data'] != null) {
            final List<dynamic> bankList = data['data'];
            _banks.value = bankList.map((item) => BankModel.fromJson(item)).toList();
            dev.log('Loaded ${_banks.length} banks', name: 'A2CModule');
          }
        },
      );
    } catch (e) {
      dev.log('Error fetching banks', name: 'A2CModule', error: e);
      Get.snackbar(
        'Error',
        'Failed to load banks: $e',
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
        duration: const Duration(seconds: 2),
      );
    } finally {
      _isLoadingBanks.value = false;
    }
  }

  // Verify bank account
  Future<void> verifyBankAccount() async {
    if (selectedBank.value == null) {
      Get.snackbar(
        'Error',
        'Please select a bank',
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    if (accountNumberController.text.length != 10) {
      Get.snackbar(
        'Error',
        'Please enter a valid 10-digit account number',
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    try {
      _isVerifyingAccount.value = true;
      _accountName.value = null;
      _isAccountVerified.value = false;
      dev.log('Verifying account...', name: 'A2CModule');

      final transactionUrl = box.read('transaction_service_url') ?? '';
      final url = '${transactionUrl}verifyBank';
      // final url = 'https://transaction1.mcd.5starcompany.com.ng/api/v2/verifyBank';
      dev.log('Verify URL: $url', name: 'A2CModule');

      final body = {
        'accountnumber': accountNumberController.text,
        'code': selectedBank.value!.code,
      };

      dev.log('Request body: $body', name: 'A2CModule');

      final response = await apiService.postrequest(url, body);

      response.fold(
        (failure) {
          dev.log('Account verification failed', name: 'A2CModule', error: failure.message);
          Get.snackbar(
            'Error',
            failure.message,
            backgroundColor: AppColors.errorBgColor,
            colorText: AppColors.textSnackbarColor,
            duration: const Duration(seconds: 2),
          );
        },
        (data) {
          dev.log('Account verified successfully', name: 'A2CModule');
          if (data['success'] == 1) {
            _accountName.value = data['data'];
            _isAccountVerified.value = true;
            Get.snackbar(
              'Success',
              'Account verified: ${data['data']}',
              backgroundColor: AppColors.successBgColor,
              colorText: AppColors.textSnackbarColor,
              duration: const Duration(seconds: 2),
            );
          } else {
            Get.snackbar(
              'Error',
              data['message'] ?? 'Failed to verify account',
              backgroundColor: AppColors.errorBgColor,
              colorText: AppColors.textSnackbarColor,
              duration: const Duration(seconds: 2),
            );
          }
        },
      );
    } catch (e) {
      dev.log('Error verifying account', name: 'A2CModule', error: e);
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
        duration: const Duration(seconds: 2),
      );
    } finally {
      _isVerifyingAccount.value = false;
    }
  }

  // Convert airtime to cash
  Future<void> convertAirtime() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    // Validate bank details if bank payment is selected
    if (selectedPaymentMethod == 'bank') {
      if (selectedBank.value == null) {
        Get.snackbar(
          'Error',
          'Please select a bank',
          backgroundColor: AppColors.errorBgColor,
          colorText: AppColors.textSnackbarColor,
          duration: const Duration(seconds: 2),
        );
        return;
      }

      if (!isAccountVerified) {
        Get.snackbar(
          'Error',
          'Please verify your account number',
          backgroundColor: AppColors.errorBgColor,
          colorText: AppColors.textSnackbarColor,
          duration: const Duration(seconds: 2),
        );
        return;
      }
    }

    try {
      _isConverting.value = true;
      dev.log('Converting airtime...', name: 'A2CModule');

      final transactionUrl = box.read('transaction_service_url') ?? '';
      final url = '${transactionUrl}airtimeconverter';
      dev.log('Convert URL: $url', name: 'A2CModule');

      // Generate reference
      final username = box.read('biometric_username_real') ?? 'A2C';
      final userPrefix = username.length >= 2 
          ? username.substring(0, 2).toUpperCase() 
          : 'A2C';
      final ref = 'MCD2_$userPrefix${DateTime.now().microsecondsSinceEpoch}';

      final body = {
        'network': selectedNetwork,
        'number': phoneController.text,
        'amount': amountController.text,
        'receiver': selectedPaymentMethod,
        'ref': ref,
      };

      // Add bank details if bank payment is selected
      if (selectedPaymentMethod == 'bank') {
        body['bank_code'] = selectedBank.value!.code;
        body['account_number'] = accountNumberController.text;
        body['account_name'] = accountName ?? '';
      }

      dev.log('Request body: $body', name: 'A2CModule');

      final response = await apiService.postrequest(url, body);

      response.fold(
        (failure) {
          dev.log('Conversion failed', name: 'A2CModule', error: failure.message);
          Get.snackbar(
            'Error',
            failure.message,
            backgroundColor: AppColors.errorBgColor,
            colorText: AppColors.textSnackbarColor,
            duration: const Duration(seconds: 3),
          );
        },
        (data) {
          dev.log('Conversion response: $data', name: 'A2CModule');
          if (data['success'] == 1) {
            Get.snackbar(
              'Success',
              data['message'] ?? 'Airtime conversion initiated successfully',
              backgroundColor: AppColors.successBgColor,
              colorText: AppColors.textSnackbarColor,
              duration: const Duration(seconds: 5),
            );

            Get.dialog(
              Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset('assets/images/a2c-avatar-icon.png', width: 80, height: 80),
                      const SizedBox(height: 10),
                      Text(
                        data['message'] ?? 'Your airtime conversion has been initiated successfully.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.primaryGrey2,
                        ),
                      ),
                      Gap(30),
                      Row(
                        children: [
                          Text('09031945519', style: TextStyle(fontSize: 14, color: AppColors.primaryColor)),
                          Icon(Icons.copy, size: 16, color: AppColors.primaryColor),
                        ],
                      ),
                      Gap(30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          BusyButton(
                            title: 'Done',
                            borderRadius: BorderRadius.circular(32),
                            color: AppColors.primaryColor,
                            textColor: Colors.white,
                            onTap: () { Get.back(); }, 
                          ),
                          BusyButton(
                            title: 'Home', 
                            borderRadius: BorderRadius.circular(32),
                            color: AppColors.primaryColor.withOpacity(0.1),
                            textColor: AppColors.primaryColor,
                            onTap: () { 
                              Get.back(); 
                              Get.toNamed(Routes.HOME_SCREEN);
                            }, 
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            );
            
            // Clear form
            phoneController.clear();
            amountController.clear();
            accountNumberController.clear();
            _accountName.value = null;
            _isAccountVerified.value = false;
            selectedBank.value = null;
            
            // Navigate back after delay
            // Future.delayed(const Duration(seconds: 3), () {
            //   Get.back();
            // });
          } else {
            Get.snackbar(
              'Error',
              data['message'] ?? 'Failed to convert airtime',
              backgroundColor: AppColors.errorBgColor,
              colorText: AppColors.textSnackbarColor,
              duration: const Duration(seconds: 3),
            );
          }
        },
      );
    } catch (e) {
      dev.log('Error converting airtime', name: 'A2CModule', error: e);
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
        duration: const Duration(seconds: 2),
      );
    } finally {
      _isConverting.value = false;
    }
  }
}