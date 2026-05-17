import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mcd/app/styles/app_colors.dart';
import 'package:mcd/core/network/dio_api_service.dart';
import 'package:mcd/app/modules/history_screen_module/models/transaction_history_model.dart';
import 'dart:developer' as dev;
import './receipt_template.dart';
import 'package:mcd/core/utils/date_util.dart';

class TransactionDetailModuleController extends GetxController {
  final _selectedTemplate = ReceiptTemplate.receipt.obs;
  ReceiptTemplate get selectedTemplate => _selectedTemplate.value;
  set selectedTemplate(ReceiptTemplate val) => _selectedTemplate.value = val;
  var apiService = DioApiService();
  final box = GetStorage();

  // Global key for capturing receipt screenshot
  final receiptKey = GlobalKey();

  // Transaction object from API
  Transaction? transaction;

  // Computed properties from transaction
  String get name =>
      _formatTransactionName(transaction?.name ?? 'Unknown Transaction');
  String get image => _getTransactionIcon();
  double get amount => transaction?.amountValue ?? 0.0;
  String get paymentType => _getPaymentType();
  String get paymentMethod {
    final detailed = detailedTransaction;

    if (legacyPaymentMethod != null && legacyPaymentMethod!.isNotEmpty) {
      return legacyPaymentMethod!;
    }

    if (detailed != null) {
      if (detailed['payment_method'] != null &&
          detailed['payment_method'].toString().isNotEmpty) {
        return detailed['payment_method'].toString();
      }
      if (detailed['payment_mode'] != null &&
          detailed['payment_mode'].toString().isNotEmpty) {
        return detailed['payment_mode'].toString();
      }
    }

    // fallback to transaction object
    return transaction?.serverLog?.paymentMethod ?? '';
  }

  // legacy fields from arguments
  String? legacyPhoneNumber;
  String? legacyPackageName;
  String? legacyPaymentMethod;
  String? legacyBillerName;

  String get userId => transaction?.userName ?? 'N/A';
  String get phoneNumber {
    final _ = detailedTransaction;

    if (legacyPhoneNumber != null && legacyPhoneNumber != 'N/A') {
      return legacyPhoneNumber!;
    }
    return transaction?.phoneNumber ?? 'N/A';
  }

  String get customerName => _getCustomerName();
  String get customerAddress => _getCustomerAddress();
  String get kwUnits => _getKwUnits();
  String get transactionId => transaction?.ref ?? 'N/A';

  // NIN Validation specific fields
  String get ninSurname => _getNinField('surname');
  String get ninFirstName => _getNinField('firstname');
  String get ninMiddleName => _getNinField('middlename');
  String get ninGender => _getNinField('gender');
  String get ninPhoneNumber => _getNinField('telephoneno');
  String get ninBirthDate => _getNinField('birthdate');
  String get ninStateOfOrigin => _getNinField('state_of_origin');
  String get ninStateOfResidence => _getNinField('residence_state');
  String get ninEducationalLevel => _getNinField('educationallevel');
  String get ninMaritalStatus => _getNinField('maritalstatus');
  String get ninProfession => _getNinField('profession');
  String get ninPhoto => _getNinField('photo');
  String get ninNin => _getNinField('nin');
  String get packageName {
    // Access observable to ensure GetX registers dependency
    final _ = detailedTransaction;

    if (legacyPackageName != null &&
        legacyPackageName!.isNotEmpty &&
        legacyPackageName != 'N/A') {
      return legacyPackageName!;
    }
    return _getPackageName();
  }

  String get billerName {
    // Access observable to ensure GetX registers dependency
    final _ = detailedTransaction;
    return legacyBillerName ?? _getBillerName();
  }

  String get token =>
      (transaction?.token ?? '').trim().replaceAll(RegExp(r',\s*$'), '');
  String get date => DateUtil.formatDateTime(transaction?.date);
  String get description =>
      (transaction?.description ?? '').trim().replaceAll(RegExp(r',\s*$'), '');
  String get status => transaction?.status ?? '';
  String get network => transaction?.networkProvider ?? '';
  String get quantity => transaction?.serverLog?.quantity ?? '1';
  String get designType => transaction?.serverLog?.designType ?? 'N/A';
  String get initialAmount => transaction?.iWallet ?? 'N/A';
  String get finalAmount => transaction?.fWallet ?? 'N/A';

  final _isRepeating = false.obs;
  bool get isRepeating => _isRepeating.value;

  final _isSharing = false.obs;
  bool get isSharing => _isSharing.value;

  final _isDownloading = false.obs;
  bool get isDownloading => _isDownloading.value;

  final _isFetchingDetail = false.obs;
  bool get isFetchingDetail => _isFetchingDetail.value;

  // Detailed transaction data from API
  final Rx<Map<String, dynamic>?> _detailedTransaction =
      Rx<Map<String, dynamic>?>(null);
  Map<String, dynamic>? get detailedTransaction => _detailedTransaction.value;

  // Epin design data
  int _designId = 1;
  int get designId => _designId;
  String? _networkCode;
  String? get networkCode => _networkCode;

