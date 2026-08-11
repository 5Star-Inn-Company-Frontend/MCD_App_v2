import 'dart:convert';
import 'dart:developer' as dev;
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mcd/core/network/dio_api_service.dart';
import 'package:mcd/core/models/bank_model.dart';

class BankService extends GetxService {
  static BankService get to => Get.find<BankService>();

  final DioApiService _apiService = DioApiService();
  final GetStorage _storage = GetStorage();
  
  final RxList<BankModel> banks = <BankModel>[].obs;
  final RxBool isLoadingBanks = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadCachedBanks();
  }

  void _loadCachedBanks() {
    try {
      final cachedBanks = _storage.read('cached_banks_list');
      if (cachedBanks != null) {
        final List<dynamic> decoded = jsonDecode(cachedBanks);
        banks.value = decoded.map((e) => BankModel.fromJson(e)).toList();
        dev.log('Loaded ${banks.length} banks from cache', name: 'BankService');
      }
    } catch (e) {
      dev.log('Error loading cached banks: $e', name: 'BankService');
    }
  }

  Future<void> fetchBanks({bool force = false}) async {
    if (banks.isNotEmpty && !force) {
      dev.log('Banks already loaded', name: 'BankService');
      return;
    }

    try {
      isLoadingBanks.value = true;
      dev.log('Fetching banks...', name: 'BankService');

      final transactionUrl = _storage.read('transaction_service_url');
      if (transactionUrl == null) {
        dev.log('Transaction URL not found', name: 'BankService');
        return;
      }

      final url = '${transactionUrl}banklist';
      final response = await _apiService.getrequest(url);

      response.fold(
        (failure) {
          dev.log('Failed to fetch banks: ${failure.message}', name: 'BankService');
        },
        (data) {
          if (data['success'] == 1 && data['data'] != null) {
            final List<dynamic> bankList = data['data'];
            banks.value = bankList.map((item) => BankModel.fromJson(item)).toList();
            
            // Cache the list
            _storage.write('cached_banks_list', jsonEncode(bankList));
            dev.log('Successfully fetched and cached ${banks.length} banks', name: 'BankService');
          }
        },
      );
    } catch (e) {
      dev.log('Error fetching banks: $e', name: 'BankService');
    } finally {
      isLoadingBanks.value = false;
    }
  }
}
