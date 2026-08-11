import 'dart:developer' as dev;
import 'package:get/get.dart';
import 'package:mcd/app/modules/foreign_airtime_module/models/foreign_airtime_model.dart';
import 'package:mcd/app/routes/app_pages.dart';
import 'package:mcd/core/services/country_service.dart';

class CountrySelectionController extends GetxController {
  // Observables
  bool get isLoading => CountryService.to.isLoading.value;
  String get errorMessage => CountryService.to.errorMessage.value;
  RxList<CountryModel> get countries => CountryService.to.countries;
  
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
    await CountryService.to.fetchCountries(forceRefresh: forceRefresh);
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
