import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_paystack_payment_plus/flutter_paystack_payment_plus.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mcd/app/routes/app_pages.dart';
import 'package:mcd/app/styles/app_colors.dart';
import 'package:mcd/core/constants/fonts.dart';
import 'package:mcd/core/controllers/payment_config_controller.dart';
import 'package:mcd/core/network/api_constants.dart';
import 'package:mcd/core/network/dio_api_service.dart';
import 'package:mcd/core/services/general_market_payment_service.dart';
import 'package:mcd/core/utils/amount_formatter.dart';

enum PaymentType {
  airtime,
  data,
  electricity,
  cable,
  airtimePin,
  dataPin,
  ninValidation,
  resultChecker,
  betting,
}

class GeneralPayoutController extends GetxController {
  final apiService = DioApiService();
  final box = GetStorage();
  PaymentConfigController? _paymentConfig;
  final _gmPaymentService = GeneralMarketPaymentService();

  // Paystack plugin
  final plugin = PaystackPayment();

  // Common state
  late final PaymentType paymentType;
  late final Map<String, dynamic> paymentData;

  final selectedPaymentMethod = 1.obs;
  final isPaying = false.obs;
  final walletBalance = '0'.obs;
  final bonusBalance = '0'.obs;
  final pointsBalance = '0'.obs;
  final usePoints = false.obs;
  final promoCodeController = TextEditingController();
  final gmBalance = '0'.obs;

  // Payment method availability
  final paymentMethodStatus = <String, String>{}.obs;
  final paymentMethodDetails = <String, String>{}.obs;
  final isLoadingPaymentMethods = true.obs;

  // Card Input State (Paystack)
  final cardFormKey = GlobalKey<FormState>();
  final cardNumberController = TextEditingController();
  final cardNameController = TextEditingController();
  final expiryMonthController = TextEditingController();
  final expiryYearController = TextEditingController();
  final cvvController = TextEditingController();
  final cardType = ''.obs;
  final isCardLoading = false.obs;
  final cardNumberFocus = FocusNode();
  final expiryMonthFocus = FocusNode();
  final expiryYearFocus = FocusNode();
  final cvvFocus = FocusNode();
  String _currentReference = '';
  String? _currentTxRef;
  int _currentAmount = 0;

  String get txRef {
    _currentTxRef ??= _generateReference();
    return _currentTxRef!;
  }

  // UI Data
  String serviceName = '';
  String serviceImage = '';
  String phoneNumber = '';
  RxList<Map<String, String>> detailsRows = <Map<String, String>>[].obs;

  // Cable-specific
  final isRenewalMode = false.obs;
  final showPackageSelection = false.obs;
  final cablePackages = <dynamic>[].obs;
  final selectedCablePackage = Rxn<dynamic>();
  final isLoadingPackages = false.obs;
  final cableBouquetDetails = <String, String>{}.obs;

  // Airtime-specific
  final isMultipleAirtime = false.obs;
  final multipleAirtimeList = <Map<String, dynamic>>[].obs;

  // paystack 1.5% fee applied on top of transaction amount
  static const double paystackFeeRate = 0.015;

  // exposes base transaction amount for UI fee display
  double get transactionAmount => _getTransactionAmount();

  // Paystack keys (from config or fallback)
  String get paystackPublicKey =>
      box.read('paystack_public_key') ??
      'pk_live_bf9ad0c818ede7986e1f93198a1eb02eef57c7d9';

  @override
  void onInit() {
    super.onInit();
    // initialize paystack plugin
    plugin.initialize(publicKey: paystackPublicKey);

    // add listener for card type detection
    cardNumberController.addListener(_detectCardType);

    // Get payment config controller
    try {
      _paymentConfig = Get.find<PaymentConfigController>();
    } catch (e) {
      dev.log('PaymentConfigController not found, will fetch directly',
          name: 'GeneralPayout');
    }

    final args = Get.arguments as Map<String, dynamic>? ?? {};
    paymentType = args['paymentType'] ?? PaymentType.airtime;
    paymentData = args['paymentData'] ?? {};

    _initializePaymentTypeData();
    _currentTxRef = null; // ensure clean state on init
    fetchBalances();
    fetchGMBalance();
    fetchPaymentMethodAvailability();
  }

  @override
  void onClose() {
    cardNumberController.dispose();
    cardNameController.dispose();
    expiryMonthController.dispose();
    expiryYearController.dispose();
    cvvController.dispose();
    promoCodeController.dispose();
    cardNumberFocus.dispose();
    expiryMonthFocus.dispose();
    expiryYearFocus.dispose();
    cvvFocus.dispose();
    super.onClose();
  }

  // generate reference
  String _generateReference() {
    // final timestamp = DateTime.now().millisecondsSinceEpoch;
    // return 'MCD_$timestamp';

    final username = box.read('biometric_username_real') ?? 'MCD';
    final userPrefix = username.length >= 3
        ? username.substring(0, 3).toUpperCase()
        : username.toUpperCase();
    return 'MCD2_$userPrefix${DateTime.now().microsecondsSinceEpoch}';
  }

  void _initializePaymentTypeData() {
    switch (paymentType) {
      case PaymentType.airtime:
        _initializeAirtimeData();
        break;
      case PaymentType.data:
        _initializeDataData();
        break;
      case PaymentType.electricity:
        _initializeElectricityData();
        break;
      case PaymentType.cable:
        _initializeCableData();
        break;
      case PaymentType.airtimePin:
        _initializeAirtimePinData();
        break;
      case PaymentType.dataPin:
        _initializeDataPinData();
        break;
      case PaymentType.ninValidation:
        _initializeNinValidationData();
        break;
      case PaymentType.resultChecker:
        _initializeResultCheckerData();
        break;
      case PaymentType.betting:
        _initializeBettingData();
        break;
    }
  }

  void _initializeAirtimeData() {
    isMultipleAirtime.value = paymentData['isMultiple'] ?? false;

    if (isMultipleAirtime.value) {
      multipleAirtimeList.value =
          List<Map<String, dynamic>>.from(paymentData['multipleList'] ?? []);
      serviceName = 'Multiple Airtime';
      serviceImage = '';
    } else {
      serviceName =
          paymentData['provider']?.network?.toUpperCase() ?? 'Airtime';
      serviceImage = paymentData['networkImage'] ?? '';
      phoneNumber = paymentData['phoneNumber'] ?? 'N/A';
      detailsRows.value = [
        {
          'label': 'Amount',
          'value':
              '₦${AmountUtil.formatFigure(double.tryParse((paymentData['amount'] ?? '0').toString()) ?? 0)}'
        },
        {'label': 'Phone Number', 'value': phoneNumber},
        {'label': 'Network', 'value': serviceName},
        if (paymentData['offerName'] != null)
          {'label': 'Bonus', 'value': paymentData['offerName'].toString()},
      ];
    }
  }

  void _initializeDataData() {
    serviceName = paymentData['networkProvider']?.name?.toUpperCase() ?? 'Data';
    serviceImage = paymentData['networkImage'] ?? '';
    phoneNumber = paymentData['phoneNumber'] ?? 'N/A';
    detailsRows.value = [
      {'label': 'Plan', 'value': paymentData['dataPlan']?.name ?? 'N/A'},
      {
        'label': 'Amount',
        'value':
            '₦${AmountUtil.formatFigure(double.tryParse((paymentData['dataPlan']?.price ?? '0').toString()) ?? 0)}'
      },
      {'label': 'Phone Number', 'value': phoneNumber},
      {'label': 'Network', 'value': serviceName},
    ];
  }

