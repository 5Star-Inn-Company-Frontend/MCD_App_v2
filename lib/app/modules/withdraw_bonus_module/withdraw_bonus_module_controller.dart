import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mcd/app/styles/app_colors.dart';
import 'package:mcd/core/constants/app_strings.dart';
import 'package:mcd/core/network/api_constants.dart';
import 'package:mcd/core/network/dio_api_service.dart';
import 'dart:developer' as dev;
import 'package:mcd/core/utils/amount_formatter.dart';

class WithdrawBonusModuleController extends GetxController {
  final apiService = DioApiService();
  final box = GetStorage();

  final formKey = GlobalKey<FormState>();
  final amountController = TextEditingController();
  final selectedAmount = ''.obs;
  final accountNumberController = TextEditingController();
  final accountNameController = TextEditingController();
  final bankSearchController = TextEditingController();

  final selectedWallet = 'Mega Bonus'.obs;
  final selectedWalletType = 'mega_bonus'.obs; // 'mega_bonus' or 'commission'
  final selectedBank = 'Choose bank'.obs;
  final selectedBankCode = ''.obs;
  final megaBonusBalance = 0.0.obs;
  final commissionBalance = 0.0.obs;
  final isWithdrawing = false.obs;
  final banks = <Map<String, String>>[].obs;
  final isLoadingBanks = false.obs;
  final isValidatingAccount = false.obs;
  final _bankSearchQuery = ''.obs;
  String get bankSearchQuery => _bankSearchQuery.value;
  set bankSearchQuery(String value) => _bankSearchQuery.value = value;

  List<Map<String, String>> get filteredBanks {
    if (bankSearchQuery.isEmpty) {
      return banks;
    }
    return banks
        .where((bank) =>
            bank['name']!.toLowerCase().contains(bankSearchQuery.toLowerCase()))
        .toList();
  }

  final quickAmounts = ['500', '1000', '2500', '5000', '10000', '25000'];

  @override
  void onInit() {
    super.onInit();
    dev.log('WithdrawBonusModuleController initialized', name: 'WithdrawBonus');
    fetchBanks();
    fetchMegaBonusBalance();
  }

  @override
  void onClose() {
    amountController.dispose();
    accountNumberController.dispose();
    accountNameController.dispose();
    bankSearchController.dispose();
    super.onClose();
  }

  void setQuickAmount(String amount) {
    amountController.text = amount;
    selectedAmount.value = amount;
    try {
      final amt = double.tryParse(amount.replaceAll(',', '')) ?? 0.0;
      dev.log('Quick amount selected: ₦${AmountUtil.formatFigure(amt)}',
          name: 'WithdrawBonus');
    } catch (e) {
      dev.log('Quick amount selected: ₦$amount', name: 'WithdrawBonus');
    }
  }

  final isLoadingBalance = false.obs;

  Future<void> fetchMegaBonusBalance() async {
    try {
      isLoadingBalance.value = true;
      dev.log('Fetching balances from dashboard', name: 'WithdrawBonus');

      final result =
          await apiService.getrequest('${ApiConstants.authUrlV2}/dashboard');

      result.fold(
        (failure) {
          dev.log('Failed to fetch balances',
              name: 'WithdrawBonus', error: failure.message);
          Get.snackbar(
            'Error',
            'Failed to load balances',
            backgroundColor: AppColors.errorBgColor,
            colorText: AppColors.textSnackbarColor,
          );
        },
        (data) {
          if (data['data']?['balance'] != null) {
            final balance = data['data']['balance'];
            megaBonusBalance.value =
                double.tryParse(balance['bonus']?.toString() ?? '0') ?? 0.0;
            commissionBalance.value =
                double.tryParse(balance['commission']?.toString() ?? '0') ??
                    0.0;
            dev.log(
                'Balances loaded - Mega Bonus: ₦${AmountUtil.formatFigure(megaBonusBalance.value)}, Commission: ₦${AmountUtil.formatFigure(commissionBalance.value)}',
                name: 'WithdrawBonus');
          }
        },
      );
    } catch (e) {
      dev.log('Error fetching balances', name: 'WithdrawBonus', error: e);
    } finally {
      isLoadingBalance.value = false;
    }
  }

