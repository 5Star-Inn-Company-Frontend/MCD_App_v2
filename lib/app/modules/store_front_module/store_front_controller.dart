import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:mcd/app/styles/app_colors.dart';
import 'models/storefront_dashboard_model.dart';
import 'models/storefront_plan_model.dart';
import 'models/storefront_provider_model.dart';
import 'models/storefront_usage_model.dart';
import 'repository/store_front_repository.dart';
import 'widgets/airtime/edit_discount_dialog.dart';
import 'widgets/airtime/provider_selection_dialog.dart';
import 'widgets/data/data_plan_list_dialog.dart';
import 'widgets/data/data_provider_dialog.dart';
import 'widgets/data/data_type_dialog.dart';
import 'widgets/data/edit_data_plan_dialog.dart';
import 'widgets/tv/edit_tv_plan_dialog.dart';
import 'widgets/tv/tv_plan_list_dialog.dart';
import 'widgets/tv/tv_provider_dialog.dart';

class StoreFrontController extends GetxController {
  final repository = StoreFrontRepository();

  final isLoadingDashboard = false.obs;
  final isUpdatingProfile = false.obs;
  final isUpdatingPayment = false.obs;

  final dashboardData = Rxn<StorefrontDashboardModel>();
  final usageData = Rxn<StorefrontUsageModel>();

  final storeName = ''.obs;
  final welcomeMessage = ''.obs;
  final storeCode = ''.obs;
  final status = true.obs;
  final whatsappLink = ''.obs;
  final todaySales = 'N0'.obs;
  final customersCount = '0'.obs;
  final todayCommission = 'N0'.obs;

  final isPayWithCardEnabled = true.obs;
  final isVirtualAccountEnabled = false.obs;
  final isMobileMoneyEnabled = false.obs;

  final storeNameController = TextEditingController();
  final welcomeMessageController = TextEditingController();

  final mtnEnabled = true.obs;
  final gloEnabled = true.obs;
  final airtelEnabled = true.obs;
  final etisalatEnabled = true.obs;
  final mtnDiscount = '2'.obs;
  final mcdBaseCost = '3%'.obs;

  final mtnDataEnabled = true.obs;
  final gloDataEnabled = true.obs;
  final airtelDataEnabled = true.obs;
  final etisalatDataEnabled = true.obs;

  final cgDataEnabled = true.obs;
  final smeDataEnabled = true.obs;
  final dgDataEnabled = true.obs;

  final plan1GBEnabled = true.obs;
  final plan2GBEnabled = true.obs;
  final plan5GBEnabled = true.obs;

  final mcdDataBaseCost = 'N350'.obs;
  final dataSellPrice = '400'.obs;

  final dstvEnabled = true.obs;
  final gotvEnabled = true.obs;
  final startimesEnabled = true.obs;
  final showmaxEnabled = true.obs;

  final tvCompactEnabled = true.obs;
  final tvPremiumEnabled = true.obs;

  final mcdTvBaseCost = 'N15,700'.obs;
  final tvSellPrice = '16000'.obs;

  final airtimeProviders = <StorefrontProviderModel>[].obs;
  final dataProviders = <StorefrontProviderModel>[].obs;
  final tvProviders = <StorefrontProviderModel>[].obs;
  final activePlans = <StorefrontPlanModel>[].obs;
  final isLoadingPlans = false.obs;
  final isLoadingAirtime = false.obs;
  final isLoadingData = false.obs;
  final isLoadingTv = false.obs;

  @override
  void onInit() {
    super.onInit();
    dev.log('[StoreFrontController] onInit - initializing and fetching storefront data', name: 'StoreFront');
    fetchDashboard();
    fetchUsage();
    fetchCategoryProviders('airtime');
    fetchCategoryProviders('data');
    fetchCategoryProviders('cabletv');
  }

  @override
  void onClose() {
    storeNameController.dispose();
    welcomeMessageController.dispose();
    super.onClose();
  }

