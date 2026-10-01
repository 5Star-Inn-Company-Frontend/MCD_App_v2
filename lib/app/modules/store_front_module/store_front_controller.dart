import 'package:get/get.dart';
import 'package:mcd/app/modules/store_front_module/widgets/airtime/edit_discount_dialog.dart';
import 'package:mcd/app/modules/store_front_module/widgets/airtime/provider_selection_dialog.dart';
import 'package:mcd/app/modules/store_front_module/widgets/data/data_plan_list_dialog.dart';
import 'package:mcd/app/modules/store_front_module/widgets/data/data_provider_dialog.dart';
import 'package:mcd/app/modules/store_front_module/widgets/data/data_type_dialog.dart';
import 'package:mcd/app/modules/store_front_module/widgets/data/edit_data_plan_dialog.dart';
import 'package:mcd/app/modules/store_front_module/widgets/tv/edit_tv_plan_dialog.dart';
import 'package:mcd/app/modules/store_front_module/widgets/tv/tv_plan_list_dialog.dart';
import 'package:mcd/app/modules/store_front_module/widgets/tv/tv_provider_dialog.dart';

class StoreFrontController extends GetxController {
  final isPayWithCardEnabled = true.obs;
  final isVirtualAccountEnabled = false.obs;
  final isMobileMoneyEnabled = false.obs;

  // Airtime
  final mtnEnabled = true.obs;
  final gloEnabled = true.obs;
  final airtelEnabled = true.obs;
  final etisalatEnabled = true.obs; // 9mobile
  final mtnDiscount = '2'.obs;
  final mcdBaseCost = '3%'.obs;

  // Data Providers
  final mtnDataEnabled = true.obs;
  final gloDataEnabled = true.obs;
  final airtelDataEnabled = true.obs;
  final etisalatDataEnabled = true.obs;

  // Data Types
  final cgDataEnabled = true.obs;
  final smeDataEnabled = true.obs;
  final dgDataEnabled = true.obs;

  // Data Plans
  final plan1GBEnabled = true.obs;
  final plan2GBEnabled = true.obs;
  final plan5GBEnabled = true.obs;
  
  // Data Edit
  final mcdDataBaseCost = 'N350'.obs;
  final dataSellPrice = '400'.obs;

  // TV Providers
  final dstvEnabled = true.obs;
  final gotvEnabled = true.obs;
  final startimesEnabled = true.obs;
  final showmaxEnabled = true.obs;

  // TV Plans
  final tvCompactEnabled = true.obs;
  final tvPremiumEnabled = true.obs;

  // TV Edit
  final mcdTvBaseCost = 'N15,700'.obs;
  final tvSellPrice = '16000'.obs;

  void togglePayWithCard(bool value) => isPayWithCardEnabled.value = value;
  void toggleVirtualAccount(bool value) => isVirtualAccountEnabled.value = value;
  void toggleMobileMoney(bool value) => isMobileMoneyEnabled.value = value;

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

  // --- Dialogs (Airtime) ---
  void showSelectProviderDialog() {
    Get.dialog(
      const ProviderSelectionDialog(),
      barrierDismissible: true,
    );
  }

  void showEditDiscountDialog(String providerName) {
    Get.back(); // Close previous dialog if open
    Get.dialog(
      EditDiscountDialog(providerName: providerName),
      barrierDismissible: true,
    );
  }

  // --- Dialogs (Data) ---
  void showDataProviderDialog() {
    Get.dialog(
      const DataProviderDialog(),
      barrierDismissible: true,
    );
  }

  void showDataTypeDialog(String providerName) {
    Get.back();
    Get.dialog(
      DataTypeDialog(providerName: providerName),
      barrierDismissible: true,
    );
  }

  void showDataPlanListDialog(String providerName, String typeName) {
    Get.back();
    Get.dialog(
      DataPlanListDialog(providerName: providerName, typeName: typeName),
      barrierDismissible: true,
    );
  }

  void showEditDataPlanDialog(String providerName, String typeName, String planName) {
    Get.back();
    Get.dialog(
      EditDataPlanDialog(providerName: providerName, typeName: typeName, planName: planName),
      barrierDismissible: true,
    );
  }

  // --- Dialogs (TV) ---
  void showTvProviderDialog() {
    Get.dialog(
      const TvProviderDialog(),
      barrierDismissible: true,
    );
  }

  void showTvPlanListDialog(String providerName) {
    Get.back();
    Get.dialog(
      TvPlanListDialog(providerName: providerName),
      barrierDismissible: true,
    );
  }

  void showEditTvPlanDialog(String providerName, String planName) {
    Get.back();
    Get.dialog(
      EditTvPlanDialog(providerName: providerName, planName: planName),
      barrierDismissible: true,
    );
  }
}
