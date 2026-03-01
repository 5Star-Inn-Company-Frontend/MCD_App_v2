import 'package:mcd/core/import/imports.dart';
import 'package:mcd/core/network/dio_api_service.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:developer' as dev;

import 'dart:math';

class MomoModuleController extends GetxController {
  final apiService = DioApiService();

  final isLoading = false.obs;
  final isSubmitting = false.obs;

  final selectedCurrency = Rxn<String>();
  final selectedProvider = Rxn<Map<String, dynamic>>();
  final selectedCountryCode = ''.obs;

  // currency to country calling code map
  static const currencyCountryCodeMap = <String, String>{
    'KES': '254', // Kenya
    'UGX': '256', // Uganda
    'GHS': '233', // Ghana
    'ZMW': '260', // Zambia
    'XAF': '237', // Cameroon (Central African CFA)
    'XOF': '221', // Senegal (West African CFA)
    'ZAR': '27', // South Africa
  };

  final phoneController = TextEditingController();
  final amountController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final currencies = <String>[].obs;
  final providers = <Map<String, dynamic>>[].obs;

  final currentStage = 0.obs;

  final exchangeRate = 0.0.obs;
  final convertedAmount = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCurrencies();
    amountController.addListener(_calculateConversion);
  }

  @override
  void onClose() {
    phoneController.dispose();
    amountController.dispose();
    amountController.removeListener(_calculateConversion);
    super.onClose();
  }

  void _calculateConversion() {
    final amount = double.tryParse(amountController.text) ?? 0.0;
    convertedAmount.value = amount * exchangeRate.value;
  }

  Future<void> fetchCurrencies() async {
    try {
      isLoading.value = true;
      final box = GetStorage();
      final transactionUrl = box.read('transaction_service_url');

      if (transactionUrl == null) {
        dev.log('transaction URL not found', name: 'MomoModule');
        return;
      }

      final url = '${transactionUrl}payment/momo/currencies';
      dev.log('Fetching currencies from: $url', name: 'MomoModule');

      final result = await apiService.getrequest(url);

      result.fold(
        (failure) {
          dev.log('Failed to fetch currencies: ${failure.message}',
              name: 'MomoModule');
          Get.snackbar('Error', 'Failed to load currencies',
              backgroundColor: AppColors.errorBgColor,
              colorText: AppColors.white);
        },
        (data) {
          if (data['success'] == 1 && data['data'] != null) {
            final List<dynamic> list = data['data'];
            currencies.value = list.cast<String>();
          }
        },
      );
    } catch (e) {
      dev.log('Error fetching currencies', error: e, name: 'MomoModule');
    } finally {
      isLoading.value = false;
    }
  }

  void onCurrencyChanged(String? value) {
    if (value == null) return;
    selectedCurrency.value = value;
    selectedProvider.value = null;
    providers.clear();

    // auto-match country code from currency
    selectedCountryCode.value = currencyCountryCodeMap[value] ?? '';

    fetchProviders(value);
    fetchExchangeRate(value);
  }

  Future<void> fetchExchangeRate(String currency) async {
    try {
      exchangeRate.value = 0.0;
      _calculateConversion();

      final box = GetStorage();
      final transactionUrl = box.read('transaction_service_url');

      if (transactionUrl == null) return;

      final url = '${transactionUrl}payment/fx';
      final body = {"currency": currency};
      final result = await apiService.postrequest(url, body);

      result.fold((failure) {
        dev.log('Failed to fetch exchange rate: ${failure.message}',
            name: 'MomoModule');
        Get.snackbar('Error', 'Failed to load exchange rate',
            backgroundColor: AppColors.errorBgColor,
            colorText: AppColors.white);
      }, (data) {
        if (data['success'] == 1 && data['data'] != null) {
          exchangeRate.value = double.tryParse(data['data'].toString()) ?? 0.0;
          _calculateConversion();
        }
      });
    } catch (e) {
      dev.log('Error fetching exchange rate', error: e, name: 'MomoModule');
    }
  }

  Future<void> fetchProviders(String currency) async {
    try {
      isLoading.value = true;
      final box = GetStorage();
      final transactionUrl = box.read('transaction_service_url');

      if (transactionUrl == null) return;

      final url = '${transactionUrl}payment/momo/providers/$currency';
      final result = await apiService.getrequest(url);

      result.fold((failure) {
        Get.snackbar('Error', failure.message,
            backgroundColor: AppColors.errorBgColor,
            colorText: AppColors.white);
      }, (data) {
        if (data['success'] == 1 && data['data'] != null) {
          final List<dynamic> providerList = data['data'];
          providers.value = providerList.cast<Map<String, dynamic>>();
        }
      });
    } catch (e) {
      dev.log('Error fetching providers', error: e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> proceed() async {
    if (!formKey.currentState!.validate()) return;
    if (selectedCurrency.value == null || selectedProvider.value == null) {
      Get.snackbar('Error', 'Please select currency and provider',
          backgroundColor: AppColors.errorBgColor, colorText: AppColors.white);
      return;
    }

    if (selectedCountryCode.value.isEmpty) {
      Get.snackbar('Error', 'Unsupported currency for country code mapping',
          backgroundColor: AppColors.errorBgColor, colorText: AppColors.white);
      return;
    }

    isSubmitting.value = true;
    try {
      await _initiateMomoPayment();
    } catch (e) {
      dev.log('Error processing momo payment', error: e, name: 'MomoModule');
      Get.snackbar('Error', 'An unexpected error occurred',
          backgroundColor: AppColors.errorBgColor, colorText: AppColors.white);
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> _initiateMomoPayment() async {
    final box = GetStorage();
    final transactionUrl = box.read('transaction_service_url');

    if (transactionUrl == null) {
      Get.snackbar('Error', 'Service URL not configured',
          backgroundColor: AppColors.errorBgColor, colorText: AppColors.white);
      return;
    }

    // Generate Reference
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(9999);
    final ref = 'MCD2_FW_MOMO$timestamp$random';

    final url = '${transactionUrl}payment/momo/initiate';
    dev.log(url, name: 'MomoModule');

    // strip leading zero and prepend country code
    var rawPhone = phoneController.text;
    if (rawPhone.startsWith('0')) {
      rawPhone = rawPhone.substring(1);
    }
    final phone = '${selectedCountryCode.value}$rawPhone';

    // Get provider code/name
    final providerCode = selectedProvider.value?['code'] ??
        selectedProvider.value?['name'] ??
        '';

    final body = {
      "phone": phone,
      "currency": selectedCurrency.value,
      "provider": providerCode,
      "amount": amountController.text,
      "ref": ref
    };

    dev.log('Initiating Momo Payment: $body', name: 'MomoModule');

    final result = await apiService.postrequest(url, body);

    result.fold(
      (failure) {
        Get.snackbar('Error', failure.message,
            backgroundColor: AppColors.errorBgColor,
            colorText: AppColors.white);
      },
      (data) {
        dev.log('Momo Initiate Response: $data', name: 'MomoModule');

        if (data['success'] == 1) {
          final authType = data['auth'];

          if (authType == "OTP") {
            // Case A: OTP Required
            _showOTPDialog(ref);
          } else {
            // Case B: No OTP
            Get.snackbar('Success', data['message'] ?? 'Transaction initiated',
                backgroundColor: AppColors.successBgColor,
                colorText: AppColors.white);
            currentStage.value = 1;
          }
        } else {
          Get.snackbar('Error', data['message'] ?? 'Transaction failed',
              backgroundColor: AppColors.errorBgColor,
              colorText: AppColors.white);
        }
      },
    );
  }

  void _showOTPDialog(String ref) {
    final otpController = TextEditingController();
    Get.defaultDialog(
      title: "OTP Required",
      titleStyle: const TextStyle(
        fontFamily: AppFonts.manRope,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
      content: Column(
        children: [
          const Text(
            "Please enter the OTP sent to your phone to authorize the transaction.",
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: AppFonts.manRope, fontSize: 14),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: otpController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: "Enter OTP",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
        ],
      ),
      confirm: SizedBox(
        width: 120,
        child: ElevatedButton(
          onPressed: () {
            if (otpController.text.isNotEmpty) {
              Get.back(); // Close dialog
              _authorizeMomoPayment(otpController.text, ref);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text("Confirm"),
        ),
      ),
      cancel: SizedBox(
        width: 120,
        child: OutlinedButton(
          onPressed: () => Get.back(),
          style: OutlinedButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text("Cancel"),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _authorizeMomoPayment(String otp, String ref) async {
    isSubmitting.value = true;
    final box = GetStorage();
    final transactionUrl = box.read('transaction_service_url');
    final url = '${transactionUrl}payment/momo/authorize';

    final body = {"otp": otp, "ref": ref};

    dev.log('Authorizing Momo Payment: $body', name: 'MomoModule');

    final result = await apiService.postrequest(url, body);

    isSubmitting.value = false; // Stop loading even if success/fail

    result.fold(
      (failure) {
        Get.snackbar('Error', failure.message,
            backgroundColor: AppColors.errorBgColor,
            colorText: AppColors.white);
      },
      (data) {
        dev.log('Momo Authorize Response: $data', name: 'MomoModule');

        if (data['success'] == 1) {
          Get.snackbar('Success', data['message'] ?? 'Transaction authorized',
              backgroundColor: AppColors.successBgColor,
              colorText: AppColors.white);
          currentStage.value = 1;
        } else {
          Get.snackbar('Error', data['message'] ?? 'Authorization failed',
              backgroundColor: AppColors.errorBgColor,
              colorText: AppColors.white);
        }
      },
    );
  }
}