  Future<void> fetchDashboard() async {
    dev.log('[StoreFrontController] fetchDashboard() called', name: 'StoreFront');
    isLoadingDashboard.value = true;
    final result = await repository.getDashboard();
    isLoadingDashboard.value = false;
    result.fold(
      (failure) {
        dev.log('[StoreFrontController] fetchDashboard() FAILED: ${failure.message}', name: 'StoreFront');
      },
      (data) {
        dev.log('[StoreFrontController] fetchDashboard() SUCCESS: store="${data.storeName}", code="${data.storeCode}", link="${data.whatsappLink}", sales=${data.todaySales}', name: 'StoreFront');
        dashboardData.value = data;
        storeName.value = data.storeName;
        welcomeMessage.value = data.welcomeMessage;
        storeCode.value = data.storeCode;
        status.value = data.status;
        whatsappLink.value = data.whatsappLink;

        final currencyFormatter = NumberFormat('#,##0', 'en_US');
        todaySales.value = 'N${currencyFormatter.format(data.todaySales)}';
        customersCount.value = data.customersCount.toString();
        todayCommission.value = 'N${currencyFormatter.format(data.todayCommission)}';

        isPayWithCardEnabled.value = data.acceptCard;
        isVirtualAccountEnabled.value = data.acceptVirtualAccount;
        isMobileMoneyEnabled.value = data.acceptMobileMoney;

        storeNameController.text = data.storeName;
        welcomeMessageController.text = data.welcomeMessage;
      },
    );
  }

  Future<void> fetchUsage() async {
    dev.log('[StoreFrontController] fetchUsage() called', name: 'StoreFront');
    final result = await repository.getUsage();
    result.fold(
      (failure) {
        dev.log('[StoreFrontController] fetchUsage() FAILED: ${failure.message}', name: 'StoreFront');
      },
      (data) {
        dev.log('[StoreFrontController] fetchUsage() SUCCESS: ordersUsed=${data.dailyOrdersUsed}/${data.dailyOrdersLimit}, salesUsed=${data.dailySalesUsed}/${data.dailySalesLimit}, plan=${data.referralPlan}', name: 'StoreFront');
        usageData.value = data;
      },
    );
  }

  Future<void> saveProfile() async {
    dev.log('[StoreFrontController] saveProfile() called: name="${storeNameController.text.trim()}", welcome="${welcomeMessageController.text.trim()}", status=${status.value ? 1 : 0}, code="${storeCode.value}"', name: 'StoreFront');
    isUpdatingProfile.value = true;
    final result = await repository.updateProfile(
      storeName: storeNameController.text.trim(),
      welcomeMessage: welcomeMessageController.text.trim(),
      status: status.value ? 1 : 0,
      storeCode: storeCode.value.isNotEmpty ? storeCode.value : null,
    );
    isUpdatingProfile.value = false;
    result.fold(
      (failure) {
        dev.log('[StoreFrontController] saveProfile() FAILED: ${failure.message}', name: 'StoreFront');
        Get.snackbar(
          'Error',
          failure.message,
          backgroundColor: AppColors.errorBgColor,
          colorText: Colors.white,
        );
      },
      (data) {
        dev.log('[StoreFrontController] saveProfile() SUCCESS: $data', name: 'StoreFront');
        storeName.value = storeNameController.text.trim();
        welcomeMessage.value = welcomeMessageController.text.trim();
        Get.back();
        Get.snackbar(
          'Success',
          'Store profile updated successfully',
          backgroundColor: AppColors.primaryColor,
          colorText: Colors.white,
        );
        fetchDashboard();
      },
    );
  }

  Future<void> togglePayWithCard(bool value) async {
    isPayWithCardEnabled.value = value;
    await _syncPaymentMethods();
  }

  Future<void> toggleVirtualAccount(bool value) async {
    isVirtualAccountEnabled.value = value;
    await _syncPaymentMethods();
  }

  Future<void> toggleMobileMoney(bool value) async {
    isMobileMoneyEnabled.value = value;
    await _syncPaymentMethods();
  }

