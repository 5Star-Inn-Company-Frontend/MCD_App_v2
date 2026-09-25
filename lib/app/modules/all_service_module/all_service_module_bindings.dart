import 'package:get/get.dart';
import 'package:mcd/app/modules/all_service_module/all_service_module_controller.dart';

class AllServiceModuleBindings implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AllServiceModuleController>(
      () => AllServiceModuleController(),
    );
  }
}
