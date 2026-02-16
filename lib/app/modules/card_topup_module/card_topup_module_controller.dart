import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mcd/app/routes/app_pages.dart';
import 'package:mcd/app/styles/app_colors.dart';
import 'package:mcd/core/constants/fonts.dart';
import 'package:mcd/core/network/dio_api_service.dart';
import 'package:flutter_paystack_payment_plus/flutter_paystack_payment_plus.dart';
import 'dart:developer' as dev;

class CardTopupModuleController extends GetxController {
  final apiService = DioApiService();
  final box = GetStorage();

  // paystack plugin
  final plugin = PaystackPayment();

  // for amount input screen
  final enteredAmount = ''.obs;
  final isProcessing = false.obs;

  // for card details screen
  final formKey = GlobalKey<FormState>();
  final cardNumberController = TextEditingController();
  final cardNameController = TextEditingController();
  final expiryMonthController = TextEditingController();
  final expiryYearController = TextEditingController();
  final cvvController = TextEditingController();
  final amountController = TextEditingController();

  final isLoading = false.obs;
  final cardType = ''.obs;

  // stored reference and amount for payment flow
  String _currentReference = '';
  int _currentAmount = 0;

  String get paystackPublicKey =>
      box.read('paystack_public_key') ??
      'pk_live_bf9ad0c818ede7986e1f93198a1eb02eef57c7d9';

  @override
  void onInit() {
    super.onInit();
    dev.log('CardTopupModuleController initialized', name: 'CardTopup');

    // initialize paystack plugin
    plugin.initialize(publicKey: paystackPublicKey);

    // add listener for card type detection
    cardNumberController.addListener(_detectCardType);
  }

  @override
  void onClose() {
    cardNumberController.dispose();
    cardNameController.dispose();
    expiryMonthController.dispose();
    expiryYearController.dispose();
    cvvController.dispose();
    amountController.dispose();
    super.onClose();
  }

  // generate reference
  String _generateReference() {
    final username = box.read('biometric_username_real') ?? 'MCD';
    final userPrefix = username.length >= 3
        ? username.substring(0, 3).toUpperCase()
        : username.toUpperCase();
    return 'MCD2_$userPrefix${DateTime.now().microsecondsSinceEpoch}';
  }

  // amount input methods
  void addDigit(String digit) {
    if (enteredAmount.value.length < 10) {
      enteredAmount.value += digit;
    }
  }

  void deleteDigit() {
    if (enteredAmount.value.isNotEmpty) {
      enteredAmount.value =
          enteredAmount.value.substring(0, enteredAmount.value.length - 1);
    }
  }

  String get formattedAmount {
    if (enteredAmount.value.isEmpty) return '0.00';
    final amount = int.parse(enteredAmount.value);
    final formatter = NumberFormat('#,###');
    return formatter.format(amount);
  }