  Future<void> _syncPaymentMethods() async {
    dev.log('[StoreFrontController] _syncPaymentMethods() called: card=${isPayWithCardEnabled.value}, va=${isVirtualAccountEnabled.value}, mm=${isMobileMoneyEnabled.value}', name: 'StoreFront');
    isUpdatingPayment.value = true;
    final result = await repository.updatePaymentMethods(
      acceptVirtualAccount: isVirtualAccountEnabled.value,
      acceptCard: isPayWithCardEnabled.value,
      acceptMobileMoney: isMobileMoneyEnabled.value,
    );
    isUpdatingPayment.value = false;
    result.fold(
      (failure) {
        dev.log('[StoreFrontController] _syncPaymentMethods() FAILED: ${failure.message}', name: 'StoreFront');
        Get.snackbar(
          'Error',
          failure.message,
          backgroundColor: AppColors.errorBgColor,
          colorText: Colors.white,
        );
      },
      (data) {
        dev.log('[StoreFrontController] _syncPaymentMethods() SUCCESS: $data', name: 'StoreFront');
      },
    );
  }

  void copyWhatsappLink() {
    final link = whatsappLink.value;
    if (link.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: link));
      Get.snackbar(
        'Copied',
        'WhatsApp store link copied to clipboard',
        backgroundColor: AppColors.primaryColor,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'Not Available',
        'Store link is still loading or not configured',
        backgroundColor: AppColors.errorBgColor,
        colorText: Colors.white,
      );
    }
  }

  void shareWhatsappLink() {
    final link = whatsappLink.value;
    if (link.isNotEmpty) {
      Share.share(link, subject: 'Shop from my WhatsApp Storefront');
    } else {
      Get.snackbar(
        'Not Available',
        'Store link is still loading or not configured',
        backgroundColor: AppColors.errorBgColor,
        colorText: Colors.white,
      );
    }
  }

  Future<void> fetchCategoryProviders(String category) async {
    dev.log('[StoreFrontController] fetchCategoryProviders("$category") called', name: 'StoreFront');
    if (category == 'airtime') isLoadingAirtime.value = true;
    if (category == 'data') isLoadingData.value = true;
    if (category == 'cabletv') isLoadingTv.value = true;

    final result = await repository.getCategoryProviders(category);

    if (category == 'airtime') isLoadingAirtime.value = false;
    if (category == 'data') isLoadingData.value = false;
    if (category == 'cabletv') isLoadingTv.value = false;

    result.fold(
      (failure) {
        dev.log('[StoreFrontController] fetchCategoryProviders("$category") FAILED: ${failure.message}', name: 'StoreFront');
      },
      (providers) {
        dev.log('[StoreFrontController] fetchCategoryProviders("$category") SUCCESS: ${providers.length} providers loaded', name: 'StoreFront');
        if (category == 'airtime') {
          airtimeProviders.value = providers;
        } else if (category == 'data') {
          dataProviders.value = providers;
        } else if (category == 'cabletv') {
          tvProviders.value = providers;
        }
      },
    );
  }

  Future<void> updateProviderToggle({
    required String category,
    required String provider,
    required bool isEnabled,
    required double discountPercent,
  }) async {
    dev.log('[StoreFrontController] updateProviderToggle() called: cat=$category, provider=$provider, isEnabled=$isEnabled, discount=$discountPercent', name: 'StoreFront');
    _updateLocalProvider(category, provider, isEnabled: isEnabled, discountPercent: discountPercent);
    final result = await repository.updateProvider(
      category: category,
      provider: provider,
      isEnabled: isEnabled,
      discountPercent: discountPercent,
    );
    result.fold(
      (failure) {
        Get.snackbar(
          'Error',
          failure.message,
          backgroundColor: AppColors.errorBgColor,
          colorText: Colors.white,
        );
        fetchCategoryProviders(category);
      },
      (_) {
        fetchCategoryProviders(category);
      },
    );
  }

  void _updateLocalProvider(String category, String provider, {bool? isEnabled, double? discountPercent}) {
    List<StorefrontProviderModel> list;
    if (category == 'airtime') {
      list = airtimeProviders;
    } else if (category == 'data') {
      list = dataProviders;
    } else if (category == 'cabletv') {
      list = tvProviders;
    } else {
      return;
    }
    final index = list.indexWhere((p) => p.provider.toLowerCase() == provider.toLowerCase());
    if (index != -1) {
      final current = list[index];
      list[index] = current.copyWith(
        isEnabled: isEnabled ?? current.isEnabled,
        discountPercent: discountPercent ?? current.discountPercent,
      );
      if (category == 'airtime') airtimeProviders.refresh();
      if (category == 'data') dataProviders.refresh();
      if (category == 'cabletv') tvProviders.refresh();
    }
  }

  Future<void> fetchPlans({
    required String category,
    required String provider,
    String? type,
  }) async {
    dev.log('[StoreFrontController] fetchPlans() called: cat=$category, provider=$provider, type=$type', name: 'StoreFront');
    isLoadingPlans.value = true;
    final result = await repository.getPlans(
      category: category,
      provider: provider,
      type: type,
    );
    isLoadingPlans.value = false;
    result.fold(
      (failure) {
        dev.log('[StoreFrontController] fetchPlans() FAILED: ${failure.message}', name: 'StoreFront');
      },
      (plans) {
        dev.log('[StoreFrontController] fetchPlans() SUCCESS: ${plans.length} plans loaded', name: 'StoreFront');
        activePlans.value = plans;
      },
    );
  }

  Future<void> updatePlanPrice({
    required String category,
    required String itemCode,
    required double sellPrice,
    required bool isEnabled,
  }) async {
    dev.log('[StoreFrontController] updatePlanPrice() called: cat=$category, itemCode=$itemCode, price=$sellPrice, isEnabled=$isEnabled', name: 'StoreFront');
    await repository.updatePlanPrice(
      category: category,
      itemCode: itemCode,
      sellPrice: sellPrice,
      isEnabled: isEnabled,
    );
  }

  Future<void> updatePlanToggle({
    required String category,
    required StorefrontPlanModel plan,
    required bool isEnabled,
  }) async {
    dev.log('[StoreFrontController] updatePlanToggle() called: cat=$category, itemCode=${plan.itemCode}, isEnabled=$isEnabled', name: 'StoreFront');
    final index = activePlans.indexWhere((p) => p.itemCode == plan.itemCode);
    if (index != -1) {
      activePlans[index] = plan.copyWith(isEnabled: isEnabled);
      activePlans.refresh();
    }
    final result = await repository.updatePlanPrice(
      category: category,
      itemCode: plan.itemCode,
      sellPrice: plan.sellPrice,
      isEnabled: isEnabled,
    );
    result.fold(
      (failure) {
        Get.snackbar(
          'Error',
          failure.message,
          backgroundColor: AppColors.errorBgColor,
          colorText: Colors.white,
        );
        if (index != -1) {
          activePlans[index] = plan;
          activePlans.refresh();
        }
      },
      (_) {},
    );
  }

  Future<bool> updatePlanPriceAndSync({
    required String category,
    required String itemCode,
    required double sellPrice,
    required bool isEnabled,
    required String provider,
    String? type,
  }) async {
    dev.log('[StoreFrontController] updatePlanPriceAndSync() called: cat=$category, itemCode=$itemCode, price=$sellPrice, isEnabled=$isEnabled', name: 'StoreFront');
    final result = await repository.updatePlanPrice(
      category: category,
      itemCode: itemCode,
      sellPrice: sellPrice,
      isEnabled: isEnabled,
    );
    return result.fold(
      (failure) {
        Get.snackbar(
          'Error',
          failure.message,
          backgroundColor: AppColors.errorBgColor,
          colorText: Colors.white,
        );
        return false;
      },
      (_) {
        Get.snackbar(
          'Success',
          'Plan price updated successfully',
          backgroundColor: AppColors.primaryColor,
          colorText: Colors.white,
        );
        fetchPlans(category: category, provider: provider, type: type);
        return true;
      },
    );
  }

  void toggleProvider(String provider, bool value) {
    switch (provider.toLowerCase()) {
      case 'mtn':
        mtnEnabled.value = value;
        break;
      case 'glo':
        gloEnabled.value = value;
        break;
      case 'airtel':
        airtelEnabled.value = value;
        break;
      case '9mobile':
        etisalatEnabled.value = value;
        break;
    }
  }

  void toggleDataProvider(String provider, bool value) {
    switch (provider.toLowerCase()) {
      case 'mtn':
        mtnDataEnabled.value = value;
        break;
      case 'glo':
        gloDataEnabled.value = value;
        break;
      case 'airtel':
        airtelDataEnabled.value = value;
        break;
      case '9mobile':
        etisalatDataEnabled.value = value;
        break;
    }
  }

  void toggleDataType(String type, bool value) {
    switch (type.toLowerCase()) {
      case 'cg':
        cgDataEnabled.value = value;
        break;
      case 'sme':
        smeDataEnabled.value = value;
        break;
      case 'dg':
        dgDataEnabled.value = value;
        break;
    }
  }

  void toggleDataPlan(String plan, bool value) {
    if (plan.contains('1GB')) plan1GBEnabled.value = value;
    if (plan.contains('2GB')) plan2GBEnabled.value = value;
    if (plan.contains('5GB')) plan5GBEnabled.value = value;
  }

  void toggleTvProvider(String provider, bool value) {
    switch (provider.toLowerCase()) {
      case 'dstv':
        dstvEnabled.value = value;
        break;
      case 'gotv':
        gotvEnabled.value = value;
        break;
      case 'startimes':
        startimesEnabled.value = value;
        break;
      case 'showmax':
        showmaxEnabled.value = value;
        break;
    }
  }

  void toggleTvPlan(String plan, bool value) {
    if (plan.contains('Compact')) tvCompactEnabled.value = value;
    if (plan.contains('Premium')) tvPremiumEnabled.value = value;
  }

  void showSelectProviderDialog() {
    if (airtimeProviders.isEmpty) {
      fetchCategoryProviders('airtime');
    }
    Get.dialog(
      const ProviderSelectionDialog(),
      barrierDismissible: true,
    );
  }

  void showEditDiscountDialog(StorefrontProviderModel provider) {
    Get.back();
    Get.dialog(
      EditDiscountDialog(provider: provider),
      barrierDismissible: true,
    );
  }

  void showDataProviderDialog() {
    if (dataProviders.isEmpty) {
      fetchCategoryProviders('data');
    }
    Get.dialog(
      const DataProviderDialog(),
      barrierDismissible: true,
    );
  }

  void showDataTypeDialog(StorefrontProviderModel provider) {
    Get.back();
    Get.dialog(
      DataTypeDialog(provider: provider),
      barrierDismissible: true,
    );
  }

  void showDataPlanListDialog(String providerName, String typeName) {
    Get.back();
    fetchPlans(category: 'data', provider: providerName, type: typeName);
    Get.dialog(
      DataPlanListDialog(providerName: providerName, typeName: typeName),
      barrierDismissible: true,
    );
  }

  void showEditDataPlanDialog({
    required String providerName,
    required String typeName,
    required StorefrontPlanModel plan,
  }) {
    Get.back();
    Get.dialog(
      EditDataPlanDialog(
        providerName: providerName,
        typeName: typeName,
        plan: plan,
      ),
      barrierDismissible: true,
    );
  }

  void showTvProviderDialog() {
    if (tvProviders.isEmpty) {
      fetchCategoryProviders('cabletv');
    }
    Get.dialog(
      const TvProviderDialog(),
      barrierDismissible: true,
    );
  }

  void showTvPlanListDialog(String providerName) {
    Get.back();
    fetchPlans(category: 'cabletv', provider: providerName);
    Get.dialog(
      TvPlanListDialog(providerName: providerName),
      barrierDismissible: true,
    );
  }

  void showEditTvPlanDialog({
    required String providerName,
    required StorefrontPlanModel plan,
  }) {
    Get.back();
    Get.dialog(
      EditTvPlanDialog(
        providerName: providerName,
        plan: plan,
      ),
      barrierDismissible: true,
    );
  }
}