  void _initializeElectricityData() {
    serviceName = paymentData['provider']?.name ?? 'Electricity';
    serviceImage = paymentData['providerImage'] ?? '';
    phoneNumber = paymentData['meterNumber'] ?? 'N/A';

    // Get validation details
    final validationDetails =
        paymentData['validationDetails'] as Map<String, dynamic>?;

    detailsRows.value = [
      {
        'label': 'Amount',
        'value':
            '₦${AmountUtil.formatFigure(double.tryParse((paymentData['amount']?.toString() ?? '0')) ?? 0)}'
      },
      {'label': 'Biller Name', 'value': serviceName},
      {'label': 'Account Name', 'value': paymentData['customerName'] ?? 'N/A'},
      {'label': 'Account Number', 'value': phoneNumber},
      {
        'label': 'Address',
        'value': validationDetails?['Address']?.toString().trim() ?? 'N/A'
      },
      {
        'label': 'Min Purchase',
        'value': validationDetails?['Min_Purchase_Amount'] != null
            ? '₦${AmountUtil.formatFigure(double.tryParse(validationDetails!['Min_Purchase_Amount'].toString()) ?? 0)}'
            : '₦0.00'
      },
      {
        'label': 'Arrears',
        'value': validationDetails?['Customer_Arrears'] != null
            ? '₦${AmountUtil.formatFigure(double.tryParse(validationDetails!['Customer_Arrears'].toString()) ?? 0)}'
            : '₦0.00'
      },
      {
        'label': 'Account Type',
        'value': validationDetails?['Meter_Type']?.toString().trim() ?? 'N/A'
      },
    ];
  }

  void _initializeCableData() {
    serviceName = paymentData['provider']?.name ?? 'Cable TV';
    serviceImage = paymentData['providerImage'] ?? '';
    phoneNumber = paymentData['smartCardNumber'] ?? 'N/A';
    detailsRows.value = [
      {'label': 'Account Name', 'value': paymentData['customerName'] ?? 'N/A'},
      {'label': 'Biller Name', 'value': serviceName},
      {'label': 'Smartcard Number', 'value': phoneNumber},
    ];

    // Cable bouquet details
    final bouquetDetails =
        paymentData['bouquetDetails'] as Map<String, dynamic>?;
    if (bouquetDetails != null) {
      // Use renewal_amount if current_bouquet_price is empty/null/zero
      final rawPrice =
          bouquetDetails['current_bouquet_price']?.toString() ?? '';
      final renewalAmt = bouquetDetails['renewal_amount']?.toString() ?? '0';
      final bouquetPrice =
          (rawPrice.isEmpty || rawPrice == '0' || rawPrice == 'null')
              ? renewalAmt
              : rawPrice;

      // Format due date from ISO to readable
      String formattedDueDate = 'N/A';
      final rawDueDate = bouquetDetails['due_date'];
      if (rawDueDate != null &&
          rawDueDate.toString().isNotEmpty &&
          rawDueDate != 'N/A') {
        try {
          final dt = DateTime.parse(rawDueDate.toString());
          const months = [
            'Jan',
            'Feb',
            'Mar',
            'Apr',
            'May',
            'Jun',
            'Jul',
            'Aug',
            'Sep',
            'Oct',
            'Nov',
            'Dec'
          ];
          formattedDueDate = '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
        } catch (_) {
          formattedDueDate = rawDueDate.toString();
        }
      }

      cableBouquetDetails.value = {
        'currentBouquet': bouquetDetails['current_bouquet'] ?? 'N/A',
        'bouquetPrice': bouquetPrice,
        'dueDate': formattedDueDate,
        'status': bouquetDetails['status'] ?? 'Unknown',
        'renewalAmount': renewalAmt,
        'currentBouquetCode':
            bouquetDetails['current_bouquet_code'] ?? 'UNKNOWN',
      };
    }

    // If no valid current bouquet info, skip action buttons and go straight to package selection
    if (!hasValidCurrentBouquet) {
      dev.log(
          'No valid current bouquet info, going straight to package selection',
          name: 'GeneralPayout');
      selectNewPackage();
    }
  }

  void _initializeAirtimePinData() {
    serviceName = paymentData['networkName'] ?? 'Airtime PIN';
    serviceImage = paymentData['networkImage'] ?? '';
    detailsRows.value = [
      {'label': 'Network Type', 'value': serviceName},
      {
        'label': 'Amount',
        'value':
            '₦${AmountUtil.formatFigure(double.tryParse((paymentData['amount'] ?? '0').toString()) ?? 0)}'
      },
      {'label': 'Quantity', 'value': paymentData['quantity'] ?? 'N/A'},
      {'label': 'Design Type', 'value': paymentData['designName'] ?? 'N/A'},
    ];
  }

  void _initializeDataPinData() {
    serviceName = paymentData['networkName'] ?? 'Data PIN';
    serviceImage = paymentData['networkImage'] ?? '';
    detailsRows.value = [
      {'label': 'Network Type', 'value': serviceName},
      {
        'label': 'Amount',
        'value':
            '₦${AmountUtil.formatFigure(double.tryParse((paymentData['amount'] ?? '0').toString()) ?? 0)}'
      },
      {'label': 'Quantity', 'value': paymentData['quantity'] ?? 'N/A'},
      {'label': 'Design Type', 'value': paymentData['designType'] ?? 'N/A'},
    ];
  }

  // void _initializeEpinData() {
  //   serviceName = 'E-PIN';
  //   serviceImage = paymentData['serviceImage'] ?? '';
  //   detailsRows.value = [
  //     {'label': 'Service', 'value': paymentData['serviceName'] ?? 'N/A'},
  //     {
  //       'label': 'Amount',
  //       'value':
  //           '₦${AmountUtil.formatFigure(double.tryParse((paymentData['amount'] ?? '0').toString()) ?? 0)}'
  //     },
  //     {'label': 'Quantity', 'value': paymentData['quantity'] ?? 'N/A'},
  //   ];
  // }

  void _initializeNinValidationData() {
    serviceName = 'NIN Validation';
    serviceImage = '';
    detailsRows.value = [
      {'label': 'Service', 'value': 'NIN Validation'},
      {
        'label': 'Amount',
        'value':
            '₦${AmountUtil.formatFigure(double.tryParse((paymentData['amount'] ?? '0').toString()) ?? 0)}'
      },
      {'label': 'NIN', 'value': paymentData['ninNumber'] ?? 'N/A'},
    ];
  }

  void _initializeResultCheckerData() {
    serviceName = paymentData['examName'] ?? 'Result Checker';
    serviceImage = '';
    detailsRows.value = [
      {'label': 'Exam Type', 'value': paymentData['examName'] ?? 'N/A'},
      {
        'label': 'Amount',
        'value':
            '₦${AmountUtil.formatFigure(double.tryParse((paymentData['amount'] ?? '0').toString()) ?? 0)}'
      },
      {'label': 'Quantity', 'value': paymentData['quantity'] ?? 'N/A'},
    ];
  }

