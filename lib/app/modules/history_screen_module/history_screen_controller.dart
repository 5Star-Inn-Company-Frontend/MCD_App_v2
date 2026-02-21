import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mcd/app/modules/history_screen_module/models/transaction_history_model.dart';
import 'package:mcd/app/styles/app_colors.dart';
import 'package:mcd/core/constants/app_asset.dart';
import 'package:mcd/core/network/dio_api_service.dart';
import 'dart:developer' as dev;

class TransactionUIModel {
  final String name;
  final String image;
  final double amount;
  final String time;

  TransactionUIModel({
    required this.name,
    required this.image,
    required this.amount,
    required this.time,
  });
}

class HistoryScreenController extends GetxController {
  var apiService = DioApiService();
  final box = GetStorage();

  final _typeFilter = 'All'.obs;
  String get typeFilter => _typeFilter.value;
  set typeFilter(String value) {
    _typeFilter.value = value;
    fetchTransactions(); // Refetch when filter changes
  }

  final _statusFilter = 'All Status'.obs;
  String get statusFilter => _statusFilter.value;
  set statusFilter(String value) {
    _statusFilter.value = value;
    fetchTransactions(); // Refetch when status filter changes
  }

  final _dateFrom = ''.obs;
  String get dateFrom => _dateFrom.value;

  final _dateTo = ''.obs;
  String get dateTo => _dateTo.value;

  // set date range and refetch
  void setDateRange(String from, String to) {
    _dateFrom.value = from;
    _dateTo.value = to;
    fetchTransactions();
  }

  // clear date filter
  void clearDateFilter() {
    _dateFrom.value = '';
    _dateTo.value = '';
    fetchTransactions();
  }

  // Future<void> testFetchTransactions(String transactionRef) async {
  //   try {
      
  //     final transUrl = box.read('transaction_service_url') ?? '';
  //     final url = '${transUrl}transactions';
      
  //     dev.log('Request URL: $url', name: 'HistoryScreen');
      
  //     final response = await apiService.getrequest(url);
      
  //     response.fold(
  //       (failure) {
  //         dev.log('Failed to fetch transaction detail', 
  //             name: 'HistoryScreen', error: failure.message);
  //       },
  //       (data) {
  //         dev.log('Response JSON for /transactions endpoint: $data', name: 'HistoryScreen');
  //       },
  //     );
  //   } catch (e) {
  //     dev.log('Error fetching transaction detail', name: 'HistoryScreen', error: e);
  //   }
  // }

  // Fetch transaction detail using transactions-detail endpoint
  Future<void> fetchTransactionDetail(String transactionRef) async {
    try {
      dev.log('Fetching transaction detail for ref: $transactionRef', name: 'HistoryScreen');
      
      final transUrl = box.read('transaction_service_url') ?? '';
      final url = '${transUrl}transactions-detail/$transactionRef';
      
      dev.log('Request URL: $url', name: 'HistoryScreen');
      
      final response = await apiService.getrequest(url);
      
      response.fold(
        (failure) {
          dev.log('Failed to fetch transaction detail', 
              name: 'HistoryScreen', error: failure.message);
        },
        (data) {
          dev.log('Transaction Detail Response JSON: $data', name: 'HistoryScreen');
        },
      );
    } catch (e) {
      dev.log('Error fetching transaction detail', name: 'HistoryScreen', error: e);
    }
  }

  final _selectedValue = 'January'.obs;
  String get selectedValue => _selectedValue.value;
  set selectedValue(String value) => _selectedValue.value = value;

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  final _isLoadingMore = false.obs;
  bool get isLoadingMore => _isLoadingMore.value;

  final _isDownloadingStatement = false.obs;
  bool get isDownloadingStatement => _isDownloadingStatement.value;

  final Rxn<TransactionHistoryModel> _transactionHistory =
      Rxn<TransactionHistoryModel>();
  TransactionHistoryModel? get transactionHistory => _transactionHistory.value;

