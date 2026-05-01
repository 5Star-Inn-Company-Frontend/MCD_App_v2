import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:developer' as dev;

import '../../routes/app_pages.dart';
import '../../../core/services/deep_link_service.dart';

class SplashScreenController extends GetxController {
  final _obj = ''.obs;
  set obj(value) => _obj.value = value;
  get obj => _obj.value;

  final box = GetStorage();

  @override
  void onInit() {
    super.onInit();
    dev.log('SplashScreenController initialized', name: 'Splash');
    checkAuth();
  }

  Future<void> checkAuth() async {
    await Future.delayed(const Duration(seconds: 2));

    final token = box.read('token');
    dev.log('Token check: ${token != null ? 'exists' : 'null'}', name: 'Splash');

    if (token != null && token.toString().isNotEmpty) {
      dev.log('navigating to HOME_SCREEN', name: 'Splash');
      Get.offAllNamed(Routes.HOME_SCREEN);
    } else {
      dev.log('navigating to LOGIN_SCREEN', name: 'Splash');
      Get.offAllNamed(Routes.LOGIN_SCREEN);
    }


    try {
      final deepLinkService = Get.find<DeepLinkService>();
      deepLinkService.consumePendingDeepLink();
    } catch (e) {
      dev.log('error consuming pending deep link: $e', name: 'Splash');
    }
  }
}
