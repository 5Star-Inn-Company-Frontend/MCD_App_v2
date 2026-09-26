import 'package:get/get.dart';
import 'banner_list_module_controller.dart';

class BannerListModuleBindings implements Bindings {
  @override
  void dependencies() {
    Get.put(BannerListModuleController());
  }
}