  void selectWallet(String wallet, String type) {
    selectedWallet.value = wallet;
    selectedWalletType.value = type;
    dev.log('Wallet selected: $wallet ($type)', name: 'WithdrawBonus');
    Get.back(); // Close the dropdown dialog
  }

  String get selectedWalletBalance {
    if (selectedWalletType.value == 'mega_bonus') {
      return AmountUtil.formatFigure(megaBonusBalance.value);
    } else {
      return AmountUtil.formatFigure(commissionBalance.value);
    }
  }

  Future<void> fetchBanks() async {
    try {
      isLoadingBanks.value = true;
      dev.log('Fetching banks list', name: 'WithdrawBonus');

      final transactionUrl = box.read('transaction_service_url');
      if (transactionUrl == null) {
        dev.log('Transaction URL not found',
            name: 'WithdrawBonus', error: 'URL missing');
        return;
      }

      final result = await apiService.getrequest('${transactionUrl}banklist');

      result.fold(
        (failure) {
          dev.log('Failed to fetch banks',
              name: 'WithdrawBonus', error: failure.message);
          Get.snackbar(
            'Error',
            'Failed to load banks: ${failure.message}',
            backgroundColor: AppColors.errorBgColor,
            colorText: AppColors.textSnackbarColor,
          );
        },
        (data) {
          if (data['success'] == 1 && data['data'] != null) {
            banks.clear();
            for (var bank in data['data']) {
              banks.add({
                'name': bank['name'] ?? '',
                'code': bank['code'] ?? '',
              });
            }
            dev.log('Banks loaded: ${banks.length} banks',
                name: 'WithdrawBonus');
          }
        },
      );
    } catch (e) {
      dev.log('Error fetching banks', name: 'WithdrawBonus', error: e);
    } finally {
      isLoadingBanks.value = false;
    }
  }

  Future<void> validateAccountNumber() async {
    if (accountNumberController.text.length != 10) {
      Get.snackbar(
        'Error',
        'Please enter a valid 10-digit account number',
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
      );
      return;
    }

    if (selectedBankCode.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select a bank first',
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
      );
      return;
    }