  final _totalIn = 0.0.obs;
  double get totalIn => _totalIn.value;

  final _totalOut = 0.0.obs;
  double get totalOut => _totalOut.value;

  // Pagination
  int _currentPage = 1;
  String? _nextPageUrl;
  String? _prevPageUrl;
  bool get hasMorePages => _nextPageUrl != null;

  final List<String> months = [
    'January',
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  ];

  // Get filtered transactions
  List<Transaction> get filteredTransactions {
    if (transactionHistory == null) return [];
    return transactionHistory!.transactions;
  }

  @override
  void onInit() {
    selectedValue = months.first;
    dev.log('Initializing History Screen', name: 'HistoryScreen');
    fetchTransactions();
    fetchTransactionSummary();
    super.onInit();
  }

  // Fetch transaction summary (inflow/outflow)
  Future<void> fetchTransactionSummary() async {
    try {
      final transUrl = box.read('transaction_service_url') ?? '';

      // calculate date range (last 365 days by default)
      final now = DateTime.now();
      final dateFrom = DateTime(now.year - 1, now.month, now.day);
      final dateTo = now;

      final dateFromStr =
          '${dateFrom.year}-${dateFrom.month.toString().padLeft(2, '0')}-${dateFrom.day.toString().padLeft(2, '0')}';
      final dateToStr =
          '${dateTo.year}-${dateTo.month.toString().padLeft(2, '0')}-${dateTo.day.toString().padLeft(2, '0')}';

      final url =
          '${transUrl}transactions-summary?date_from=$dateFromStr&date_to=$dateToStr';
      dev.log('Summary URL: $url', name: 'HistoryScreen');

      final response = await apiService.getrequest(url);

      response.fold(
        (failure) {
          dev.log('Failed to fetch summary',
              name: 'HistoryScreen', error: failure.message);
        },
        (data) {
          dev.log('Summary response: $data', name: 'HistoryScreen');
          if (data['success'] == 1 && data['data'] != null) {
            _totalIn.value =
                double.tryParse(data['data']['inflow'].toString()) ?? 0.0;
            _totalOut.value =
                double.tryParse(data['data']['outflow'].toString()) ?? 0.0;
            dev.log('Summary - In: $_totalIn, Out: $_totalOut',
                name: 'HistoryScreen');
          }
        },
      );
    } catch (e) {
      dev.log('Error fetching summary', name: 'HistoryScreen', error: e);
    }
  }