  // Available designs
  final designs = [
    {'id': 1, 'name': 'Design 1', 'image': 'assets/images/epin/design-1.png'},
    {'id': 2, 'name': 'Design 2', 'image': 'assets/images/epin/design-2.png'},
    {'id': 3, 'name': 'Design 3', 'image': 'assets/images/epin/design-3.png'},
    {'id': 4, 'name': 'Design 4', 'image': 'assets/images/epin/design-4.png'},
    {'id': 5, 'name': 'Design 5', 'image': 'assets/images/epin/design-5.png'},
    {'id': 6, 'name': 'Design 6', 'image': 'assets/images/epin/design-6.png'},
  ];

  String get designImage {
    final design = designs.firstWhere(
      (d) => d['id'] == _designId,
      orElse: () => designs[0],
    );
    return design['image'] as String;
  }

  String get username => box.read('biometric_username_real') ?? 'User';

  // Network logo mapping
  String _getNetworkLogo(String? code) {
    switch (code?.toUpperCase()) {
      case 'MTN':
        return 'assets/images/mtn.png';
      case 'AIRTEL':
        return 'assets/images/airtel.png';
      case '9MOBILE':
        return 'assets/images/etisalat.png';
      case 'GLO':
        return 'assets/images/glo.png';
      default:
        return 'assets/images/mtn.png';
    }
  }

  String get networkLogo => _getNetworkLogo(_networkCode);

  // Network dial codes
  String _getDialCode(String? network) {
    switch (network?.toUpperCase()) {
      case 'MTN':
        return 'To load dial *311*PIN#';
      case 'AIRTEL':
        return 'To load dial *126*PIN#';
      case 'GLO':
        return 'To load dial *123*PIN#';
      case '9MOBILE':
        return 'To load dial *222*PIN#';
      default:
        return 'To load dial *311*PIN#';
    }
  }

  /// Public helpers for epin card rendering
  String getNetworkLogoFor(String? code) => _getNetworkLogo(code);
  String getDialCodeFor(String? network) => _getDialCode(network);

  // Parse epins from server_response
  final _epins = <Map<String, dynamic>>[].obs;
  List<Map<String, dynamic>> get epins => _epins;

  // GlobalKeys for capturing each epin card as image
  final Map<int, GlobalKey> epinCardKeys = {};

  /// Get or create a GlobalKey for an epin card at the given index
  GlobalKey getEpinCardKey(int index) {
    return epinCardKeys.putIfAbsent(index, () => GlobalKey());
  }

  bool get isEpinTransaction {
    final code = transaction?.code.toLowerCase() ?? '';
    return code.contains('airtime_pin') || code.contains('data_pin');
  }

  @override
  void onInit() {
    super.onInit();
    final arguments = Get.arguments as Map<String, dynamic>?;

    if (arguments != null && arguments['transaction'] != null) {
      transaction = arguments['transaction'] as Transaction;

      // Fetch detailed transaction data from API
      if (transaction?.ref != null) {
        fetchTransactionDetail(transaction!.ref);
      }
    } else {
      // Fallback to old format for backward compatibility
      dev.log('Using legacy transaction format', name: 'TransactionDetail');
      _loadLegacyFormat(arguments);
    }
  }

  // Fetch detailed transaction from transactions-detail endpoint
  Future<void> fetchTransactionDetail(String ref) async {
    _isFetchingDetail.value = true;
    try {
      final transUrl = box.read('transaction_service_url') ?? '';
      final url = '${transUrl}transactions-detail/$ref';

      dev.log('Fetching from: $url', name: 'TransactionDetail');

      final response = await apiService.getrequest(url);

      response.fold(
        (failure) {
          dev.log('Failed to fetch transaction detail',
              name: 'TransactionDetail', error: failure.message);
        },
        (data) {
          if (data['success'] == 1 && data['data'] != null) {
            _detailedTransaction.value = data['data'];
            dev.log('Transaction detail fetched successfully',
                name: 'TransactionDetail');
            dev.log(
                'Server response type: ${data['data']['server_response'].runtimeType}',
                name: 'TransactionDetail');

            // Parse epins if this is an epin transaction
            if (isEpinTransaction && data['data']['server_response'] != null) {
              _parseEpins(data['data']['server_response']);

              // Load designId & networkCode from local storage (saved at purchase time)
              final savedDesign = box.read('epin_design_$ref');
              if (savedDesign != null) {
                _designId = savedDesign is int
                    ? savedDesign
                    : int.tryParse(savedDesign.toString()) ?? 1;
                dev.log(
                    'Loaded designId=$_designId from local storage for ref=$ref',
                    name: 'TransactionDetail');
              }

              final savedNetwork = box.read('epin_network_$ref');
              if (savedNetwork != null) {
                _networkCode = savedNetwork.toString();
                dev.log(
                    'Loaded networkCode=$_networkCode from local storage for ref=$ref',
                    name: 'TransactionDetail');
              }

              // Fallback: try network from server_log if still not set
              _networkCode ??= transaction?.serverLog?.network;
            }
          }
        },
      );
    } catch (e) {
      dev.log('Error fetching transaction detail',
          name: 'TransactionDetail', error: e);
    } finally {
      _isFetchingDetail.value = false;
    }
  }