    try {
      isValidatingAccount.value = true;
      accountNameController.clear();
      dev.log(
          'Validating account: ${accountNumberController.text} at bank: $selectedBankCode',
          name: 'WithdrawBonus');

      final transactionUrl = box.read('transaction_service_url');
      if (transactionUrl == null) {
        dev.log('Transaction URL not found',
            name: 'WithdrawBonus', error: 'URL missing');
        return;
      }

      final body = {
        'accountnumber': accountNumberController.text,
        'code': selectedBankCode.value,
      };

      final result =
          await apiService.postrequest('${transactionUrl}verifyBank', body);

      result.fold(
        (failure) {
          dev.log('Account validation failed',
              name: 'WithdrawBonus', error: failure.message);
          Get.snackbar(
            'Error',
            failure.message,
            backgroundColor: AppColors.errorBgColor,
            colorText: AppColors.textSnackbarColor,
          );
          accountNameController.text = '';
        },
        (data) {
          if (data['success'] == 1) {
            final accountName = data['data'] ?? 'Unknown';
            accountNameController.text = accountName;
            dev.log('Account validated: $accountName', name: 'WithdrawBonus');
            Get.snackbar(
              'Success',
              'Account verified: $accountName',
              backgroundColor: AppColors.successBgColor,
              colorText: AppColors.textSnackbarColor,
            );
          } else {
            accountNameController.text = '';
            Get.snackbar(
              'Error',
              data['message'] ?? 'Could not validate account',
              backgroundColor: AppColors.errorBgColor,
              colorText: AppColors.textSnackbarColor,
            );
          }
        },
      );
    } catch (e) {
      dev.log('Error validating account', name: 'WithdrawBonus', error: e);
      Get.snackbar(
        'Error',
        'An error occurred while validating account',
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
      );
    } finally {
      isValidatingAccount.value = false;
    }
  }

  Future<void> confirmAndWithdraw() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (accountNameController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please validate your account number first',
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
      );
      return;
    }

    final amount = double.tryParse(amountController.text.replaceAll(',', ''));
    if (amount == null || amount <= 0) {
      Get.snackbar(
        'Error',
        'Please enter a valid amount',
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
      );
      return;
    }

    // Check balance based on selected wallet
    final currentBalance = selectedWalletType.value == 'mega_bonus'
        ? megaBonusBalance.value
        : commissionBalance.value;

    if (amount > currentBalance) {
      Get.snackbar(
        'Error',
        'Insufficient balance',
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
      );
      return;
    }

    final ref = AppStrings.ref;

    try {
      isWithdrawing.value = true;
      try {
        dev.log(
            'Initiating withdrawal: ₦${AmountUtil.formatFigure(amount)} from ${selectedWallet.value} to ${accountNumberController.text}',
            name: 'WithdrawBonus');
      } catch (e) {
        dev.log(
            'Initiating withdrawal: ₦$amount from ${selectedWallet.value} to ${accountNumberController.text}',
            name: 'WithdrawBonus');
      }

      final transactionUrl = box.read('transaction_service_url');
      if (transactionUrl == null) {
        dev.log('Transaction URL not found',
            name: 'WithdrawBonus', error: 'URL missing');
        return;
      }

      final body = {
        'amount': amount.toString(),
        'wallet': selectedWallet.value, // "Mega Bonus" or "Commission"
        'ref': ref,
        'account_number': accountNumberController.text,
        'bank': selectedBank.value,
        'bank_code': selectedBankCode.value,
      };

      dev.log('Withdrawal request body: $body', name: 'WithdrawBonus');
      final result =
          await apiService.postrequest('${transactionUrl}withdrawfund', body);

      result.fold(
        (failure) {
          dev.log('Withdrawal failed',
              name: 'WithdrawBonus', error: failure.message);
          Get.snackbar(
            'Withdrawal Failed',
            failure.message,
            backgroundColor: AppColors.errorBgColor,
            colorText: AppColors.textSnackbarColor,
          );
        },
        (data) {
          dev.log('Withdrawal response: $data', name: 'WithdrawBonus');
          if (data['success'] == 1) {
            dev.log('Withdrawal successful', name: 'WithdrawBonus');
            Get.snackbar(
              'Success',
              data['message'] ?? 'Withdrawal request submitted successfully!',
              backgroundColor: AppColors.successBgColor,
              colorText: AppColors.textSnackbarColor,
            );

            // Clear form
            amountController.clear();
            accountNumberController.clear();
            accountNameController.clear();
            selectedBank.value = 'Choose bank';
            selectedBankCode.value = '';

            // Refresh balance
            fetchMegaBonusBalance();

            // Go back after 2 seconds
            Future.delayed(const Duration(seconds: 2), () {
              Get.back();
            });
          } else {
            dev.log('Withdrawal unsuccessful',
                name: 'WithdrawBonus', error: data['message']);
            Get.snackbar(
              'Withdrawal Failed',
              data['message'] ?? 'An unknown error occurred.',
              backgroundColor: AppColors.errorBgColor,
              colorText: AppColors.textSnackbarColor,
            );
          }
        },
      );
    } catch (e) {
      dev.log('Withdrawal error', name: 'WithdrawBonus', error: e);
      Get.snackbar(
        'Error',
        'An unexpected error occurred',
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
      );
    } finally {
      isWithdrawing.value = false;
    }
  }
}