  void showConfirmationBottomSheet() {
    if (enteredAmount.value.isEmpty || int.parse(enteredAmount.value) <= 0) {
      Get.snackbar(
        'Error',
        'Please enter a valid amount',
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
      );
      return;
    }

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.account_balance_wallet,
                size: 32,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Confirm Wallet Top-up',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: AppFonts.manRope,
                color: AppColors.background,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Are you sure you want to fund your wallet with the sum of ₦${formattedAmount}?',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                color: AppColors.background.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: Obx(() => ElevatedButton(
                    onPressed: isProcessing.value
                        ? null
                        : () {
                            Get.back();
                            initiatePaystackPayment();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: isProcessing.value
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Pay with Paystack',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: AppFonts.manRope,
                              color: Colors.white,
                            ),
                          ),
                  )),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: OutlinedButton(
                onPressed: () => Get.back(),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: AppFonts.manRope,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      isDismissible: true,
      enableDrag: true,
    );
  }

  Future<void> initiatePaystackPayment() async {
    try {
      isProcessing.value = true;

      _currentAmount = int.parse(enteredAmount.value);
      _currentReference = _generateReference();

      // call /fundwallet endpoint first
      final transactionUrl = box.read('transaction_service_url');
      if (transactionUrl == null) {
        isProcessing.value = false;
        Get.snackbar(
          'Error',
          'Service configuration error. Please login again.',
          backgroundColor: AppColors.errorBgColor,
          colorText: AppColors.textSnackbarColor,
        );
        return;
      }

      final fundBody = {
        'amount': _currentAmount.toString(),
        'ref': _currentReference,
        'medium': 'paystack',
      };

      dev.log('fundwallet request: $fundBody', name: 'CardTopup');

      final result =
          await apiService.postrequest('${transactionUrl}fundwallet', fundBody);

      result.fold(
        (failure) {
          isProcessing.value = false;
          dev.log('fundwallet error: ${failure.message}', name: 'CardTopup');
          Get.snackbar(
            'Error',
            failure.message,
            backgroundColor: AppColors.errorBgColor,
            colorText: AppColors.textSnackbarColor,
          );
        },
        (data) {
          dev.log('fundwallet response: $data', name: 'CardTopup');

          if (data['success'] == 1 || data['message'] != null) {
            isProcessing.value = false;
            // show card input dialog
            _showCardInputDialog();
          } else {
            isProcessing.value = false;
            Get.snackbar(
              'Error',
              data['message'] ?? 'Failed to initialize payment',
              backgroundColor: AppColors.errorBgColor,
              colorText: AppColors.textSnackbarColor,
            );
          }
        },
      );
    } catch (e) {
      isProcessing.value = false;
      dev.log('Error initiating payment: $e', name: 'CardTopup');
      Get.snackbar(
        'Error',
        'Failed to process payment',
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
      );
    }
  }

  // show card input dialog
  void _showCardInputDialog() {
    // clear previous inputs
    cardNumberController.clear();
    expiryMonthController.clear();
    expiryYearController.clear();
    cvvController.clear();
    cardType.value = '';

    Get.dialog(
      Dialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Enter Card Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: AppFonts.manRope,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Get.back(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Amount: ₦$formattedAmount',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // card number
                  const Text(
                    'Card Number',
                    style:
                        TextStyle(fontSize: 14, fontFamily: AppFonts.manRope),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: cardNumberController,
                    keyboardType: TextInputType.number,
                    maxLength: 19,
                    style: const TextStyle(fontFamily: AppFonts.manRope),
                    decoration: InputDecoration(
                      hintText: '0000 0000 0000 0000',
                      hintStyle: TextStyle(color: AppColors.primaryGrey),
                      counterText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                            color: AppColors.primaryGrey2.withOpacity(0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                            color: AppColors.primaryColor, width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Required';
                      final cleaned = value.replaceAll(' ', '');
                      if (cleaned.length < 16) return 'Invalid card number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // expiry month, year and cvv row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Month',
                              style: TextStyle(
                                  fontSize: 14, fontFamily: AppFonts.manRope),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: expiryMonthController,
                              keyboardType: TextInputType.number,
                              maxLength: 2,
                              style:
                                  const TextStyle(fontFamily: AppFonts.manRope),
                              decoration: InputDecoration(
                                hintText: 'MM',
                                hintStyle:
                                    TextStyle(color: AppColors.primaryGrey),
                                counterText: '',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                      color: AppColors.primaryGrey2
                                          .withOpacity(0.3)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                      color: AppColors.primaryColor, width: 2),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                final month = int.tryParse(value);
                                if (month == null || month < 1 || month > 12) {
                                  return 'Invalid';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Year',
                              style: TextStyle(
                                  fontSize: 14, fontFamily: AppFonts.manRope),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: expiryYearController,
                              keyboardType: TextInputType.number,
                              maxLength: 2,
                              style:
                                  const TextStyle(fontFamily: AppFonts.manRope),
                              decoration: InputDecoration(
                                hintText: 'YY',
                                hintStyle:
                                    TextStyle(color: AppColors.primaryGrey),
                                counterText: '',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                      color: AppColors.primaryGrey2
                                          .withOpacity(0.3)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                      color: AppColors.primaryColor, width: 2),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                if (value.length < 2) return 'Invalid';
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'CVV',
                              style: TextStyle(
                                  fontSize: 14, fontFamily: AppFonts.manRope),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: cvvController,
                              keyboardType: TextInputType.number,
                              maxLength: 3,
                              obscureText: true,
                              style:
                                  const TextStyle(fontFamily: AppFonts.manRope),
                              decoration: InputDecoration(
                                hintText: '***',
                                hintStyle:
                                    TextStyle(color: AppColors.primaryGrey),
                                counterText: '',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                      color: AppColors.primaryGrey2
                                          .withOpacity(0.3)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                      color: AppColors.primaryColor, width: 2),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                if (value.length < 3) return 'Invalid';
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // pay button
                  Obx(() => SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed:
                              isLoading.value ? null : () => _chargeCard(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: isLoading.value
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Pay Now',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: AppFonts.manRope,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  // get card from UI
  PaymentCard _getCardFromUI() {
    final expiryMonth = int.tryParse(expiryMonthController.text) ?? 0;
    final expiryYear = int.tryParse(expiryYearController.text) ?? 0;

    return PaymentCard(
      cardNumber: cardNumberController.text.replaceAll(' ', ''),
      cvv: cvvController.text,
      expiryMonth1: expiryMonth,
      expiryYear1: expiryYear,
    );
  }

  // charge card with paystack
  Future<void> _chargeCard() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;

      final userEmail = box.read('user_email') ?? 'user@mcd.com';

      dev.log(
          'chargeCard request: ref=$_currentReference, amount=${_currentAmount * 100}, email=$userEmail',
          name: 'CardTopup');

      Charge charge = Charge();
      charge.card = _getCardFromUI();
      charge.amount = _currentAmount * 100; // convert to kobo
      charge.email = userEmail;
      charge.reference = _currentReference;
      charge.putCustomField('Charged From', 'MCD App');

      final context = Get.context!;
      final response = await plugin.chargeCard(context, charge: charge);

      dev.log(
          'chargeCard response: status=${response.status}, message=${response.message}',
          name: 'CardTopup');

      if (response.status == true) {
        // payment successful
        isLoading.value = false;
        Get.back(); // close dialog

        Get.snackbar(
          'Payment Successful',
          'Your wallet will be credited shortly.',
          backgroundColor: AppColors.successBgColor,
          colorText: AppColors.textSnackbarColor,
          duration: const Duration(seconds: 4),
        );

        // clear amount and go home
        enteredAmount.value = '';
        Get.until((route) => route.settings.name == Routes.HOME_SCREEN);
      } else {
        isLoading.value = false;
        Get.snackbar(
          'Payment Failed',
          response.message,
          backgroundColor: AppColors.errorBgColor,
          colorText: AppColors.textSnackbarColor,
        );
      }
    } catch (e) {
      isLoading.value = false;
      dev.log('chargeCard error: $e', name: 'CardTopup');
      Get.snackbar(
        'Error',
        'Failed to process payment',
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
      );
    }
  }

  void _detectCardType() {
    final number = cardNumberController.text.replaceAll(' ', '');
    if (number.isEmpty) {
      cardType.value = '';
      return;
    }

    if (number.startsWith('4')) {
      cardType.value = 'visa';
    } else if (number.startsWith(RegExp(r'^5[1-5]')) ||
        number.startsWith(
            RegExp(r'^2(22[1-9]|2[3-9][0-9]|[3-6][0-9]{2}|7[0-1][0-9]|720)'))) {
      cardType.value = 'mastercard';
    } else if (number.startsWith('506') || number.startsWith('650')) {
      cardType.value = 'verve';
    } else {
      cardType.value = '';
    }
  }

  String formatCardNumber(String value) {
    value = value.replaceAll(' ', '');
    String formatted = '';
    for (int i = 0; i < value.length; i++) {
      if (i > 0 && i % 4 == 0) {
        formatted += ' ';
      }
      formatted += value[i];
    }
    return formatted;
  }

  String formatExpiryDate(String value) {
    value = value.replaceAll('/', '');
    if (value.length >= 2) {
      return '${value.substring(0, 2)}/${value.substring(2)}';
    }
    return value;
  }

  Future<void> processTopup() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      isLoading.value = true;
      dev.log('Processing card top-up', name: 'CardTopup');

      final utilityUrl = box.read('utility_service_url');
      if (utilityUrl == null) {
        dev.log('Utility URL not found',
            name: 'CardTopup', error: 'URL missing');
        Get.snackbar(
          'Error',
          'Service configuration error. Please login again.',
          backgroundColor: AppColors.errorBgColor,
          colorText: AppColors.textSnackbarColor,
        );
        return;
      }

      final body = {
        'card_number': cardNumberController.text.replaceAll(' ', ''),
        'card_name': cardNameController.text,
        'expiry_date':
            '${expiryMonthController.text}/${expiryYearController.text}',
        'cvv': cvvController.text,
        'amount': amountController.text,
      };

      dev.log('Sending card top-up request', name: 'CardTopup');

      final result =
          await apiService.postrequest('${utilityUrl}card-topup', body);

      result.fold(
        (failure) {
          dev.log('Card top-up failed',
              name: 'CardTopup', error: failure.message);
          Get.snackbar(
            'Error',
            failure.message,
            backgroundColor: AppColors.errorBgColor,
            colorText: AppColors.textSnackbarColor,
          );
        },
        (data) {
          if (data['success'] == 1) {
            dev.log('Card top-up successful', name: 'CardTopup');
            Get.snackbar(
              'Success',
              data['message'] ?? 'Top-up successful',
              backgroundColor: AppColors.successBgColor,
              colorText: AppColors.textSnackbarColor,
            );

            _clearForm();
            Get.back();
          } else {
            Get.snackbar(
              'Error',
              data['message'] ?? 'Top-up failed',
              backgroundColor: AppColors.errorBgColor,
              colorText: AppColors.textSnackbarColor,
            );
          }
        },
      );
    } catch (e) {
      dev.log('Error processing card top-up', name: 'CardTopup', error: e);
      Get.snackbar(
        'Error',
        'An error occurred while processing your request',
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _clearForm() {
    cardNumberController.clear();
    cardNameController.clear();
    expiryMonthController.clear();
    expiryYearController.clear();
    cvvController.clear();
    amountController.clear();
    cardType.value = '';
  }
}
