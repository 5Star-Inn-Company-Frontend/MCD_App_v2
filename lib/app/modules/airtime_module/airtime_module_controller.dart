import 'package:get_storage/get_storage.dart';
import 'package:mcd/app/modules/airtime_module/model/airtime_provider_model.dart';
import 'package:mcd/app/modules/general_payout/general_payout_controller.dart';
import 'package:mcd/core/import/imports.dart';
import 'dart:developer' as dev;
import 'package:permission_handler/permission_handler.dart';

import '../../../core/network/dio_api_service.dart';
import '../../utils/strings.dart';

class AirtimeModuleController extends GetxController {
  final apiService = DioApiService();
  final box = GetStorage();

  final formKey = GlobalKey<FormState>();
  final phoneController = TextEditingController();
  final amountController = TextEditingController();
  final selectedAmount = ''.obs;

  final selectedProvider = Rxn<AirtimeProvider>();

  final _isLoading = true.obs;
  bool get isLoading => _isLoading.value;

  final _errorMessage = RxnString();
  String? get errorMessage => _errorMessage.value;

  final _airtimeProviders = <AirtimeProvider>[].obs;
  List<AirtimeProvider> get airtimeProviders => _airtimeProviders;

  final _isPaying = false.obs;
  bool get isPaying => _isPaying.value;

  // Tab switcher state
  final isSingleAirtime = true.obs;

  // Multiple airtime list
  final multipleAirtimeList = <Map<String, dynamic>>[].obs;

  // Inline verification state for multiple airtime
  final isVerifying = false.obs;
  final isNumberVerified = false.obs;
  final verifiedNetwork = ''.obs;

  // Track if this is foreign airtime
  bool _isForeign = false;
  bool get isForeign => _isForeign;
  String? _countryCode;
  String? get countryCode => _countryCode;

  final Map<String, String> networkImages = {
    'mtn': AppAsset.mtn,
    'airtel': AppAsset.airtel,
    'glo': AppAsset.glo,
    '9mobile': AppAsset.nineMobile,
  };

  String getProviderLogo(String networkName) {
    final normalized = networkName.toLowerCase().trim();

    if (normalized.contains('mtn')) return AppAsset.mtn;
    if (normalized.contains('airtel')) return AppAsset.airtel;
    if (normalized.contains('glo')) return AppAsset.glo;
    if (normalized.contains('9mobile') ||
        normalized.contains('etisalat') ||
        normalized == '9mob') {
      return AppAsset.nineMobile;
    }

    return AppAsset.mcdLogo;
  }

  @override
  void onInit() {
    super.onInit();
    // Check if we have a verified number and network from navigation
    final verifiedNumber = Get.arguments?['verifiedNumber'];
    final verifiedNetwork = Get.arguments?['verifiedNetwork'];
    final isForeign = Get.arguments?['isForeign'] ?? false;
    final countryCode = Get.arguments?['countryCode'];

    _isForeign = isForeign;
    // For non-foreign airtime, default to 'NG' if countryCode is null or empty
    _countryCode = (countryCode == null || countryCode.toString().isEmpty) 
        ? (isForeign ? null : 'NG') 
        : countryCode;

    if (verifiedNumber != null) {
      phoneController.text = verifiedNumber;
      dev.log('Airtime initialized with verified number: $verifiedNumber',
          name: 'AirtimeModule');
    }

    if (verifiedNetwork != null) {
      dev.log('Airtime initialized with verified network: $verifiedNetwork',
          name: 'AirtimeModule');
    }

    if (isForeign) {
      dev.log(
          'Airtime initialized in FOREIGN mode for country code: $countryCode',
          name: 'AirtimeModule');
      fetchForeignAirtimeProviders(
          countryCode: countryCode, preSelectedNetwork: verifiedNetwork);
    } else {
      fetchAirtimeProviders(preSelectedNetwork: verifiedNetwork);
    }
  }

  @override
  void onClose() {
    phoneController.dispose();
    amountController.dispose();
    super.onClose();
  }

