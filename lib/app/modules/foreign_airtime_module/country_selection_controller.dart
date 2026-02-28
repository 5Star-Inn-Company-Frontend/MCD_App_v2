import 'dart:convert';
import 'dart:developer' as dev;
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mcd/app/modules/foreign_airtime_module/models/foreign_airtime_model.dart';
import 'package:mcd/app/routes/app_pages.dart';
import 'package:mcd/core/network/dio_api_service.dart';

class CountrySelectionController extends GetxController {
  final apiService = DioApiService();
  final box = GetStorage();

  static const _cacheKey = 'cached_countries';
  static const _cacheTsKey = 'cached_countries_ts';
  static const _cacheTtlHours = 24;

  // Observables
  final isLoading = true.obs;
  final errorMessage = RxnString();
  final countries = <CountryModel>[].obs;
  final selectedCountry = Rxn<CountryModel>();
  final searchQuery = ''.obs;

  // Filtered countries based on search
  List<CountryModel> get filteredCountries {
    if (searchQuery.value.isEmpty) {
      return countries;
    }
    return countries
        .where((country) => country.name
            .toLowerCase()
            .contains(searchQuery.value.toLowerCase()))
        .toList();
  }

  @override
  void onInit() {
    super.onInit();
    dev.log('CountrySelectionController initialized', name: 'ForeignAirtime');
    fetchCountries();
  }

  Future<void> fetchCountries({bool forceRefresh = false}) async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      // serve from cache if valid and not forced
      if (!forceRefresh && _isCacheValid()) {
        _loadFromCache();
        isLoading.value = false;
        return;
      }

      dev.log('Fetching countries from network...', name: 'ForeignAirtime');

      final transactionUrl = box.read('transaction_service_url');
      if (transactionUrl == null || transactionUrl.isEmpty) {
        errorMessage.value = 'Service URL not configured. Please login again.';
        isLoading.value = false;
        return;
      }

      final url = '${transactionUrl}airtime/countries';
      dev.log('Fetching from: $url', name: 'ForeignAirtime');

      final result = await apiService.getrequest(url);

      result.fold(
        (failure) {
          dev.log('Failed to fetch countries',
              name: 'ForeignAirtime', error: failure.message);
          // fall back to stale cache if available
          if (_hasCache()) {
            dev.log('Using stale cache as fallback', name: 'ForeignAirtime');
            _loadFromCache();
          } else {
            errorMessage.value = failure.message;
          }
          isLoading.value = false;
        },
        (data) {
          dev.log('Countries response: $data', name: 'ForeignAirtime');

          if (data['success'] == 1) {
            final response = CountriesResponse.fromJson(data);
            countries.value = response.countries;
            dev.log('Fetched ${countries.length} countries',
                name: 'ForeignAirtime');
            _writeCache();
          } else {
            errorMessage.value = data['message'] ?? 'Failed to fetch countries';
          }

          isLoading.value = false;
        },
      );
    } catch (e) {
      dev.log('Error fetching countries', name: 'ForeignAirtime', error: e);
      errorMessage.value = 'An error occurred while fetching countries';
      isLoading.value = false;
    }
  }

  bool _hasCache() => box.read(_cacheKey) != null;

  bool _isCacheValid() {
    final raw = box.read(_cacheKey);
    final tsRaw = box.read(_cacheTsKey);
    if (raw == null || tsRaw == null) return false;
    final ts = DateTime.tryParse(tsRaw as String);
    if (ts == null) return false;
    return DateTime.now().difference(ts).inHours < _cacheTtlHours;
  }

  void _loadFromCache() {
    try {
      final raw = box.read(_cacheKey) as String;
      final List<dynamic> decoded = jsonDecode(raw);
      countries.value = decoded
          .map((e) => CountryModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      dev.log('Loaded ${countries.length} countries from cache',
          name: 'ForeignAirtime');
    } catch (e) {
      dev.log('Cache parse error, will refetch',
          name: 'ForeignAirtime', error: e);
      // clear bad cache
      box.remove(_cacheKey);
      box.remove(_cacheTsKey);
    }
  }

  void _writeCache() {
    try {
      final encoded = jsonEncode(countries.map((c) => c.toJson()).toList());
      box.write(_cacheKey, encoded);
      box.write(_cacheTsKey, DateTime.now().toIso8601String());
      dev.log('Countries cached (${countries.length} entries)',
          name: 'ForeignAirtime');
    } catch (e) {
      dev.log('Failed to write countries cache',
          name: 'ForeignAirtime', error: e);
    }
  }

  void selectCountry(CountryModel country) {
    dev.log('Country selected: ${country.name} (${country.code})',
        name: 'ForeignAirtime');
    selectedCountry.value = country;

    // Get the first calling code or empty string
    final callingCode =
        country.callingCodes.isNotEmpty ? country.callingCodes.first : '';

    // Check for return mode
    if (Get.arguments?['returnResult'] == true) {
      Get.back(result: country);
      return;
    }

    // Navigate to number verification with country code
    Get.toNamed(
      Routes.NUMBER_VERIFICATION_MODULE,
      arguments: {
        'redirectTo': Get.arguments?['redirectTo'] ?? Routes.AIRTIME_MODULE,
        'isForeign': true,
        'countryCode': country.code,
        'countryName': country.name,
        'callingCode': callingCode,
      },
    );
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query.trim();
  }
}
