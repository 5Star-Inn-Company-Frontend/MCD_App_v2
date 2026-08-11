import 'package:get/get.dart';
import 'package:mcd/app/modules/store_front_module/store_front_controller.dart';

class StoreFrontBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StoreFrontController>(
      () => StoreFrontController(),
    );
  }
}