  void _loadLegacyFormat(Map<String, dynamic>? arguments) {
    final userId = box.read('biometric_username_real') ?? 'N/A';

    if (arguments == null) return;

    legacyPhoneNumber = arguments['phoneNumber'];
    legacyPackageName = arguments['packageName'];
    legacyPaymentMethod = arguments['paymentMethod'];
    legacyBillerName = arguments['billerName'];

    // Load design and network info for epin cards
    if (arguments['designId'] != null) {
      _designId = arguments['designId'] is int
          ? arguments['designId']
          : int.tryParse(arguments['designId'].toString()) ?? 1;
    }
    if (arguments['networkCode'] != null) {
      _networkCode = arguments['networkCode'].toString();
    }

    // Check if server response data was passed (e.g., from NIN validation, electricity, cable)
    if (arguments['serverResponse'] != null) {
      var serverResp = arguments['serverResponse'];

      // Parse JSON string if needed
      if (serverResp is String) {
        try {
          serverResp = jsonDecode(serverResp);
        } catch (e) {
          dev.log('Failed to parse serverResponse JSON string',
              name: 'TransactionDetail', error: e);
        }
      }

      _detailedTransaction.value = {
        'server_response': serverResp,
      };
      dev.log('Using passed server response data', name: 'TransactionDetail');

      // Parse epins from server response (for airtime_pin / data_pin)
      _parseEpins(serverResp);
    }

    // Create a mock transaction from old format
    transaction = Transaction(
      id: 0,
      ref: arguments['transactionId'] ?? 'N/A',
      name: arguments['name'] ?? 'Unknown Transaction',
      amount: arguments['amount'] ?? 0.0,
      status: 'successful',
      description: arguments['description'] ?? '',
      date: arguments['date'] ?? '',
      userName: arguments['userId'] ?? userId,
      ipAddress: '',
      code: arguments['paymentType']?.toString().toLowerCase() ?? '',
      token: arguments['token'],
      serverLog: null,
    );

    // If no epins were parsed but this is an epin transaction,
    // generate basic cards from available arguments
    if (_epins.isEmpty && isEpinTransaction) {
      final amount = arguments['amount']?.toString() ?? '';
      final qty = int.tryParse(arguments['packageName']
                  ?.toString()
                  .replaceAll(RegExp(r'[^0-9]'), '') ??
              '1') ??
          1;
      final ref = arguments['transactionId'] ?? 'N/A';

      _epins.value = List.generate(qty, (i) {
        return {
          'pin': '',
          'serial': '',
          'amount': amount,
          'expiry': '',
          'network': _networkCode ?? 'MTN',
          'id': '',
          'refNo': qty > 1 ? '$ref-${i + 1}' : ref,
        };
      });
      dev.log('Generated $qty basic epin card(s) from arguments',
          name: 'TransactionDetail');
    }
  }

  /// Parse epins from server response data
  void _parseEpins(dynamic serverResponse) {
    try {
      var response = serverResponse;

      // Parse JSON string if needed
      if (response is String) {
        response = jsonDecode(response);
      }

      if (response is Map) {
        // If the top-level map has a server_response field, dig into it
        if (response['server_response'] != null) {
          var sr = response['server_response'];
          if (sr is String) {
            sr = jsonDecode(sr);
          }
          if (sr is Map) {
            response = sr;
          }
        }

        // Extract reference
        final reference =
            response['data']?['reference'] ?? response['reference'] ?? '';

        // Check if epins exist in data.epins
        var epinsData = response['data']?['epins'] ?? response['epins'];

        if (epinsData is List && epinsData.isNotEmpty) {
          int index = 1;
          _epins.value = epinsData.map<Map<String, dynamic>>((epin) {
            final refNo = epinsData.length > 1
                ? '$reference-${index++}'
                : reference.toString();
            return {
              'pin': epin['pin']?.toString() ?? '',
              'serial': epin['serial']?.toString() ?? '',
              'amount': epin['amount']?.toString() ?? '',
              'expiry': epin['expiry']?.toString() ?? '',
              'network': epin['network']?.toString() ?? _networkCode ?? 'MTN',
              'id': epin['id']?.toString() ?? '',
              'refNo': refNo,
            };
          }).toList();

          // If networkCode not set from arguments, use first epin's network
          _networkCode ??= _epins.first['network'];

          dev.log('Epin reference: $reference', name: 'TransactionDetail');
          dev.log('Parsed ${_epins.length} epins from server response',
              name: 'TransactionDetail');
        }
      }
    } catch (e) {
      dev.log('Error parsing epins from server response',
          name: 'TransactionDetail', error: e);
    }
  }

