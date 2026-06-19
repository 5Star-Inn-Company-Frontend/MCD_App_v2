import 'package:mcd/app/modules/account_info_module/account_info_module_controller.dart';
import 'package:mcd/app/modules/home_screen_module/home_screen_controller.dart';
import 'package:get/get.dart';
/**
 * GetX Template Generator - fb.com/htngu.99
 * */

class HomeScreenBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeScreenController>(() => HomeScreenController());
    Get.lazyPut(() => AccountInfoModuleController());
  }
}
