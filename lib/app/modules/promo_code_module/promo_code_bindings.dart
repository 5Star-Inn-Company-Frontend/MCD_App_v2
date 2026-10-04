import 'package:get/get.dart';
import 'package:mcd/app/modules/promo_code_module/promo_code_controller.dart';

class PromoCodeBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PromoCodeController>(
      () => PromoCodeController(),
    );
  }
}