  void _initializeBettingData() {
    serviceName = paymentData['providerName'] ?? 'Betting';
    serviceImage = paymentData['providerImage'] ?? '';
    phoneNumber = paymentData['userId'] ?? 'N/A';
    detailsRows.value = [
      {'label': 'Provider', 'value': paymentData['providerName'] ?? 'N/A'},
      {'label': 'User ID', 'value': phoneNumber},
      {'label': 'Customer Name', 'value': paymentData['customerName'] ?? 'N/A'},
      {
        'label': 'Amount',
        'value':
            '₦${AmountUtil.formatFigure(double.tryParse((paymentData['amount'] ?? '0').toString()) ?? 0)}'
      },
    ];
  }

  Future<void> fetchBalances() async {
    try {
      dev.log('Fetching balances...', name: 'GeneralPayout');

      final result =
          await apiService.getrequest('${ApiConstants.authUrlV2}/dashboard');
      result.fold(
        (failure) {
          dev.log('Failed to fetch balances',
              name: 'GeneralPayout', error: failure.message);
        },
        (data) {
          if (data['data'] != null && data['data']['balance'] != null) {
            walletBalance.value =
                data['data']['balance']['wallet']?.toString() ?? '0';
            bonusBalance.value =
                data['data']['balance']['bonus']?.toString() ?? '0';
            pointsBalance.value =
                data['data']['balance']['points']?.toString() ?? '0';
            dev.log('Balances fetched successfully', name: 'GeneralPayout');
          }
        },
      );
    } catch (e) {
      dev.log('Error fetching balances', name: 'GeneralPayout', error: e);
    }
  }

  Future<void> fetchGMBalance() async {
    final transactionUrl = box.read('transaction_service_url');
    if (transactionUrl == null) {
      dev.log('Transaction URL not found',
          name: 'GeneralPayout', error: 'URL missing');
      return;
    }

    final result =
        await apiService.getrequest('${transactionUrl}gmtransactions');

    result.fold(
      (failure) {
        dev.log('GM balance fetch failed: ${failure.message}',
            name: 'GeneralPayout');
      },
      (data) {
        // dev.log('GM balance response: $data', name: 'GeneralPayout');
        if (data['wallet'] != null) {
          gmBalance.value = data['wallet'].toString();
          dev.log('GM balance updated to: ₦${gmBalance.value}',
              name: 'GeneralPayout');
        } else {
          dev.log('Wallet balance not found in response',
              name: 'GeneralPayout');
        }
      },
    );
  }

  Future<void> fetchPaymentMethodAvailability() async {
    try {
      // Use PaymentConfigController if available
      if (_paymentConfig != null) {
        dev.log(
            'Using cached payment method availability from PaymentConfigController',
            name: 'GeneralPayout');

        paymentMethodStatus.value = _paymentConfig!.paymentMethodStatus;
        paymentMethodDetails.value = _paymentConfig!.paymentMethodDetails;

        dev.log('Payment method availability: $paymentMethodStatus',
            name: 'GeneralPayout');

        // If not loaded yet, trigger refresh
        if (paymentMethodStatus.isEmpty) {
          dev.log('Payment methods not loaded, refreshing...',
              name: 'GeneralPayout');
          isLoadingPaymentMethods.value = true;
          await _paymentConfig!.refresh();
          paymentMethodStatus.value = _paymentConfig!.paymentMethodStatus;
          paymentMethodDetails.value = _paymentConfig!.paymentMethodDetails;
          isLoadingPaymentMethods.value = false;
        }
        return;
      }

      // Fallback: Fetch directly if PaymentConfigController not available
      dev.log('Fetching payment method availability directly...',
          name: 'GeneralPayout');
      isLoadingPaymentMethods.value = true;

      final transactionUrl = box.read('transaction_service_url');
      if (transactionUrl == null) {
        dev.log('Transaction URL not found',
            name: 'GeneralPayout', error: 'URL missing');
        isLoadingPaymentMethods.value = false;
        return;
      }

      final result =
          await apiService.getrequest('${transactionUrl}payment-methods');
      result.fold(
        (failure) {
          dev.log('Failed to fetch payment method availability',
              name: 'GeneralPayout', error: failure.message);
          isLoadingPaymentMethods.value = false;
        },
        (data) {
          if (data['success'] == 1 &&
              data['data'] != null &&
              data['data']['status'] != null) {
            final status = data['data']['status'] as Map<String, dynamic>;
            paymentMethodStatus.value =
                status.map((key, value) => MapEntry(key, value.toString()));
            dev.log('Payment method availability: $paymentMethodStatus',
                name: 'GeneralPayout');

            if (data['data']['details'] != null) {
              final details = data['data']['details'] as Map<String, dynamic>;
              paymentMethodDetails.value =
                  details.map((key, value) => MapEntry(key, value.toString()));

              if (details['paystack_public'] != null) {
                box.write('paystack_public_key', details['paystack_public']);
                dev.log(
                    'Paystack public key stored: ${details['paystack_public']}',
                    name: 'GeneralPayout');
              }
            }
          }
          isLoadingPaymentMethods.value = false;
        },
      );
    } catch (e) {
      dev.log('Error fetching payment method availability',
          name: 'GeneralPayout', error: e);
      isLoadingPaymentMethods.value = false;
    }
  }

  bool isPaymentMethodAvailable(String method) {
    final status = paymentMethodStatus[method];
    return status == '1';
  }

  String getPaymentMethodKey() {
    switch (selectedPaymentMethod.value) {
      case 1:
        return 'wallet';
      case 2:
        return 'general_market';
      case 3:
        return 'paystack';
      default:
        return 'wallet';
    }
  }

  String getPaymentMethodDisplayName() {
    switch (selectedPaymentMethod.value) {
      case 1:
        return 'MCD Wallet';
      case 2:
        return 'General Market';
      case 3:
        return 'Paystack';
      default:
        return 'MCD Wallet';
    }
  }

  void selectPaymentMethod(int? value) {
    if (value != null) {
      String methodKey;
      String methodName;

      switch (value) {
        case 1:
          methodKey = 'wallet';
          methodName = 'MCD Wallet';
          break;
        case 2:
          methodKey = 'pay_gm';
          methodName = 'General Market';
          break;
        case 3:
          methodKey = 'paystack';
          methodName = 'Paystack';
          break;
        default:
          return;
      }

      if (!isPaymentMethodAvailable(methodKey)) {
        dev.log('Payment method $methodKey is not available',
            name: 'GeneralPayout');
        Get.snackbar(
          'Unavailable',
          'This payment method is currently not available',
          backgroundColor: AppColors.errorBgColor,
          colorText: AppColors.textSnackbarColor,
        );
        return;
      }

      selectedPaymentMethod.value = value;
      dev.log('Payment method selected: $methodName', name: 'GeneralPayout');
    }
  }

  void toggleUsePoints(bool value) {
    usePoints.value = value;
    dev.log('Use points toggled: $value', name: 'GeneralPayout');
  }

  void clearPromoCode() {
    promoCodeController.clear();
    dev.log('Promo code cleared', name: 'GeneralPayout');
  }

  // Card Payment Methods
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