  Future<void> pickContact() async {
    try {
      final permissionStatus = await Permission.contacts.request();

      if (permissionStatus.isGranted) {
        String? number = await contactpicked();

        if (number != null && number.length == 11) {
          phoneController.text = number;
          dev.log('Selected contact number: $number', name: 'AirtimeModule');

          // auto-detect network from phone prefix
          final detectedNetwork = _detectNetworkFromNumber(number);
          if (detectedNetwork != null && _airtimeProviders.isNotEmpty) {
            final matchedProvider = _airtimeProviders.firstWhereOrNull(
                (provider) =>
                    _normalizeNetworkName(provider.network) == detectedNetwork);
            if (matchedProvider != null) {
              selectedProvider.value = matchedProvider;
              dev.log('Auto-selected network: $detectedNetwork',
                  name: 'AirtimeModule');
            }
          }
        } else {
          Get.snackbar(
            'Invalid Number',
            'The selected contact does not have a valid Nigerian phone number',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
        }
      } else if (permissionStatus.isPermanentlyDenied) {
        Get.snackbar(
          'Permission Denied',
          'Please enable contacts permission in settings',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        await openAppSettings();
      } else {
        Get.snackbar(
          'Permission Required',
          'Contacts permission is required to select a contact',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      dev.log('Error picking contact', name: 'AirtimeModule', error: e);
      Get.snackbar(
        'Error',
        'Failed to pick contact. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> fetchAirtimeProviders({String? preSelectedNetwork}) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = null;
      dev.log('Fetching airtime providers...', name: 'AirtimeModule');

      final transactionUrl = box.read('transaction_service_url');
      if (transactionUrl == null || transactionUrl.isEmpty) {
        _errorMessage.value = "Transaction URL not found. Please log in again.";
        dev.log('Transaction URL not found',
            name: 'AirtimeModule', error: _errorMessage.value);
        return;
      }

      final fullUrl = transactionUrl + 'airtime';
      dev.log('Request URL: $fullUrl', name: 'AirtimeModule');
      final result = await apiService.getrequest(fullUrl);

      result.fold(
        (failure) {
          _errorMessage.value = failure.message;
          dev.log('Failed to fetch providers',
              name: 'AirtimeModule', error: failure.message);
        },
        (data) {
          dev.log('Providers fetched successfully', name: 'AirtimeModule');
          if (data['data'] != null && data['data'] is List) {
            final List<dynamic> providerListJson = data['data'];
            _airtimeProviders.value = providerListJson
                .map((item) => AirtimeProvider.fromJson(item))
                .toList();
            dev.log('Loaded ${_airtimeProviders.length} providers',
                name: 'AirtimeModule');

            // Pre-select network if provided from verification
            if (preSelectedNetwork != null && _airtimeProviders.isNotEmpty) {
              dev.log('Trying to match network: "$preSelectedNetwork"',
                  name: 'AirtimeModule');
              dev.log(
                  'Available providers: ${_airtimeProviders.map((p) => p.network).join(", ")}',
                  name: 'AirtimeModule');

              // Normalize the network name for matching
              final normalizedInput = _normalizeNetworkName(preSelectedNetwork);
              dev.log('Normalized input: "$normalizedInput"',
                  name: 'AirtimeModule');

              final matchedProvider = _airtimeProviders.firstWhereOrNull(
                  (provider) =>
                      _normalizeNetworkName(provider.network) ==
                      normalizedInput);

              if (matchedProvider != null) {
                selectedProvider.value = matchedProvider;
                dev.log(
                    'Pre-selected verified network: ${matchedProvider.network}',
                    name: 'AirtimeModule');
              } else {
                selectedProvider.value = _airtimeProviders.first;
                dev.log(
                    'Network "$preSelectedNetwork" not found in providers, auto-selected first: ${selectedProvider.value?.network}',
                    name: 'AirtimeModule');
              }
            } else if (_airtimeProviders.isNotEmpty) {
              selectedProvider.value = _airtimeProviders.first;
              dev.log(
                  'Auto-selected provider: ${selectedProvider.value?.network}',
                  name: 'AirtimeModule');
            }
          } else {
            _errorMessage.value = "Invalid data format from server.";
            dev.log('Invalid data format',
                name: 'AirtimeModule', error: _errorMessage.value);
          }
        },
      );
    } catch (e) {
      _errorMessage.value = "An unexpected error occurred: $e";
      dev.log("Error fetching providers", name: 'AirtimeModule', error: e);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> fetchForeignAirtimeProviders(
      {String? countryCode, String? preSelectedNetwork}) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = null;
      dev.log('Fetching foreign airtime providers for country: $countryCode',
          name: 'AirtimeModule');

      final transactionUrl = box.read('transaction_service_url');
      if (transactionUrl == null || transactionUrl.isEmpty) {
        _errorMessage.value = "Transaction URL not found. Please log in again.";
        dev.log('Transaction URL not found',
            name: 'AirtimeModule', error: _errorMessage.value);
        return;
      }

      final fullUrl = '${transactionUrl}foreign_airtime/$countryCode';
      dev.log('Request URL: $fullUrl', name: 'AirtimeModule');
      final result = await apiService.getrequest(fullUrl);

      result.fold(
        (failure) {
          _errorMessage.value = failure.message;
          dev.log('Failed to fetch foreign providers',
              name: 'AirtimeModule', error: failure.message);
        },
        (data) {
          dev.log('Foreign providers fetched successfully',
              name: 'AirtimeModule');
          dev.log('Raw foreign providers data: $data', name: 'AirtimeModule');
          if (data['data'] != null && data['data'] is List) {
            final List<dynamic> providerListJson = data['data'];
            dev.log(
                'First provider JSON: ${providerListJson.isNotEmpty ? providerListJson[0] : "empty"}',
                name: 'AirtimeModule');
            _airtimeProviders.value = providerListJson
                .map((item) => AirtimeProvider.fromJson(item))
                .toList();
            dev.log('Loaded ${_airtimeProviders.length} foreign providers',
                name: 'AirtimeModule');
            dev.log(
                'Foreign providers: ${_airtimeProviders.map((p) => p.network).join(", ")}',
                name: 'AirtimeModule');

            // Pre-select network if provided from verification
            if (preSelectedNetwork != null && _airtimeProviders.isNotEmpty) {
              dev.log('Trying to match foreign network: "$preSelectedNetwork"',
                  name: 'AirtimeModule');

              final matchedProvider = _airtimeProviders.firstWhereOrNull(
                  (provider) =>
                      provider.network.toLowerCase() ==
                      preSelectedNetwork.toLowerCase());

              if (matchedProvider != null) {
                selectedProvider.value = matchedProvider;
                dev.log(
                    'Pre-selected verified foreign network: ${matchedProvider.network}',
                    name: 'AirtimeModule');
              } else {
                selectedProvider.value = _airtimeProviders.first;
                dev.log(
                    'Foreign network "$preSelectedNetwork" not found, auto-selected first: ${selectedProvider.value?.network}',
                    name: 'AirtimeModule');
              }
            } else if (_airtimeProviders.isNotEmpty) {
              selectedProvider.value = _airtimeProviders.first;
              dev.log(
                  'Auto-selected foreign provider: ${selectedProvider.value?.network}',
                  name: 'AirtimeModule');
            }
          } else {
            _errorMessage.value = "Invalid data format from server.";
            dev.log('Invalid data format',
                name: 'AirtimeModule', error: _errorMessage.value);
          }
        },
      );
    } catch (e) {
      _errorMessage.value = "An unexpected error occurred: $e";
      dev.log("Error fetching foreign providers",
          name: 'AirtimeModule', error: e);
    } finally {
      _isLoading.value = false;
    }
  }

  void onProviderSelected(AirtimeProvider? provider) {
    if (provider != null) {
      selectedProvider.value = provider;
      dev.log('Provider selected: ${provider.network}', name: 'AirtimeModule');
    }
  }

  /// detect network from nigerian phone prefix
  String? _detectNetworkFromNumber(String phoneNumber) {
    if (phoneNumber.length < 4) return null;

    final prefix = phoneNumber.substring(0, 4);

    // mtn prefixes
    const mtnPrefixes = [
      '0703',
      '0706',
      '0803',
      '0806',
      '0810',
      '0813',
      '0814',
      '0816',
      '0903',
      '0906',
      '0913',
      '0916'
    ];
    if (mtnPrefixes.contains(prefix)) return 'mtn';

    // airtel prefixes
    const airtelPrefixes = [
      '0701',
      '0708',
      '0802',
      '0808',
      '0812',
      '0902',
      '0907',
      '0912',
      '0901'
    ];
    if (airtelPrefixes.contains(prefix)) return 'airtel';

    // glo prefixes
    const gloPrefixes = ['0705', '0805', '0807', '0811', '0905', '0915'];
    if (gloPrefixes.contains(prefix)) return 'glo';

    // 9mobile prefixes
    const nmobilePrefixes = ['0809', '0817', '0818', '0909', '0908'];
    if (nmobilePrefixes.contains(prefix)) return '9mobile';

    return null;
  }

  /// Normalize network name for consistent matching
  String _normalizeNetworkName(String networkName) {
    final normalized = networkName.toLowerCase().trim();

    // Handle common variations
    if (normalized.contains('mtn')) return 'mtn';
    if (normalized.contains('airtel')) return 'airtel';
    if (normalized.contains('glo')) return 'glo';
    if (normalized.contains('9mobile') ||
        normalized.contains('etisalat') ||
        normalized == '9mob') {
      return '9mobile';
    }

    return normalized;
  }

  void onAmountSelected(String amount) {
    amountController.text = amount;
    selectedAmount.value = amount;
    dev.log('Amount selected: ₦$amount', name: 'AirtimeModule');
  }

  // void setPaymentMethod(String method) {
  //   dev.log('Setting payment method: $method', name: 'AirtimeModule');
  //   selectedPaymentMethod.value = method;
  // }

  void pay() async {
    dev.log('Navigating to payout screen', name: 'AirtimeModule');

    if (selectedProvider.value == null) {
      dev.log('Navigation failed: No provider selected',
          name: 'AirtimeModule', error: 'Provider missing');
      Get.snackbar("Error", "Please select a network provider.",
          backgroundColor: AppColors.errorBgColor,
          colorText: AppColors.textSnackbarColor);
      return;
    }

    if (formKey.currentState?.validate() ?? false) {
      Get.toNamed(
        Routes.GENERAL_PAYOUT,
        arguments: {
          'paymentType': PaymentType.airtime,
          'paymentData': {
            'provider': selectedProvider.value,
            'phoneNumber': phoneController.text,
            'amount': amountController.text,
            'networkImage': getProviderLogo(selectedProvider.value!.network),
            'isForeign': _isForeign,
            'countryCode': _countryCode,
          },
        },
      );
    }
  }

  // Multiple airtime methods

  // reset verification state when phone number changes
  void onPhoneNumberChanged() {
    isNumberVerified.value = false;
    verifiedNetwork.value = '';
  }

  // verify number inline without navigating away
  Future<void> verifyNumberInline() async {
    // Only enforce 11-digit validation for Nigerian numbers
    if (phoneController.text.isEmpty) {
      Get.snackbar("Error", "Please enter a phone number.",
          backgroundColor: AppColors.errorBgColor,
          colorText: AppColors.textSnackbarColor);
      return;
    }

    if (!_isForeign && phoneController.text.length != 11) {
      Get.snackbar("Error", "Please enter a valid 11-digit phone number.",
          backgroundColor: AppColors.errorBgColor,
          colorText: AppColors.textSnackbarColor);
      return;
    }

    isVerifying.value = true;

    try {
      final transactionUrl = box.read('transaction_service_url');
      if (transactionUrl == null) {
        Get.snackbar("Error", "Transaction URL not found. Please log in again.",
            backgroundColor: AppColors.errorBgColor,
            colorText: AppColors.textSnackbarColor);
        return;
      }

      final body = {
        "service": "airtime",
        "provider": _isForeign ? _countryCode : "Ng",
        "number": phoneController.text,
      };

      // Use different endpoint for foreign vs Nigerian validation
      final endpoint = _isForeign ? 'validate' : 'validate-number';
      dev.log('Inline verification request to $endpoint: $body', name: 'AirtimeModule');
      final result = await apiService.postrequest(
          '$transactionUrl$endpoint', body);

      result.fold(
        (failure) {
          dev.log('Inline verification failed: ${failure.message}',
              name: 'AirtimeModule');
          Get.snackbar("Verification Failed", failure.message,
              backgroundColor: AppColors.errorBgColor,
              colorText: AppColors.textSnackbarColor);
          isNumberVerified.value = false;
        },
        (data) {
          dev.log('Inline verification response: $data', name: 'AirtimeModule');
          if (data['success'] == 1) {
            final networkName = data['data']?['operatorName'] ?? 'Unknown';
            verifiedNetwork.value = networkName;
            isNumberVerified.value = true;

            // auto-select the matching provider
            final normalizedNetwork = _normalizeNetworkName(networkName);
            final matchedProvider = _airtimeProviders.firstWhereOrNull(
                (p) => _normalizeNetworkName(p.network) == normalizedNetwork);
            if (matchedProvider != null) {
              selectedProvider.value = matchedProvider;
            }

            dev.log('Number verified as: $networkName', name: 'AirtimeModule');
          } else {
            Get.snackbar("Verification Failed",
                data['message'] ?? "Could not verify number.",
                backgroundColor: AppColors.errorBgColor,
                colorText: AppColors.textSnackbarColor);
            isNumberVerified.value = false;
          }
        },
      );
    } catch (e) {
      dev.log('Inline verification error: $e', name: 'AirtimeModule');
      Get.snackbar("Error", "Verification failed. Please try again.",
          backgroundColor: AppColors.errorBgColor,
          colorText: AppColors.textSnackbarColor);
    } finally {
      isVerifying.value = false;
    }
  }

  // add verified number to multiple list
  void addToMultipleList() {
    if (!isNumberVerified.value) {
      Get.snackbar("Error", "Please verify the number first.",
          backgroundColor: AppColors.errorBgColor,
          colorText: AppColors.textSnackbarColor);
      return;
    }

    if (amountController.text.isEmpty) {
      Get.snackbar("Error", "Please enter an amount.",
          backgroundColor: AppColors.errorBgColor,
          colorText: AppColors.textSnackbarColor);
      return;
    }

    // Validate amount against min/max
    final amount = double.tryParse(amountController.text);
    if (amount == null) {
      Get.snackbar("Error", "Please enter a valid amount.",
          backgroundColor: AppColors.errorBgColor,
          colorText: AppColors.textSnackbarColor);
      return;
    }

    final provider = selectedProvider.value;
    if (provider?.minAmount != null && amount < provider!.minAmount!) {
      Get.snackbar("Amount Too Low", 
          "Amount must be at least ${provider.minAmount!.toStringAsFixed(0)}.",
          backgroundColor: AppColors.errorBgColor,
          colorText: AppColors.textSnackbarColor);
      return;
    }

    if (provider?.maxAmount != null && amount > provider!.maxAmount!) {
      Get.snackbar("Amount Too High", 
          "Amount must not exceed ${provider.maxAmount!.toStringAsFixed(0)}.",
          backgroundColor: AppColors.errorBgColor,
          colorText: AppColors.textSnackbarColor);
      return;
    }

    // Check if we can add more (max 5)
    if (multipleAirtimeList.length >= 5) {
      Get.snackbar("Limit Reached", "You can only add up to 5 numbers.",
          backgroundColor: AppColors.errorBgColor,
          colorText: AppColors.textSnackbarColor);
      return;
    }

    multipleAirtimeList.add({
      'provider': selectedProvider.value,
      'phoneNumber': phoneController.text,
      'amount': amountController.text,
      'networkImage': getProviderLogo(verifiedNetwork.value),
      'verifiedNetwork': verifiedNetwork.value,
    });

    dev.log(
        'Added to multiple list: ${phoneController.text} - ₦${amountController.text}',
        name: 'AirtimeModule');

    Get.snackbar(
      "Added",
      "${phoneController.text} - ₦${amountController.text}",
      backgroundColor: AppColors.successBgColor,
      colorText: AppColors.textSnackbarColor,
      duration: const Duration(seconds: 2),
    );

    // Clear inputs for next entry
    phoneController.clear();
    amountController.clear();
    isNumberVerified.value = false;
    verifiedNetwork.value = '';
  }

  void removeFromMultipleList(int index) {
    if (index >= 0 && index < multipleAirtimeList.length) {
      dev.log(
          'Removing from multiple list: ${multipleAirtimeList[index]['phoneNumber']}',
          name: 'AirtimeModule');
      multipleAirtimeList.removeAt(index);
    }
  }

  void payMultiple() async {
    if (multipleAirtimeList.isEmpty) {
      Get.snackbar("Error", "Please add at least one number to the list.",
          backgroundColor: AppColors.errorBgColor,
          colorText: AppColors.textSnackbarColor);
      return;
    }

    dev.log(
        'Navigating to multiple airtime payout with ${multipleAirtimeList.length} numbers',
        name: 'AirtimeModule');

    Get.toNamed(
      Routes.GENERAL_PAYOUT,
      arguments: {
        'paymentType': PaymentType.airtime,
        'paymentData': {
          'isMultiple': true,
          'multipleList': multipleAirtimeList.toList(),
          'isForeign': _isForeign,
          'countryCode': _countryCode,
        },
      },
    );
  }
}
