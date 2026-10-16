import 'package:get/get.dart';
import './mcd_rewards_module_controller.dart';

class McdRewardsModuleBindings implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<McdRewardsModuleController>(
        () => McdRewardsModuleController());
  }
}
