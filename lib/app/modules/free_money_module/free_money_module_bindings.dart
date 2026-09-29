import 'package:get/get.dart';
import 'package:mcd/app/modules/free_money_module/free_money_module_controller.dart';

class FreeMoneyModuleBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FreeMoneyModuleController>(
      () => FreeMoneyModuleController(),
    );
  }
}
