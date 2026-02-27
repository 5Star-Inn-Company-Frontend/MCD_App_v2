import 'dart:developer' as dev;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mcd/core/import/imports.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/network/dio_api_service.dart';
import '../../utils/strings.dart';

class NumberVerificationModuleController extends GetxController {
  final apiService = DioApiService();
  final box = GetStorage();

  final phoneController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final isLoading = false.obs;

  String? _redirectTo;
  bool _isMultipleAirtimeAdd = false;
  bool _isForeign = false;
  String? _countryCode;
  String? _countryName;
  String? _callingCode;

  // Expose isForeign for UI
  bool get isForeign => _isForeign;
  String? get callingCode => _callingCode;
  String? get countryName => _countryName;

  // recent verified numbers
  final recentNumbers = <Map<String, String>>[].obs;
  static const _recentNumbersKey = 'recent_verified_numbers';

  // beneficiaries from API
  final beneficiaries = <Map<String, dynamic>>[].obs;
  final isLoadingBeneficiaries = false.obs;

  // all beneficiaries regardless of type
  List<Map<String, dynamic>> get filteredBeneficiaries =>
      beneficiaries.toList();

  @override
  void onInit() {
    super.onInit();
    // Get the redirect route from navigation arguments
    _redirectTo = Get.arguments?['redirectTo'];
    _isMultipleAirtimeAdd = Get.arguments?['isMultipleAirtimeAdd'] ?? false;
    _isForeign = Get.arguments?['isForeign'] ?? false;
    _countryCode = Get.arguments?['countryCode'];
    _countryName = Get.arguments?['countryName'];
    _callingCode = Get.arguments?['callingCode'];

    // Pre-fill phone number if provided (for multiple airtime)
    final preFilledNumber = Get.arguments?['phoneNumber'];
    if (preFilledNumber != null) {
      phoneController.text = preFilledNumber;
    }

    // auto-verify when 11 digits reached
    // phoneController.addListener(_onPhoneChanged);

    dev.log(
        'NumberVerificationModule initialized with redirectTo: $_redirectTo, isMultipleAirtimeAdd: $_isMultipleAirtimeAdd, isForeign: $_isForeign, countryCode: $_countryCode',
        name: 'NumberVerification');

    _loadRecentNumbers();
    fetchBeneficiaries(); // Load beneficiaries on init
  }