  String _getTransactionIcon() {
    if (transaction == null) return 'assets/images/mcdlogo.png';

    final code = transaction!.code.toLowerCase();
    final name = transaction!.name.toLowerCase();

    if (code.contains('airtime_pin') || name.contains('airtime_pin')) {
      // Airtime PIN/Epin
      if (name.contains('mtn') || code.contains('mtn')) {
        return 'assets/images/history/mtn.png';
      }
      if (name.contains('glo') || code.contains('glo')) {
        return 'assets/images/glo.png';
      }
      if (name.contains('airtel') || code.contains('airtel')) {
        return 'assets/images/history/airtel.png';
      }
      if (name.contains('9mobile') || code.contains('9mobile')) {
        return 'assets/images/history/9mobile.png';
      }
      return 'assets/images/mcdlogo.png';
    } else if (code.contains('airtime') || name.contains('airtime')) {
      if (name.contains('mtn')) return 'assets/images/history/mtn.png';
      if (name.contains('glo')) return 'assets/images/glo.png';
      if (name.contains('airtel')) return 'assets/images/history/airtel.png';
      if (name.contains('9mobile')) return 'assets/images/history/9mobile.png';
      return 'assets/images/mcdlogo.png';
    } else if (code.contains('data') || name.contains('data')) {
      if (name.contains('mtn')) return 'assets/images/history/mtn.png';
      if (name.contains('glo')) return 'assets/images/glo.png';
      if (name.contains('airtel')) return 'assets/images/history/airtel.png';
      return 'assets/images/mcdlogo.png';
    } else if (code.contains('betting') || name.contains('betting')) {
      // Betting - check for specific platform
      final network = transaction!.serverLog?.network.toLowerCase() ??
          transaction!.name.toLowerCase();

      if (network.contains('1xbet')) {
        return 'assets/images/betting/1XBET.png';
      } else if (network.contains('bangbet')) {
        return 'assets/images/betting/BANGBET.png';
      } else if (network.contains('bet9ja')) {
        return 'assets/images/betting/BET9JA.png';
      } else if (network.contains('betking')) {
        return 'assets/images/betting/BETKING.png';
      } else if (network.contains('betlion')) {
        return 'assets/images/betting/BETLION.png';
      } else if (network.contains('betway')) {
        return 'assets/images/betting/BETWAY.png';
      } else if (network.contains('cloudbet')) {
        return 'assets/images/betting/CLOUDBET.png';
      } else if (network.contains('merrybet')) {
        return 'assets/images/betting/MERRYBET.png';
      } else if (network.contains('msport') || network.contains('m-sport')) {
        return 'assets/images/betting/MSPORTHUB.png';
      } else if (network.contains('nairabet')) {
        return 'assets/images/betting/NAIRABET.png';
      } else if (network.contains('sportybet')) {
        return 'assets/images/betting/SPORTYBET.png';
      } else if (network.contains('naijabet')) {
        return 'assets/images/betting/NAIJABET.png';
      } else {
        return 'assets/images/betting/betting.png';
      }
    } else if (code.contains('electricity') || name.contains('electric')) {
      // Electricity - check for specific provider
      final network = transaction!.serverLog?.network.toLowerCase() ??
          transaction!.name.toLowerCase();

      if (network.contains('aba') || network.contains('abapower')) {
        return 'assets/images/electricity/ABA.png';
      } else if (network.contains('aedc') || network.contains('abuja')) {
        return 'assets/images/electricity/AEDC.png';
      } else if (network.contains('bedc') || network.contains('benin')) {
        return 'assets/images/electricity/BEDC.png';
      } else if (network.contains('eedc') || network.contains('enugu')) {
        return 'assets/images/electricity/EEDC.png';
      } else if (network.contains('ekedc') || network.contains('eko')) {
        return 'assets/images/electricity/EKEDC.png';
      } else if (network.contains('ibedc') || network.contains('ibadan')) {
        return 'assets/images/electricity/IBEDC.png';
      } else if (network.contains('ikedc') || network.contains('ikeja')) {
        return 'assets/images/electricity/IKEDC.png';
      } else if (network.contains('jos') || network.contains('jedc')) {
        return 'assets/images/electricity/JED.png';
      } else if (network.contains('kaedc') || network.contains('kaduna')) {
        return 'assets/images/electricity/KAEDC.png';
      } else if (network.contains('kedco') || network.contains('kano')) {
        return 'assets/images/electricity/KEDCO.png';
      } else if (network.contains('phed') ||
          network.contains('portharcourt') ||
          network.contains('port harcourt')) {
        return 'assets/images/electricity/PHED.png';
      } else if (network.contains('yedc') || network.contains('yola')) {
        return 'assets/images/electricity/YEDC.png';
      } else {
        return 'assets/images/electricity/electricity.png';
      }
    } else if (code.contains('cable') ||
        name.contains('dstv') ||
        name.contains('gotv') ||
        name.contains('startimes')) {
      // Cable TV - check for specific provider
      final network = transaction!.serverLog?.network.toLowerCase() ??
          transaction!.name.toLowerCase();

      if (network.contains('dstv')) {
        return 'assets/images/cable/dstv.jpeg';
      } else if (network.contains('gotv')) {
        return 'assets/images/cable/gotv.jpeg';
      } else if (network.contains('showmax')) {
        return 'assets/images/cable/showmax.jpeg';
      } else if (network.contains('startimes')) {
        return 'assets/images/cable/startimes.jpeg';
      } else {
        return 'assets/images/history/cable.png';
      }
    } else if (code.contains('nin') || name.contains('nin')) {
      // NIN Validation
      return 'assets/images/nin.png';
    } else if (transaction!.isCredit) {
      return 'assets/images/mcdlogo.png';
    }

    return 'assets/images/mcdlogo.png';
  }

