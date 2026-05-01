import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:share_plus/share_plus.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mcd/core/import/imports.dart';
import 'package:mcd/core/network/dio_api_service.dart';
import 'package:mcd/app/styles/app_colors.dart';
import 'models/giveaway_model.dart';
import 'package:mcd/core/services/ads_service.dart';
import 'package:mcd/core/services/deep_link_service.dart';
import 'widgets/giveaway_detail_sheet.dart';

class GiveawayModuleController extends GetxController {
  final apiService = DioApiService();
  final box = GetStorage();
  final adsService = AdsService();

  // Observables
  final _giveaways = <GiveawayModel>[].obs;
  final _myGiveawayCount = 0.obs;
  final _isLoading = false.obs;
  final _isCreating = false.obs;
  final _isNotificationEnabled = true.obs;

  // Getters
  List<GiveawayModel> get giveaways => _giveaways;
  int get myGiveawayCount => _myGiveawayCount.value;
  bool get isLoading => _isLoading.value;
  bool get isCreating => _isCreating.value;
  bool get isNotificationEnabled => _isNotificationEnabled.value;

  // Form controllers
  final amountController = TextEditingController();
  final quantityController = TextEditingController();
  final descriptionController = TextEditingController();
  final receiverController = TextEditingController();

  // Form data
  final _selectedType = 'airtime'.obs;
  final _selectedTypeCode = RxnString('mtn');
  final _selectedImage = Rx<File?>(null);
  final _showContact = true.obs;
  final _isPublic = true.obs;

  // Dynamic Data Lists
  final dataPlans = <Map<String, dynamic>>[].obs;
  final electricityProviders = <Map<String, dynamic>>[].obs;
  final cableProviders = <Map<String, dynamic>>[].obs;
  final cablePackages = <Map<String, dynamic>>[].obs;
  final bettingProviders = <Map<String, dynamic>>[].obs;

  // Selected Items
  final selectedDataPlan = Rxn<Map<String, dynamic>>();
  final selectedElectricityProvider = Rxn<Map<String, dynamic>>();
  final selectedCableProvider = Rxn<Map<String, dynamic>>();
  final selectedCablePackage = Rxn<Map<String, dynamic>>();
  final selectedBettingProvider = Rxn<Map<String, dynamic>>();

  // Helper getters for dropdown values (using codes instead of objects)
  String? get selectedDataPlanCode => selectedDataPlan.value?['coded'];
  String? get selectedElectricityProviderCode =>
      selectedElectricityProvider.value?['code'];
  String? get selectedCableProviderCode => selectedCableProvider.value?['code'];
  String? get selectedCablePackageCode => selectedCablePackage.value?['coded'];
  String? get selectedBettingProviderCode =>
      selectedBettingProvider.value?['code'];

  // Loading States for Dropdowns
  final isFetchingDataPlans = false.obs;
  final isFetchingElectricityProviders = false.obs;
  final isFetchingCableProviders = false.obs;
  final isFetchingCablePackages = false.obs;
  final isFetchingBettingProviders = false.obs;

  String get selectedType => _selectedType.value;
  String? get selectedTypeCode => _selectedTypeCode.value;
  File? get selectedImage => _selectedImage.value;
  bool get showContact => _showContact.value;
  bool get isPublic => _isPublic.value;

  // App lifecycle observer to re-check permissions when user returns from settings
  late final AppLifecycleListener _lifecycleListener;

  @override
  void onInit() {
    super.onInit();
    fetchGiveaways();
    checkNotificationStatus();

    _lifecycleListener = AppLifecycleListener(
      onResume: () => checkNotificationStatus(),
    );

    adsService.showInterstitialAd();

    final uniqueProviders = <String, Map<String, dynamic>>{};
    final providerList = [
      {'name': 'DSTV', 'code': 'DSTV'},
      {'name': 'GOTV', 'code': 'GOTV'},
      {'name': 'STARTIMES', 'code': 'STARTIMES'},
      {'name': 'SHOWMAX', 'code': 'SHOWMAX'},
    ];

    for (var provider in providerList) {
      uniqueProviders[provider['code'] as String] = provider;
    }

    cableProviders.assignAll(uniqueProviders.values.toList());

    ever(_selectedType, (_) {
      _selectedTypeCode.value = null;
      amountController.clear();
      selectedDataPlan.value = null;
      selectedElectricityProvider.value = null;
      selectedCableProvider.value = null;
      selectedCablePackage.value = null;
      selectedBettingProvider.value = null;
      dataPlans.clear();
      cablePackages.clear();
      if (_selectedType.value == 'electricity') fetchElectricityProviders();
      if (_selectedType.value == 'betting_topup') fetchBettingProviders();
    });

    _handleDeepLinkArguments();
  }

