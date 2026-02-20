import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/material.dart';
import 'package:mcd/app/routes/app_pages.dart';
import 'package:mcd/app/modules/data_module/model/data_plan_model.dart';
import 'package:mcd/app/modules/data_module/network_provider.dart';
import 'package:mcd/app/modules/general_payout/general_payout_controller.dart';
import 'package:mcd/app/styles/app_colors.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/network/dio_api_service.dart';
import 'dart:developer' as dev;

import '../../utils/strings.dart';

class DataModuleController extends GetxController {
  final apiService = DioApiService();
  final box = GetStorage();

  final phoneController = TextEditingController();
  final networkProviders = <NetworkProvider>[].obs;
  final selectedNetworkProvider = Rxn<NetworkProvider>();

  // State for the data plans
  final _allDataPlansForNetwork = <DataPlanModel>[].obs;
  final filteredDataPlans = <DataPlanModel>[].obs;
  final selectedPlan = Rxn<DataPlanModel>(); // To track the tapped plan

  // State for the custom tab bar, mimicking the old UI
  final tabBarItems = ['Daily', 'Night', 'Weekend', 'Weekly', 'Monthly'].obs;
  final selectedTab = 'Daily'.obs;

  // Amount filter options
  final amountFilters = ['All', '< 200', '< 500', '< 1000', '< 1500'].obs;
  final selectedAmountFilter = 'All'.obs;

  // Loading and Error States
  final isLoading = true.obs;
  final isPaying = false.obs;
  final errorMessage = RxnString();

  // Foreign Data State
  bool isForeign = false;
  String? countryCode;
  String? verifiedNetworkName;