  // Fetch beneficiaries from API
  Future<void> fetchBeneficiaries() async {
    try {
      isLoadingBeneficiaries.value = true;
      dev.log('Fetching beneficiaries from API', name: 'NumberVerification');

      final transactionUrl = box.read('transaction_service_url');
      if (transactionUrl == null) {
        dev.log('Transaction URL not found', name: 'NumberVerification');
        Get.snackbar(
          'Error',
          'Transaction URL not found. Please log in again.',
          backgroundColor: AppColors.errorBgColor,
          colorText: AppColors.textSnackbarColor,
        );
        return;
      }

      final url = '${transactionUrl}beneficiary/airtime';
      dev.log('Fetching from: $url', name: 'NumberVerification');

      final result = await apiService.getrequest(url);

      result.fold(
        (failure) {
          dev.log('Failed to fetch beneficiaries: ${failure.message}',
              name: 'NumberVerification');
          Get.snackbar(
            'Error',
            failure.message,
            backgroundColor: AppColors.errorBgColor,
            colorText: AppColors.textSnackbarColor,
          );
        },
        (data) {
          dev.log('Beneficiaries response: $data', name: 'NumberVerification');

          if (data['success'] == 1) {
            // Parse beneficiaries data
            if (data['data'] != null && data['data'] is List) {
              final List<dynamic> beneficiaryList = data['data'];
              beneficiaries.assignAll(
                beneficiaryList
                    .map((e) => Map<String, dynamic>.from(e))
                    .toList(),
              );
              dev.log('Loaded ${beneficiaries.length} beneficiaries',
                  name: 'NumberVerification');
            } else {
              dev.log('No beneficiaries found or invalid data format',
                  name: 'NumberVerification');
              Get.snackbar(
                'Info',
                'No beneficiaries found',
                backgroundColor: AppColors.primaryColor,
                colorText: Colors.white,
              );
            }
          } else {
            dev.log('API returned success=0: ${data['message']}',
                name: 'NumberVerification');
            Get.snackbar(
              'Error',
              data['message'] ?? 'Failed to fetch beneficiaries',
              backgroundColor: AppColors.errorBgColor,
              colorText: AppColors.textSnackbarColor,
            );
          }
        },
      );
    } catch (e) {
      dev.log('Error fetching beneficiaries',
          name: 'NumberVerification', error: e);
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
      );
    } finally {
      isLoadingBeneficiaries.value = false;
    }
  }

  void _loadRecentNumbers() {
    try {
      final stored = box.read(_recentNumbersKey);
      if (stored != null) {
        final List<dynamic> decoded = jsonDecode(stored);
        recentNumbers.assignAll(
          decoded.map((e) => Map<String, String>.from(e)).toList(),
        );
        dev.log('Loaded ${recentNumbers.length} recent numbers',
            name: 'NumberVerification');
      }
    } catch (e) {
      dev.log('Error loading recent numbers',
          name: 'NumberVerification', error: e);
    }
  }

  Future<void> _saveRecentNumber(
    String phone,
    String network,
    Map<String, dynamic> networkData, {
    bool isForeign = false,
    String? countryCode,
    String? countryName,
    String? redirectTo,
  }) async {
    try {
      // remove if already exists
      recentNumbers.removeWhere((item) => item['phone'] == phone);

      // add to front with all navigation data
      recentNumbers.insert(0, {
        'phone': phone,
        'network': network,
        'networkData': jsonEncode(networkData),
        'isForeign': isForeign.toString(),
        'countryCode': countryCode ?? (isForeign ? '' : 'NG'),
        'countryName': countryName ?? '',
        'redirectTo': redirectTo ?? '',
      });

      // keep max 10
      if (recentNumbers.length > 10) {
        recentNumbers.removeLast();
      }

      await box.write(_recentNumbersKey, jsonEncode(recentNumbers));
      dev.log('Saved recent number: $phone ($network)',
          name: 'NumberVerification');
    } catch (e) {
      dev.log('Error saving recent number',
          name: 'NumberVerification', error: e);
    }
  }

  void selectRecentNumber(Map<String, String> item) {
    final phone = item['phone'] ?? '';
    final network = item['network'] ?? '';
    final redirectTo = item['redirectTo'] ?? '';

    dev.log('Selected recent number: $phone ($network)',
        name: 'NumberVerification');

    // parse stored network data
    Map<String, dynamic> networkData = {};
    try {
      if (item['networkData'] != null && item['networkData']!.isNotEmpty) {
        networkData = jsonDecode(item['networkData']!);
      }
    } catch (e) {
      networkData = {'operatorName': network};
    }

    final isForeign = item['isForeign'] == 'true';
    final countryCode = item['countryCode'];
    final countryName = item['countryName'];

    // navigate directly since number was already verified
    // prioritize current redirect over stored one
    final destination =
        _redirectTo ?? (redirectTo.isNotEmpty ? redirectTo : null);
    if (destination != null && destination.isNotEmpty) {
      Get.offNamed(destination, arguments: {
        'verifiedNumber': phone,
        'verifiedNetwork': network,
        'networkData': networkData,
        'isForeign': isForeign,
        'countryCode': (countryCode?.isEmpty ?? true)
            ? (isForeign ? null : 'NG')
            : countryCode,
        'countryName': countryName,
      });
    } else {
      // fallback: just fill the input
      phoneController.text = phone;
    }
  }

  void selectBeneficiary(Map<String, dynamic> beneficiary) {
    final phone = beneficiary['phone']?.toString() ?? '';
    final network = beneficiary['network']?.toString() ?? '';

    dev.log('Selected beneficiary: $phone ($network)',
        name: 'NumberVerification');

    final isForeignBeneficiary = _isForeignNetwork(network);

    // prefer api-provided country code, fallback to deriving from network name
    String? derivedCountryCode;
    if (isForeignBeneficiary) {
      derivedCountryCode = beneficiary['country_code']?.toString() ??
          beneficiary['countryCode']?.toString() ??
          _countryCodeFromNetwork(network);
      dev.log(
          'Derived country code for foreign beneficiary: $derivedCountryCode',
          name: 'NumberVerification');
    }

    final networkData = {'operatorName': network};

    if (_redirectTo != null && _redirectTo!.isNotEmpty) {
      Get.offNamed(_redirectTo!, arguments: {
        'verifiedNumber': phone,
        'verifiedNetwork': network,
        'networkData': networkData,
        'isForeign': isForeignBeneficiary,
        'countryCode': isForeignBeneficiary ? derivedCountryCode : 'NG',
      });
    } else {
      phoneController.text = phone;
    }
  }

  // maps network name keywords to ISO country codes used by the foreign airtime API
  String? _countryCodeFromNetwork(String network) {
    final n = network.toUpperCase();
    if (n.contains('UGANDA')) return 'UG';
    if (n.contains('KENYA')) return 'KE';
    if (n.contains('GHANA')) return 'GH';
    if (n.contains('SOUTH AFRICA')) return 'ZA';
    if (n.contains('TANZANIA')) return 'TZ';
    if (n.contains('ZAMBIA')) return 'ZM';
    if (n.contains('RWANDA')) return 'RW';
    if (n.contains('SENEGAL')) return 'SN';
    if (n.contains('COTE') || n.contains('IVORY')) return 'CI';
    if (n.contains('CAMEROON')) return 'CM';
    if (n.contains('BENIN')) return 'BJ';
    if (n.contains('TOGO')) return 'TG';
    if (n.contains('MALI')) return 'ML';
    if (n.contains('NIGER')) return 'NE';
    return null;
  }

  bool _isForeignNetwork(String network) {
    final normalized = network.toUpperCase();
    // Check if network name contains country/foreign indicators
    return normalized.contains('UGANDA') ||
        normalized.contains('KENYA') ||
        normalized.contains('GHANA') ||
        normalized.contains('SOUTH AFRICA') ||
        // Add more foreign indicators
        (!normalized.contains('MTN') &&
            !normalized.contains('AIRTEL') &&
            !normalized.contains('GLO') &&
            !normalized.contains('9MOBILE') &&
            !normalized.contains('ETISALAT')) ||
        // Or if it's MTN/AIRTEL but with country suffix
        (normalized.contains('MTN') && normalized != 'MTN') ||
        (normalized.contains('AIRTEL') && normalized != 'AIRTEL');
  }

  void onPhoneInputChanged(String value) {
    // Only auto-verify if exactly 11 digits (stripping any non-digits) and not foreign
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (!_isForeign && digits.length == 11 && !isLoading.value) {
      dev.log('Auto-verifying: $digits (11 digits reached)',
          name: 'NumberVerification');
      verifyNumber();
    }
  }

  @override
  void onClose() {
    phoneController.dispose();
    super.onClose();
  }

  Future<void> pickContact() async {
    try {
      final permissionStatus = await Permission.contacts.request();

      if (permissionStatus.isGranted) {
        String? number = await contactpicked();

        if (number != null && number.length == 11) {
          phoneController.text = number;
          dev.log('Selected contact number: $number',
              name: 'NumberVerification');
        } else {
          Get.snackbar(
            'Invalid Number',
            'The selected contact does not have a valid Nigerian phone number',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
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
      dev.log('Error picking contact', name: 'NumberVerification', error: e);
      Get.snackbar(
        'Error',
        'Failed to pick contact. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> pasteFromClipboard() async {
    try {
      final clipboardData = await Clipboard.getData('text/plain');
      if (clipboardData != null &&
          clipboardData.text != null &&
          clipboardData.text!.isNotEmpty) {
        String phoneNumber = clipboardData.text!;
        phoneNumber = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');

        if (phoneNumber.startsWith('234')) {
          phoneNumber = '0${phoneNumber.substring(3)}';
        } else if (phoneNumber.startsWith('+234')) {
          phoneNumber = '0${phoneNumber.substring(4)}';
        } else if (!phoneNumber.startsWith('0') && phoneNumber.length == 10) {
          phoneNumber = '0$phoneNumber';
        }

        if (phoneNumber.length == 11) {
          phoneController.text = phoneNumber;
          dev.log('Pasted phone number: $phoneNumber',
              name: 'NumberVerification');
          Get.snackbar(
            'Pasted',
            'Phone number pasted successfully',
            snackPosition: SnackPosition.TOP,
            backgroundColor: AppColors.successBgColor,
            colorText: AppColors.textSnackbarColor,
            duration: const Duration(seconds: 1),
          );
        } else {
          Get.snackbar(
            'Invalid Number',
            'Clipboard does not contain a valid Nigerian phone number',
            snackPosition: SnackPosition.TOP,
            backgroundColor: AppColors.errorBgColor,
            colorText: AppColors.textSnackbarColor,
          );
        }
      } else {
        Get.snackbar(
          'Empty Clipboard',
          'No text found in clipboard',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.errorBgColor,
          colorText: AppColors.textSnackbarColor,
        );
      }
    } catch (e) {
      dev.log('Error pasting from clipboard',
          name: 'NumberVerification', error: e);
      Get.snackbar(
        'Error',
        'Failed to paste from clipboard',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
      );
    }
  }

  Future<void> verifyNumber() async {
    if (formKey.currentState?.validate() ?? false) {
      await _callValidationApi();
    }
  }

  Future<void> _callValidationApi() async {
    isLoading.value = true;
    try {
      final transactionUrl = box.read('transaction_service_url');
      if (transactionUrl == null) {
        Get.snackbar("Error", "Transaction URL not found. Please log in again.",
            backgroundColor: AppColors.errorBgColor,
            colorText: AppColors.textSnackbarColor);
        return;
      }

      if (_isForeign) {
        // For foreign airtime, use the validate endpoint
        await _validateForeignNumber(transactionUrl);
      } else {
        // For Nigerian airtime, use the existing validation
        await _validateNigerianNumber(transactionUrl);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _validateNigerianNumber(String transactionUrl) async {
    final serviceName =
        (_redirectTo?.contains('data') ?? false) ? 'data' : 'airtime';

    final body = {
      "service": serviceName,
      "provider": "Ng",
      "number": phoneController.text,
    };

    dev.log('Validation request body: $body', name: 'NumberVerification');
    final result =
        await apiService.postrequest('$transactionUrl' 'validate-number', body);
    dev.log('Validation request sent to: $transactionUrl' 'validate-number',
        name: 'NumberVerification');

    result.fold(
      (failure) {
        dev.log('Verification Failed: ${failure.message}',
            name: 'NumberVerification');
        Get.snackbar("Verification Failed", failure.message,
            backgroundColor: AppColors.errorBgColor,
            colorText: AppColors.textSnackbarColor);
      },
      (data) {
        dev.log('Verification response: $data', name: 'NumberVerification');
        if (data['success'] == 1) {
          final networkName =
              data['data']?['operatorName'] ?? 'Unknown Network';
          final networkData = data['data'] ?? {};
          dev.log('Network verified: "$networkName" (Full data: $networkData)',
              name: 'NumberVerification');
          _showConfirmationDialog(
              phoneController.text, networkName, networkData);
        } else {
          dev.log("Verification Failed: ${data['message']}",
              name: 'NumberVerification');
          Get.snackbar("Verification Failed",
              data['message'] ?? "Could not verify number.",
              backgroundColor: AppColors.errorBgColor,
              colorText: AppColors.textSnackbarColor);
        }
      },
    );
  }

  Future<void> _validateForeignNumber(String transactionUrl) async {
    final body = {
      "service": "airtime",
      "provider": _countryCode,
      "number": phoneController.text,
    };

    dev.log('Foreign validation request body: $body',
        name: 'NumberVerification');
    final result =
        await apiService.postrequest('${transactionUrl}validate', body);
    dev.log('Foreign validation request sent to: ${transactionUrl}validate',
        name: 'NumberVerification');

    result.fold(
      (failure) {
        dev.log('Foreign verification Failed: ${failure.message}',
            name: 'NumberVerification');
        Get.snackbar("Verification Failed", failure.message,
            backgroundColor: AppColors.errorBgColor,
            colorText: AppColors.textSnackbarColor);
      },
      (data) {
        dev.log('Foreign verification response: $data',
            name: 'NumberVerification');
        if (data['success'] == 1) {
          final networkName = data['data']?['operatorName'] ??
              _countryName ??
              'Unknown Network';
          final networkData = data['data'] ?? {};
          dev.log(
              'Foreign number verified: "$networkName" (Full data: $networkData)',
              name: 'NumberVerification');
          _showConfirmationDialog(
              phoneController.text, networkName, networkData,
              isForeign: true);
        } else {
          dev.log("Foreign verification Failed: ${data['message']}",
              name: 'NumberVerification');
          Get.snackbar("Verification Failed",
              data['message'] ?? "Could not verify number.",
              backgroundColor: AppColors.errorBgColor,
              colorText: AppColors.textSnackbarColor);
        }
      },
    );
  }

  void _showConfirmationDialog(
      String phoneNumber, String networkName, Map<String, dynamic> networkData,
      {bool isForeign = false}) {
    Get.defaultDialog(
        backgroundColor: Colors.white,
        title: '',
        content: Padding(
          padding: const EdgeInsets.only(
              top: 0, left: 24.0, right: 24.0, bottom: 16.0),
          child: Column(
            children: [
              // Gap(20),
              Image.asset('assets/images/mcdagentlogo.png', height: 80),

              Gap(20),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: "Mega Cheap Data detected ",
                  style: const TextStyle(
                    color: AppColors.background,
                    fontFamily: AppFonts.manRope,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  children: [
                    TextSpan(
                      text: phoneNumber,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: AppFonts.manRope),
                    ),
                    const TextSpan(
                      text: " is an ",
                      style: TextStyle(fontFamily: AppFonts.manRope),
                    ),
                    TextSpan(
                      text: networkName,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: AppFonts.manRope),
                    ),
                    const TextSpan(
                      text: " number?",
                      style: TextStyle(fontFamily: AppFonts.manRope),
                    ),
                  ],
                ),
              ),

              Gap(20),
              button('Cancel', AppColors.primaryColor.withOpacity(0.1),
                      AppColors.primaryColor)
                  .onTap(() {
                dev.log('User cancelled confirmation',
                    name: 'NumberVerification');
                Get.back(); // Close dialog
              }),

              Gap(20),
              button('Confirm', AppColors.primaryColor, Colors.white).onTap(() {
                Get.back(); // Close dialog

                // save to recent numbers with all navigation data
                _saveRecentNumber(
                  phoneNumber,
                  networkName,
                  networkData,
                  isForeign: isForeign,
                  countryCode: _countryCode,
                  countryName: _countryName,
                  redirectTo: _redirectTo,
                );

                dev.log(
                    'Number confirmed. Navigating to: $_redirectTo with network: $networkName',
                    name: 'NumberVerification');

                // Use a post frame callback to ensure dialog is fully closed
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_isMultipleAirtimeAdd) {
                    // For multiple airtime, return the verified data instead of navigating
                    dev.log('Returning verified data for multiple airtime add',
                        name: 'NumberVerification');
                    Get.back(result: {
                      'verifiedNumber': phoneNumber,
                      'verifiedNetwork': networkName,
                      'networkData': networkData,
                    });
                  } else if (_redirectTo != null) {
                    // Navigate without disposing this controller immediately
                    // Pass both verified number and network information
                    Get.offNamed(_redirectTo!, arguments: {
                      'verifiedNumber': phoneNumber,
                      'verifiedNetwork': networkName,
                      'networkData': networkData,
                      'isForeign': isForeign,
                      'countryCode': _countryCode,
                      'countryName': _countryName,
                    });
                  } else {
                    Get.snackbar("Success", "Number verified!",
                        backgroundColor: AppColors.successBgColor,
                        colorText: AppColors.textSnackbarColor);
                    Get.back();
                  }
                });
              }),
            ],
          ),
        )
        // title: "Confirm Network",
        // titleStyle: const TextStyle(fontWeight: FontWeight.bold, fontFamily: AppFonts.manRope,),
        // middleText: "Is the number $phoneNumber a $networkName number?",
        // middleTextStyle: const TextStyle(fontFamily: AppFonts.manRope,),
        // textConfirm: "Confirm",
        // textCancel: "Cancel",
        // confirmTextColor: Colors.white,
        // barrierDismissible: false,
        // contentPadding: EdgeInsets.all(20),
        // radius: 12,
        // onConfirm: () {
        //   Get.back(); // Close dialog
        //   dev.log('Number confirmed. Navigating to: $_redirectTo with network: $networkName', name: 'NumberVerification');

        //   // Use a post frame callback to ensure dialog is fully closed
        //   WidgetsBinding.instance.addPostFrameCallback((_) {
        //     if (_redirectTo != null) {
        //       // Navigate without disposing this controller immediately
        //       // Pass both verified number and network information
        //       Get.offNamed(_redirectTo!, arguments: {
        //         'verifiedNumber': phoneNumber,
        //         'verifiedNetwork': networkName,
        //         'networkData': networkData,
        //       });
        //     } else {
        //       Get.snackbar("Success", "Number verified!",
        //           backgroundColor: AppColors.successBgColor, colorText: AppColors.textSnackbarColor);
        //       Get.back();
        //     }
        //   });
        // },
        // onCancel: () {
        //   dev.log('User cancelled confirmation', name: 'NumberVerification');
        // },
        );
  }

  Widget button(String text, Color color, Color textColor) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Center(
          child: TextSemiBold(
        text,
        color: textColor,
      )),
    );
  }
}

extension on Widget {
  Widget onTap(void Function()? param0) {
    return GestureDetector(
      onTap: param0,
      child: this,
    );
  }
}
