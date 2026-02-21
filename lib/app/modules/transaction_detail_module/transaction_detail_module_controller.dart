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

class TransactionDetailModuleController extends GetxController {
  var apiService = DioApiService();
  final box = GetStorage();

  // Global key for capturing receipt screenshot
  final receiptKey = GlobalKey();

  // Transaction object from API
  Transaction? transaction;

  // Computed properties from transaction
  String get name => _formatTransactionName(transaction?.name ?? 'Unknown Transaction');
  String get image => _getTransactionIcon();
  double get amount => transaction?.amountValue ?? 0.0;
  String get paymentType => _getPaymentType();
  String get paymentMethod {
    if (legacyPaymentMethod != null && legacyPaymentMethod!.isNotEmpty) {
      return legacyPaymentMethod!;
    }
    return transaction?.serverLog?.paymentMethod ?? 'wallet';
  }

  // legacy fields from arguments
  String? legacyPhoneNumber;
  String? legacyPackageName;
  String? legacyPaymentMethod;
  String? legacyBillerName;

  String get userId => transaction?.userName ?? 'N/A';
  String get phoneNumber {
    if (legacyPhoneNumber != null && legacyPhoneNumber != 'N/A') {
      return legacyPhoneNumber!;
    }
    return transaction?.phoneNumber ?? 'N/A';
  }

  String get customerName => _getCustomerName();
  String get customerAddress => _getCustomerAddress();
  String get kwUnits => _getKwUnits();
  String get transactionId => transaction?.ref ?? 'N/A';
  String get packageName {
    if (legacyPackageName != null &&
        legacyPackageName!.isNotEmpty &&
        legacyPackageName != 'N/A') {
      return legacyPackageName!;
    }
    return _getPackageName();
  }

  String get billerName => legacyBillerName ?? _getBillerName();
  String get token =>
      (transaction?.token ?? '').trim().replaceAll(RegExp(r',\s*$'), '');
  String get date => transaction?.date ?? '';
  String get description =>
      (transaction?.description ?? '').trim().replaceAll(RegExp(r',\s*$'), '');
  String get status => transaction?.status ?? '';
  String get network => transaction?.networkProvider ?? '';
  String get quantity => transaction?.serverLog?.quantity ?? '1';
  String get initialAmount => transaction?.iWallet ?? 'N/A';
  String get finalAmount => transaction?.fWallet ?? 'N/A';

  final _isRepeating = false.obs;
  bool get isRepeating => _isRepeating.value;

  final _isSharing = false.obs;
  bool get isSharing => _isSharing.value;

  final _isDownloading = false.obs;
  bool get isDownloading => _isDownloading.value;

  // Detailed transaction data from API
  final Rx<Map<String, dynamic>?> _detailedTransaction = Rx<Map<String, dynamic>?>(null);
  Map<String, dynamic>? get detailedTransaction => _detailedTransaction.value;

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
            dev.log('Transaction detail fetched successfully', name: 'TransactionDetail');
            dev.log('Server response type: ${data['data']['server_response'].runtimeType}', name: 'TransactionDetail');
          }
        },
      );
    } catch (e) {
      dev.log('Error fetching transaction detail', name: 'TransactionDetail', error: e);
    }
  }

  void _loadLegacyFormat(Map<String, dynamic>? arguments) {
    final userId = box.read('biometric_username_real') ?? 'N/A';

    if (arguments == null) return;

    legacyPhoneNumber = arguments['phoneNumber'];
    legacyPackageName = arguments['packageName'];
    legacyPaymentMethod = arguments['paymentMethod'];
    legacyBillerName = arguments['billerName'];

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

  String _getCustomerName() {
    if (transaction == null) return 'N/A';

    final code = transaction!.code.toLowerCase();

    // Try to get from server_response first
    if (detailedTransaction != null && detailedTransaction!['server_response'] != null) {
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
              dev.log('Found customerName: ${serverResponse['customerName']}', name: 'TransactionDetail');
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
        dev.log('Error parsing customerName from server_response', name: 'TransactionDetail', error: e);
      }
    }

    // Fallback to description parsing
    final desc = transaction!.description;
    if (code.contains('electricity') || code.contains('electric') || code.contains('cable')) {
      final nameMatch = RegExp(r'Customer Name:\s*([^,]+)', caseSensitive: false)
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
    if (detailedTransaction != null && detailedTransaction!['server_response'] != null) {
      try {
        var serverResponse = detailedTransaction!['server_response'];
        
        // Parse JSON string if needed
        if (serverResponse is String) {
          serverResponse = jsonDecode(serverResponse);
        }
        
        if (code.contains('electricity') || code.contains('electric')) {
          if (serverResponse is Map) {
            if (serverResponse['customerAddress'] != null) {
              dev.log('Found customerAddress: ${serverResponse['customerAddress']}', name: 'TransactionDetail');
              return serverResponse['customerAddress'].toString();
            }
          }
        }
      } catch (e) {
        dev.log('Error parsing customerAddress from server_response', name: 'TransactionDetail', error: e);
      }
    }

    // Fallback to description parsing
    final desc = transaction!.description;
    if (code.contains('electricity') || code.contains('electric')) {
      final addressMatch = RegExp(r'Address:\s*([^,]+)', caseSensitive: false)
          .firstMatch(desc);
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
    if (detailedTransaction != null && detailedTransaction!['server_response'] != null) {
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
              dev.log('Found units: ${serverResponse['units']}', name: 'TransactionDetail');
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
        dev.log('Error parsing units from server_response', name: 'TransactionDetail', error: e);
      }
    }

    // Fallback to description parsing
    final desc = transaction!.description;
    if (code.contains('electricity') || code.contains('electric')) {
      final unitsMatch = RegExp(r'(?:Units|kwUnits):\s*([\d.]+)', caseSensitive: false)
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
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Transaction Receipt - $paymentType - ₦$amount',
      );

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
}
