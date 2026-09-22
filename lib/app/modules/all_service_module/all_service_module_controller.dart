import 'package:get/get.dart';
import 'package:mcd/app/modules/home_screen_module/model/button_model.dart';
import 'package:mcd/app/routes/app_pages.dart';
import 'package:mcd/core/constants/app_asset.dart';
import 'package:mcd/core/controllers/service_status_controller.dart';
import 'package:mcd/core/services/usage_tracker_service.dart';
import 'package:mcd/app/modules/home_screen_module/home_screen_controller.dart';

class AllServiceModuleController extends GetxController {
  
  final Map<String, List<ButtonModel>> categorizedServices = {
    'TOP UP': [],
    'BILLS': [],
    'EARN': [],
    'OTHERS': [],
  };

  @override
  void onInit() {
    super.onInit();
    _loadServices();
  }

  void _loadServices() {
    final ssc = ServiceStatusController.to;
    final rawServices = ssc.getRawServices();
    
    final Map<String, String> keyMap = {
      "Data": "data",
      "Airtime": "airtime",
      "Cable Tv": "paytv",
      "Electricity": "electricity",
      "Betting": "betting",
      "Epins": "rechargecard",
      "Airtime to cash": "airtimeconverter",
      "Exams": "resultchecker",
      "NIN Validation": "nin_validation",
    };

    bool isEnabled(String buttonText) {
      final key = keyMap[buttonText];
      if (key == null) return true;
      final val = rawServices[key];
      return val == null || val.toString() == '1';
    }

    // Top Up
    if (isEnabled("Data")) categorizedServices['TOP UP']!.add(ButtonModel(icon: AppAsset.internet, text: "Data", link: Routes.DATA_MODULE));
    if (isEnabled("Airtime")) categorizedServices['TOP UP']!.add(ButtonModel(icon: AppAsset.airtime, text: "Airtime", link: Routes.AIRTIME_MODULE));
    if (isEnabled("Epins")) categorizedServices['TOP UP']!.add(ButtonModel(icon: AppAsset.list, text: "Epins", link: "epin"));

    // Bills
    if (isEnabled("Cable Tv")) categorizedServices['BILLS']!.add(ButtonModel(icon: AppAsset.tv, text: "Cable Tv", link: Routes.CABLE_MODULE));
    if (isEnabled("Electricity")) categorizedServices['BILLS']!.add(ButtonModel(icon: AppAsset.electricity, text: "Electricity", link: Routes.ELECTRICITY_MODULE));

    // Earn
    if (isEnabled("Reward Centre")) categorizedServices['EARN']!.add(ButtonModel(icon: AppAsset.gift, text: "Reward Centre", link: Routes.REWARD_CENTRE_MODULE));
    if (isEnabled("Airtime to cash")) categorizedServices['EARN']!.add(ButtonModel(icon: AppAsset.money, text: "Airtime to cash", link: Routes.A2C_MODULE));

    // Others
    if (isEnabled("Betting")) categorizedServices['OTHERS']!.add(ButtonModel(icon: AppAsset.ball, text: "Betting", link: Routes.BETTING_MODULE));
    if (isEnabled("Exams")) categorizedServices['OTHERS']!.add(ButtonModel(icon: AppAsset.capOne, text: "Exams", link: Routes.RESULT_CHECKER_MODULE));
    if (isEnabled("POS")) categorizedServices['OTHERS']!.add(ButtonModel(icon: AppAsset.posIcon, text: "POS", link: Routes.POS_HOME));
    if (isEnabled("NIN Validation")) categorizedServices['OTHERS']!.add(ButtonModel(icon: AppAsset.nin, text: "NIN Validation", link: Routes.NIN_VALIDATION_MODULE));
    if (isEnabled("Virtual Card")) categorizedServices['OTHERS']!.add(ButtonModel(icon: 'assets/icons/bank-card-two.svg', text: "Virtual Card", link: Routes.VIRTUAL_CARD_DETAILS));
    if (isEnabled("Store Front")) categorizedServices['OTHERS']!.add(ButtonModel(icon: AppAsset.service, text: "Store Front", link: Routes.STORE_FRONT));
  }

  Future<void> handleServiceTap(ButtonModel button) async {
    UsageTrackerService.to.incrementUsage(button.text);
    
    if (Get.isRegistered<HomeScreenController>()) {
      await Get.find<HomeScreenController>().handleServiceNavigation(button);
    } else {
      // incase HomeScreenController is not present
      if (button.link.isNotEmpty && button.link != 'epin') {
        Get.toNamed(button.link);
      }
    }
  }
}
