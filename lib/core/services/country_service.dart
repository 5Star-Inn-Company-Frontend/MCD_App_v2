import 'dart:convert';
import 'dart:developer' as dev;
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mcd/app/modules/foreign_airtime_module/models/foreign_airtime_model.dart';
import 'package:mcd/core/network/dio_api_service.dart';

class CountryService extends GetxService {
  static CountryService get to => Get.find<CountryService>();

  final DioApiService _apiService = DioApiService();
  final GetStorage _box = GetStorage();

  static const _cacheKey = 'cached_countries';
  static const _cacheTsKey = 'cached_countries_ts';
  static const _cacheTtlHours = 24;

  final RxList<CountryModel> countries = <CountryModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadFromCache();

    // Trigger background refresh if we have a URL
    final url = _box.read('transaction_service_url');
    if (url != null) {
      fetchCountries();
    }
  }

  bool _isCacheValid() {
    final tsRaw = _box.read(_cacheTsKey);
    if (tsRaw != null) {
      final ts = DateTime.tryParse(tsRaw as String);
      if (ts != null &&
          DateTime.now().difference(ts).inHours < _cacheTtlHours &&
          _box.read(_cacheKey) != null) {
        return true;
      }
    }
    return false;
  }

  void _loadFromCache() {
    final cachedData = _box.read(_cacheKey);
    if (cachedData != null) {
      try {
        final List<dynamic> rawList = cachedData is String 
            ? jsonDecode(cachedData) 
            : cachedData;
            
        // Use CountryModel.fromJson on each element
        countries.value = rawList
            .map((e) => CountryModel.fromJson(e as Map<String, dynamic>))
            .toList();
            
        dev.log('Loaded ${countries.length} countries from cache', name: 'CountryService');
      } catch (e) {
        dev.log('Error loading countries from cache: $e', name: 'CountryService');
      }
    }
  }

  void _writeCache(dynamic data) {
    try {
      _box.write(_cacheKey, data);
      _box.write(_cacheTsKey, DateTime.now().toIso8601String());
    } catch (e) {
      dev.log('Error writing countries cache: $e', name: 'CountryService');
    }
  }

  Future<void> fetchCountries({bool forceRefresh = false}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      if (!forceRefresh && _isCacheValid() && countries.isNotEmpty) {
        dev.log('Countries cache valid, skipping network fetch', name: 'CountryService');
        isLoading.value = false;
        return;
      }

      final transactionUrl = _box.read('transaction_service_url');
      if (transactionUrl == null || transactionUrl.isEmpty) {
        errorMessage.value = 'Service URL not configured';
        isLoading.value = false;
        return;
      }

      final url = '${transactionUrl}airtime/countries';
      final result = await _apiService.getrequest(url);

      result.fold(
        (failure) {
          dev.log('Failed to fetch countries: ${failure.message}', name: 'CountryService');
          if (countries.isEmpty) {
            errorMessage.value = failure.message;
          }
        },
        (data) {
          if (data['success'] == 1) {
            final response = CountriesResponse.fromJson(data);
            countries.value = response.countries;
            _writeCache(data); // Cache the raw response data
            dev.log('Fetched ${countries.length} countries from network', name: 'CountryService');
          } else {
            if (countries.isEmpty) {
              errorMessage.value = data['message'] ?? 'Failed to fetch countries';
            }
          }
        },
      );
    } catch (e) {
      dev.log('Exception fetching countries: $e', name: 'CountryService');
      if (countries.isEmpty) {
        errorMessage.value = 'An error occurred while fetching countries';
      }
    } finally {
      isLoading.value = false;
    }
  }
}