  String _getPaymentType() {
    if (transaction == null) return 'Transaction';

    final code = transaction!.code.toLowerCase();
    final service = transaction!.serverLog?.service.toLowerCase() ?? '';

    if (code.contains('airtime_pin') || service.contains('airtime_pin')) {
      return 'Airtime PIN';
    }
    if (code.contains('data_pin') || service.contains('data_pin')) {
      return 'Data PIN';
    }
    if (code.contains('airtime') || service.contains('airtime')) {
      return 'Airtime';
    }
    if (code.contains('data') || service.contains('data')) return 'Data';
    if (code.contains('betting') || service.contains('betting')) {
      return 'Betting';
    }
    if (code.contains('electricity') || service.contains('electricity')) {
      return 'Electricity';
    }
    if (code.contains('cable') || service.contains('cable')) return 'Cable TV';
    if (code.contains('nin') || service.contains('nin'))
      return 'NIN Validation';
    if (code.contains('commission')) return 'Commission';

    // Format the transaction name properly
    return _formatTransactionName(transaction!.name);
  }

  /// Format transaction name: replace underscores with spaces and capitalize words
  String _formatTransactionName(String name) {
    if (name.isEmpty) return 'Transaction';

    // Replace underscores with spaces
    String formatted = name.replaceAll('_', ' ');

    // Capitalize each word
    return formatted.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  // Helper method to get NIN validation fields
  String _getNinField(String fieldName) {
    if (transaction == null) return 'N/A';

    final code = transaction!.code.toLowerCase();
    if (!code.contains('nin')) return 'N/A';

    if (detailedTransaction != null &&
        detailedTransaction!['server_response'] != null) {
      try {
        var serverResponse = detailedTransaction!['server_response'];

        // parse json string if needed
        if (serverResponse is String) {
          serverResponse = jsonDecode(serverResponse);
        }

        // handle nested data key
        if (serverResponse is Map && serverResponse['data'] is Map) {
          serverResponse = serverResponse['data'];
        }

        if (serverResponse is Map) {
          final value = serverResponse[fieldName];
          if (value != null &&
              value.toString().isNotEmpty &&
              value.toString() != 'null') {
            return value.toString();
          }
        }
      } catch (e) {
        dev.log('Error parsing NIN field $fieldName from server_response',
            name: 'TransactionDetail', error: e);
      }
    }

    return 'N/A';
  }

  String _getCustomerName() {
    if (transaction == null) return 'N/A';

    final code = transaction!.code.toLowerCase();

    // Try to get from server_response first
    if (detailedTransaction != null &&
        detailedTransaction!['server_response'] != null) {
      try {
        var serverResponse = detailedTransaction!['server_response'];

        // Parse JSON string if needed
        if (serverResponse is String) {
          serverResponse = jsonDecode(serverResponse);
        }

        // For electricity - customerName is at root level of server_response
        if (code.contains('electricity') || code.contains('electric')) {
          if (serverResponse is Map) {
            if (serverResponse['customerName'] != null) {
              dev.log('Found customerName: ${serverResponse['customerName']}',
                  name: 'TransactionDetail');
              return serverResponse['customerName'].toString();
            }
          }
        }

        // For cable TV
        if (code.contains('cable') || code.contains('tv')) {
          if (serverResponse is Map && serverResponse['customerName'] != null) {
            return serverResponse['customerName'].toString();
          }
        }
      } catch (e) {
        dev.log('Error parsing customerName from server_response',
            name: 'TransactionDetail', error: e);
      }
    }

    // Fallback to description parsing
    final desc = transaction!.description;
    if (code.contains('electricity') ||
        code.contains('electric') ||
        code.contains('cable')) {
      final nameMatch =
          RegExp(r'Customer Name:\s*([^,]+)', caseSensitive: false)
              .firstMatch(desc);
      if (nameMatch != null) {
        return nameMatch.group(1)?.trim() ?? 'N/A';
      }
    }

    return 'N/A';
  }

  String _getCustomerAddress() {
    if (transaction == null) return 'N/A';

    final code = transaction!.code.toLowerCase();

    // Try to get from server_response first
    if (detailedTransaction != null &&
        detailedTransaction!['server_response'] != null) {
      try {
        var serverResponse = detailedTransaction!['server_response'];

        // Parse JSON string if needed
        if (serverResponse is String) {
          serverResponse = jsonDecode(serverResponse);
        }

        if (code.contains('electricity') || code.contains('electric')) {
          if (serverResponse is Map) {
            if (serverResponse['customerAddress'] != null) {
              dev.log(
                  'Found customerAddress: ${serverResponse['customerAddress']}',
                  name: 'TransactionDetail');
              return serverResponse['customerAddress'].toString();
            }
          }
        }
      } catch (e) {
        dev.log('Error parsing customerAddress from server_response',
            name: 'TransactionDetail', error: e);
      }
    }

    // Fallback to description parsing
    final desc = transaction!.description;
    if (code.contains('electricity') || code.contains('electric')) {
      final addressMatch =
          RegExp(r'Address:\s*([^,]+)', caseSensitive: false).firstMatch(desc);
      if (addressMatch != null) {
        return addressMatch.group(1)?.trim() ?? 'N/A';
      }
    }

    return 'N/A';
  }

  String _getKwUnits() {
    if (transaction == null) return 'N/A';

    final code = transaction!.code.toLowerCase();

    // Try to get from server_response first
    if (detailedTransaction != null &&
        detailedTransaction!['server_response'] != null) {
      try {
        var serverResponse = detailedTransaction!['server_response'];

        // Parse JSON string if needed
        if (serverResponse is String) {
          serverResponse = jsonDecode(serverResponse);
        }

        if (code.contains('electricity') || code.contains('electric')) {
          if (serverResponse is Map) {
            // Try multiple possible field names at root level
            if (serverResponse['units'] != null) {
              dev.log('Found units: ${serverResponse['units']}',
                  name: 'TransactionDetail');
              return serverResponse['units'].toString();
            }
            if (serverResponse['kwUnits'] != null) {
              return serverResponse['kwUnits'].toString();
            }
            if (serverResponse['KWh'] != null) {
              return serverResponse['KWh'].toString();
            }
          }
        }
      } catch (e) {
        dev.log('Error parsing units from server_response',
            name: 'TransactionDetail', error: e);
      }
    }

    // Fallback to description parsing
    final desc = transaction!.description;
    if (code.contains('electricity') || code.contains('electric')) {
      final unitsMatch =
          RegExp(r'(?:Units|kwUnits):\s*([\d.]+)', caseSensitive: false)
              .firstMatch(desc);
      if (unitsMatch != null) {
        final units = unitsMatch.group(1)?.trim() ?? '';
        return units.isNotEmpty ? '$units kWh' : 'N/A';
      }
    }

    return 'N/A';
  }

  String _getPackageName() {
    if (transaction == null) return 'N/A';

    final code = transaction!.code.toLowerCase();
    final desc = transaction!.description.toLowerCase();

    // For airtime_pin, extract denomination from code
    if (code.contains('airtime_pin')) {
      // Extract amount from code like "airtime_pin_MTN_100"
      final parts = transaction!.code.split('_');
      if (parts.length >= 3) {
        return '₦${parts.last} E-PIN';
      }
      return 'E-PIN';
    }

    // For data, extract plan name from description
    if (code.contains('data')) {
      final planMatch =
          RegExp(r'(\d+\.?\d*[GT]B.*?)(?:on|using|$)', caseSensitive: false)
              .firstMatch(transaction!.description);
      if (planMatch != null) {
        return planMatch.group(1)?.trim() ?? 'N/A';
      }
    }

    // For electricity, check if prepaid or postpaid
    if (code.contains('electricity')) {
      if (desc.contains('prepaid')) return 'Prepaid';
      if (desc.contains('postpaid')) return 'Postpaid';
      return 'Prepaid'; // Default
    }

    return 'N/A';
  }

  String _getBillerName() {
    if (transaction == null) return 'N/A';

    final code = transaction!.code.toLowerCase();
    final name = transaction!.name.toLowerCase();

    if (code.contains('jamb') || name.contains('jamb')) return 'Jamb';
    if (code.contains('resultchecker') || code.contains('result_checker')) {
      return 'Result Checker';
    }
    if (code.contains('waec') || name.contains('waec')) return 'WAEC';
    if (code.contains('neco') || name.contains('neco')) return 'NECO';
    if (code.contains('nabteb') || name.contains('nabteb')) return 'NABTEB';

    return 'N/A';
  }

  void copyToken() {
    if (token != 'N/A') {
      dev.log('Token copied to clipboard: $token', name: 'TransactionDetail');
    }
  }

  // Repeat transaction (Buy Again)
  Future<void> repeatTransaction() async {
    if (transactionId == 'N/A' || transactionId.isEmpty) {
      Get.snackbar(
        'Error',
        'Cannot repeat transaction: Invalid transaction ID',
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    try {
      _isRepeating.value = true;
      dev.log('Repeating transaction: $transactionId',
          name: 'TransactionDetail');

      final transactionUrl = box.read('transaction_service_url') ?? '';
      final url = '${transactionUrl}transaction/repeat';
      dev.log('Repeat URL: $url', name: 'TransactionDetail');

      final body = {
        'ref': transactionId,
      };

      final response = await apiService.postrequest(url, body);

      response.fold(
        (failure) {
          dev.log('Failed to repeat transaction',
              name: 'TransactionDetail', error: failure.message);
          Get.snackbar(
            'Error',
            failure.message,
            backgroundColor: AppColors.errorBgColor,
            colorText: AppColors.textSnackbarColor,
            duration: const Duration(seconds: 2),
          );
        },
        (data) {
          dev.log('Repeat transaction response: $data',
              name: 'TransactionDetail');
          if (data['success'] == 1) {
            Get.snackbar(
              'Success',
              data['message'] ?? 'Transaction repeated successfully',
              backgroundColor: AppColors.successBgColor,
              colorText: AppColors.textSnackbarColor,
              duration: const Duration(seconds: 2),
            );
            // Navigate back after successful repeat
            Future.delayed(const Duration(seconds: 2), () {
              Get.back();
            });
          } else {
            Get.snackbar(
              'Error',
              data['message'] ?? 'Failed to repeat transaction',
              backgroundColor: AppColors.errorBgColor,
              colorText: AppColors.textSnackbarColor,
              duration: const Duration(seconds: 2),
            );
          }
        },
      );
    } catch (e) {
      dev.log('Error repeating transaction',
          name: 'TransactionDetail', error: e);
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
        duration: const Duration(seconds: 2),
      );
    } finally {
      _isRepeating.value = false;
    }
  }

  // Capture receipt as image and share
  Future<void> shareReceipt() async {
    try {
      _isSharing.value = true;
      dev.log('Sharing receipt', name: 'TransactionDetail');

      // Add a small delay for UI to hide internal balances
      await Future.delayed(const Duration(milliseconds: 100));

      final boundary = receiptKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception('Unable to capture receipt');
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      // Save to temporary directory
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/receipt_$transactionId.png');
      await file.writeAsBytes(pngBytes);

      dev.log('Receipt saved to: ${file.path}', name: 'TransactionDetail');

      // Share the file
      await Share.shareXFiles([XFile(file.path)]);

      dev.log('Receipt shared successfully', name: 'TransactionDetail');
    } catch (e) {
      dev.log('Error sharing receipt', name: 'TransactionDetail', error: e);
      Get.snackbar(
        'Error',
        'Failed to share receipt: $e',
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
        duration: const Duration(seconds: 2),
      );
    } finally {
      _isSharing.value = false;
    }
  }

  // Download receipt to device storage
  Future<void> downloadReceipt() async {
    try {
      _isDownloading.value = true;
      dev.log('Downloading receipt', name: 'TransactionDetail');

      // Add a small delay for UI to hide internal balances
      await Future.delayed(const Duration(milliseconds: 100));

      // Handle permissions for different platforms
      if (Platform.isAndroid) {
        PermissionStatus status;

        // Try photos permission first (works for Android 13+)
        status = await Permission.photos.status;

        if (!status.isGranted) {
          status = await Permission.photos.request();

          // If photos permission is not available, try storage (Android 12 and below)
          if (!status.isGranted) {
            status = await Permission.storage.status;
            if (!status.isGranted) {
              status = await Permission.storage.request();
            }
          }
        }

        if (status.isPermanentlyDenied) {
          Get.snackbar(
            'Permission Required',
            'Please enable storage permission in Settings to download receipts',
            backgroundColor: AppColors.errorBgColor,
            colorText: AppColors.textSnackbarColor,
            duration: const Duration(seconds: 3),
            mainButton: TextButton(
              onPressed: () => openAppSettings(),
              child:
                  const Text('Settings', style: TextStyle(color: Colors.white)),
            ),
          );
          return;
        }

        if (status.isDenied) {
          Get.snackbar(
            'Permission Denied',
            'Storage permission is required to download receipt',
            backgroundColor: AppColors.errorBgColor,
            colorText: AppColors.textSnackbarColor,
            duration: const Duration(seconds: 2),
          );
          return;
        }
      } else if (Platform.isIOS) {
        // Check and request photo library permission for iOS
        final status = await Permission.photos.status;

        if (!status.isGranted) {
          final requested = await Permission.photos.request();

          if (requested.isPermanentlyDenied) {
            Get.snackbar(
              'Permission Required',
              'Please enable photo library access in Settings to download receipts',
              backgroundColor: AppColors.errorBgColor,
              colorText: AppColors.textSnackbarColor,
              duration: const Duration(seconds: 3),
              mainButton: TextButton(
                onPressed: () => openAppSettings(),
                child: const Text('Settings',
                    style: TextStyle(color: Colors.white)),
              ),
            );
            return;
          }

          if (requested.isDenied) {
            Get.snackbar(
              'Permission Denied',
              'Photo library access is required to download receipt',
              backgroundColor: AppColors.errorBgColor,
              colorText: AppColors.textSnackbarColor,
              duration: const Duration(seconds: 2),
            );
            return;
          }
        }
      }

      final boundary = receiptKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception('Unable to capture receipt');
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      // Save to appropriate directory based on platform
      Directory? directory;
      String fileName;

      if (Platform.isAndroid) {
        // Try to save to public Downloads folder
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          // Fallback to Documents folder
          directory = Directory('/storage/emulated/0/Documents');
          if (!await directory.exists()) {
            // Final fallback to app-specific external storage
            directory = await getExternalStorageDirectory();
          }
        }

        final timestamp = DateTime.now().millisecondsSinceEpoch;
        fileName = 'Receipt_${transactionId}_$timestamp.png';
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        fileName = 'Receipt_${transactionId}_$timestamp.png';
      } else {
        directory = await getApplicationDocumentsDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        fileName = 'Receipt_${transactionId}_$timestamp.png';
      }

      if (directory == null) {
        throw Exception('Unable to access storage');
      }
      // Ensure the directory exists (create if necessary)
      try {
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }
      } catch (e) {
        dev.log('Failed to create directory: ${directory.path}',
            name: 'TransactionDetail', error: e);
      }

      File file = File('${directory.path}/$fileName');

      try {
        await file.writeAsBytes(pngBytes);
      } on FileSystemException catch (e) {
        dev.log('Primary save failed, attempting fallback',
            name: 'TransactionDetail', error: e);

        // Fallback: save to app documents directory
        final fallbackDir = await getApplicationDocumentsDirectory();
        if (!await fallbackDir.exists()) {
          await fallbackDir.create(recursive: true);
        }
        final fallbackFile = File('${fallbackDir.path}/$fileName');
        await fallbackFile.writeAsBytes(pngBytes);
        file = fallbackFile;
      }

      dev.log('Receipt saved to: ${file.path}', name: 'TransactionDetail');

      // Show success message with the file path
      Get.snackbar(
        'Saved',
        'Receipt saved to Downloads',
        backgroundColor: AppColors.successBgColor,
        colorText: AppColors.textSnackbarColor,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      dev.log('Download failed', name: 'TransactionDetail', error: e);
      Get.snackbar(
        'Download Failed',
        'Unable to download receipt: ${e.toString()}',
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
        duration: const Duration(seconds: 2),
      );
    } finally {
      _isDownloading.value = false;
    }
  }

  // Format a single epin into shareable text (fallback)
  String _formatEpinText(Map<String, dynamic> epin) {
    final network =
        epin['network']?.toString().toUpperCase() ?? _networkCode ?? 'MTN';
    final dialCode = _getDialCode(network);
    final pin = epin['pin'] ?? '';
    final serial = epin['serial'] ?? '';
    final amount = epin['amount'] ?? '';
    final expiry = epin['expiry'] ?? '';
    final refNo = epin['refNo']?.toString() ?? transactionId;

    return '''
$network Airtime PIN
━━━━━━━━━━━━━━━━
Ref No:       $refNo
PIN:          $pin
Amount:       ₦$amount
Expiry Date:  $expiry
Serial No:    $serial
$dialCode
━━━━━━━━━━━━━━━━''';
  }

  /// Capture a RepaintBoundary widget as a PNG file
  Future<File?> _captureCardAsImage(GlobalKey key, String fileName) async {
    try {
      final boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return null;

      final pngBytes = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$fileName.png');
      await file.writeAsBytes(pngBytes);
      return file;
    } catch (e) {
      dev.log('Error capturing card image: $fileName',
          name: 'TransactionDetail', error: e);
      return null;
    }
  }

  /// Share a single epin card as an image
  Future<void> shareSingleEpin(int index) async {
    try {
      final key = epinCardKeys[index];
      if (key == null) return;

      final epin = _epins[index];
      final refNo = epin['refNo']?.toString() ?? transactionId;
      final file = await _captureCardAsImage(key, 'epin_$refNo');

      if (file != null) {
        await Share.shareXFiles([XFile(file.path)]);
      } else {
        // Fallback to text if image capture fails
        await Share.share(_formatEpinText(epin), subject: 'E-PIN Details');
      }
    } catch (e) {
      dev.log('Error sharing single epin', name: 'TransactionDetail', error: e);
      Get.snackbar(
        'Error',
        'Failed to share PIN',
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
        duration: const Duration(seconds: 2),
      );
    }
  }

  /// Share all epin cards as images
  Future<void> shareAllEpins() async {
    try {
      if (_epins.isEmpty) return;

      final List<XFile> files = [];

      for (int i = 0; i < _epins.length; i++) {
        final key = epinCardKeys[i];
        if (key == null) continue;

        final refNo = _epins[i]['refNo']?.toString() ?? '${transactionId}_$i';
        final file = await _captureCardAsImage(key, 'epin_$refNo');
        if (file != null) {
          files.add(XFile(file.path));
        }
      }

      if (files.isNotEmpty) {
        await Share.shareXFiles(files);
      } else {
        // Fallback to text if image capture fails
        final buffer = StringBuffer();
        buffer.writeln('Your E-PINs (${_epins.length})');
        buffer.writeln('');
        for (int i = 0; i < _epins.length; i++) {
          if (_epins.length > 1)
            buffer.writeln('PIN ${i + 1} of ${_epins.length}');
          buffer.writeln(_formatEpinText(_epins[i]));
          buffer.writeln('');
        }
        await Share.share(buffer.toString().trimRight(),
            subject: 'E-PIN Details');
      }
    } catch (e) {
      dev.log('Error sharing all epins', name: 'TransactionDetail', error: e);
      Get.snackbar(
        'Error',
        'Failed to share PINs',
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
        duration: const Duration(seconds: 2),
      );
    }
  }
}