  // Fetch transactions from API with filters
  Future<void> fetchTransactions({int page = 1, bool append = false}) async {
    try {
      if (append) {
        _isLoadingMore.value = true;
      } else {
        _isLoading.value = true;
        _currentPage = 1;
      }
      dev.log('Fetching transactions (page: $page, append: $append)...',
          name: 'HistoryScreen');

      final transUrl = box.read('transaction_service_url') ?? '';

      // Build query parameters
      final queryParams = <String, String>{};
      if (page > 1) queryParams['page'] = page.toString();

      // Add filters if they are set
      if (_dateFrom.value.isNotEmpty) {
        queryParams['date_from'] = _dateFrom.value; // Format: YYYY-MM-DD
      }
      if (_dateTo.value.isNotEmpty) {
        queryParams['date_to'] = _dateTo.value; // Format: YYYY-MM-DD
      }

      if (_statusFilter.value != 'All Status') {
        queryParams['status'] = _statusFilter.value.toLowerCase();
      }

      if (_typeFilter.value != 'All') {
        queryParams['type'] = _typeFilter.value.toLowerCase();
      }

      // Build URL with query params
      String url = '${transUrl}transactions-filter';
      if (queryParams.isNotEmpty) {
        final queryString =
            queryParams.entries.map((e) => '${e.key}=${e.value}').join('&');
        url = '$url?$queryString';
      }

      dev.log('Request URL: $url', name: 'HistoryScreen');

      final response = await apiService.getrequest(url);

      response.fold(
        (failure) {
          dev.log('Failed to fetch transactions',
              name: 'HistoryScreen', error: failure.message);
          Get.snackbar(
            'Error',
            failure.message,
            backgroundColor: AppColors.errorBgColor,
            colorText: AppColors.textSnackbarColor,
          );
        },
        (data) {
          dev.log('Transactions response received', name: 'HistoryScreen');
          if (data['success'] == 1) {
            final newData = TransactionHistoryModel.fromJson(data);

            // Store pagination info
            _currentPage = newData.data.currentPage;
            _nextPageUrl = newData.data.nextPageUrl;
            _prevPageUrl = newData.data.prevPageUrl;

            if (append && _transactionHistory.value != null) {
              // Append new transactions to existing list
              final existingTransactions =
                  _transactionHistory.value!.transactions;
              final combinedTransactions = [
                ...existingTransactions,
                ...newData.transactions
              ];

              // Create updated model with combined transactions
              _transactionHistory.value = TransactionHistoryModel(
                success: newData.success,
                message: newData.message,
                data: TransactionDataPagination(
                  currentPage: newData.data.currentPage,
                  transactions: combinedTransactions,
                  firstPageUrl: newData.data.firstPageUrl,
                  from: _transactionHistory.value!.data.from,
                  nextPageUrl: newData.data.nextPageUrl,
                  path: newData.data.path,
                  perPage: newData.data.perPage,
                  prevPageUrl: newData.data.prevPageUrl,
                  to: newData.data.to,
                ),
              );
            } else {
              _transactionHistory.value = newData;
            }

            dev.log(
                'Loaded ${newData.transactions.length} transactions (page $_currentPage, hasMore: $hasMorePages)',
                name: 'HistoryScreen');
          } else {
            dev.log('Transaction fetch unsuccessful',
                name: 'HistoryScreen', error: data['message']);
            Get.snackbar(
              'Error',
              data['message'] ?? 'Failed to load transactions',
              backgroundColor: AppColors.errorBgColor,
              colorText: AppColors.textSnackbarColor,
            );
          }
        },
      );
    } catch (e) {
      dev.log('Error fetching transactions', name: 'HistoryScreen', error: e);
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
      );
    } finally {
      _isLoading.value = false;
      _isLoadingMore.value = false;
      dev.log('Fetch transactions completed', name: 'HistoryScreen');
    }
  }

  // Load more transactions (next page)
  Future<void> loadMoreTransactions() async {
    if (_isLoadingMore.value || !hasMorePages) return;

    dev.log('Loading more transactions...', name: 'HistoryScreen');
    await fetchTransactions(page: _currentPage + 1, append: true);
  }

  // Refresh transactions
  Future<void> refreshTransactions() async {
    dev.log('Refreshing transactions...', name: 'HistoryScreen');
    await fetchTransactions();
    await fetchTransactionSummary();
  }

  // Download transaction statement
  Future<void> downloadStatement(
      String fromDate, String toDate, String format) async {
    try {
      _isDownloadingStatement.value = true;
      dev.log(
          'Downloading statement from $fromDate to $toDate in $format format',
          name: 'HistoryScreen');

      final transUrl = box.read('transaction_service_url') ?? '';
      final url = '${transUrl}transactions-statement';

      final body = {
        'from': fromDate,
        'to': toDate,
        'format': format,
      };

      dev.log('Request URL: $url', name: 'HistoryScreen');
      dev.log('Request body: $body', name: 'HistoryScreen');

      final response = await apiService.postrequest(url, body);

      response.fold(
        (failure) {
          dev.log('Failed to download statement',
              name: 'HistoryScreen', error: failure.message);
          Get.snackbar(
            'Error',
            failure.message,
            backgroundColor: AppColors.errorBgColor,
            colorText: AppColors.textSnackbarColor,
          );
        },
        (data) {
          dev.log('Statement download response received $data',
              name: 'HistoryScreen');
          if (data['success'] == 1) {
            Get.snackbar(
              'Success',
              data['message'] ?? 'Statement downloaded successfully',
              backgroundColor: AppColors.successBgColor,
              colorText: AppColors.white,
            );
            if (data['data'] != null && data['data']['url'] != null) {
              dev.log('Statement URL: ${data['data']['url']}',
                  name: 'HistoryScreen');
            }
          } else {
            Get.snackbar(
              'Error',
              data['message'] ?? 'Failed to download statement',
              backgroundColor: AppColors.errorBgColor,
              colorText: AppColors.textSnackbarColor,
            );
          }
        },
      );
    } catch (e) {
      dev.log('Error downloading statement', name: 'HistoryScreen', error: e);
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
      );
    } finally {
      _isDownloadingStatement.value = false;
    }
  }

  // Get transaction icon based on type
  String getTransactionIcon(Transaction transaction) {
    final type = transaction.name.toLowerCase();
    final code = transaction.code.toLowerCase();
    final description = transaction.description.toLowerCase();

    String icon;

    // Check by service type
    if (code.contains('airtime_pin') || type.contains('airtime_pin')) {
      // Airtime PIN/Epin - use epin icon or network icon
      if (type.contains('mtn') ||
          code.contains('mtn') ||
          description.contains('mtn')) {
        icon = AppAsset.mtn;
      } else if (type.contains('glo') ||
          code.contains('glo') ||
          description.contains('glo')) {
        icon = 'assets/images/glo.png';
      } else if (type.contains('airtel') ||
          code.contains('airtel') ||
          description.contains('airtel')) {
        icon = 'assets/images/history/airtel.png';
      } else if (type.contains('9mobile') ||
          code.contains('9mobile') ||
          description.contains('9mobile')) {
        icon = 'assets/images/history/9mobile.png';
      } else {
        icon = 'assets/images/mcdlogo.png';
      }
    } else if (code.contains('airtime') || type.contains('airtime')) {
      // Regular airtime - Network-specific icons
      if (type.contains('mtn') || description.contains('mtn')) {
        icon = AppAsset.mtn;
      } else if (type.contains('glo') || description.contains('glo')) {
        icon = 'assets/images/glo.png';
      } else if (type.contains('airtel') || description.contains('airtel')) {
        icon = 'assets/images/history/airtel.png';
      } else if (type.contains('9mobile') || description.contains('9mobile')) {
        icon = 'assets/images/history/9mobile.png';
      } else {
        icon = 'assets/images/mcdlogo.png';
      }
    } else if (code.contains('data') || type.contains('data')) {
      if (type.contains('mtn') || description.contains('mtn')) {
        icon = AppAsset.mtn;
      } else if (type.contains('glo') || description.contains('glo')) {
        icon = 'assets/images/history/glo.png';
      } else if (type.contains('airtel') || description.contains('airtel')) {
        icon = 'assets/images/history/airtel.png';
      } else if (type.contains('9mobile') || description.contains('9mobile')) {
        icon = 'assets/images/history/9mobile.png';
      } else {
        icon = 'assets/images/mcdlogo.png';
      }
    } else if (code.contains('betting') ||
        type.contains('betting') ||
        type.contains('bet')) {
      // Betting - check for specific platform
      final network = transaction.serverLog?.network.toLowerCase() ??
          transaction.name.toLowerCase();

      if (network.contains('1xbet')) {
        icon = 'assets/images/betting/1XBET.png';
      } else if (network.contains('bangbet')) {
        icon = 'assets/images/betting/BANGBET.png';
      } else if (network.contains('bet9ja')) {
        icon = 'assets/images/betting/BET9JA.png';
      } else if (network.contains('betking')) {
        icon = 'assets/images/betting/BETKING.png';
      } else if (network.contains('betlion')) {
        icon = 'assets/images/betting/BETLION.png';
      } else if (network.contains('betway')) {
        icon = 'assets/images/betting/BETWAY.png';
      } else if (network.contains('cloudbet')) {
        icon = 'assets/images/betting/CLOUDBET.png';
      } else if (network.contains('merrybet')) {
        icon = 'assets/images/betting/MERRYBET.png';
      } else if (network.contains('msport') || network.contains('m-sport')) {
        icon = 'assets/images/betting/MSPORTHUB.png';
      } else if (network.contains('nairabet')) {
        icon = 'assets/images/betting/NAIRABET.png';
      } else if (network.contains('sportybet')) {
        icon = 'assets/images/betting/SPORTYBET.png';
      } else if (network.contains('naijabet')) {
        icon = 'assets/images/betting/NAIJABET.png';
      } else {
        icon = 'assets/images/betting/betting.png';
      }
    } else if (code.contains('electricity') || type.contains('electric')) {
      // Electricity - check for specific provider
      final network = transaction.serverLog?.network.toLowerCase() ??
          transaction.name.toLowerCase();

      if (network.contains('aba') || network.contains('abapower')) {
        icon = 'assets/images/electricity/ABA.png';
      } else if (network.contains('aedc') || network.contains('abuja')) {
        icon = 'assets/images/electricity/AEDC.png';
      } else if (network.contains('bedc') || network.contains('benin')) {
        icon = 'assets/images/electricity/BEDC.png';
      } else if (network.contains('eedc') || network.contains('enugu')) {
        icon = 'assets/images/electricity/EEDC.png';
      } else if (network.contains('ekedc') || network.contains('eko')) {
        icon = 'assets/images/electricity/EKEDC.png';
      } else if (network.contains('ibedc') || network.contains('ibadan')) {
        icon = 'assets/images/electricity/IBEDC.png';
      } else if (network.contains('ikedc') || network.contains('ikeja')) {
        icon = 'assets/images/electricity/IKEDC.png';
      } else if (network.contains('jos') || network.contains('jedc')) {
        icon = 'assets/images/electricity/JED.png';
      } else if (network.contains('kaedc') || network.contains('kaduna')) {
        icon = 'assets/images/electricity/KAEDC.png';
      } else if (network.contains('kedco') || network.contains('kano')) {
        icon = 'assets/images/electricity/KEDCO.png';
      } else if (network.contains('phed') ||
          network.contains('portharcourt') ||
          network.contains('port harcourt')) {
        icon = 'assets/images/electricity/PHED.png';
      } else if (network.contains('yedc') || network.contains('yola')) {
        icon = 'assets/images/electricity/YEDC.png';
      } else {
        icon = 'assets/images/electricity/electricity.png';
      }
    } else if (code.contains('cable') ||
        type.contains('dstv') ||
        type.contains('gotv') ||
        type.contains('startimes')) {
      // Cable TV - check for specific provider
      final network = transaction.serverLog?.network.toLowerCase() ??
          transaction.name.toLowerCase();

      if (network.contains('dstv')) {
        icon = 'assets/images/cable/dstv.jpeg';
      } else if (network.contains('gotv')) {
        icon = 'assets/images/cable/gotv.jpeg';
      } else if (network.contains('showmax')) {
        icon = 'assets/images/cable/showmax.jpeg';
      } else if (network.contains('startimes')) {
        icon = 'assets/images/cable/startimes.jpeg';
      } else {
        icon = 'assets/images/history/cable.png';
      }
    } else if (transaction.isCredit || code.contains('commission')) {
      icon = AppAsset.withdrawal;
    } else if (type.contains('withdrawal') ||
        description.contains('withdrawal')) {
      icon = AppAsset.withdrawal;
    } else {
      icon = 'assets/images/mcdlogo.png'; // Default icon
    }

    return icon;
  }
}