  @override
  void onReady() {
    super.onReady();
    // onReady fires after the page is fully pushed onto the navigator stack.
    // this is the correct place to trigger the bottom sheet from deep link args.
    _openDeepLinkSheetIfNeeded();
  }

  void _handleDeepLinkArguments() {
    // only parse and store the id — do not navigate yet
    // actual sheet trigger happens in onReady()
    final args = Get.arguments as Map<String, dynamic>?;
    if (args == null) return;
    dev.log('giveaway module received args: $args', name: 'GiveawayModule');
  }

  void _openDeepLinkSheetIfNeeded() {
    final args = Get.arguments as Map<String, dynamic>?;
    if (args == null || args['id'] == null) return;

    final giveawayId = args['id'] is int
        ? args['id']
        : int.tryParse(args['id'].toString()) ?? 0;
    if (giveawayId == 0) return;

    dev.log('opening detail sheet for deep link: $giveawayId',
        name: 'GiveawayModule');

    // import is in controller already via widgets/giveaway_detail_sheet.dart
    Get.bottomSheet(
      GiveawayDetailSheet(giveawayId: giveawayId),
      isScrollControlled: true,
      ignoreSafeArea: false,
    );
  }

  @override
  void onClose() {
    _lifecycleListener.dispose();
    amountController.dispose();
    quantityController.dispose();
    descriptionController.dispose();
    receiverController.dispose();
    super.onClose();
  }

  Future<void> checkNotificationStatus() async {
    try {
      final settings =
          await FirebaseMessaging.instance.getNotificationSettings();
      final isAuthorized =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
              settings.authorizationStatus == AuthorizationStatus.provisional;

      final appLevelEnabled =
          box.read('giveaway_notification_enabled') ?? false;

      _isNotificationEnabled.value = isAuthorized && appLevelEnabled;
      dev.log(
          'Notification status check: isAuthorized=$isAuthorized, appLevelEnabled=$appLevelEnabled',
          name: 'GiveawayModule');
    } catch (e) {
      dev.log('Error checking notification status',
          error: e, name: 'GiveawayModule');
    }
  }