  @override
  void onInit() {
    super.onInit();
    // Check if we have a verified number and network from navigation
    final verifiedNumber = Get.arguments?['verifiedNumber'];
    final verifiedNetwork = Get.arguments?['verifiedNetwork'];

    if (verifiedNumber != null) {
      phoneController.text = verifiedNumber;
    }

    isForeign = Get.arguments?['isForeign'] ?? false;
    countryCode = Get.arguments?['countryCode'];
    verifiedNetworkName = verifiedNetwork;

    if (isForeign) {
      // For foreign data, create a single provider for the verified network
      final provider = NetworkProvider(
          name: verifiedNetwork ?? 'Unknown',
          imageAsset:
              'assets/images/mcdlogo.png'); // Use generic logo or fetch dynamic if possible
      networkProviders.value = [provider];
      onNetworkSelected(provider);
      dev.log(
          'Foreign Data Mode: Initialized for $verifiedNetwork ($countryCode)');
    } else {
      networkProviders.value = NetworkProvider.all;
    }

    // Pre-select network if verified (and not already handled by foreign logic above)
    if (!isForeign && verifiedNetwork != null && networkProviders.isNotEmpty) {
      dev.log('Data Module - Trying to match network: "$verifiedNetwork"');

      // Normalize the network name for matching
      final normalizedInput = _normalizeNetworkName(verifiedNetwork);
      dev.log('Normalized input: "$normalizedInput"');

      final matchedProvider = networkProviders.firstWhereOrNull((provider) =>
          _normalizeNetworkName(provider.name) == normalizedInput);

      if (matchedProvider != null) {
        onNetworkSelected(matchedProvider);
        dev.log('Pre-selected verified network: ${matchedProvider.name}');
      } else {
        onNetworkSelected(networkProviders.first);
        dev.log(
            'Network "$verifiedNetwork" not found, auto-selected first: ${networkProviders.first.name}');
      }
    } else if (networkProviders.isNotEmpty) {
      onNetworkSelected(networkProviders.first);
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
          dev.log('Selected contact number: $number', name: 'DataModule');

          // detect network from phone prefix and update
          final detectedNetwork = _detectNetworkFromNumber(number);
          dev.log('Detected network: $detectedNetwork', name: 'DataModule');
          if (detectedNetwork != null) {
            final matchedProvider = networkProviders.firstWhereOrNull(
                (provider) =>
                    _normalizeNetworkName(provider.name) ==
                    _normalizeNetworkName(detectedNetwork));
            dev.log(
                'Matched provider: ${matchedProvider?.name}, Current: ${selectedNetworkProvider.value?.name}',
                name: 'DataModule');
            if (matchedProvider != null &&
                matchedProvider != selectedNetworkProvider.value) {
              onNetworkSelected(matchedProvider);
              dev.log('Auto-switched to network: ${matchedProvider.name}',
                  name: 'DataModule');
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
      dev.log('Error picking contact', name: 'DataModule', error: e);
      Get.snackbar(
        'Error',
        'Failed to pick contact. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void onNetworkSelected(NetworkProvider? provider) {
    if (provider == null || provider == selectedNetworkProvider.value) return;
    selectedNetworkProvider.value = provider;
    fetchDataPlansForNetwork();
  }

  void onTabSelected(String tabName) {
    selectedTab.value = tabName;
    _filterPlansByTab();
  }

  void onAmountFilterSelected(String filter) {
    selectedAmountFilter.value = filter;
    _filterPlansByTab();
  }

  void onPlanSelected(DataPlanModel plan) {
    selectedPlan.value = plan;
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
        normalized == '9mob') return '9mobile';

    return normalized;
  }

  /// Detect network from Nigerian phone number prefix
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
    if (mtnPrefixes.contains(prefix)) return 'MTN';

    // airtel prefixes
    const airtelPrefixes = [
      '0701',
      '0708',
      '0802',
      '0808',
      '0812',
      '0901',
      '0902',
      '0904',
      '0907',
      '0912'
    ];
    if (airtelPrefixes.contains(prefix)) return 'Airtel';

    // glo prefixes
    const gloPrefixes = [
      '0705',
      '0805',
      '0807',
      '0811',
      '0815',
      '0905',
      '0915'
    ];
    if (gloPrefixes.contains(prefix)) return 'Glo';

    // 9mobile prefixes
    const nineMobilePrefixes = ['0809', '0817', '0818', '0908', '0909'];
    if (nineMobilePrefixes.contains(prefix)) return '9mobile';

    return null;
  }

  Future<void> fetchDataPlansForNetwork() async {
    if (selectedNetworkProvider.value == null) return;
    try {
      isLoading.value = true;
      errorMessage.value = null;
      _allDataPlansForNetwork.clear();
      final transactionUrl = box.read('transaction_service_url');
      if (transactionUrl == null || transactionUrl.isEmpty) {
        errorMessage.value = "Service URL not found.";
        return;
      }

      if (isForeign) {
        dev.log(
            "Fetching foreign data for $countryCode, network: $verifiedNetworkName");
        final url =
            '${transactionUrl}foreign_data/$countryCode';
        dev.log("Foreign Data URL: $url");

        final result = await apiService.getrequest(url);
        dev.log("Foreign Data Response: $result");

        result.fold(
          (failure) => errorMessage.value = failure.message,
          (data) {
            dev.log("Foreign Data Full Response: $data");
            
            // Check if data is a list of providers
            if (data['data'] != null && data['data'] is List) {
              final providersList = data['data'] as List;
              dev.log("Foreign Data Providers List: $providersList");
              
              final List<DataPlanModel> parsedPlans = [];
              
              // Iterate through each provider
              for (var provider in providersList) {
                if (provider is Map<String, dynamic>) {
                  final name = provider['name'] ?? 'Unknown';
                  final operatorId = provider['operatorId']?.toString() ?? '';
                  final fixedAmountsDescriptions = provider['fixedAmountsDescriptions'];
                  
                  if (fixedAmountsDescriptions != null && fixedAmountsDescriptions is Map) {
                    fixedAmountsDescriptions.forEach((price, description) {
                      // Infer category
                      String category = 'Others';
                      final descLower = description.toString().toLowerCase();
                      if (descLower.contains('daily') || descLower.contains('day')) {
                        category = 'Daily';
                      } else if (descLower.contains('weekly') || descLower.contains('week')) {
                        category = 'Weekly';
                      } else if (descLower.contains('monthly') || descLower.contains('month')) {
                        category = 'Monthly';
                      } else if (descLower.contains('weekend')) {
                        category = 'Weekend';
                      } else if (descLower.contains('night')) {
                        category = 'Night';
                      }

                      parsedPlans.add(DataPlanModel(
                        name: description.toString(),
                        coded: price.toString(),
                        price: price.toString(),
                        network: name,
                        category: category,
                        id: 0,
                        operatorId: operatorId,
                      ));
                    });
                  }
                }
              }
              
              if (parsedPlans.isEmpty) {
                errorMessage.value = "No data plans found for this country.";
                return;
              }
              
              // Update categories tab
              tabBarItems.assignAll(parsedPlans.map((e) => e.category).toSet().toList());
              // Sort categories to have typical order if possible
              tabBarItems.sort((a, b) {
                final order = ['Daily', 'Night', 'Weekend', 'Weekly', 'Monthly', 'Others'];
                return order.indexOf(a).compareTo(order.indexOf(b));
              });

              _allDataPlansForNetwork.assignAll(parsedPlans);

              if (tabBarItems.isNotEmpty) {
                onTabSelected(tabBarItems.first);
              }
            } 
            // Original format check (single provider object)
            else if (data['data'] != null && data['data'] is Map) {
              final dataMap = data['data'] as Map<String, dynamic>;
              final name = dataMap['name'] ?? 'Unknown';
              final operatorId = dataMap['operatorId']?.toString() ?? '';
              final fixedAmountsDescriptions =
                  dataMap['fixedAmountsDescriptions'];

              if (fixedAmountsDescriptions != null &&
                  fixedAmountsDescriptions is Map) {
                final List<DataPlanModel> parsedPlans = [];

                fixedAmountsDescriptions.forEach((price, description) {
                  // Infer category
                  String category = 'Others';
                  final descLower = description.toString().toLowerCase();
                  if (descLower.contains('daily') ||
                      descLower.contains('day')) {
                    category = 'Daily';
                  } else if (descLower.contains('weekly') ||
                      descLower.contains('week')) {
                    category = 'Weekly';
                  } else if (descLower.contains('monthly') ||
                      descLower.contains('month')) {
                    category = 'Monthly';
                  } else if (descLower.contains('weekend')) {
                    category = 'Weekend';
                  } else if (descLower.contains('night')) {
                    category = 'Night';
                  }

                  parsedPlans.add(DataPlanModel(
                    name: description.toString(),
                    coded: price.toString(), // Using price as the code/ID
                    price: price.toString(),
                    network: name,
                    category: category,
                    id: 0, // No specific plan ID in this response format
                    operatorId: operatorId,
                  ));
                });

                // Update categories tab
                tabBarItems.assignAll(
                    parsedPlans.map((e) => e.category).toSet().toList());
                // Sort categories to have typical order if possible
                tabBarItems.sort((a, b) {
                  final order = [
                    'Daily',
                    'Night',
                    'Weekend',
                    'Weekly',
                    'Monthly',
                    'Others'
                  ];
                  return order.indexOf(a).compareTo(order.indexOf(b));
                });

                _allDataPlansForNetwork.assignAll(parsedPlans);

                if (tabBarItems.isNotEmpty) {
                  onTabSelected(tabBarItems.first);
                }
              } else {
                errorMessage.value =
                    "No fixed amounts found for this foreign provider.";
              }
            } else {
              errorMessage.value = "Invalid data format received from server.";
            }
          },
        );
      } else {
        final networkName = selectedNetworkProvider.value!.name.toUpperCase();
        final result =
            await apiService.getrequest('$transactionUrl' 'data/$networkName');
        result.fold(
          (failure) => errorMessage.value = failure.message,
          (data) {
            if (data['data'] != null && data['data'] is List) {
              final plansJson = data['data'] as List;
              tabBarItems.assignAll(plansJson
                  .map((item) => item['category'] as String)
                  .toSet()
                  .toList());
              _allDataPlansForNetwork.assignAll(
                  plansJson.map((item) => DataPlanModel.fromJson(item)));
              onTabSelected(tabBarItems
                  .first); // Automatically select the first tab and filter
            } else {
              _allDataPlansForNetwork.clear();
              filteredDataPlans.clear();
              errorMessage.value = "No data plans found for this network.";
            }
          },
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  void _filterPlansByTab() {
    // This logic assumes categories from the API match the tab names.
    // e.g., 'Daily', 'SME', 'Gifting'. You may need to adjust this mapping.
    String filterKey = selectedTab.value.toUpperCase();
    if (filterKey == 'DAILY') {
      // Example: If your API uses a different name like 'SME' for daily plans
      // filterKey = 'SME';
    }

    // First filter by category
    var plansFilteredByCategory = _allDataPlansForNetwork
        .where((plan) => plan.category.toUpperCase() == filterKey);

    // Then filter by amount
    var plansFilteredByAmount = plansFilteredByCategory.where((plan) {
      final price = double.tryParse(plan.price.toString()) ?? 0;
      
      switch (selectedAmountFilter.value) {
        case '< 200':
          return price < 200;
        case '< 500':
          return price < 500;
        case '< 1000':
          return price < 1000;
        case '< 1500':
          return price < 1500;
        case 'All':
        default:
          return true;
      }
    });

    filteredDataPlans.assignAll(plansFilteredByAmount);
    selectedPlan.value = null; // Clear selection when filters change
  }

  void pay() async {
    if (selectedPlan.value == null) {
      Get.snackbar("Error", "Please select a data plan to purchase.",
          backgroundColor: AppColors.errorBgColor,
          colorText: AppColors.textSnackbarColor);
      return;
    }

    if (selectedNetworkProvider.value == null) {
      Get.snackbar("Error", "Network provider is not selected.",
          backgroundColor: AppColors.errorBgColor,
          colorText: AppColors.textSnackbarColor);
      return;
    }

    Get.toNamed(
      Routes.GENERAL_PAYOUT,
      arguments: {
        'paymentType': PaymentType.data,
        'paymentData': {
          'networkProvider': selectedNetworkProvider.value,
          'dataPlan': selectedPlan.value,
          'phoneNumber': phoneController.text,
          'networkImage': selectedNetworkProvider.value!.imageAsset,
          'isForeign': isForeign,
          'countryCode': countryCode,
        },
      },
    );
  }
}