  Future<void> _showCardInputDialog() async {
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
              key: cardFormKey,
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
                    'Amount: ₦${AmountUtil.formatFigure(_currentAmount.toDouble())}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Fee (1.5%): ₦${AmountUtil.formatFigure(_currentAmount * paystackFeeRate)}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Total: ₦${AmountUtil.formatFigure(_currentAmount * (1 + paystackFeeRate))}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
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
                    focusNode: cardNumberFocus,
                    onChanged: (value) {
                      if (value.replaceAll(' ', '').length >= 16) {
                        expiryMonthFocus.requestFocus();
                      }
                    },
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
                              focusNode: expiryMonthFocus,
                              onChanged: (value) {
                                if (value.length >= 2) {
                                  expiryYearFocus.requestFocus();
                                }
                              },
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
                              focusNode: expiryYearFocus,
                              onChanged: (value) {
                                if (value.length >= 2) {
                                  cvvFocus.requestFocus();
                                }
                              },
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
                              focusNode: cvvFocus,
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
                              isCardLoading.value ? null : () => _chargeCard(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: isCardLoading.value
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

  Future<void> _chargeCard() async {
    if (!cardFormKey.currentState!.validate()) {
      dev.log(
          'Paystack payment validation failed: Invalid card details entered',
          name: 'GeneralPayout');
      return;
    }

    try {
      isCardLoading.value = true;

      final userEmail = box.read('user_email') ?? 'user@mcd.com';
      dev.log('Initiating Paystack payment...', name: 'GeneralPayout');
      dev.log('User Email: $userEmail', name: 'GeneralPayout');
      dev.log('Reference: $_currentReference', name: 'GeneralPayout');
      dev.log('Amount (Kobo): ${_currentAmount * 100}', name: 'GeneralPayout');

      Charge charge = Charge();
      charge.card = _getCardFromUI();
      // apply 1.5% paystack fee on top of base amount
      final amountWithFee =
          (_currentAmount * (1 + paystackFeeRate) * 100).round();
      charge.amount = amountWithFee; // in kobo
      dev.log(
          'Paystack charge: base=₦$_currentAmount fee=₦${(_currentAmount * paystackFeeRate).toStringAsFixed(2)} total=₦${(_currentAmount * (1 + paystackFeeRate)).toStringAsFixed(2)}',
          name: 'GeneralPayout');
      charge.email = userEmail;
      charge.reference = _currentReference;
      charge.putCustomField('Charged From', 'MCD App');

      // Re-initialize plugin to ensure we have the latest key from storage
      // This handles cases where onInit ran before the key was fetched/updated
      // final currentKey = paystackPublicKey;
      // dev.log(
      //     'Re-initializing Paystack with key: ${currentKey.substring(0, 5)}...${currentKey.substring(currentKey.length - 4)}',
      //     name: 'GeneralPayout');
      // await plugin.initialize(publicKey: currentKey);

      // dev.log(
      //     'Card Expiry: ${charge.card!.expiryMonth}/${charge.card!.expiryYear}',
      //     name: 'GeneralPayout');
      dev.log('Invoking Paystack plugin.chargeCard...', name: 'GeneralPayout');

      final context = Get.context!;
      
      // Close the card input dialog so it doesn't block Paystack's OTP/3DS window
      Get.back();
      
      // show "Verifying" overlay so user knows we are still processing after OTP
      Get.dialog(
        const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.white),
              SizedBox(height: 16),
              Text(
                'Verifying Transaction...',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                  fontFamily: AppFonts.manRope,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
        barrierDismissible: false,
      );
      
      final response = await plugin.chargeCard(context, charge: charge);
      
      // close the "Verifying" overlay
      if (Get.isDialogOpen ?? false) Get.back();

      dev.log('Paystack Response Received:', name: 'GeneralPayout');
      dev.log('Status: ${response.status}', name: 'GeneralPayout');
      dev.log('Message: ${response.message}', name: 'GeneralPayout');
      dev.log('Reference: ${response.reference}', name: 'GeneralPayout');
      dev.log('Verify: ${response.verify}', name: 'GeneralPayout');

      if (response.status == true) {
        dev.log('Payment Successful. Processing post-payment actions...',
            name: 'GeneralPayout');
        // payment successful
        isCardLoading.value = false;
        _currentTxRef = null; // clear reference on success
        Get.back(); // close dialog

        Get.snackbar(
          'Payment Successful',
          'Transaction completed successfully.',
          backgroundColor: AppColors.successBgColor,
          colorText: AppColors.textSnackbarColor,
          duration: const Duration(seconds: 4),
        );

        dev.log('Navigating to receipt...', name: 'GeneralPayout');
        // Navigate to receipt
        _navigateToReceipt(_currentReference, _currentAmount.toDouble(), {
          'message': response.message,
          'status': response.status,
          'reference': _currentReference
        });
      } else {
        dev.log('Payment Failed or Cancelled. Reason: ${response.message}',
            name: 'GeneralPayout');
        isCardLoading.value = false;
        Get.snackbar(
          'Payment Failed',
          response.message,
          backgroundColor: AppColors.errorBgColor,
          colorText: AppColors.textSnackbarColor,
        );
      }
    } catch (e, stackTrace) {
      isCardLoading.value = false;
      dev.log('CRITICAL ERROR in _chargeCard:',
          name: 'GeneralPayout', error: e, stackTrace: stackTrace);
      Get.snackbar(
        'Error',
        'Failed to process payment',
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
      );
    }
  }

  // Whether we have valid current bouquet info for renewal
  bool get hasValidCurrentBouquet {
    final bouquet = cableBouquetDetails['currentBouquet'] ?? '';
    final code = cableBouquetDetails['currentBouquetCode'] ?? 'UNKNOWN';
    return bouquet.isNotEmpty && bouquet != 'N/A' && code != 'UNKNOWN';
  }

  // Whether the bouquet info card should be visible
  // Show when: valid current bouquet exists, OR user has selected a package, OR in renewal mode
  bool get shouldShowBouquetCard {
    return hasValidCurrentBouquet ||
        selectedCablePackage.value != null ||
        isRenewalMode.value;
  }

  // Whether the user has chosen renewal or change bouquet
  bool get cableHasSelectedOption =>
      isRenewalMode.value || showPackageSelection.value;

  // Cable-specific methods
  void selectRenewal() {
    isRenewalMode.value = true;
    showPackageSelection.value = false;
    selectedCablePackage.value = null;

    // Update bouquet card to show renewal info
    final renewalAmount = cableBouquetDetails['renewalAmount'] ?? '0';
    cableBouquetDetails['bouquetPrice'] = renewalAmount;
    cableBouquetDetails.refresh();

    dev.log('Renewal mode selected, price: ₦$renewalAmount',
        name: 'GeneralPayout');
  }

  void selectNewPackage() {
    showPackageSelection.value = true;
    isRenewalMode.value = false;
    selectedCablePackage.value = null;
    fetchCablePackages();
    dev.log('New package selection mode', name: 'GeneralPayout');
  }

  void onCablePackageSelected(dynamic package) {
    selectedCablePackage.value = package;
    final name = package['name']?.toString() ?? 'N/A';
    var amount = package['amount']?.toString() ?? '';

    // If amount is empty/null, try to extract from name (e.g. "DStv Premium N44,500")
    if (amount.isEmpty || amount == 'null') {
      final priceMatch = RegExp(r'[N₦]([\d,]+)').firstMatch(name);
      if (priceMatch != null) {
        amount = priceMatch.group(1)?.replaceAll(',', '') ?? '0';
      }
    }

    // Update bouquet card to reflect the newly selected package
    cableBouquetDetails['currentBouquet'] = name;
    cableBouquetDetails['bouquetPrice'] = amount;
    cableBouquetDetails.refresh();

    dev.log('Cable package selected: $name - ₦$amount', name: 'GeneralPayout');
  }

  Future<void> fetchCablePackages() async {
    try {
      isLoadingPackages.value = true;
      final providerCode = paymentData['provider']?.code;
      if (providerCode == null) return;

      final transactionUrl = box.read('transaction_service_url');
      final url = '$transactionUrl' 'tv/$providerCode';

      final result = await apiService.getrequest(url);
      result.fold(
        (failure) {
          dev.log('Failed to fetch packages',
              name: 'GeneralPayout', error: failure.message);
        },
        (data) {
          cablePackages.value = List.from(data['data'] ?? []);
          dev.log('Loaded ${cablePackages.length} packages',
              name: 'GeneralPayout');
        },
      );
    } finally {
      isLoadingPackages.value = false;
    }
  }

  void confirmAndPay() async {
    if (isPaying.value) {
      dev.log('Payment already in progress, ignoring click',
          name: 'GeneralPayout');
      return;
    }

    isPaying.value = true;
    dev.log('Confirming payment for ${paymentType.name}',
        name: 'GeneralPayout');

    try {
      // Check if General Market payment is selected
      if (selectedPaymentMethod.value == 2) {
        await _handleGeneralMarketPayment();
        return;
      }

      // Process other payment methods
      switch (paymentType) {
        case PaymentType.airtime:
          await _processAirtimePayment();
          break;
        case PaymentType.data:
          await _processDataPayment();
          break;
        case PaymentType.electricity:
          await _processElectricityPayment();
          break;
        case PaymentType.cable:
          await _processCablePayment();
          break;
        case PaymentType.airtimePin:
          await _processAirtimePinPayment();
          break;
        case PaymentType.dataPin:
          await _processDataPinPayment();
          break;
        case PaymentType.ninValidation:
          await _processNinValidationPayment();
          break;
        case PaymentType.resultChecker:
          await _processResultCheckerPayment();
          break;
        case PaymentType.betting:
          await _processBettingPayment();
          break;
      }
    } catch (e) {
      dev.log("Payment Error", name: 'GeneralPayout', error: e);
      Get.snackbar(
        "Payment Error",
        "An unexpected error occurred.",
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
      );
    } finally {
      isPaying.value = false;
    }
  }

  Future<void> _handleGeneralMarketPayment() async {
    dev.log('Starting General Market payment flow', name: 'GeneralPayout');

    final amount = _getTransactionAmount();
    final currentGMBalance = double.tryParse(gmBalance.value) ?? 0.0;

    dev.log('GM Balance: ₦$currentGMBalance, Amount: ₦$amount',
        name: 'GeneralPayout');

    final success = await _gmPaymentService.processGeneralMarketPayment(
      amount: amount,
      currentGMBalance: currentGMBalance,
      onPaymentSuccess: () async {
        dev.log('GM ads completed, processing actual transaction',
            name: 'GeneralPayout');
        // After ads are watched, process the actual payment
        await _processActualTransaction();
      },
      onPaymentFailed: (errorMessage) {
        dev.log('GM payment failed: $errorMessage', name: 'GeneralPayout');
        isPaying.value = false;
        
        if (errorMessage.contains('already in progress')) {
          Get.snackbar(
            'Payment Stuck?',
            errorMessage,
            backgroundColor: AppColors.errorBgColor,
            colorText: AppColors.textSnackbarColor,
            duration: const Duration(seconds: 5),
            mainButton: TextButton(
              onPressed: () {
                GeneralMarketPaymentService().forceCancelPayment();
                Get.back(); // close snackbar
                Get.snackbar(
                  'Reset Successful', 
                  'State cleared. You can try your payment again.', 
                  backgroundColor: AppColors.successBgColor, 
                  colorText: AppColors.textSnackbarColor
                );
              },
              child: const Text('FORCE CANCEL', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          );
        } else {
          Get.snackbar(
            'Payment Failed',
            errorMessage,
            backgroundColor: AppColors.errorBgColor,
            colorText: AppColors.textSnackbarColor,
          );
        }
      },
    );

    if (!success) {
      isPaying.value = false;
    }
  }

  double _getTransactionAmount() {
    if (isMultipleAirtime.value) {
      return multipleAirtimeList.fold<double>(
          0, (sum, item) => sum + double.parse(item['amount']));
    }
    // cable amount comes from bouquet details, not paymentData['amount']
    if (paymentType == PaymentType.cable) {
      return double.tryParse(
              cableBouquetDetails['bouquetPrice']?.toString() ?? '0') ??
          0.0;
    }
    return double.tryParse(paymentData['amount']?.toString() ?? '0') ?? 0.0;
  }

  Future<void> _processActualTransaction() async {
    try {
      dev.log('Processing transaction with GM payment', name: 'GeneralPayout');

      // Process based on payment type
      switch (paymentType) {
        case PaymentType.airtime:
          await _processAirtimePayment();
          break;
        case PaymentType.data:
          await _processDataPayment();
          break;
        case PaymentType.electricity:
          await _processElectricityPayment();
          break;
        case PaymentType.cable:
          await _processCablePayment();
          break;
        case PaymentType.airtimePin:
          await _processAirtimePinPayment();
          break;
        case PaymentType.dataPin:
          await _processDataPinPayment();
          break;
        case PaymentType.ninValidation:
          await _processNinValidationPayment();
          break;
        case PaymentType.resultChecker:
          await _processResultCheckerPayment();
          break;
        case PaymentType.betting:
          await _processBettingPayment();
          break;
      }

      // Refresh GM balance after successful transaction
      dev.log('Transaction complete, refreshing GM balance',
          name: 'GeneralPayout');
      await fetchGMBalance();
    } catch (e) {
      dev.log('Transaction processing error', name: 'GeneralPayout', error: e);
      isPaying.value = false;
      Get.snackbar(
        'Transaction Failed',
        'An error occurred while processing your transaction',
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
      );
    }
  }

  Future<void> _performHandshake({
    required String endpoint,
    required Map<String, dynamic> body,
    required double amount,
    required String localRef,
    String? successMessage,
    Future<void> Function(Map<String, dynamic> data)? onServiceSuccess,
  }) async {
    final transactionUrl = box.read('transaction_service_url');
    if (transactionUrl == null) {
      Get.snackbar("Error", "Transaction URL not found.",
          backgroundColor: AppColors.errorBgColor,
          colorText: AppColors.textSnackbarColor);
      return;
    }

    dev.log('Sending handshake to $transactionUrl$endpoint',
        name: 'GeneralPayout');
    dev.log('Payload: $body', name: 'GeneralPayout');

    final result =
        await apiService.postrequest('$transactionUrl$endpoint', body);

    await result.fold(
      (failure) async {
        dev.log('Handshake failed: $endpoint',
            name: 'GeneralPayout', error: failure.message);
        Get.snackbar("Payment Failed", failure.message,
            backgroundColor: AppColors.errorBgColor,
            colorText: AppColors.textSnackbarColor);
      },
      (data) async {
        dev.log('Handshake response: $data', name: 'GeneralPayout');

        if (getPaymentMethodKey() == 'paystack') {
          if (data['success'] == 1 || data['success'] == true) {
            dev.log('Handshake successful. Proceeding to Paystack charge.',
                name: 'GeneralPayout');
            _currentReference = localRef;
            _currentAmount = amount.toInt();
            await _showCardInputDialog();
          } else {
            dev.log('Handshake returned failure: ${data['message']}',
                name: 'GeneralPayout');
            Get.snackbar(
                "Payment Failed", data['message'] ?? "Handshake failed",
                backgroundColor: AppColors.errorBgColor,
                colorText: AppColors.textSnackbarColor);
          }
        } else {
          if (onServiceSuccess != null) {
            await onServiceSuccess(data);
          } else {
            _handleServicePaymentResponse(
              data,
              amount,
              successMessage: successMessage,
              localRef: localRef,
            );
          }
        }
      },
    );
  }

  Future<void> _processAirtimePayment() async {
    final transactionUrl = box.read('transaction_service_url');
    if (transactionUrl == null) return;

    if (isMultipleAirtime.value) {
      await _processMultipleAirtime(transactionUrl);
    } else {
      await _processSingleAirtime(transactionUrl);
    }
  }

  Future<void> _processSingleAirtime(String transactionUrl) async {
    final ref = txRef;
    final provider = paymentData['provider'];
    final phoneNumber = paymentData['phoneNumber'];
    final amount = paymentData['amount'];

    final body = {
      "provider": provider?.network?.toUpperCase() ?? '',
      "amount": amount.toString(),
      "number": phoneNumber,
      "country": paymentData['countryCode'] ?? "NG",
      "payment": getPaymentMethodKey(),
      "promo": promoCodeController.text.trim().isEmpty
          ? "0"
          : promoCodeController.text.trim(),
      "ref": ref,
      "operatorID": int.tryParse(provider?.server ?? '0') ?? 0,
      if (paymentData['bonus'] != null)
        "bonus": paymentData['bonus'].toString(),
    };

    await _performHandshake(
      endpoint: 'airtime',
      body: body,
      amount: double.tryParse(amount.toString()) ?? 0.0,
      localRef: ref,
      successMessage: "Airtime purchase successful!",
    );
  }

  Future<void> _processMultipleAirtime(String transactionUrl) async {
    if (multipleAirtimeList.isEmpty) {
      Get.snackbar("Error", "No numbers to process.",
          backgroundColor: AppColors.errorBgColor,
          colorText: AppColors.textSnackbarColor);
      return;
    }

    final ref = txRef;
    final dataArray = multipleAirtimeList.map((item) {
      final provider = item['provider'];
      final phoneNumber = item['phoneNumber'];
      final amount = item['amount'];

      return {
        "provider": provider?.network?.toUpperCase() ?? '',
        "amount": amount.toString(),
        "number": phoneNumber,
        "operatorID": int.tryParse(provider?.server ?? '0') ?? 0,
      };
    }).toList();

    final body = {
      "country": paymentData['countryCode'] ?? "NG",
      "payment": getPaymentMethodKey(),
      "promo": promoCodeController.text.trim().isEmpty
          ? "0"
          : promoCodeController.text.trim(),
      "ref": ref,
      "number": multipleAirtimeList.length.toString(),
      if (paymentData['bonus'] != null)
        "bonus": paymentData['bonus'].toString(),
      "data": dataArray,
    };

    final totalAmount = multipleAirtimeList.fold<double>(
        0, (sum, item) => sum + double.parse(item['amount'].toString()));

    await _performHandshake(
      endpoint: 'airtime-multiple',
      body: body,
      amount: totalAmount,
      localRef: ref,
      onServiceSuccess: (data) async {
        if (data['success'] == 1) {
          Get.snackbar(
            "Success",
            data['message'] ??
                "${multipleAirtimeList.length} airtime purchase(s) completed successfully!",
            backgroundColor: AppColors.successBgColor,
            colorText: AppColors.textSnackbarColor,
            duration: const Duration(seconds: 4),
          );
          Future.delayed(const Duration(seconds: 2), () {
            Get.offAllNamed(Routes.HOME_SCREEN);
          });
        } else {
          Get.snackbar(
              "Payment Failed", data['message'] ?? "An unknown error occurred.",
              backgroundColor: AppColors.errorBgColor,
              colorText: AppColors.textSnackbarColor);
        }
      },
    );
  }

  Future<void> _processDataPayment() async {
    final ref = txRef;
    // final networkProvider = paymentData['networkProvider'];
    final dataPlan = paymentData['dataPlan'];
    final phoneNumber = paymentData['phoneNumber'];
    final isForeign = paymentData['isForeign'] == true;

    final Map<String, dynamic> body = isForeign
        ? {
            "name": dataPlan?.name ?? '',
            "coded": dataPlan?.operatorId?.toString() ?? '',
            "amount": dataPlan?.price ?? '',
            "number": phoneNumber,
            "payment": getPaymentMethodKey(),
            "promo": promoCodeController.text.trim().isEmpty
                ? "0"
                : promoCodeController.text.trim(),
            "ref": ref,
            "country": paymentData['countryCode'] ?? "NG"
          }
        : {
            "coded": dataPlan?.coded ?? '',
            "number": phoneNumber,
            "payment": getPaymentMethodKey(),
            "promo": promoCodeController.text.trim().isEmpty
                ? "0"
                : promoCodeController.text.trim(),
            "ref": ref,
            "country": "NG"
          };

    final amount = double.tryParse((dataPlan?.price ?? '0').toString()) ?? 0.0;

    await _performHandshake(
      endpoint: 'data',
      body: body,
      amount: amount,
      localRef: ref,
      successMessage: "Data purchase successful!",
    );
  }

  Future<void> _processElectricityPayment() async {
    final ref = txRef;
    final provider = paymentData['provider'];
    final meterNumber = paymentData['meterNumber'];
    final amount = paymentData['amount'];

    final body = {
      "provider": provider?.code?.toLowerCase() ?? '',
      "number": meterNumber,
      "amount": amount?.toString() ?? '',
      "payment": getPaymentMethodKey(),
      "promo": promoCodeController.text.trim().isEmpty
          ? "0"
          : promoCodeController.text.trim(),
      "ref": ref,
    };

    final amountDouble = double.tryParse((amount ?? '0').toString()) ?? 0.0;

    await _performHandshake(
      endpoint: 'electricity',
      body: body,
      amount: amountDouble,
      localRef: ref,
      successMessage: "Electricity payment successful!",
    );
  }

  Future<void> _processCablePayment() async {
    if (isRenewalMode.value) {
      final currentBouquetCode =
          cableBouquetDetails['currentBouquetCode'] ?? 'UNKNOWN';
      if (currentBouquetCode == 'UNKNOWN') {
        Get.snackbar("Error", "Cannot renew. Invalid bouquet information.",
            backgroundColor: AppColors.errorBgColor,
            colorText: AppColors.textSnackbarColor);
        return;
      }
    } else if (!showPackageSelection.value ||
        selectedCablePackage.value == null) {
      Get.snackbar("Error", "Please select a package.",
          backgroundColor: AppColors.errorBgColor,
          colorText: AppColors.textSnackbarColor);
      return;
    }

    final ref = txRef;
    final smartCardNumber = paymentData['smartCardNumber'];

    String packageCode;
    String packageAmount;

    if (isRenewalMode.value) {
      packageCode = cableBouquetDetails['currentBouquetCode'] ?? 'UNKNOWN';
      packageAmount = cableBouquetDetails['renewalAmount'] ?? '0';
    } else {
      packageCode = selectedCablePackage.value?['code'] ??
          selectedCablePackage.value?['coded'] ??
          '';
      packageAmount = cableBouquetDetails['bouquetPrice'] ??
          selectedCablePackage.value?['amount']?.toString() ??
          '0';
    }

    final body = {
      "coded": packageCode,
      "number": smartCardNumber,
      "payment": getPaymentMethodKey(),
      "promo": promoCodeController.text.trim().isEmpty
          ? "0"
          : promoCodeController.text.trim(),
      "ref": ref,
    };

    final amount = double.tryParse((packageAmount).toString()) ?? 0.0;

    await _performHandshake(
      endpoint: 'tv',
      body: body,
      amount: amount,
      localRef: ref,
      successMessage: "Cable subscription successful!",
    );
  }

  Future<void> _processAirtimePinPayment() async {
    final ref = txRef;
    final body = {
      'provider': paymentData['networkCode']?.toUpperCase() ?? '',
      'amount': paymentData['amount'] ?? '',
      'quantity': paymentData['quantity'] ?? '1',
      'payment': getPaymentMethodKey(),
      'promo':
          promoCodeController.text.isNotEmpty ? promoCodeController.text : '0',
      'ref': ref,
      'number': '09031945519'
    };

    double amount =
        double.tryParse((paymentData['amount'] ?? '0').toString()) ?? 0;
    int quantity =
        int.tryParse((paymentData['quantity'] ?? '1').toString()) ?? 1;
    double totalAmount = amount * quantity;

    await _performHandshake(
      endpoint: 'airtimepin',
      body: body,
      amount: totalAmount,
      localRef: ref,
      onServiceSuccess: (data) async {
        if (data['success'] == 1) {
          final transactionId = data['ref'] ?? data['trnx_id'] ?? ref;
          final token = data['token'] ?? 'N/A';
          final formattedDate = DateTime.now()
              .toIso8601String()
              .substring(0, 19)
              .replaceAll('T', ' ');

          Get.snackbar(
              "Success", data['message'] ?? "Airtime Pin purchase successful!",
              backgroundColor: AppColors.successBgColor,
              colorText: AppColors.textSnackbarColor);

          final _designId = paymentData['designId'] ?? 1;
          final _networkCode = paymentData['networkCode'] ?? 'MTN';
          box.write('epin_design_$transactionId', _designId);
          box.write('epin_network_$transactionId', _networkCode);

          Get.offNamed(
            Routes.TRANSACTION_DETAIL_MODULE,
            arguments: {
              'name': 'Airtime Pin (${paymentData['networkName'] ?? 'N/A'})',
              'amount': paymentData['amount'] ?? '',
              'phoneNumber': 'N/A',
              'packageName': 'Quantity: ${paymentData['quantity'] ?? '1'}',
              'paymentMethod': getPaymentMethodDisplayName(),
              'transactionId': transactionId,
              'date': formattedDate,
              'token': token,
              'paymentType': 'airtime_pin',
              'serverResponse': data,
              'designId': paymentData['designId'] ?? 1,
              'networkCode': paymentData['networkCode'] ?? 'MTN',
            },
          );
        } else {
          Get.snackbar(
              "Payment Failed",
              data['message'] ??
                  "Airtime Pin purchase failed. Please try again.",
              backgroundColor: AppColors.errorBgColor,
              colorText: AppColors.textSnackbarColor);
        }
      },
    );
  }

  Future<void> _processDataPinPayment() async {
    final ref = txRef;
    final body = {
      "coded": paymentData['coded'] ?? '',
      "payment": getPaymentMethodKey(),
      "promo":
          promoCodeController.text.isEmpty ? "0" : promoCodeController.text,
      "ref": ref,
      "country": "NG",
      "quantity": paymentData['quantity'] ?? '1',
    };

    double amount =
        double.tryParse((paymentData['amount'] ?? '0').toString()) ?? 0;
    int quantity =
        int.tryParse((paymentData['quantity'] ?? '1').toString()) ?? 1;
    double totalAmount = amount * quantity;

    await _performHandshake(
      endpoint: 'datapin',
      body: body,
      amount: totalAmount,
      localRef: ref,
      onServiceSuccess: (data) async {
        if (data['success'] == 1 || data['success'] == true) {
          final transactionId = data['ref'] ?? data['trnx_id'] ?? ref;
          final token = data['token'] ?? 'N/A';
          final formattedDate = DateTime.now()
              .toIso8601String()
              .substring(0, 19)
              .replaceAll('T', ' ');

          Get.snackbar(
              "Success", data['message'] ?? "Data Pin purchase successful!",
              backgroundColor: AppColors.successBgColor,
              colorText: AppColors.textSnackbarColor);

          final _designId = paymentData['designId'] ?? 1;
          final _networkCode = paymentData['networkCode'] ?? 'MTN';
          box.write('epin_design_$transactionId', _designId);
          box.write('epin_network_$transactionId', _networkCode);

          Get.offNamed(
            Routes.TRANSACTION_DETAIL_MODULE,
            arguments: {
              'name': 'Data Pin (${paymentData['networkName'] ?? 'N/A'})',
              'amount': paymentData['amount'] ?? '',
              'phoneNumber': 'N/A',
              'packageName': 'Quantity: ${paymentData['quantity'] ?? '1'}',
              'paymentMethod': getPaymentMethodDisplayName(),
              'transactionId': transactionId,
              'date': formattedDate,
              'token': token,
              'paymentType': 'data_pin',
              'serverResponse': data,
              'designId': paymentData['designId'] ?? 1,
              'networkCode': paymentData['networkCode'] ?? 'MTN',
            },
          );
        } else {
          Get.snackbar(
              "Payment Failed", data['message'] ?? "An unknown error occurred.",
              backgroundColor: AppColors.errorBgColor,
              colorText: AppColors.textSnackbarColor);
        }
      },
    );
  }

  Future<void> _processBettingPayment() async {
    final ref = txRef;
    final body = {
      "provider": paymentData['providerCode']?.toUpperCase() ?? '',
      "number": paymentData['userId'] ?? '',
      "amount": paymentData['amount']?.toString() ?? '0',
      "payment": getPaymentMethodKey(),
      "promo": promoCodeController.text.trim().isEmpty
          ? "0"
          : promoCodeController.text.trim(),
      "ref": ref,
    };

    final amount =
        double.tryParse((paymentData['amount'] ?? '0').toString()) ?? 0.0;

    await _performHandshake(
      endpoint: 'betting',
      body: body,
      amount: amount,
      localRef: ref,
      successMessage: "Betting deposit successful!",
    );
  }

  // Future<void> _processEpinPayment() async {
  //   final ref = txRef;
  //   final body = {
  //     "provider": paymentData['networkCode']?.toUpperCase() ?? '',
  //     "amount": paymentData['amount'] ?? '',
  //     "number": paymentData['recipient'] ?? '',
  //     "quantity": paymentData['quantity'] ?? '',
  //     "payment": getPaymentMethodKey(),
  //     "promo":
  //         promoCodeController.text.isEmpty ? "0" : promoCodeController.text,
  //     "ref": ref,
  //   };
  //   double amount =
  //       double.tryParse((paymentData['amount'] ?? '0').toString()) ?? 0;
  //   int quantity =
  //       int.tryParse((paymentData['quantity'] ?? '1').toString()) ?? 1;
  //   double totalAmount = amount * quantity;
  //   await _performHandshake(
  //     endpoint: 'airtimepin',
  //     body: body,
  //     amount: totalAmount,
  //     localRef: ref,
  //     onServiceSuccess: (data) async {
  //       if (data['success'] == 1 || data['success'] == true) {
  //         final transactionId = data['ref'] ?? data['trnx_id'] ?? ref;
  //         final token = data['token'] ?? 'N/A';
  //         final formattedDate = DateTime.now()
  //             .toIso8601String()
  //             .substring(0, 19)
  //             .replaceAll('T', ' ');
  //         Get.snackbar(
  //             "Success", data['message'] ?? "E-pin purchase successful!",
  //             backgroundColor: AppColors.successBgColor,
  //             colorText: AppColors.textSnackbarColor);
  //         Get.offNamed(
  //           Routes.EPIN_TRANSACTION_DETAIL,
  //           arguments: {
  //             'networkName': paymentData['networkName'] ?? '',
  //             'networkImage': paymentData['networkImage'] ?? '',
  //             'amount': paymentData['amount'] ?? '',
  //             'designType': paymentData['designType'] ?? 'Standard',
  //             'quantity': paymentData['quantity'] ?? '1',
  //             'paymentMethod': getPaymentMethodDisplayName(),
  //             'transactionId': transactionId,
  //             'postedDate': formattedDate,
  //             'transactionDate': formattedDate,
  //             'token': token,
  //           },
  //         );
  //       } else {
  //         Get.snackbar(
  //             "Payment Failed", data['message'] ?? "An unknown error occurred.",
  //             backgroundColor: AppColors.errorBgColor,
  //             colorText: AppColors.textSnackbarColor);
  //       }
  //     },
  //   );
  // }

  Future<void> _processNinValidationPayment() async {
    final ref = txRef;
    final body = {
      "number": paymentData['ninNumber'] ?? '',
      "ref": ref,
      "payment": getPaymentMethodKey(),
      "promo":
          promoCodeController.text.isEmpty ? "0" : promoCodeController.text,
    };

    final amount =
        double.tryParse((paymentData['amount'] ?? '0').toString()) ?? 0.0;

    await _performHandshake(
      endpoint: 'ninvalidation',
      body: body,
      amount: amount,
      localRef: ref,
      onServiceSuccess: (data) async {
        if (data['success'] == 1 || data['success'] == true) {
          final transactionId = data['data']?['transaction_id'] ?? ref;
          Get.snackbar(
              "Success",
              data['message'] ??
                  "NIN validation request submitted successfully!",
              backgroundColor: AppColors.successBgColor,
              colorText: AppColors.textSnackbarColor);

          _navigateToReceipt(transactionId.toString(), amount, data);
        } else {
          Get.snackbar("Payment Failed",
              data['message'] ?? "An unknown error occurred.",
              backgroundColor: AppColors.errorBgColor,
              colorText: AppColors.textSnackbarColor);
        }
      },
    );
  }

  Future<void> _processResultCheckerPayment() async {
    final ref = txRef;
    final body = {
      "coded": paymentData['examCode']?.toUpperCase() ?? '',
      "quantity": paymentData['quantity'] ?? '1',
      "ref": ref,
      "number": "0",
      "payment": getPaymentMethodKey(),
      "promo":
          promoCodeController.text.isEmpty ? "0" : promoCodeController.text,
    };

    final amount =
        double.tryParse((paymentData['amount'] ?? '0').toString()) ?? 0.0;

    await _performHandshake(
      endpoint: 'resultchecker',
      body: body,
      amount: amount,
      localRef: ref,
      onServiceSuccess: (data) async {
        if (data['success'] == 1 || data['success'] == true) {
          final transactionId = data['data']?['transaction_id'] ?? ref;
          Get.snackbar(
              "Success",
              data['message'] ??
                  "Result Checker purchase successful! Check your email.",
              backgroundColor: AppColors.successBgColor,
              colorText: AppColors.textSnackbarColor);
          _navigateToReceipt(transactionId.toString(), amount, data);
        } else {
          Get.snackbar("Payment Failed",
              data['message'] ?? "An unknown error occurred.",
              backgroundColor: AppColors.errorBgColor,
              colorText: AppColors.textSnackbarColor);
        }
      },
    );
  }

  void _handleServicePaymentResponse(
    Map<String, dynamic> data,
    double amount, {
    String? successMessage,
    String? localRef,
  }) {

    final isPaystack = getPaymentMethodKey() == 'paystack';

    if (isPaystack) {
      dev.log(
          'Warning: _handleServicePaymentResponse called for Paystack. Should have been intercepted.',
          name: 'GeneralPayout');
    }

    if (data['success'] == 1 || data['success'] == true) {
      final transactionId = localRef ?? data['ref'] ?? data['trnx_id'] ?? 'N/A';
      // final token = data['token']?.toString() ??
      //     data['data']?['token']?.toString() ??
      //     data['Token']?.toString() ??
      //     data['data']?['Token']?.toString();

      dev.log('Payment successful. Transaction ID: $transactionId',
          name: 'GeneralPayout');
      _currentTxRef = null; // clear reference on success

      // invalidate beneficiaries cache on success for airtime/data
      if (paymentType == PaymentType.airtime || paymentType == PaymentType.data) {
        box.remove('cached_beneficiaries_airtime_ts');
        dev.log('Beneficiaries cache timestamp cleared for refresh',
            name: 'GeneralPayout');
      }

      Get.snackbar(
          "Success", data['message'] ?? successMessage ?? "Payment successful!",
          backgroundColor: AppColors.successBgColor,
          colorText: AppColors.textSnackbarColor);

      _navigateToReceipt(transactionId.toString(), amount, data);
    } else {
      dev.log('Payment unsuccessful',
          name: 'GeneralPayout', error: data['message']);
      Get.snackbar(
          "Payment Failed", data['message'] ?? "An unknown error occurred.",
          backgroundColor: AppColors.errorBgColor,
          colorText: AppColors.textSnackbarColor);
    }
  }

  void _navigateToReceipt(
    String transactionId, double amount, Map<String, dynamic> data) {
    final userId = box.read('biometric_username_real') ?? 'N/A';

    // extract token if present
    String? token;
    if (data.containsKey('token') ||
        (data['data'] != null && data['data']['token'] != null)) {
      token = data['token']?.toString() ?? data['data']?['token']?.toString();
    } else if (data.containsKey('Token') ||
        (data['data'] != null && data['data']['Token'] != null)) {
      token = data['Token']?.toString() ?? data['data']?['Token']?.toString();
    }

    // extract server response data for all payment types
    dynamic serverResponseData;
    if (data['server_response'] != null) {
      serverResponseData = data['server_response'];
      dev.log('Passing server_response to receipt', name: 'GeneralPayout');
    } else if (paymentType == PaymentType.ninValidation &&
        data['data'] != null) {
      serverResponseData = data['data'];
      dev.log('Passing NIN validation data to receipt: $serverResponseData',
          name: 'GeneralPayout');
    }

    Get.offNamed(
      Routes.TRANSACTION_DETAIL_MODULE,
      arguments: {
        'name': serviceName,
        'image': serviceImage,
        'amount': amount,
        'paymentType': paymentType.name.toUpperCase(),
        'paymentMethod': getPaymentMethodDisplayName(),
        'userId': userId,
        'phoneNumber': phoneNumber,
        'transactionId': transactionId,
        'date': DateTime.now().toIso8601String(),
        'token': token,
        'status': 'success',
        'packageName':
            paymentData['examName'] ?? paymentData['packageName'] ?? 'N/A',
        'billerName': _getBillerNameForPayment(),
        'serverResponse': serverResponseData, // pass NIN validation data
      },
    );
  }

  String _getBillerNameForPayment() {
    switch (paymentType) {
      case PaymentType.resultChecker:
        return paymentData['examName'] ?? 'Result Checker';
      case PaymentType.ninValidation:
        return 'NIN Validation';
      default:
        return serviceName;
    }
  }

  
}