  Future<void> enableNotifications() async {
    try {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        await FirebaseMessaging.instance.subscribeToTopic('giveaway');
        box.write('giveaway_notification_enabled', true);
        _isNotificationEnabled.value = true;

        Get.snackbar(
          'Success',
          'Notifications enabled and subscribed to giveaways',
          backgroundColor: AppColors.successBgColor,
          colorText: AppColors.textSnackbarColor,
        );
      } else {
        Get.snackbar(
          'Permission Denied',
          'Please enable notifications in your device settings to receive giveaways.',
          backgroundColor: AppColors.errorBgColor,
          colorText: AppColors.textSnackbarColor,
        );
      }
    } catch (e) {
      dev.log('Error enabling notifications', error: e, name: 'GiveawayModule');
      Get.snackbar('Error', 'Failed to enable notifications');
    }
  }

  // Fetch all giveaways
  Future<void> fetchGiveaways() async {
    try {
      _isLoading.value = true;

      final utilityUrl = box.read('utility_service_url') ?? '';
      final url = '${utilityUrl}fetch-giveaways';
      final response = await apiService.getrequest(url);

      response.fold(
        (failure) {
          Get.snackbar(
            'Error',
            failure.message,
            backgroundColor: AppColors.errorBgColor,
            colorText: AppColors.textSnackbarColor,
          );
        },
        (data) {
          if (data['success'] == 1) {
            final giveawaysData = data['data'] as List;
            _giveaways.value =
                giveawaysData.map((e) => GiveawayModel.fromJson(e)).toList();
            _myGiveawayCount.value = data['mygiveaway'] ?? 0;
          } else {
            Get.snackbar(
              'Error',
              data['message'] ?? 'Failed to fetch giveaways',
              backgroundColor: AppColors.errorBgColor,
              colorText: AppColors.textSnackbarColor,
            );
          }
        },
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch giveaways: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  // Fetch single giveaway details
  Future<GiveawayDetailModel?> fetchGiveawayDetail(int id) async {
    try {
      final utilityUrl = box.read('utility_service_url') ?? '';
      final url = '${utilityUrl}fetch-giveaway/$id';

      final response = await apiService.getrequest(url);

      GiveawayDetailModel? detailModel;
      response.fold(
        (failure) {
          dev.log('Fetch giveaway detail failed: ${failure.message}',
              name: 'GiveawayModule');
          Get.snackbar(
            'Error',
            failure.message,
            backgroundColor: AppColors.errorBgColor,
            colorText: AppColors.textSnackbarColor,
          );
        },
        (data) {
          if (data['success'] == 1) {
            detailModel = GiveawayDetailModel.fromJson(data['data']);
          }
        },
      );
      return detailModel;
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch giveaway details: $e');
      return null;
    }
  }

  // --- New Methods for Dynamic Dropdowns ---

  Future<void> fetchDataPlans(String networkCode) async {
    try {
      isFetchingDataPlans.value = true;
      dataPlans.clear();
      final transactionUrl = box.read('transaction_service_url');
      if (transactionUrl == null) return;

      final url = '${transactionUrl}data/${networkCode.toUpperCase()}';
      final response = await apiService.getrequest(url);

      response.fold(
        (failure) {
          dev.log('Fetch data plans failed: ${failure.message}',
              name: 'GiveawayModule');
        },
        (data) {
          if (data['data'] != null && data['data'] is List) {
            final plans = List<Map<String, dynamic>>.from(data['data']);
            final uniquePlans = <String, Map<String, dynamic>>{};
            for (var plan in plans) {
              final coded = plan['coded']?.toString() ?? '';
              if (coded.isNotEmpty && !uniquePlans.containsKey(coded)) {
                uniquePlans[coded] = plan;
              }
            }
            dataPlans.assignAll(uniquePlans.values.toList());
          }
        },
      );
    } finally {
      isFetchingDataPlans.value = false;
    }
  }

  Future<void> fetchElectricityProviders() async {
    try {
      isFetchingElectricityProviders.value = true;
      electricityProviders.clear();
      final transactionUrl = box.read('transaction_service_url');
      if (transactionUrl == null) return;

      final url = '${transactionUrl}electricity';
      final response = await apiService.getrequest(url);

      response.fold(
        (failure) {
          dev.log('Fetch electricity providers failed: ${failure.message}',
              name: 'GiveawayModule');
        },
        (data) {
          if (data['data'] != null && data['data'] is List) {
            final providers = List<Map<String, dynamic>>.from(data['data']);
            final uniqueProviders = <String, Map<String, dynamic>>{};
            for (var provider in providers) {
              final code = provider['code']?.toString() ?? '';
              if (code.isNotEmpty && !uniqueProviders.containsKey(code)) {
                uniqueProviders[code] = provider;
              }
            }
            electricityProviders.assignAll(uniqueProviders.values.toList());
          }
        },
      );
    } finally {
      isFetchingElectricityProviders.value = false;
    }
  }

  // Cable providers are now static and initialized in onInit()
  // No need for fetchCableProviders() method

  Future<void> fetchCablePackages(String providerCode) async {
    try {
      isFetchingCablePackages.value = true;
      cablePackages.clear();
      final transactionUrl = box.read('transaction_service_url');
      if (transactionUrl == null) return;

      final url = '${transactionUrl}tv/$providerCode';
      final response = await apiService.getrequest(url);

      response.fold(
        (failure) {
          dev.log('Fetch cable packages failed: ${failure.message}',
              name: 'GiveawayModule');
        },
        (data) {
          if (data['data'] != null && data['data'] is List) {
            final packages = List<Map<String, dynamic>>.from(data['data']);
            final uniquePackages = <String, Map<String, dynamic>>{};
            for (var package in packages) {
              final code = package['code']?.toString() ??
                  package['coded']?.toString() ??
                  '';
              if (code.isNotEmpty && !uniquePackages.containsKey(code)) {
                uniquePackages[code] = package;
              }
            }
            cablePackages.assignAll(uniquePackages.values.toList());
          }
        },
      );
    } finally {
      isFetchingCablePackages.value = false;
    }
  }

  Future<void> fetchBettingProviders() async {
    try {
      isFetchingBettingProviders.value = true;
      bettingProviders.clear();
      final transactionUrl = box.read('transaction_service_url');
      if (transactionUrl == null) return;

      final url = '${transactionUrl}betting';
      final response = await apiService.getrequest(url);

      response.fold(
        (failure) {
          dev.log('Fetch betting providers failed: ${failure.message}',
              name: 'GiveawayModule');
        },
        (data) {
          if (data['data'] != null && data['data'] is List) {
            final providers = List<Map<String, dynamic>>.from(data['data']);
            final uniqueProviders = <String, Map<String, dynamic>>{};
            for (var provider in providers) {
              final code = provider['code']?.toString() ?? '';
              if (code.isNotEmpty && !uniqueProviders.containsKey(code)) {
                uniqueProviders[code] = provider;
              }
            }
            bettingProviders.assignAll(uniqueProviders.values.toList());
          }
        },
      );
    } finally {
      isFetchingBettingProviders.value = false;
    }
  }

  // --- Selection Setters ---

  void setType(String type) {
    _selectedType.value = type;
  }

  void setTypeCode(String? code) {
    _selectedTypeCode.value = code;
    if (code != null) {
      if (_selectedType.value == 'data') {
        fetchDataPlans(code);
      } else if (_selectedType.value == 'tv') {
        fetchCablePackages(code);
      }
    }
  }

  void setDataPlan(String? planCode) {
    if (planCode != null) {
      final plan = dataPlans.firstWhere(
        (p) => p['coded'] == planCode,
        orElse: () => <String, dynamic>{},
      );
      if (plan.isNotEmpty) {
        selectedDataPlan.value = plan;
        final price = plan['price'] ?? plan['amount'] ?? '0';
        amountController.text = price.toString();
      }
    } else {
      selectedDataPlan.value = null;
    }
  }

  void setElectricityProvider(String? providerCode) {
    if (providerCode != null) {
      final provider = electricityProviders.firstWhere(
        (p) => p['code'] == providerCode,
        orElse: () => <String, dynamic>{},
      );
      if (provider.isNotEmpty) {
        selectedElectricityProvider.value = provider;
      }
    } else {
      selectedElectricityProvider.value = null;
    }
  }

  void setCableProvider(String? providerCode) {
    selectedCablePackage.value = null;
    cablePackages.clear();

    if (providerCode != null) {
      final provider = cableProviders.firstWhere(
        (p) => p['code'] == providerCode,
        orElse: () => <String, dynamic>{},
      );
      if (provider.isNotEmpty) {
        selectedCableProvider.value = provider;
        fetchCablePackages(provider['code']);
      }
    } else {
      selectedCableProvider.value = null;
    }
  }

  void setCablePackage(String? packageCode) {
    if (packageCode != null) {
      final package = cablePackages.firstWhere(
        (p) => p['coded'] == packageCode,
        orElse: () => <String, dynamic>{},
      );
      if (package.isNotEmpty) {
        selectedCablePackage.value = package;
        final amount = package['amount'] ?? package['price'] ?? '0';
        amountController.text = amount.toString();
      }
    } else {
      selectedCablePackage.value = null;
    }
  }

  void setBettingProvider(String? providerCode) {
    if (providerCode != null) {
      final provider = bettingProviders.firstWhere(
        (p) => p['code'] == providerCode,
        orElse: () => <String, dynamic>{},
      );
      if (provider.isNotEmpty) {
        selectedBettingProvider.value = provider;
      }
    } else {
      selectedBettingProvider.value = null;
    }
  }

  void setShowContact(bool value) => _showContact.value = value;
  void setIsPublic(bool value) => _isPublic.value = value;

  // Create giveaway
  Future<bool> createGiveaway() async {
    if (!_validateCreateForm()) return false;

    try {
      _isCreating.value = true;

      String? base64Image;
      if (_selectedImage.value != null) {
        final bytes = await _selectedImage.value!.readAsBytes();
        // base64Image = 'data:image/png;base64,${base64Encode(bytes)}';
        base64Image = base64Encode(bytes);
      }

      String finalTypeCode = '';

      switch (_selectedType.value) {
        case 'airtime':
          finalTypeCode = _selectedTypeCode.value ?? '';
          break;
        case 'data':
          if (selectedDataPlan.value != null) {
            finalTypeCode = selectedDataPlan.value!['coded'] ?? '';
          }
          break;
        case 'electricity':
          if (selectedElectricityProvider.value != null) {
            finalTypeCode = selectedElectricityProvider.value!['code'] ?? '';
          }
          break;
        case 'tv':
          if (selectedCablePackage.value != null) {
            finalTypeCode = selectedCablePackage.value!['code'] ??
                selectedCablePackage.value!['coded'] ??
                '';
          }
          break;
        case 'betting_topup':
          if (selectedBettingProvider.value != null) {
            finalTypeCode = selectedBettingProvider.value!['code'] ?? '';
          }
          break;
        default:
          finalTypeCode = _selectedTypeCode.value ?? '';
      }

      final body = {
        'amount': amountController.text,
        'quantity': int.parse(quantityController.text),
        'type': _selectedType.value,
        'type_code': finalTypeCode,
        'image': base64Image ?? '',
        'description': descriptionController.text,
        'public': _isPublic.value ? 'yes' : 'no',
      };

      final utilityUrl = box.read('utility_service_url') ?? '';
      final url = '${utilityUrl}create-giveaway';

      final response = await apiService.postrequest(url, body);

      bool success = false;
      int giveawayId = 0;
      await response.fold(
        (failure) {
          dev.log('Create Giveaway Error - ${failure.message}',
              name: 'GiveawayModule');
          Get.snackbar(
            'Error',
            failure.message,
            backgroundColor: AppColors.errorBgColor,
            colorText: AppColors.textSnackbarColor,
          );
        },
        (data) {
          dev.log('create giveaway response: $data', name: 'GiveawayModule');
          if (data['success'] == 1) {
            dev.log('RESULT: Giveaway created successfully',
                name: 'GiveawayModule');
            Get.snackbar(
              'Success',
              data['message'] ?? 'Giveaway created successfully',
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );
            success = true;

            final dynamic rawId = data['id'] ?? data['data']?['id'];
            if (rawId != null) {
              if (rawId is int) {
                giveawayId = rawId;
              } else if (rawId is String) {
                giveawayId = int.tryParse(rawId) ?? 0;
              }
            }
            dev.log('Captured Giveaway ID: $giveawayId',
                name: 'GiveawayModule');
          } else {
            dev.log('RESULT: Create failed, message: ${data['message']}',
                name: 'GiveawayModule');
            Get.snackbar(
              'Error',
              data['message'] ?? 'Failed to create giveaway',
            );
          }
        },
      );

      if (success) {
        final isPrivate = _isPublic.value == false;
        dev.log('Giveaway visibility - isPrivate: $isPrivate',
            name: 'GiveawayModule');

        final savedDescription = descriptionController.text;
        final savedType = _selectedType.value;

        _clearForm();
        await fetchGiveaways(); // Refresh the giveaway list

        if (giveawayId == 0) {
          dev.log('ID missing from response, searching refreshed list...',
              name: 'GiveawayModule');
          try {
            final match = _giveaways.firstWhere(
              (g) => g.description == savedDescription && g.type == savedType,
            );
            giveawayId = match.id;
            dev.log('Found matching giveaway ID: $giveawayId',
                name: 'GiveawayModule');
          } catch (_) {
            dev.log('Could not find matching giveaway in list',
                name: 'GiveawayModule');
          }
        }

        if (giveawayId != 0) {
          _showShareLinkDialog(giveawayId);
        } else {
          Get.offNamed(Routes.GIVEAWAY_MODULE);
        }
      }

      return success;
    } catch (e) {
      Get.snackbar('Error', 'Failed to create giveaway: $e');
      return false;
    } finally {
      _isCreating.value = false;
    }
  }

  // Claim giveaway
  Future<bool> claimGiveaway(int giveawayId, String receiver) async {
    if (receiver.isEmpty) {
      Get.snackbar('Error', 'Please enter phone number');
      return false;
    }

    try {
      final body = {
        'giveaway_id': giveawayId,
        'receiver': receiver,
      };

      final utilityUrl = box.read('utility_service_url') ?? '';
      final url = '${utilityUrl}request-giveaway';
      final response = await apiService.postrequest(url, body);

      bool success = false;
      response.fold(
        (failure) {
          dev.log('Claim giveaway failed: ${failure.message}',
              name: 'GiveawayModule');
          Get.snackbar(
            'Error',
            failure.message,
            backgroundColor: AppColors.errorBgColor,
            colorText: AppColors.textSnackbarColor,
          );
        },
        (data) {
          if (data['success'] == 1) {
            dev.log('Giveaway claimed successfully', name: 'GiveawayModule');
            Get.snackbar(
              'Success',
              data['message'] ?? 'Giveaway claimed successfully',
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );
            fetchGiveaways();
            success = true;
          } else {
            dev.log('Claim failed: ${data['message']}', name: 'GiveawayModule');
            Get.snackbar(
              'Error',
              data['message'] ?? 'Failed to claim giveaway',
            );
          }
        },
      );
      return success;
    } catch (e) {
      Get.snackbar('Error', 'Failed to claim giveaway: $e');
      return false;
    }
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      _selectedImage.value = File(image.path);
    }
  }

  void shareGiveaway(int id) {
    final link = DeepLinkService.buildClaimLink(id);
    Share.share(
      'Claim my giveaway on MEGA Cheap Data!\n\n$link\n\n(If it opens in browser, look for an "Open in App" option.)',
    );
  }

  // Show Ad Dialog first
  Future<void> showAdClaimDialogFirst(
      int giveawayId, String giveawayType, BuildContext context) async {
    // SECURITY: Double check status before showing ad
    final latestDetail = await fetchGiveawayDetail(giveawayId);
    if (latestDetail == null || latestDetail.completed || latestDetail.giveaway.status != 1) {
      Get.snackbar(
        'Expired',
        'Sorry, this giveaway has just been fully claimed.',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: AppColors.primaryColor,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Watch Ad to Claim',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: AppFonts.manRope,
                  color: AppColors.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'To claim this giveaway, please watch some ads.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.primaryGrey2,
                  fontFamily: AppFonts.manRope,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: AppColors.primaryGrey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: AppColors.primaryGrey,
                          fontWeight: FontWeight.w600,
                          fontFamily: AppFonts.manRope,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back(); // Close ad dialog
                        _showRewardedAdThenRecipient(
                            giveawayId, giveawayType, context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Watch Ad',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontFamily: AppFonts.manRope,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  // Show rewarded ad then recipient dialog
  Future<void> _showRewardedAdThenRecipient(
      int giveawayId, String giveawayType, BuildContext context) async {
    // Show loading indicator
    Get.dialog(
      const Center(
        child: CircularProgressIndicator(
          color: AppColors.primaryColor,
        ),
      ),
      barrierDismissible: false,
    );

    try {
      final success = await adsService.showRewardedAd(
        onRewarded: () {
          // Ad watched successfully
        },
      );

      Get.back(); // Close loading indicator

      if (success) {
        // Ad watched successfully, now show recipient dialog
        _showRecipientDialogAfterAd(context, giveawayId, giveawayType);
      } else {
        Get.snackbar(
          'Ad Failed',
          'Failed to load ad. Please try again later.',
          backgroundColor: AppColors.errorBgColor,
          colorText: AppColors.white,
        );
      }
    } catch (e) {
      Get.back(); // Close loading
      Get.snackbar('Error', 'An error occurred: $e');
    }
  }

  // Show recipient dialog after ad is watched
  void _showRecipientDialogAfterAd(
      BuildContext context, int giveawayId, String giveawayType) {
    String inputLabel;
    String inputHint;
    TextInputType keyboardType;

    switch (giveawayType.toLowerCase()) {
      case 'airtime':
      case 'data':
        inputLabel = 'Phone Number';
        inputHint = 'Enter phone number';
        keyboardType = TextInputType.phone;
        break;
      case 'electricity':
        inputLabel = 'Meter Number';
        inputHint = 'Enter meter number';
        keyboardType = TextInputType.number;
        break;
      case 'tv':
        inputLabel = 'Smart Card Number';
        inputHint = 'Enter smart card number';
        keyboardType = TextInputType.number;
        break;
      case 'betting_topup':
        inputLabel = 'Customer ID';
        inputHint = 'Enter betting account ID';
        keyboardType = TextInputType.text;
        break;
      default:
        inputLabel = 'Recipient';
        inputHint = 'Enter recipient details';
        keyboardType = TextInputType.text;
    }

    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                inputLabel,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: AppFonts.manRope,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter the $inputLabel for the giveaway recipient',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.primaryGrey2,
                  fontFamily: AppFonts.manRope,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: receiverController,
                keyboardType: keyboardType,
                decoration: InputDecoration(
                  hintText: inputHint,
                  hintStyle: const TextStyle(
                    color: AppColors.primaryGrey2,
                    fontFamily: AppFonts.manRope,
                  ),
                  filled: true,
                  fillColor: AppColors.filledInputColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xffE5E5E5)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xffE5E5E5)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.primaryColor),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        receiverController.clear();
                        Get.back();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppColors.primaryGrey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: AppColors.primaryGrey,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final receiver = receiverController.text.trim();
                        if (receiver.isEmpty) {
                          Get.snackbar('Error', 'Please enter $inputLabel');
                          return;
                        }
                        Get.back(); // Close dialog
                        final claimed =
                            await claimGiveaway(giveawayId, receiver);
                        if (claimed) {
                          receiverController.clear();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Claim',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  // Show Ad Dialog before claiming (old flow - kept for backward compatibility)
  void showAdClaimDialog(int giveawayId, String receiver) {
    // Close any previous dialogs (like the input dialog)
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }

    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: AppColors.primaryColor,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Watch Ad to Claim',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: AppFonts.manRope,
                  color: AppColors.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'To claim this giveaway, please watch some ads to support the creator.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.primaryGrey2,
                  fontFamily: AppFonts.manRope,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: AppColors.primaryGrey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: AppColors.primaryGrey,
                          fontWeight: FontWeight.w600,
                          fontFamily: AppFonts.manRope,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back(); // Close dialog
                        _showRewardedAd(giveawayId, receiver);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Watch Ad',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontFamily: AppFonts.manRope,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _showRewardedAd(int giveawayId, String receiver) async {
    // Show loading indicator
    Get.dialog(
      const Center(
        child: CircularProgressIndicator(
          color: AppColors.primaryColor,
        ),
      ),
      barrierDismissible: false,
    );

    try {
      final success = await adsService.showRewardedAd(
        onRewarded: () {
          // This callback might be called when user earns reward
          // We'll handle logic in the success check below mostly,
          // but for safety we can ensure we don't double claim.
        },
      );

      Get.back(); // Close loading indicator

      if (success) {
        // Proceed to claim
        final claimed = await claimGiveaway(giveawayId, receiver);
        if (claimed) {
          receiverController.clear();
          if (Get.isBottomSheetOpen ?? false) {
            Get.back(); // Close details sheet if open
          }
        }
      } else {
        Get.snackbar(
          'Ad Failed',
          'Failed to load ad. Please try again later.',
          backgroundColor: AppColors.errorBgColor,
          colorText: AppColors.white,
        );
      }
    } catch (e) {
      Get.back(); // Close loading
      Get.snackbar('Error', 'An error occurred: $e');
    }
  }

  bool _validateCreateForm() {
    if (amountController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter amount');
      return false;
    }

    final amount = double.tryParse(amountController.text);
    if (amount == null || amount < 100) {
      Get.snackbar(
        'Invalid Amount',
        'Minimum amount for creating a giveaway is ₦100',
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.white,
      );
      return false;
    }

    if (quantityController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter quantity');
      return false;
    }
    if (descriptionController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter description');
      return false;
    }
    if (_selectedImage.value == null) {
      Get.snackbar('Error', 'Please select an image',
          backgroundColor: AppColors.errorBgColor, colorText: AppColors.white);
      return false;
    }

    if (_selectedType.value == 'data' && selectedDataPlan.value == null) {
      Get.snackbar('Error', 'Please select a data plan');
      return false;
    }
    if (_selectedType.value == 'electricity' &&
        selectedElectricityProvider.value == null) {
      Get.snackbar('Error', 'Please select a provider');
      return false;
    }
    if (_selectedType.value == 'tv' && selectedCablePackage.value == null) {
      Get.snackbar('Error', 'Please select a package');
      return false;
    }
    if (_selectedType.value == 'betting_topup' &&
        selectedBettingProvider.value == null) {
      Get.snackbar('Error', 'Please select a provider');
      return false;
    }
    if (_selectedTypeCode.value == null &&
        (_selectedType.value == 'airtime' || _selectedType.value == 'data')) {
      Get.snackbar('Error', 'Please select a network');
      return false;
    }

    return true;
  }

  void _clearForm() {
    amountController.clear();
    quantityController.clear();
    descriptionController.clear();
    _selectedImage.value = null;
    _selectedType.value = 'airtime';
    _selectedTypeCode.value = 'mtn';
    selectedDataPlan.value = null;
    selectedElectricityProvider.value = null;
    selectedCableProvider.value = null;
    selectedCablePackage.value = null;
    selectedBettingProvider.value = null;
    _isPublic.value = true;
  }

  void _showShareLinkDialog(int id) {
    final link = DeepLinkService.buildClaimLink(id);
    Get.defaultDialog(
      contentPadding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
      title: 'Giveaway created',
      titleStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        fontFamily: AppFonts.manRope,
        color: AppColors.textPrimaryColor,
      ),
      middleText:
          'Share this private link with anyone you want to claim your giveaway.',
      middleTextStyle: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        fontFamily: AppFonts.manRope,
        color: AppColors.primaryGrey2,
        height: 1.4,
      ),
      content: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.filledInputColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xffE5E5E5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Private claim link',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    fontFamily: AppFonts.manRope,
                    color: AppColors.primaryGrey2,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: SelectableText(
                        link,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          fontFamily: AppFonts.manRope,
                          color: AppColors.primaryColor,
                          height: 1.35,
                        ),
                      ),
                    ),
                    const Gap(8),
                    IconButton(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: link));
                        Get.snackbar(
                          'Copied',
                          'Link copied to clipboard',
                          snackPosition: SnackPosition.TOP,
                          backgroundColor: AppColors.primaryColor,
                          colorText: Colors.white,
                          duration: const Duration(seconds: 2),
                        );
                      },
                      icon:
                          const Icon(Icons.copy, color: AppColors.primaryColor),
                      tooltip: 'Copy link',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Share.share(
                  'Claim my giveaway on MEGA Cheap Data!\n\n$link\n\n(If it opens in browser, look for an "Open in App" option.)',
                );
              },
              icon: const Icon(Icons.share),
              label: const Text(
                'Share link',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  fontFamily: AppFonts.manRope,
                ),
              ),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
      confirm: Align(
        alignment: Alignment.centerRight,
        child: ElevatedButton(
          onPressed: () {
            Get.back();
            Get.offNamed(Routes.GIVEAWAY_MODULE);
          },
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: AppColors.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            'Done',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              fontFamily: AppFonts.manRope,
            ),
          ),
        ),
      ),
      onConfirm: () {
        Get.back();
        Get.offNamed(Routes.GIVEAWAY_MODULE);
      },
    );
  }
}
